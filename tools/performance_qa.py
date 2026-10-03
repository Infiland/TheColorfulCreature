#!/usr/bin/env python3
"""Inspect native frame-work evidence and compare unchanged normal gameplay.

This command never builds or launches the game. Measured spans are native wall
work between explicit event markers, not process CPU, GPU or presentation time.
Frame-budget observations do not establish that a level can be completed.
"""
import argparse
import json
import math
import re
import statistics
from pathlib import Path

from gameplay_qa import (INPUT_CLOCK, SIMULATION_HZ, observed_render_fps,
                         proof_clock_errors, validate_input_events, whole_number)
from native_evidence import file_hash
from slope_qa import finite_json, native_flag, trace_observation_errors, trace_source_contract_errors
from tcc_project import ROOT, PROJECT, level_content_identity, read_yy, source_identity
from timing_qa import binding

CORE_PHASES = ('beginRegistry', 'beginTracked', 'beginInput', 'beginFinish',
               'nativeEvents', 'endRegistry', 'endGameplay', 'endFinish')
DRAW_PHASES = ('drawPrepare', 'drawWorld', 'drawRestore', 'drawGui')
PHASES = CORE_PHASES + ('beforeDrawGap',) + DRAW_PHASES
COUNTERS = ('registerChecks', 'alarmChecks', 'activationScans', 'pendingChecks')
REQUEST_FIELDS = {'room', 'challenge', 'mode', 'fps', 'inputClock', 'simulationHz',
                  'seed', 'expect', 'maxFrames', 'traceEvery', 'allowDeaths',
                  'diagnosticOnly', 'inputs', 'performanceObservation',
                  'identity', 'output', 'saveRoot', 'wallTimeoutSeconds'}
COMPARISON_EXCLUSIONS = ('player.challengeRunId',
                         'events[].world.nativeClock.nativeElapsedUs',
                         'events[].world.nativeClock.outerId')


def finite(value):
    return type(value) in (int, float) and math.isfinite(value)


