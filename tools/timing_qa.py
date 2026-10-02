#!/usr/bin/env python3
"""Offline requests and strict assessment of native-fixed-tick-v2 observations.

This tool never launches a runner. ``generate`` writes unverified requests;
``verify`` audits recorded native files; ``compare`` additionally requires one
actual render-cap60 comparator. Source snapshots and native payloads are read
and hashed without changing historical evidence.
"""
import argparse
from collections import Counter, defaultdict
import json
import math
from pathlib import Path
import re

from gameplay_qa import (INPUT_CLOCK, SIMULATION_HZ, RENDER_COMPARISON_FPS,
                         proof_clock_errors, validate_input_events, whole_number)
from native_evidence import file_hash
from tcc_project import ROOT, artifact_identity, level_content_identity, source_identity, verify_frozen_source_identity

FIXTURE = 'native-fixed-tick-v2'
PREPARATION_KIND = 'native-timing-probe-only'
WARMUP_TICKS = 30
PHASES = ('root-before-final-begin-flush', 'root-begin-after-flush',
          'root-step-after-flush', 'root-after-native')
INITIAL_ROLES = ('signed-negative', 'zero-direction', 'diagonal', 'positive-alarm',
                 'animation-fps-origin', 'animation-frame-origin', 'native-path',
                 'partner-moving', 'partner-overlap', 'collision-moving',
                 'collision-overlap', 'native-no-step')
LATE_ROLES = ('late-created', 'late-zero-overrides', 'late-direction-override')
ROLES = INITIAL_ROLES + LATE_ROLES
NO_STEP_ROLES = {'partner-moving', 'partner-overlap', 'native-no-step'}
EVENTS = {'step', 'alarm-0', 'animation-end', 'collision-probe', 'collision-partner'}
COUNTERS = ('stepEvents', 'alarmEvents', 'collisionEvents', 'animationEndEvents',
            'rawAlarmEntries', 'rawAnimationEndEntries')
INACTIVE_FIELDS = ('x', 'y', 'speed', 'direction', 'gravity', 'friction',
                   'imageIndex', 'imageSpeed', 'alarm0', 'pathPosition', 'pathSpeed',
                   'stepEvents', 'alarmEvents', 'animationEndEvents',
                   'rawAlarmEntries', 'rawAnimationEndEntries')
ACTIVE_FIELDS = INACTIVE_FIELDS + ('xprevious', 'yprevious', 'hspeed', 'vspeed',
                                  'gravityDirection', 'imageXscale', 'imageYscale',
                                  'imageAngle', 'spriteFrames', 'spriteSpeed',
                                  'spriteSpeedType', 'collisionEvents')
POSE_FIELDS = ('x', 'y', 'pathPosition', 'imageIndex')
FLOAT_FIELDS = {'x', 'y', 'xprevious', 'yprevious', 'hspeed', 'vspeed', 'speed',
                'direction', 'gravity', 'gravityDirection', 'friction',
                'imageIndex', 'imageSpeed', 'pathPosition', 'pathSpeed',
                'imageXscale', 'imageYscale', 'imageAngle', 'spriteSpeed'}
FLOAT_ABS = 1e-6
FLOAT_REL = 1e-10
TOLERANCE = ('Only observed finite continuous native fields use abs<=1e-6 or '
             'rel<=1e-10 (math.isclose). This is far below one pixel and does '
             'not round ticks, counters, alarms, angles, signs, masks or phases.')


class Audit:
    def __init__(self):
        self.errors = []
        self.count = 0

    def require(self, condition, message):
        if not condition:
            self.count += 1
            if len(self.errors) < 200 and message not in self.errors:
                self.errors.append(message)
        return bool(condition)


def finite(value):
    return type(value) in (int, float) and math.isfinite(value)


def reference(value, kind):
    """GameMaker VM emits typed @ref strings; numeric references also exist."""
    if whole_number(value, -1):
        return value
    if isinstance(value, str):
        match = re.fullmatch(r'@ref ' + re.escape(kind) + r'\(([A-Za-z_][A-Za-z0-9_]*|-?\d+)\)', value)
        if match:
            return int(match[1]) if re.fullmatch(r'-?\d+', match[1]) else match[1]
    return None


def actor_reference(value):
    parsed = reference(value, 'instance')
    return parsed if whole_number(parsed, 1) else None


def same(field, left, right):
    if field in FLOAT_FIELDS and finite(left) and finite(right):
        return math.isclose(left, right, rel_tol=FLOAT_REL, abs_tol=FLOAT_ABS)
    return type(left) is type(right) and left == right or (
        type(left) in (int, float) and type(right) in (int, float) and left == right)


def specification(fps, ticks=72):
    if type(fps) is not int or not 30 <= fps <= 1000:
        raise ValueError('Rendering cap must be a whole number from 30 to 1000')
    if type(ticks) is not int or not 60 <= ticks <= 240:
        raise ValueError('Probe ticks must be a whole number from 60 to 240')
    return {'room': 'r_gameplay_qa', 'fixture': 'default', 'mode': 'replay',
            'fps': fps, 'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ,
            'seed': 1, 'expect': 'frames', 'maxFrames': ticks + 8, 'traceEvery': 1,
            'inputs': [{'frame': 30, 'mask': 6}, {'frame': 31, 'mask': 2},
                       {'frame': 65, 'mask': 0}],
            'timingProbe': {'ticks': ticks, 'maxOuterFrames': 6000, 'maxSamples': 100000}}


def load(path):
    return json.loads(Path(path).read_text())


