#!/usr/bin/env python3
"""Generate and verify normal-input native slope diagnostics.

Generate JSON specs, then run them with tools/gameplay_qa.py. Verification reads
the resulting spec.json/runtime.json; it does not simulate player movement.
These fixtures never qualify as authored levels or completion witnesses for one.
Input frames are fixed 60 Hz simulation ticks; fps caps rendering only.
"""
import argparse
import hashlib
import json
import math
import re
from pathlib import Path

from gameplay_qa import (INPUT_CLOCK, SIMULATION_HZ, RENDER_COMPARISON_FPS,
                         require_fixed_clock, proof_clock_errors,
                         validate_input_events, whole_number, launch_timeout)
from native_evidence import file_hash
from tcc_project import ROOT, level_content_identity, source_identity
from timing_qa import binding

FPS = RENDER_COMPARISON_FPS
COLOURS = ('red', 'yellow', 'green', 'blue', 'white')
LOWER = ('ascent', 'descent', 'jump', 'mismatch')
UPPER = ('ceiling', 'side', 'empty', 'mismatch')
ACTOR_PROJECTILES = ('o_playerbullet', 'o_playerbulletMU', 'o_bulletleft', 'o_bulletright',
                     'o_rocket', 'o_rocket2', 'o_enemytroopprojectileboss5')
CANDIDATE = {'status': 'NEW UNVERIFIED', 'verified': False,
             'requiresFreshNativeRecording': True}
DIAGNOSTIC_REQUEST_FIELDS = {'room', 'fixture', 'mode', 'fps', 'inputClock', 'simulationHz', 'seed',
    'expect', 'maxFrames', 'traceEvery', 'allowDeaths', 'diagnosticOnly', 'inputs',
    'identity', 'output', 'saveRoot', 'captureFrames', 'captureDirectory', 'captureClock',
    'wallTimeoutSeconds', 'observeTroops', 'observeNativeActors', 'actor',
    'requestCandidate', 'slopeCandidate', 'readinessCandidate'}


def finite(value):
    return type(value) in (int, float) and math.isfinite(value)


def native_flag(value):
    # GameMaker serializes some native boolean expressions as real 0/1.
    return type(value) is bool or (finite(value) and value in (0, 1))


def finite_json(value):
    if isinstance(value, dict):
        return all(finite_json(item) for item in value.values())
    if isinstance(value, list):
        return all(finite_json(item) for item in value)
    return not isinstance(value, float) or math.isfinite(value)


TRACE_SCHEMA_VERSION = 2
TRACE_BOUNDARIES = 'native-end-or-terminal-contact'
TRACE_PHASES = ('root-end', 'death-contact', 'exit-contact')


def trace_observation_errors(spec, result):
    """Inspect raw phase/event links, never create missing native tick samples.

    This pure contract check cannot establish native provenance or currentness.
    Legacy v1 rows and multi-death/absent-actor intervals remain unqualified.
    """
    errors = []
    def require(condition, message):
        if not condition:
            errors.append(message)
    require(whole_number(result.get('traceSchemaVersion'))
            and result.get('traceSchemaVersion') == TRACE_SCHEMA_VERSION
            and result.get('traceBoundaries') == TRACE_BOUNDARIES,
            'Missing/wrong explicit native terminal-observation trace schema')
    count = result.get('simulationFrames')
    trace, events = result.get('trace'), result.get('events')
    if (not whole_number(count, 1) or not isinstance(trace, list)
            or len(trace) != count or not all(isinstance(row, dict) for row in trace)):
        return errors + ['Terminal reader requires complete actual per-tick player observations']
    require(all(whole_number(row.get('frame')) and row['frame'] == index
                for index, row in enumerate(trace)),
            'Terminal trace ticks are missing, duplicate, late or misordered')
    require(all(row.get('observationPhase') in TRACE_PHASES for row in trace),
            'Unknown/missing actual native player observation phase')
    if not isinstance(events, list) or not all(isinstance(event, dict) for event in events):
        return errors + ['Terminal observation needs its raw native event array']
    terminal = [row for row in trace if row.get('observationPhase') != 'root-end']
    contacts = [event for event in events if event.get('kind') in ('death', 'exit-contact')]
    require(len(terminal) <= 1 and all(row is trace[-1] for row in terminal),
            'Terminal callback pose must be the unique final observed tick; respawn gaps are unsupported')
    if not terminal:
        require(not contacts and result.get('completion') is None and result.get('deaths') == 0
                and result.get('status') == 'observed',
                'Root-End-only trace contains an unexplained terminal status/event')
    elif len(terminal) == 1:
        row = terminal[0]
        kind = 'death' if row.get('observationPhase') == 'death-contact' else 'exit-contact'
        require(len(contacts) == 1 and contacts[0].get('kind') == kind
                and contacts[0].get('state') == row,
                'Terminal row differs from its unique actual native contact event.state')
        require(row.get('frame') == count - 1 and result.get('final') == row,
                'Terminal pose is not the consumed final simulation tick')
        if kind == 'death':
            require(result.get('status') == 'death' and result.get('deaths') == 1
                    and result.get('completion') is None,
                    'Death-contact trace lacks exactly one terminating native death')
        else:
            local = spec.get('actor', 'single-player') == 'local-multiplayer'
            require(result.get('status') == ('observed' if local else 'complete')
                    and result.get('deaths') == 0 and result.get('completion') == row,
                    'Exit-contact trace differs from actual completion/race context')
    return errors


