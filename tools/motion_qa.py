#!/usr/bin/env python3
"""Author normal input calibrations and report measurements from actual engine traces."""
import argparse
import json
from pathlib import Path

from gameplay_qa import (INPUT_CLOCK, SIMULATION_HZ, RENDER_COMPARISON_FPS,
                         proof_clock_errors, validate_input_events, whole_number)
from slope_qa import CANDIDATE, DIAGNOSTIC_REQUEST_FIELDS, native_record_errors, read_native_record

FPS = RENDER_COMPARISON_FPS
GRAVITY = {'gravity01': .027, 'gravity05': .172, 'gravity15': .5, 'gravity25': .83}
SPEED = {'speed5': 2.8, 'speed7': 4, 'speed10': 5.5, 'speed15': 8.5}
FIXTURES = ('default', *GRAVITY, *SPEED, 'water', 'ice', 'ladder', 'doublejump', 'zerogravity')


def specification(fixture, fps):
    if fixture not in FIXTURES or type(fps) is not int or fps not in FPS:
        raise ValueError('Unsupported motion fixture/render cap')
    frame = lambda seconds: round(seconds * SIMULATION_HZ)
    duration = 15 if fixture == 'gravity01' else 4
    inputs = [(frame(.5), 6), (frame(.5) + 1, 2), (frame(3), 0)]
    if fixture == 'ice':
        inputs = [(frame(.5), 2), (frame(2), 0)]
    elif fixture == 'ladder':
        inputs = [(frame(.5), 4), (frame(1.5), 0), (frame(2), 2), (frame(3), 0)]
    elif fixture == 'doublejump':
        inputs = [(frame(.5), 4), (frame(.5) + 1, 0), (frame(.9), 4), (frame(.9) + 1, 0)]
    elif fixture == 'zerogravity':
        duration = 5
        inputs = [(frame(.5), 4), (frame(2), 8), (frame(3), 5), (frame(4), 8)]
    return {'room': 'r_gameplay_qa', 'fixture': fixture, 'mode': 'replay',
            'fps': fps, 'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ,
            'seed': 1, 'expect': 'frames', 'maxFrames': frame(duration),
            'traceEvery': 1, 'inputs': [{'frame': f, 'mask': m} for f, m in inputs],
            'requestCandidate': dict(CANDIDATE)}


def validate_request(spec):
    canonical = specification(spec.get('fixture'), spec.get('fps'))
    if set(spec) - DIAGNOSTIC_REQUEST_FIELDS:
        raise ValueError('Unsupported request fields could change the motion fixture')
    if any(spec.get(key) != canonical[key] for key in
           ('room', 'mode', 'expect', 'inputs', 'maxFrames', 'traceEvery', 'inputClock', 'simulationHz')):
        raise ValueError('Motion calibration differs from its canonical fixture/ordinary input schedule')
    if not whole_number(spec.get('traceEvery')) or spec.get('traceEvery') != 1:
        raise ValueError('Motion calibration requires an explicit integer every-tick trace')
    if not whole_number(spec.get('seed', 1)) or spec.get('actor', 'single-player') != 'single-player':
        raise ValueError('Motion calibration requires a normal single-player actor and whole seed')
    if any(key in spec for key in ('challenge', 'specialIndex', 'route', 'routeStartFrame', 'playerColor',
            'slope', 'projectile', 'orientation', 'cameraFixture', 'cameraObservation', 'timingProbe',
            'timingScenario', 'levelSelect', 'endlessMode', 'cosmetics', 'cosmeticFixtures')):
        raise ValueError('Unrelated setup changes the requested motion calibration')
    if spec.get('allowDeaths', False) is not False:
        raise ValueError('Motion calibration must stop on actual death')
    validate_input_events(spec.get('inputs'))
    return spec