def binding(build, *, legacy_version=None):
    """Rehash the immutable snapshot and compiled native payload, never launch."""
    build = Path(build).resolve()
    evidence = load(build / 'evidence.json')
    if evidence.get('configuration') != 'QA':
        raise ValueError('Timing evidence requires an isolated QA build')
    snapshot = Path(evidence.get('source_snapshot', '')).resolve()
    if not evidence.get('source_snapshot') or not snapshot.is_dir():
        raise ValueError('Build source snapshot is missing')
    coverage = verify_frozen_source_identity(snapshot, evidence.get('source_identity'),
                                            legacy_version=legacy_version)
    observed_source = coverage['identity']
    no_step = load_yy(snapshot / 'objects/o_timing_qa_nostep/o_timing_qa_nostep.yy')
    if no_step.get('parentObjectId') is not None or any(event.get('eventType') == 3 for event in no_step.get('eventList', [])):
        raise ValueError('Compiled no-Step diagnostic actor has a native/inherited Step event')
    for relative, entry in [('Alarm_0.gml', 'native-no-step-alarm-entry'),
                            ('Other_7.gml', 'native-no-step-animation-end-entry')]:
        body = (snapshot / 'objects/o_timing_qa_nostep' / relative).read_text()
        if entry not in body or body.index(entry) > body.find('if (!timing_is_tick())'):
            raise ValueError('Native no-Step callback observation is missing or follows its body guard')
    diagnostic_sources = list((snapshot / 'scripts/scr_timing_qa').glob('*.gml'))
    diagnostic_sources += list((snapshot / 'objects').glob('o_timing_qa_*/*.gml'))
    if not diagnostic_sources or any(re.search(r'\b(?:event_perform|event_user)\s*\(', path.read_text()) for path in diagnostic_sources):
        raise ValueError('Timing diagnostics are missing or manually dispatch native events')
    app = build / 'DerivedData/Build/Products/Release/The_Colorful_Creature.app'
    executable = app / 'Contents/MacOS/The_Colorful_Creature'
    executable_hash = file_hash(executable)
    if executable_hash != evidence.get('executable_sha256'):
        raise ValueError('Native executable hash differs from build evidence')
    payload = artifact_identity(app)
    if payload != evidence.get('artifact_identity'):
        raise ValueError('Native payload hash/file count differs from build evidence')
    return {'build': str(build), 'snapshot': str(snapshot), 'source': observed_source,
            'executableSha256': executable_hash, 'artifact': payload,
            'compilerBackend': evidence.get('compiler_backend'), 'sourceCoverage': coverage}


def load_yy(path):
    return json.loads(re.sub(r',\s*([}\]])', r'\1', Path(path).read_text()))


def preparation_errors(result):
    """Bind diagnostic setup before recorded input, without a wall-rate claim.

    These fields come from the real RoomStart preparation and complete logical
    Begin setup. Native position/event evidence still needs its separate audit.
    Missing historical fields never implicitly become a completed warmup.
    """
    audit = Audit()
    prep = result.get('diagnosticPreparation')
    if not audit.require(isinstance(prep, dict), 'missing native timing preparation metadata'):
        return audit
    audit.require(prep.get('kind') == PREPARATION_KIND and prep.get('complete') is True,
                  'native timing preparation is incomplete or not diagnostic-only')
    tick_fields = ('warmupTicks', 'roomStartTick', 'readyAfterTick', 'scenarioStartTick',
                   'recordedFramesBeforeSetup')
    ticks_valid = audit.require(all(whole_number(prep.get(field)) for field in tick_fields),
                                'malformed native preparation simulation ticks/counts')
    if ticks_valid:
        audit.require(prep['warmupTicks'] == WARMUP_TICKS
                      and prep['readyAfterTick'] == prep['roomStartTick'] + WARMUP_TICKS
                      and prep['scenarioStartTick'] >= prep['readyAfterTick'],
                      'native preparation did not finish the declared 30 logical warmup ticks')
        audit.require(prep['recordedFramesBeforeSetup'] == 0,
                      'player input was recorded before diagnostic setup completed')
    time_fields = ('startedUs', 'setupElapsedUs', 'warmupElapsedUs', 'accumulatorResetUs')
    times_valid = audit.require(all(whole_number(prep.get(field)) for field in time_fields),
                                'missing/nonfinite/negative native preparation microseconds')
    if times_valid:
        audit.require(prep['warmupElapsedUs'] > 0
                      and prep['accumulatorResetUs'] - prep['startedUs']
                      == prep['warmupElapsedUs'] + prep['setupElapsedUs'],
                      'native preparation timestamps are unordered or do not bind setup/reset')
    initial_frame = (result.get('initial') or {}).get('frame')
    audit.require(whole_number(initial_frame) and initial_frame == 0,
                  'native initial player does not begin at recorded simulation frame0')
    probe = result.get('timingProbe')
    if not audit.require(isinstance(probe, dict), 'preparation has no actual native probe binding'):
        return audit
    audit.require(ticks_valid and probe.get('startTick') == prep.get('scenarioStartTick'),
                  'native probe start tick differs from completed preparation scenario')
    samples = probe.get('samples')
    if not audit.require(isinstance(samples, list), 'preparation has no native setup/Begin observations'):
        return audit
    creations = [sample for sample in samples if isinstance(sample, dict)
                 and sample.get('phase') == 'create-native' and sample.get('outerSequence') == 0]
    begins = [sample for sample in samples if isinstance(sample, dict)
              and sample.get('phase') == 'root-begin-after-flush' and sample.get('outerSequence') == 1]
    for name, observations in (('initial native creation', creations), ('first complete logical Begin', begins)):
        audit.require(bool(observations) and all(sample.get('isTick') is True
                      and sample.get('tickId') == prep.get('scenarioStartTick')
                      and sample.get('relativeTick') == 0
                      and sample.get('renderId') == probe.get('startRender') for sample in observations),
                      name + ' is not bound to the actual preparation scenario boundary')
    if times_valid:
        audit.require(all(finite(sample.get('elapsedUs'))
                          and 0 <= sample['elapsedUs'] <= prep['setupElapsedUs'] for sample in creations),
                      'native initial creation observations fall outside declared setup duration')
    return audit


