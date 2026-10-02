#!/usr/bin/env python3
"""Prepare and inspect input-only Lunar Base witnesses through the real QA game.

Every candidate starts challenge 19 normally and replays its complete input
prefix. No position, velocity, pickup, hazard or completion state is injected.
Compilation and trace inspection never launch the game; only `run` does.
Input frames are fixed 60 Hz simulation ticks; fps is only the render cap.
The input-mask contract is shared with gameplay_qa: pause=32 is a normal
pause/resume rising edge, and Lunar's shoot name aliases interact=8. Replay
recordings retain paused/no-player ticks; route actions still require the
existing live-player waypoint controller.
"""
import argparse
from collections import Counter
import hashlib
import html
import json
import math
from pathlib import Path

from tcc_project import ROOT
from gameplay_qa import (INPUT_CLOCK, SIMULATION_HZ, RENDER_COMPARISON_FPS,
                         INPUT_BITS, INPUT_MASK_MAX,
                         require_fixed_clock, proof_clock_errors,
                         validate_input_events, whole_number, launch_timeout)

FPS = RENDER_COMPARISON_FPS
BUTTONS = {('shoot' if key == 'interact' else key): bit for key, bit in INPUT_BITS.items()}
COLOURS = ('red', 'yellow', 'green', 'blue', 'white')
SOURCE = ROOT / 'datafiles/Challenges/Lunar Base Challenge/1/LevelEditor.sav'
ROUTE = ROOT / 'implementation/1.3.0/lunar-route/route-plan.json'
STATE_FIELDS = ('color', 'gravity', 'walkSpeed', 'ammo', 'keysRemaining', 'water', 'zeroGravity')
ROUTE_ACTIONS = ('wait', 'move', 'jump', 'airjump', 'fire', 'climb', 'interact',
                 'portal', 'wait-hazard', 'restart')


def read_json(path):
    return json.loads(Path(path).read_text())


def source_hash():
    return hashlib.sha256(SOURCE.read_bytes()).hexdigest()


def expected_world_counts():
    entries = json.JSONDecoder().raw_decode(SOURCE.read_text())[0]['ROOT']
    counts = Counter()
    for entry in entries:
        name = entry['obj']
        if 'background' in name or name == 'o_playerspawner':
            continue
        if name.endswith('LE'):
            name = name[:-2]
        counts['o_door' if name == 'o_lockeddoor' else name] += 1
    return counts


def mask(keys):
    result = 0
    for key in keys:
        if key not in BUTTONS:
            raise ValueError(f'Unknown input {key!r}; use {", ".join(BUTTONS)}')
        result |= BUTTONS[key]
    if result & 3 == 3:
        raise ValueError('Opposite horizontal inputs are not a useful route action')
    return result


def held_inputs(events, frame):
    state = 0
    for event in events:
        if event['frame'] > frame:
            break
        # GameMaker serializes its numeric button mask as a JSON real.
        value = event['mask']
        if not whole_number(value) or value > INPUT_MASK_MAX:
            raise ValueError('Native input recording contains a nonintegral or invalid button mask')
        state = int(value)
    return [key for key, bit in BUTTONS.items() if state & bit]


