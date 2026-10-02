#!/usr/bin/env python3
"""Assess actual native background layers without launching or emulating motion.

Layer acceptance is separate from the complete timing_qa actor foundation.
Generated requests remain NEW UNVERIFIED. Actual cap60 is the comparator;
requested rendering caps never establish delivered display FPS. Historical
records without pause/Draw observations are incomplete, never backfilled.
"""
import argparse
from collections import defaultdict
import copy
import json
import math
from pathlib import Path
import re

import timing_qa
from gameplay_qa import INPUT_CLOCK, SIMULATION_HZ, whole_number
from native_evidence import file_hash
from tcc_project import ROOT

CAPS = (30, 60, 75, 100, 120, 144, 150, 237)
DEFINITIONS = {
    'horizontal-negative': {'initialX': 32, 'initialY': -4096, 'hspeed': -.2, 'vspeed': 0},
    'vertical-positive': {'initialX': 96, 'initialY': -4096, 'hspeed': 0, 'vspeed': 1},
    'diagonal': {'initialX': 160, 'initialY': -4096, 'hspeed': .2, 'vspeed': -.5},
}
BEGIN, STEP, END = 'root-begin-after-flush', 'root-step-after-flush', 'root-after-native'
PRE_DRAW, POST_DRAW, SETUP = 'root-before-draw', 'root-after-draw', 'layer-setup'
PHASES = (BEGIN, STEP, END, PRE_DRAW, POST_DRAW)
BOOLS = ('isTick', 'drawScheduled', 'centralBeginPending', 'rootEndAlreadyObserved', 'paused')
COUNTERS = ('outerSequence', 'renderId', 'tickId', 'relativeTick', 'generatedDrawFrames', 'nativeOuterHz')
STAMP_FIELDS = ('outerSequence', 'renderId', 'tickId', 'relativeTick', 'isTick', 'drawScheduled', 'paused')
VALUES = ('x', 'y', 'hspeed', 'vspeed')
SCOPE = ('Observed three native background layers and complete actor foundation; '
         'actual cap60 cross-logical comparison, no campaign/OS/service/display-rate claim.')
LIMITS = [
    'No manual movement, compensating offsets, synthesized phases or passing native fixture.',
    'The first skipped Begin may include the preceding logical tick native tail; later skipped intervals must freeze.',
    'Current-tick End is not assumed to contain that tick layer motion; observed phase order and actual cap60 determine it.',
    'Terminal QA End writes the result before its Draw; that final tail remains explicitly unobserved.',
    'Native API/phase behavior requires actual new-build records; source changes alone establish no acceptance.',
    'Generated caps do not establish delivered device/display FPS.',
]


def same(left, right):
    return timing_qa.finite(left) and timing_qa.finite(right) and math.isclose(
        left, right, abs_tol=timing_qa.FLOAT_ABS, rel_tol=timing_qa.FLOAT_REL)


def native_true(value):
    # layer_exists() in the actual VM records is native real1, not a JSON bool.
    return value is True or (whole_number(value, 1) and value == 1)


def draw_counter_errors(end, pre, post):
    """Bind the actual hooks around timing_before_draw's sole increment.

    Root pre-Draw samples before timing_before_draw, post-Draw samples after
    restoration. This checks counters only; it creates no native phase/state.
    """
    audit = timing_qa.Audit()
    typed = audit.require(all(whole_number(value) for value in (end,pre,post)),
                          'pre/post Draw counters are missing/boolean/fractional')
    if typed:
        audit.require(pre == end and post == end + 1,
                      'pre/post Draw counters do not bind the actual pre-increment/post-increment hooks')
    return audit


def layer_reference(value):
    """Require the native typed layer namespace, not an actor/sprite/raw ID."""
    if not isinstance(value, str):
        return None
    match = re.fullmatch(r'@ref layer\((\d+)\)', value)
    return int(match[1]) if match else None


def specification(fps, ticks=72):
    if type(fps) is not int or fps not in CAPS:
        raise ValueError('Layer requests support the declared eight rendering caps')
    spec = timing_qa.specification(fps, ticks)
    spec['timingProbe']['observeLayers'] = True
    spec['layerCandidate'] = {'verified': False, 'requiresFreshNativeRecording': True, 'scope': SCOPE}
    return spec


def request_errors(spec):
    audit = timing_qa.Audit()
    if not audit.require(isinstance(spec, dict), 'layer request must be an object'):
        return audit
    probe = spec.get('timingProbe')
    valid = audit.require(isinstance(probe, dict) and probe.get('observeLayers') is True
                          and type(probe.get('ticks')) is int and 60 <= probe['ticks'] <= 240
                          and type(spec.get('fps')) is int and spec['fps'] in CAPS,
                          'layer request lacks a genuine boolean observeLayers/tick/cap declaration')
    if valid:
        expected = specification(spec['fps'], probe['ticks'])
        fields = ('room', 'fixture', 'mode', 'fps', 'inputClock', 'simulationHz', 'seed',
                  'expect', 'maxFrames', 'traceEvery', 'inputs', 'timingProbe')
        audit.require(all(spec.get(key) == expected[key] for key in fields),
                      'layer request differs from the complete native72-tick-family foundation timeline')
        audit.require(type(spec.get('seed')) is int and type(spec.get('maxFrames')) is int
                      and type(spec.get('traceEvery')) is int
                      and type(spec.get('simulationHz')) is int
                      and type(probe.get('maxOuterFrames')) is int
                      and type(probe.get('maxSamples')) is int,
                      'request counters/seed are not exact non-boolean integer types')
    audit.require(not any(key in spec for key in ('timingScenario', 'actor', 'challenge', 'specialIndex',
                  'levelSelect', 'route', 'routeStartFrame', 'fpsOverrides', 'cosmetics', 'cameraProbe')),
                  'layer request mixes another actor/context/controller or legacy timeline')
    if 'layerCandidate' in spec:
        candidate = spec['layerCandidate']
        audit.require(isinstance(candidate, dict) and candidate.get('verified') is False
                      and candidate.get('requiresFreshNativeRecording') is True,
                      'generated layer candidate lost its NEW UNVERIFIED status')
    return audit