def record_errors(spec, result, summary, bound=None, run=None, native_log=None):
    audit = Audit()
    preparation = preparation_errors(result)
    for error in preparation.errors:
        audit.require(False, error)
    audit.count += max(0, preparation.count - len(preparation.errors))
    for error in proof_clock_errors(spec, result, summary):
        audit.require(False, error)
    audit.require(summary.get('normalRuntimeEnd') is True and summary.get('timedOut') is False,
                  'missing normal native engine end or timed-out launch')
    audit.require(summary.get('compiledPayloadVerified') is True, 'missing compiled-payload verification')
    if native_log is not None:
        audit.require('###game_end###0' in native_log, 'native log lacks normal engine end marker')
    audit.require(result.get('status') == 'observed' and result.get('deaths') == 0,
                  'default calibration did not end observed without a death')
    audit.require(result.get('normalRules') is True and result.get('diagnosticOnly') is True,
                  'missing normal-rules diagnostic-only markers')
    audit.require(result.get('muted') is True and summary.get('muted') is True,
                  'diagnostic mute is not bound in native result and summary')
    audit.require(spec.get('room') == 'r_gameplay_qa' and spec.get('fixture') == 'default'
                  and spec.get('mode') == 'replay' and spec.get('expect') == 'frames',
                  'request must use a real default calibration player/input replay')
    audit.require(result.get('inputMode') == 'replay' and result.get('inputs') == spec.get('inputs')
                  and result.get('fps') == spec.get('fps') and result.get('seed') == spec.get('seed'),
                  'submitted replay/render cap/seed bindings differ')
    audit.require(type(spec.get('fps')) is int and 30 <= spec['fps'] <= 1000,
                  'invalid requested rendering cap')
    audit.require(result.get('frames') == spec.get('maxFrames') and spec.get('traceEvery') == 1,
                  'player tick budget was not completed or every-tick trace not requested')
    for field, count_field in (('renderFrameDeltasUs', 'renderFrames'),
                               ('simulationFrameDeltasUs', 'simulationFrames')):
        deltas = result.get(field)
        audit.require(isinstance(deltas, list) and whole_number(result.get(count_field))
                      and len(deltas) == result[count_field]
                      and all(finite(value) and value >= 0 for value in deltas),
                      'missing/truncated separate native clock deltas: ' + field)
    audit.require(result.get('frameDeltasUs') == result.get('simulationFrameDeltasUs')
                  and isinstance(result.get('frameDeltasUs'), list),
                  'legacy frame deltas are not bound to the simulation clock')
    audit.require((result.get('initial') or {}).get('room') == 'r_gameplay_qa',
                  'native initial player is outside the diagnostic room')
    trace = result.get('trace')
    audit.require(isinstance(trace, list) and whole_number(spec.get('maxFrames'), 1)
                  and len(trace) == spec['maxFrames']
                  and all(isinstance(sample, dict) and sample.get('frame') == index
                          and sample.get('room') == 'r_gameplay_qa' and sample.get('actor') == 'o_player'
                          and all(finite(sample.get(field)) for field in ('x', 'y', 'hsp', 'vsp'))
                          and isinstance(sample.get('bbox'), list) and len(sample['bbox']) == 4
                          and all(finite(value) for value in sample['bbox'])
                          for index, sample in enumerate(trace)),
                  'default native player trace is missing/truncated or not bound to every logical input tick')
    try:
        validate_input_events(spec.get('inputs'))
    except (ValueError, TypeError) as error:
        audit.require(False, 'invalid submitted input events: ' + str(error))
    audit.require(result.get('sourceIdentity') == spec.get('identity') and isinstance(spec.get('identity'), dict),
                  'request/native source identity differs or is absent')
    audit.require(summary.get('requestedRenderFps') == spec.get('fps')
                  and summary.get('requestedInputClock') == INPUT_CLOCK
                  and summary.get('requestedSimulationHz') == SIMULATION_HZ,
                  'launcher requested clock/render cap binding differs')
    if run is not None:
        audit.require(result.get('isolatedSaveRoot') == spec.get('saveRoot') == str(Path(run).resolve() / 'saves'),
                      'request/native saves are not isolated in this run')
        audit.require(spec.get('output') == str(Path(run).resolve() / 'runtime.json'), 'native output path differs')
    if bound is not None:
        content = level_content_identity(spec, Path(bound['snapshot']))
        expected = {**bound['source'], 'executableSha256': bound['executableSha256'],
                    'artifactSha256': bound['artifact']['sha256'], 'levelContentSha256': content}
        audit.require(spec.get('identity') == expected, 'request identity differs from freshly hashed build/content')
        audit.require(summary.get('sourceIdentity') == bound['source']
                      and summary.get('executableSha256') == bound['executableSha256']
                      and summary.get('levelContentSha256') == content,
                      'launcher source/executable/content hashes differ from frozen build')
    return audit


