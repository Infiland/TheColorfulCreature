#!/usr/bin/env python3
"""Offline camera requests and native camera/Draw observation assessment.

generate writes four NEW UNVERIFIED direct/smooth x render60/150 requests.
verify reads immutable native evidence; compare requires an actual60 native
comparator for each follow policy. No command launches a runner or changes GML.
Structural/state success is never visual acceptance. Death, third-torch fire,
portals, clipping/occlusion and later campaign/Lunar contexts remain pending.
"""
import argparse
from collections import Counter, defaultdict
import copy
import json
import math
from pathlib import Path
import re
import struct
import zlib

from gameplay_qa import (INPUT_CLOCK, SIMULATION_HZ, require_fixed_clock,
                         validate_input_events, whole_number)
from native_evidence import file_hash
from tcc_project import ROOT
from timing_qa import (Audit, actor_reference, binding as timing_binding, finite,
                       preparation_errors, record_errors, reference)

CAPS = (60, 150)
FOLLOWS = ('direct', 'smooth')
TICKS = 240
PHASES = ('root-begin', 'root-end', 'pre-draw-authoritative', 'pre-draw-interpolated',
          'view-draw-begin', 'actor-draw', 'view-draw-end',
          'post-draw-before-restore', 'post-draw-restored')
DRAW_PHASES = {'view-draw-begin', 'actor-draw', 'view-draw-end'}
BOUNDARY_PHASES = set(PHASES) - {'actor-draw'}
INPUTS = [{'frame': 0, 'mask': 0}, {'frame': 30, 'mask': 2}, {'frame': 210, 'mask': 0}]
CAPTURE_FRAMES = (60, 94, 120, 180)
FLOAT_ABS, FLOAT_REL = 1e-6, 1e-10
MATRIX_ABS = 1e-5
IDENTITY = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
ACTOR_FIELDS = ('x', 'y', 'hsp', 'vsp', 'speed', 'direction', 'hspeed', 'vspeed',
                'imageIndex', 'imageAngle', 'imageXscale', 'imageYscale', 'imageAlpha',
                'visible', 'depth', 'bbox', 'spriteName', 'maskName', 'spriteOrigin', 'maskOrigin')
RESTORE_FIELDS = ACTOR_FIELDS + ('xprevious', 'yprevious', 'sprite', 'mask', 'effectiveMask', 'state')
TRACE_FIELDS = ('x', 'y', 'hsp', 'vsp', 'direction', 'motionSpeed', 'sprite', 'animationFrame',
                'animationVelocity', 'eyesY', 'gravity', 'walkSpeed', 'color', 'grounded',
                'water', 'breath', 'doubleJump', 'zeroGravity', 'ammo', 'keysRemaining',
                'challengeTime', 'challengeDeaths', 'paused', 'bbox')
CONTINUOUS = {'x', 'y', 'hsp', 'vsp', 'hspeed', 'vspeed', 'speed', 'direction', 'motionSpeed',
              'imageIndex', 'imageAngle', 'imageXscale', 'imageYscale', 'imageAlpha', 'depth',
              'bbox', 'spriteOrigin', 'maskOrigin', 'worldDelta', 'animationFrame',
              'animationVelocity', 'eyesY', 'gravity', 'walkSpeed', 'breath', 'challengeTime',
              'xcord', 'ycord', 'gunrotation'}
SCOPE = 'Native camera/Draw observation and fixed60 state; no visual or release acceptance.'
ROLE_OBJECTS = {'player': 'o_player', 'smooth-camera': 'o_smoothcamera',
                'equipped-gun': 'o_gunequipped', 'torch': 'o_torch'}
QA43_INTERPOLATION_PREDICATE = '''
    if (object_index == o_parentandroidbutton || object_is_ancestor(object_index, o_parentandroidbutton)) return false;
    return variable_instance_exists(id, "hsp") || variable_instance_exists(id, "vsp") || speed != 0
        || (variable_instance_exists(id, "timing_native") && timing_native.speed != 0);
'''
FOLLOWER_INTERPOLATION_PREDICATE = '''
    if (object_index == o_parentandroidbutton || object_is_ancestor(object_index, o_parentandroidbutton)) return false;
    if (object_index == o_smoothcamera || object_index == o_smoothcameraboss5
        || object_index == o_gunequipped || object_index == o_fire) return true;
    if (object_index == o_torch && (holding || died)) return true;
    return variable_instance_exists(id, "hsp") || variable_instance_exists(id, "vsp") || speed != 0
        || (variable_instance_exists(id, "timing_native") && timing_native.speed != 0);
'''
INTERPOLATION_PREDICATES = {'qa43-moving-only': QA43_INTERPOLATION_PREDICATE,
                          'explicit-followers-v1': FOLLOWER_INTERPOLATION_PREDICATE}
SMOOTH_STEP_SHA256 = 'effb0f25487f074544e7696a7640319200662fad8689f296577bf83613b3d8e0'


def interpolation_source_errors(source):
    """Fail closed when a snapshot changes the derived Draw eligibility model."""
    audit = Audit()
    stripped = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    predicate = re.search(r'function\s+timing_interpolates_instance\(\)\s*\{(.*?)\n\}', stripped, flags=re.S)
    compact = lambda text: re.sub(r'\s+', '', text)
    profile = next((name for name, body in INTERPOLATION_PREDICATES.items()
                    if predicate is not None and compact(predicate[1]) == compact(body)), None)
    audit.require(profile is not None,
                  'compiled interpolation predicate differs; deliberately update the source-derived model')
    if profile == 'explicit-followers-v1':
        tracked = re.search(r'function\s+timing_native_active\(\)\s*\{(.*?)\n\}', stripped, flags=re.S)
        audit.require(tracked is not None and compact('if (object_index == o_smoothcamera || '
                      'object_index == o_smoothcameraboss5) return true;') in compact(tracked[1]),
                      'explicit interpolated smooth helpers lack source native timing registration')
    for token in ('if (global.renderfps <= TCC_SIM_HZ) return;',
                  'var _alpha = clamp(_t.accumulator_us * TCC_SIM_HZ / 1000000, 0, 1);',
                  'if (point_distance(_n.previous_x, _n.previous_y, x, y) > 64) continue;',
                  'x = lerp(_n.previous_x, _n.current_x, _alpha);',
                  'y = lerp(_n.previous_y, _n.current_y, _alpha);'):
        audit.require(compact(token) in compact(stripped), 'compiled interpolation clock/teleport/lerp contract differs')
    return audit, profile


def merge(audit, other):
    for error in other.errors:
        audit.require(False, error)
    audit.count += max(0, other.count - len(other.errors))


def exact(left, right):
    """Exact native restoration, including boolean/numeric type distinctions."""
    if isinstance(left, dict) and isinstance(right, dict):
        return left.keys() == right.keys() and all(exact(left[k], right[k]) for k in left)
    if isinstance(left, list) and isinstance(right, list):
        return len(left) == len(right) and all(exact(a, b) for a, b in zip(left, right))
    return type(left) is type(right) and left == right or (
        type(left) in (int, float) and type(right) in (int, float) and left == right)


def same(field, left, right):
    if isinstance(left, dict) and isinstance(right, dict):
        return left.keys() == right.keys() and all(same(k, left[k], right[k]) for k in left)
    if isinstance(left, list) and isinstance(right, list):
        return len(left) == len(right) and all(same(field, a, b) for a, b in zip(left, right))
    if field in CONTINUOUS and finite(left) and finite(right):
        return math.isclose(left, right, abs_tol=FLOAT_ABS, rel_tol=FLOAT_REL)
    return exact(left, right)


def native_flag(value):
    """Only native built-in flags may serialize as exact numeric zero/one.

    This is not used for observer-authored booleans, keys, masks or counters.
    Retain raw native values in evidence; do not normalize recorded documents.
    """
    if type(value) is bool:
        return value
    if type(value) in (int, float) and value in (0, 1):
        return value == 1
    return None


def specification(follow, fps, captures=False):
    if follow not in FOLLOWS or type(fps) is not int or fps not in CAPS or type(captures) is not bool:
        raise ValueError('Initial camera scope is direct/smooth at render60/150 only')
    spec = {'room': 'r_gameplay_qa', 'fixture': 'default', 'mode': 'replay',
            'fps': fps, 'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ, 'seed': 1,
            'expect': 'frames', 'maxFrames': TICKS, 'traceEvery': 1, 'inputs': copy.deepcopy(INPUTS),
            'manualCameraCandidate': True,
            'cameraObservation': {'maxSamples': 20000},
            'cameraFixture': {'follow': follow, 'geometry': 'flat', 'startX': 1536,
                              'floorY': 7000, 'gun': True, 'torches': 1},
            'cameraCandidate': {'status': 'NEW UNVERIFIED', 'verified': False,
                                'requiresFreshNativeRecording': True, 'scope': SCOPE}}
    if captures:
        spec.update(captureClock='draw', captureFrames=list(CAPTURE_FRAMES))
    return spec


def request_errors(spec):
    audit = Audit()
    if not audit.require(isinstance(spec, dict), 'camera request must be an object'):
        return audit
    try:
        require_fixed_clock(('camera request', spec))
        validate_input_events(spec.get('inputs'))
    except (ValueError, TypeError) as error:
        audit.require(False, str(error))
    fixture = spec.get('cameraFixture')
    follow = fixture.get('follow') if isinstance(fixture, dict) else None
    valid = audit.require(follow in FOLLOWS and type(spec.get('fps')) is int and spec['fps'] in CAPS,
                          'request lacks the bounded direct/smooth render60/150 case')
    if valid:
        expected = specification(follow, spec['fps'])
        fields = ('room', 'fixture', 'mode', 'fps', 'inputClock', 'simulationHz', 'seed',
                  'expect', 'maxFrames', 'traceEvery', 'inputs', 'cameraFixture', 'manualCameraCandidate')
        audit.require(all(exact(spec.get(k), expected[k]) for k in fields),
                      'request differs from the real240-tick flat camera fixture/input timeline')
    audit.require(spec.get('manualCameraCandidate') is True, 'current camera request must explicitly enable manual fixed60 follow')
    observer = spec.get('cameraObservation')
    audit.require(observer is True or isinstance(observer, dict), 'camera observation is missing or disabled')
    if isinstance(observer, dict):
        limits = {'maxSamples': (64, 50000, 12000), 'maxActors': (1, 32, 12),
                  'maxIdentities': (1, 512, 128), 'maxCandidates': (1, 256, 64), 'maxIssues': (1, 1024, 128)}
        audit.require(not set(observer) - set(limits), 'unknown camera-observation limit')
        values = {key: observer.get(key, default) for key, (_, _, default) in limits.items()}
        for key, (minimum, maximum, _) in limits.items():
            audit.require(whole_number(values[key], minimum) and values[key] <= maximum,
                          'invalid camera-observation limit: ' + key)
        audit.require(all(whole_number(values[k], 1) for k in ('maxActors', 'maxIdentities', 'maxCandidates'))
                      and values['maxIdentities'] >= values['maxActors']
                      and values['maxCandidates'] >= values['maxActors'], 'inconsistent actor selection budgets')
    audit.require(not any(k in spec for k in ('challenge', 'specialIndex', 'levelSelect', 'actor', 'playerColor',
                  'timingProbe', 'timingScenario', 'route', 'routeStartFrame', 'fpsOverrides', 'cosmetics', 'cosmeticFixtures')),
                  'camera request mixes another fixture, gameplay override or legacy timeline')
    candidate = spec.get('cameraCandidate')
    if candidate is not None:
        audit.require(isinstance(candidate, dict) and candidate.get('verified') is False
                      and candidate.get('requiresFreshNativeRecording') is True,
                      'camera request falsely claims pre-verification')
    captures = spec.get('captureFrames', [])
    audit.require(isinstance(captures, list) and len(captures) <= 16
                  and all(whole_number(v, 1) and v < TICKS for v in captures)
                  and len(set(captures)) == len(captures), 'invalid bounded capture simulation frames')
    if captures:
        audit.require(spec.get('captureClock') == 'draw', 'captures must use unique actual-Draw filenames')
    return audit