def binding(build):
    """Rehash the immutable app and require the actual supported layer setup."""
    bound = timing_qa.binding(build)
    source_path = Path(bound['snapshot']) / 'scripts/scr_timing_qa/scr_timing_qa.gml'
    source = source_path.read_text()
    setup = re.search(r'function timing_qa_layers_setup\(\)\s*\{([\s\S]*?)\n\}', source)
    declared = re.search(r'var _definitions\s*=\s*(\[[\s\S]*?\]);', setup[1] if setup else '')
    if not declared:
        raise ValueError('Compiled snapshot has no actual native layer setup definitions')
    definitions = json.loads(re.sub(r'([{,]\s*)([A-Za-z_]\w*)\s*:', r'\1"\2":', declared[1]))
    observed = {row['role']: {'initialX':row['x'], 'initialY':row['y'], 'hspeed':row['h'], 'vspeed':row['v']}
                for row in definitions}
    if len(definitions) != 3 or observed != DEFINITIONS:
        raise ValueError('Compiled layer definitions differ from the supported three native roles')
    if not all(call in setup[1] for call in ('layer_create(', 'layer_background_create(', 'layer_hspeed(', 'layer_vspeed(')):
        raise ValueError('Compiled layer setup does not use genuine native background layers/speeds')
    sample = re.search(r'function timing_qa_layers_sample\(_phase\)\s*\{([\s\S]*?)\n\}', source)
    if not sample or re.search(r'\b(?:layer_x|layer_y|layer_hspeed|layer_vspeed|event_perform|event_user)\s*\(', sample[1]):
        raise ValueError('Layer observer is missing or mutates/dispatches native state')
    bound['layerObserverSha256'] = file_hash(source_path)
    return bound


