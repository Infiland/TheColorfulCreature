#!/usr/bin/env python3
"""Offline requests and strict native pause/interruption assessment.

``generate`` writes NEW UNVERIFIED 240-tick pure-replay requests at render
caps60/150. ``verify`` reads actual native evidence; ``compare`` requires an
actual cap60 comparator for each scenario. No command launches the game.
pause-input-v1 uses normal pause32 rising edges; platform-interrupt-v1 calls
production platform_interrupt() at tick60, not an actual OS suspension.
End observations follow timing_end_step(). Gameplay time uses tau=1/60;
wall/session durations are observed independently and never compared equally.
"""
import argparse
from collections import defaultdict
import copy
import json
import math
import re
from pathlib import Path

from gameplay_qa import (INPUT_CLOCK, SIMULATION_HZ, INPUT_BITS,
                         require_fixed_clock, validate_input_events, whole_number)
from native_evidence import file_hash
from tcc_project import ROOT
from timing_qa import Audit, binding, finite, preparation_errors, record_errors

SCENARIOS = ('pause-input-v1', 'platform-interrupt-v1')
CAPS = (60, 150)
TICKS = 240
PAUSE_FRAME, RESUME_FRAME = 60, 180
TAU = 1 / SIMULATION_HZ
TICK_US = 1000000 / SIMULATION_HZ
CLOCK_EPSILON_US = 0.0001  # Same native accumulator tick-decision epsilon.
FLOAT_ABS, FLOAT_REL = 1e-6, 1e-10
POSE_FIELDS = ('x', 'y', 'hsp', 'vsp', 'bbox', 'direction', 'motionSpeed',
               'gravity', 'walkSpeed', 'color', 'grounded', 'water', 'breath',
               'doubleJump', 'zeroGravity', 'ammo', 'keysRemaining')
CONTINUOUS = {'x', 'y', 'hsp', 'vsp', 'bbox', 'direction', 'motionSpeed',
              'gravity', 'walkSpeed', 'breath', 'challengeTime', 'animationFrame',
              'animationVelocity', 'eyesY'}
BOOL_FIELDS = ('paused', 'inputApplied', 'playerPresent', 'pauseController',
               'pauseScreen', 'returnButton', 'previousPauseApplied',
               'resumeBoundaryApplied', 'backgroundBoundaryApplied',
               'pauseClockAfterEnd', 'resumeBoundaryLatched', 'settingsButton',
               'feedbackButton', 'restartButton', 'isSimulationTick', 'beginPending')
WALL_FIELDS = ('elapsedUs', 'pausedWallSeconds', 'outerElapsedUs',
               'accumulatorUs', 'accumulatorBeforeUs')
SCOPE = ('Actual native End observations and ordinary pause/controller behavior; '
         'cross-cap acceptance requires actual60. No level/completion or OS-suspend claim.')


def same(field, left, right):
    if isinstance(left, dict) and isinstance(right, dict):
        return left.keys() == right.keys() and all(same(k, left[k], right[k]) for k in left)
    if isinstance(left, list) and isinstance(right, list):
        return len(left) == len(right) and all(same(field, a, b) for a, b in zip(left, right))
    if field in CONTINUOUS and finite(left) and finite(right):
        return math.isclose(left, right, abs_tol=FLOAT_ABS, rel_tol=FLOAT_REL)
    return type(left) is type(right) and left == right or (
        type(left) in (int, float) and type(right) in (int, float) and left == right)


def specification(kind, fps):
    if kind not in SCENARIOS or type(fps) is not int or fps not in CAPS:
        raise ValueError('Expected pause-input-v1/platform-interrupt-v1 and render cap60/150')
    right, pause = INPUT_BITS['right'], INPUT_BITS['pause']
    inputs = [{'frame': frame, 'mask': mask} for frame, mask in
              [(0, 0), (30, right), (60, right | pause if kind == SCENARIOS[0] else right),
               (61, right), (180, right | pause), (181, right), (210, 0)]]
    scenario = {'kind': kind}
    if kind == SCENARIOS[1]:
        scenario['interruptFrame'] = PAUSE_FRAME
    return {'room': 'r_gameplay_qa', 'fixture': 'default', 'mode': 'replay',
            'fps': fps, 'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ,
            'seed': 1, 'expect': 'frames', 'maxFrames': TICKS, 'traceEvery': 1,
            'inputs': inputs, 'timingScenario': scenario,
            'pauseCandidate': {'verified': False, 'requiresFreshNativeRecording': True,
                               'scope': SCOPE}}