def read_record(run_path, build_path):
    """Bind original request, runtime, log, saves, frozen source and app bytes."""
    run = Path(run_path).resolve()
    paths = [run / name for name in ('spec.json', 'runtime.json', 'summary.json', 'runtime.log')]
    hashes = {path.name: file_hash(path) for path in paths}
    spec, result, summary = [json.loads(path.read_text()) for path in paths[:3]]
    if not all(isinstance(document, dict) for document in (spec, result, summary)):
        raise ValueError('Request, runtime and summary must be objects')
    log = paths[3].read_text(errors='replace')
    bound = binding(build_path)
    errors = proof_clock_errors(spec, result, summary)
    errors += trace_observation_errors(spec, result)
    errors += trace_source_contract_errors(bound['snapshot'])

    def require(condition, message):
        if not condition:
            errors.append(message)

    require(all(finite_json(document) for document in (spec, result, summary)), 'Non-finite native JSON')
    require(not any('offlineFixture' in document for document in (spec, result, summary)),
            'Offline fixtures cannot qualify as native evidence')
    require(not set(spec) - REQUEST_FIELDS, 'Unsupported performance request fields: ' +
            ', '.join(sorted(set(spec) - REQUEST_FIELDS)))
    snapshot = Path(bound['snapshot'])
    rooms = {entry['id']['name'] for entry in read_yy(snapshot / PROJECT.name)['resources']
             if entry['id']['path'].startswith('rooms/')}
    campaign = (isinstance(spec.get('room'), str) and re.fullmatch(r'r_lvl\d+', spec['room'])
                and spec['room'] in rooms and 'challenge' not in spec)
    lunar = ('room' not in spec and type(spec.get('challenge')) is int and spec['challenge'] == 19)
    room = spec.get('room') if campaign else 'r_challengelevel'
    require(bool(campaign or lunar), 'Only registered campaign rooms or normal Lunar Base challenge 19 are supported')
    require(type(spec.get('fps')) is int and 30 <= spec['fps'] <= 1000,
            'Render cap must be an integer from 30 to 1000')
    require(spec.get('mode') == 'replay' and result.get('inputMode') == 'replay'
            and result.get('inputs') == spec.get('inputs') and spec.get('expect') == 'frames'
            and type(spec.get('traceEvery')) is int and spec['traceEvery'] == 1
            and spec.get('allowDeaths', False) is False,
            'Require normal replay, exact inputs, frame budget and full no-death trace')
    require(type(spec.get('performanceObservation')) is bool,
            'Passive performance observation must be explicitly true or false')
    require(type(spec.get('diagnosticOnly', False)) is bool,
            'diagnosticOnly must be boolean; ordinary workloads may use false')
    try:
        validate_input_events(spec.get('inputs'))
    except (TypeError, ValueError) as error:
        errors.append('Invalid inputs: ' + str(error))
    require(whole_number(spec.get('seed', 1)) and result.get('seed') == spec.get('seed', 1)
            and result.get('fps') == spec.get('fps'), 'Seed/render cap binding differs')
    require(result.get('format') == 'tcc.gameplay-evidence'
            and whole_number(result.get('schemaVersion')) and result['schemaVersion'] == 1
            and whole_number(result.get('inputMaskVersion')) and result['inputMaskVersion'] == 2,
            'Missing native gameplay schema')
    require(result.get('normalRules') is True
            and result.get('diagnosticOnly') == spec.get('diagnosticOnly', False)
            and result.get('muted') is True
            and summary.get('muted') is True, 'Normal rules and muted native run are required')
    require(summary.get('normalRuntimeEnd') is True and summary.get('timedOut') is False
            and summary.get('compiledPayloadVerified') is True and '###game_end###0' in log,
            'Native run did not end normally with bound compiled payload')
    require(result.get('status') == 'observed' and result.get('reason') == 'Frame limit reached'
            and 'TCC_GAMEPLAY_QA_OBSERVED: Frame limit reached' in log
            and result.get('deaths') == 0 and result.get('completion') is None
            and whole_number(spec.get('maxFrames'), 1)
            and result.get('simulationFrames') == spec.get('maxFrames'),
            'Require full frame budget, zero deaths, and observed non-completion status')
    require(all(summary.get(key) == result.get(key) for key in ('status', 'reason', 'frames', 'deaths', 'bounds'))
            and summary.get('requestedRenderFps') == spec.get('fps')
            and summary.get('requestedInputClock') == INPUT_CLOCK
            and summary.get('requestedSimulationHz') == SIMULATION_HZ,
            'Launcher request/status/state binding differs')
    require(finite(result.get('elapsedUs')) and result['elapsedUs'] >= 0
            and summary.get('nativeElapsedUs') == result.get('elapsedUs')
            and finite(summary.get('wallSeconds')) and summary['wallSeconds'] >= 0,
            'Native/launcher elapsed measurements are absent or unbound')
    for field, count_field in (('renderFrameDeltasUs', 'renderFrames'),
                               ('simulationFrameDeltasUs', 'simulationFrames')):
        values = result.get(field)
        require(isinstance(values, list) and whole_number(result.get(count_field))
                and len(values) == result[count_field]
                and all(finite(value) and value >= 0 for value in values), 'Invalid native clock deltas: ' + field)
    require(result.get('frameDeltasUs') == result.get('simulationFrameDeltasUs'), 'Simulation delta alias differs')

    def sample_valid(sample):
        return (isinstance(sample, dict) and sample.get('room') == room and sample.get('actor') == 'o_player'
                and all(finite(sample.get(field)) for field in
                        ('x', 'y', 'hsp', 'vsp', 'direction', 'motionSpeed', 'animationFrame',
                         'animationVelocity', 'eyesY', 'gravity', 'walkSpeed', 'color', 'water', 'breath',
                         'doubleJump', 'zeroGravity', 'ammo', 'keysRemaining', 'challengeTime',
                         'challengeDeaths', 'lives', 'seed'))
                and all(native_flag(sample.get(field)) for field in
                        ('grounded', 'paused', 'cheats', 'revealHidden', 'challengePractice'))
                and not sample['cheats'] and not sample['revealHidden']
                and not sample['challengePractice'] and isinstance(sample.get('sprite'), str)
                and isinstance(sample.get('bbox'), list) and len(sample['bbox']) == 4
                and all(finite(value) for value in sample['bbox'])
                and sample['bbox'][0] <= sample['bbox'][2] and sample['bbox'][1] <= sample['bbox'][3])

    trace, initial = result.get('trace'), result.get('initial')
    require(sample_valid(initial) and initial.get('frame') == 0, 'Missing/invalid normal initial player state')
    require(isinstance(trace, list) and bool(trace) and all(sample_valid(row) for row in trace),
            'Invalid normal per-tick player state')
    require(isinstance(trace, list) and bool(trace) and result.get('final') == trace[-1], 'Final state differs from last tick')
    if sample_valid(initial) and isinstance(trace, list) and trace and all(sample_valid(row) for row in trace):
        xs, ys = [initial['x']] + [row['x'] for row in trace], [initial['y']] + [row['y'] for row in trace]
        require(result.get('bounds') == dict(minX=min(xs), maxX=max(xs), minY=min(ys), maxY=max(ys)),
                'Bounds differ from exact native player observations')
    content = level_content_identity(spec, snapshot)
    expected = {**bound['source'], 'executableSha256': bound['executableSha256'],
                'artifactSha256': bound['artifact']['sha256'], 'levelContentSha256': content}
    require(spec.get('identity') == result.get('sourceIdentity') == expected, 'Frozen source/app/content binding differs')
    require(summary.get('sourceIdentity') == bound['source']
            and summary.get('executableSha256') == bound['executableSha256']
            and summary.get('levelContentSha256') == content, 'Launcher hash binding differs')
    require(spec.get('output') == str(run / 'runtime.json')
            and spec.get('saveRoot') == result.get('isolatedSaveRoot') == str(run / 'saves')
            and (run / 'saves').is_dir() and ROOT != run and ROOT not in run.parents,
            'Original output/save root is not isolated outside checkout')
    storage = summary.get('evidenceStorage', {})
    require(not storage.get('sha256') or storage['sha256'] == hashes['runtime.json'], 'Launcher raw runtime hash differs')
    require(hashes == {path.name: file_hash(path) for path in paths}, 'Evidence changed during inspection')
    current = (source_identity(ROOT)['physicsSha256'] == bound['source']['physicsSha256']
               and level_content_identity(spec, ROOT) == content)
    return spec, result, errors, current, hashes, bound


