#!/usr/bin/env python3
"""Check native projectile lifetimes and unmodified troop AI on real slopes.

Fixtures are diagnostic setup only, never authored-level completion evidence.
No Step code in this tool moves actors or substitutes collision results.
Inputs and lifetimes count 60 Hz simulation ticks; fps caps rendering only.
"""
import argparse
import contextlib
import io
import json
from pathlib import Path

from gameplay_qa import run
from gameplay_qa import INPUT_CLOCK, SIMULATION_HZ, whole_number
from slope_qa import (FPS, ACTOR_PROJECTILES, diagnostic_errors, diagnostic_report,
                      validate_request, write_request, read_native_record, finite, native_flag, CANDIDATE)

PROJECTILES = ACTOR_PROJECTILES


def specifications(rates):
    for fps in rates:
        if type(fps) is not int or fps not in FPS:
            raise ValueError('Unsupported render cap; actor inputs always use 60 Hz')
        for projectile in PROJECTILES:
            spec = dict(room='r_gameplay_qa', fixture='projectile-slopes',
                projectile=projectile, fps=fps, inputClock=INPUT_CLOCK, simulationHz=SIMULATION_HZ,
                seed=1, expect='frames', mode='replay',
                maxFrames=12, inputs=[], traceEvery=1, requestCandidate=dict(CANDIDATE))
            yield f'{projectile}-{fps}', validate_request(spec)
        for orientation in (0, 1):
            spec = dict(room='r_gameplay_qa', fixture='troop-slope',
                orientation=orientation, fps=fps, inputClock=INPUT_CLOCK, simulationHz=SIMULATION_HZ,
                seed=1, expect='frames', mode='replay',
                maxFrames=round(SIMULATION_HZ*2.5),
                inputs=[dict(frame=round(SIMULATION_HZ*.25), mask=1 if orientation == 0 else 2)],
                traceEvery=1, requestCandidate=dict(CANDIDATE))
            yield f'troop-{orientation}-{fps}', validate_request(spec)