def binding(build):
    """Reuse full snapshot/executable/artifact rehashing; require camera hooks."""
    bound = timing_binding(build)
    snapshot = Path(bound['snapshot'])
    interpolation, profile = interpolation_source_errors((snapshot / 'scripts/scr_timing/scr_timing.gml').read_text())
    if interpolation.count:
        raise ValueError('; '.join(interpolation.errors))
    bound['interpolationModel'] = profile
    camera = (snapshot / 'scripts/scr_camera_qa/scr_camera_qa.gml').read_text()
    recorder = camera.split('function camera_qa_fixture(', 1)[0]
    stripped = re.sub(r'/\*.*?\*/|//[^\n]*', '', recorder, flags=re.S)
    if re.search(r'\b(?:camera_(?:set_\w+|apply|create\w*|destroy)|matrix_set|'
                 r'instance_(?:create\w*|destroy|activate\w*|deactivate\w*))\s*\(', stripped):
        raise ValueError('Compiled camera recorder mutates cameras/matrices/actor lifecycle')
    if not all('function ' + name + '(' in camera for name in
               ('camera_qa_sample', 'camera_qa_summary', 'camera_qa_fixture',
                'camera_qa_configured_query', 'camera_qa_configured_native')):
        raise ValueError('Compiled camera observer/fixture interface is missing')
    hooks = {'scripts/scr_timing/scr_timing.gml': ('root-begin', 'root-end'),
             'objects/o_deltatime/Draw_76.gml': ('pre-draw-authoritative', 'pre-draw-interpolated'),
             'objects/o_deltatime/Draw_77.gml': ('post-draw-before-restore', 'post-draw-restored'),
             'objects/o_deltatime/Draw_72.gml': ('view-draw-begin',),
             'objects/o_deltatime/Draw_73.gml': ('view-draw-end',),
             'objects/o_player/Draw_0.gml': ('actor-draw',),
             'objects/o_gunequipped/Draw_0.gml': ('actor-draw',)}
    for path, phases in hooks.items():
        text = (snapshot / path).read_text()
        if not all(re.search(r'camera_qa_sample\(\s*"' + phase + '"', text) for phase in phases):
            raise ValueError('Compiled camera hook is missing: ' + path)
    camera_helper = (snapshot / 'scripts/scr_timing_camera/scr_timing_camera.gml').read_text()
    axis = camera_helper.split('function timing_camera_axis(', 1)[-1].split('\n}', 1)[0]
    expected_axis = '_origin, _size, _border, _speed, _target, _room_size) {\n    _border = min(_border, _size / 2);\n    var _destination = _origin;\n    if (_target < _origin + _border) _destination = floor(_target - _border);\n    else if (_target > _origin + _size - _border)\n        _destination = floor(_target - _size + _border);\n    var _moved = _speed < 0 ? _destination\n        : _origin + clamp(_destination - _origin, -_speed, _speed);\n    return min(max(_moved, 0), _room_size - _size);'
    if re.sub(r'\s+', '', axis) != re.sub(r'\s+', '', expected_axis):
        raise ValueError('Compiled default camera follow rule changed; deliberately review its native-derived model')
    qa = (snapshot / 'scripts/scr_gameplay_qa/scr_gameplay_qa.gml').read_text()
    if not re.search(r'cameraObservation\s*:\s*camera_qa_summary\(', qa) or 'camera_qa_fixture(' not in qa:
        raise ValueError('Compiled QA lacks real camera fixture/result integration')
    # This exact source-backed helper has no renderable animation. Preserve its
    # raw native imageIndex in reports/restoration checks, but do not promote
    # that otherwise unused outer-frame counter into logical gameplay state.
    helper = snapshot / 'objects/o_smoothcamera'
    if file_hash(helper / 'Step_0.gml') != SMOOTH_STEP_SHA256:
        raise ValueError('Smooth helper Step changed; deliberately review its source-derived convergence model')
    if not re.search(r'timing_create_depth\(\s*0\s*,\s*0\s*,\s*-100\s*,\s*o_smoothcamera\s*\)', camera):
        raise ValueError('Smooth diagnostic helper no longer starts at the source-bound0,0 position')
    yy = re.sub(r',\s*([}\]])', r'\1', (helper / 'o_smoothcamera.yy').read_text())
    resource = json.loads(yy)
    if resource.get('spriteId') is not None or resource.get('spriteMaskId') is not None:
        raise ValueError('Smooth helper gained a sprite/mask; review logical animation contract')
    for event in helper.glob('*.gml'):
        body = re.sub(r'/\*.*?\*/|//[^\n]*', '', event.read_text(), flags=re.S)
        if re.search(r'\b(?:image_index|sprite_index|mask_index)\b', body):
            raise ValueError('Smooth helper now uses animation/resources; review comparator')
    return bound


def common_record_errors(spec, result, summary, bound, run, native_log):
    """Retain every applicable timing binding check, without fictional setup.

    Only the exact one missing actor-probe-preparation error is discharged when
    both probe and preparation are absent. Any supplied setup remains rejected.
    This adapter fails closed if the shared prefix ever changes.
    """
    shared = record_errors(spec, result, summary, bound, run, native_log)
    preparation = preparation_errors(result)
    if result.get('diagnosticPreparation') is None and result.get('timingProbe') is None:
        expected = ['missing native timing preparation metadata']
        if preparation.errors != expected or preparation.count != 1 or shared.errors[:1] != expected:
            raise ValueError('Shared timing preparation prefix changed; review camera adapter')
        shared.errors = shared.errors[1:]
        shared.count -= 1
    shared.require(all(summary.get(k) is True for k in
                       ('headlessRequested', 'quietWindowRequested', 'backgroundLaunchRequested')),
                   'native camera run lacks quiet/background launch isolation')
    shared.require(result.get('drawEventsEnabled') is True and whole_number(result.get('drawCalls'), 1)
                   and result['drawCalls'] == result.get('renderFrames'),
                   'actual ordinary Draw count is missing or differs from separate rendering clock')
    return shared


def vector(value, size):
    return isinstance(value, list) and len(value) == size and all(finite(v) for v in value)


def matrix(value):
    return vector(value, 16) and any(v != 0 for v in value)


def transform(m, v):
    # Official matrix_get/matrix_build store columns consecutively (0..3,4..7).
    return [sum(m[row + col * 4] * v[col] for col in range(4)) for row in range(4)]


def projected_rect(matrices, rect):
    if not all(matrix(matrices.get(k)) for k in ('world', 'view', 'projection')) or not vector(rect, 4):
        raise ValueError('Incomplete actual Draw matrices/camera rectangle')
    x, y, w, h = rect
    points = []
    for px, py in ((x, y), (x + w, y), (x, y + h), (x + w, y + h)):
        point = [px, py, 0, 1]
        for key in ('world', 'view', 'projection'):
            point = transform(matrices[key], point)
        if not all(finite(v) for v in point) or abs(point[3]) < 1e-12:
            raise ValueError('Degenerate/nonfinite native homogeneous projection')
        points.append([point[0] / point[3], point[1] / point[3]])
    return points


def configured_native_errors(camera):
    """Validate genuine configured getters; never label them applied matrices."""
    audit = Audit()
    native = camera.get('configuredNative') if isinstance(camera, dict) else None
    if not audit.require(isinstance(native, dict), 'configured native camera getters are missing'):
        return audit
    audit.require(whole_number(native.get('schemaVersion'), 1) and native['schemaVersion'] == 1
                  and native.get('configuredOnly') is True and native.get('matrixValidity') in
                  {'first-use-provisional', 'prior-viewport-use-observed'}, 'configured getter schema/context differs')
    for field, operation in (('viewMatrix', 'camera_get_view_mat'),
                             ('projectionMatrix', 'camera_get_proj_mat'), ('updateScript', 'camera_get_update_script')):
        query = native.get(field)
        if not audit.require(isinstance(query, dict) and query.get('operation') == operation
                             and query.get('ok') is True and isinstance(query.get('nativeType'), str)
                             and bool(query['nativeType']), 'missing/failed typed native getter: ' + operation):
            continue
        if field != 'updateScript':
            # A real first-use provisional matrix can contain zeros. Preserve it
            # without claiming its viewport validity or using it for projection.
            audit.require(query.get('nativeType') == 'array' and vector(query.get('value'), 16),
                          'native configured matrix shape/type differs: ' + operation)
        else:
            none, owned = query.get('equalsNone'), query.get('equalsTimingCamera')
            audit.require(type(none) is bool and type(owned) is bool
                          and isinstance(query.get('nativeString'), str)
                          and ((none is True and owned is False and finite(query.get('value')) and query['value'] == -1)
                               or (none is False and owned is True and query.get('value') ==
                                   '@ref script(timing_camera_native_disabled)')),
                          'native callback comparisons/return disagree or leave the bounded default/owned fixture')
    return audit


def configured_camera(row):
    views = (row.get('configuredViews') or {}).get('views') or []
    return views[0].get('camera') if views and isinstance(views[0], dict) else None


def configured_restored(left, right):
    # First actual viewport use can change only this observer validity label.
    # Every actual getter value, type, callback, target and camera property stays
    # exact; neither configured snapshot is interpreted as an applied transform.
    if not isinstance(left, dict) or not isinstance(right, dict):
        return False
    a, b = copy.deepcopy(left), copy.deepcopy(right)
    for value in (a, b):
        if isinstance(value.get('configuredNative'), dict):
            value['configuredNative'].pop('matrixValidity', None)
    return exact(a, b)