def distribution(values):
    if not values:
        return None
    ordered = sorted(values)
    return {'mean': statistics.mean(values), 'p50': statistics.median(values),
            'p95': ordered[int((len(ordered) - 1) * .95)]}


def profile(result, warmup, enabled=True):
    errors, gaps = [], []
    evidence = result.get('performanceObservation')
    if not isinstance(evidence, dict) or evidence.get('measurement') != 'native wall-work spans; not process CPU time':
        return {}, ['Missing explicit wall-work performance measurement'], gaps
    rows = evidence.get('rows')
    if not enabled:
        if rows != [] or evidence.get('truncated') is not False:
            errors.append('Disabled passive profiler exported measurements or a truncation flag')
        return {'enabled': False, 'rawRows': 0, 'warmupSimulationTicks': warmup,
                'eligibleRows': 0, 'incompleteRows': 0}, errors, [
                    'Performance observation is explicitly disabled; gameplay-only audit has no wall-work spans']
    if not isinstance(rows, list) or not rows or len(rows) > 4096 or evidence.get('truncated') is not False:
        return {}, ['Missing, unbounded or truncated performance rows'], gaps
    valid = []
    previous = None
    for index, row in enumerate(rows):
        fields = ('frame', 'outerId', 'tickId', 'instanceCount', 'trackedCount')
        if (not isinstance(row, dict) or not all(whole_number(row.get(field)) for field in fields)
                or not all(native_flag(row.get(field)) for field in ('tick', 'drawn', 'complete'))
                or not isinstance(row.get('phasesUs'), dict)
                or set(row['phasesUs']) - set(PHASES)
                or not all(finite(value) and value >= 0 for value in row['phasesUs'].values())
                or not isinstance(row.get('counters'), dict)
                or set(row['counters']) != set(COUNTERS)
                or not all(whole_number(value) for value in row['counters'].values())):
            errors.append(f'Malformed performance row {index}')
            continue
        if (previous and (row['outerId'] <= previous['outerId']
                          or row['tickId'] < previous['tickId'] or row['frame'] < previous['frame'])):
            errors.append(f'Non-monotonic/duplicate performance clocks at row {index}')
        previous = row
        if (not whole_number(result.get('simulationFrames'), 1)
                or row['frame'] >= result['simulationFrames']):
            errors.append(f'Performance frame exceeds observed simulation budget at row {index}')
        if row['complete'] and not set(CORE_PHASES) <= set(row['phasesUs']):
            errors.append(f'Complete performance row lacks core event spans at row {index}')
        if set(DRAW_PHASES) <= set(row['phasesUs']) and not row['drawn']:
            errors.append(f'Actual Draw spans contradict scheduled Draw flag at row {index}')
        if row['complete'] and row['frame'] >= warmup:
            valid.append(row)

    def category(selected):
        return {'rows': len(selected),
                'phaseSpansUs': {phase: {**distribution(values), 'samples': len(values)}
                    for phase in PHASES if (values := [row['phasesUs'][phase] for row in selected if phase in row['phasesUs']])},
                'counterMeans': {field: statistics.mean(row['counters'][field] for row in selected)
                                 for field in COUNTERS} if selected else {},
                'instanceCount': distribution([row['instanceCount'] for row in selected]),
                'trackedCount': distribution([row['trackedCount'] for row in selected])}

    tick = [row for row in valid if row['tick']]
    skipped = [row for row in valid if not row['tick']]
    drawn = [row for row in valid if set(DRAW_PHASES) <= set(row['phasesUs'])]
    partial = [row for row in valid if set(DRAW_PHASES) & set(row['phasesUs'])
               and not set(DRAW_PHASES) <= set(row['phasesUs'])]
    if not tick:
        errors.append('No complete post-warmup tick measurements')
    if not drawn:
        errors.append('No complete post-warmup actual Draw measurements')
    if not skipped:
        gaps.append('Native host produced no complete post-warmup skipped tick rows')
    if partial:
        gaps.append(f'{len(partial)} complete rows have only partial Draw event observations')
    return {'enabled': True, 'rawRows': len(rows), 'warmupSimulationTicks': warmup, 'eligibleRows': len(valid),
            'incompleteRows': sum(not row.get('complete') for row in rows if isinstance(row, dict)),
            'tick': category(tick), 'skipped': category(skipped), 'actualDraw': category(drawn)}, errors, gaps