def layer_errors(spec, result):
    """Validate raw phase/state observations; never normalize observed offsets."""
    audit = request_errors(spec)
    if audit.count:
        return audit, {}
    if not isinstance(result, dict):
        audit.require(False, 'runtime must be an object')
        return audit, {}
    audit.require(result.get('format') == 'tcc.gameplay-evidence'
                  and whole_number(result.get('schemaVersion'), 1) and result['schemaVersion'] == 1
                  and whole_number(result.get('inputMaskVersion'), 1) and result['inputMaskVersion'] == 2,
                  'missing/non-numeric native gameplay/input schema')
    audit.require(all(whole_number(result.get(key)) for key in
                      ('frames','simulationFrames','renderFrames','deaths','fps','seed',
                       'simulationHz','elapsedUs','drawCalls','routeIndex')),
                  'missing/boolean/fractional native runtime clock/counter fields')
    probe = result.get('timingProbe')
    if not audit.require(isinstance(probe, dict), 'runtime has no real timing probe'):
        return audit, {}
    audit.require(whole_number(probe.get('schemaVersion'), 1) and probe['schemaVersion'] == 2
                  and probe.get('fixture') == timing_qa.FIXTURE and probe.get('verdict') == 'unassessed',
                  'missing/wrong native-v2 probe schema/fixture/verdict')
    audit.require(probe.get('spec') == spec.get('timingProbe') and isinstance(probe.get('spec'), dict)
                  and probe['spec'].get('observeLayers') is True,
                  'native probe did not retain the actual observeLayers request')
    layers = probe.get('nativeLayers')
    if not audit.require(isinstance(layers, dict), 'missing nativeLayers observations'):
        return audit, {}
    audit.require(layers.get('verdict') == 'unassessed' and layers.get('samplesTruncated') is False,
                  'native layer observer is assessed/missing truncation state/truncated')
    definitions = layers.get('definitions')
    if not audit.require(isinstance(definitions, list) and len(definitions) == 3
                         and all(isinstance(row, dict) for row in definitions),
                         'missing/extra/malformed three native layer definitions'):
        return audit, {}
    ids = {}
    for definition in definitions:
        role, ref = definition.get('role'), definition.get('id')
        valid = audit.require(isinstance(role, str) and role in DEFINITIONS
                              and role not in ids and layer_reference(ref) is not None,
                              'missing/duplicate/wrong typed native layer definition role/ref')
        if valid:
            ids[role] = ref
            audit.require(all(timing_qa.finite(definition.get(key))
                              and same(definition[key], value) for key, value in DEFINITIONS[role].items()),
                          'actual native layer authored definition differs: ' + role)
    audit.require(set(ids) == set(DEFINITIONS) and len(set(ids.values())) == 3,
                  'native layer inventory/typed IDs are missing/ambiguous')
    samples = layers.get('samples')
    if not audit.require(isinstance(samples, list) and samples and all(isinstance(row, dict) for row in samples),
                         'missing/malformed raw native layer samples'):
        return audit, {}
    metadata_ok = audit.require(all(whole_number(probe.get(key), 1) for key in
                               ('startTick', 'startRender', 'outerFramesObserved', 'logicalOuterFrames'))
                               and whole_number(probe.get('skippedOuterFrames'))
                               and whole_number(probe.get('targetTicks'), 60),
                               'missing/boolean/fractional native layer/probe counters')
    if not metadata_ok:
        return audit, {}
    start, first_render, outer_count, target = (int(probe[key]) for key in
                                             ('startTick', 'startRender', 'outerFramesObserved', 'targetTicks'))
    if not audit.require(outer_count <= spec['timingProbe']['maxOuterFrames']
                         and target <= 240
                         and len(samples) <= spec['timingProbe']['maxSamples'],
                         'native layer counters/samples exceed bounded actual request'):
        return audit, {}
    audit.require(target == (spec.get('timingProbe') or {}).get('ticks'),
                  'native layer target differs from the actual request')
    groups, setups, phase_counts = {}, [], defaultdict(int)
    actor_stamps = {}
    for row in probe.get('samples', []) if isinstance(probe.get('samples'), list) else []:
        if isinstance(row, dict) and row.get('phase') in (BEGIN, STEP, END):
            key = row.get('outerSequence'), row.get('phase')
            stamp = {field:row.get(field) for field in STAMP_FIELDS}
            audit.require(key not in actor_stamps or actor_stamps[key] == stamp,
                          'actor foundation has contradictory actual phase stamps')
            actor_stamps[key] = stamp
    last_elapsed, last_order = -1, (-1, -1)
    for row in samples:
        phase = row.get('phase')
        typed = audit.require(all(whole_number(row.get(key)) for key in COUNTERS)
                              and all(type(row.get(key)) is bool for key in BOOLS)
                              and whole_number(row.get('elapsedUs')),
                              'missing/nonfinite/boolean-counter or non-boolean pause/phase stamp')
        if not typed:
            # Keep independently usable historical Begin/End geometry so drift
            # is reported even when its old schema lacks explicit pause fields.
            usable = all(whole_number(row.get(key)) for key in COUNTERS)
            usable &= all(type(row.get(key)) is bool for key in BOOLS if key != 'paused')
            usable &= whole_number(row.get('elapsedUs'))
            if not usable:
                continue
        audit.require(row.get('paused') is False, 'layer diagnostic is paused or lacks explicit native boolean pause state')
        audit.require(row['tickId'] == start + row['relativeTick']
                      and row['nativeOuterHz'] >= SIMULATION_HZ,
                      'layer native logical tick/outer rate binding differs')
        audit.require(row['elapsedUs'] >= last_elapsed, 'layer native phase observations moved backward')
        last_elapsed = row['elapsedUs']
        if not audit.require(isinstance(phase, str) and (phase == SETUP or phase in PHASES),
                             'unknown native layer phase'):
            continue
        order = (int(row['outerSequence']), -1 if phase == SETUP else PHASES.index(phase))
        audit.require(order > last_order, 'raw native layer phase order is reordered/duplicated')
        last_order = order
        values = row.get('layers')
        if not audit.require(isinstance(values, list) and len(values) == 3
                             and all(isinstance(state, dict) for state in values),
                             'incomplete/malformed actual layer sample inventory'):
            continue
        states = {}
        for state in values:
            role = state.get('role')
            valid = audit.require(isinstance(role, str) and role in ids and role not in states
                                  and state.get('id') == ids.get(role)
                                  and layer_reference(state.get('id')) is not None
                                  and native_true(state.get('present'))
                                  and all(timing_qa.finite(state.get(key)) for key in VALUES),
                                  'missing/wrong typed layer ID, presence, duplicate role or finite state')
            if valid:
                states[role] = {key:state[key] for key in VALUES}
        audit.require(set(states) == set(DEFINITIONS), 'actual layer sample loses native role coverage')
        record = {**row, 'states':states}
        phase_counts[phase] += 1
        if phase == SETUP:
            setups.append(record)
            audit.require(row['outerSequence'] == 0 and row['relativeTick'] == 0 and row['isTick'] is True
                          and row['renderId'] == first_render and row['centralBeginPending'] is False
                          and row['rootEndAlreadyObserved'] is False,
                          'native layer setup is not the genuine prepared initial Begin')
            continue
        outer = int(row['outerSequence'])
        if not audit.require(1 <= outer <= outer_count, 'layer phase is outside actual observed outer window'):
            continue
        audit.require(row['renderId'] == first_render + outer - 1, 'layer render/outer sequence is not contiguous')
        peers = groups.setdefault(outer, {})
        audit.require(phase not in peers, 'duplicate native layer phase in outer' + str(outer))
        if phase not in peers:
            peers[phase] = record
        if phase in (BEGIN, STEP, END):
            actual = actor_stamps.get((outer, phase))
            audit.require(actual is not None and all(row.get(key) == actual.get(key) for key in actual),
                          'layer stamp is not bound to the actual complete actor foundation phase')
        audit.require(row['rootEndAlreadyObserved'] is (phase in (END, PRE_DRAW, POST_DRAW))
                      and row['centralBeginPending'] is (phase in (PRE_DRAW, POST_DRAW)),
                      'layer phase has wrong explicit native Begin/End/tail ownership')
    audit.require(len(setups) == 1 and set(groups) == set(range(1, outer_count + 1)),
                  'layer setup/outer coverage is missing/duplicated')
    if setups and set(setups[0]['states']) == set(DEFINITIONS):
        for role, state in setups[0]['states'].items():
            definition = DEFINITIONS[role]
            audit.require(all(same(state[field], definition[key]) for field, key in
                              [('x', 'initialX'), ('y', 'initialY'), ('hspeed', 'hspeed'), ('vspeed', 'vspeed')]),
                          'native layer setup state differs: ' + role)
    logical, skipped, canonical, tails, skip_drifts = 0, 0, {}, [], []
    previous = None
    for outer in range(1, outer_count + 1):
        peers = groups.get(outer, {})
        if not audit.require(all(phase in peers for phase in (BEGIN, STEP, END)),
                             'missing complete Begin/Step/End layer phase coverage outer' + str(outer)):
            continue
        begin, step, end = (peers[phase] for phase in (BEGIN, STEP, END))
        if outer == 1 and len(setups) == 1:
            audit.require(all(role in setups[0]['states'] and role in begin['states']
                              and all(same(setups[0]['states'][role][field],begin['states'][role][field])
                                      for field in VALUES) for role in DEFINITIONS),
                          'native layer first Begin differs from its actual same-outer setup')
        tick = begin['isTick']
        logical += int(tick); skipped += int(not tick)
        audit.require(all(all(row.get(key) == begin.get(key) for key in STAMP_FIELDS)
                          for row in (step, end)), 'layer Step/End disagrees with Begin stamp')
        audit.require(begin['elapsedUs'] <= step['elapsedUs'] <= end['elapsedUs'],
                      'native Begin/Step/End phase order differs')
        audit.require(all(row['generatedDrawFrames'] == begin['generatedDrawFrames']
                          for row in (step, end)), 'generated Draw counter changes before root End')
        expected_tick = logical - 1
        audit.require(begin['relativeTick'] == expected_tick, 'layer logical progress differs from actual tick flags')
        for role in DEFINITIONS:
            if not all(role in row['states'] for row in (begin, step, end)):
                continue
            for row in (begin, step, end):
                audit.require(all(same(row['states'][role][field], DEFINITIONS[role][field] if tick else 0)
                                  for field in ('hspeed', 'vspeed')),
                              f'native layer speed is not restored/held at {outer}/{row["phase"]}/{role}')
            audit.require(all(same(begin['states'][role][field], row['states'][role][field])
                              for row in (step, end) for field in ('x', 'y')),
                          f'layer offset advances inside observed Begin/Step/End at {outer}/{role}')
        draw_phases = [phase for phase in (PRE_DRAW, POST_DRAW) if phase in peers]
        # Final QA End serializes before Draw/game_end; never invent its tail.
        if outer < outer_count:
            expected = [PRE_DRAW, POST_DRAW] if begin['drawScheduled'] else []
            audit.require(draw_phases == expected,
                          'missing/full-tail Draw phase coverage differs outer' + str(outer))
        if draw_phases:
            audit.require(draw_phases == [PRE_DRAW, POST_DRAW] and begin['drawScheduled'] is True,
                          'unpaired/unrequested native layer Draw phases')
            if len(draw_phases) == 2:
                pre, post = peers[PRE_DRAW], peers[POST_DRAW]
                audit.require(all(all(row.get(key) == begin.get(key) for key in STAMP_FIELDS)
                                  for row in (pre, post)), 'Draw phase disagrees with actual logical/outer stamp')
                audit.require(end['elapsedUs'] <= pre['elapsedUs'] <= post['elapsedUs'],
                              'native End/pre/post Draw order differs')
                counters = draw_counter_errors(end['generatedDrawFrames'],pre['generatedDrawFrames'],
                                               post['generatedDrawFrames'])
                for error in counters.errors:
                    audit.require(False,error)
                if not tick:
                    audit.require(all(role in row['states'] and role in end['states']
                                      and all(same(row['states'][role][field], end['states'][role][field])
                                              for field in VALUES)
                                      for row in (pre, post) for role in DEFINITIONS),
                                  'layer advances/changes native speed during a skipped outer Draw tail')
        if previous:
            prev_begin, prev_end, prev_peers = previous
            audit.require(begin['generatedDrawFrames'] - prev_end['generatedDrawFrames']
                          == int(prev_begin['drawScheduled']),
                          'generated Draw count does not bind the preceding observed outer')
            deltas = {}
            for role in DEFINITIONS:
                if role not in prev_end['states'] or role not in begin['states']:
                    continue
                delta = {field:begin['states'][role][field] - prev_end['states'][role][field] for field in ('x', 'y')}
                deltas[role] = delta
                if not prev_begin['isTick']:
                    frozen = all(same(begin['states'][role][field], prev_end['states'][role][field]) for field in ('x', 'y'))
                    audit.require(frozen, f'genuine skipped-outer layer tail drift {outer-1}->{outer}/{role}')
                    if not frozen:
                        skip_drifts.append({'previousOuter':outer-1, 'outer':outer, 'role':role, 'delta':delta})
                else:
                    # Direction/presence are observed; no guessed current-tick
                    # coordinates or floating-point motion emulation is used.
                    for field, speed in [('x', 'hspeed'), ('y', 'vspeed')]:
                        sign = DEFINITIONS[role][speed]
                        audit.require((delta[field] * sign > 0 if sign else same(delta[field], 0)),
                                      f'preceding native tick tail is missing/reversed at {outer}/{role}/{field}')
            tails.append({'previousOuter':outer-1, 'outer':outer,
                          'previousWasTick':prev_begin['isTick'], 'currentIsTick':tick,
                          'deltas':deltas})
        if tick and 1 <= begin['relativeTick'] <= target:
            canonical[int(begin['relativeTick'])] = {
                role:{field:end['states'][role][field] for field in VALUES}
                for role in DEFINITIONS if role in end['states']}
        previous = begin, end, peers
    audit.require(logical == probe['logicalOuterFrames'] and skipped == probe['skippedOuterFrames']
                  and logical + skipped == outer_count,
                  'layer native logical/skipped/outer counter binding differs')
    audit.require(set(canonical) == set(range(1, target + 1)),
                  'missing complete target logical layer window')
    return audit, {'canonical':canonical if audit.count == 0 else {},
                   'observedLogicalRows':canonical, 'layerDefinitions':definitions,
                   'phaseCounts':dict(phase_counts), 'observedOuterFrames':outer_count,
                   'logicalOuterFrames':logical, 'skippedOuterFrames':skipped,
                   'skipTailDrifts':skip_drifts, 'tailIntervals':tails,
                   'terminalTailObserved':bool(groups.get(outer_count, {}).get(POST_DRAW)),
                   'requiresActual60Comparison':True}