def request_errors(spec):
    audit = Audit()
    if not audit.require(isinstance(spec, dict), 'request must be an object'):
        return audit
    try:
        require_fixed_clock(('pause request', spec))
        validate_input_events(spec.get('inputs'))
    except ValueError as error:
        audit.require(False, str(error))
    scenario = spec.get('timingScenario')
    kind = scenario.get('kind') if isinstance(scenario, dict) else None
    valid = audit.require(kind in SCENARIOS and type(spec.get('fps')) is int and spec['fps'] in CAPS,
                          'missing/wrong pause scenario or requested render cap')
    if valid:
        expected = specification(kind, spec['fps'])
        fields = ('room', 'fixture', 'mode', 'fps', 'inputClock', 'simulationHz', 'seed',
                  'expect', 'maxFrames', 'traceEvery', 'inputs', 'timingScenario')
        audit.require(all(spec.get(key) == expected[key] for key in fields),
                      'request differs from the complete ordinary240-tick scenario/input timeline')
    audit.require(not any(key in spec for key in ('challenge', 'specialIndex', 'levelSelect',
                  'actor', 'playerColor', 'timingProbe', 'route', 'routeStartFrame', 'fpsOverrides', 'cosmetics')),
                  'request mixes pause observation with another fixture/controller or legacy timeline')
    if 'pauseCandidate' in spec:
        audit.require(isinstance(spec['pauseCandidate'], dict)
                      and spec['pauseCandidate'].get('verified') is False,
                      'generated/exported request must remain explicitly unverified')
    return audit


def merge(audit, other):
    for error in other.errors:
        audit.require(False, error)
    audit.count += max(0, other.count - len(other.errors))


def exact_snapshot(left, right):
    """No tolerance or coercion within two native observations of one tick."""
    if type(left) is not type(right):
        return False
    if isinstance(left, dict):
        return left.keys() == right.keys() and all(exact_snapshot(left[key], right[key]) for key in left)
    if isinstance(left, list):
        return len(left) == len(right) and all(exact_snapshot(a, b) for a, b in zip(left, right))
    return left == right


def pause_source_errors(bound):
    """Bind the distinct trace/observer schemas to the actual compiled source."""
    audit = Audit()
    try:
        snapshot = Path(bound['snapshot'])
        source = (snapshot / 'scripts/scr_gameplay_qa/scr_gameplay_qa.gml').read_text()
        source = re.sub(r'/\*[\s\S]*?\*/|//[^\n]*', '', source)
        compact = re.sub(r'\s+', '', source)
        observer = source.split('function qa_pause_observe()', 1)[1].split('\nfunction ', 1)[0]
        observer = re.sub(r'\s+', '', observer)
        fields = ('observationPhase:"root-end"', 'nativeEventType:event_type',
                  'nativeEventNumber:event_number', 'roomGeneration:_t.room_generation',
                  'room:room_get_name(room)', 'isSimulationTick:_t.tick', 'beginPending:_t.begin_pending',
                  'livePlayers:instance_number(o_player)', 'localPlayers:instance_number(o_playerMU)',
                  'deadPlayers:instance_number(o_playerdead)', 'challengeDeaths:global.deaths',
                  'settingsButton:instance_exists(o_settings)!=0',
                  'feedbackButton:instance_exists(o_givefeedback)!=0',
                  'restartButton:instance_exists(o_restartchallengebutton)!=0',
                  'player:_player!=noone?qa_snapshot(_player):undefined')
        audit.require(all(field in observer for field in fields),
                      'compiled pause observer lacks actual Root End/event/generation/count/UI reads')
        audit.require('traceSchemaVersion:2,traceBoundaries:"native-end-or-terminal-contact"' in compact
                      and '_state.observationPhase=_phase;' in compact
                      and 'qa_store_player_sample(_s,"root-end");' in compact
                      and compact.index('qa_pause_observe();') < compact.index('_q.frame+=1;'),
                      'compiled trace/observer phase or before-frame-increment contract differs')
        hook = (snapshot / 'objects/o_gameplay_qa/Step_2.gml').read_text()
        hook = re.sub(r'/\*[\s\S]*?\*/|//[^\n]*', '', hook)
        yy = json.loads((snapshot / 'objects/o_gameplay_qa/o_gameplay_qa.yy').read_text())
        audit.require(re.sub(r'\s+', '', hook) == 'timing_end_step();qa_end_step();'
                      and any(event.get('eventType') == 3 and event.get('eventNum') == 2
                              for event in yy.get('eventList', [])),
                      'compiled registered Root End hook/order differs from pause contract')
    except (OSError, ValueError, TypeError, KeyError, IndexError) as error:
        audit.require(False, 'compiled pause source contract unavailable: ' + str(error))
    return audit


def common_record_errors(spec, result, summary, bound, run, native_log):
    """Reuse every applicable shared native binding check without fake setup.

    timing_qa.record_errors includes a separate actor-probe preparation audit.
    Pause scenarios forbid that probe. Remove only its one missing-preparation
    error when both probe/setup are absent. Any supplied malformed preparation
    retains all shared errors. Initial frame0 is checked separately below.
    """
    shared = record_errors(spec, result, summary, bound, run, native_log)
    preparation = preparation_errors(result)
    if result.get('diagnosticPreparation') is None and result.get('timingProbe') is None:
        expected = ['missing native timing preparation metadata']
        if preparation.errors != expected or preparation.count != 1 or shared.errors[:1] != expected:
            raise ValueError('Shared timing audit preparation prefix changed; review adapter')
        shared.errors = shared.errors[1:]
        shared.count -= 1
    return shared