def assess_probe(probe, request_probe):
    """Assess actual phases. A valid structural run is not cross-cap acceptance."""
    audit = Audit()
    if not audit.require(isinstance(probe, dict), 'missing native timing probe'):
        return audit, {}
    audit.require(probe.get('schemaVersion') == 2 and probe.get('fixture') == FIXTURE
                  and probe.get('verdict') == 'unassessed', 'missing native-v2/unassessed observer schema')
    audit.require(isinstance(request_probe, dict) and probe.get('spec') == request_probe,
                  'request/native timing-probe spec differs')
    target = request_probe.get('ticks') if isinstance(request_probe, dict) else None
    audit.require(whole_number(target, 60) and target <= 240 and probe.get('targetTicks') == target,
                  'invalid/mismatching logical target ticks')
    if not whole_number(target, 60):
        return audit, {}
    target = int(target)
    start = probe.get('startTick')
    audit.require(whole_number(start), 'probe start tick is absent/malformed')
    if not whole_number(start):
        return audit, {}
    audit.require(probe.get('observationWindowComplete') is True
                  and whole_number(probe.get('observedThroughTick'))
                  and probe['observedThroughTick'] >= start + target, 'incomplete native observation window')
    for field in ('samplesTruncated', 'eventsTruncated', 'outerLimitReached', 'lateCreationPending',
                  'noStepDestroyed', 'cleanupPending'):
        audit.require(probe.get(field) is False, 'probe did not explicitly clear ' + field)
    for field in ('duplicateBeginHooks', 'duplicateEndHooks', 'endHooksWithoutBegin',
                  'duplicatePostFlushHooks', 'droppedSamples', 'droppedEvents'):
        audit.require(whole_number(probe.get(field)) and probe[field] == 0, 'probe reports/misses ' + field)
    audit.require(probe.get('inactiveReadFailures') == [], 'inactive native reads failed or were not reported')
    audit.require(probe.get('eventBodiesOnSkippedFrames') == [], 'event bodies executed off tick or were not reported')
    audit.require(probe.get('gameplayHz') == SIMULATION_HZ, 'native gameplay Hz is not fixed60')
    # instance_exists() serializes its native real 1, unlike the explicit
    # boolean active/present fields in individual observed state records.
    audit.require(probe.get('noStepLifecycleStage') == 2 and
                  (probe.get('noStepPresent') is True or whole_number(probe.get('noStepPresent'), 1)
                   and probe['noStepPresent'] == 1),
                  'native no-Step actor did not survive complete lifecycle')
    arrays = {}
    for key in ('samples', 'events', 'nativeCallbackEntries', 'lifecycleActions', 'animations', 'actors'):
        value = probe.get(key)
        audit.require(isinstance(value, list), 'probe array missing: ' + key)
        arrays[key] = value if isinstance(value, list) else []
    samples, events = arrays['samples'], arrays['events']
    ids, births = {}, {}
    for sample in samples:
        if not isinstance(sample, dict) or not isinstance(sample.get('state'), dict):
            audit.require(False, 'malformed sample/state'); continue
        state = sample['state']; role = state.get('role'); actor_id = state.get('instanceId')
        if role in ROLES and actor_reference(actor_id) is not None:
            audit.require(actor_id not in ids or ids[actor_id] == role, 'native ID reused by different probe roles')
            ids[actor_id] = role
            if sample.get('phase') == 'create-native':
                audit.require(role not in births, 'duplicate native creation: ' + role)
                births[role] = sample
    audit.require(set(births) == set(ROLES), 'missing/extra native role creations')
    role_ids = Counter(ids.values())
    audit.require(all(role_ids[role] == 1 for role in ROLES), 'role has missing/multiple native instance IDs')

    def role_of(record):
        state = record.get('state', {})
        role = state.get('role') or ids.get(state.get('instanceId'))
        audit.require(role in ROLES and ids.get(state.get('instanceId')) == role, 'unbound native actor role/ID')
        return role

    def stamp(record):
        audit.require(all(whole_number(record.get(field)) for field in ('outerSequence', 'renderId', 'tickId', 'relativeTick'))
                      and type(record.get('isTick')) is bool and record.get('tickId') == start + record.get('relativeTick', -1),
                      'malformed native phase stamp')
        audit.require(finite(record.get('elapsedUs')) and record['elapsedUs'] >= 0, 'missing native elapsed observation')
        audit.require(whole_number(record.get('generatedDrawFrames')) and type(record.get('drawScheduled')) is bool
                      and whole_number(record.get('nativeOuterHz'), SIMULATION_HZ),
                      'missing/malformed separate native render/outer clock observation')
        audit.require(type(record.get('centralBeginPending')) is bool and type(record.get('rootEndAlreadyObserved')) is bool,
                      'native tail/central phase ownership is missing; no implicit legacy normalization')

    def state_check(record):
        state = record['state']; role = role_of(record)
        active = state.get('active')
        audit.require(type(active) is bool and state.get('present') is active, 'ambiguous native presence/active state')
        if active is False:
            audit.require(role == 'native-no-step' and state.get('inactiveReadSucceeded') is True,
                          'absent actor/inactive read is not explicitly observed')
        fields = ACTIVE_FIELDS if active else INACTIVE_FIELDS
        audit.require(all(finite(state.get(field)) for field in fields), 'incomplete finite native actor state: ' + str(role))
        for field in COUNTERS if active else tuple(field for field in COUNTERS if field != 'collisionEvents'):
            audit.require(whole_number(state.get(field)), 'malformed native counter: ' + str(role) + '/' + field)
        audit.require(whole_number(state.get('alarm0'), -1), 'malformed native alarm count')
        for field in ('sprite', 'mask', 'path') if active else ('path',):
            kind = 'path' if field == 'path' else 'sprite'
            audit.require(reference(state.get(field), kind) is not None, 'missing native resource reference: ' + str(role) + '/' + field)
        return role

    groups = defaultdict(lambda: defaultdict(dict)); created_final = {}
    for sample in samples:
        if not isinstance(sample, dict) or not isinstance(sample.get('state'), dict):
            continue
        stamp(sample); role = state_check(sample); phase = sample.get('phase'); outer = sample.get('outerSequence')
        if phase in PHASES:
            audit.require(sample.get('centralBeginPending') is False
                          and sample.get('rootEndAlreadyObserved') is (phase == 'root-after-native'),
                          'authoritative phase has wrong native tail/central ownership: ' + phase)
        if phase in PHASES and whole_number(outer) and role in ROLES:
            audit.require(role not in groups[outer][phase], f'duplicate {phase}/{outer}/{role}')
            groups[outer][phase][role] = sample
        if phase in ('caller-final-zero-overrides', 'caller-final-direction-override'):
            audit.require(role not in created_final, 'duplicate caller-final observation: ' + str(role))
            created_final[role] = sample
    outer_count = probe.get('outerFramesObserved')
    audit.require(whole_number(outer_count, 1) and set(groups) == set(range(1, int(outer_count) + 1)),
                  'native outer-frame phase coverage is incomplete')
    logical_rows, previous, previous_samples, skipped, logical = {}, {}, {}, 0, 0
    prior_stamp = None
    for outer in sorted(groups):
        phases = groups[outer]
        expected_roles = {role for role, birth in births.items() if birth.get('outerSequence', 0) <= outer}
        for phase in PHASES:
            audit.require(set(phases.get(phase, {})) == expected_roles, f'incomplete {phase}/{outer} actor coverage')
        after = phases.get('root-after-native', {})
        frame_sample = next(iter(after.values()), None)
        if not frame_sample:
            continue
        is_tick, tick = frame_sample.get('isTick'), frame_sample.get('relativeTick')
        if prior_stamp:
            audit.require(frame_sample.get('renderId') == prior_stamp.get('renderId', -2) + 1,
                          'native outer render IDs are missing/duplicate/out of order')
            audit.require(tick == prior_stamp.get('relativeTick', -2) + (1 if is_tick else 0),
                          'logical/skipped native tick sequence differs')
            audit.require(frame_sample.get('generatedDrawFrames', -1) >= prior_stamp.get('generatedDrawFrames', 0)
                          and frame_sample.get('elapsedUs', -1) >= prior_stamp.get('elapsedUs', 0),
                          'native render/time observations go backwards')
        prior_stamp = frame_sample
        audit.require(all(sample.get('isTick') is is_tick and sample.get('relativeTick') == tick
                          and sample.get('renderId') == frame_sample.get('renderId')
                          for rows in phases.values() for sample in rows.values()), f'inconsistent outer-frame stamps: {outer}')
        anchors, image_anchors = {}, {}
        for role in after:
            anchor = previous.get(role)
            if anchor is None:
                birth = created_final.get(role) or births.get(role)
                audit.require(birth is not None and (birth.get('outerSequence') == outer
                              or outer == 1 and role in INITIAL_ROLES and birth.get('outerSequence') == 0),
                              'outer has no explicit creation/prior native anchor: ' + role)
                anchor = birth['state'] if birth else {}
            anchors[role] = anchor
            image_anchor = anchor.get('imageIndex')
            prior_sample = previous_samples.get(role)
            if prior_sample and prior_sample.get('isTick') and anchor.get('active'):
                # GameMaker advances native animation between root End
                # and the next central Begin. Explicit tail ownership
                # attributes one advance to that prior logical frame.
                # No tail advance is allowed after a prior skipped End.
                frames = anchor.get('spriteFrames')
                rate, multiplier = anchor.get('spriteSpeed'), anchor.get('imageSpeed')
                audit.require(finite(image_anchor) and finite(rate) and finite(multiplier)
                              and whole_number(frames, 1), f'unobservable logical animation tail {outer}/{role}')
                if finite(image_anchor) and finite(rate) and finite(multiplier) and whole_number(frames, 1):
                    advanced = image_anchor + rate * multiplier
                    wrapped = advanced < 0 or advanced >= frames
                    image_anchor = advanced % frames
                    if wrapped:
                        audit.require(any(event.get('phase') == 'animation-end'
                                          and event.get('outerSequence') == prior_sample.get('outerSequence')
                                          and (event.get('state') or {}).get('role') == role
                                          and event.get('centralBeginPending') is True
                                          and event.get('rootEndAlreadyObserved') is True
                                          for event in events), f'missing owned native animation tail wrap {outer}/{role}')
            image_anchors[role] = image_anchor
            # The native animation tail precedes the next central Begin even
            # when that next outer is logical. Checking both Begin observations
            # catches leakage after an isolated skip as well as adjacent skips.
            for phase in PHASES[:2]:
                sample = phases.get(phase, {}).get(role)
                if sample:
                    audit.require(same('imageIndex', sample['state'].get('imageIndex'), image_anchor),
                                  f'native animation tail differs {outer}/{role}/{phase}')
        if is_tick:
            logical += 1
            audit.require(tick not in logical_rows, 'duplicate logical after-native tick')
            logical_rows[tick] = {role: sample['state'] for role, sample in after.items()}
        else:
            skipped += 1
            for role, final_sample in after.items():
                final = final_sample['state']; begin_sample = phases.get('root-begin-after-flush', {}).get(role)
                step_sample = phases.get('root-step-after-flush', {}).get(role)
                if not begin_sample or not step_sample:
                    continue
                anchor, image_anchor = anchors[role], image_anchors[role]
                prior_sample = previous_samples.get(role)
                for phase, rows in phases.items():
                    sample = rows.get(role)
                    if sample:
                        for field in POSE_FIELDS:
                            expected = image_anchor if field == 'imageIndex' else anchor.get(field)
                            audit.require(same(field, sample['state'].get(field), expected),
                                          f'skipped outer {outer}/{role}/{phase} leaks {field}')
                for field in ('stepEvents', 'alarmEvents'):
                    audit.require(final.get(field) == anchor.get(field), f'skipped outer {outer}/{role} advances {field}')
                owned_wraps = sum(event.get('phase') == 'animation-end'
                                  and prior_sample is not None
                                  and event.get('outerSequence') == prior_sample.get('outerSequence')
                                  and (event.get('state') or {}).get('role') == role
                                  and event.get('centralBeginPending') is True
                                  and event.get('rootEndAlreadyObserved') is True for event in events)
                audit.require(final.get('animationEndEvents') == anchor.get('animationEndEvents', 0) + owned_wraps,
                              f'skipped outer {outer}/{role} advances unowned animation body counter')
                old_alarm = anchor.get('alarm0'); begin = begin_sample['state']; step = step_sample['state']
                if finite(old_alarm):
                    if old_alarm > 0:
                        # A Begin-active actor is compensated before the native
                        # Alarm phase, then decremented back. A newly activated
                        # actor first visible after that boundary is not exempt:
                        # its retained positive alarm must still remain intact.
                        expected_begin = old_alarm + 1 if begin.get('active') else old_alarm
                        audit.require(begin.get('alarm0') == expected_begin,
                                      f'skip Begin compensation differs {outer}/{role}')
                        audit.require(step.get('alarm0') == old_alarm and final.get('alarm0') == old_alarm,
                                      f'skipped positive alarm leaks {outer}/{role}')
                    else:
                        allowed = {old_alarm, -1} if old_alarm == 0 else {old_alarm}
                        audit.require(begin.get('alarm0') == old_alarm and step.get('alarm0') in allowed
                                      and final.get('alarm0') in allowed, f'zero/inactive alarm promoted on skip {outer}/{role}')
                for sample in (begin_sample, step_sample, final_sample):
                    if sample['state'].get('active'):
                        for field in ('speed', 'gravity', 'friction', 'pathSpeed', 'imageSpeed'):
                            audit.require(sample['state'].get(field) == 0, f'skipped native property not held {outer}/{role}/{field}')
        previous.update({role: sample['state'] for role, sample in after.items()})
        previous_samples.update(after)
    audit.require(probe.get('logicalOuterFrames') == logical and probe.get('skippedOuterFrames') == skipped,
                  'probe native logical/skipped outer counters differ from actual snapshots')
    audit.require(set(range(1, target + 1)) <= set(logical_rows), 'missing a target logical after-native tick')
    counts = probe.get('postFlushHookCounts')
    audit.require(isinstance(counts, dict) and all(counts.get(phase) == outer_count for phase in PHASES[1:3]),
                  'named Begin/Step after-flush hook counts missing/different')
    for role in LATE_ROLES:
        first_step = next((event for event in events if isinstance(event, dict) and event.get('phase') == 'step'
                           and (event.get('state') or {}).get('role') == role), None)
        audit.require(first_step is not None and first_step.get('relativeTick') == 4,
                      'late actor first actual Step is not logical tick4: ' + role)
    zero = created_final.get('late-zero-overrides')
    audit.require(zero is not None and all(zero['state'].get(field) == 0 for field in
                  ('speed', 'gravity', 'friction', 'pathSpeed', 'imageSpeed', 'alarm0'))
                  and zero['state'].get('direction') == 271, 'caller-final zero overrides are missing/different')
    if zero:
        for sample in samples:
            if ((sample.get('state') or {}).get('role') == 'late-zero-overrides' and sample.get('phase') not in
                    ('create-native', 'created-registration-queued')):
                state = sample['state']
                audit.require(all(state.get(field) == 0 for field in ('speed', 'gravity', 'friction', 'pathSpeed', 'imageSpeed'))
                              and state.get('direction') == 271 and state.get('alarm0') in (0, -1)
                              and state.get('alarmEvents') == 0 and state.get('animationEndEvents') == 0,
                              'a late zero caller override was lost')
                for field in POSE_FIELDS:
                    audit.require(same(field, state.get(field), zero['state'].get(field)), 'late zero actor advances ' + field)
    direction = created_final.get('late-direction-override')
    audit.require(direction is not None and direction['state'].get('direction') == 271,
                  'caller-final direction override is absent/different')

    event_counts = Counter(); step_ticks = set(); callback_counts = Counter()
    def bind_native_event(record):
        rows = groups.get(record.get('outerSequence'), {}).get('root-after-native', {})
        role = (record.get('state') or {}).get('role')
        owner = rows.get(role)
        audit.require(owner is not None
                      and all(record.get(key) == owner.get(key) for key in
                              ('renderId', 'tickId', 'relativeTick', 'isTick')),
                      'native event/callback lies outside its actual observed outer/tick/role')

    for event in events:
        if not isinstance(event, dict) or not isinstance(event.get('state'), dict):
            audit.require(False, 'malformed native event body'); continue
        stamp(event); role = state_check(event); phase = event.get('phase')
        bind_native_event(event)
        audit.require(event.get('isTick') is True and phase in EVENTS, 'unrecognized/off-tick native event body')
        is_tail = event.get('centralBeginPending') is True and event.get('rootEndAlreadyObserved') is True
        audit.require(is_tail is (phase == 'animation-end'), 'native event body has ambiguous/wrong tail ownership')
        event_counts[(role, phase)] += 1
        if phase == 'step':
            key = role, event.get('relativeTick')
            audit.require(role not in NO_STEP_ROLES and key not in step_ticks, 'no-Step actor or duplicate native Step body')
            step_ticks.add(key)
    for entry in arrays['nativeCallbackEntries']:
        if not isinstance(entry, dict) or not isinstance(entry.get('state'), dict):
            audit.require(False, 'malformed native callback entry'); continue
        stamp(entry); role = state_check(entry); phase = entry.get('phase')
        bind_native_event(entry)
        audit.require(role == 'native-no-step' and phase in
                      ('native-no-step-alarm-entry', 'native-no-step-animation-end-entry'), 'wrong raw no-Step callback entry')
        audit.require((entry.get('centralBeginPending') is True and entry.get('rootEndAlreadyObserved') is True)
                      is (phase == 'native-no-step-animation-end-entry'), 'raw no-Step callback has wrong native tail ownership')
        callback_counts[phase] += 1
        if entry.get('isTick'):
            body = 'alarm-0' if phase == 'native-no-step-alarm-entry' else 'animation-end'
            audit.require(any(event.get('phase') == body and event.get('outerSequence') == entry.get('outerSequence')
                              and (event.get('state') or {}).get('role') == role for event in events),
                          'raw no-Step callback has no matching native tick body')
    audit.require(all(callback_counts[kind] > 0 for kind in
                      ('native-no-step-alarm-entry', 'native-no-step-animation-end-entry')),
                  'no genuine native no-Step Alarm/AnimationEnd callbacks observed')
    audit.require(all(event_counts[('native-no-step', kind)] > 0 for kind in ('alarm-0', 'animation-end')),
                  'no native no-Step Alarm/AnimationEnd logical bodies observed')
    actions = arrays['lifecycleActions']
    audit.require(len(actions) == 2 and [action.get('phase') for action in actions] ==
                  ['native-deactivation-request', 'native-reactivation-request'], 'unordered/incomplete native lifecycle requests')
    if len(actions) == 2:
        for action in actions:
            stamp(action); audit.require(role_of(action) == 'native-no-step', 'lifecycle request targets wrong actor')
        deactivation, reactivation = actions
        audit.require(deactivation.get('relativeTick') == 8 and deactivation.get('isTick') is True
                      and deactivation['state'].get('active') is True, 'deactivation is not the native tick8 active request')
        on_skip = reactivation.get('isTick') is False
        audit.require(probe.get('noStepReactivatedOnSkippedFrame') is on_skip
                      and reactivation.get('relativeTick') == (16 if on_skip else 17)
                      and reactivation['state'].get('inactiveReadSucceeded') is True,
                      'reactivation phase/retained inactive read is unbound')
        audit.require(reactivation.get('outerSequence', -1) > deactivation.get('outerSequence', -1),
                      'reactivation preceded deactivation')
        # A 60-cap native run can contain isolated skipped outers well after
        # these lifecycle windows. Those do not retroactively make tick4
        # creation or tick17 reactivation a skipped trial. Bind each action to
        # its actual phase; the comparison separately requires a genuine
        # skipped creation/reactivation trial from at least one run.
        late_on_skip = all(births.get(role, {}).get('isTick') is False for role in LATE_ROLES)
        audit.require(type(probe.get('lateCreatedOnSkippedFrame')) is bool
                      and probe['lateCreatedOnSkippedFrame'] is late_on_skip,
                      'late creation flag differs from actual native creation phases')
        if not skipped:
            audit.require(not on_skip and not late_on_skip,
                          'non-skipped native comparator reports skipped creation/reactivation')
    # Bind final serialized counters to actual observed native bodies/entries.
    for state in arrays['actors']:
        if not isinstance(state, dict):
            audit.require(False, 'malformed final actor'); continue
        role = state.get('role')
        collision_phase = 'collision-partner' if str(role).startswith('partner-') else 'collision-probe'
        for field, phase in [('stepEvents', 'step'), ('alarmEvents', 'alarm-0'), ('animationEndEvents', 'animation-end'),
                             ('collisionEvents', collision_phase)]:
            audit.require(state.get(field) == event_counts[(role, phase)], 'final event/body counter binding differs: ' + str(role) + '/' + field)
        last = previous.get(role, {})
        audit.require(last and all(same(field, state.get(field), last.get(field)) for field in ACTIVE_FIELDS)
                      and all(state.get(field) == last.get(field) for field in ('sprite', 'mask', 'path', 'present', 'active')),
                      'final actor summary differs from authoritative last native snapshot: ' + str(role))
        if role in NO_STEP_ROLES:
            audit.require(state.get('stepEvents') == 0, 'native no-Step role acquired a Step body')
        if role == 'native-no-step':
            audit.require(state.get('rawAlarmEntries') == callback_counts['native-no-step-alarm-entry']
                          and state.get('rawAnimationEndEntries') == callback_counts['native-no-step-animation-end-entry'],
                          'raw no-Step callback counters differ')
    audit.require(len(arrays['actors']) == len(ROLES) and {state.get('role') for state in arrays['actors']} == set(ROLES),
                  'final actor inventory incomplete')
    return audit, {'logicalRows': logical_rows, 'births': births, 'skippedOuterFrames': skipped,
                   'logicalOuterFrames': logical, 'eventCounts': dict(event_counts)}