def inspect_run(run_path, build_path=None, warmup=120):
    if not whole_number(warmup) or build_path is None:
        raise ValueError('Explicit build binding and nonnegative whole warmup ticks are required')
    spec, result, errors, current, hashes, bound = read_record(run_path, build_path)
    enabled = spec.get('performanceObservation') is True
    measurements, profile_errors, gaps = profile(result, warmup, enabled)
    errors += profile_errors
    return {'passed': not errors, 'errors': errors, 'coverageGaps': gaps, 'fullyCovered': not errors and not gaps,
            'run': str(Path(run_path).resolve()), 'buildBinding': bound, 'rawSha256': hashes,
            'matchesCurrentPlayableContent': current, 'requestedRenderFps': spec['fps'],
            'observedRenderFps': observed_render_fps(result), 'simulationFrames': result.get('simulationFrames'),
            'measurement': ('Native wall-work event spans; excludes unobserved engine, driver, GPU and presentation work'
                            if enabled else None),
            'qualifiesAsCompletion': False, 'performance': measurements}


def gameplay_projection(value, path=()):
    """Omit only run IDs and explicitly observed wall/render-clock metadata."""
    if isinstance(value, dict):
        return {key: gameplay_projection(item, path + (key,)) for key, item in value.items()
                if not (key == 'challengeRunId' and value.get('actor') == 'o_player')
                and not (path[-2:] == ('world', 'nativeClock') and key in ('nativeElapsedUs', 'outerId'))}
    if isinstance(value, list):
        return [gameplay_projection(item, path) for item in value]
    return value