def trace_source_contract_errors(snapshot):
    """Bind v2 markers to freshly rehashed compiled QA source, not a claim."""
    try:
        source = (Path(snapshot) / 'scripts/scr_gameplay_qa/scr_gameplay_qa.gml').read_text()
    except (OSError, UnicodeError) as error:
        return ['Cannot read frozen native trace source contract: ' + str(error)]
    # Read only the result writer/callback bodies, excluding source comments.
    source = re.sub(r'/\*[\s\S]*?\*/|//[^\n]*', '', source)
    required = (r'\btraceSchemaVersion\s*:\s*2\s*[,}]',
                r'\btraceBoundaries\s*:\s*"native-end-or-terminal-contact"',
                r'\bfunction\s+qa_store_player_sample\s*\(',
                r'qa_store_player_sample\s*\(\s*_state\s*,\s*"death-contact"\s*\)',
                r'qa_store_player_sample\s*\(\s*_state\s*,\s*"exit-contact"\s*\)',
                r'qa_store_player_sample\s*\(\s*_s\s*,\s*"root-end"\s*\)')
    if not all(re.search(pattern, source) for pattern in required):
        return ['Frozen compiled QA source does not emit the explicit native v2 trace contract']
    return []


def native_record_errors(spec, result, summary, bound=None, run=None, native_log=None):
    """Validate real native provenance and every recorded simulation tick.

    Pure callers must supply the trusted, freshly rehashed build binding and
    original run/log. Missing bindings never become qualifying evidence.
    Geometry/status assertions remain the responsibility of each fixture.
    """
    errors = proof_clock_errors(spec, result, summary)
    errors.extend(trace_observation_errors(spec, result))
    def require(condition, message):
        if not condition:
            errors.append(message)
    require(all(finite_json(document) for document in (spec, result, summary)),
            'Non-finite values cannot be native state/clock evidence')
    require(summary.get('normalRuntimeEnd') is True and summary.get('timedOut') is False
            and summary.get('compiledPayloadVerified') is True,
            'Missing normal native termination or compiled payload binding')
    require(isinstance(native_log, str) and '###game_end###0' in native_log,
            'Missing raw native log/normal engine end marker')
    require(result.get('normalRules') is True and result.get('diagnosticOnly') is True,
            'Missing normal-rules diagnostic marker')
    require(result.get('muted') is True and summary.get('muted') is True,
            'Native diagnostic mute binding is absent')
    require(result.get('format') == 'tcc.gameplay-evidence'
            and whole_number(result.get('schemaVersion')) and result.get('schemaVersion') == 1,
            'Missing native gameplay evidence schema')
    require(not any('offlineFixture' in document for document in (spec, result, summary)),
            'Explicitly untrusted offline fixtures cannot qualify as native evidence')
    require(isinstance(result.get('status'), str) and isinstance(result.get('reason'), str)
            and isinstance(native_log, str)
            and f'TCC_GAMEPLAY_QA_{str(result.get("status", "")).upper()}: {result.get("reason")}' in native_log,
            'Native status/reason is not bound to its actual runtime log')
    require(spec.get('room') == 'r_gameplay_qa' and spec.get('mode') == 'replay'
            and result.get('inputMode') == 'replay' and result.get('inputs') == spec.get('inputs')
            and type(spec.get('fps')) is int and spec['fps'] in FPS
            and result.get('fps') == spec.get('fps') and result.get('seed') == spec.get('seed', 1),
            'Native input, seed, diagnostic room or render-cap binding differs')
    try:
        validate_input_events(spec.get('inputs'))
    except (ValueError, TypeError) as error:
        errors.append('Invalid submitted inputs: ' + str(error))
    require(summary.get('requestedRenderFps') == spec.get('fps')
            and summary.get('requestedInputClock') == INPUT_CLOCK
            and summary.get('requestedSimulationHz') == SIMULATION_HZ,
            'Launcher requested clock/render-cap binding differs')
    require(all(summary.get(key) == result.get(key) for key in
                ('status', 'reason', 'frames', 'deaths', 'bounds')),
            'Launcher status/state/counts differ from raw native result')
    require(finite(result.get('elapsedUs')) and result['elapsedUs'] >= 0
            and summary.get('nativeElapsedUs') == result.get('elapsedUs')
            and finite(summary.get('wallSeconds')) and summary['wallSeconds'] >= 0,
            'Separate native/launcher elapsed measurements are absent or unbound')
    for field, count_field in (('renderFrameDeltasUs', 'renderFrames'),
                               ('simulationFrameDeltasUs', 'simulationFrames')):
        values = result.get(field)
        require(isinstance(values, list) and whole_number(result.get(count_field))
                and len(values) == result[count_field]
                and all(finite(value) and value >= 0 for value in values),
                'Missing/truncated separate native clock deltas: ' + field)
    require(isinstance(result.get('frameDeltasUs'), list)
            and result.get('frameDeltasUs') == result.get('simulationFrameDeltasUs'),
            'Legacy frame deltas are not bound to the simulation clock')
    count = result.get('simulationFrames')
    maximum = spec.get('maxFrames')
    require(whole_number(count, 1) and whole_number(maximum, 1) and count <= maximum,
            'Native simulation count is absent or exceeds the requested budget')
    require(whole_number(spec.get('traceEvery')) and spec.get('traceEvery') == 1,
            'Every simulation-tick trace must be explicitly requested')
    actor = 'o_playerMU' if spec.get('actor', 'single-player') == 'local-multiplayer' else 'o_player'
    trace = result.get('trace')
    def player_sample(sample):
        return (isinstance(sample, dict) and sample.get('room') == 'r_gameplay_qa'
                and sample.get('actor') == actor
                and all(finite(sample.get(field)) for field in
                        ('x', 'y', 'hsp', 'vsp', 'color', 'gravity', 'walkSpeed', 'breath', 'doubleJump',
                         'water', 'zeroGravity', 'ammo', 'keysRemaining', 'challengeTime', 'challengeDeaths',
                         'direction', 'motionSpeed', 'seed', 'lives'))
                and all(native_flag(sample.get(field)) for field in
                        ('grounded', 'paused', 'cheats', 'revealHidden', 'challengePractice'))
                and isinstance(sample.get('bbox'), list) and len(sample['bbox']) == 4
                and all(finite(value) for value in sample['bbox'])
                and sample['bbox'][0] <= sample['bbox'][2] and sample['bbox'][1] <= sample['bbox'][3])
    require(isinstance(trace, list) and whole_number(count, 1) and len(trace) == count
            and all(player_sample(sample) and whole_number(sample.get('frame'))
                    and sample['frame'] == index for index, sample in enumerate(trace)),
            'Player trace is missing/truncated or not bound to every logical tick')
    require(player_sample(result.get('initial')) and result['initial'].get('frame') == 0,
            'Missing initial native player/fixture state')
    require(isinstance(trace, list) and bool(trace) and result.get('final') == trace[-1],
            'Final native state is not the last observed player tick')
    require(isinstance(result.get('events'), list)
            and all(isinstance(event, dict) for event in result['events']), 'Missing/malformed native event array')
    if player_sample(result.get('initial')) and isinstance(trace, list) and trace and all(player_sample(sample) for sample in trace):
        xs = [result['initial']['x'], *(sample['x'] for sample in trace)]
        ys = [result['initial']['y'], *(sample['y'] for sample in trace)]
        require(result.get('bounds') == {'minX': min(xs), 'maxX': max(xs), 'minY': min(ys), 'maxY': max(ys)},
                'Native bounds differ from actual initial/per-tick player observations')
    require(isinstance(spec.get('identity'), dict) and bool(spec.get('identity'))
            and result.get('sourceIdentity') == spec.get('identity'),
            'Request/native source identity differs or is absent')
    require(bound is not None, 'Fresh source/executable/artifact build binding is required')
    require(run is not None, 'Original native run path is required for save/output binding')
    if run is not None:
        run = Path(run).resolve()
        require(result.get('isolatedSaveRoot') == spec.get('saveRoot') == str(run / 'saves')
                and (run / 'saves').is_dir(), 'Request/native saves are not isolated in this run')
        require(spec.get('output') == str(run / 'runtime.json'), 'Native output path differs from original run')
    if bound is not None:
        try:
            errors.extend(trace_source_contract_errors(bound['snapshot']))
            content = level_content_identity(spec, Path(bound['snapshot']))
            expected = {**bound['source'], 'executableSha256': bound['executableSha256'],
                        'artifactSha256': bound['artifact']['sha256'], 'levelContentSha256': content}
            require(spec.get('identity') == expected, 'Request identity differs from freshly hashed build/content')
            require(summary.get('sourceIdentity') == bound['source']
                    and summary.get('executableSha256') == bound['executableSha256']
                    and summary.get('levelContentSha256') == content,
                    'Launcher source/executable/content hashes differ from frozen build')
        except (OSError, ValueError, KeyError, TypeError) as error:
            errors.append('Invalid native build/content binding: ' + str(error))
    return errors


