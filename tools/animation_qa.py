#!/usr/bin/env python3
"""Write input specs and inspect actual native Draw observations; never launch."""
import argparse
import json
import math
import struct
from collections import Counter
from pathlib import Path

from gameplay_qa import INPUT_CLOCK, SIMULATION_HZ, validate_input_events, whole_number
from slope_qa import CANDIDATE, DIAGNOSTIC_REQUEST_FIELDS, native_flag, read_native_record

FPS = (60, 75, 100, 120, 144, 150)
ACTORS = ('single-player', 'local-multiplayer')
ONEWAYS = tuple('o_oneway' + direction + 'block' for direction in ('up', 'down', 'left', 'right'))
EVENTS = ((0, 0), (20, 2), (50, 1), (80, 6), (81, 2), (125, 0),
          (140, 5), (141, 1), (185, 0), (190, 2), (200, 34), (201, 2),
          (230, 34), (231, 2), (250, 0), (260, 3), (270, 0))


def specification(fps, actor='single-player'):
    if type(fps) is not int or fps not in FPS or actor not in ACTORS:
        raise ValueError('Unsupported animation render cap or actor')
    inputs = [{'frame': frame, 'mask': mask} for frame, mask in EVENTS
              if actor != 'local-multiplayer' or frame not in (200, 201, 230, 231)]
    return dict(room='r_gameplay_qa', fixture='default', mode='replay', fps=fps,
                actor=actor, inputClock=INPUT_CLOCK, simulationHz=SIMULATION_HZ,
                seed=1, expect='frames', maxFrames=280, traceEvery=1,
                animationObservation=True, inputs=inputs, requestCandidate=dict(CANDIDATE))


def validate_request(spec):
    canonical = specification(spec.get('fps'), spec.get('actor', 'single-player'))
    if set(spec) - (DIAGNOSTIC_REQUEST_FIELDS | {'animationObservation'}):
        raise ValueError('Unrelated animation setup fields are unsupported')
    if any(spec.get(key, canonical[key] if key == 'actor' else None) != canonical[key]
           for key in canonical if key != 'requestCandidate'):
        raise ValueError('Animation fixture/input schedule differs from its canonical request')
    if spec.get('allowDeaths', False) is not False:
        raise ValueError('Animation diagnostic must stop on actual death')
    validate_input_events(spec['inputs'])


def finite(value):
    return type(value) in (int, float) and math.isfinite(value)


def float32(value):
    return struct.unpack('<f', struct.pack('<f', value))[0]