def assess_record(spec, result, summary, bound=None, run=None, native_log=None):
    # This delegates the complete record_errors + native actor lifecycle, event,
    # signed motion/path/animation and source/artifact/save/log/clock assessment.
    audit, details = layer_errors(spec, result)
    probe = result.get('timingProbe') if isinstance(result,dict) else None
    # Bound hostile/malformed counters before the reused foundation allocates
    # its actual phase ranges. Rejected fragments cannot establish foundation.
    safe = request_errors(spec).count == 0 and isinstance(probe,dict) and isinstance(summary,dict)
    safe = safe and whole_number(probe.get('outerFramesObserved'),1) and probe['outerFramesObserved'] <= 6000
    safe = safe and whole_number(probe.get('targetTicks'),60) and probe['targetTicks'] <= 240
    safe = safe and all(isinstance(probe.get(key),list) and len(probe[key]) <= 100000
                        for key in ('samples','events','nativeCallbackEntries'))
    foundation = timing_qa.assess_record(spec,result,summary,bound,run,native_log) if safe else {
        'passed':False,'errors':['unbounded/malformed native actor foundation request/counters/arrays'],
        'errorCount':1,'canonical':{},'spec':spec,'fps':spec.get('fps') if isinstance(spec,dict) else None}
    audit.require(isinstance(summary, dict) and all(whole_number(summary.get(key)) for key in
                  ('frames','simulationFrames','renderFrames','deaths','requestedRenderFps',
                   'requestedSimulationHz','simulationHz','nativeElapsedUs','launcherExitCode')),
                  'missing/boolean/fractional native launcher clock/counter fields')
    audit.require(isinstance(bound, dict) and run is not None and isinstance(native_log, str),
                  'layer acceptance requires freshly rehashed native build/run/log bindings')
    audit.require(foundation.get('passed') is True, 'complete native actor foundation failed')
    if audit.count:
        details['canonical'] = {}
    return {**details, 'passed':audit.count == 0, 'errors':audit.errors, 'errorCount':audit.count,
            'fps':spec.get('fps') if isinstance(spec,dict) else None,
            'sourceIdentity':result.get('sourceIdentity') if isinstance(result,dict) else None, 'spec':spec,
            'foundation':foundation, 'scope':SCOPE, 'limitations':LIMITS}