def summarize(path, build=None):
    path = Path(path)
    try:
        spec, result, summary, errors, current, hashes = read_native_record(path, build)
        validate_request(spec)
    except (OSError, ValueError, KeyError, TypeError) as error:
        return {'passed': False, 'qualifiesCurrentDiagnostic': False, 'diagnosticOnly': True,
                'errors': ['Native motion record/request binding failed: ' + str(error)], 'run': str(path.resolve())}
    fixture = spec['fixture']
    trace = result.get('trace', [])
    if (result.get('status') != 'observed' or result.get('deaths') != 0 or not trace
            or result.get('simulationFrames') != spec.get('maxFrames')):
        errors.append('Calibration did not finish all normal input frames without death')
    if errors:
        return {'fixture': fixture, 'fps': spec['fps'], 'passed': False, 'errors': errors,
                'qualifiesCurrentDiagnostic': False, 'rawHashes': hashes, 'run': str(path.resolve())}
    if result['initial']['x'] != 96 or result['initial']['y'] != (6940 if fixture == 'ice' else 6972):
        errors.append('Initial player placement differs from the actual requested motion fixture')
    if fixture in GRAVITY and not any(abs(s['gravity'] - GRAVITY[fixture]) < 1e-6 for s in trace):
        errors.append('Requested gravity setting never observed')
    if fixture in SPEED and not any(abs(s['walkSpeed'] - SPEED[fixture]) < 1e-6 for s in trace):
        errors.append('Requested speed setting never observed')
    if fixture == 'water' and not any(s['water'] == 2 and s['breath'] < 450 for s in trace):
        errors.append('No submerged breath consumption')
    if fixture == 'doublejump':
        pulse = round(.9 * SIMULATION_HZ)
        if not any(s['doubleJump'] > 0 for s in trace):
            errors.append('No airborne jump charge collected')
        if not any(s['frame'] >= pulse and s['frame'] <= pulse + 2 and s['vsp'] < -9 for s in trace):
            errors.append('No second normal jump observed')
    if fixture == 'zerogravity' and not any(s['zeroGravity'] == 1 for s in trace):
        errors.append('Zero-gravity pickup never applied')
    if fixture == 'ice':
        release = round(2 * SIMULATION_HZ)
        if not any(release < s['frame'] < release + 5 and s['hsp'] > 0 for s in trace):
            errors.append('No momentum after releasing movement on ice')
    if fixture == 'ladder' and not any(abs(s['vsp'] + 3) < 1e-6 for s in trace):
        errors.append('No normal ladder climb observed')
    return {'fixture': fixture, 'fps': spec['fps'], 'inputClock': spec.get('inputClock'),
            'simulationHz': spec.get('simulationHz'), 'passed': not errors, 'errors': errors,
            'diagnosticOnly': True, 'qualifiesCurrentDiagnostic': not errors and current,
            'matchesCurrentPlayableContent': current, 'qualifiesAsAuthoredContent': False,
            'rawHashes': hashes,
            'heightFromStart': result['initial']['y'] - result['bounds']['minY'],
            'horizontalTravel': result['bounds']['maxX'] - result['bounds']['minX'],
            'simulationFrames': result.get('simulationFrames'), 'renderFrames': result.get('renderFrames'),
            'nativeElapsedUs': result.get('elapsedUs'), 'launcherWallSeconds': summary.get('wallSeconds'),
            'observedRenderFps': summary.get('observedRenderFps'), 'muted': summary.get('muted'),
            'backgroundLaunchRequested': summary.get('backgroundLaunchRequested'), 'sourceIdentity': result['sourceIdentity'],
            'run': str(path.resolve()),
            'limitations': ['Gravity15/speed7 target values equal defaults; value alone does not prove pickup collection.',
                            'Native diagnostic observations do not establish hardware/service checks or level design acceptance.']}


# These are presentation fields in actual player snapshots. Challenge time,
# RNG seed, collision masks and every observed actor/world field remain state.
PRESENTATION_FIELDS = {'sprite', 'animationFrame', 'animationVelocity', 'eyesY'}
STATE_FIELDS = ('status', 'deaths', 'frames', 'simulationFrames', 'normalRules',
                'diagnosticOnly', 'initial', 'final', 'completion', 'bounds', 'trace',
                'events', 'initialNativeActors', 'nativeActors', 'endingContext',
                'practiceObservation', 'specialObservationVersion',
                'traceSchemaVersion', 'traceBoundaries')


def simulation_state(value):
    if isinstance(value, dict):
        presentation = PRESENTATION_FIELDS if {'actor', 'x', 'y', 'bbox'} <= value.keys() else set()
        return {key: simulation_state(item) for key, item in value.items()
                if key not in presentation}
    if isinstance(value, list):
        return [simulation_state(item) for item in value]
    return value