def camera_axis(origin, size, border, speed, target, room_size):
    """Measured QA45 default-follow rule, source matched to the manual helper."""
    border = min(border, size / 2)
    goal = math.floor(target - border) if target < origin + border else (
        math.floor(target - size + border) if target > origin + size - border else origin)
    moved = goal if speed < 0 else origin + min(speed, max(-speed, goal - origin))
    return min(max(moved, 0), room_size - size)


def camera_descriptor(value, follow, audit, where):
    if not audit.require(isinstance(value, dict) and value.get('available') is True,
                         'missing actual/configured camera descriptor: ' + where):
        return
    audit.require(vector(value.get('view'), 4) and value['view'][2:] == [1024, 768]
                  and whole_number(value.get('cameraId'))
                  and finite(value.get('angle')) and value['angle'] == 0,
                  'camera geometry differs from the real calibration viewport: ' + where)
    merge(audit, configured_native_errors(value))
    target = value.get('target')
    wanted = 'o_player' if follow == 'direct' else 'o_smoothcamera'
    audit.require(isinstance(target, dict) and target.get('kind') in {'object', 'instance'}
                  and target.get('objectName') == wanted
                  and reference(target.get('rawRef'), target.get('kind', '')) is not None,
                  'camera follow target is unresolved or differs: ' + where)
    audit.require(exact(value.get('border'), [32, 32] if follow == 'direct' else [512, 384])
                  and exact(value.get('followSpeed'), [-1, -1] if follow == 'direct' else [-2, -2]),
                  'authored camera follow policy differs: ' + where)


def registry_errors(identities, samples):
    audit = Audit(); registry = {}
    if not audit.require(isinstance(identities, list) and len(identities) >= 3,
                         'camera actor registry binding missing'):
        return audit
    for index, entry in enumerate(identities):
        if not audit.require(isinstance(entry, dict), 'malformed camera actor registry entry'):
            continue
        native_id = actor_reference(entry.get('instanceId'))
        audit.require(native_id is not None and native_id not in registry
                      and whole_number(entry.get('registryId')) and entry['registryId'] == index
                      and entry.get('role') in ROLE_OBJECTS
                      and all(whole_number(entry.get(k), 1) for k in
                              ('firstTick', 'firstOuter', 'firstRoomGeneration')),
                      'missing/duplicate/nonsequential native actor registry identity')
        if native_id is not None:
            registry[native_id] = entry
    seen = set()
    for sample in samples:
        actors = sample.get('actors')
        if not isinstance(actors, list):
            continue  # actor_map reports the malformed list independently.
        for actor in actors:
            if not isinstance(actor, dict):
                continue
            native_id = actor_reference(actor.get('instanceId')); entry = registry.get(native_id)
            bound = audit.require(entry is not None and whole_number(actor.get('registryId'))
                          and actor.get('registryId') == entry['registryId'] and actor.get('role') == entry['role']
                          and entry['firstRoomGeneration'] == sample.get('roomGeneration')
                          and entry['firstTick'] <= sample.get('tickId', -1)
                          and entry['firstOuter'] <= sample.get('outerId', -1),
                          'sample actor is not bound to its real registry role/creation clock')
            if bound and native_id not in seen:
                audit.require(all(entry[k] == sample.get(v) for k, v in
                                  (('firstTick', 'tickId'), ('firstOuter', 'outerId'),
                                   ('firstRoomGeneration', 'roomGeneration'))),
                              'registry first observation clock differs from raw first appearance')
                seen.add(native_id)
    audit.require(seen == set(registry), 'declared registry actor has no raw native observation')
    return audit


def draw_camera_binding(row, configured_id, completed_uses, audit):
    actual = row.get('actualDraw')
    if not audit.require(isinstance(actual, dict), 'missing actual Draw camera'):
        return
    active = actual.get('activeCamera'); camera = actual.get('camera')
    audit.require(whole_number(active) and isinstance(camera, dict)
                  and whole_number(camera.get('cameraId')) and camera['cameraId'] == active == configured_id,
                  'actual active camera ID differs from descriptor/configured viewport')
    key = (row.get('roomGeneration'), active)
    prior = key in completed_uses
    validity = ('prior-viewport-use-observed' if prior else
                'first-viewport-use-completed' if row.get('phase') == 'view-draw-end' else 'first-use-provisional')
    audit.require(actual.get('priorViewportUseObserved') is prior
                  and actual.get('cameraMatrixValidity') == validity,
                  'camera first-use/past-viewport validity contradicts actual ordered Draw phases')
    if row.get('phase') == 'view-draw-end':
        completed_uses.add(key)


def input_mask(frame):
    mask = 0
    for event in INPUTS:
        if frame >= event['frame']:
            mask = event['mask']
    return mask


def actor_map(sample, audit, profile='qa43-moving-only'):
    actors = sample.get('actors')
    if not audit.require(isinstance(actors, list), 'sample actor list missing'):
        return {}
    mapped = {}
    for actor in actors:
        if not audit.require(isinstance(actor, dict), 'malformed actor observation'):
            continue
        native_id = actor_reference(actor.get('instanceId'))
        audit.require(native_id is not None and native_id not in mapped, 'missing/duplicate actual actor identity')
        audit.require(native_flag(actor.get('present')) is True and native_flag(actor.get('active')) is True
                      and actor.get('readSucceeded') is not False,
                      'initial camera scope contains absent/inactive/unreadable actors')
        role = actor.get('role')
        audit.require(role in ROLE_OBJECTS,
                      'unexpected lifecycle/actor role in initial camera scope')
        audit.require(actor.get('objectName') == ROLE_OBJECTS.get(role)
                      and reference(actor.get('objectId'), 'object') == ROLE_OBJECTS.get(role),
                      'native actor role/object binding differs')
        smooth = role == 'smooth-camera'
        audit.require(all(finite(actor.get(k)) for k in ACTOR_FIELDS if k in CONTINUOUS and k not in
                      {'bbox', 'spriteOrigin', 'maskOrigin', 'hsp', 'vsp'})
                      and vector(actor.get('bbox'), 4) and (smooth or
                      vector(actor.get('spriteOrigin'), 2) and vector(actor.get('maskOrigin'), 2))
                      and native_flag(actor.get('visible')) is not None,
                      'incomplete/nonfinite native actor pose/mask')
        audit.require(all(actor.get(k) is None or finite(actor[k]) for k in ('hsp', 'vsp'))
                      and all(finite(actor.get(k)) for k in ('xprevious', 'yprevious'))
                      and all(reference(actor.get(k), 'sprite') is not None for k in ('sprite', 'mask', 'effectiveMask'))
                      and (smooth or isinstance(actor.get('spriteName'), str) and isinstance(actor.get('maskName'), str))
                      and isinstance(actor.get('state'), dict), 'missing actor motion/resource/state binding')
        timing = actor.get('timing')
        if timing is not None:
            audit.require(isinstance(timing, dict) and all(finite(timing.get(k)) for k in
                          ('previousX', 'previousY', 'currentX', 'currentY', 'startX', 'startY',
                           'savedDrawX', 'savedDrawY', 'authoritativeSpeed', 'authoritativeDirection'))
                          and type(timing.get('interpolated')) is bool and type(timing.get('held')) is bool,
                          'native authoritative timing endpoints/flags are missing or malformed')
        if smooth:
            audit.require(all(reference(actor.get(k), 'sprite') == -1 for k in ('sprite', 'mask', 'effectiveMask'))
                          and all(actor.get(k) is None for k in ('spriteName', 'maskName', 'spriteOrigin', 'maskOrigin',
                                                                   'hsp', 'vsp'))
                          and (actor.get('timing') is None if profile == 'qa43-moving-only'
                               else isinstance(actor.get('timing'), dict))
                          and actor.get('speed') == 0 and exact(actor.get('bbox'),
                                                               [actor.get('x'), actor.get('y')] * 2),
                          'sprite-less smooth helper gained animation/mask/native movement semantics')
        if native_id is not None:
            mapped[native_id] = actor
    return mapped


def canonical_actor(actor):
    state = {k: v for k, v in actor['state'].items() if k != 'customskin_spr'}
    row = {k: actor.get(k) for k in ACTOR_FIELDS}
    if actor.get('role') == 'smooth-camera':
        row.pop('imageIndex')
    row['state'] = state
    attachment = actor.get('attachment')
    if isinstance(attachment, dict):
        row['worldDelta'] = attachment.get('worldDelta')
    return row


def float32(value):
    return struct.unpack('<f', struct.pack('<f', value))[0]


def expected_interpolation(actor, fps, alpha, profile='qa43-moving-only'):
    if profile not in INTERPOLATION_PREDICATES:
        raise ValueError('Unknown/unbound native interpolation predicate')
    native = actor.get('timing')
    eligible = (actor.get('hsp') is not None or actor.get('vsp') is not None or actor.get('speed') != 0
                or isinstance(native, dict) and native.get('authoritativeSpeed') != 0)
    if profile == 'explicit-followers-v1':
        if actor.get('role') in {'smooth-camera', 'equipped-gun'}:
            eligible = True
        if actor.get('role') == 'torch':
            state = actor.get('state') or {}
            # Source assigns these pickup flags numeric0/1. Read only those
            # exact boolean-compatible values; missing/malformed is unverified.
            flags = [state.get(k) for k in ('holding', 'died')]
            if not all(type(v) is bool or type(v) in (int, float) and v in (0, 1) for v in flags):
                raise ValueError('Torch holding/died predicate has no explicit source-compatible flags')
            eligible = eligible or any(v == 1 for v in flags)
    if eligible and not isinstance(native, dict):
        raise ValueError('Eligible moving actor lacks authoritative timing registration')
    if fps <= SIMULATION_HZ or not eligible:
        return False, [actor.get('x'), actor.get('y')]
    fields = ('previousX', 'previousY', 'currentX', 'currentY')
    if not all(finite(native.get(k)) for k in fields):
        raise ValueError('Eligible actor has no finite authoritative interpolation endpoints')
    if math.hypot(native['previousX'] - actor['x'], native['previousY'] - actor['y']) > 64:
        if actor.get('role') == 'smooth-camera' and profile == 'explicit-followers-v1':
            # The real sprite-less helper begins at0,0 and converges toward the
            # distant calibration player. The exact compiled >64px guard keeps
            # that authoritative helper pose, and the real60 comparator still
            # binds every logical helper position. This does not accept a
            # player/follower teleport, portal or third-torch/fire lifecycle.
            return False, [actor.get('x'), actor.get('y')]
        raise ValueError('Unexpected >64-pixel discontinuity; portal/wrap acceptance is outside initial scope')
    # Native built-in x/y storage rounds the double-precision GML lerp result to
    # IEEE754 binary32. Round that derived expectation once; never round or
    # normalize authoritative/restored observations or widen their tolerance.
    return True, [float32(native['previousX'] + (native['currentX'] - native['previousX']) * alpha),
                  float32(native['previousY'] + (native['currentY'] - native['previousY']) * alpha)]


