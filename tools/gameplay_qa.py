#!/usr/bin/env python3
"""Run input-only witnesses through the native QA build, with isolated per-run saves.

Example spec: {"room":"r_gameplay_qa","fps":60,"inputClock":"simulation-60",
"simulationHz":60,"seed":1,"expect":"frames",
"maxFrames":180,"inputs":[{"frame":30,"mask":6},{"frame":31,"mask":2}]}
Shared input-mask contract: left=1, right=2, jump=4, interact=8, restart=16,
pause=32. Masks are whole numbers from 0 to 63; events set the complete held
state. Pause acts on a rising edge through normal player_pause_pressed(), so
release bit32 before another pause/resume press. Input recording includes
logical ticks while paused or without a live player.
Input indices and frame limits count fixed 60Hz simulation ticks; fps is a render cap.
An 'observed' calibration result never qualifies as a completed level.
"""
import argparse
import base64
import hashlib
import json
import math
import os
import re
import statistics
from pathlib import Path

from tcc_project import ROOT, source_identity, level_content_identity, artifact_identity
from native_runner import run_native
from native_evidence import compress_completed_runtime

INPUT_CLOCK = 'simulation-60'
SIMULATION_HZ = 60
RENDER_COMPARISON_FPS = (30, 60, 75, 100, 120, 144, 150, 237)
# Normative action bits for requests, native recordings and exported replays.
INPUT_BITS = {'left': 1, 'right': 2, 'jump': 4, 'interact': 8, 'restart': 16, 'pause': 32}
INPUT_MASK_MAX = sum(INPUT_BITS.values())


def whole_number(value, minimum=0):
    return (type(value) in (int, float) and math.isfinite(value)
            and int(value) == value and value >= minimum)


def clock_errors(document, label='request'):
    """Legacy evidence has no implicit clock and cannot qualify as normalized."""
    errors = []
    if document.get('inputClock') != INPUT_CLOCK:
        errors.append(f'{label}: missing/wrong inputClock (requires {INPUT_CLOCK})')
    if not whole_number(document.get('simulationHz'), 1) or document['simulationHz'] != SIMULATION_HZ:
        errors.append(f'{label}: missing/wrong simulationHz (requires {SIMULATION_HZ})')
    return errors


def require_fixed_clock(*documents):
    errors = [error for label, document in documents for error in clock_errors(document, label)]
    if errors:
        raise ValueError('; '.join(errors))


def simulation_count_errors(result):
    errors = []
    if not whole_number(result.get('frames')):
        errors.append('runtime: frames must count whole simulation ticks')
    if (not whole_number(result.get('simulationFrames'))
            or result['simulationFrames'] != result.get('frames')):
        errors.append('runtime: missing/wrong simulationFrames alias of frames')
    if not whole_number(result.get('renderFrames')):
        errors.append('runtime: missing/wrong separate renderFrames count')
    return errors


def proof_clock_errors(spec, result, summary):
    errors = [error for label, document in [('request', spec), ('runtime', result), ('summary', summary)]
              for error in clock_errors(document, label)]
    errors.extend(simulation_count_errors(result))
    if summary.get('clockVerified') is not True:
        errors.append('summary: fixed60 clock was not verified')
    for field in ('frames', 'simulationFrames', 'renderFrames'):
        if not whole_number(summary.get(field)) or summary[field] != result.get(field):
            errors.append(f'summary: missing/wrong {field} binding')
    return errors


def launch_timeout(spec):
    """The render cap never changes the duration of a simulation-tick budget."""
    require_fixed_clock(('request', spec))
    ticks = spec.get('maxFrames', SIMULATION_HZ * 180)
    if not whole_number(ticks, 1):
        raise ValueError('maxFrames must be a positive whole simulation-tick count')
    limit = ticks / SIMULATION_HZ * 2 + 45
    if 'wallTimeoutSeconds' in spec:
        requested = spec['wallTimeoutSeconds']
        if type(requested) not in (int, float) or not math.isfinite(requested) or not 1 <= requested <= 7200:
            raise ValueError('wallTimeoutSeconds must be a finite value from 1 to 7200')
        limit = max(limit, requested)
    return limit