def observation_errors(spec, result):
    audit = Audit()
    merge(audit, request_errors(spec))
    if not isinstance(spec, dict):
        return audit, {}
    if not isinstance(result, dict):
        audit.require(False, 'runtime must be an object')
        return audit, {}
    audit.require(result.get('format') == 'tcc.gameplay-evidence' and whole_number(result.get('schemaVersion'), 1)
                  and result['schemaVersion'] == 1,
                  'missing/wrong native gameplay evidence format/schema')
    audit.require(result.get('inputMaskVersion') == 2 and type(result.get('inputMaskVersion')) in (int, float),
                  'runtime lacks the six-action inputMaskVersion2 schema')
    audit.require(whole_number(result.get('traceSchemaVersion'), 1)
                  and result['traceSchemaVersion'] == 2
                  and result.get('traceBoundaries') == 'native-end-or-terminal-contact',
                  'missing/wrong native terminal-observation trace schema2/boundary marker')
    audit.require(result.get('timingScenario') == spec.get('timingScenario'),
                  'native scenario differs from request or was lost during export')
    audit.require(result.get('timingProbe') is None and result.get('diagnosticPreparation') is None,
                  'pause observation unexpectedly contains actor-probe preparation')
    initial = result.get('initial')
    audit.require(isinstance(initial, dict) and whole_number(initial.get('frame')) and initial['frame'] == 0
                  and initial.get('paused') is False and finite(initial.get('challengeTime')),
                  'actual initial player/clock is not bound to unpaused recorded frame0')
    rows, trace = result.get('pauseObservations'), result.get('trace')
    complete = audit.require(isinstance(rows, list) and len(rows) == TICKS
                             and all(isinstance(row, dict) and whole_number(row.get('frame')) and row['frame'] == index
                                     for index, row in enumerate(rows)),
                             'missing/truncated/unordered per-tick native pause observations')
    audit.require(isinstance(trace, list) and len(trace) == TICKS,
                  'missing complete every-tick native player trace, including paused ticks')
    if not complete or request_errors(spec).count:
        return audit, {}
    audit.require(isinstance(trace, list) and bool(trace) and result.get('final') == trace[-1],
                  'native final player is not bound to the last complete trace sample')
    ending = result.get('endingContext')
    audit.require(isinstance(ending, dict) and ending.get('room') == 'r_gameplay_qa'
                  and same('challengeTime', ending.get('challengeTime'), rows[-1].get('challengeTime'))
                  and finite(result.get('elapsedUs')) and finite(rows[-1].get('elapsedUs'))
                  and result['elapsedUs'] >= rows[-1]['elapsedUs'],
                  'native ending room/gameplay/wall clocks differ from the final End observation')
    kind = spec['timingScenario']['kind']
    state, index = 0, 0
    canonical = {}
    for frame, row in enumerate(rows):
        while index < len(spec['inputs']) and spec['inputs'][index]['frame'] <= frame:
            state = spec['inputs'][index]['mask']; index += 1
        audit.require(whole_number(row.get('mask')) and row['mask'] == state, f'held input differs at tick{frame}')
        typed = audit.require(all(type(row.get(key)) is bool for key in BOOL_FIELDS)
                              and all(finite(row.get(key)) and row[key] >= 0 for key in WALL_FIELDS)
                              and finite(row.get('challengeTime')) and row['challengeTime'] >= 0
                              and all(whole_number(row.get(key), 1) for key in ('tickId', 'renderId'))
                              and whole_number(row.get('roomGeneration'), 1)
                              and all(whole_number(row.get(key)) for key in
                                      ('interruptSerial', 'consumedInterruptSerial', 'nativeEventType',
                                       'nativeEventNumber', 'livePlayers', 'localPlayers', 'deadPlayers', 'challengeDeaths')),
                              f'malformed/missing End clocks, counters or boolean states at tick{frame}')
        audit.require(row.get('observationPhase') == 'root-end' and row.get('room') == 'r_gameplay_qa'
                      and row.get('nativeEventType') == 3 and row.get('nativeEventNumber') == 2
                      and row.get('isSimulationTick') is True and row.get('beginPending') is True
                      and row.get('roomGeneration') == rows[0].get('roomGeneration')
                      and row.get('livePlayers') == 1 and row.get('localPlayers') == 0
                      and row.get('deadPlayers') == 0 and row.get('challengeDeaths') == 0,
                      f'actual Root End phase/room/generation/player counts differ at tick{frame}')
        paused = PAUSE_FRAME <= frame < RESUME_FRAME
        audit.require(row.get('paused') is paused and row.get('pauseClockAfterEnd') is paused,
                      f'actual pause/End clock transition differs at tick{frame}')
        audit.require(row.get('pauseController') is True and row.get('playerPresent') is True,
                      f'normal player/pause controller missing at tick{frame}')
        # Boundary Step ordering can affect input application on ticks60/180.
        if frame not in (PAUSE_FRAME, RESUME_FRAME):
            audit.require(row.get('inputApplied') is (not paused),
                          f'player input application differs inside pause/active interval at tick{frame}')
        audit.require(row.get('pauseScreen') is paused and row.get('returnButton') is paused,
                      f'actual pause UI presence differs at tick{frame}')
        audit.require(row.get('settingsButton') is paused and row.get('feedbackButton') is paused
                      and row.get('restartButton') is False,
                      f'actual pause settings/feedback cleanup or fixture restart UI differs at tick{frame}')
        audit.require(row.get('backgroundBoundaryApplied') is False,
                      f'unrequested OS/background boundary at tick{frame}')
        if frame:
            previous = rows[frame - 1]
            if typed and all(whole_number(previous.get(key), 1) for key in ('tickId', 'renderId')):
                audit.require(row['tickId'] == previous['tickId'] + 1 and row['renderId'] > previous['renderId'],
                              f'logical tick/native outer order differs at tick{frame}')
                audit.require(row['elapsedUs'] >= previous.get('elapsedUs', math.inf)
                              and row['pausedWallSeconds'] >= previous.get('pausedWallSeconds', math.inf),
                              f'wall observation moved backward at tick{frame}')
            if finite(previous.get('challengeTime')) and finite(row.get('challengeTime')):
                delta = row['challengeTime'] - previous['challengeTime']
                allowed = (0, TAU) if frame in (PAUSE_FRAME, RESUME_FRAME) else ((0,) if paused else (TAU,))
                audit.require(any(math.isclose(delta, value, abs_tol=1e-9, rel_tol=1e-10) for value in allowed),
                              f'gameplay clock did not use the actual End pause phase/tau at tick{frame}')
        if frame:
            audit.require(row.get('previousPauseApplied') is (PAUSE_FRAME < frame <= RESUME_FRAME),
                          f'Begin previous-End pause clock differs at tick{frame}')
        if typed and (row['previousPauseApplied'] or row['resumeBoundaryApplied'] or row['backgroundBoundaryApplied']):
            audit.require(row['accumulatorUs'] <= CLOCK_EPSILON_US,
                          f'paused/boundary logical tick retained gameplay debt at tick{frame}')
        player = row.get('player')
        player_valid = audit.require(isinstance(player, dict) and whole_number(player.get('frame')) and player['frame'] == frame
                                     and player.get('actor') == 'o_player' and player.get('room') == 'r_gameplay_qa'
                                     and player.get('paused') is paused
                                     and same('challengeTime', player.get('challengeTime'), row.get('challengeTime'))
                                     and all(key in player for key in POSE_FIELDS)
                                     and all(finite(player.get(key)) for key in ('x', 'y', 'hsp', 'vsp', 'direction', 'motionSpeed'))
                                     and isinstance(player.get('bbox'), list) and len(player['bbox']) == 4
                                     and all(finite(value) for value in player['bbox']),
                                     f'missing/malformed actual player snapshot at tick{frame}')
        if player_valid:
            native_trace = trace[frame] if isinstance(trace, list) and len(trace) > frame else None
            audit.require(isinstance(native_trace, dict) and native_trace.get('observationPhase') == 'root-end',
                          f'missing/wrong actual trace Root End phase at tick{frame}')
            # Only the required trace-only phase marker is excluded. Never add
            # a phase/default to the fresh observer snapshot or alter raw data.
            audit.require(isinstance(native_trace, dict) and exact_snapshot(
                              {key: value for key, value in native_trace.items() if key != 'observationPhase'}, player),
                          f'pause snapshot payload differs from raw native player trace at tick{frame}')
            if PAUSE_FRAME < frame < RESUME_FRAME and isinstance(rows[PAUSE_FRAME + 1].get('player'), dict):
                baseline = rows[PAUSE_FRAME + 1]['player']
                audit.require(all(same(key, player[key], baseline.get(key)) for key in POSE_FIELDS),
                              f'player pose/physics/state changed inside pause at tick{frame}')
            canonical[frame] = {key: row[key] for key in
                                ('frame', 'mask', 'paused', 'inputApplied', 'playerPresent', 'pauseController',
                                 'pauseScreen', 'returnButton', 'challengeTime', 'pauseClockAfterEnd',
                                 'previousPauseApplied', 'interruptSerial', 'consumedInterruptSerial',
                                 'settingsButton', 'feedbackButton', 'restartButton', 'observationPhase',
                                 'nativeEventType', 'nativeEventNumber', 'roomGeneration', 'room',
                                 'isSimulationTick', 'beginPending', 'livePlayers', 'localPlayers',
                                 'deadPlayers', 'challengeDeaths') if key in row}
            canonical[frame]['player'] = player
    if all(finite(rows[index].get('pausedWallSeconds')) for index in (61, 179)):
        audit.require(rows[179]['pausedWallSeconds'] > rows[61]['pausedWallSeconds'],
                      'actual wall pause accounting did not advance through the paused interior')
    players = [rows[index].get('player') for index in (29, 59, 181, 209)]
    if all(isinstance(player, dict) and finite(player.get('x')) for player in players):
        audit.require(players[1]['x'] > players[0]['x'] and players[3]['x'] > players[2]['x'],
                      'ordinary right input did not actually move the player before and after pause')
    events = result.get('events')
    audit.require(isinstance(events, list), 'missing native event list')
    interrupts = [event for event in (events if isinstance(events, list) else []) if isinstance(event, dict)
                  and event.get('kind') == 'production-platform-interrupt']
    if kind == SCENARIOS[0]:
        audit.require(not interrupts and all(row.get('interruptSerial') == 0
                      and row.get('consumedInterruptSerial') == 0 and row.get('interruptConsumption') is None
                      and row.get('resumeBoundaryApplied') is False and row.get('resumeBoundaryLatched') is False for row in rows),
                      'ordinary pause input unexpectedly invoked/consumed an interruption boundary')
    else:
        audit.require(len(interrupts) == 1 and interrupts[0].get('frame') == PAUSE_FRAME
                      and interrupts[0].get('tickId') == rows[PAUSE_FRAME].get('tickId')
                      and interrupts[0].get('pausedBefore') is False,
                      'missing/duplicate/misphased actual production platform_interrupt invocation')
        consumption = rows[PAUSE_FRAME + 1].get('interruptConsumption')
        interrupt_render = rows[PAUSE_FRAME].get('renderId')
        if not whole_number(interrupt_render, 1):
            interrupt_render = -2
        valid = audit.require(isinstance(consumption, dict)
                              and whole_number(consumption.get('serial'), 1) and consumption['serial'] == 1
                              and consumption.get('renderId') == interrupt_render + 1
                              and consumption.get('tickId') == rows[PAUSE_FRAME].get('tickId')
                              and consumption.get('previousPauseApplied') is True
                              and all(finite(consumption.get(key)) and consumption[key] >= 0 for key in
                                      ('elapsedUs', 'accumulatorBeforeUs', 'accumulatorBoundedUs', 'limitUs')),
                              'interruption serial1 was not consumed at the next actual native Begin')
        if valid:
            bounded = min(TICK_US, consumption['accumulatorBeforeUs'] + min(consumption['elapsedUs'], TICK_US))
            audit.require(abs(consumption['limitUs'] - TICK_US) <= CLOCK_EPSILON_US
                          and abs(consumption['accumulatorBoundedUs'] - bounded) <= CLOCK_EPSILON_US,
                          'consumed interruption debt does not follow the native bounded Begin formula')
            if consumption['renderId'] == rows[61].get('renderId'):
                audit.require(consumption['elapsedUs'] == rows[61].get('outerElapsedUs')
                              and consumption['accumulatorBeforeUs'] == rows[61].get('accumulatorBeforeUs'),
                              'consumption Begin clocks differ from their actual logical End observation')
        for frame, row in enumerate(rows):
            audit.require(row.get('interruptSerial') == (1 if frame >= PAUSE_FRAME else 0)
                          and row.get('consumedInterruptSerial') == (1 if frame > PAUSE_FRAME else 0)
                          and row.get('resumeBoundaryLatched') is (frame == PAUSE_FRAME),
                          f'interruption latch/serial lifetime differs at tick{frame}')
            audit.require((row.get('interruptConsumption') is None if frame <= PAUSE_FRAME
                          else row.get('interruptConsumption') == consumption),
                          f'interruption consumption record changed/repeated at tick{frame}')
            applied = frame == PAUSE_FRAME + 1 and valid and consumption['renderId'] == row.get('renderId')
            audit.require(row.get('resumeBoundaryApplied') is bool(applied),
                          f'Begin interruption consumption phase differs at tick{frame}')
    details = {'canonical': canonical if not audit.count else {}, 'tauSeconds': TAU,
               'observationPhase': 'qa_end_step after timing_end_step, before QA frame increment',
               'boundaryChallengeTime': {str(frame): rows[frame].get('challengeTime') for frame in (59, 60, 61, 179, 180, 181)},
               'pausedWallSecondsObserved': rows[179].get('pausedWallSeconds'),
               'nativeElapsedUs': result.get('elapsedUs'),
               'interruptConsumption': rows[61].get('interruptConsumption')}
    return audit, details