def read_native_record(run, build=None):
    """Read immutable raw data, freshly rehash the build, and detect read races."""
    run = Path(run).resolve()
    files = [run / name for name in ('spec.json', 'runtime.json', 'summary.json', 'runtime.log')]
    before = {str(path): file_hash(path) for path in files}
    spec, result, summary = [json.loads(path.read_text()) for path in files[:3]]
    if not all(isinstance(document, dict) for document in (spec, result, summary)):
        raise ValueError('Native request/result/summary must be objects')
    log = files[3].read_text(errors='replace')
    bound = binding(build) if build is not None else None
    errors = native_record_errors(spec, result, summary, bound, run, log)
    storage = summary.get('evidenceStorage')
    if isinstance(storage, dict) and storage.get('sha256') is not None and storage['sha256'] != before[str(files[1])]:
        errors.append('Raw runtime hash differs from launcher/compression evidence')
    if {str(path): file_hash(path) for path in files} != before:
        errors.append('Raw native files changed during verification')
    current = False
    if bound is not None:
        current = (source_identity(ROOT)['physicsSha256'] == bound['source']['physicsSha256']
                   and level_content_identity(spec, ROOT) == level_content_identity(spec, Path(bound['snapshot'])))
    return spec, result, summary, errors, current, before


def specification(colour, orientation, scenario, fps, seed=1):
    """Author 60 Hz input ticks; vertical timing is verified by the engine."""
    if (type(fps) is not int or fps not in FPS or type(colour) is not int or colour not in range(5)
            or type(orientation) is not int or orientation not in range(4)):
        raise ValueError('Unsupported slope fixture setting')
    if scenario not in (LOWER if orientation < 2 else UPPER):
        raise ValueError('Scenario does not match the slope orientation')
    motion = ('ascent' if orientation < 2 else 'ceiling') if scenario == 'mismatch' else scenario
    if orientation < 2:
        direction = 1 if orientation == 0 else 2
        if motion == 'descent':
            direction = 3 - direction
    elif motion == 'empty':
        direction = 2 if orientation == 2 else 1
    else:
        direction = 1 if orientation == 2 else 2
    frame = lambda seconds: round(seconds * SIMULATION_HZ)
    if motion == 'jump':
        inputs = [
            {'frame': frame(.25), 'mask': direction},
            {'frame': frame(1.05), 'mask': 0},
            {'frame': frame(1.10), 'mask': 4},
            {'frame': frame(1.10) + 1, 'mask': 0},
            {'frame': frame(2.20), 'mask': direction},
        ]
    elif motion == 'ceiling':
        inputs = [
            {'frame': frame(.25), 'mask': 4},
            {'frame': frame(.25) + 1, 'mask': 0},
            {'frame': frame(1.65), 'mask': direction},
        ]
    else:
        inputs = [{'frame': frame(.25), 'mask': direction}]
    result = 'death' if scenario == 'mismatch' and colour != 4 else ('observed' if motion == 'side' else 'complete')
    return {
        'room': 'r_gameplay_qa', 'fixture': 'slope', 'mode': 'replay',
        'fps': fps, 'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ,
        'seed': seed, 'expect': 'frames' if motion == 'side' else 'exit',
        'maxFrames': frame(2.50 if motion == 'side' else 5), 'traceEvery': 1,
        'allowDeaths': False, 'diagnosticOnly': True,
        'slope': {'colour': colour, 'orientation': orientation, 'scenario': scenario},
        'validation': {'status': result, 'motion': motion,
                       'pickupColour': (1 if colour == 0 else 0) if scenario == 'mismatch' else colour,
                       'description': description(orientation, motion, result)},
        'inputs': inputs,
        'requestCandidate': dict(CANDIDATE),
    }