def validate_spec(spec, *, fixed_clock=True, current_map=True):
    if not isinstance(spec, dict):
        raise ValueError('Expected a Lunar input request object')
    if 'fpsOverrides' in spec:
        raise ValueError('Legacy fpsOverrides cannot select simulation inputs by render FPS')
    if fixed_clock:
        require_fixed_clock(('Lunar request', spec))
    if spec.get('challenge') != 19 or any(k in spec for k in ('room', 'fixture', 'specialIndex', 'playerColor')):
        raise ValueError('Lunar input witnesses must use the normal challenge 19 start')
    if (spec.get('mode', 'replay') not in ('replay', 'route')
            or type(spec.get('fps')) is not int or spec['fps'] not in FPS):
        raise ValueError('Expected replay/route mode and a supported render FPS cap')
    if spec.get('expect') not in ('frames', 'exit'):
        raise ValueError('Expected frames for investigation or exit for a completion attempt')
    events = spec.get('inputs', [])
    validate_input_events(events)
    last = events[-1]['frame'] if events else -1
    maximum = spec.get('maxFrames')
    if type(maximum) is not int or maximum <= last or maximum < 1:
        raise ValueError('The simulation-tick observation must extend beyond the last input event')
    route_start = spec.get('routeStartFrame', 0)
    if type(route_start) is not int or not 0 <= route_start < maximum:
        raise ValueError('routeStartFrame must be a nonnegative simulation tick before maxFrames')
    if route_start and (spec.get('mode') != 'route' or any(e['frame'] >= route_start for e in events)):
        raise ValueError('A route input prefix must end before routeStartFrame')
    if spec.get('mode') == 'route':
        route = spec.get('route')
        if not isinstance(route, list) or not route:
            raise ValueError('Route discovery requires normal-input waypoint stages')
        for stage in route:
            if not isinstance(stage, dict) or stage.get('action') not in ROUTE_ACTIONS:
                raise ValueError('Unsupported normal-input route action')
            for field in ('seconds', 'timeoutSeconds'):
                if field in stage and (type(stage[field]) not in (int, float)
                        or not math.isfinite(stage[field]) or stage[field] < 0
                        or (field == 'timeoutSeconds' and stage[field] == 0)):
                    raise ValueError(f'Route {field} must be finite; durations use the 60 Hz simulation clock')
    authored_hash = spec.get('sourceMapSha256')
    if current_map and authored_hash and authored_hash != source_hash():
        raise ValueError('Lunar source map changed; review the candidate before replaying it')
    if fixed_clock:
        launch_timeout(spec)
    return spec


def seconds_to_ticks(seconds):
    if type(seconds) not in (int, float) or not math.isfinite(seconds) or seconds < 0:
        raise ValueError('Simulation seconds must be finite and nonnegative')
    return round(seconds * SIMULATION_HZ)


def validate_plan_clock(plan):
    if 'fpsOverrides' in plan:
        raise ValueError('Legacy fpsOverrides require new input authoring; render caps cannot select motion timelines')
    if 'inputClock' in plan or 'simulationHz' in plan:
        require_fixed_clock(('Lunar plan', plan))


def compile_plan(plan, fps, seed=1, delay_frames=0):
    if plan.get('format') != 'tcc.lunar-input-plan' or plan.get('schemaVersion') != 1:
        raise ValueError('Expected a tcc.lunar-input-plan version 1 document')
    validate_plan_clock(plan)
    if type(fps) is not int or fps not in FPS or type(delay_frames) is not int or delay_frames < 0:
        raise ValueError('Unsupported render cap or nonintegral/negative simulation-tick variation')
    actions = plan['actions']
    duration = plan['seconds']
    events = {0: 0}

    def add(frame, value):
        if frame in events and events[frame] != value:
            raise ValueError(f'Conflicting input changes at frame {frame}')
        events[frame] = value

    for action in actions:
        if ('at' in action) == ('atFrame' in action):
            raise ValueError('Each action requires exactly one of at (seconds) or atFrame')
        frame = action['atFrame'] if 'atFrame' in action else seconds_to_ticks(action['at'])
        if type(frame) is not int or frame < 0:
            raise ValueError('Action frames must be nonnegative integers')
        if frame:
            frame += delay_frames
        add(frame, mask(action.get('keys', [])))
        if 'holdFrames' in action:
            count = action['holdFrames']
            if type(count) is not int or count < 1 or 'then' not in action:
                raise ValueError('A pulse needs positive holdFrames and explicit then inputs')
            add(frame + count, mask(action['then']))
    spec = {'challenge': 19, 'mode': 'replay', 'fps': fps, 'seed': seed,
            'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ,
            'expect': plan.get('expect', 'frames'),
            'maxFrames': seconds_to_ticks(duration) + delay_frames,
            'traceEvery': 1, 'allowDeaths': plan.get('allowDeaths', False),
            'inputs': [{'frame': frame, 'mask': value} for frame, value in sorted(events.items())],
            'sourceMapSha256': source_hash(),
            'lunarCandidate': {'name': plan['name'], 'purpose': plan['purpose'],
                               'verified': False, 'delayFrames': delay_frames,
                               'expectedCheckpoints': plan.get('expectedCheckpoints', [])}}
    return validate_spec(spec)