def assess_record(spec, result, summary, bound=None, run=None, native_log=None):
    audit, details = observation_errors(spec, result)
    if not all(isinstance(doc, dict) for doc in (spec, result, summary)):
        audit.require(False, 'native request/runtime/summary must be objects')
    else:
        merge(audit, common_record_errors(spec, result, summary, bound, run, native_log))
    merge(audit, pause_source_errors(bound))
    audit.require(isinstance(bound, dict) and run is not None and isinstance(native_log, str),
                  'acceptance requires rehashed native build/run/log bindings, not a canned fixture or export')
    if audit.count:
        details['canonical'] = {}
    return {**details, 'passed': audit.count == 0, 'errors': audit.errors, 'errorCount': audit.count,
            'fps': spec.get('fps') if isinstance(spec, dict) else None,
            'scenario': (spec.get('timingScenario') or {}).get('kind') if isinstance(spec, dict)
                        and isinstance(spec.get('timingScenario'), dict) else None,
            'sourceIdentity': result.get('sourceIdentity') if isinstance(result, dict) else None,
            'spec': spec, 'scope': SCOPE}


def read_run(run, bound):
    run = Path(run).resolve()
    names = ('spec.json', 'runtime.json', 'summary.json', 'runtime.log')
    try:
        before = {name: file_hash(run / name) for name in names}
        docs = [json.loads((run / name).read_text()) for name in names[:3]]
        record = assess_record(*docs, bound, run, (run / 'runtime.log').read_text(errors='replace'))
        after = {name: file_hash(run / name) for name in names}
        if before != after:
            raise ValueError('Raw evidence changed during read-only assessment')
        record['rawHashes'] = after
    except (OSError, ValueError, TypeError, KeyError, AttributeError) as error:
        record = {'passed': False, 'errors': ['missing/malformed/unbound native evidence: ' + str(error)],
                  'errorCount': 1, 'canonical': {}, 'scope': 'no native pause conclusion'}
    record['run'] = str(run)
    return record