def comparison_errors(spec, result, summary, *, native_errors=None):
    errors = list(native_errors) if native_errors is not None else native_record_errors(spec, result, summary)
    if (not summary.get('normalRuntimeEnd') or not summary.get('compiledPayloadVerified')
            or result.get('status') not in ('complete', 'observed', 'death') or result.get('normalRules') is not True):
        errors.append('Comparison needs a normally ended, payload-bound, normal-rules native result')
    if (spec.get('mode', 'replay') != 'replay' or result.get('inputMode') != 'replay'
            or result.get('inputs') != spec.get('inputs')
            or result.get('sourceIdentity') != spec.get('identity')
            or result.get('fps') != spec.get('fps') or result.get('seed') != spec.get('seed')):
        errors.append('Comparison input, identity, seed or render-cap binding differs')
    try:
        validate_input_events(spec.get('inputs'))
    except (ValueError, TypeError) as error:
        errors.append(str(error))
    if spec.get('traceEvery', 1) != 1:
        errors.append('Simulation comparison requires every observed input tick')
    trace = result.get('trace', [])
    if not isinstance(trace, list) or not trace:
        errors.append('Missing simulation trace')
    else:
        ticks = [sample.get('frame') if isinstance(sample, dict) else None for sample in trace]
        if (any(not whole_number(tick) for tick in ticks)
                or any(a >= b for a, b in zip(ticks, ticks[1:]))):
            errors.append('Simulation trace ticks are malformed, duplicate or out of order')
        required = {'frame', 'room', 'actor', 'x', 'y', 'hsp', 'vsp', 'color', 'bbox'}
        if any(not isinstance(sample, dict) or not required <= sample.keys() for sample in trace):
            errors.append('Simulation trace is missing observed player geometry/state')
    if result.get('status') == 'complete' and not result.get('completion'):
        errors.append('Completion comparison is missing the actual completed state')
    if result.get('status') == 'death':
        from slope_qa import validate_request as validate_slope
        try:
            validate_slope(spec)
            if (spec.get('fixture') != 'slope' or spec['validation']['status'] != 'death'
                    or result.get('deaths') != 1 or result.get('completion') is not None):
                raise ValueError('Death is not the exact requested incompatible-colour slope case')
        except (ValueError, KeyError, TypeError) as error:
            errors.append('Unexplained death cannot be a comparison baseline: ' + str(error))
    return errors


def compare_records(records, *, native_errors=None, current=None):
    """Pure comparison; qualification needs the original file-reader audits."""
    errors = []
    for path, spec, result, summary in records:
        audit = None if native_errors is None else native_errors.get(str(path.resolve()))
        errors.extend(f'{path}: {error}' for error in comparison_errors(spec, result, summary, native_errors=audit))
    if len(records) < 2:
        errors.append('At least two rendering caps are required')
    rates = [spec.get('fps') for _, spec, _, _ in records]
    if any(type(fps) is not int or fps not in FPS for fps in rates):
        errors.append('Comparison rendering caps are missing/malformed')
    elif len(set(rates)) != len(records):
        errors.append('Each comparison run must have a distinct rendering cap')
    baselines = [record for record in records if record[1].get('fps') == 60]
    if len(baselines) != 1:
        errors.append('Exactly one actual fixed60 simulation run at render cap60 is required')
    baseline = baselines[0] if len(baselines) == 1 else (records[0] if records else None)
    if baseline:
        _, base_spec, base_result, _ = baseline
        # Compare every defining request parameter, including actor, geometry,
        # projectile and optional observer setup; exclude only launch/storage,
        # render pacing, captures and candidacy provenance.
        ignored = {'fps', 'output', 'saveRoot', 'captureFrames', 'captureDirectory', 'captureClock',
                   'wallTimeoutSeconds', 'requestCandidate', 'slopeCandidate', 'readinessCandidate',
                   'backgroundLaunchRequested', 'visible', 'headless'}
        request_state = lambda spec: {key: value for key, value in spec.items() if key not in ignored}
        for path, spec, result, _ in records:
            if request_state(spec) != request_state(base_spec):
                errors.append(f'{path}: submitted simulation request differs from baseline')
            if result.get('sourceIdentity') != base_result.get('sourceIdentity'):
                errors.append(f'{path}: compiled source/payload/room binding differs from baseline')
            for field in STATE_FIELDS:
                if simulation_state(result.get(field)) != simulation_state(base_result.get(field)):
                    errors.append(f'{path}: recorded simulation state differs in {field}')
    return {'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ,
            'comparison': 'aligned recorded simulation state; excludes wall/render timing and visual poses',
            'passed': not errors, 'errors': errors, 'baselineRun': str(baseline[0].resolve()) if baseline else None,
            'qualifiesCurrentDiagnostic': not errors and bool(current) and all(current.values()),
            'qualifiesAsAuthoredContent': False,
            'runs': [{'run': str(path.resolve()), 'fps': spec.get('fps'),
                      'simulationFrames': result.get('simulationFrames'),
                      'renderFrames': result.get('renderFrames'),
                      'nativeElapsedUs': result.get('elapsedUs'),
                      'launcherWallSeconds': summary.get('wallSeconds'),
                      'observedRenderFps': summary.get('observedRenderFps')}
                     for path, spec, result, summary in records],
            'limitations': ['Only recorded player and opt-in actor/world state is compared.',
                            'Unobserved actors and absent hardware/service checks are not established.',
                            'State equality is independent of special-draft design acceptance.']}