def read_run(run, bound):
    run = Path(run).resolve()
    names = ('spec.json', 'runtime.json', 'summary.json', 'runtime.log')
    try:
        before = {name:file_hash(run/name) for name in names}
        docs = [timing_qa.load(run/name) for name in names[:3]]
        record = assess_record(*docs, bound, run, (run/'runtime.log').read_text(errors='replace'))
        after = {name:file_hash(run/name) for name in names}
        if before != after:
            raise ValueError('Actual native files changed during assessment')
        record['rawHashes'] = after
        record['foundation']['rawHashes'] = after
        record['foundation']['run'] = str(run)
    except (OSError, ValueError, TypeError, KeyError, AttributeError, IndexError, OverflowError) as error:
        record = {'passed':False, 'errors':['missing/malformed/unbound native layer evidence: '+str(error)],
                  'errorCount':1, 'canonical':{}, 'foundation':{'passed':False,'errors':[str(error)]}, 'scope':SCOPE}
    record['run'] = str(run)
    return record


def compact(record):
    value = {key:item for key,item in record.items() if key not in
             ('canonical', 'spec', 'observedLogicalRows', 'tailIntervals', 'foundation')}
    value['foundation'] = {key:item for key,item in record.get('foundation', {}).items()
                           if key not in ('canonical', 'spec')}
    return value


