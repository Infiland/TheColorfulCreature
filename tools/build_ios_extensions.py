#!/usr/bin/env python3
"""Rebuild the tagged extension sources for iOS 15; output stays outside the repo.

The distributed 2.0.2 binaries have higher deployment targets than their source
and AdMob's simulator binary still references the removed GADSimulatorID symbol.
Requires the exported game's installed CocoaPods dependencies and DEVELOPER_DIR.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def run(*args):
    subprocess.run([str(a) for a in args], check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pods', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    output = args.output.expanduser().resolve()
    if output == ROOT or ROOT in output.parents:
        parser.error('Keep outputs outside the repository')
    output.mkdir(parents=True, exist_ok=True)
    evidence = {'minimum_ios': '15.0', 'xcode': subprocess.check_output(['xcodebuild', '-version'], text=True).strip(), 'libraries': {}}
    for name in ['GMAdMob', 'GMGameCenter']:
        source = ROOT / 'extensions' / name / 'source'
        sources = sorted((source / 'code_gen/core').glob('*.cpp')) + sorted((source / 'code_gen/ios').glob('*.mm')) + sorted((source / 'src/ios').glob('*.mm'))
        headers = output / name / 'Headers'
        headers.mkdir(parents=True, exist_ok=True)
        for header in [source / 'src/ios' / f'{name}_ios.h', source / 'code_gen/ios' / f'{name}Internal_ios.h']:
            shutil.copy2(header, headers / header.name)
        libraries = []
        for sdk, target, slice_name in [('iphoneos', 'arm64-apple-ios15.0', 'ios-arm64'), ('iphonesimulator', 'arm64-apple-ios15.0-simulator', 'ios-arm64_x86_64-simulator')]:
            build = output / name / sdk
            build.mkdir(parents=True, exist_ok=True)
            sysroot = subprocess.check_output(['xcrun', '--sdk', sdk, '--show-sdk-path'], text=True).strip()
            flags = ['-target', target, '-isysroot', sysroot, '-std=c++17', '-O2', '-g', '-fPIC', '-DOS_IOS', '-DEXTGEN_HAS_JNI=0', '-DEXTGEN_APPLE_NATIVE_FW=0', '-I', source / 'code_gen', '-I', source / 'code_gen/core']
            # These tagged SDKs embed different versions of ExtUtils. Static linking
            # must not coalesce their C++ globals or their native initialization tables.
            flags += [f'-Dgm=tcc_{name}', f'-DGMExtensionInitialise=TCC_{name}_Initialise',
                      f'-DYYExtensionInitialise=TCC_{name}_YYInitialise']
            if name == 'GMAdMob':
                for framework in ['GoogleMobileAds', 'UserMessagingPlatform']:
                    matches = list(args.pods.rglob(f'{framework}.xcframework/{slice_name}/{framework}.framework'))
                    if len(matches) != 1:
                        raise RuntimeError(f'Expected one {framework} slice under {args.pods}, found {matches}')
                    flags += ['-F', matches[0].parent]
            objects = []
            for src in sources:
                obj = build / (src.stem + '.o')
                run('xcrun', '--sdk', sdk, 'clang++', *flags, *(['-fobjc-arc'] if src.suffix == '.mm' else []), '-c', src, '-o', obj)
                objects.append(obj)
            library = build / f'lib{name}.a'
            run('xcrun', 'libtool', '-static', '-o', library, *objects)
            libraries += ['-library', library, '-headers', headers]
            evidence['libraries'][f'{name}/{sdk}'] = hashlib.sha256(library.read_bytes()).hexdigest()
        framework = output / f'{name}.xcframework'
        if framework.exists():
            shutil.rmtree(framework)
        run('xcodebuild', '-create-xcframework', *libraries, '-output', framework)
    (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')


if __name__ == '__main__':
    main()
