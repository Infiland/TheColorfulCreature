#!/usr/bin/env python3
"""Compare the current troop path algorithm with and without its geometry cache.

Both modes replay the same ordinary inputs and seed through the native engine.
This is not a comparison to a historical Git baseline. Only `run` launches apps.
Input/observation limits count fixed 60 Hz ticks; fps caps rendering only.
"""
import argparse
import hashlib
import json
import statistics
from pathlib import Path

from lunar_qa import validate_spec, FPS, write_request
from gameplay_qa import (INPUT_CLOCK, SIMULATION_HZ, require_fixed_clock,
                         proof_clock_errors, validate_input_events,
                         whole_number, launch_timeout)
from tcc_project import ROOT

STATE_FIELDS = ('frame', 'room', 'x', 'y', 'vsp', 'bbox', 'grounded', 'color',
                'gravity', 'walkSpeed', 'ammo', 'keysRemaining', 'water',
                'zeroGravity', 'challengeDeaths', 'challengeRunId', 'challengePractice')
SEARCH_FIELDS = ('generation', 'width', 'height', 'path_requests',
                 'search_iterations', 'max_search_iterations', 'budget_deferrals')


def read(path):
    return json.loads(Path(path).read_text())


def write(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + '\n')


def input_identity(spec):
    return hashlib.sha256(json.dumps({k: spec.get(k) for k in
        ('room', 'challenge', 'mode', 'fps', 'seed', 'maxFrames', 'inputs', 'allowDeaths',
         'inputClock', 'simulationHz', 'sourceMapSha256')}, sort_keys=True).encode()).hexdigest()