def camera_draw_origin(previous, current, fps, alpha):
    if fps <= SIMULATION_HZ or math.dist(previous, current) > 64:
        return current
    return [float32(a + (b-a) * alpha) for a, b in zip(previous, current)]


def assess_draw_window(rows, follow, fps, audit, details, profile='qa43-moving-only', camera_history=None):
    by_phase = defaultdict(list)
    for row in rows:
        by_phase[row['phase']].append(row)
    pre = by_phase['pre-draw-authoritative'][0]
    lerped = by_phase['pre-draw-interpolated'][0]
    post = by_phase['post-draw-restored'][0]
    before_restore = by_phase['post-draw-before-restore'][0]
    audit.require(configured_restored(configured_camera(pre), configured_camera(post)),
                  'configured camera rectangle/matrices/callback were not restored exactly after actual Draw')
    details['configuredDrawRestorationChecks'] += 1
    pre_camera, lerped_camera = configured_camera(pre), configured_camera(lerped)
    if audit.require(camera_history is not None, 'camera Draw history lacks genuine logical End endpoints'):
        expected = camera_draw_origin(*camera_history, fps, lerped['alpha'])
        audit.require(exact(lerped_camera['view'], expected + pre_camera['view'][2:]),
                      'actual camera interpolation differs from previous/current endpoints and player alpha')
    before, during, after, tail = (actor_map(row, audit, profile) for row in (pre, lerped, post, before_restore))
    audit.require(before.keys() == during.keys() == after.keys(), 'actor lifecycle changed inside a native Draw window')
    audit.require(during.keys() == tail.keys() and all(all(exact(during[key].get(k), tail[key].get(k))
                  for k in RESTORE_FIELDS) for key in during.keys() & tail.keys()),
                  'ordinary Draw body changed interpolated actor pose/mask/input/state before restoration')
    for native_id in before.keys() & during.keys() & after.keys():
        a, b, c = before[native_id], during[native_id], after[native_id]
        audit.require(all(exact(a.get(k), c.get(k)) for k in RESTORE_FIELDS),
                      'post-Draw authoritative pose/mask/input/state was not restored exactly: ' + a['role'])
        native = a.get('timing')
        audit.require(native is None or native.get('interpolated') is False, 'pre-Draw pose was already interpolated')
        if isinstance(native, dict):
            audit.require(exact(native.get('currentX'), a['x']) and exact(native.get('currentY'), a['y']),
                          'authoritative timing current endpoint differs from actual pre-Draw pose')
        try:
            applied, expected = expected_interpolation(a, fps, lerped['alpha'], profile)
            audit.require(all(math.isclose(b[k], v, abs_tol=FLOAT_ABS, rel_tol=FLOAT_REL)
                              for k, v in zip(('x', 'y'), expected)),
                          'actual Draw pose does not match recorded endpoints/alpha: ' + a['role'])
            details['interpolation'][a['role'] + ('-applied' if applied else '-not-applied')] += 1
            if not applied and fps > SIMULATION_HZ and a['role'] == 'smooth-camera' and isinstance(native, dict) \
                    and all(finite(native.get(k)) for k in ('previousX', 'previousY')) \
                    and math.hypot(native['previousX'] - a['x'], native['previousY'] - a['y']) > 64:
                details['interpolation']['smooth-camera-source-64px-guard'] += 1
            if native is not None:
                bn, cn = b.get('timing'), c.get('timing')
                audit.require(isinstance(bn, dict) and isinstance(cn, dict)
                              and bn.get('interpolated') is applied and cn.get('interpolated') is False,
                              'interpolation/restoration flags differ from actual source eligibility')
                audit.require(all(exact(native.get(k), cn.get(k)) for k in
                              ('previousX', 'previousY', 'currentX', 'currentY', 'startX', 'startY',
                               'held', 'authoritativeSpeed', 'authoritativeDirection')),
                              'Draw changed authoritative timing fields')
                if applied:
                    audit.require(exact(bn.get('savedDrawX'), a['x']) and exact(bn.get('savedDrawY'), a['y'])
                                  and exact(cn.get('savedDrawX'), a['x']) and exact(cn.get('savedDrawY'), a['y']),
                                  'saved native Draw restoration pose differs')
            if a['role'] in {'equipped-gun', 'torch'}:
                for observed, peers in ((a, before), (b, during), (c, after)):
                    attachment = observed.get('attachment')
                    owner_id = actor_reference(attachment.get('sourceOwner')) if isinstance(attachment, dict) else None
                    owner = peers.get(owner_id)
                    audit.require(owner is not None and owner.get('role') == 'player'
                                  and vector(attachment.get('worldDelta'), 2)
                                  and all(math.isclose(v, observed[k] - owner[k], abs_tol=FLOAT_ABS, rel_tol=FLOAT_REL)
                                          for k, v in zip(('x', 'y'), attachment['worldDelta'])),
                                  'follower offset is not bound to actual owner/poses')
                if isinstance(a.get('attachment'), dict) and isinstance(b.get('attachment'), dict):
                    left, right = a['attachment'].get('worldDelta'), b['attachment'].get('worldDelta')
                    if vector(left, 2) and vector(right, 2):
                        details['followerOffsets'].append({'role': a['role'], 'simulationFrame': pre['simulationFrame'],
                            'drawId': pre['drawId'], 'interpolated': applied, 'authoritative': left, 'duringDraw': right,
                            'change': [right[i] - left[i] for i in range(2)]})
        except (ValueError, TypeError, KeyError) as error:
            audit.require(False, str(error))
    for row in rows:
        if row['phase'] not in DRAW_PHASES:
            continue
        actual = row.get('actualDraw')
        if not audit.require(isinstance(actual, dict) and actual.get('actualDrawContext') is True
                             and actual.get('viewport') == 0 and native_flag(actual.get('viewEnabled')) is True
                             and actual.get('matchesConfiguredCamera') is True,
                             'actual ordinary Draw camera/view binding missing'):
            continue
        camera_descriptor(actual.get('camera'), follow, audit, row['phase'])
        audit.require(exact(actual.get('camera', {}).get('view'), lerped_camera['view']),
                      'native ordinary Draw moved the camera after the recorded interpolation')
        mats, declared = actual.get('matrices'), actual.get('cameraMatrices')
        typed = audit.require(isinstance(mats, dict) and all(matrix(mats.get(k)) for k in ('world', 'view', 'projection')),
                              'missing/degenerate applied native Draw matrices')
        validity = actual.get('cameraMatrixValidity')
        audit.require(validity in {'first-use-provisional', 'first-viewport-use-completed', 'prior-viewport-use-observed'},
                      'camera first-use validity was lost/normalized')
        if typed:
            audit.require(all(math.isclose(v, e, abs_tol=FLOAT_ABS, rel_tol=FLOAT_REL)
                              for v, e in zip(mats['world'], IDENTITY)), 'unexpected native world transform in flat fixture')
        if validity == 'first-use-provisional':
            details['provisionalCameraSamples'] += 1
        elif typed:
            audit.require(isinstance(declared, dict) and all(matrix(declared.get(k)) for k in ('view', 'projection'))
                          and all(math.isclose(v, e, abs_tol=FLOAT_ABS, rel_tol=FLOAT_REL)
                                  for k in ('view', 'projection') for v, e in zip(mats[k], declared.get(k, [])))
                          and all(len(declared.get(k, [])) == 16 for k in ('view', 'projection')),
                          'configured camera matrices differ from actual applied Draw matrices')
            try:
                points = projected_rect(mats, actual['camera']['view'])
                audit.require(all(math.isclose(abs(v), 1, abs_tol=MATRIX_ABS, rel_tol=0)
                                  for point in points for v in point)
                              and len({tuple(round(v, 5) for v in point) for point in points}) == 4,
                              'applied matrices do not cover the configured native camera rectangle')
            except (ValueError, KeyError, TypeError) as error:
                audit.require(False, str(error))
        if row['phase'] == 'actor-draw':
            drawn = actor_map(row, audit, profile)
            audit.require(len(drawn) == 1, 'actor Draw copied other actors or omitted its caller')
            for native_id, actor in drawn.items():
                peer = during.get(native_id)
                audit.require(peer is not None and actor.get('snapshotOnly') is False
                              and actor.get('drawEntryObserved') is True
                              and all(exact(actor.get(k), peer.get(k)) for k in ('x', 'y', 'bbox', 'mask', 'state')),
                              'actual actor Draw entry differs from the interpolated pose/state')
        else:
            audit.require(row.get('actors') == [], 'per-view Draw redundantly copies the full actor registry')
    for role in ('player', 'equipped-gun'):
        present = {key for key, actor in during.items() if actor.get('role') == role and native_flag(actor.get('visible')) is True}
        entered = {actor_reference(actor.get('instanceId')) for row in by_phase['actor-draw']
                   for actor in row.get('actors', []) if isinstance(actor, dict) and actor.get('role') == role}
        audit.require(present == entered, 'native existing Draw hook coverage differs: ' + role)
    details['completeDrawWindows'] += 1