def compile_waypoints(plan, fps, seed=1):
    if plan.get('format') != 'tcc.lunar-waypoint-plan' or plan.get('schemaVersion') != 1:
        raise ValueError('Expected a tcc.lunar-waypoint-plan version 1 document')
    validate_plan_clock(plan)
    route = plan.get('route', [])
    spec = {'challenge': 19, 'mode': 'route', 'fps': fps, 'seed': seed,
            'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ,
            'expect': plan.get('expect', 'frames'), 'maxFrames': seconds_to_ticks(plan['seconds']),
            'traceEvery': 1, 'allowDeaths': False, 'inputs': [], 'route': route,
            'sourceMapSha256': source_hash(),
            'lunarCandidate': {'name': plan['name'], 'purpose': plan['purpose'],
                               'verified': False, 'requiresSeparateReplay': True}}
    return validate_spec(spec)


def recorded_replay(path, expect=None):
    path = Path(path)
    spec = validate_spec(read_json(path / 'spec.json'))
    runtime = read_json(path / 'runtime.json')
    summary = read_json(path / 'summary.json')
    issues = proof_clock_errors(spec, runtime, summary)
    if issues:
        raise ValueError('Cannot export a legacy/unverified-clock recording: ' + '; '.join(issues))
    if runtime.get('inputMode') not in ('route', 'record') or not runtime.get('normalRules'):
        raise ValueError('Expected an actual normal-rules recording from the native engine')
    if (runtime.get('sourceIdentity') != spec.get('identity')
            or not summary.get('normalRuntimeEnd') or not summary.get('compiledPayloadVerified')):
        raise ValueError('Recording must bind to a verified native payload and end normally')
    validate_input_events(runtime.get('inputs'))
    candidate = {key: spec[key] for key in ('challenge', 'fps', 'seed', 'maxFrames', 'sourceMapSha256',
                                          'inputClock', 'simulationHz') if key in spec}
    candidate.update(mode='replay', expect=expect or spec['expect'], traceEvery=1,
                     allowDeaths=spec.get('allowDeaths', False),
                     inputs=[{'frame': int(e['frame']), 'mask': int(e['mask'])} for e in runtime['inputs']],
                     lunarCandidate={'verified': False, 'recordingSource': str(path.resolve()),
                                     'recordingInputMode': runtime['inputMode'],
                                     'recordingSourceIdentity': runtime['sourceIdentity']})
    return validate_spec(candidate)


def request_from_legacy_60(path, fps=SIMULATION_HZ):
    """Copy authentic 60 FPS request inputs, never relabel historical proof."""
    path = Path(path).resolve()
    original_bytes = path.read_bytes()
    source = validate_spec(json.loads(original_bytes), fixed_clock=False, current_map=False)
    if source['fps'] != SIMULATION_HZ:
        raise ValueError('Only authentic old 60 FPS requests can retain their exact input indices')
    if 'inputClock' in source or 'simulationHz' in source:
        require_fixed_clock(('source request', source))
    fields = ('challenge', 'mode', 'seed', 'maxFrames', 'expect', 'traceEvery', 'allowDeaths',
              'inputs', 'route', 'routeStartFrame', 'captureFrames', 'observeTroops', 'wallTimeoutSeconds')
    candidate = {key: source[key] for key in fields if key in source}
    candidate.update(fps=fps, inputClock=INPUT_CLOCK, simulationHz=SIMULATION_HZ,
                     sourceMapSha256=source_hash(),
                     lunarCandidate={'verified': False, 'requiresFreshNativeRecording': True,
                         'requestSource': str(path),
                         'requestSha256': hashlib.sha256(original_bytes).hexdigest(),
                         'originalSourceMapSha256': source.get('sourceMapSha256'),
                         'originalRenderFps': source['fps'],
                         'originalInputClock': source.get('inputClock'),
                         'qualification': 'Unverified request only; historical runtime evidence is unchanged.',
                         'retryTimeline': 'Death/respawn now consume simulation ticks; retry inputs need fresh recording.'})
    return validate_spec(candidate)


def write_request(path, request):
    """Never overwrite pre-normalization requests or any existing evidence."""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x') as file:
        file.write(json.dumps(request, indent=2) + '\n')


def compact_state(state, simulation_hz=SIMULATION_HZ):
    if not state:
        return None
    if not whole_number(state.get('frame')):
        raise ValueError('Native state frame must be a whole simulation-tick index')
    return {'frame': state['frame'],
            'simulationSeconds': round(state['frame'] / simulation_hz, 4) if simulation_hz else None,
            'x': round(state['x'], 4), 'y': round(state['y'], 4),
            'vsp': round(state['vsp'], 4), 'grounded': state['grounded'],
            **{key: state.get(key) for key in STATE_FIELDS},
            **{key: state[key] for key in ('challengeTime', 'challengeDeaths', 'challengeRunId', 'challengePractice')
               if key in state}}