def validate_request(spec, *, fixed_clock=True):
    if not isinstance(spec, dict) or spec.get('room') != 'r_gameplay_qa':
        raise ValueError('Expected a native diagnostic request in r_gameplay_qa')
    if 'fpsOverrides' in spec:
        raise ValueError('Legacy fpsOverrides cannot select simulation inputs by render cap')
    if fixed_clock:
        require_fixed_clock(('slope diagnostic request', spec))
    if (type(spec.get('fps')) is not int or spec['fps'] not in FPS
            or spec.get('mode', 'replay') != 'replay'
            or spec.get('expect') not in ('frames', 'exit')):
        raise ValueError('Use pure replay inputs, a supported render cap and frames/exit observation')
    if any(key in spec for key in ('challenge', 'specialIndex', 'route', 'routeStartFrame', 'playerColor')):
        raise ValueError('Slope diagnostics cannot contain authored-content or adaptive-route setup')
    fixture = spec.get('fixture')
    if set(spec) - DIAGNOSTIC_REQUEST_FIELDS - {'slope', 'validation', 'projectile', 'orientation'}:
        raise ValueError('Unsupported request fields could change the diagnostic fixture')
    if any(key in spec for key in ('cameraFixture', 'cameraObservation', 'timingProbe', 'timingScenario',
                                   'levelSelect', 'endlessMode', 'cosmetics', 'cosmeticFixtures')):
        raise ValueError('Unrelated diagnostic/gameplay setup changes the requested slope fixture')
    if not whole_number(spec.get('seed', 1)):
        raise ValueError('Fixture seed must be a nonnegative whole number')
    if fixture == 'slope':
        if 'projectile' in spec or 'orientation' in spec:
            raise ValueError('Actor fixture parameters cannot select a player slope fixture')
        slope = spec.get('slope', {})
        if not isinstance(slope, dict):
            raise ValueError('Missing slope geometry settings')
        if set(slope) != {'colour', 'orientation', 'scenario'}:
            raise ValueError('Unsupported slope geometry settings')
        canonical = specification(slope.get('colour'), slope.get('orientation'), slope.get('scenario'), spec['fps'])
        if (not isinstance(spec.get('validation'), dict)
                or not whole_number(spec['validation'].get('pickupColour'))
                or spec['validation'] != canonical['validation'] or spec.get('expect') != canonical['expect']):
            raise ValueError('Slope validation/exit expectation does not match the actual requested fixture')
        if spec.get('allowDeaths', False) is not False:
            raise ValueError('Slope mismatch must stop on its actual first death')
    elif fixture == 'projectile-slopes':
        if any(key in spec for key in ('slope', 'validation', 'orientation')):
            raise ValueError('Unrelated geometry/validation parameters in projectile fixture')
        if spec.get('projectile') not in ACTOR_PROJECTILES:
            raise ValueError('Unsupported native projectile fixture')
    elif fixture == 'troop-slope':
        if any(key in spec for key in ('slope', 'validation', 'projectile')):
            raise ValueError('Unrelated geometry/validation parameters in troop fixture')
        if type(spec.get('orientation')) is not int or spec['orientation'] not in (0, 1):
            raise ValueError('Unsupported native troop slope orientation')
    else:
        raise ValueError('Expected slope, projectile-slopes or troop-slope diagnostic')
    if spec.get('actor', 'single-player') not in ('single-player', 'local-multiplayer'):
        raise ValueError('Unsupported slope diagnostic actor')
    if fixture != 'slope':
        if spec.get('actor', 'single-player') != 'single-player' or spec.get('expect') != 'frames':
            raise ValueError('Native actor fixtures require the actual single-player observer')
        expected_inputs = ([] if fixture == 'projectile-slopes' else
                           [{'frame': 15, 'mask': 1 if spec['orientation'] == 0 else 2}])
        if spec.get('maxFrames') != (12 if fixture == 'projectile-slopes' else 150) or spec.get('inputs') != expected_inputs:
            raise ValueError('Native actor fixture input schedule/tick budget differs from the canonical observation')
    validate_input_events(spec.get('inputs'))
    maximum = spec.get('maxFrames')
    if not whole_number(maximum, 1) or (spec['inputs'] and maximum <= spec['inputs'][-1]['frame']):
        raise ValueError('Simulation-tick budget must extend beyond the last input change')
    if not whole_number(spec.get('traceEvery')) or spec.get('traceEvery') != 1:
        raise ValueError('Slope verification requires every simulation-tick observation')
    if fixed_clock:
        launch_timeout(spec)
    return spec