def observation_errors(spec, result, profile='qa43-moving-only'):
    audit = Audit(); merge(audit, request_errors(spec))
    audit.require(profile in INTERPOLATION_PREDICATES, 'native interpolation source model is missing/unknown')
    details = {'canonical': {}, 'logicalActors': {}, 'interpolation': Counter(), 'followerOffsets': [],
               'completeDrawWindows': 0, 'provisionalCameraSamples': 0, 'pendingFinalDraw': False,
               'supplementarySpriteLessAnimation': [], 'logicalCameras': {}, 'skippedRootSpatialChecks': 0,
               'configuredDrawRestorationChecks': 0, 'nextBeginCameraRestorationChecks': 0, 'logicalCameraMathChecks': 0}
    if not isinstance(spec, dict) or not isinstance(result, dict):
        audit.require(False, 'native camera request/runtime must be objects'); return audit, details
    audit.require(result.get('format') == 'tcc.gameplay-evidence' and whole_number(result.get('schemaVersion'), 1)
                  and result['schemaVersion'] == 1
                  and result.get('inputMaskVersion') == 2 and type(result.get('inputMaskVersion')) in (int, float),
                  'native gameplay/input evidence schema missing')
    audit.require(result.get('timingProbe') is None and result.get('diagnosticPreparation') is None,
                  'initial camera fixture must not contain actor-probe preparation')
    initial = result.get('initial')
    audit.require(isinstance(initial, dict) and initial.get('frame') == 0 and initial.get('paused') is False
                  and initial.get('x') == 1536 and initial.get('y') == 6972,
                  'actual initial calibration player is not bound to the source fixture')
    obs = result.get('cameraObservation')
    if not audit.require(isinstance(obs, dict), 'missing native camera observation'):
        return audit, details
    follow = (spec.get('cameraFixture') or {}).get('follow')
    audit.require(obs.get('format') == 'tcc.camera-observation' and whole_number(obs.get('schemaVersion'), 1)
                  and obs['schemaVersion'] == 2
                  and obs.get('verdict') == 'unassessed' and obs.get('recordingStarted') is True
                  and obs.get('spec') == spec.get('cameraObservation')
                  and obs.get('sourceIdentity') == result.get('sourceIdentity')
                  and obs.get('inputClock') == INPUT_CLOCK and whole_number(obs.get('simulationHz'), 1)
                  and obs['simulationHz'] == SIMULATION_HZ and whole_number(obs.get('renderCap'), 1)
                  and obs['renderCap'] == spec.get('fps'), 'camera observer schema/spec/source/clock binding differs')
    for key in ('samplesTruncated', 'identitiesTruncated', 'selectionTruncated', 'discoveryTruncated',
                'issuesTruncated', 'fixtureStartsTruncated'):
        audit.require(obs.get(key) is False, 'camera observation incomplete/truncated: ' + key)
    audit.require(all(whole_number(obs.get(k)) and obs[k] == 0 for k in
                      ('issueCount', 'readFailures', 'matrixFailures', 'droppedSamples'))
                  and obs.get('issues') == [], 'native camera observer recorded phase/read failures or dropped data')
    fixture = obs.get('fixture')
    audit.require(isinstance(fixture, dict) and fixture.get('kind') == 'native-camera-calibration-only'
                  and fixture.get('follow') == follow and fixture.get('geometry') == 'flat'
                  and exact(fixture.get('start'), [1536, 6972]) and fixture.get('floorY') == 7000
                  and fixture.get('gun') is True and fixture.get('torches') == 1
                  and all(fixture.get(k) is False for k in ('portals', 'wrap', 'zeroGravityCycle')),
                  'native fixture setup differs from the bounded real actors/geometry')
    starts = obs.get('fixtureStarts')
    audit.require(isinstance(starts, list) and len(starts) == 1 and isinstance(starts[0], dict)
                  and starts[0].get('simulationFrame') == 0 and starts[0].get('deaths') == 0
                  and actor_reference(starts[0].get('playerId')) is not None
                  and isinstance(starts[0].get('pickupIds'), list) and len(starts[0]['pickupIds']) == 2
                  and all(actor_reference(v) is not None for v in starts[0]['pickupIds']),
                  'missing native player/pickup creation or unexpected retry')
    samples = obs.get('samples')
    if not audit.require(isinstance(samples, list) and len(samples) > 0 and all(isinstance(v, dict) for v in samples),
                         'camera raw phase samples missing/malformed'):
        return audit, details
    identities = obs.get('identities')
    merge(audit, registry_errors(identities, samples))
    if isinstance(identities, list) and isinstance(starts, list) and len(starts) == 1 and isinstance(starts[0], dict):
        player_ids = [row.get('instanceId') for row in identities if isinstance(row,dict) and row.get('role') == 'player']
        helper_ids = [row.get('instanceId') for row in identities if isinstance(row,dict) and row.get('role') == 'smooth-camera']
        audit.require(player_ids == [starts[0].get('playerId')] and
                      (helper_ids == [starts[0].get('helperId')] if follow == 'smooth' else
                       helper_ids == [] and finite(starts[0].get('helperId')) and starts[0]['helperId'] == -4),
                      'fixture-created player/helper identities differ from the actual registry')
    groups = []; current = []; previous = None; counts = Counter()
    for row in samples:
        phase = row.get('phase'); counts[phase] += 1
        # Validate every raw boundary, including skipped roots. Logical-only
        # validation would miss a bad mask/read/lifecycle record on Begin.
        actor_map(row, audit, profile)
        audit.require(phase in PHASES and row.get('phaseIssues') == [], 'unknown/rejected native phase')
        audit.require(row.get('room') == 'r_gameplay_qa' and exact(row.get('roomSize'), [4096, 8192]),
                      'camera sample escaped the diagnostic room')
        stamp = all(whole_number(row.get(k), 1) for k in ('roomGeneration', 'tickId', 'outerId'))
        audit.require(stamp and whole_number(row.get('simulationFrame'))
                      and row['simulationFrame'] <= TICKS and whole_number(row.get('generatedDrawFrames'))
                      and finite(row.get('elapsedUs')) and row['elapsedUs'] >= 0
                      and finite(row.get('accumulatorUs')) and row['accumulatorUs'] >= 0
                      and finite(row.get('alpha')) and 0 <= row['alpha'] <= 1
                      and type(row.get('isTick')) is bool and type(row.get('drawScheduled')) is bool
                      and whole_number(row.get('renderCap'), 1) and row['renderCap'] == spec.get('fps')
                      and whole_number(row.get('nativeOuterHz'), 60) and row['nativeOuterHz'] <= 1000
                      and whole_number(row.get('inputMask')) and row['inputMask'] < 64,
                      'missing/malformed simulation/outer/Draw clock stamp')
        audit.require(type(row.get('qaStarted')) is bool and whole_number(row.get('nativeEventType'))
                      and whole_number(row.get('nativeEventNumber')), 'genuine native event/start markers are missing')
        event = {'root-begin': (3, 1), 'root-end': (3, 2),
                 'pre-draw-authoritative': (8, 76), 'pre-draw-interpolated': (8, 76),
                 'view-draw-begin': (8, 72), 'view-draw-end': (8, 73),
                 'post-draw-before-restore': (8, 77), 'post-draw-restored': (8, 77), 'actor-draw': (8, 0)}.get(phase)
        audit.require(event is not None and exact([row.get('nativeEventType'), row.get('nativeEventNumber')], list(event)),
                      'configured/ordinary Draw phase is not bound to its real registered native event')
        if finite(row.get('accumulatorUs')) and finite(row.get('alpha')):
            expected_alpha = min(1, max(0, row['accumulatorUs'] * SIMULATION_HZ / 1000000))
            audit.require(math.isclose(row['alpha'], expected_alpha, abs_tol=1e-12, rel_tol=0),
                          'native interpolation alpha differs from the recorded fixed60 accumulator')
        audit.require(type(row.get('drawContext')) is bool and row['drawContext'] is (phase in DRAW_PHASES)
                      and row.get('suppliedDrawContext') is row.get('drawContext'), 'ordinary Draw context was falsely supplied')
        if previous is not None:
            audit.require(row.get('elapsedUs', -1) >= previous.get('elapsedUs', math.inf)
                          and stamp and row['outerId'] >= previous.get('outerId', math.inf),
                          'raw observation wall/native outer order moved backward')
        key = (row.get('roomGeneration'), row.get('outerId'))
        if current and key != (current[0].get('roomGeneration'), current[0].get('outerId')):
            groups.append(current); current = []
        current.append(row); previous = row
        if phase not in DRAW_PHASES:
            configured = row.get('configuredViews')
            audit.require(row.get('actualDraw') is None and isinstance(configured, dict)
                          and native_flag(configured.get('enabled')) is True and configured.get('implicitDefault') is False
                          and isinstance(configured.get('views'), list) and len(configured['views']) == 8,
                          'configured views are missing or mislabeled as an applied Draw camera')
            if isinstance(configured, dict) and isinstance(configured.get('views'), list):
                for index, view in enumerate(configured['views']):
                    audit.require(isinstance(view, dict) and view.get('viewport') == index and native_flag(view.get('enabled')) is True
                                  and native_flag(view.get('visible')) is (index == 0) and view.get('configuredOnly') is True,
                                  'actual configured viewport order/policy differs')
                if configured['views']:
                    view = configured['views'][0]
                    audit.require(exact(view.get('port'), [0, 0, 1024, 768]), 'native viewport zero bounds differ')
                    camera_descriptor(view.get('camera'), follow, audit, phase)
    if current:
        groups.append(current)
    first = samples[0]
    audit.require(first.get('phase') == 'root-begin' and first.get('tickId') == obs.get('startTick')
                  and first.get('outerId') == obs.get('startOuter')
                  and first.get('simulationFrame') == obs.get('startSimulationFrame') == 0
                  and first.get('roomGeneration') == obs.get('startRoomGeneration')
                  and obs.get('startQaStarted') is first.get('qaStarted') is False
                  and first.get('isTick') is True and obs.get('startReason') == 'camera-fixture-first-complete-begin',
                  'first genuine complete camera Begin is missing or metadata was synthesized/deferred')
    audit.require(len({row.get('roomGeneration') for row in samples}) == 1, 'unexpected camera scene/retry transition')
    phase_counts = obs.get('phaseCounts')
    audit.require(isinstance(phase_counts, dict) and all(whole_number(v, 1) for v in phase_counts.values())
                  and exact(dict(counts), phase_counts) and whole_number(obs.get('closedOuterFrames'))
                  and obs['closedOuterFrames'] == len(groups) - 1,
                  'raw camera phase counts/frame closure differ from native summary')
    logical = {}; prior_outer = None; prior_tick = None; draw_ids = []; last_draw = None
    completed_camera_uses = set(); prior_camera = None; camera_history = None
    for index, rows in enumerate(groups):
        by = defaultdict(list)
        for row in rows:
            by[row.get('phase')].append(row)
        begin, end = by['root-begin'], by['root-end']
        pair = audit.require(len(begin) == len(end) == 1 and rows[0].get('phase') == 'root-begin'
                             and rows[1].get('phase') == 'root-end', 'missing/duplicate/reordered actual root phase pair')
        if not pair:
            continue
        b, e = begin[0], end[0]
        bc, ec = configured_camera(b), configured_camera(e)
        if prior_camera is not None:
            audit.require(configured_restored(prior_camera, bc), 'next native Begin did not retain exact restored camera getters/properties')
            details['nextBeginCameraRestorationChecks'] += 1
        prior_camera = ec
        if isinstance(bc, dict) and isinstance(ec, dict):
            target_role = 'player' if follow == 'direct' else 'smooth-camera'
            targets = [actor for actor in e.get('actors', []) if isinstance(actor, dict) and actor.get('role') == target_role]
            if audit.require(len(targets) == 1, 'logical camera target lacks a unique actual fixture actor'):
                expected = [camera_axis(bc['view'][i], bc['view'][i+2], bc['border'][i], bc['followSpeed'][i],
                                        targets[0][key], e['roomSize'][i]) for i, key in enumerate(('x', 'y'))]
                audit.require(exact(ec['view'], expected + bc['view'][2:]) if b['isTick'] else exact(ec['view'], bc['view']),
                              'actual camera End differs from measured fixed60 follow or changes on a skipped outer')
                callback = ((ec.get('configuredNative') or {}).get('updateScript') or {})
                audit.require(callback.get('equalsTimingCamera') is True, 'manual camera callback ownership was not observed')
                details['logicalCameraMathChecks'] += 1
                if b['isTick']:
                    # First ownership resets history to the new End rectangle.
                    camera_history = (ec['view'][:2] if camera_history is None else camera_history[1], ec['view'][:2])
        audit.require(all(exact(b.get(k), e.get(k)) for k in ('tickId', 'outerId', 'roomGeneration', 'isTick', 'simulationFrame')),
                      'root pair clock/scene identity differs')
        audit.require(whole_number(e.get('inputMask')) and e['inputMask'] ==
                      input_mask(e['simulationFrame'] - int(not b['isTick'])),
                      'actual root End input mask differs from the genuine fixed60 input timeline')
        if prior_outer is not None:
            audit.require(b['outerId'] == prior_outer + 1 and b['tickId'] == prior_tick + int(b['isTick']),
                          'missing native outer frame or logical tick in the raw observation')
        prior_outer, prior_tick = b['outerId'], b['tickId']
        if not b['isTick']:
            left, right = actor_map(b, audit, profile), actor_map(e, audit, profile)
            # Native animation tail/wrap callbacks belong to the timing probe's
            # phase-aware animation oracle. Do not infer their ownership here.
            # This camera scope independently checks physical/resource/state
            # hold, retaining all raw imageIndex observations unchanged.
            fields = tuple(k for k in RESTORE_FIELDS if k != 'imageIndex')
            audit.require(left.keys() == right.keys() and all(all(exact(left[key].get(k), right[key].get(k))
                          for k in fields) for key in left.keys() & right.keys()),
                          'skipped native root frame changed spatial/resource/input state')
            details['skippedRootSpatialChecks'] += 1
        if b['isTick']:
            frame = e['simulationFrame']
            audit.require(frame not in logical, 'duplicate logical authoritative End frame')
            actors = actor_map(e, audit, profile); roles = [actor.get('role') for actor in actors.values()]
            audit.require(roles.count('player') == 1 and roles.count('smooth-camera') == int(follow == 'smooth')
                          and all(roles.count(r) <= 1 for r in ('equipped-gun', 'torch')), 'logical actor role coverage differs')
            logical[frame] = {actor['role']: canonical_actor(actor) for actor in actors.values()}
            views = (e.get('configuredViews') or {}).get('views') or []
            camera = views[0].get('camera') if views and isinstance(views[0], dict) else None
            if isinstance(camera, dict):
                details['logicalCameras'][frame] = camera.get('view')
            helper = next((actor for actor in actors.values() if actor['role'] == 'smooth-camera'), None)
            if helper is not None:
                details['supplementarySpriteLessAnimation'].append({
                    'simulationFrame': frame, 'outerId': e['outerId'], 'imageIndex': helper['imageIndex'],
                    'reason': 'Native outer animation counter on source-bound sprite-less helper; unused by its code.'})
        drawn = len(rows) > 2
        if not drawn:
            if index == len(groups) - 1 and b['drawScheduled']:
                details['pendingFinalDraw'] = True
            else:
                audit.require(b['drawScheduled'] is False, 'scheduled native Draw window is missing')
            continue
        fixed = [row['phase'] for row in rows if row['phase'] != 'actor-draw']
        audit.require(fixed == list(BOUNDARY_ORDER), 'native interpolation/view/restoration boundaries are missing or reordered')
        if fixed != list(BOUNDARY_ORDER):
            continue
        draw_rows = rows[2:]
        draw_id = draw_rows[0].get('drawId')
        audit.require(whole_number(draw_id, 1) and all(row.get('drawId') == draw_id for row in draw_rows)
                      and all(row.get('simulationFrame') == e['simulationFrame'] + int(b['isTick']) for row in draw_rows),
                      'Draw sequence/simulation phase binding differs')
        draw_ids.append(draw_id)
        for row in draw_rows:
            expected_generated = draw_rows[0]['generatedDrawFrames'] + int(row['phase'] != 'pre-draw-authoritative')
            audit.require(row['generatedDrawFrames'] == expected_generated, 'actual generated Draw count changed outside interpolation hook')
            audit.require(exact(row.get('inputMask'), e.get('inputMask')), 'Draw changed the logical input mask')
            if row['phase'] in DRAW_PHASES:
                configured = draw_rows[0].get('configuredViews') or {}
                views = configured.get('views') or []
                camera = views[0].get('camera') if views and isinstance(views[0], dict) else None
                configured_id = camera.get('cameraId') if isinstance(camera, dict) else None
                draw_camera_binding(row, configured_id, completed_camera_uses, audit)
        if last_draw is not None:
            audit.require(draw_rows[0]['generatedDrawFrames'] == last_draw, 'generated Draw history was skipped/missing')
        last_draw = draw_rows[-1]['generatedDrawFrames']
        assess_draw_window(draw_rows, follow, spec['fps'], audit, details, profile, camera_history)
        prior_camera = configured_camera(draw_rows[-1])
    audit.require(draw_ids == list(range(1, len(draw_ids) + 1)) and len(draw_ids) > 0, 'actual Draw sequence is incomplete or duplicate')
    audit.require(set(logical) == set(range(TICKS)), 'authoritative logical camera window lacks the genuine initial complete tick')
    tail = obs.get('pendingTail'); last = groups[-1]
    expected_tail = {'outer': last[0].get('outerId'), 'generation': last[0].get('roomGeneration'),
                     'expectedDraw': last[0].get('drawScheduled'), 'drawStage': 0 if len(last) == 2 else 4,
                     'issuesIfClosedNow': ['missing-complete-draw-window'] if details['pendingFinalDraw'] else []}
    audit.require(exact(tail, expected_tail), 'final pending Draw is not explicitly and accurately represented')
    trace = result.get('trace')
    if isinstance(trace, list) and len(trace) == TICKS and all(isinstance(row, dict) for row in trace):
        helper_pose = [0, 0]
        for frame, actors in logical.items():
            player = actors.get('player', {})
            row = trace[int(frame)]
            audit.require(all(same(k, player.get(k), row.get(k)) for k in ('x', 'y', 'hsp', 'vsp', 'bbox')),
                          'native root authoritative End does not bind the real player trace at frame' + str(frame))
        details['canonical'] = {frame: {k: row.get(k) for k in TRACE_FIELDS} for frame, row in enumerate(trace)}
        if follow == 'smooth':
            for frame, row in enumerate(trace):
                if not all(finite(row.get(k)) for k in ('x','y')):
                    audit.require(False, 'missing real player trace for source-bound helper convergence'); break
                helper_pose = [float32(left + (row[key] - left) * .05) for left,key in zip(helper_pose,('x','y'))]
                helper = logical.get(frame, {}).get('smooth-camera')
                if frame >= 0:
                    audit.require(isinstance(helper,dict) and exact([helper.get('x'),helper.get('y')],helper_pose),
                                  'smooth helper is not source-bound initial0,0-to-real-player convergence at tick' + str(frame))
    roles_seen = {role for actors in logical.values() for role in actors}
    audit.require({'player', 'equipped-gun', 'torch'} <= roles_seen, 'ordinary inputs did not genuinely collect both follower pickups')
    details['logicalActors'] = logical
    details['interpolation'] = dict(details['interpolation'])
    details['outerFramesObserved'] = len(groups)
    details['cameraObservationStart'] = {k: obs.get(k) for k in ('startTick', 'startOuter', 'startSimulationFrame',
                                                                                  'startRoomGeneration', 'startQaStarted', 'startReason')}
    return audit, details