def prepare(spec_path, output, repeats):
    source = read(spec_path)
    require_fixed_clock(('navigation request', source))
    if 'fpsOverrides' in source:
        raise ValueError('Legacy fpsOverrides cannot select a simulation timeline by render cap')
    if source.get('challenge') == 19:
        validate_spec(source)
    else:
        # A registered original campaign room can exercise more simultaneous
        # real troops than Lunar's early corridor. Do not create a fixture.
        room = source.get('room', '')
        if (not room.startswith('r_lvl') or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789_' for c in room)
                or not (ROOT / 'rooms' / room / (room + '.yy')).is_file()
                or any(k in source for k in ('fixture', 'specialIndex', 'playerColor', 'challenge'))):
            raise ValueError('Use normal Lunar challenge19 or an original r_lvl campaign room')
        validate_input_events(source.get('inputs', []))
        limit = source.get('maxFrames')
        inputs = source.get('inputs', [])
        if (type(source.get('fps')) is not int or source['fps'] not in FPS
                or not whole_number(limit, 1) or (inputs and limit <= inputs[-1]['frame'])):
            raise ValueError('Use a supported render cap and a 60 Hz tick budget beyond all input changes')
    if source.get('mode', 'replay') != 'replay':
        raise ValueError('Compare pure input replays, not adaptive route discovery')
    launch_timeout(source)
    identity = input_identity(source)
    paths = []
    # Alternate order between pairs to reduce a consistent warm/late bias.
    for repeat in range(repeats):
        modes = ('cached', 'rebuild') if repeat % 2 == 0 else ('rebuild', 'cached')
        for mode in modes:
            spec = {k: v for k, v in source.items()
                    if k not in ('output', 'saveRoot', 'identity', 'captureDirectory', 'captureFrames')}
            spec.update(navMode=mode, wallTimeoutSeconds=max(600, source.get('wallTimeoutSeconds', 600)),
                        navigationComparison={'repeat': repeat + 1,
                            'inputSha256': identity,
                            'reference': 'current algorithm with per-request geometry rebuild',
                            'historicalBaseline': False})
            launch_timeout(spec)
            path = output / f'pair-{repeat+1:02d}-{mode}.json'
            write_request(path, spec)
            paths.append(path)
    write(output / 'manifest.json', {'specs': [str(p.resolve()) for p in paths],
                                     'inputSha256': identity, 'repeats': repeats,
                                     'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ})
    return paths


def observation(path):
    spec, runtime, summary = (read(path / name) for name in ('spec.json', 'runtime.json', 'summary.json'))
    clock_issues = proof_clock_errors(spec, runtime, summary)
    errors = list(clock_issues)
    expected = 'cached' if spec['navMode'] == 'cached' else 'rebuild-per-request'
    nav = runtime.get('troopNavigation', {})
    if nav.get('cache_mode') != expected:
        errors.append('Native build does not report the requested navigation mode')
    if not summary.get('normalRuntimeEnd') or not summary.get('compiledPayloadVerified'):
        errors.append('Native run or compiled payload was not verified')
    if not runtime.get('normalRules') or runtime.get('sourceIdentity') != spec.get('identity'):
        errors.append('Native rules or identity differs from the stamped specification')
    if runtime.get('fps') != spec.get('fps') or runtime.get('seed') != spec.get('seed', 1):
        errors.append('Native render cap/seed differs from the stamped specification')
    if not nav.get('path_requests'):
        errors.append('No real troop requested a path; this run cannot measure caching')
    if nav.get('max_search_iterations', 0) > 2000:
        errors.append('A path exceeded the preserved search limit')
    world = next((e.get('world') for e in runtime.get('events', []) if e.get('kind') == 'initial-world'), None)
    if spec.get('challenge') == 19 and (not world or world.get('cullingSetting') != 0):
        errors.append('Expected complete unculled original-world initialization')
    if 'room' in spec and runtime.get('initial', {}).get('room') != spec['room']:
        errors.append('The native player did not start in the original campaign room')
    if spec['navMode'] == 'rebuild' and (nav.get('builds') != nav.get('path_requests') or nav.get('cache_hits') != 0):
        errors.append('Per-request reference did not rebuild once for every path request')
    trace = [{k: s.get(k) for k in STATE_FIELDS} for s in runtime.get('trace', [])]
    costs = sorted(runtime.get('stepCostsUs', []))
    events = [{k: e.get(k) for k in ('kind', 'reason')} |
              {'state': {k: e.get('state', {}).get(k) for k in STATE_FIELDS}}
              for e in runtime.get('events', []) if e.get('kind') in ('death', 'exit')]
    return {'path': str(path.resolve()), 'mode': spec['navMode'], 'errors': errors,
            'inputSha256': input_identity(spec), 'sourceIdentity': runtime['sourceIdentity'],
            'fps': spec['fps'], 'seed': spec.get('seed', 1), 'status': runtime['status'],
            'inputClock': runtime.get('inputClock'), 'simulationHz': runtime.get('simulationHz'),
            'clockVerified': not clock_issues, 'clockErrors': clock_issues,
            'frames': runtime['frames'], 'deaths': runtime['deaths'], 'trace': trace,
            'simulationFrames': runtime.get('simulationFrames'), 'renderFrames': runtime.get('renderFrames'),
            'simulationSeconds': runtime['frames'] / SIMULATION_HZ if not clock_issues else None,
            'nativeElapsedUs': runtime.get('elapsedUs'),
            'nativeChallengeTimeSeconds': (runtime.get('completion') or runtime.get('final') or {}).get('challengeTime'),
            'events': events, 'navigation': nav,
            'performance': {k: summary.get(k) for k in
                ('stepCostMedianUs', 'stepCostP95Us', 'observedRenderFps', 'wallSeconds')} |
                {'stepCostP99Us': costs[int((len(costs) - 1) * .99)] if costs else None,
                 'stepCostMaxUs': max(costs) if costs else None,
                 'stepCostTotalUs': sum(costs)},
            'currentPlayableContent': summary.get('matchesCurrentPlayableContent') is True}


def compare(directories):
    pairs = []
    by_pair = {}
    for path in directories:
        spec = read(path / 'spec.json')
        repeat = spec['navigationComparison']['repeat']
        by_pair.setdefault(repeat, {})[spec['navMode']] = observation(path)
    for repeat, modes in sorted(by_pair.items()):
        if set(modes) != {'cached', 'rebuild'}:
            raise ValueError(f'Pair {repeat} is missing a mode')
        cached, rebuild = modes['cached'], modes['rebuild']
        errors = cached['errors'] + rebuild['errors']
        for field in ('inputSha256', 'sourceIdentity', 'fps', 'seed', 'status', 'inputClock',
                      'simulationHz', 'frames', 'simulationFrames', 'deaths', 'trace', 'events'):
            if cached[field] != rebuild[field]:
                errors.append(f'Equivalent-input comparison differs in {field}')
        for field in SEARCH_FIELDS:
            if cached['navigation'].get(field) != rebuild['navigation'].get(field):
                errors.append(f'Path algorithm/request behavior differs in {field}')
        builds = cached['navigation'].get('builds', 0)
        reference_builds = rebuild['navigation'].get('builds', 0)
        if builds >= reference_builds:
            errors.append('The cached run did not reduce actual grid rebuilds')
        # Keep full state in runtime.json; the comparison report cites its path.
        for mode in (cached, rebuild):
            mode.pop('trace')
            mode.pop('events')
        pairs.append({'repeat': repeat, 'equivalent': not errors, 'errors': errors,
                      'cached': cached, 'rebuild': rebuild,
                      'avoidedBuilds': reference_builds - builds})
    metrics = {}
    for field in ('stepCostMedianUs', 'stepCostP95Us', 'stepCostP99Us', 'stepCostMaxUs',
                  'stepCostTotalUs', 'observedRenderFps'):
        values = {mode: [p[mode]['performance'][field] for p in pairs
                         if p[mode]['performance'][field] is not None]
                  for mode in ('cached', 'rebuild')}
        metrics[field] = {mode: statistics.median(v) if v else None for mode, v in values.items()}
    equivalent = bool(pairs) and all(p['equivalent'] for p in pairs)
    clocks_verified = bool(pairs) and all(p[mode]['clockVerified'] for p in pairs for mode in ('cached', 'rebuild'))
    return {'comparison': 'Current path algorithm, cached geometry versus rebuilding per request',
            'inputClock': INPUT_CLOCK if clocks_verified else None,
            'simulationHz': SIMULATION_HZ if clocks_verified else None,
            'requiredInputClock': INPUT_CLOCK, 'requiredSimulationHz': SIMULATION_HZ,
            'historicalBaseline': False, 'allPairsEquivalent': equivalent,
            'qualifiesCurrentComparison': equivalent and all(p[mode]['currentPlayableContent']
                                                           for p in pairs for mode in ('cached', 'rebuild')),
            'pairs': pairs, 'medianAcrossRuns': metrics,
            'limitations': ['Frozen diagnostic source does not establish final release performance.',
                           'FPS is a render cap; inputs and budgets use 60 Hz simulation ticks.',
                           'Observed render pacing is separate from simulation duration; wall time includes app bootstrap.',
                           'Legacy evidence has no implicit normalized clock and cannot qualify.',
                           'Concurrent compiler work may affect CPU timing; native game processes are serialized.']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    prep = sub.add_parser('prepare')
    prep.add_argument('--spec', type=Path, required=True)
    prep.add_argument('--output', type=Path, required=True)
    prep.add_argument('--repeats', type=int, choices=(1, 2, 3, 4), default=2)
    run_cmd = sub.add_parser('run')
    run_cmd.add_argument('--manifest', type=Path, required=True)
    run_cmd.add_argument('--build', type=Path, required=True)
    run_cmd.add_argument('--output', type=Path, required=True)
    run_cmd.add_argument('--build-snapshot', action='store_true')
    inspect_cmd = sub.add_parser('compare')
    inspect_cmd.add_argument('runs', type=Path, nargs='+')
    inspect_cmd.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.command == 'prepare':
        paths = prepare(args.spec, args.output, args.repeats)
        print(json.dumps({'specs': [str(p) for p in paths], 'historicalBaseline': False}, indent=2))
        return 0
    if args.command == 'run':
        from gameplay_qa import run
        manifest = read(args.manifest)
        require_fixed_clock(('navigation manifest', manifest))
        paths = [Path(p) for p in manifest['specs']]
        directories = []
        for path in paths:
            directory = args.output / path.stem
            run(args.build, path, directory, args.build_snapshot)
            directories.append(directory)
            if not (directory / 'runtime.json').is_file():
                raise RuntimeError(f'No native evidence from {directory}; stopping the comparison')
        result = compare(directories)
        write(args.output / 'comparison.json', result)
    else:
        result = compare(args.runs)
        write(args.output, result)
    print(json.dumps(result, indent=2))
    return 0 if result['allPairsEquivalent'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