def compare_records(records):
    audit = Audit()
    groups = defaultdict(list)
    audit.require(len(records) >= 2, 'at least two actual native records are required')
    for record in records:
        audit.require(record.get('passed') is True and bool(record.get('rawHashes')) and bool(record.get('run')),
                      'comparison requires strictly assessed actual native files, not a fixture/export')
        audit.require(record.get('scenario') in SCENARIOS, 'missing/wrong comparison scenario')
        groups[record.get('scenario')].append(record)
    baselines = {}
    for kind, peers in groups.items():
        caps = [record.get('fps') for record in peers]
        audit.require(len(caps) == len(set(caps)) and set(caps) == set(CAPS),
                      f'{kind}: comparison requires unique actual cap60/150 records')
        actual60 = [record for record in peers if record.get('fps') == 60]
        if len(actual60) != 1:
            continue
        base = actual60[0]; baselines[kind] = base.get('run')
        for record in peers:
            audit.require(record.get('sourceIdentity') == base.get('sourceIdentity'),
                          f'{kind}: native source/payload/content identity differs across caps')
            fields = ('room', 'fixture', 'mode', 'inputClock', 'simulationHz', 'seed', 'expect',
                      'maxFrames', 'traceEvery', 'inputs', 'timingScenario')
            audit.require(all(record.get('spec', {}).get(key) == base.get('spec', {}).get(key) for key in fields),
                          f'{kind}: submitted logical inputs/scenario differ across caps')
            if base.get('passed') is not True or record.get('passed') is not True:
                continue
            for frame in range(TICKS):
                left, right = base.get('canonical', {}).get(frame), record.get('canonical', {}).get(frame)
                audit.require(isinstance(left, dict) and isinstance(right, dict) and same('logical-state', left, right),
                              f'{kind}: observed logical state differs tick{frame}/cap{record.get("fps")}')
    return {'passed': audit.count == 0, 'errors': audit.errors, 'errorCount': audit.count,
            'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ, 'baselineRuns': baselines,
            'comparison': 'actual End logical states against actual cap60; wall clocks/outer phases excluded',
            'floatTolerance': 'finite continuous fields abs<=1e-6 or rel<=1e-10; ticks/masks/states exact',
            'runs': [{key: value for key, value in record.items() if key not in ('canonical', 'spec')} for record in records],
            'limitations': ['Requested caps do not establish delivered display FPS.',
                            'platform-interrupt-v1 invokes production callback; no actual OS-suspend witness.',
                            'Wall elapsed/pause durations are independently observed, never equalized.',
                            'Stored hsp/vsp need not be zero while paused.', SCOPE]}