def diagnostic_errors(spec, result, summary, *, native_errors=None):
    """Bind clocks and ordinary inputs before inspecting native geometry."""
    errors = list(native_errors) if native_errors is not None else native_record_errors(spec, result, summary)
    try:
        validate_request(spec)
        validate_input_events(result.get('inputs'))
    except (ValueError, TypeError) as error:
        errors.append(str(error))
    if not summary.get('normalRuntimeEnd') or not summary.get('compiledPayloadVerified'):
        errors.append('Missing normal native termination or compiled payload binding')
    if (result.get('inputMode') != 'replay' or result.get('inputs') != spec.get('inputs')
            or result.get('sourceIdentity') != spec.get('identity')
            or not isinstance(spec.get('identity'), dict) or not spec['identity']
            or result.get('fps') != spec.get('fps') or result.get('seed') != spec.get('seed', 1)):
        errors.append('Native input, identity, seed or render-cap binding differs from specification')
    if result.get('normalRules') is not True or result.get('diagnosticOnly') is not True:
        errors.append('Missing normal-rules diagnostic marker')
    return errors


def diagnostic_report(spec, result, summary, errors, current=False):
    clock_issues = proof_clock_errors(spec, result, summary)
    return {'passed': not errors, 'errors': errors, 'diagnosticOnly': True,
            'qualifiesCurrentDiagnostic': not errors and current is True,
            'fps': spec.get('fps'), 'requestedRenderFps': spec.get('fps'),
            'inputClock': result.get('inputClock'), 'simulationHz': result.get('simulationHz'),
            'clockVerified': not clock_issues, 'clockErrors': clock_issues,
            'simulationFrames': result.get('simulationFrames'), 'renderFrames': result.get('renderFrames'),
            'simulationSeconds': result.get('frames', 0) / SIMULATION_HZ if not clock_issues else None,
            'nativeElapsedUs': result.get('elapsedUs'), 'launcherWallSeconds': summary.get('wallSeconds'),
            'observedRenderFps': summary.get('observedRenderFps'),
            'sourceIdentity': result.get('sourceIdentity'),
            'matchesCurrentPlayableContent': current is True,
            'cachedLauncherMatchesCurrentPlayableContent': summary.get('matchesCurrentPlayableContent'),
            'qualifiesAsAuthoredContent': False}


