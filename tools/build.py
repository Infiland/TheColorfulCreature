#!/usr/bin/env python3
"""Reproducible GameMaker exports. Native diagnostic builds are not store archives."""
import argparse
import hashlib
import json
import os
import plistlib
import re
import shutil
import zipfile
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = '2026.0.0.23'
IDE = '2026.0.0.16'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('configuration', choices=['Steam', 'Apple', 'MacAppStore', 'iOS', 'iOSCheck', 'Android', 'AndroidRelease', 'Check'])
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--native-diagnostic', action='store_true')
    parser.add_argument('--self-check', action='store_true')
    parser.add_argument('--mac-store-sign-embedded', action='store_true',
        help='Pre-sign generated Mac App Store dylibs with TCC_MAC_DEVELOPMENT_IDENTITY before archiving')
    parser.add_argument('--clean', action='store_true', help='Discard generated compiler caches before export')
    args = parser.parse_args()
    output = args.output.expanduser().absolute()
    if output.resolve() == ROOT or ROOT in output.resolve().parents:
        parser.error('Keep build outputs outside the checkout')
    if args.self_check and (not args.native_diagnostic or args.configuration != 'Check'):
        parser.error('--self-check requires Check --native-diagnostic')
    if args.self_check and output != output.resolve():
        parser.error('Use a real, non-symlink output path for Mac runtime checks, such as ~/Library/Caches/TCCPort/check')
    if args.mac_store_sign_embedded and args.configuration != 'MacAppStore':
        parser.error('--mac-store-sign-embedded requires MacAppStore')
    output.mkdir(parents=True, exist_ok=True)
    if args.clean:
        for name in ['cache', 'temp', 'export']:
            if (output / name).exists():
                shutil.rmtree(output / name)
    product_dir = output / 'export'
    product_dir.mkdir(exist_ok=True)
    runtime = Path(os.environ.get('TCC_GM_RUNTIME', f'/Users/Shared/GameMakerStudio2-LTS2026/Cache/runtimes/runtime-{RUNTIME}'))
    users = list((Path.home() / 'Library/Application Support/GameMakerStudio2-LTS2026').glob('*/licence.plist'))
    user = Path(os.environ['TCC_GM_USER']) if 'TCC_GM_USER' in os.environ else (users[0].parent if len(users) == 1 else None)
    if user is None:
        parser.error('Set TCC_GM_USER to the licensed GameMaker user directory')
    if runtime.name != f'runtime-{RUNTIME}':
        parser.error(f'Tested runtime pin is {RUNTIME}')
    target = {'iOS': 'ios', 'iOSCheck': 'ios', 'Android': 'android', 'AndroidRelease': 'android'}.get(args.configuration, 'mac')
    env = dict(os.environ, DOTNET_EnableHWIntrinsic='0')
    env.setdefault('DEVELOPER_DIR', '/Applications/Xcode-26.6.app/Contents/Developer')
    if target == 'android':
        env.setdefault('TCC_UPLOAD_KEYSTORE', str(Path.home() / '.config/tcc-release/android/tcc-upload-2026.jks'))
        if not Path(env['TCC_UPLOAD_KEYSTORE']).is_file():
            parser.error('Set TCC_UPLOAD_KEYSTORE to the replacement upload keystore outside the repository')
        if not env.get('TCC_UPLOAD_PASSWORD'):
            env['TCC_UPLOAD_PASSWORD'] = subprocess.check_output(['security', 'find-generic-password',
                '-s', 'The Colorful Creature Android upload 2026', '-a', 'com.infiland.tcc', '-w'], text=True).strip()
    igor = runtime / 'bin/igor/osx/arm64/Igor'
    command = [str(igor), f'--project={ROOT / "The Colorful Creature.yyp"}', f'--rp={runtime}', f'--uf={user}',
        f'--pf={os.environ.get("TCC_GM_PREFABS", "/Users/Shared/GameMakerStudio2-LTS2026/Prefabs")}',
        '--runtime=YYC', f'--config={args.configuration}', f'--cache={output / "cache"}', f'--temp={output / "temp"}',
        f'--of={product_dir / "TCC.zip"}', f'--tf={product_dir / "TCC.zip"}', '--ignorecache', '-j=1']
    if target == 'android':
        command += ['--packagetype=aab', '--', target, 'Package']
    else:
        command += ['--', target, 'Compile']
    evidence = {'configuration': args.configuration, 'IDE': IDE, 'runtime': RUNTIME,
        'baseline': '4b6e942c', 'xcode': subprocess.check_output(['xcodebuild', '-version'], env=env, text=True).strip(),
        'compiler_workaround': 'DOTNET_EnableHWIntrinsic=0 and -j=1; not isolated',
        'device_tests': 'not performed', 'store_status': 'not uploaded'}
    def run(command, filename, recoverable_error=None):
        print(f'Running {filename}; output: {output / filename}', flush=True)
        with (output / filename).open('w') as log:
            result = subprocess.run(command, cwd=ROOT, env=env, stdout=log, stderr=subprocess.STDOUT)
        # Igor can report a fatal exception while returning zero.
        log_text = (output / filename).read_text(errors='replace')
        failed = bool(re.search(r'Unhandled exception|System\.[\w.]+Exception:|BUILD FAILED|FAILED:|Error :', log_text))
        evidence[filename] = {'exit_code': result.returncode, 'fatal_log_error': failed}
        (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
        recovered = bool(result.returncode and recoverable_error and recoverable_error in log_text)
        if (result.returncode or failed) and not recovered:
            print('\n'.join(log_text.splitlines()[-25:]))
            sys.exit(result.returncode or 1)
        return recovered
    if args.configuration == 'MacAppStore':
        run(['sh', str(ROOT / 'extensions/TCCGameController/build.sh'), '--self-check'], 'controllers.log')
    recovered_android_signing = run(command, 'compile.log',
        "Cannot convert '' to File." if target == 'android' else None)
    if target == 'android':
        extension_options = json.loads((output / 'cache/ExtensionOptions.json').read_text())
        admob = next(e['Options'] for e in extension_options['Extensions'] if e['Name'] == 'GMAdMob')
        if args.configuration == 'AndroidRelease':
            expected_ads = {
                'Android_AppID': 'ca-app-pub-7108130195717311~2960588105',
                'Android_BANNER': 'ca-app-pub-7108130195717311/1705849205',
                'Android_INTERSTITIAL': 'ca-app-pub-7108130195717311/1322705824',
                'Android_REWARDED': 'ca-app-pub-7108130195717311/8981703993',
            }
            for name, value in expected_ads.items():
                if admob[name]['Value'] != value:
                    raise RuntimeError(f'AndroidRelease has the wrong {name} ad identifier')
            evidence['production_ad_ids'] = expected_ads
        gradle_root = output / 'cache' / args.configuration / args.configuration
    if target == 'android' and recovered_android_signing:
        # Igor leaves the CLI keystore settings blank in Gradle. Complete the already
        # compiled project using environment-backed signing; never write the password.
        gradle = gradle_root / 'com.infiland.tcc/build.gradle'
        if not gradle.is_file():
            raise RuntimeError(f'Android signing recovery has no Gradle project: {gradle}')
        source = gradle.read_text()
        replacements = {
            'storeFile file("")': 'storeFile file(System.getenv("TCC_UPLOAD_KEYSTORE"))',
            'storePassword ""': 'storePassword System.getenv("TCC_UPLOAD_PASSWORD")',
            'keyAlias "default_alias"': 'keyAlias "tcc-upload"',
            'keyPassword ""': 'keyPassword System.getenv("TCC_UPLOAD_PASSWORD")',
        }
        for old, new in replacements.items():
            if source.count(old) != 1:
                raise RuntimeError(f'Unexpected Android signing template: {old}')
            source = source.replace(old, new)
        # AGP 8.13 cannot build an AAB while GameMaker's APK ABI splits are enabled.
        source, split_count = re.subn(r'(splits\s*\{\s*abi\s*\{\s*enable\s+)true',
            r'\1false', source, count=1)
        if split_count != 1:
            raise RuntimeError('Expected exactly one Android ABI split setting')
        gradle.write_text(source)
        run([str(gradle_root / 'com.infiland.tcc/gradle/gradlew'), '-p', str(gradle_root),
            'clean', ':com.infiland.tcc:bundleRelease', '--no-daemon'], 'gradle-package.log')
    if target == 'android':
        bundles = list((gradle_root / 'com.infiland.tcc/build/outputs/bundle/release').glob('*.aab'))
        if len(bundles) != 1:
            raise RuntimeError(f'Expected one signed AAB, found {bundles}')
        artifact = product_dir / 'TCC-1.2.0-1002000.aab'
        shutil.copy2(bundles[0], artifact)
        evidence['android_aab'] = {'path': str(artifact),
            'sha256': hashlib.sha256(artifact.read_bytes()).hexdigest()}
        evidence['compile.log']['recovered_empty_signing_config'] = recovered_android_signing
        (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
        return
    project_dir = product_dir / 'The_Colorful_Creature'
    if target == 'mac':
        support = project_dir / 'The_Colorful_Creature/Supporting Files'
        # GameMaker 2026.0.0.23 exports its stock green icon.icns even when
        # option_mac_icon_png points at the project's shared artwork.
        icon_source = ROOT / 'options/shared/icon.png'
        ios_icon_source = ROOT / 'options/ios/icons/itunes/itunes_1024.png'
        if icon_source.read_bytes() != ios_icon_source.read_bytes():
            raise RuntimeError('The Mac and iOS source icons no longer match')
        iconset = output / 'mac-app-icon.iconset'
        if iconset.exists():
            shutil.rmtree(iconset)
        iconset.mkdir()
        for size in [16, 32, 128, 256, 512]:
            for scale in [1, 2]:
                pixels = size * scale
                suffix = '@2x' if scale == 2 else ''
                destination = iconset / f'icon_{size}x{size}{suffix}.png'
                subprocess.run(['sips', '-z', str(pixels), str(pixels),
                    str(icon_source), '--out', str(destination)],
                    check=True, stdout=subprocess.DEVNULL)
        mac_icon = support / 'icon.icns'
        mac_icon.unlink(missing_ok=True)
        subprocess.run(['iconutil', '-c', 'icns', str(iconset), '-o', str(mac_icon)], check=True)
        evidence['mac_icon'] = {'source_sha256': hashlib.sha256(icon_source.read_bytes()).hexdigest(),
            'icns_sha256': hashlib.sha256(mac_icon.read_bytes()).hexdigest()}
        for filename in ['game.ini', 'options.ini']:
            path = support / filename
            path.write_text(re.sub(r'^Splash=.*$', 'Splash=""', path.read_text(), flags=re.MULTILINE))
        if args.configuration in ['Apple', 'MacAppStore', 'Check']:
            path = support / 'The_Colorful_Creature.entitlements'
            entitlements = plistlib.loads(path.read_bytes())
            entitlements['com.apple.developer.game-center'] = True
            if args.configuration == 'MacAppStore':
                entitlements['com.apple.security.app-sandbox'] = True
                entitlements['com.apple.security.network.client'] = True
            path.write_bytes(plistlib.dumps(entitlements))
        if args.mac_store_sign_embedded:
            identity = env.get('TCC_MAC_DEVELOPMENT_IDENTITY')
            if not identity:
                parser.error('Set TCC_MAC_DEVELOPMENT_IDENTITY to a local Apple Development signing identity')
            libraries = sorted(support.glob('*.dylib'))
            if not libraries:
                raise RuntimeError(f'No Mac libraries found in {support}')
            for library in libraries:
                subprocess.run(['codesign', '--force', '--sign', identity,
                    '--identifier', library.name, str(library)], check=True)
                signature = subprocess.check_output(['codesign', '-dv', str(library)],
                    stderr=subprocess.STDOUT, text=True)
                if f'Identifier={library.name}' not in signature:
                    raise RuntimeError(f'Unstable signing identifier for {library}')
            evidence['pre_signed_libraries'] = [library.name for library in libraries]
            (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    if target == 'ios':
        project = project_dir / 'The_Colorful_Creature.xcodeproj/project.pbxproj'
        # The legacy linker asserts under Xcode 26.6 and is absent in Xcode 27.
        project.write_text(project.read_text().replace('"-ld64",', ''))
        frameworks = project_dir / 'Fw'
        frameworks.mkdir(exist_ok=True)
        for name in ['GMAdMob', 'GMGameCenter']:
            with zipfile.ZipFile(ROOT / 'extensions' / name / 'iOSSourceFromMac' / f'{name}.zip') as archive:
                archive.extractall(frameworks)
        podfile = project_dir / 'Podfile'
        podfile.write_text(re.sub(r'https://github.com/CocoaPods/Specs(?:\.git)?', 'https://cdn.cocoapods.org/', podfile.read_text()))
        run(['pod', 'install', f'--project-directory={project_dir}'], 'pods.log')
    if args.native_diagnostic:
        if target == 'ios':
            run(['xcodebuild', '-workspace', str(project_dir / 'The_Colorful_Creature.xcworkspace'),
                 '-scheme', 'The_Colorful_Creature', '-configuration', 'Release', '-sdk', 'iphonesimulator',
                 '-destination', 'generic/platform=iOS Simulator', '-derivedDataPath', str(output / 'DerivedData'),
                 'ARCHS=arm64', 'CODE_SIGNING_ALLOWED=NO', 'build'], 'native.log')
            return
        if target != 'mac':
            parser.error('--native-diagnostic supports Apple exports only')
        project = project_dir / 'The_Colorful_Creature.xcodeproj'
        native_command = ['xcodebuild', '-project', str(project), '-scheme', 'The_Colorful_Creature',
            '-configuration', 'Release', '-derivedDataPath', str(output / 'DerivedData')]
        if args.configuration == 'MacAppStore':
            native_command += ['-destination', 'generic/platform=macOS', 'ARCHS=arm64 x86_64',
                'ONLY_ACTIVE_ARCH=NO', 'PRODUCT_BUNDLE_IDENTIFIER=com.infiland.tcc']
        native_command += ['CODE_SIGNING_ALLOWED=NO', 'build']
        run(native_command, 'native.log')
        app = output / 'DerivedData/Build/Products/Release/The_Colorful_Creature.app'
        if args.configuration == 'MacAppStore':
            executable = app / 'Contents/MacOS/The_Colorful_Creature'
            libraries = [executable, *app.rglob('*.dylib')]
            for binary in libraries:
                archs = subprocess.check_output(['lipo', '-archs', str(binary)], text=True).split()
                if set(archs) != {'arm64', 'x86_64'}:
                    raise RuntimeError(f'Mac App Store binary is not universal: {binary}: {archs}')
            evidence['architectures'] = ['arm64', 'x86_64']
        if args.configuration != 'Steam':
            steam = [str(p.relative_to(app)) for p in app.rglob('*') if 'steam' in p.name.lower() and p.suffix == '.dylib']
            if steam:
                raise RuntimeError(f'Non-Steam package contains Steam libraries: {steam}')
            evidence['steam_libraries'] = 'absent'
        executable = app / 'Contents/MacOS/The_Colorful_Creature'
        evidence['executable_sha256'] = hashlib.sha256(executable.read_bytes()).hexdigest()
        if args.self_check:
            try:
                with (output / 'self-check.log').open('w') as log:
                    result = subprocess.run([str(executable)], env=env, stdout=log, stderr=subprocess.STDOUT, timeout=45)
                passed = result.returncode == 0 and 'TCC_PORT_SELF_CHECK_PASS' in (output / 'self-check.log').read_text()
            except subprocess.TimeoutExpired:
                passed = False
                evidence['self_check_timeout'] = True
            evidence['self_check'] = passed
            (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
            if not passed:
                raise RuntimeError(f'Self-check failed; inspect {output / "self-check.log"}')
        (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')


if __name__ == '__main__':
    main()