def actor_errors(spec, result):
    """Inspect raw actor lifetimes/cells; this pure check is not native proof."""
    errors = []
    def require(condition, message):
        if not condition:
            errors.append(message)
    require(result.get('status') == 'observed' and result.get('deaths') == 0, 'Fixture did not finish without player death')
    require(result.get('simulationFrames') == spec['maxFrames'], 'Actor observation ended before its full logical-tick budget')
    initial = result.get('initialNativeActors', [])
    observations = result.get('nativeActors', [])
    if not isinstance(initial, list) or not isinstance(observations, list):
        return errors + ['Missing native actor initial/lifetime arrays']
    if spec['fixture'] == 'projectile-slopes':
        expected = [{'name': f'{colour}-{orientation}-{empty}', 'object': spec['projectile'],
                     'colour': colour, 'orientation': orientation, 'scenario': 'empty' if empty else 'filled',
                     'x': 1280 + orientation * 640 + ((104 if orientation in (0, 3) else 24) if empty
                                                     else 128 - (104 if orientation in (0, 3) else 24)),
                     'y': 1024 + colour * 1152 + ((24 if orientation < 2 else 104) if empty
                                                 else 128 - (24 if orientation < 2 else 104))}
                    for colour in range(5) for orientation in range(4) for empty in range(2)]
    else:
        expected = [{'name': 'native-chase', 'object': 'o_enemyplayer', 'colour': 4,
                     'orientation': spec['orientation'], 'scenario': 'ascent',
                     'x': 736 if spec['orientation'] == 0 else 192, 'y': 6972}]
    fields = ('name', 'object', 'colour', 'orientation', 'scenario')
    def sample_valid(sample, meta, frame):
        if not isinstance(sample, dict):
            return False
        if (not whole_number(sample.get('frame')) or sample['frame'] != frame
                or not whole_number(sample.get('colour')) or not whole_number(sample.get('orientation'))
                or any(sample.get(key) != meta[key] for key in fields) or not native_flag(sample.get('alive'))):
            return False
        if sample['alive']:
            return (all(finite(sample.get(key)) for key in ('x', 'y'))
                    and isinstance(sample.get('bbox'), list) and len(sample['bbox']) == 4
                    and all(finite(value) for value in sample['bbox'])
                    and native_flag(sample.get('overlap')) and native_flag(sample.get('floor'))
                    and all(finite(sample[key]) for key in ('vsp', 'state', 'reactionTicks', 'move') if key in sample))
        return not any(key in sample for key in ('x', 'y', 'bbox', 'overlap', 'floor', 'vsp', 'state', 'reactionTicks', 'move'))
    # Only authored initial placement is checked here; subsequent motion is
    # observed engine state, never predicted or replaced by a Python model.
    require(len(initial) == len(expected) and all(sample_valid(sample, meta, 0)
            and sample['alive'] and sample.get('x') == meta['x'] and sample.get('y') == meta['y']
            for sample, meta in zip(initial, expected)),
            'Initial actors do not match the unique ordered requested fixture cells/object/geometry')
    count = spec['maxFrames']
    require(len(observations) == count * len(expected)
            and all(sample_valid(sample, expected[index % len(expected)], index // len(expected))
                    for index, sample in enumerate(observations)),
            'Native actor lifetime coverage is missing, duplicate, reordered or differs from the requested cells')
    if errors:
        return errors
    if spec['fixture'] == 'projectile-slopes':
        for actor in initial:
            filled = actor['scenario'] == 'filled'
            require(actor.get('alive') and actor.get('overlap') == filled, f"Invalid initial native mask: {actor['name']}")
            trace = [state for state in observations if state['name'] == actor['name']]
            require(bool(trace), f"No observed actor lifetime: {actor['name']}")
            if not trace:
                continue
            if filled:
                require(not trace[0]['alive'], f"Projectile survived inside filled triangle: {actor['name']}")
            else:
                require(len(trace) >= 2 and all(state['alive'] and not state['overlap'] for state in trace[:2]),
                        f"Projectile incorrectly blocked in empty triangle half: {actor['name']}")
            died = False
            for state in trace:
                require(not died or not state['alive'], f"Destroyed actor reappeared without fixture creation: {actor['name']}")
                died = died or not state['alive']
    else:
        require(len(initial) == 1 and initial[0]['object'] == 'o_enemyplayer', 'No original troop instance')
        live = [state for state in observations if state['alive']]
        require(len(live) == len(observations) and bool(live), 'Troop disappeared during chase')
        require(all(not state['overlap'] for state in live), 'Troop embedded in a filled triangle')
        require(any(state['floor'] for state in live), 'Troop never used diagonal support')
        require(any(state['y'] < 6885 for state in live), 'Troop never reached the high end of the slope')
        require(any(state.get('state') == 1 for state in live), 'No native chase state observed')
    return errors


def verify(target, build=None):
    target = Path(target)
    try:
        spec, result, summary, native_errors, current, hashes = read_native_record(target, build)
    except (OSError, ValueError, KeyError, TypeError) as error:
        return {'passed': False, 'diagnosticOnly': True, 'qualifiesCurrentDiagnostic': False,
                'errors': ['Native actor record/build read failed: ' + str(error)], 'run': str(target.resolve())}
    if spec.get('fixture') not in ('projectile-slopes', 'troop-slope'):
        raise ValueError('Not a native projectile/troop slope diagnostic')
    errors = diagnostic_errors(spec, result, summary, native_errors=native_errors)
    if not errors:
        errors.extend(actor_errors(spec, result))
    return {**diagnostic_report(spec, result, summary, errors, current), 'rawHashes': hashes,
            'run': str(target.resolve()), 'fixture': spec['fixture'],
            'projectile': spec.get('projectile'), 'orientation': spec.get('orientation')}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--fps', type=int, nargs='+', choices=FPS, default=[60, 150],
                        help='Render caps; native actor schedules/lifetimes always use 60 Hz')
    parser.add_argument('--build-snapshot', action='store_true')
    parser.add_argument('--headless', action='store_true')
    args = parser.parse_args()
    if 60 not in args.fps or len(set(args.fps)) != len(args.fps):
        parser.error('Use unique render caps including actual60 for the native state comparator')
    args.output.mkdir(parents=True, exist_ok=False)
    requests = args.output / 'specs'
    requests.mkdir()
    reports = []
    comparisons, groups = [], {}
    rates = [60, *(fps for fps in args.fps if fps != 60)]
    for name, spec in specifications(rates):
        path = requests / (name + '.json')
        write_request(path, spec)
        target = args.output / name
        with contextlib.redirect_stdout(io.StringIO()):
            run(args.build, path, target, args.build_snapshot, headless=args.headless)
        summary = json.loads((target / 'summary.json').read_text())
        if summary['status'] == 'crash-or-no-evidence':
            raise RuntimeError(f'Native crash; inspect {target}')
        report = verify(target, args.build)
        reports.append(report)
        (args.output / 'actor-report.json').write_text(json.dumps(reports, indent=2) + '\n')
        print(f"{name}: {'PASS' if report['passed'] else 'FAIL'} {report['errors']}", flush=True)
        if not report['passed']:
            return 1
        key = (spec['fixture'], spec.get('projectile'), spec.get('orientation'))
        groups.setdefault(key, []).append(target)
        if len(groups[key]) > 1:
            from motion_qa import compare
            comparison = compare([groups[key][0], target], args.build)
            comparisons.append(comparison)
            (args.output / 'actor-comparisons.json').write_text(json.dumps(comparisons, indent=2) + '\n')
            if not comparison['passed']:
                print(f'{name}: native state comparison FAIL {comparison["errors"]}', flush=True)
                return 1
    (args.output / 'comparison-status.json').write_text(json.dumps({
        'baselineRenderCap': 60, 'crossCapCompared': len(rates) > 1,
        'comparisonCount': len(comparisons), 'qualifiesAsAuthoredContent': False}, indent=2) + '\n')
    return 0 if all(report['passed'] for report in reports) else 1


if __name__ == '__main__':
    raise SystemExit(main())
