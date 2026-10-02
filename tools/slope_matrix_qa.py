#!/usr/bin/env python3
"""Run slope geometry/animation at fixed 60 Hz with independent render caps.

Only this CLI launches apps. Verification requires explicit request, runtime
and summary clocks; historical frame-indexed proofs never qualify implicitly.
"""
import argparse
import contextlib
import io
import json
from pathlib import Path

from gameplay_qa import run
from slope_qa import COLOURS, FPS, LOWER, UPPER, specification, verify, write_request


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--fps', nargs='+', type=int, choices=FPS, default=FPS,
                        help='Render caps; every fixture uses identical 60 Hz input ticks')
    parser.add_argument('--colour', nargs='+', choices=COLOURS, default=COLOURS)
    parser.add_argument('--build-snapshot', action='store_true')
    parser.add_argument('--local-multiplayer', action='store_true')
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
    for fps in rates:
        for colour in args.colour:
            for orientation in range(4):
                for scenario in LOWER if orientation < 2 else UPPER:
                    name = f'{colour}-{orientation}-{scenario}-{fps}'
                    spec = requests / (name + '.json')
                    request = specification(COLOURS.index(colour), orientation, scenario, fps)
                    if args.local_multiplayer:
                        request['actor'] = 'local-multiplayer'
                    write_request(spec, request)
                    target = args.output / name
                    with contextlib.redirect_stdout(io.StringIO()):
                        run(args.build, spec, target, args.build_snapshot, headless=args.headless)
                    summary = json.loads((target / 'summary.json').read_text())
                    if summary['status'] == 'crash-or-no-evidence':
                        raise RuntimeError(f'Native failure; inspect {target}')
                    report = verify(target, args.build)
                    report.update(run=str(target.resolve()))
                    reports.append(report)
                    (args.output / 'matrix-report.json').write_text(json.dumps(reports, indent=2) + '\n')
                    if not report['passed'] or len(reports) % 10 == 0:
                        print(f"{len(reports)} checked; {sum(r['passed'] for r in reports)} passed; "
                              f"last={name} errors={report['errors']}", flush=True)
                    if not report['passed']:
                        return 1
                    key = (colour, orientation, scenario)
                    groups.setdefault(key, []).append(target)
                    if len(groups[key]) > 1:
                        from motion_qa import compare
                        comparison = compare([groups[key][0], target], args.build)
                        comparisons.append(comparison)
                        (args.output / 'matrix-comparisons.json').write_text(json.dumps(comparisons, indent=2) + '\n')
                        if not comparison['passed']:
                            print(f'{name}: native state comparison FAIL {comparison["errors"]}', flush=True)
                            return 1
    (args.output / 'comparison-status.json').write_text(json.dumps({
        'baselineRenderCap': 60, 'crossCapCompared': len(rates) > 1,
        'comparisonCount': len(comparisons), 'qualifiesAsAuthoredContent': False}, indent=2) + '\n')
    return 0 if all(report['passed'] for report in reports) else 1


if __name__ == '__main__':
    raise SystemExit(main())