def request_from_legacy_60(path, fps=SIMULATION_HZ):
    """Retain old60 request inputs as a new unverified request, never a proof."""
    path = Path(path).resolve()
    original_bytes = path.read_bytes()
    source = validate_request(json.loads(original_bytes), fixed_clock=False)
    if source['fps'] != SIMULATION_HZ:
        raise ValueError('Only authentic old 60 FPS input timelines can be retained unchanged')
    if 'inputClock' in source or 'simulationHz' in source:
        require_fixed_clock(('source request', source))
    fields = ('room', 'fixture', 'mode', 'seed', 'expect', 'maxFrames', 'traceEvery', 'allowDeaths',
              'diagnosticOnly', 'slope', 'validation', 'projectile', 'orientation', 'actor',
              'inputs', 'captureFrames', 'observeTroops', 'wallTimeoutSeconds')
    candidate = {key: source[key] for key in fields if key in source}
    candidate.update(fps=fps, inputClock=INPUT_CLOCK, simulationHz=SIMULATION_HZ,
                     diagnosticOnly=True,
                     slopeCandidate={'verified': False, 'requiresFreshNativeRecording': True,
                         'requestSource': str(path),
                         'requestSha256': hashlib.sha256(original_bytes).hexdigest(),
                         'originalRenderFps': source['fps'], 'originalInputClock': source.get('inputClock'),
                         'qualification': 'Unverified request only; historical runtime evidence is unchanged.',
                         'retryTimeline': 'Death/respawn consume logical ticks; any retry schedule needs fresh recording.'})
    return validate_request(candidate)


def write_request(path, request):
    """Export only explicit-clock requests, leaving historical files untouched."""
    validate_request(request)
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x') as file:
        file.write(json.dumps({**request, 'requestCandidate': dict(CANDIDATE)}, indent=2) + '\n')


def description(orientation, motion, result):
    if result == 'death':
        return 'An ordinary incompatible-colour contact must kill the player before any door completion.'
    return {
        'ascent': 'Walk from the lower floor, climb the 128-pixel triangle, cross its flat seam and reach the upper door.',
        'descent': 'Walk from the upper landing, remain supported down the triangle and reach the lower door.',
        'jump': 'Climb to mid-slope, stop, jump once with the normal jump, land on the same triangle and reach the upper door.',
        'ceiling': 'Jump into the upper triangle diagonal, stop at the ceiling, land and walk to the door.',
        'side': 'Walk into the upper triangle flat wall and remain outside it; the door behind it must not be reached.',
        'empty': 'Walk into the empty lower half of the upper triangle bounding box and reach the door in the nook.',
    }[motion]


def observed_ceiling_stop(trace, orientation):
    """Recognize a real native stop within the solver's one-pixel clearance.

    Single-precision instance storage can leave the exact y-1 contact query
    one ULP short. Require the actual upward velocity to stop, the player to
    stay outside the triangle, and its mask to be at the authored diagonal.
    This checks recorded native states; it never predicts or changes movement.
    """
    for previous, state in zip(trace, trace[1:]):
        if previous['vsp'] >= -1 or abs(state['vsp']) > .0001:
            continue
        left, top, right, bottom = state['bbox']
        corner = right - .5 if orientation == 2 else left + .5
        plane = 6840 + (corner - 384 if orientation == 2 else 512 - corner)
        gap = top + .5 - plane
        ulp = max(1, abs(left), abs(top), abs(right), abs(bottom)) * 2 ** -23
        if (0 <= gap <= 1 + 2 * ulp and 384 <= corner < 512
                and abs(state['x'] - previous['x']) <= 2 * ulp
                and state['y'] <= previous['y'] + 2 * ulp
                and not state['slopeContact']['overlap']):
            return {'frame': state['frame'], 'maskDiagonalGapPixels': gap,
                    'maximumClearancePixels': 1 + 2 * ulp}
    return None