def canonical_rows(probe, rows, audit):
    """Map observed resource relationships, never equate arbitrary raw IDs."""
    animations = probe.get('animations', [])
    names = {record.get('sprite'): record.get('name') for record in animations if isinstance(record, dict)
             and reference(record.get('sprite'), 'sprite') is not None}
    audit.require(len(animations) == 2 and set(names.values()) == {'fps-origin', 'frame-origin'},
                  'dynamic animation resource map is missing/ambiguous')
    frame_type = next((animation.get('requestedType') for animation in animations
                       if animation.get('name') == 'frame-origin'), None)
    audit.require(whole_number(frame_type), 'native per-game-frame sprite speed type is absent')
    for animation in animations:
        audit.require(animation.get('source') == 's_playerdead' and animation.get('frames', 0) > 1
                      and animation.get('afterType') == frame_type and same('spriteSpeed', animation.get('afterSpeed'), .25),
                      'actual dynamic animation normalization differs')
    anchors = rows.get(1, {})
    particle = (anchors.get('zero-direction') or {}).get('mask')
    block = (anchors.get('partner-moving') or {}).get('mask')
    audit.require(reference(particle, 'sprite') is not None and reference(block, 'sprite') is not None and particle != block,
                  'native fixed mask peer classes are absent/indistinct')
    if isinstance(particle, str) or isinstance(block, str):
        audit.require(reference(particle, 'sprite') == 's_redparticle' and reference(block, 'sprite') == 's_redblock',
                      'native fixed mask names differ from authored diagnostic actors')
    path_refs = {state.get('path') for actors in rows.values() for state in actors.values()
                 if reference(state.get('path'), 'path') not in (None, -1)}
    audit.require(len(path_refs) == 1, 'native path resource membership is missing/ambiguous')
    normalized = {}
    for tick, actors in rows.items():
        normalized[tick] = {}
        for role, state in actors.items():
            value = {key: item for key, item in state.items() if key not in
                     {'instanceId', 'sprite', 'mask', 'path', 'beginEvents', 'endEvents',
                      'birthTick', 'birthRender', 'birthOuterSequence', 'birthIsTick'}}
            if state.get('active'):
                mask = state.get('mask')
                mask_class = 'particle-mask' if mask == particle else 'block-mask' if mask == block else 'unknown-mask'
                expected_mask = 'block-mask' if role.startswith('partner-') else 'particle-mask'
                audit.require(mask_class == expected_mask, f'observed mask relation changed {tick}/{role}')
                value['maskClass'] = mask_class
                sprite = state.get('sprite')
                sprite_class = names.get(sprite) or ('particle-sprite' if sprite == particle else 'block-sprite' if sprite == block else 'unknown-sprite')
                expected_sprite = ('frame-origin' if role == 'animation-frame-origin' else
                                   'fps-origin' if role in {'animation-fps-origin', 'native-no-step', *LATE_ROLES} else
                                   'block-sprite' if role.startswith('partner-') else 'particle-sprite')
                audit.require(sprite_class == expected_sprite, f'observed sprite relation changed {tick}/{role}')
                value['spriteClass'] = sprite_class
            parsed_path = reference(state.get('path'), 'path')
            path_present = parsed_path is not None and parsed_path != -1
            audit.require(path_present is (role in {'native-path', 'late-zero-overrides'}),
                          f'observed path membership differs {tick}/{role}')
            value['pathPresent'] = path_present
            normalized[tick][role] = value
    return normalized