def world_retry_comparisons(events):
    initial_event = next((e for e in events if e.get('kind') == 'initial-world'), None)
    if not initial_event or not initial_event.get('world'):
        return {'available': False, 'retries': [],
                'limitation': 'This build did not capture the initial Lunar world.'}
    initial = initial_event['world']
    retry_events = [(i, e) for i, e in enumerate(events) if e.get('kind') == 'retry-world' and e.get('world')]
    dynamic = {'o_enemyplayer', 'o_redblockmove', 'o_yellowblockmove',
               'o_Hspikemovingup', 'o_spikemovingdownup', 'o_spikemovingrightleft',
               'o_spikemovingupdown'}
    fixed_fields = {'hp', 'hpbreakable', 'hpbreakablemax', 'containsammo', 'hasammo',
                    'movespeed', 'originalcooldown', 'originaltimer', 'spikespeed', 'locked'}

    def rows_by_origin(world):
        result = {}
        for row in world.get('instances', []):
            key = (row['type'], row['startX'], row['startY'], row['scaleX'], row['scaleY'])
            result.setdefault(key, []).append(row)
        return result

    initial_rows = rows_by_origin(initial)
    reports = []
    for event_index, event in retry_events:
        world = event['world']
        retry_rows = rows_by_origin(world)
        errors, timing_differences = [], []
        if not initial.get('completeGameplayScope') or not world.get('completeGameplayScope'):
            errors.append('Object deactivation makes this snapshot incomplete')
        if world.get('fps') != initial.get('fps') or world.get('seed') != initial.get('seed'):
            errors.append('Initial/retry FPS or seed differs')
        for field in ('counts', 'projectiles'):
            if world.get(field) != initial.get(field):
                errors.append(f'{field} did not return to its initial value')
        if world.get('players') != 1 or world.get('localPlayers') != 0 or world.get('deadPlayers') != 0:
            errors.append('Retry did not restore exactly one live player and no dead/local players')
        if initial_rows.keys() != retry_rows.keys():
            errors.append('Original object types/positions/transforms differ after retry')
        for origin in initial_rows.keys() & retry_rows.keys():
            before_group, after_group = initial_rows[origin], retry_rows[origin]
            if len(before_group) != len(after_group):
                errors.append(f'Instance multiplicity changed at {origin}')
                continue
            for before, after in zip(before_group, after_group):
                if origin[0] not in dynamic and (before['x'], before['y']) != (after['x'], after['y']):
                    errors.append(f'Static geometry/pickup moved at {origin}')
                for field in fixed_fields:
                    if before.get('state', {}).get(field) != after.get('state', {}).get(field):
                        errors.append(f'Reset state {field} differs at {origin}')
                before_phase = {k: v for k, v in before.get('state', {}).items() if k not in fixed_fields}
                after_phase = {k: v for k, v in after.get('state', {}).items() if k not in fixed_fields}
                if origin[0] in dynamic:
                    before_phase.update(x=before['x'], y=before['y'])
                    after_phase.update(x=after['x'], y=after['y'])
                if before_phase != after_phase:
                    timing_differences.append({'type': origin[0], 'startX': origin[1], 'startY': origin[2],
                                               'initial': before_phase, 'retry': after_phase})
        initial_state, retry_state = initial_event.get('state', {}), event.get('state', {})
        previous_death = next((e.get('state', {}) for e in reversed(events[:event_index])
                               if e.get('kind') == 'death'), {})
        counter_fields = ('challengeTime', 'challengeDeaths', 'challengeRunId', 'challengePractice')
        counter_available = all(key in state for key in counter_fields
                                for state in (initial_state, retry_state, previous_death))
        counter_errors = []
        if counter_available:
            if retry_state['challengeDeaths'] != previous_death['challengeDeaths'] + 1:
                counter_errors.append('Challenge death counter did not retain exactly one new death')
            if retry_state['challengeTime'] < previous_death['challengeTime']:
                counter_errors.append('Challenge elapsed time moved backward during retry')
            if retry_state['challengeRunId'] != initial_state['challengeRunId']:
                counter_errors.append('Challenge run eligibility changed during room retry')
            if retry_state['challengePractice'] != initial_state['challengePractice']:
                counter_errors.append('Practice eligibility changed during room retry')
        object_passed = not errors and not timing_differences
        reports.append({'frame': event.get('state', {}).get('frame', world.get('frame')),
                        'staticResetPassed': not errors, 'errors': errors,
                        'sameFirstInputDynamicState': not timing_differences,
                        'dynamicDifferences': timing_differences,
                        'objectResetPassed': object_passed,
                        'challengeCounters': {'available': counter_available, 'errors': counter_errors,
                                              'passed': counter_available and not counter_errors},
                        'completeResetPassed': object_passed and counter_available and not counter_errors})
    return {'available': True, 'initialInstanceCount': len(initial.get('instances', [])),
            'initialCounts': initial.get('counts'), 'initialPlayers': initial.get('players'),
            'initialSnapshotFrame': initial.get('frame'),
            'initialSnapshotPhase': initial.get('snapshotPhase', 'legacy-first-input'),
            'initializationReady': initial.get('initializationReady', False),
            'initialCompleteScope': initial.get('completeGameplayScope'), 'retries': reports,
            'timingNote': 'Dynamic differences require investigation at the same first-input phase; they are not silently accepted.'}