BOUNDARY_ORDER = ('root-begin', 'root-end', 'pre-draw-authoritative', 'pre-draw-interpolated',
                  'view-draw-begin', 'view-draw-end', 'post-draw-before-restore', 'post-draw-restored')


def png_dimensions(data):
    """Validate complete bounded native RGBA8 PNG bytes, without pixel acceptance."""
    if len(data) > 64 * 1024 * 1024 or data[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError('missing/oversized native PNG signature')
    offset = 8; chunks = []; compressed = bytearray(); width = height = None
    while offset < len(data):
        if offset + 12 > len(data):
            raise ValueError('truncated native PNG chunk header')
        size = struct.unpack('>I', data[offset:offset+4])[0]
        kind = data[offset+4:offset+8]; end = offset + 12 + size
        if end > len(data) or zlib.crc32(data[offset+4:end-4]) & 0xffffffff != struct.unpack('>I', data[end-4:end])[0]:
            raise ValueError('truncated native PNG chunk or invalid CRC')
        payload = data[offset+8:end-4]; chunks.append(kind)
        if kind == b'IHDR':
            if len(chunks) != 1 or size != 13:
                raise ValueError('duplicate/reordered native PNG dimensions')
            width,height,depth,color,compression,filters,interlace = struct.unpack('>IIBBBBB',payload)
            if not 1 <= width <= 4096 or not 1 <= height <= 4096 or (depth,color,compression,filters,interlace) != (8,6,0,0,0):
                raise ValueError('unsupported native capture dimensions/encoding; explicit decoder review required')
        elif kind == b'IDAT':
            compressed.extend(payload)
        elif kind == b'IEND':
            if size != 0 or end != len(data):
                raise ValueError('native PNG trailing data or malformed ending')
        offset = end
    if not chunks or chunks[0] != b'IHDR' or chunks[-1] != b'IEND' or not compressed or width is None:
        raise ValueError('incomplete native PNG header/image/ending')
    # One filter byte plus four RGBA bytes/pixel per noninterlaced scanline.
    expected = height * (1 + width * 4); decoder = zlib.decompressobj()
    decoded = decoder.decompress(compressed, expected + 1)
    if len(decoded) != expected or not decoder.eof or decoder.unused_data or decoder.unconsumed_tail:
        raise ValueError('partial/oversized native PNG image payload')
    if any(decoded[row * (1 + width*4)] > 4 for row in range(height)):
        raise ValueError('invalid native PNG scanline filter')
    return width, height


def capture_errors(spec, result, run):
    audit = Audit(); captures = result.get('nativeCaptures'); hashed = []
    audit.require(result.get('nativeCapturesTruncated') is False, 'native capture metadata is missing/truncated')
    if not audit.require(isinstance(captures, list), 'native capture array missing'):
        return audit, hashed
    wanted = spec.get('captureFrames', [])
    if not wanted:
        audit.require(not captures, 'native captures exist without requested Draw images')
        return audit, hashed
    directory = Path(run).resolve() / 'frames' if run is not None else None
    audit.require(directory is not None and spec.get('captureDirectory') == str(directory), 'native capture directory is not isolated in this run')
    restored = {(row.get('roomGeneration'), row.get('outerId')): row for row in
                (result.get('cameraObservation') or {}).get('samples', []) if isinstance(row, dict)
                and row.get('phase') == 'post-draw-restored'}
    names = set(); keys = set(); observed_frames = set()
    for item in captures:
        if not audit.require(isinstance(item, dict), 'malformed native capture metadata'):
            continue
        name = item.get('file'); frame = item.get('simulationFrame'); gen = item.get('roomGeneration')
        draw = item.get('drawId'); outer = item.get('outerId')
        typed = all(whole_number(v, 1) for v in (frame, gen, draw, outer, item.get('tickId')))
        expected = f'frame-{int(frame):06d}-generation-{int(gen)}-draw-{int(draw)}-outer-{int(outer)}.png' if typed else None
        audit.require(typed and name == expected and name not in names and (gen, draw, outer) not in keys
                      and item.get('context') == 'application-surface-at-qa-gui'
                      and item.get('room') == 'r_gameplay_qa' and frame in wanted,
                      'capture filename/clock/context is missing, reused or escapes scope')
        names.add(name); keys.add((gen, draw, outer)); observed_frames.add(frame)
        peer = restored.get((gen, outer))
        audit.require(peer is not None and peer.get('generatedDrawFrames') == draw
                      and peer.get('simulationFrame') == frame and peer.get('tickId') == item.get('tickId')
                      and exact(peer.get('alpha'), item.get('alpha')), 'GUI native capture is not bound to its actual restored Draw')
        if not typed or name != expected or directory is None:
            continue
        path = directory / name
        try:
            before = file_hash(path)
            width, height = png_dimensions(path.read_bytes())
            audit.require(width >= 1024 and height >= 768 and file_hash(path) == before,
                          'native captured image is partial or changed during assessment')
            hashed.append({'file': str(path), 'sha256': before, 'width': width, 'height': height,
                           'simulationFrame': frame, 'outerId': outer, 'generatedDrawId': draw})
        except (OSError, ValueError, zlib.error) as error:
            audit.require(False, 'missing/unreadable actual native capture: ' + str(error))
    actual_draws = {(row.get('roomGeneration'), row.get('generatedDrawFrames'), row.get('outerId'))
                    for row in restored.values() if row.get('simulationFrame') in wanted}
    audit.require(keys == actual_draws, 'requested actual Draw capture is missing or has no restored native phase')
    # A simulation tick may have no generated Draw. Its absent image is explicit
    # coverage information, not an invented screenshot or a fictional failure.
    return audit, hashed


def assess_record(spec, result, summary, bound=None, run=None, native_log=None):
    profile = bound.get('interpolationModel') if isinstance(bound, dict) else None
    audit, details = observation_errors(spec, result, profile)
    if all(isinstance(doc, dict) for doc in (spec, result, summary)):
        merge(audit, common_record_errors(spec, result, summary, bound, run, native_log))
        images, capture_hashes = capture_errors(spec, result, run)
        merge(audit, images); details['nativeCaptures'] = capture_hashes
        wanted = set(spec.get('captureFrames', []))
        drawn = {row.get('simulationFrame') for row in (result.get('cameraObservation') or {}).get('samples', [])
                 if isinstance(row, dict) and row.get('phase') == 'post-draw-restored'}
        details['nativeCaptureCoverage'] = {'requestedSimulationFrames': sorted(wanted),
            'capturedSimulationFrames': sorted({item['simulationFrame'] for item in capture_hashes}),
            'requestedSimulationFramesWithoutDraw': sorted(wanted - drawn),
            'noImageInventedForSuppressedDraw': True}
    else:
        audit.require(False, 'native request/runtime/summary must be objects')
    audit.require(isinstance(bound, dict) and run is not None and isinstance(native_log, str),
                  'native assessment requires rehashed build/run/log bindings; exports/fixtures cannot pass')
    if audit.count:
        details['canonical'] = {}; details['logicalActors'] = {}; details['logicalCameras'] = {}
    return {**details, 'passed': audit.count == 0, 'errors': audit.errors, 'errorCount': audit.count,
            'fps': spec.get('fps') if isinstance(spec, dict) else None,
            'follow': (spec.get('cameraFixture') or {}).get('follow') if isinstance(spec, dict)
                      and isinstance(spec.get('cameraFixture'), dict) else None,
            'sourceIdentity': result.get('sourceIdentity') if isinstance(result, dict) else None,
            'interpolationModel': profile,
            'spec': spec, 'visualAcceptance': False, 'scope': SCOPE}


def read_run(run, bound):
    run = Path(run).resolve(); names = ('spec.json', 'runtime.json', 'summary.json', 'runtime.log')
    try:
        before = {name: file_hash(run / name) for name in names}
        docs = [json.loads((run / name).read_text()) for name in names[:3]]
        record = assess_record(*docs, bound, run, (run / 'runtime.log').read_text(errors='replace'))
        after = {name: file_hash(run / name) for name in names}
        if before != after:
            raise ValueError('Raw native evidence changed during assessment')
        record.update(rawHashes=after, assessedNativeFiles=True)
    except (OSError, ValueError, TypeError, KeyError, AttributeError, IndexError) as error:
        record = {'passed': False, 'errors': ['missing/malformed/unbound native evidence: ' + str(error)],
                  'errorCount': 1, 'canonical': {}, 'logicalActors': {}, 'visualAcceptance': False,
                  'scope': 'no native camera conclusion'}
    record['run'] = str(run)
    return record


def compare_records(records):
    audit = Audit(); groups = defaultdict(list); camera_comparisons = []
    audit.require(len(records) >= 2, 'comparison requires actual native60 and150 recordings')
    for record in records:
        audit.require(record.get('passed') is True and record.get('assessedNativeFiles') is True
                      and isinstance(record.get('rawHashes'), dict) and len(record['rawHashes']) == 4,
                      'record lacks strict raw native/source/payload assessment')
        groups[record.get('follow')].append(record)
    for follow, peers in groups.items():
        audit.require(follow in FOLLOWS and sorted(peer.get('fps', -1) for peer in peers) == list(CAPS),
                      'each follow policy requires exactly one actual60 and one150 comparator')
        bases = [peer for peer in peers if peer.get('fps') == 60]
        if len(bases) != 1:
            continue
        base = bases[0]
        for record in peers:
            audit.require(record.get('sourceIdentity') == base.get('sourceIdentity'), 'source/executable/artifact/content changed across caps')
            fields = ('room', 'fixture', 'mode', 'inputClock', 'simulationHz', 'seed', 'expect',
                      'maxFrames', 'traceEvery', 'inputs', 'cameraFixture', 'cameraObservation', 'manualCameraCandidate')
            audit.require(all(exact(record.get('spec', {}).get(k), base.get('spec', {}).get(k)) for k in fields),
                          'submitted logical fixture/input/observation contract differs across caps')
            if record.get('passed') is not True or base.get('passed') is not True:
                continue
            for name, expected_frames in (('canonical', set(range(TICKS))), ('logicalActors', set(range(TICKS)))):
                left, right = base.get(name, {}), record.get(name, {})
                audit.require(set(left) == set(right) == expected_frames, 'actual logical comparator coverage missing: ' + name)
                for frame in set(left) & set(right):
                    audit.require(same('logical-state', left[frame], right[frame]),
                                  f'actual60 authoritative {name} differs {follow}/frame{frame}/render{record.get("fps")}')
            if record is not base:
                left, right = base.get('logicalCameras', {}), record.get('logicalCameras', {})
                audit.require(set(left) == set(right) == set(range(TICKS)),
                              'raw root-End configured camera comparison coverage is missing')
                differences = [{'simulationFrame': frame, 'render60View': left[frame],
                                'render150View': right[frame], 'delta': [r-l for l,r in zip(left[frame], right[frame])]}
                               for frame in sorted(set(left) & set(right)) if not exact(left[frame], right[frame])]
                audit.require(not differences, 'authoritative fixed60 camera rectangles differ across render caps')
                camera_comparisons.append({'follow': follow, 'equal': not differences,
                    'differingLogicalTicks': len(differences),
                    'maximumViewOriginDeltaPixels': max((abs(v) for item in differences for v in item['delta'][:2]), default=0),
                    'examples': differences[:32],
                    'largestDifference': max(differences, key=lambda item: max(abs(v) for v in item['delta'][:2]), default=None),
                    'interpretation': 'Actual manual fixed60 configured camera at authoritative root End; render caps must '
                        'retain the same rectangles. Complete Draw restoration remains separately checked; no visual acceptance.'})
    return {'passed': audit.count == 0, 'errors': audit.errors, 'errorCount': audit.count,
            'visualAcceptance': False, 'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ,
            'comparison': 'actual60 player trace and root-End logical actor state by input frame/role',
            'floatTolerance': 'Cross-cap continuous fields abs1e-6/rel1e-10; discrete fields and restoration exact. '
                              'Matrix corner tolerance1e-5 NDC (<0.006 pixels at1024px) accounts for native float projection.',
            'runs': [public_record(record) for record in records],
            'configuredCameraRootEndComparison': camera_comparisons,
            'pending': ['human/native pixel appearance and occlusion/clipping review',
                        'death/retry/third-torch fire and portal/wrap lifecycle',
                        'other rendering caps, original campaign and Lunar camera contexts'], 'scope': SCOPE}


def public_record(record):
    return {k: v for k, v in record.items() if k not in {'canonical', 'logicalActors', 'logicalCameras', 'spec'}}


def selfcheck():
    """Offline planner/rejection fixtures; no fabricated full native PASS."""
    count = 0
    for follow in FOLLOWS:
        for cap in CAPS:
            spec = specification(follow, cap, True)
            assert request_errors(spec).count == 0
            for mutate in (lambda s: s.pop('inputClock'), lambda s: s.pop('simulationHz'),
                           lambda s: s.update(mode='route'), lambda s: s.update(maxFrames=239),
                           lambda s: s.update(fps=75), lambda s: s.update(seed=True),
                           lambda s: s.pop('manualCameraCandidate'), lambda s: s.update(manualCameraCandidate=1),
                           lambda s: s['inputs'][1].update(mask=True), lambda s: s['inputs'][1].update(frame=30.5),
                           lambda s: s['cameraFixture'].update(torches=3), lambda s: s['cameraFixture'].update(portals=True),
                           lambda s: s.update(timingProbe={}), lambda s: s.update(cameraObservation=False),
                           lambda s: s['cameraObservation'].update(maxSamples=63),
                           lambda s: s['cameraCandidate'].update(verified=True), lambda s: s.update(captureClock='simulation')):
                bad = copy.deepcopy(spec); mutate(bad); assert request_errors(bad).count > 0; count += 1
            assert assess_record(spec, {}, {}).get('passed') is False; count += 1
    for bad in (None, [], False, {}):
        assert observation_errors(specification('direct', 60), bad)[0].count > 0; count += 1
    assert exact(False, 0) is False and exact({'holding': True}, {'holding': 1}) is False
    assert same('x', 1, 1 + 1e-8) and not same('mask', 1, 1 + 1e-8)
    for value in ([], [0] * 16, [1] * 15, [True] * 16, [math.nan] * 16):
        assert not matrix(value); count += 1
    # A mathematical orthographic schema fixture tests column-major evaluation;
    # it is never submitted as a native run or accepted as camera/pixel evidence.
    view = IDENTITY.copy(); view[12] = -100; view[13] = -200
    projection = [2/1024,0,0,0, 0,-2/768,0,0, 0,0,1,0, -1,1,0,1]
    corners = projected_rect({'world': IDENTITY, 'view': view, 'projection': projection}, [100,200,1024,768])
    assert corners == [[-1,1],[1,1],[-1,-1],[1,-1]]; count += 1
    assert compare_records([])['passed'] is False
    assert compare_records([{'passed':True,'follow':'direct','fps':60},
                            {'passed':True,'follow':'direct','fps':150}])['passed'] is False
    count += 2
    # Isolated, source-shaped phase/identity fixtures exercise the same helpers
    # as real assessment. They have no build/run/log binding and cannot qualify.
    uses = set()
    for phase, validity, prior in (('view-draw-begin', 'first-use-provisional', False),
                                  ('actor-draw', 'first-use-provisional', False),
                                  ('view-draw-end', 'first-viewport-use-completed', False),
                                  ('view-draw-begin', 'prior-viewport-use-observed', True)):
        row = {'phase': phase, 'roomGeneration': 2, 'actualDraw': {'activeCamera': 5100,
               'camera': {'cameraId': 5100}, 'priorViewportUseObserved': prior, 'cameraMatrixValidity': validity}}
        audit = Audit(); draw_camera_binding(row, 5100, uses, audit); assert audit.count == 0; count += 1
    for field, value in (('activeCamera', 5101), ('activeCamera', True), ('cameraMatrixValidity', 'first-use-provisional'),
                         ('priorViewportUseObserved', False), ('priorViewportUseObserved', 1)):
        bad = copy.deepcopy(row); bad['actualDraw'][field] = value
        audit = Audit(); draw_camera_binding(bad, 5100, uses.copy(), audit); assert audit.count > 0; count += 1
    entries = [{'registryId': i, 'instanceId': '@ref instance(' + str(100 + i) + ')', 'role': role,
                'firstTick': 1, 'firstOuter': 1, 'firstRoomGeneration': 2}
               for i, role in enumerate(('player', 'equipped-gun', 'torch'))]
    sample = {'tickId': 1, 'outerId': 1, 'roomGeneration': 2, 'actors': copy.deepcopy(entries)}
    assert registry_errors(entries, [sample]).count == 0; count += 1
    for mutate in (lambda e,s: e[1].update(instanceId=e[0]['instanceId']),
                   lambda e,s: e[1].update(registryId=0), lambda e,s: e[1].update(registryId=True),
                   lambda e,s: s['actors'][1].update(role='player'), lambda e,s: e[0].update(firstOuter=2),
                   lambda e,s: s['actors'].pop(), lambda e,s: s['actors'][0].update(instanceId='@ref instance(999)')):
        e, s = copy.deepcopy(entries), copy.deepcopy(sample); mutate(e,s)
        assert registry_errors(e, [s]).count > 0; count += 1
    actor = {k: 0 for k in ACTOR_FIELDS}; actor.update(x=10, y=20, speed=0, role='player', state={}, hsp=4, vsp=0,
        timing={'previousX': 6, 'previousY': 20, 'currentX': 10, 'currentY': 20, 'authoritativeSpeed': 0})
    applied, pose = expected_interpolation(actor, 150, .1)
    assert applied and pose == [struct.unpack('<f', struct.pack('<f', 6.4))[0],20]; count += 1
    assert expected_interpolation(actor, 60, .1) == (False,[10,20]); count += 1
    for mutate in (lambda a: a.update(timing=None), lambda a: a['timing'].pop('currentX'),
                   lambda a: a['timing'].update(previousX=-100), lambda a: a['timing'].update(previousX=True)):
        bad = copy.deepcopy(actor); mutate(bad)
        try:
            expected_interpolation(bad,150,.1)
        except ValueError:
            count += 1
        else:
            raise AssertionError('Malformed eligible native interpolation was accepted')
    left = canonical_actor(actor); actor['imageIndex'] = 5
    assert not same('logical-state', left, canonical_actor(actor)); count += 1
    actor['role'] = 'smooth-camera'; left = canonical_actor(actor); actor['imageIndex'] = 6
    assert same('logical-state', left, canonical_actor(actor)); count += 1
    for profile, predicate in INTERPOLATION_PREDICATES.items():
        source = ('function timing_interpolates_instance() {\n' + predicate + '\n}\n'
                  'function timing_native_active() {\n'
                  'if (object_index == o_smoothcamera || object_index == o_smoothcameraboss5) return true;\n}\n'
                  'if (global.renderfps <= TCC_SIM_HZ) return;\n'
                  'var _alpha = clamp(_t.accumulator_us * TCC_SIM_HZ / 1000000, 0, 1);\n'
                  'if (point_distance(_n.previous_x, _n.previous_y, x, y) > 64) continue;\n'
                  'x = lerp(_n.previous_x, _n.current_x, _alpha);\n'
                  'y = lerp(_n.previous_y, _n.current_y, _alpha);\n')
        checks, model = interpolation_source_errors(source)
        assert checks.count == 0 and model == profile; count += 1
        for before, after in (('speed != 0', 'speed != 1'), ('> 64', '> 65'),
                              ('global.renderfps <= TCC_SIM_HZ', 'global.renderfps < TCC_SIM_HZ'),
                              ('lerp(_n.previous_x, _n.current_x, _alpha)', 'lerp(x, _n.current_x, _alpha)')):
            assert interpolation_source_errors(source.replace(before, after))[0].count > 0; count += 1
    follower = copy.deepcopy(actor); follower.update(role='equipped-gun', hsp=None, vsp=None)
    assert expected_interpolation(follower,150,.1,'qa43-moving-only')[0] is False; count += 1
    assert expected_interpolation(follower,150,.1,'explicit-followers-v1')[0] is True; count += 1
    for role in ('torch', 'smooth-camera'):
        follower['role'] = role; follower['state'] = {'holding':1,'died':0}
        assert expected_interpolation(follower,150,.1,'explicit-followers-v1')[0] is True; count += 1
    for flags in ({'holding':False,'died':False}, {'holding':0.0,'died':0.0}):
        follower['role'] = 'torch'; follower['state'] = flags
        assert expected_interpolation(follower,150,.1,'explicit-followers-v1')[0] is False; count += 1
    for flags in ({}, {'holding':2,'died':0}, {'holding':'1','died':0}):
        follower['state'] = flags
        try:
            expected_interpolation(follower,150,.1,'explicit-followers-v1')
        except ValueError:
            count += 1
        else:
            raise AssertionError('Malformed follower predicate was accepted')
    follower['timing']['previousX'] = -100; follower['state'] = {'holding':1,'died':0}
    follower['role'] = 'smooth-camera'
    assert expected_interpolation(follower,150,.1,'explicit-followers-v1') == (False,[10,20]); count += 1
    for role in ('torch','equipped-gun'):
        follower['role'] = role
        try:
            expected_interpolation(follower,150,.1,'explicit-followers-v1')
        except ValueError:
            count += 1
        else:
            raise AssertionError('Follower teleport was accepted as helper convergence')
    def chunk(kind, data):
        return struct.pack('>I',len(data)) + kind + data + struct.pack('>I',zlib.crc32(kind+data) & 0xffffffff)
    header = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR',struct.pack('>IIBBBBB',1,1,8,6,0,0,0))
    png = header + chunk(b'IDAT',zlib.compress(b'\0\0\0\0\0')) + chunk(b'IEND',b'')
    assert png_dimensions(png) == (1,1); count += 1
    malformed_pngs = [b'', png[:7], png[:33], png[:-1], png+b'\0', png[:-12],
        png[:33]+chunk(b'IDAT',b'not-zlib')+chunk(b'IEND',b''),
        header+chunk(b'IDAT',zlib.compress(b'\0\0'))+chunk(b'IEND',b''),
        header+chunk(b'IDAT',zlib.compress(b'\5\0\0\0\0'))+chunk(b'IEND',b'')]
    for bad in malformed_pngs:
        try:
            png_dimensions(bad)
        except (ValueError,zlib.error):
            count += 1
        else:
            raise AssertionError('Malformed/partial capture PNG was accepted')
    return {'status': 'offline planner/math/phase/identity/malformed/export rejection checks only', 'fixtures': count,
            'nativeLaunches': 0, 'nativeAcceptanceEstablished': False, 'visualAcceptance': False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    generate = sub.add_parser('generate', help='Write NEW UNVERIFIED requests; no native launch')
    generate.add_argument('--output', type=Path, required=True)
    generate.add_argument('--captures', action='store_true')
    sub.add_parser('selfcheck', help='Offline planner and rejection checks only')
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
            raise ValueError('Keep new unverified requests outside the checkout')
        output.mkdir(parents=True, exist_ok=False)
        for follow in FOLLOWS:
            for cap in CAPS:
                request = specification(follow, cap, args.captures)
                with (output / f'{follow}-{cap}.json').open('x') as stream:
                    stream.write(json.dumps(request, indent=2) + '\n')
        print(json.dumps({'status': 'NEW UNVERIFIED requests only', 'count': 4, 'nativeLaunches': 0,
                          'maxFrames': TICKS, 'inputClock': INPUT_CLOCK, 'simulationHz': SIMULATION_HZ,
                          'output': str(output)}, indent=2)); return 0
    try:
        bound = binding(args.build)
        records = [read_run(run, bound) for run in args.runs]
        report = compare_records(records) if args.command == 'compare' else {
            'passed': all(record['passed'] for record in records), 'binding': bound,
            'crossCapAcceptance': False, 'visualAcceptance': False, 'runs': [public_record(record) for record in records]}
    except (OSError, ValueError, TypeError, KeyError, RuntimeError) as error:
        report = {'passed': False, 'visualAcceptance': False,
                  'errors': ['native build binding unavailable/invalid: ' + str(error)]}
    if args.output:
        output = args.output.resolve()
        if output == ROOT or ROOT in output.parents:
            raise ValueError('Keep native observation reports outside the checkout')
        output.parent.mkdir(parents=True, exist_ok=True)
        with output.open('x') as stream:
            stream.write(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