def compare_records(records):
    audit = timing_qa.Audit()
    audit.require(len(records) >= 2, 'layer comparison requires at least two actual native runs')
    for record in records:
        audit.require(record.get('passed') is True and bool(record.get('rawHashes')) and bool(record.get('run')),
                      'layer comparison requires strictly assessed genuine native files')
    caps = [record.get('fps') for record in records]
    audit.require(all(type(cap) is int and cap in CAPS for cap in caps) and len(set(caps)) == len(caps),
                  'comparison rendering caps are missing/invalid/duplicated')
    bases = [record for record in records if record.get('fps') == 60]
    audit.require(len(bases) == 1, 'layer comparison requires exactly one actual cap60 comparator')
    foundations = [record.get('foundation', {}) for record in records]
    actor = timing_qa.compare_records(foundations)
    audit.require(actor.get('passed') is True, 'actual cross-cap actor foundation failed')
    observed_differences = []
    if len(bases) == 1:
        base = bases[0]
        fields = ('room', 'fixture', 'mode', 'inputClock', 'simulationHz', 'seed', 'expect',
                  'maxFrames', 'traceEvery', 'inputs', 'timingProbe')
        target = ((base.get('spec') or {}).get('timingProbe') or {}).get('ticks')
        for record in records:
            audit.require(record.get('sourceIdentity') == base.get('sourceIdentity'),
                          'layer source/payload/content differs across actual caps')
            audit.require(all(record.get('spec', {}).get(key) == base.get('spec', {}).get(key) for key in fields),
                          'layer logical request/observeLayers differs across actual caps')
            if not whole_number(target, 60):
                continue
            for tick in range(1, int(target) + 1):
                # Rejected historical records retain read-only actual logical
                # rows for diagnosis; these are never canonical acceptance.
                left = base.get('observedLogicalRows', {}).get(tick, {})
                right = record.get('observedLogicalRows', {}).get(tick, {})
                qualified = record.get('passed') is True and base.get('passed') is True
                if qualified:
                    audit.require(set(left) == set(right) == set(DEFINITIONS),
                                  'actual cap60 logical layer coverage differs tick'+str(tick))
                for role in left.keys() & right.keys():
                    differences = {key:{'actual60':left[role].get(key), 'observed':right[role].get(key)}
                                   for key in VALUES if not same(left[role].get(key), right[role].get(key))}
                    if differences:
                        observed_differences.append({'relativeTick':tick, 'role':role,
                            'cap':record.get('fps'), 'fields':differences, 'qualifiedRows':qualified})
                    if qualified:
                        audit.require(not differences,
                                      f'actual native cap60 layer state differs tick{tick}/{role}/cap{record.get("fps")}')
    return {'passed':audit.count == 0, 'errors':audit.errors, 'errorCount':audit.count,
            'actorFoundation':actor, 'baselineRun':bases[0].get('run') if len(bases)==1 else None,
            'observedActual60Differences':observed_differences,
            'observedActual60DifferencesAreAcceptance':False,
            'comparison':'actual root-End native layer state by relative logical tick/role against actual cap60',
            'floatTolerance':timing_qa.TOLERANCE, 'runs':[compact(record) for record in records],
            'scope':SCOPE, 'limitations':LIMITS}


def assess_runs(build, runs):
    """Bind both passes to fresh actual source/app bytes, including read races."""
    before = binding(build)
    records = [read_run(run, before) for run in runs]
    after = binding(build)
    if before != after:
        raise ValueError('Native source/artifact/observer binding changed during layer assessment')
    return before, records