def assess_record(spec, result, summary, bound=None, run=None, native_log=None):
    audit = record_errors(spec, result, summary, bound, run, native_log)
    probe = result.get('timingProbe')
    probe_audit, details = assess_probe(probe, spec.get('timingProbe'))
    for error in probe_audit.errors:
        audit.require(False, error)
    audit.count += max(0, probe_audit.count - len(probe_audit.errors))
    audit.require(isinstance(probe, dict) and probe.get('renderCap') == spec.get('fps'), 'native probe/request render cap differs')
    if isinstance(probe, dict):
        audit.require(probe.get('logicalOuterFrames') == result.get('simulationFrames'),
                      'native logical outer count differs from completed player simulation ticks')
        observations = [sample for sample in probe.get('samples', []) if isinstance(sample, dict)]
        starts = [sample.get('generatedDrawFrames') for sample in observations
                  if sample.get('phase') == 'create-native' and sample.get('outerSequence') == 0]
        ends = [sample.get('generatedDrawFrames') for sample in observations
                if sample.get('phase') == 'root-after-native'
                and sample.get('outerSequence') == probe.get('outerFramesObserved')]
        audit.require(bool(starts) and bool(ends) and all(whole_number(value) for value in starts + ends)
                      and len(set(starts)) == len(set(ends)) == 1
                      and ends[0] - starts[0] == result.get('renderFrames'),
                      'separate generated native render count differs from result/launcher binding')
    canonical = canonical_rows(probe, details.get('logicalRows', {}), audit) if isinstance(probe, dict) and audit.count == 0 else {}
    return {'passed': audit.count == 0, 'errors': audit.errors, 'errorCount': audit.count,
            'fps': spec.get('fps'), 'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ,
            'simulationFrames': result.get('simulationFrames'), 'renderFrames': result.get('renderFrames'),
            'diagnosticPreparation': result.get('diagnosticPreparation'),
            'lateCreatedOnSkippedFrame': probe.get('lateCreatedOnSkippedFrame') if isinstance(probe, dict) else None,
            'noStepReactivatedOnSkippedFrame': probe.get('noStepReactivatedOnSkippedFrame') if isinstance(probe, dict) else None,
            'skippedOuterFrames': details.get('skippedOuterFrames'),
            'logicalOuterFrames': details.get('logicalOuterFrames'), 'canonical': canonical,
            'sourceIdentity': result.get('sourceIdentity'), 'spec': spec,
            'scope': 'native probe structure/state; cross-cap acceptance requires actual60 comparison'}