def observed_render_fps(result):
    # Ignore bootstrap rendering; input/simulation-step deltas are a different
    # clock and cannot provide a fallback measurement of rendering cadence.
    stable = result.get('renderFrameDeltasUs', [])[1:]
    mean_delta = statistics.mean(stable) if stable else 0
    return 1e6 / mean_delta if mean_delta > 0 else None


def validate_input_events(events):
    if not isinstance(events, list):
        raise ValueError('Inputs must be an ordered array')
    previous = -1
    for event in events:
        if not isinstance(event, dict):
            raise ValueError('Each input event must contain frame and mask numbers')
        values = [event.get('frame'), event.get('mask')]
        if any(type(value) not in (int, float) or not math.isfinite(value) or int(value) != value
               for value in values):
            raise ValueError('Input frame and mask must be finite integers')
        frame, mask = values
        if frame <= previous or frame < 0 or not 0 <= mask <= INPUT_MASK_MAX:
            raise ValueError(f'Input frames must increase strictly and masks must be from 0 to {INPUT_MASK_MAX}')
        previous = frame


def run(build, spec_path, output, build_snapshot=False, visible=False, headless=False):
    build = build.resolve()
    output = output.resolve()
    if output == ROOT or ROOT in output.parents:
        raise ValueError('Keep runtime logs and diagnostic saves outside the checkout')
    output.mkdir(parents=True, exist_ok=False)
    evidence = json.loads((build / 'evidence.json').read_text())
    if evidence['configuration'] != 'QA':
        raise ValueError('Gameplay recording requires the isolated QA configuration')
    executable = build / 'DerivedData/Build/Products/Release/The_Colorful_Creature.app/Contents/MacOS/The_Colorful_Creature'
    binary_hash = hashlib.sha256(executable.read_bytes()).hexdigest()
    if binary_hash != evidence['executable_sha256']:
        raise ValueError('Executable no longer matches its build evidence')
    bundle_identity = evidence.get('artifact_identity')
    payload_verified = bool(bundle_identity)
    if bundle_identity and artifact_identity(executable.parents[2]) != bundle_identity:
        raise ValueError('Compiled payload no longer matches its build evidence')
    identity = evidence.get('source_identity')
    if not identity:
        raise ValueError('Build has no source identity')
    spec = json.loads(spec_path.read_text())
    limit = launch_timeout(spec)
    validate_input_events(spec.get('inputs', []))
    route_start = spec.get('routeStartFrame', 0)
    if type(route_start) is not int or route_start < 0:
        raise ValueError('routeStartFrame must be a nonnegative whole frame')
    if route_start and (spec.get('mode') != 'route'
                        or any(event['frame'] >= route_start for event in spec.get('inputs', []))):
        raise ValueError('A route input prefix must end before routeStartFrame')
    if type(spec['fps']) is not int or not 30 <= spec['fps'] <= 1000:
        raise ValueError('FPS must be a whole number from 30 to 1000')
    content_root = Path(evidence.get('source_snapshot') or ROOT)
    content_hash = level_content_identity(spec, content_root)
    if not build_snapshot and (source_identity()['physicsSha256'] != identity['physicsSha256']
                               or level_content_identity(spec) != content_hash):
        raise ValueError('Playable source changed since this build; rebuild before recording evidence')
    spec.update(output=str(output / 'runtime.json'), saveRoot=str(output / 'saves'),
                identity={**identity, 'executableSha256': binary_hash, 'levelContentSha256': content_hash,
                          'artifactSha256': bundle_identity['sha256'] if bundle_identity else None})
    if spec.get('captureFrames'):
        if len(spec['captureFrames']) > 240 or any(not isinstance(f, int) or f < 0 for f in spec['captureFrames']):
            raise ValueError('Use at most 240 nonnegative capture frames')
        spec['captureDirectory'] = str(output / 'frames')
        (output / 'frames').mkdir()
    if spec.get('galleryPreview'):
        spec['galleryOutput'] = str(output / 'gallery')
        (output / 'gallery').mkdir()
    (output / 'saves').mkdir()
    if spec.get('cosmeticFixtures'):
        if spec['cosmeticFixtures'] is not True:
            raise ValueError('cosmeticFixtures must be a boolean')
        # Copy the existing native self-check PNG bytes into this run's profile.
        # Do not synthesize new art or read/write a real user's custom folders.
        fixture_source = (content_root / 'scripts/scr_cosmetics/scr_cosmetics.gml').read_text()
        spec['cosmetics'] = {}
        for kind, folder in [('skin', 'Player Skins'), ('hat', 'Player Hats'), ('item', 'Player Items')]:
            match = re.search(r'var _' + kind + r'_data = "([A-Za-z0-9+/=]+)";', fixture_source)
            if not match:
                raise ValueError('Missing native cosmetic fixture: ' + kind)
            name = 'qa-' + kind + '.png'
            destination = output / 'saves' / 'Custom' / folder / name
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(base64.b64decode(match[1], validate=True))
            spec['cosmetics'][kind] = name
    actual_spec = output / 'spec.json'
    actual_spec.write_text(json.dumps(spec, indent=2) + '\n')
    process_report = run_native(executable, output / 'runtime.log', limit,
                                env=dict(os.environ, TCC_QA_SPEC=str(actual_spec)),
                                arguments=['--tcc-qa=' + str(actual_spec)], visible=visible, headless=headless)
    ended_normally = process_report['normalRuntimeEnd']
    current_identity = source_identity()
    content_matches = (current_identity['physicsSha256'] == identity['physicsSha256']
                       and level_content_identity(spec) == content_hash)
    report = {'executableSha256': binary_hash, 'sourceIdentity': identity,
              'requestedRenderFps': spec['fps'], 'requestedInputClock': spec['inputClock'],
              'requestedSimulationHz': spec['simulationHz'],
              'levelContentSha256': content_hash, 'matchesCurrentPlayableContent': content_matches,
              'compiledPayloadVerified': payload_verified, 'compilerBackend': evidence.get('compiler_backend', 'YYC'),
              **process_report,
              'matchesCurrentSource': current_identity == identity}
    runtime_file = output / 'runtime.json'
    if runtime_file.is_file():
        result = json.loads(runtime_file.read_text())
        report.update(status=result['status'], reason=result['reason'], frames=result['frames'],
                      deaths=result['deaths'], bounds=result['bounds'], muted=result.get('muted', False))
        clock_issues = clock_errors(result, 'runtime') + simulation_count_errors(result)
        report.update(inputClock=result.get('inputClock'), simulationHz=result.get('simulationHz'),
                      clockVerified=not clock_issues, clockErrors=clock_issues,
                      simulationFrames=result.get('simulationFrames', result['frames']),
                      renderFrames=result.get('renderFrames'), nativeElapsedUs=result.get('elapsedUs'))
        # Render pacing is observed independently. Simulation-step deltas must
        # never masquerade as a measurement of the rendering cap.
        costs = result['stepCostsUs']
        report['observedRenderFps'] = observed_render_fps(result)
        report['observedFps'] = report['observedRenderFps']
        report['stepCostMedianUs'] = statistics.median(costs) if costs else None
        report['stepCostP95Us'] = sorted(costs)[int((len(costs)-1)*.95)] if costs else None
        report['qualifiesAsCompletion'] = (ended_normally and payload_verified and not clock_issues
            and result.get('fps') == spec['fps'] and result['status'] == 'complete'
            and spec.get('mode', 'replay') == 'replay'
            and not result.get('diagnosticOnly', False)
            and result['normalRules'] and result['deaths'] == 0 and result.get('completion') is not None
            and result['sourceIdentity'] == spec['identity'] and content_matches)
        if ended_normally:
            report['evidenceStorage'] = compress_completed_runtime(runtime_file)
    else:
        report.update(status='crash-or-no-evidence', qualifiesAsCompletion=False)
    (output / 'summary.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2), flush=True)
    return ended_normally and report.get('clockVerified', False) and report['status'] in ['complete', 'observed']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--spec', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--build-snapshot', action='store_true',
                        help='Measure a frozen build while source changes; stale evidence never qualifies for current content')
    parser.add_argument('--visible', action='store_true', help='Keep the diagnostic window visible for visual inspection')
    parser.add_argument('--headless', action='store_true', help='Pass -headless to the native runner; Mac also requests a hidden background launch')
    args = parser.parse_args()
    raise SystemExit(0 if run(args.build, args.spec, args.output, args.build_snapshot, args.visible, args.headless) else 1)


if __name__ == '__main__':
    main()