def native_rejection_checks(build, runs):
    """Mutate copies of preserved raw evidence; never launch/write a native run.

    Historical layers can already fail. Each layer control must still report
    its specific malformed condition. Source/log controls start from a real
    actor record whose complete strict assessment succeeds, then require its
    independent record_errors binding check to reject the changed metadata.
    """
    bound, records = assess_runs(build, runs)
    if not records or any(record.get('foundation', {}).get('passed') is not True for record in records):
        raise ValueError('Rejection controls require complete actual native actor foundation records')
    baselines = [record for record in records if record.get('fps') == 60]
    if len(baselines) != 1:
        raise ValueError('Rejection controls require one actual cap60 record')
    run = Path(baselines[0]['run'])
    before = {name:file_hash(run/name) for name in ('spec.json','runtime.json','summary.json','runtime.log')}
    spec, result, summary = [timing_qa.load(run/name) for name in ('spec.json','runtime.json','summary.json')]
    log = (run/'runtime.log').read_text(errors='replace')
    # Only the layer audit sees this reduced copy; it cannot be submitted as
    # full native foundation evidence. Keep actual stamps, not guessed ones.
    geometry = {key:result[key] for key in ('format','schemaVersion','inputMaskVersion','frames',
                'simulationFrames','renderFrames','deaths','fps','seed','simulationHz','elapsedUs','drawCalls','routeIndex')}
    geometry['timingProbe'] = copy.deepcopy({key:value for key,value in result['timingProbe'].items()
                                           if key not in ('samples','events','nativeEntries')})
    stamps = {}
    for row in result['timingProbe']['samples']:
        if row.get('phase') in (BEGIN,STEP,END):
            key = row['outerSequence'],row['phase']
            stamps.setdefault(key,{field:row.get(field) for field in STAMP_FIELDS + ('phase',)})
    geometry['timingProbe']['samples'] = list(stamps.values())
    def at(data):
        return data['timingProbe']['nativeLayers']
    layer_controls = [
        ('boolean gameplay schema', lambda d:d.update(schemaVersion=True), 'missing/non-numeric native gameplay/input schema'),
        ('boolean probe schema', lambda d:d['timingProbe'].update(schemaVersion=True), 'missing/wrong native-v2 probe schema/fixture/verdict'),
        ('boolean death counter', lambda d:d.update(deaths=False), 'missing/boolean/fractional native runtime clock/counter fields'),
        ('nonboolean truncation', lambda d:at(d).update(samplesTruncated=0), 'native layer observer is assessed/missing truncation state/truncated'),
        ('native truncation', lambda d:at(d).update(samplesTruncated=True), 'native layer observer is assessed/missing truncation state/truncated'),
        ('boolean native counter', lambda d:d['timingProbe'].update(startTick=True), 'missing/boolean/fractional native layer/probe counters'),
        ('unbounded outer counter', lambda d:d['timingProbe'].update(outerFramesObserved=10**20), 'native layer counters/samples exceed bounded actual request'),
        ('wrong target', lambda d:d['timingProbe'].update(targetTicks=73), 'native layer target differs from the actual request'),
        ('boolean layer reference', lambda d:at(d)['definitions'][0].update(id=True), 'missing/duplicate/wrong typed native layer definition role/ref'),
        ('duplicate layer references', lambda d:at(d)['definitions'][1].update(id=at(d)['definitions'][0]['id']), 'native layer inventory/typed IDs are missing/ambiguous'),
        ('missing definition', lambda d:at(d)['definitions'].pop(), 'missing/extra/malformed three native layer definitions'),
        ('unhashable definition role', lambda d:at(d)['definitions'][0].update(role=[]), 'missing/duplicate/wrong typed native layer definition role/ref'),
        ('wrong authored speed', lambda d:at(d)['definitions'][0].update(hspeed=1), 'actual native layer authored definition differs: horizontal-negative'),
        ('nonboolean pause', lambda d:at(d)['samples'][1].update(paused=0), 'missing/nonfinite/boolean-counter or non-boolean pause/phase stamp'),
        ('actual paused layer', lambda d:at(d)['samples'][1].update(paused=True), 'layer diagnostic is paused or lacks explicit native boolean pause state'),
        ('boolean outer counter', lambda d:at(d)['samples'][1].update(outerSequence=True), 'missing/nonfinite/boolean-counter or non-boolean pause/phase stamp'),
        ('fractional timestamp', lambda d:at(d)['samples'][1].update(elapsedUs=.5), 'missing/nonfinite/boolean-counter or non-boolean pause/phase stamp'),
        ('wrong typed state ref', lambda d:at(d)['samples'][1]['layers'][0].update(id='@ref instance(2204)'), 'missing/wrong typed layer ID, presence, duplicate role or finite state'),
        ('nonboolean/nonnumeric presence', lambda d:at(d)['samples'][1]['layers'][0].update(present='1'), 'missing/wrong typed layer ID, presence, duplicate role or finite state'),
        ('nonfinite native offset', lambda d:at(d)['samples'][1]['layers'][0].update(x=float('inf')), 'missing/wrong typed layer ID, presence, duplicate role or finite state'),
        ('unhashable state role', lambda d:at(d)['samples'][1]['layers'][0].update(role=[]), 'missing/wrong typed layer ID, presence, duplicate role or finite state'),
        ('unhashable phase', lambda d:at(d)['samples'][1].update(phase=[]), 'unknown native layer phase'),
        ('missing Step phase', lambda d:at(d)['samples'].pop(2), 'missing complete Begin/Step/End layer phase coverage outer1'),
        ('duplicate native phase', lambda d:at(d)['samples'].insert(2,copy.deepcopy(at(d)['samples'][1])), 'raw native layer phase order is reordered/duplicated'),
        ('reordered native phases', lambda d:at(d)['samples'].__setitem__(slice(1,3),list(reversed(at(d)['samples'][1:3]))), 'raw native layer phase order is reordered/duplicated'),
    ]
    checks = []
    for name, mutate, error in layer_controls:
        malformed = copy.deepcopy(geometry)
        mutate(malformed)
        audit,_ = layer_errors(spec,malformed)
        if audit.count == 0 or error not in audit.errors:
            raise AssertionError('Malformed native layer control was not specifically rejected: '+name)
        checks.append({'name':name,'rejectedBy':error})
    clean = timing_qa.record_errors(spec,result,summary,bound,run,log)
    if clean.count:
        raise AssertionError('Original source-bound native record no longer meets foundation binding')
    for key in ('sourceSha256','physicsSha256'):
        stale = copy.deepcopy(bound); stale['source'][key] = '0'*64
        audit = timing_qa.record_errors(spec,result,summary,stale,run,log)
        if not audit.count or 'request identity differs from freshly hashed build/content' not in audit.errors:
            raise AssertionError('Stale source binding was not rejected: '+key)
        checks.append({'name':'stale '+key,'rejectedBy':'request identity differs from freshly hashed build/content'})
    for key in ('executableSha256','artifact'):
        stale = copy.deepcopy(bound)
        if key == 'artifact': stale[key]['sha256'] = '0'*64
        else: stale[key] = '0'*64
        audit = timing_qa.record_errors(spec,result,summary,stale,run,log)
        if not audit.count or 'request identity differs from freshly hashed build/content' not in audit.errors:
            raise AssertionError('Stale payload binding was not rejected: '+key)
        checks.append({'name':'stale '+key,'rejectedBy':'request identity differs from freshly hashed build/content'})
    malformed_spec = copy.deepcopy(spec)
    malformed_spec['identity']['levelContentSha256'] = '0'*64
    audit = timing_qa.record_errors(malformed_spec,result,summary,bound,run,log)
    if 'request identity differs from freshly hashed build/content' not in audit.errors:
        raise AssertionError('Wrong real room content binding was not rejected')
    checks.append({'name':'wrong native room content hash','rejectedBy':'request identity differs from freshly hashed build/content'})
    for name, bad_summary, bad_log, expected in (
        ('missing native normal end',summary,'','native log lacks normal engine end marker'),
        ('launcher requested clock mismatch',{**summary,'requestedInputClock':'outer-frame-v0'},log,'launcher requested clock/render cap binding differs'),
        ('launcher timeout',{**summary,'timedOut':True},log,'missing normal native engine end or timed-out launch')):
        audit = timing_qa.record_errors(spec,result,bad_summary,bound,run,bad_log)
        if expected not in audit.errors:
            raise AssertionError('Native log/clock control was not rejected: '+name)
        checks.append({'name':name,'rejectedBy':expected})
    malformed = assess_record(spec,result,{**summary,'deaths':False},bound,run,log)
    expected = 'missing/boolean/fractional native launcher clock/counter fields'
    if malformed['passed'] or expected not in malformed['errors']:
        raise AssertionError('Boolean native launcher counter was not rejected')
    checks.append({'name':'boolean native launcher death counter','rejectedBy':expected})
    if before != {name:file_hash(run/name) for name in before} or bound != binding(build):
        raise ValueError('Native evidence/source/app changed during rejection controls')
    return {'controls':checks,'rejectionFixtures':len(checks),'preservedRun':str(run),'rawHashes':before,
            'binding':bound,'actualActorFoundations':[{'run':r['run'],'passed':r['foundation']['passed']} for r in records],
            'layerAcceptanceEstablished':False}