def inspect_run(path, sample_seconds=0.5):
    path = Path(path).resolve()
    spec = validate_spec(read_json(path / 'spec.json'))
    result = read_json(path / 'runtime.json')
    summary = read_json(path / 'summary.json')
    trace, fps = result['trace'], spec['fps']
    actual_inputs = result.get('inputs', spec.get('inputs', []))
    validate_input_events(actual_inputs)
    clock_issues = proof_clock_errors(spec, result, summary)
    simulation_hz = SIMULATION_HZ if not clock_issues else None
    errors, release_gates = list(clock_issues), []
    if not result.get('normalRules'):
        errors.append('Native result did not preserve normal rules')
    if result.get('sourceIdentity') != spec.get('identity'):
        errors.append('Runtime identity differs from the stamped input specification')
    if not summary.get('compiledPayloadVerified'):
        errors.append('Compiled payload was not verified by the runner')
    if not summary.get('normalRuntimeEnd'):
        errors.append('Runtime did not end normally')
    if not summary.get('matchesCurrentPlayableContent'):
        release_gates.append('Frozen-build observation does not match current playable source')
    if result.get('fps') != fps or result.get('seed') != spec.get('seed', 1):
        errors.append('Runtime render cap/seed differs from the input specification')

    jumps, landings, changes = [], [], []
    previous = result.get('initial')
    for state in trace:
        if previous:
            changed = {key: [previous.get(key), state.get(key)] for key in STATE_FIELDS
                       if previous.get(key) != state.get(key)}
            if changed:
                changes.append({**compact_state(state, simulation_hz), 'changed': changed})
            if state['vsp'] < -1 and previous['vsp'] >= 0 and 'jump' in held_inputs(actual_inputs, state['frame']):
                jumps.append(compact_state(state, simulation_hz))
            if state['grounded'] and not previous['grounded']:
                landings.append(compact_state(state, simulation_hz))
        previous = state

    deaths = [{**compact_state(event['state'], simulation_hz),
               'inputs': held_inputs(actual_inputs, event['state']['frame'])}
              for event in result.get('events', []) if event['kind'] == 'death']
    samples = []
    next_frame = 0
    for state in trace:
        if state['frame'] >= next_frame:
            samples.append({**compact_state(state, simulation_hz),
                            'inputs': held_inputs(actual_inputs, state['frame'])})
            next_frame = state['frame'] + max(1, seconds_to_ticks(sample_seconds))

    landmarks = []
    route = read_json(ROUTE)
    if route['sourceSha256'] != source_hash():
        errors.append('Static route map is stale')
    if trace:
        for section in route['sections']:
            for marker in section.get('markers', []):
                closest = min(trace, key=lambda s: math.hypot((s['bbox'][0] + s['bbox'][2]) / 2 - marker['x'],
                                                            (s['bbox'][1] + s['bbox'][3]) / 2 - marker['y']))
                distance = math.hypot((closest['bbox'][0] + closest['bbox'][2]) / 2 - marker['x'],
                                      (closest['bbox'][1] + closest['bbox'][3]) / 2 - marker['y'])
                landmarks.append({'id': marker['id'], 'label': marker['label'],
                                  'nearestDistance': round(distance, 3),
                                  'nearest': compact_state(closest, simulation_hz)})

    # A proximity marker never proves a pickup. The native state transition is
    # the observation that establishes a gun/key/colour change.
    world_reset = world_retry_comparisons(result.get('events', []))
    if world_reset['available']:
        expected_counts = expected_world_counts()
        initial_counts = Counter(world_reset['initialCounts'])
        initial_counts['o_door'] += initial_counts.pop('o_lockeddoor', 0)
        differences = {name: {'expected': expected_counts[name], 'observed': initial_counts[name]}
                       for name in sorted(expected_counts.keys() | initial_counts.keys())
                       if expected_counts[name] != initial_counts[name]}
        world_reset.update(expectedInstanceCount=sum(expected_counts.values()),
                           originalMapCountDifferences=differences)
        if (not world_reset['initialCompleteScope'] or world_reset['initialPlayers'] != 1 or differences
                or world_reset['initialInstanceCount'] != sum(expected_counts.values())):
            errors.append('Initial world snapshot does not contain the complete original Lunar gameplay map')
    key_collected = any(c.get('changed', {}).get('keysRemaining') == [1, 0] for c in changes)
    gun_collected = any(c.get('changed', {}).get('ammo') == [0, 16] for c in changes)
    complete = bool(summary.get('qualifiesAsCompletion') and not errors and not release_gates
                    and world_reset.get('available') and world_reset.get('initializationReady')
                    and result.get('status') == 'complete' and result.get('deaths') == 0
                    and key_collected and result.get('completion')
                    and result['completion']['keysRemaining'] == 0)
    respawns = []
    for death in deaths:
        recovered = next((s for s in trace if s['frame'] >= death['frame']
                          and abs(s['x'] - 64) <= 8 and 3040 <= s['y'] <= 3180
                          and s['color'] == 0 and s['ammo'] == 0 and s['keysRemaining'] == 1), None)
        respawns.append({'deathFrame': death['frame'], 'playerStateRestored': recovered is not None,
                         'state': compact_state(recovered, simulation_hz)})
    return {'run': str(path), 'status': result['status'], 'reason': result['reason'],
            'inputMode': result.get('inputMode', spec.get('mode', 'replay')),
            'routeIndex': result.get('routeIndex'),
            'fps': fps, 'seed': spec.get('seed', 1), 'frames': result['frames'],
            'inputClock': result.get('inputClock'), 'simulationHz': result.get('simulationHz'),
            'simulationFrames': result.get('simulationFrames'), 'renderFrames': result.get('renderFrames'),
            'simulationSeconds': result['frames'] / SIMULATION_HZ if simulation_hz else None,
            'nativeElapsedUs': result.get('elapsedUs'),
            'nativeChallengeTimeSeconds': (result.get('completion') or result.get('final') or {}).get('challengeTime'),
            'timeMeaning': 'Simulation duration is ticks/60; completion/130-second claims use native challengeTime.',
            'clockVerified': not clock_issues, 'clockErrors': clock_issues,
            'deaths': result['deaths'],
            'observedRenderFps': summary.get('observedRenderFps'),
            'nativeLaunch': {key: summary.get(key) for key in
                             ('headlessRequested', 'backgroundLaunchRequested')},
            'errors': errors, 'releaseGates': release_gates, 'qualifiesAsLunarCompletion': complete,
            'gunCollected': gun_collected, 'keyCollected': key_collected,
            'initial': compact_state(result.get('initial'), simulation_hz),
            'final': compact_state(result.get('final'), simulation_hz),
            'completion': compact_state(result.get('completion'), simulation_hz),
            'stateChanges': changes, 'jumps': jumps, 'landings': landings,
            'deathEvents': deaths, 'respawns': respawns,
            'worldReset': world_reset,
            'samples': samples, 'landmarkProximityOnly': landmarks,
            'sourceIdentity': result.get('sourceIdentity')}