def read_run(run, bound):
    run = Path(run).resolve()
    try:
        documents = [load(run / name) for name in ('spec.json', 'runtime.json', 'summary.json')]
        record = assess_record(*documents, bound=bound, run=run,
                               native_log=(run / 'runtime.log').read_text(errors='replace'))
        record['rawHashes'] = {name: file_hash(run / name) for name in
                               ('spec.json', 'runtime.json', 'summary.json', 'runtime.log')}
    except (OSError, ValueError, TypeError, KeyError, AttributeError) as error:
        record = {'passed': False, 'errors': ['missing/malformed/unbound native evidence: ' + str(error)],
                  'errorCount': 1, 'canonical': {}, 'scope': 'no timing-state conclusion'}
    record['run'] = str(run)
    return record


def compare_records(records):
    audit = Audit()
    audit.require(len(records) >= 2, 'at least two actual native rendering-cap runs are required')
    for record in records:
        audit.require(record.get('passed') is True, 'run failed strict native assessment: ' + record.get('run', '(fixture)'))
    caps = [record.get('fps') for record in records]
    audit.require(len(set(caps)) == len(caps), 'comparison caps are duplicated/missing')
    baselines = [record for record in records if record.get('fps') == 60]
    audit.require(len(baselines) == 1, 'exactly one actual rendering-cap60 comparator is required')
    audit.require(any(record.get('passed') is True
                      and record.get('lateCreatedOnSkippedFrame') is True
                      and record.get('noStepReactivatedOnSkippedFrame') is True for record in records),
                  'comparison lacks a strictly accepted native skipped creation/reactivation trial')
    if len(baselines) == 1:
        baseline = baselines[0]; base_spec = baseline.get('spec', {})
        target = int((base_spec.get('timingProbe') or {}).get('ticks', 0))
        compare_fields = ('room', 'fixture', 'mode', 'inputClock', 'simulationHz', 'seed', 'expect',
                          'maxFrames', 'traceEvery', 'inputs', 'timingProbe')
        for record in records:
            audit.require(record.get('sourceIdentity') == baseline.get('sourceIdentity'), 'compiled source/payload/content differs across caps')
            audit.require(all(record.get('spec', {}).get(key) == base_spec.get(key) for key in compare_fields),
                          'submitted simulation/probe request differs across caps')
            if baseline.get('passed') is not True or record.get('passed') is not True:
                # A failed phase audit deliberately withholds canonical rows.
                # Its existing rejection remains binding; empty withheld rows
                # are not evidence of an actual native role/state difference.
                continue
            for tick in range(1, target + 1):
                left = baseline.get('canonical', {}).get(tick, {}); right = record.get('canonical', {}).get(tick, {})
                audit.require(set(left) == set(right), f'logical role coverage differs at tick{tick}/cap{record.get("fps")}')
                for role in left.keys() & right.keys():
                    audit.require(left[role].keys() == right[role].keys(), f'observed state schema differs tick{tick}/{role}/cap{record.get("fps")}')
                    for field in left[role].keys() & right[role].keys():
                        audit.require(same(field, left[role][field], right[role][field]),
                                      f'native state differs tick{tick}/{role}/{field}/cap{record.get("fps")}')
    return {'passed': audit.count == 0, 'errors': audit.errors, 'errorCount': audit.count,
            'fixture': FIXTURE, 'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ,
            'comparison': 'actual root-after-native state by logical relative tick/role against actual cap60',
            'floatTolerance': TOLERANCE, 'baselineRun': baselines[0].get('run') if len(baselines) == 1 else None,
            'runs': [{key: value for key, value in record.items() if key not in {'canonical', 'spec'}} for record in records],
            'limitations': ['Delivered display FPS is not inferred from requested cap.',
                            'Supplementary instance Begin/End counts and raw resource/instance IDs are excluded.',
                            'Resources compare through declared animations and fixed-mask names when typed native refs provide them; numeric refs use peer relationships.',
                            'No hardware/service tests, campaign restart or special-draft quality/completion claim.']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    generate = sub.add_parser('generate')
    generate.add_argument('--output', type=Path, required=True)
    generate.add_argument('--fps', type=int, nargs='+', default=RENDER_COMPARISON_FPS)
    generate.add_argument('--ticks', type=int, default=72)
    for name in ('verify', 'compare'):
        command = sub.add_parser(name)
        command.add_argument('--build', type=Path, required=True)
        command.add_argument('runs', type=Path, nargs='+')
        command.add_argument('--output', type=Path)
    args = parser.parse_args()
    if args.command == 'generate':
        output = args.output.resolve()
        if output == ROOT or ROOT in output.parents:
            raise ValueError('Keep unverified generated requests outside the checkout')
        requests = [specification(cap, args.ticks) for cap in args.fps]
        if len(set(args.fps)) != len(args.fps):
            raise ValueError('Duplicate requested caps')
        output.mkdir(parents=True, exist_ok=False)
        for request in requests:
            (output / f'probe-{request["fps"]}.json').write_text(json.dumps(request, indent=2) + '\n')
        print(json.dumps({'status': 'unverified requests only', 'count': len(requests), 'nativeLaunches': 0,
                          'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ, 'output': str(output)}, indent=2))
        return 0
    try:
        bound = binding(args.build)
        records = [read_run(run, bound) for run in args.runs]
        if args.command == 'compare':
            report = compare_records(records)
        else:
            report = {'passed': all(record['passed'] for record in records), 'binding': bound,
                      'crossCapAcceptance': False,
                      'runs': [{key: value for key, value in record.items() if key not in {'canonical', 'spec'}} for record in records]}
    except (OSError, ValueError, TypeError, KeyError, RuntimeError) as error:
        report = {'passed': False, 'errors': ['native build binding unavailable/invalid: ' + str(error)]}
    if args.output:
        output = args.output.resolve()
        if output == ROOT or ROOT in output.parents:
            raise ValueError('Keep diagnostic reports outside the checkout')
        output.parent.mkdir(parents=True, exist_ok=True)
        if output.exists():
            raise ValueError('Preserve prior reports; use a fresh output path')
        output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