def selfcheck(build=None, runs=()):
    """Planner/type/parser rejection checks only; never create native PASS."""
    count = 0
    for cap in CAPS:
        spec = specification(cap)
        assert request_errors(spec).count == 0 and spec['layerCandidate']['verified'] is False
        for change in (lambda d:d['timingProbe'].update(observeLayers=1),
                       lambda d:d['timingProbe'].update(ticks=True), lambda d:d.update(seed=True),
                       lambda d:d.update(simulationHz=True), lambda d:d.pop('inputClock'),
                       lambda d:d.update(fps=True), lambda d:d.update(maxFrames=79),
                       lambda d:d.update(mode='record'), lambda d:d.update(timingScenario={}),
                       lambda d:d['layerCandidate'].update(verified=True)):
            bad = copy.deepcopy(spec); change(bad); assert request_errors(bad).count > 0; count += 1
        for bad in ({}, {'format':'tcc.gameplay-evidence','schemaVersion':True},
                    {'timingProbe':{'schemaVersion':True}},
                    {'timingProbe':{'nativeLayers':{'definitions':[],'samples':[]}}}):
            assert layer_errors(spec, bad)[0].count > 0; count += 1
    for ref in (True, 1, -1, '@ref instance(2204)', '@ref sprite(1)', '@ref layer(-1)', '@ref layer(true)', '@ref layer(1)junk'):
        assert layer_reference(ref) is None; count += 1
    assert layer_reference('@ref layer(2204)') == 2204
    assert not native_true('1') and not native_true(1.01) and not native_true(False)
    assert compare_records([])['passed'] is False
    assert compare_records([{'passed':True,'fps':60},{'passed':True,'fps':150}])['passed'] is False
    # Counter-only controls do not synthesize missing historical Draw phases
    # or establish native acceptance. The old pre=End+1 contract must reject.
    assert draw_counter_errors(79,79,80).count == 0
    for counters in ((79,80,80),(79,79,79),(79,79,81),(0,False,1),(0,0,True),
                     (-1,-1,0),(79,79,80.5),(79,float('nan'),80)):
        assert draw_counter_errors(*counters).count > 0; count += 1
    actual = native_rejection_checks(build,runs) if build else None
    return {'status':'offline planner/schema/type/source-binding rejection only',
            'rejectionFixtures':count+2+(actual['rejectionFixtures'] if actual else 0),
            'actualRecordControls':actual,'nativeLaunches':0, 'nativeAcceptanceEstablished':False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    generate = sub.add_parser('generate', help='Write new unverified requests only')
    generate.add_argument('--output', type=Path, required=True)
    generate.add_argument('--fps', type=int, nargs='+', choices=CAPS, default=CAPS)
    generate.add_argument('--ticks', type=int, default=72)
    check = sub.add_parser('selfcheck', help='Offline malformed/type rejection controls; no native claims')
    check.add_argument('--build',type=Path)
    check.add_argument('--runs',type=Path,nargs='+')
    for name in ('verify', 'compare'):
        command = sub.add_parser(name)
        command.add_argument('--build', type=Path, required=True)
        command.add_argument('runs', type=Path, nargs='+')
        command.add_argument('--output', type=Path)
    args = parser.parse_args()
    if args.command == 'selfcheck':
        if bool(args.build) != bool(args.runs):
            raise ValueError('Actual-record controls require both --build and --runs')
        print(json.dumps(selfcheck(args.build,args.runs or ()), indent=2)); return 0
    if args.command == 'generate':
        output = args.output.resolve()
        if output == ROOT or ROOT in output.parents:
            raise ValueError('Keep generated unverified requests outside the checkout')
        if len(set(args.fps)) != len(args.fps):
            raise ValueError('Duplicate rendering caps')
        specs = [specification(cap,args.ticks) for cap in args.fps]
        output.mkdir(parents=True,exist_ok=False)
        for spec in specs:
            with (output/f'probe-{spec["fps"]}.json').open('x') as file:
                file.write(json.dumps(spec,indent=2)+'\n')
        print(json.dumps({'status':'NEW UNVERIFIED layer requests only','count':len(specs),'nativeLaunches':0,
                          'inputClock':INPUT_CLOCK,'simulationHz':SIMULATION_HZ,'output':str(output)},indent=2))
        return 0
    try:
        bound, records = assess_runs(args.build,args.runs)
        report = compare_records(records) if args.command=='compare' else {
            'passed':all(record['passed'] for record in records),'crossCapAcceptance':False,
            'binding':bound,'runs':[compact(record) for record in records],'scope':SCOPE,'limitations':LIMITS}
        report['binding'] = bound
        report['nativeLaunches'] = 0
    except (OSError,ValueError,TypeError,KeyError,RuntimeError) as error:
        report = {'passed':False,'errors':['native layer build binding unavailable: '+str(error)]}
    if args.output:
        output=args.output.resolve()
        if output==ROOT or ROOT in output.parents:
            raise ValueError('Keep reports outside the checkout')
        output.parent.mkdir(parents=True,exist_ok=True)
        with output.open('x') as file:
            file.write(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))
    return 0 if report['passed'] else 1


if __name__=='__main__':
    raise SystemExit(main())