def selfcheck():
    """Offline rejection/planner fixtures; never manufacture native acceptance."""
    count = 0

    def schema_fixture(spec, skipped_consumption=False):
        # Structure-only rows for parser negative controls, not a simulated
        # player trajectory or a native witness. assess_record must reject
        # them because no actual payload/save/log/preparation binding exists.
        rows, trace, time = [], [], 0
        interrupted = spec['timingScenario']['kind'] == SCENARIOS[1]
        consumption = {'serial':1, 'renderId':161, 'tickId':91,
                       'elapsedUs':TICK_US / 3 if skipped_consumption else TICK_US,
                       'accumulatorBeforeUs':0,
                       'accumulatorBoundedUs':TICK_US / 3 if skipped_consumption else TICK_US,
                       'limitUs':TICK_US, 'previousPauseApplied':True}
        held, event_index = 0, 0
        for frame in range(TICKS):
            while event_index < len(spec['inputs']) and spec['inputs'][event_index]['frame'] <= frame:
                held = spec['inputs'][event_index]['mask']; event_index += 1
            paused = PAUSE_FRAME <= frame < RESUME_FRAME
            if not paused:
                time += TAU
            player = dict.fromkeys(POSE_FIELDS, 0)
            x = float(frame if frame <= 61 else 61 if paused else frame - 118)
            player.update(frame=frame, actor='o_player', room='r_gameplay_qa', paused=paused,
                          challengeTime=time, x=x, y=0.0, hsp=3.75, vsp=-1.5,
                          bbox=[x, 0.0, x + 32, 32.0], direction=0.0, motionSpeed=0.0)
            render = frame + 100 + (2 if skipped_consumption and frame > PAUSE_FRAME else 0)
            row = dict.fromkeys(BOOL_FIELDS, False)
            row.update(observationPhase='root-end', nativeEventType=3, nativeEventNumber=2,
                       roomGeneration=1, room='r_gameplay_qa', isSimulationTick=True, beginPending=True,
                       livePlayers=1, localPlayers=0, deadPlayers=0, challengeDeaths=0,
                       settingsButton=paused, feedbackButton=paused, restartButton=False,
                       frame=frame, mask=held, tickId=31 + frame, renderId=render,
                       elapsedUs=(frame + 1) * TICK_US, paused=paused, inputApplied=not paused,
                       playerPresent=True, player=player, pauseController=True,
                       pauseScreen=paused, returnButton=paused, challengeTime=time,
                       pausedWallSeconds=max(0, min(frame - PAUSE_FRAME, 119)) * TAU,
                       outerElapsedUs=TICK_US, accumulatorUs=0.0, accumulatorBeforeUs=0.0,
                       previousPauseApplied=PAUSE_FRAME < frame <= RESUME_FRAME,
                       pauseClockAfterEnd=paused, interruptSerial=int(interrupted and frame >= PAUSE_FRAME),
                       consumedInterruptSerial=int(interrupted and frame > PAUSE_FRAME),
                       resumeBoundaryLatched=interrupted and frame == PAUSE_FRAME,
                       resumeBoundaryApplied=interrupted and frame == PAUSE_FRAME + 1 and not skipped_consumption,
                       interruptConsumption=copy.deepcopy(consumption) if interrupted and frame > PAUSE_FRAME else None)
            rows.append(row); trace.append(dict(player, observationPhase='root-end'))
        events = [{'kind':'production-platform-interrupt', 'frame':60, 'tickId':91, 'pausedBefore':False}] if interrupted else []
        return {'format':'tcc.gameplay-evidence', 'schemaVersion':1,
                'traceSchemaVersion':2, 'traceBoundaries':'native-end-or-terminal-contact',
                'inputMaskVersion':2, 'initial':{'frame':0,'paused':False,'challengeTime':0},
                'timingScenario':copy.deepcopy(spec['timingScenario']), 'pauseObservations':rows,
                'trace':trace, 'final':trace[-1], 'events':events, 'elapsedUs':TICKS * TICK_US + 1,
                'endingContext':{'room':'r_gameplay_qa','challengeTime':time}}

    for kind in SCENARIOS:
        left, right = (specification(kind, cap) for cap in CAPS)
        assert request_errors(left).count == request_errors(right).count == 0
        assert left['inputs'] == right['inputs'] and left['maxFrames'] == TICKS
        assert left['pauseCandidate']['verified'] is False
        for mutate in (lambda spec: spec.pop('inputClock'), lambda spec: spec.pop('simulationHz'),
                       lambda spec: spec.pop('timingScenario'), lambda spec: spec.update(mode='record'),
                       lambda spec: spec.update(maxFrames=239), lambda spec: spec.update(fps=75),
                       lambda spec: spec.update(timingProbe={}), lambda spec: spec.update(fpsOverrides={}),
                       lambda spec: spec['inputs'][2].update(mask=64),
                       lambda spec: spec['inputs'][2].update(mask=True),
                       lambda spec: spec['inputs'][2].update(frame=60.5),
                       lambda spec: spec['timingScenario'].update(kind='historical-export'),
                       lambda spec: spec['pauseCandidate'].update(verified=True)):
            bad = copy.deepcopy(left); mutate(bad)
            assert request_errors(bad).count > 0
            count += 1
        for runtime in ({}, {'inputMaskVersion':1}, {'inputMaskVersion':2,'timingScenario':left['timingScenario'],
                                                    'pauseObservations':[],'trace':[]}):
            assert observation_errors(left, runtime)[0].count > 0
            count += 1
        assert assess_record(left, {}, {}).get('passed') is False
        count += 1
        for skipped in (False, True):
            layout = schema_fixture(left, skipped)
            assert observation_errors(left, layout)[0].count == 0
            assert assess_record(left, layout, {}).get('passed') is False
            bad_preparation = {**layout, 'diagnosticPreparation':{'complete':False}}
            shared = record_errors(left, bad_preparation, {})
            reused = common_record_errors(left, bad_preparation, {}, None, None, None)
            assert (shared.errors, shared.count) == (reused.errors, reused.count)
            mutations = [lambda data:data.pop('inputMaskVersion'), lambda data:data.pop('initial'),
                         lambda data:data.pop('timingScenario'), lambda data:data['pauseObservations'].pop(),
                         lambda data:data.pop('final'), lambda data:data.pop('format'),
                         lambda data:data['endingContext'].update(challengeTime=999),
                         lambda data:data.update(diagnosticPreparation={'complete':False}),
                         lambda data:data['pauseObservations'][61].pop('outerElapsedUs'),
                         lambda data:data['pauseObservations'][0].update(mask=False),
                         lambda data:data['pauseObservations'][61].update(challengeTime=999),
                         lambda data:data['pauseObservations'][181].update(pauseScreen=True),
                         lambda data:data['pauseObservations'][70]['player'].update(hsp=0),
                         lambda data:data['trace'][70].update(x=1),
                         lambda data:data['pauseObservations'][70].update(accumulatorUs=1),
                         lambda data:data['pauseObservations'][70].update(previousPauseApplied=False)]
            if kind == SCENARIOS[1]:
                mutations += [lambda data:data['events'].clear(),
                              lambda data:data['pauseObservations'][61]['interruptConsumption'].update(serial=True),
                              lambda data:data['pauseObservations'][60].update(consumedInterruptSerial=1),
                              lambda data:data['pauseObservations'][60].update(resumeBoundaryLatched=False),
                              lambda data:data['pauseObservations'][61]['interruptConsumption'].update(renderId=162),
                              lambda data:data['pauseObservations'][61]['interruptConsumption'].update(tickId=92),
                              lambda data:data['pauseObservations'][61]['interruptConsumption'].update(accumulatorBoundedUs=TICK_US + 1)]
            else:
                mutations += [lambda data:data['pauseObservations'][70].update(interruptSerial=1)]
            for mutate in mutations:
                bad = copy.deepcopy(layout); mutate(bad)
                assert observation_errors(left, bad)[0].count > 0
                count += 1
    # Do not create a fabricated full native PASS. These canonical fragments
    # exercise exact discrete comparisons and rejection of a forged export.
    assert same('hsp', 3.0, 3.0 + 1e-8) and not same('mask', 32, 32.00000001)
    assert not same('logical-state', {'paused': True}, {'paused': 1})
    assert compare_records([])['passed'] is False
    assert compare_records([{'passed':True,'fps':60,'scenario':SCENARIOS[0]},
                            {'passed':True,'fps':150,'scenario':SCENARIOS[0]}])['passed'] is False
    return {'status':'offline planner/rejection checks only', 'rejectionFixtures':count + 2,
            'schemaFixturesNeverAcceptedAsNative':4,
            'nativeLaunches':0, 'nativeAcceptanceEstablished':False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    generate = sub.add_parser('generate', help='Write new unverified requests; never run a native app')
    generate.add_argument('--output', type=Path, required=True)
    generate.add_argument('--fps', type=int, nargs='+', choices=CAPS, default=CAPS)
    generate.add_argument('--scenario', nargs='+', choices=SCENARIOS, default=SCENARIOS)
    sub.add_parser('selfcheck', help='Offline malformed/legacy/export rejection fixtures only')
    for name in ('verify', 'compare'):
        command = sub.add_parser(name)
        command.add_argument('--build', type=Path, required=True)
        command.add_argument('runs', type=Path, nargs='+')
        command.add_argument('--output', type=Path)
    args = parser.parse_args()
    if args.command == 'selfcheck':
        print(json.dumps(selfcheck(), indent=2)); return 0
    if args.command == 'generate':
        output = args.output.resolve()
        if output == ROOT or ROOT in output.parents:
            raise ValueError('Keep generated requests outside the checkout')
        if len(set(args.fps)) != len(args.fps) or len(set(args.scenario)) != len(args.scenario):
            raise ValueError('Duplicate requested cap/scenario')
        requests = [specification(kind, fps) for kind in args.scenario for fps in args.fps]
        output.mkdir(parents=True, exist_ok=False)
        for request in requests:
            path = output / f'{request["timingScenario"]["kind"]}-{request["fps"]}.json'
            with path.open('x') as file:
                file.write(json.dumps(request, indent=2) + '\n')
        print(json.dumps({'status':'NEW UNVERIFIED requests only', 'count':len(requests),
                          'nativeLaunches':0, 'inputClock':INPUT_CLOCK, 'simulationHz':SIMULATION_HZ,
                          'maxFrames':TICKS, 'output':str(output)}, indent=2)); return 0
    try:
        bound = binding(args.build)
        records = [read_run(run, bound) for run in args.runs]
        report = compare_records(records) if args.command == 'compare' else {
            'passed':all(record['passed'] for record in records), 'binding':bound, 'crossCapAcceptance':False,
            'runs':[{key:value for key,value in record.items() if key not in ('canonical','spec')} for record in records]}
    except (OSError, ValueError, TypeError, KeyError, RuntimeError) as error:
        report = {'passed':False, 'errors':['native build binding unavailable/invalid: ' + str(error)]}
    if args.output:
        output = args.output.resolve()
        if output == ROOT or ROOT in output.parents:
            raise ValueError('Keep native assessment reports outside the checkout')
        output.parent.mkdir(parents=True, exist_ok=True)
        with output.open('x') as file:
            file.write(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