def verify(run_dir, build=None):
    run_dir = Path(run_dir)
    try:
        spec, result, summary, native_errors, current, hashes = read_native_record(run_dir, build)
    except (OSError, ValueError, KeyError, TypeError) as error:
        return {'passed': False, 'diagnosticOnly': True, 'qualifiesCurrentDiagnostic': False,
                'errors': ['Native record/build read failed: ' + str(error)], 'run': str(run_dir.resolve())}
    if spec.get('fixture') != 'slope':
        raise ValueError('Not a slope diagnostic')
    errors = diagnostic_errors(spec, result, summary, native_errors=native_errors)
    if errors:
        return {**diagnostic_report(spec, result, summary, errors, current), 'rawHashes': hashes,
                'slope': spec.get('slope'), 'run': str(run_dir.resolve())}
    expected = spec['validation']
    slope = spec['slope']
    trace = result.get('trace', [])

    def require(condition, message):
        if not condition:
            errors.append(message)

    local_multiplayer = spec.get('actor') == 'local-multiplayer'
    native_status = 'observed' if local_multiplayer and expected['status'] == 'complete' else expected['status']
    require(result['status'] == native_status, f"Status {result['status']} != {native_status}")
    motion = expected['motion']
    orientation = slope['orientation']
    if orientation < 2:
        high_x, low_x = (256, 640) if orientation == 0 else (640, 224)
        start = (high_x, 6844) if motion == 'descent' else (low_x, 6972)
    elif motion == 'side':
        start = (640 if orientation == 2 else 224, 6972)
    elif motion == 'empty':
        start = (224 if orientation == 2 else 640, 6956)
    else:
        start = (432, 6972)
    require((result['initial']['x'], result['initial']['y']) == start,
            'Initial player placement differs from the actual requested slope fixture')
    if local_multiplayer:
        require(result['initial'].get('actor') == 'o_playerMU'
                and all(state.get('actor') == 'o_playerMU' for state in trace),
                'Missing actual local multiplayer actor trace')
    require(result.get('normalRules') is True, 'Assisted rules were active')
    require(result['fps'] == spec['fps'], 'Requested render cap changed')
    require(result.get('sourceIdentity') == spec.get('identity'), 'Evidence identity differs from specification')
    require(result.get('diagnosticOnly') is True, 'Diagnostic evidence lacks its non-content marker')
    require(bool(trace), 'No real player trace')
    ticks = [state.get('frame') for state in trace]
    require(all(whole_number(tick) for tick in ticks)
            and all(a < b for a, b in zip(ticks, ticks[1:])),
            'Player observations repeat/misorder logical ticks')
    if whole_number(result.get('frames')) and all(whole_number(tick) for tick in ticks):
        require(all(tick <= result['frames'] for tick in ticks), 'Player observation exceeds the native simulation-tick count')
    require(any(s.get('color') == expected['pickupColour'] for s in trace), 'Normal colour pickup did not take effect')
    pickup_index = next((i for i, state in enumerate(trace)
                         if state.get('color') == expected['pickupColour']), None)
    if pickup_index is not None:
        require(all(state.get('color') == expected['pickupColour'] for state in trace[pickup_index:]),
                'Gameplay colour changed after the only fixture pickup')
    require(any(isinstance(s.get('slopeContact'), dict) for s in trace), 'No native slope-contact observations')
    contacts = [s for s in trace if isinstance(s.get('slopeContact'), dict)]
    contact_fields = ('floor', 'ceiling', 'left', 'right', 'overlap', 'insideBounds')
    require(len(contacts) == len(trace) and all(
        all(native_flag(state['slopeContact'].get(key)) for key in contact_fields)
        and whole_number(state['slopeContact'].get('colour'))
        and whole_number(state['slopeContact'].get('orientation')) for state in contacts),
        'Missing/malformed per-tick actual slope contact observations')
    if errors:
        return {**diagnostic_report(spec, result, summary, errors, current), 'slope': slope, 'rawHashes': hashes}
    for state in contacts:
        c = state['slopeContact']
        require(c['orientation'] == slope['orientation'] and c['colour'] == slope['colour']
                and c.get('scenario') == slope['scenario'], 'Observed slope fixture identity changed')
        # Touch may occur at the half-pixel boundary; an actual body overlap is
        # still a solver defect, even if the ordinary death check later fires.
        if expected['status'] != 'death':
            require(not c['overlap'], f"Player embedded in triangle at frame {state['frame']}")
        if 'animationVelocity' in state and c['floor'] and state['vsp'] >= 0:
            require(state['animationVelocity'] == 0,
                    f"Slope support uses an airborne pose at frame {state['frame']}")
            if abs(state['hsp']) > .01 and expected['status'] != 'death':
                require(state['animationFrame'] in [1, 2],
                        f"Grounded slope traversal has frame {state['animationFrame']} at {state['frame']}")
    if expected['status'] == 'death':
        require(result['deaths'] == 1, 'Expected exactly one normal death')
        require(result.get('completion') is None, 'Incompatible contact reached the exit')
        deaths = [event.get('state') for event in result.get('events', []) if event.get('kind') == 'death']
        require(len(deaths) == 1 and isinstance(deaths[0], dict)
                and whole_number(deaths[0].get('frame')) and deaths[0]['frame'] == result['frames'] - 1
                and deaths[0].get('actor') == ('o_playerMU' if local_multiplayer else 'o_player')
                and deaths[0].get('room') == 'r_gameplay_qa', 'No matching actual native terminating-death snapshot')
        return {**diagnostic_report(spec, result, summary, errors, current), 'slope': slope, 'rawHashes': hashes}

    require(result['deaths'] == 0, 'Diagnostic route died')
    motion = expected['motion']
    if expected['status'] == 'complete':
        require(result.get('completion') is not None, 'No actual door contact')
        require(any(e.get('kind') == 'exit-contact' for e in result.get('events', [])), 'No observed exit event')
    else:
        require(result.get('completion') is None, 'The wall was bypassed')
    if motion in ('ascent', 'descent', 'jump'):
        supported = [s for s in contacts if s['slopeContact']['floor']]
        require(len(supported) >= 3, 'Too little actual diagonal support')
        if motion == 'descent':
            require(any(s['y'] > 6940 for s in supported), 'Did not descend to the lower slope section')
        else:
            require(any(s['y'] < 6880 for s in supported), 'Did not ascend to the upper slope section')
        if motion == 'jump':
            pulse = next((e['frame'] for e in spec['inputs'] if e['mask'] == 4), None)
            require(pulse is not None, 'Missing ordinary jump pulse')
            if pulse is not None:
                before = [s for s in supported if pulse - 3 <= s['frame'] < pulse]
                after = [s for s in contacts if pulse <= s['frame'] <= pulse + 2]
                require(bool(before) and any(s['vsp'] < -5 for s in after), 'Jump did not begin from slope support')
                require(any(s['frame'] > pulse + 5 for s in supported), 'Jump did not land on the slope')
    elif motion == 'ceiling':
        stop = observed_ceiling_stop(contacts, slope['orientation'])
        require(any(s['slopeContact']['ceiling'] for s in contacts) or stop is not None,
                'Jump did not stop at the diagonal ceiling')
        require(any(s['vsp'] < -1 for s in contacts), 'No normal jump was observed')
    elif motion == 'empty':
        require(any(s['slopeContact']['insideBounds'] and not s['slopeContact']['overlap'] for s in contacts),
                'Route did not enter the empty half of the triangle bounding box')
    elif motion == 'side':
        side = 'right' if slope['orientation'] == 3 else 'left'
        stopped = [s for s in contacts if s['slopeContact'][side] and abs(s['hsp']) < .001]
        require(len(stopped) >= SIMULATION_HZ // 2, 'Player did not remain blocked for half a simulation second at the flat side')
        require(result.get('simulationFrames') == spec['maxFrames'], 'Flat-side observation ended before its full simulation-tick budget')
        if slope['orientation'] == 3:
            require(all(s['bbox'][2] <= 384.5 for s in contacts), 'Passed through the triangle left wall')
        else:
            require(all(s['bbox'][0] >= 511.5 for s in contacts), 'Passed through the triangle right wall')
    return {**diagnostic_report(spec, result, summary, errors, current), 'slope': slope, 'rawHashes': hashes,
            'actor': 'local-multiplayer' if local_multiplayer else 'single-player', 'errors': errors}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    generate = commands.add_parser('generate', help='Write input specifications; this is not completion evidence')
    generate.add_argument('--output', type=Path, required=True)
    generate.add_argument('--fps', type=int, nargs='+', choices=FPS, default=FPS, help='Render caps; input schedules always use 60 Hz')
    generate.add_argument('--colour', choices=COLOURS, nargs='+', default=COLOURS)
    generate.add_argument('--scenario', choices=tuple(dict.fromkeys(LOWER + UPPER)), nargs='+')
    generate.add_argument('--seed', type=int, default=1)
    check = commands.add_parser('verify', help='Check one or more real native run output directories')
    check.add_argument('runs', type=Path, nargs='+')
    check.add_argument('--build', type=Path, required=True, help='Rehash the actual frozen QA build; never launches')
    request = commands.add_parser('request-60', help='Copy authentic old60 diagnostic inputs into a NEW UNVERIFIED fixed60 request')
    request.add_argument('spec', type=Path)
    request.add_argument('--fps', type=int, choices=FPS, default=SIMULATION_HZ, help='New render cap; original ticks remain exact')
    request.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.command == 'request-60':
        write_request(args.output, request_from_legacy_60(args.spec, args.fps))
        print(json.dumps({'requestCandidate': str(args.output), 'verified': False,
                          'requiresFreshNativeRecording': True, 'diagnosticOnly': True}))
        return 0
    if args.command == 'generate':
        args.output.mkdir(parents=True, exist_ok=True)
        count = 0
        for fps in args.fps:
            for colour_name in args.colour:
                colour = COLOURS.index(colour_name)
                for orientation in range(4):
                    for scenario in LOWER if orientation < 2 else UPPER:
                        if args.scenario and scenario not in args.scenario:
                            continue
                        path = args.output / f'{colour_name}-{orientation}-{scenario}-{fps}.json'
                        write_request(path, specification(colour, orientation, scenario, fps, args.seed))
                        count += 1
        print(json.dumps({'specifications': count, 'diagnosticOnly': True, 'output': str(args.output.resolve())}))
        return 0
    reports = []
    for run in args.runs:
        try:
            report = verify(run, args.build)
        except (OSError, ValueError, KeyError, TypeError) as error:
            report = {'passed': False, 'diagnosticOnly': True, 'errors': [str(error)]}
        report['run'] = str(run.resolve())
        reports.append(report)
    print(json.dumps(reports, indent=2))
    return 0 if all(r['passed'] for r in reports) else 1


if __name__ == '__main__':
    raise SystemExit(main())