def trace_overlay(path, destination):
    """Overlay actual trace coordinates on source geometry; do not resimulate."""
    path = Path(path)
    spec = validate_spec(read_json(path / 'spec.json'))
    result = read_json(path / 'runtime.json')
    issues = proof_clock_errors(spec, result, read_json(path / 'summary.json'))
    if issues:
        raise ValueError('Cannot label a legacy/unverified-clock trace as simulation-60: ' + '; '.join(issues))
    from lunar_route_map import render
    entries = json.JSONDecoder().raw_decode(SOURCE.read_text())[0]['ROOT']
    destination = Path(destination)
    destination.parent.mkdir(parents=True, exist_ok=True)
    render(entries, destination,
           title=f'Lunar Base native trace — 60 Hz simulation, {spec["fps"]} FPS render cap, '
                 f'{result["status"]}, {result["deaths"]:g} deaths')
    pieces = ['<g id="native-trace">']
    previous = None
    palette = ('#ff6363', '#ffea3b', '#61ed97', '#63beff', '#ffffff')
    for state in result['trace']:
        px, py = (state['bbox'][0] + state['bbox'][2]) / 2, state['bbox'][3]
        if previous:
            old, ox, oy = previous
            if old['room'] == state['room'] and math.hypot(px - ox, py - oy) < 128:
                pieces.append(f'<path d="M{ox:g} {oy:g}L{px:g} {py:g}" fill="none" '
                              f'stroke="{palette[int(state["color"])]}" stroke-width="5"/>')
        if int(state['frame']) % SIMULATION_HZ == 0:
            title = html.escape(json.dumps(compact_state(state)))
            pieces.append(f'<g><title>{title}</title><circle cx="{px:g}" cy="{py:g}" r="7" '
                          f'fill="#ffffff" stroke="#101722" stroke-width="2"/></g>')
        previous = state, px, py
    for event in result.get('events', []):
        if event['kind'] != 'death':
            continue
        state = event['state']
        px, py = state['x'] + 16, state['y'] + 16
        pieces.append(f'<g><title>Death at frame {state["frame"]:g}</title><path '
                      f'd="M{px-12:g} {py-12:g}L{px+12:g} {py+12:g}M{px+12:g} {py-12:g}L{px-12:g} {py+12:g}" '
                      'stroke="#ff36bd" stroke-width="7"/></g>')
    pieces.append('</g>')
    destination.write_text(destination.read_text().replace('</svg>', '\n'.join(pieces) + '\n</svg>'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    compile_cmd = sub.add_parser('compile', help='Compile an inspectable action plan; no game launch')
    compile_cmd.add_argument('plan', type=Path)
    compile_cmd.add_argument('--fps', type=int, nargs='+', choices=FPS, default=FPS, help='Render FPS caps; inputs always use 60 Hz')
    compile_cmd.add_argument('--seed', type=int, default=1)
    compile_cmd.add_argument('--delay-frames', type=int, default=0, help='Delay nonzero input indices by this many simulation ticks')
    compile_cmd.add_argument('--output', type=Path, required=True)
    route_cmd = sub.add_parser('route', help='Compile normal-input waypoint candidates; requires QA route mode')
    route_cmd.add_argument('plan', type=Path)
    route_cmd.add_argument('--fps', type=int, nargs='+', choices=FPS, default=FPS, help='Render FPS caps; waypoint durations always use 60 Hz')
    route_cmd.add_argument('--seed', type=int, default=1)
    route_cmd.add_argument('--output', type=Path, required=True)
    replay_cmd = sub.add_parser('replay', help='Extract ordinary recorded inputs for a separate native replay')
    replay_cmd.add_argument('run', type=Path)
    replay_cmd.add_argument('--expect', choices=('frames', 'exit'))
    replay_cmd.add_argument('--output', type=Path, required=True)
    request_cmd = sub.add_parser('request-60', help='Copy an authentic old 60 FPS request as a NEW UNVERIFIED simulation-60 request; never convert evidence')
    request_cmd.add_argument('spec', type=Path)
    request_cmd.add_argument('--fps', type=int, choices=FPS, default=SIMULATION_HZ, help='New render cap; original input ticks stay unchanged')
    request_cmd.add_argument('--output', type=Path, required=True)
    run_cmd = sub.add_parser('run', help='Run candidates serially using the native QA runner')
    run_cmd.add_argument('--build', type=Path, required=True)
    run_cmd.add_argument('--spec', type=Path, nargs='+', required=True)
    run_cmd.add_argument('--output', type=Path, required=True)
    run_cmd.add_argument('--build-snapshot', action='store_true')
    run_cmd.add_argument('--visible', action='store_true')
    run_cmd.add_argument('--headless', action='store_true',
                         help='Use the native headless runner; simulation and observed render counts stay separate')
    inspect_cmd = sub.add_parser('inspect', help='Read native evidence without launching the game')
    inspect_cmd.add_argument('runs', type=Path, nargs='+')
    inspect_cmd.add_argument('--every', type=float, default=0.5, help='Seconds between printed position samples')
    inspect_cmd.add_argument('--output', type=Path)
    inspect_cmd.add_argument('--overlay', type=Path, help='SVG trace overlay, when inspecting one run')
    inspect_cmd.add_argument('--require-completion', action='store_true')
    inspect_cmd.add_argument('--require-retry', action='store_true',
                             help='Require one death, one normal respawn and matching complete world reset')
    args = parser.parse_args()
    if args.command == 'compile':
        plan = read_json(args.plan)
        args.output.mkdir(parents=True, exist_ok=True)
        paths = []
        for fps in args.fps:
            spec = compile_plan(plan, fps, args.seed, args.delay_frames)
            suffix = f'-seed{args.seed}-delay{args.delay_frames}' if args.seed != 1 or args.delay_frames else ''
            path = args.output / f'{plan["name"]}-{fps}{suffix}.json'
            write_request(path, spec)
            paths.append(str(path))
        print(json.dumps({'candidateSpecs': paths, 'verified': False}, indent=2))
        return 0
    if args.command == 'route':
        plan = read_json(args.plan)
        args.output.mkdir(parents=True, exist_ok=True)
        paths = []
        for fps in args.fps:
            spec = compile_waypoints(plan, fps, args.seed)
            path = args.output / f'{plan["name"]}-{fps}.json'
            write_request(path, spec)
            paths.append(str(path))
        print(json.dumps({'routeCandidates': paths, 'requiresSeparateReplay': True}, indent=2))
        return 0
    if args.command == 'replay':
        candidate = recorded_replay(args.run, args.expect)
        write_request(args.output, candidate)
        print(json.dumps({'replayCandidate': str(args.output), 'verified': False}, indent=2))
        return 0
    if args.command == 'request-60':
        candidate = request_from_legacy_60(args.spec, args.fps)
        write_request(args.output, candidate)
        print(json.dumps({'requestCandidate': str(args.output), 'verified': False,
                          'requiresFreshNativeRecording': True}, indent=2))
        return 0
    if args.command == 'run':
        from gameplay_qa import run
        args.output.mkdir(parents=True, exist_ok=True)
        successful = True
        for path in args.spec:
            validate_spec(read_json(path))
            destination = args.output / path.stem
            ended = run(args.build, path, destination, args.build_snapshot, args.visible, args.headless)
            successful &= ended
            if (destination / 'runtime.json').is_file():
                report = inspect_run(destination)
                successful &= not report['errors']
                (destination / 'lunar-report.json').write_text(json.dumps(report, indent=2) + '\n')
                trace_overlay(destination, destination / 'lunar-trace.svg')
                print(json.dumps({'run': str(destination), 'status': report['status'],
                                  'errors': report['errors'], 'final': report['final'],
                                  'qualifiesAsLunarCompletion': report['qualifiesAsLunarCompletion']}, indent=2))
        return 0 if successful else 1
    if not math.isfinite(args.every) or args.every <= 0:
        parser.error('--every must be finite and positive simulation seconds')
    reports = [inspect_run(path, args.every) for path in args.runs]
    if args.overlay:
        if len(args.runs) != 1:
            parser.error('--overlay accepts one run at a time')
        trace_overlay(args.runs[0], args.overlay)
    value = reports[0] if len(reports) == 1 else reports
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(value, indent=2) + '\n')
    print(json.dumps(value, indent=2))
    if args.require_completion:
        return 0 if all(r['qualifiesAsLunarCompletion'] for r in reports) else 1
    if args.require_retry:
        passed = all(not r['errors'] and not r['releaseGates'] and r['deaths'] == 1 and len(r['respawns']) == 1
                     and r['respawns'][0]['playerStateRestored']
                     and r['worldReset'].get('available')
                     and len(r['worldReset']['retries']) == 1
                     and r['worldReset']['retries'][0]['completeResetPassed'] for r in reports)
        return 0 if passed else 1
    return 0 if all(not r['errors'] for r in reports) else 1


if __name__ == '__main__':
    raise SystemExit(main())