def inspect_run(run, build=None):
    try:
        spec, result, summary, errors, current, hashes = read_native_record(run, build)
        validate_request(spec)
    except (OSError, ValueError, KeyError, TypeError) as error:
        return dict(passed=False, diagnosticOnly=True, qualifiesCurrentDiagnostic=False, errors=[str(error)])
    errors = list(errors)
    def require(condition, message):
        if not condition and message not in errors and len(errors) < 80:
            errors.append(message)
    require(result.get('status') == 'observed' and result.get('deaths') == 0
            and result.get('simulationFrames') == 280, 'Incomplete/dead animation calibration')
    samples = result.get('animationDraws')
    require(isinstance(samples, list) and bool(samples), 'Missing actual native Draw observations')
    samples = samples if isinstance(samples, list) else []
    actor = 'o_playerMU' if spec.get('actor') == 'local-multiplayer' else 'o_player'
    required = (*ONEWAYS, 'o_timecounter', 'o_ammocounter')
    rates = {**dict.fromkeys(ONEWAYS, 1), 'o_timecounter': .4,
             'o_ammocounter': .2 if actor == 'o_player' else 0}
    poses, holds, advances, freezes = Counter(), Counter(), Counter(), Counter()
    tails, gaps = Counter(), []
    no_tick, movement_holds, previous = 0, 0, None
    for sample in samples:
        valid = (isinstance(sample, dict) and sample.get('actor') == actor
                 and all(whole_number(sample.get(key)) for key in ('tickId', 'outerId', 'frame'))
                 and all(native_flag(sample.get(key)) for key in ('tick', 'paused', 'left', 'right'))
                 and whole_number(sample.get('pose')) and finite(sample.get('velocity'))
                 and isinstance(sample.get('animations'), list))
        require(valid, 'Malformed actual Draw/player observation')
        if not valid:
            continue
        animations = sample['animations']
        state = {entry.get('object'): entry for entry in animations if isinstance(entry, dict)}
        require(len(state) == len(animations), 'Duplicate/malformed observed animation actors')
        if sample['frame'] >= 3:
            require(set(state) == set(required), 'Missing real one-way/clock/ammo Draw actors')
        require(all(finite(entry.get('phase')) and finite(entry.get('speed'))
                    and entry.get('tracked') in (True, 1) for entry in state.values()),
                'Real custom-drawn animation is untracked or has invalid phase/speed')
        if sample['frame'] >= 3:
            for name in state.keys() & rates.keys():
                speed = state[name].get('speed')
                expected = rates[name] if sample['tick'] and not sample['paused'] else 0
                require(finite(speed) and float32(speed) == float32(expected), f'Wrong presented animation speed for {name}')
        if not sample['paused']:
            left, right, velocity = bool(sample['left']), bool(sample['right']), sample['velocity']
            direction = 0 if left == right else (1 if right else 2)
            threshold = .1 if actor == 'o_playerMU' else .3
            vertical = 6 if velocity < -threshold else (3 if velocity > threshold else 0)
            if vertical or velocity == 0:
                require(sample['pose'] == vertical + direction,
                        f"Wrong rendered player pose at frame {sample['frame']}: {sample['pose']}")
                poses[sample['pose']] += 1
        if previous is not None:
            prior, prior_state = previous
            require(sample['outerId'] > prior['outerId'] and sample['tickId'] >= prior['tickId']
                    and sample['frame'] >= prior['frame'], 'Draw observations repeat/misorder native clocks')
            tick_delta = int(sample['tickId'] - prior['tickId'])
            same_tick = tick_delta == 0
            if not sample['tick']:
                no_tick += 1
                if same_tick:
                    require(sample['pose'] == prior['pose'], 'Render-only frame changed player pose')
                    movement_holds += int(not sample['paused'] and sample['pose'] in (1, 2))
            steady = sample['paused'] == prior['paused']
            for name in state.keys() & prior_state.keys():
                phase, old, speed = (state[name].get('phase'), prior_state[name].get('phase'),
                                     prior_state[name].get('speed'))
                if not all(finite(value) for value in (phase, old, speed)):
                    continue
                # Native animation advances after the previous outer frame's
                # Draw. A skipped current frame can expose that owned tail.
                if sample['outerId'] == prior['outerId'] + 1:
                    require(float32(phase) == float32(old + speed), f'Wrong prior native animation tail for {name}')
                    tails[name] += 1
                if not prior['tick'] and tick_delta == int(sample['tick']):
                    require(float32(phase) == float32(old), f'Unowned render-only animation advance for {name}')
                    holds[name] += 1
                if steady and sample['paused'] and prior['frame'] > 202 and sample['frame'] < 230:
                    require(float32(phase) == float32(old), f'Steady pause advanced {name}')
                    freezes[name] += 1
                elif steady and not sample['paused'] and name in rates:
                    count = tick_delta + int(prior['tick']) - int(sample['tick'])
                    require(count >= 0, 'Native animation tail ownership goes backwards')
                    expected = float32(old)
                    for _ in range(max(0, count)):
                        expected = float32(expected + float32(rates[name]))
                    require(float32(phase) == expected,
                            f'Wrong active per-tick animation rate for {name}')
                    require(float32(speed) == float32(rates[name] if prior['tick'] else 0),
                            f'Wrong active native animation speed for {name}')
                    advances[name] += 1
        previous = (sample, state)
    require(all(poses[pose] >= 2 for pose in (0, 1, 2, 4, 5, 7, 8)),
            'Missing rendered idle/right/left/jump/fall pose coverage')
    require(any(sample.get('frame', -1) in range(262, 270) and sample.get('pose') == 0
                and sample.get('left') and sample.get('right') for sample in samples if isinstance(sample, dict)),
            'Both-direction grounded idle pose was not presented')
    require(all(advances[name] >= 100 for name in rates), 'Too few active real animation-rate observations')
    if actor == 'o_player':
        require(all(freezes[name] >= 10 for name in required), 'Too few steady-pause animation observations')
    if spec['fps'] > SIMULATION_HZ:
        if no_tick < 10:
            gaps.append('Too few actual render-only Draw samples at the requested cap')
        if movement_holds < 2:
            gaps.append('Too few same-tick render-only directional player pose observations')
        if not all(holds[name] >= 10 for name in required):
            gaps.append('Too few skipped prior-frame tails proving unowned animation freeze')
    return dict(passed=not errors, diagnosticOnly=True, qualifiesAsAuthoredContent=False,
                qualifiesCurrentDiagnostic=not errors and current and not gaps, currentChecksPassed=not errors and current,
                matchesCurrentPlayableContent=current, fullyCovered=not errors and not gaps, coverageGaps=gaps,
                errors=errors, run=str(Path(run).resolve()), fps=spec['fps'], actor=actor,
                drawSamples=len(samples), poseSamples=dict(poses), renderOnlySamples=no_tick,
                renderOnlyMovementSamples=movement_holds, animationHolds=dict(holds),
                nativeTailChecks=dict(tails), activeRateChecks=dict(advances), pausedFreezeChecks=dict(freezes), rawHashes=hashes,
                observedRenderFps=summary.get('observedRenderFps'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    request = commands.add_parser('spec', help='Write an unverified normal-input request')
    request.add_argument('--fps', type=int, choices=FPS, required=True)
    request.add_argument('--actor', choices=ACTORS, default='single-player')
    request.add_argument('--output', type=Path)
    check = commands.add_parser('inspect', help='Rehash native binding and assess actual Draw observations')
    check.add_argument('runs', nargs='+', type=Path)
    check.add_argument('--build', type=Path, required=True)
    args = parser.parse_args()
    if args.command == 'spec':
        text = json.dumps(specification(args.fps, args.actor), indent=2) + '\n'
        if args.output:
            args.output.write_text(text)
        else:
            print(text, end='')
        return 0
    reports = [inspect_run(run, args.build) for run in args.runs]
    print(json.dumps(reports, indent=2))
    return 0 if all(report['passed'] for report in reports) else 1


if __name__ == '__main__':
    raise SystemExit(main())