def differences(before, after, path='', limit=8):
    if isinstance(before, dict) and isinstance(after, dict) and before.keys() == after.keys():
        if not any(differences(before[key], after[key], limit=1) for key in before):
            return []
    elif isinstance(before, list) and isinstance(after, list) and len(before) == len(after):
        if not any(differences(a, b, limit=1) for a, b in zip(before, after)):
            return []
    elif (type(before) is type(after) and before == after
          or type(before) in (int, float) and type(after) in (int, float) and before == after):
        return []
    if isinstance(before, dict) and isinstance(after, dict):
        errors = []
        for key in sorted(set(before) | set(after)):
            if key not in before or key not in after:
                errors.append(f'{path}.{key}: field exists in only one recording')
            else:
                errors += differences(before[key], after[key], path + '.' + key, limit)
            if len(errors) >= limit:
                break
        return errors[:limit]
    if isinstance(before, list) and isinstance(after, list):
        if len(before) != len(after):
            return [f'{path}: lengths {len(before)} != {len(after)}']
        return [item for index, pair in enumerate(zip(before, after))
                for item in differences(*pair, f'{path}[{index}]', limit)][:limit]
    return [f'{path}: {before!r} != {after!r}']


def compare_runs(baseline_path, candidate_path, baseline_build, candidate_build, warmup=120):
    baseline = inspect_run(baseline_path, baseline_build, warmup)
    candidate = inspect_run(candidate_path, candidate_build, warmup)
    pairs = [(json.loads((Path(path) / name).read_text()), json.loads((Path(other) / name).read_text()))
             for name in ('spec.json', 'runtime.json') for path, other in [(baseline_path, candidate_path)]]
    errors = [label + ': ' + error for label, report in [('baseline', baseline), ('candidate', candidate)]
              for error in report['errors']]
    if not candidate['matchesCurrentPlayableContent']:
        errors.append('Candidate does not match freshly hashed current playable content')
    ignored = {'output', 'saveRoot', 'identity', 'performanceObservation'}
    requests = [{key: value for key, value in spec.items() if key not in ignored} for spec in pairs[0]]
    errors += differences(*requests, 'request')
    for field in ('initial', 'final', 'trace', 'events', 'bounds', 'deaths', 'completion'):
        states = [gameplay_projection(result.get(field)) for result in pairs[1]]
        errors += differences(*states, field)
    # Detect evidence mutations between independent inspection and comparison.
    for report in (baseline, candidate):
        if any(file_hash(Path(report['run']) / name) != digest for name, digest in report['rawSha256'].items()):
            errors.append('Evidence changed during comparison: ' + report['run'])
    changes = {}
    for category in ('tick', 'skipped', 'actualDraw'):
        before = baseline['performance'].get(category, {}).get('phaseSpansUs', {})
        after = candidate['performance'].get(category, {}).get('phaseSpansUs', {})
        changes[category] = {phase: {metric + 'ChangePercent':
                100 * (after[phase][metric] / before[phase][metric] - 1) if before[phase][metric] else None
                for metric in ('mean', 'p50', 'p95')} for phase in sorted(before.keys() & after.keys())}
    return {'passed': not errors, 'errors': errors[:24], 'errorCount': len(errors),
            'gameplayComparisonExclusions': list(COMPARISON_EXCLUSIONS), 'qualifiesAsCompletion': False,
            'baseline': baseline, 'candidate': candidate, 'phaseChanges': changes}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    inspect = commands.add_parser('inspect')
    inspect.add_argument('run', type=Path)
    inspect.add_argument('--build', type=Path, required=True)
    compare = commands.add_parser('compare')
    compare.add_argument('baseline', type=Path)
    compare.add_argument('candidate', type=Path)
    compare.add_argument('--baseline-build', type=Path, required=True)
    compare.add_argument('--candidate-build', type=Path, required=True)
    for command in (inspect, compare):
        command.add_argument('--warmup', type=int, default=120)
    args = parser.parse_args()
    try:
        report = (inspect_run(args.run, args.build, args.warmup) if args.command == 'inspect' else
                  compare_runs(args.baseline, args.candidate, args.baseline_build, args.candidate_build, args.warmup))
    except (OSError, ValueError, TypeError, KeyError, RuntimeError) as error:
        report = {'passed': False, 'errors': [str(error)], 'qualifiesAsCompletion': False}
    print(json.dumps(report, indent=2, allow_nan=False))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