def compare(runs, build=None):
    """Compare actual aligned simulation states; wall/render timings may differ.

    This observes the recorded player and opt-in actor/world scope. It cannot
    establish equality for actors that were not observed by the native build.
    """
    from slope_qa import verify as slope_verify
    from actor_slope_qa import verify as actor_verify
    records, audits, current, hashes = [], {}, {}, {}
    try:
        for path in map(Path, runs):
            spec, result, summary, errors, matches, raw_hashes = read_native_record(path, build)
            fixture = spec.get('fixture')
            verify = slope_verify if fixture == 'slope' else actor_verify if fixture in ('projectile-slopes', 'troop-slope') else summarize
            report = verify(path, build)
            errors.extend(report['errors'])
            if report.get('rawHashes') is not None and report['rawHashes'] != raw_hashes:
                errors.append('Raw record changed between native binding and fixture assessment')
            records.append((path, spec, result, summary))
            key = str(path.resolve())
            audits[key], current[key], hashes[key] = errors, matches and report.get('qualifiesCurrentDiagnostic') is True, raw_hashes
    except (OSError, ValueError, KeyError, TypeError) as error:
        return {'passed': False, 'qualifiesCurrentDiagnostic': False,
                'errors': ['Native comparison read/build binding failed: ' + str(error)]}
    return {**compare_records(records, native_errors=audits, current=current), 'rawHashes': hashes}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    gen = sub.add_parser('generate')
    gen.add_argument('--output', type=Path, required=True)
    gen.add_argument('--fixture', nargs='+', choices=FIXTURES, default=FIXTURES)
    gen.add_argument('--fps', nargs='+', type=int, choices=FPS, default=FPS)
    report = sub.add_parser('summarize')
    report.add_argument('runs', type=Path, nargs='+')
    report.add_argument('--build', type=Path, required=True)
    comparison = sub.add_parser('compare')
    comparison.add_argument('runs', type=Path, nargs='+')
    comparison.add_argument('--build', type=Path, required=True)
    comparison.add_argument('--output', type=Path)
    args = parser.parse_args()
    if args.command == 'generate':
        args.output.mkdir(parents=True, exist_ok=True)
        for fixture in args.fixture:
            for fps in args.fps:
                with (args.output / f'{fixture}-{fps}.json').open('x') as file:
                    file.write(json.dumps(specification(fixture, fps), indent=2) + '\n')
        print(f'Generated {len(args.fixture) * len(args.fps)} input specifications; no completion claim.')
    elif args.command == 'compare':
        report = compare(args.runs, args.build)
        if args.output:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(json.dumps(report, indent=2) + '\n')
        print(json.dumps(report, indent=2))
        return 0 if report['passed'] else 1
    else:
        reports = [summarize(path, args.build) for path in args.runs]
        print(json.dumps(reports, indent=2))
        return 0 if all(r['passed'] for r in reports) else 1


if __name__ == '__main__':
    raise SystemExit(main())
