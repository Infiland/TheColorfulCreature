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
from tcc_project import source_identity, read_yy, validate_events, artifact_identity
from native_runner import run_native
from diagnostic_host import prepare_quiet_bundle

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = '2026.0.0.23'
IDE = '2026.0.0.16'


def normalize_included_file_destinations(project):
    """Match YYC's native resource copies to GameMaker's virtual file names.

    The 2026 exporter normalizes spaces in the included-file lookup table but
    leaves spaces in Xcode's Copy Game Files destinations. The files then exist
    physically but cannot be opened by the sandboxed game. Only generated copy
    destinations are changed; source data and user save paths remain untouched.
    """
    source = project.read_text()
    changes = []

    def phase(match):
        block = match.group(0)
        if 'Copy Game Files' not in block:
            return block

        def destination(field):
            old = field.group(1)
            new = old.lower().replace(' ', '_')
            if old != new:
                changes.append({'from': old, 'to': new})
            return 'dstPath = "' + new + '";'

        return re.sub(r'dstPath\s*=\s*"([^"\n]*)";', destination, block)

    source = re.sub(r'[^\n]*Copy Game Files[^\n]*=\s*\{[^}]*\};', phase, source)
    project.write_text(source)
    return changes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('configuration', choices=['Steam', 'Apple', 'MacAppStore', 'iOS', 'iOSCheck', 'Android', 'AndroidRelease', 'SteamAndroid', 'Check', 'QA'])
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--native-diagnostic', action='store_true')
    parser.add_argument('--runtime', choices=['YYC', 'VM'], default='YYC',
        help='Use VM for faster diagnostic iteration; release builds keep YYC')
    parser.add_argument('--self-check', action='store_true')
    parser.add_argument('--headless', action='store_true', help='Use the native runner headless flag for --self-check')
    parser.add_argument('--quiet-window', action='store_true', help='Package an isolated Mac QA/Check host that cannot take desktop focus')
    parser.add_argument('--mac-store-sign-embedded', action='store_true',
        help='Pre-sign generated Mac App Store dylibs with TCC_MAC_DEVELOPMENT_IDENTITY before archiving')
    parser.add_argument('--clean', action='store_true', help='Discard generated compiler caches before export')
    parser.add_argument('--snapshot', action='store_true',
        help='Compile an immutable copy in the output directory while other work continues')
    args = parser.parse_args()
    if args.runtime == 'VM' and args.configuration not in ['Check', 'QA']:
        parser.error('VM iteration is limited to Check and QA diagnostics')
    output = args.output.expanduser().absolute()
    if output.resolve() == ROOT or ROOT in output.resolve().parents:
        parser.error('Keep build outputs outside the checkout')
    if args.self_check and (not args.native_diagnostic or args.configuration != 'Check'):
        parser.error('--self-check requires Check --native-diagnostic')
    if args.headless and not args.self_check:
        parser.error('--headless requires --self-check')
    if args.quiet_window and (not args.native_diagnostic or args.configuration not in ['QA', 'Check']):
        parser.error('--quiet-window requires QA or Check --native-diagnostic')
    if args.self_check and output != output.resolve():
        parser.error('Use a real, non-symlink output path for Mac runtime checks, such as ~/Library/Caches/TCCPort/check')
    if args.mac_store_sign_embedded and args.configuration != 'MacAppStore':
        parser.error('--mac-store-sign-embedded requires MacAppStore')
    output.mkdir(parents=True, exist_ok=True)
    compile_root = ROOT
    if args.snapshot:
        compile_root = output / 'source'
        for attempt in range(3):
            before = source_identity()
            if compile_root.exists():
                shutil.rmtree(compile_root)
            compile_root.mkdir()
            project = read_yy(ROOT / 'The Colorful Creature.yyp')
            folders = {'datafiles', 'options'} | {r['id']['path'].split('/')[0] for r in project['resources']}
            for folder in sorted(folders):
                shutil.copytree(ROOT / folder, compile_root / folder,
                                ignore=shutil.ignore_patterns('.git', '__pycache__'))
            for name in ['The Colorful Creature.yyp', 'The Colorful Creature.resource_order']:
                shutil.copy2(ROOT / name, compile_root / name)
            if before == source_identity() == source_identity(compile_root):
                break
        else:
            parser.error('Source kept changing during snapshot; retry at a stable edit boundary')
    validate_events(compile_root)
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
    target = {'iOS': 'ios', 'iOSCheck': 'ios', 'Android': 'android', 'AndroidRelease': 'android', 'SteamAndroid': 'android'}.get(args.configuration, 'mac')
    steam_android = args.configuration == 'SteamAndroid'
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
    command = [str(igor), f'--project={compile_root / "The Colorful Creature.yyp"}', f'--rp={runtime}', f'--uf={user}',
        f'--pf={os.environ.get("TCC_GM_PREFABS", "/Users/Shared/GameMakerStudio2-LTS2026/Prefabs")}',
        '--runtime=' + args.runtime, f'--config={args.configuration}', f'--cache={output / "cache"}', f'--temp={output / "temp"}',
        f'--of={product_dir / "TCC.zip"}', f'--tf={product_dir / "TCC.zip"}', '--ignorecache', '-j=1']
    if target == 'android':
        command += ['--packagetype=' + ('apk' if steam_android else 'aab'), '--', target, 'Package']
    else:
        command += ['--', target, 'Compile']
    build_identity = source_identity(compile_root)
    evidence = {'configuration': args.configuration, 'IDE': IDE, 'runtime': RUNTIME, 'compiler_backend': args.runtime,
        'source_identity': build_identity,
        'source_snapshot': str(compile_root) if args.snapshot else None,
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
            diagnostics = [line for line in log_text.splitlines()
                           if re.search(r'Error :|error:|Undefined symbols|Exception:', line)]
            print('\n'.join(diagnostics[:8] + log_text.splitlines()[-10:]))
            sys.exit(result.returncode or 1)
        return recovered

    def record_native(app):
        if args.quiet_window:
            evidence['quiet_launch_library'] = prepare_quiet_bundle(app)
        executable = app / 'Contents/MacOS/The_Colorful_Creature'
        evidence['executable_sha256'] = hashlib.sha256(executable.read_bytes()).hexdigest()
        evidence['artifact_identity'] = artifact_identity(app)
        # Preserve the finished package identity even if a queued self-check is
        # cancelled or rejected by the testing pause guard before it launches.
        (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
        if args.self_check:
            result = run_native(executable, output / 'self-check.log', 45, env=env, headless=args.headless)
            evidence['self_check_process'] = result
            passed = result['normalRuntimeEnd'] and 'TCC_PORT_SELF_CHECK_PASS' in (output / 'self-check.log').read_text()
            evidence['self_check'] = passed
            (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
            if not passed:
                raise RuntimeError(f'Self-check failed; inspect {output / "self-check.log"}')
        (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    if args.configuration == 'MacAppStore':
        run(['sh', str(compile_root / 'extensions/TCCGameController/build.sh'), '--self-check'], 'controllers.log')
    recovered_android_signing = run(command, 'compile.log',
        "Cannot convert '' to File." if target == 'android' else None)
    if source_identity(compile_root) != build_identity:
        raise RuntimeError('Project source changed during compiler export; repeat with a stable source snapshot')
    if target == 'android':
        extension_options = json.loads((output / 'cache/ExtensionOptions.json').read_text())
        admob = next((e['Options'] for e in extension_options['Extensions'] if e['Name'] == 'GMAdMob'), {})
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
        gradle_root = output / 'cache' / target / args.configuration
        android_options = read_yy(compile_root / 'options/android/options_android.yy')
        android_options.update(android_options.get('ConfigValues', {}).get(args.configuration, {}))
        package_name = '.'.join(android_options['option_android_package_' + key] for key in ['domain', 'company', 'product'])
        module = gradle_root / package_name
    if target == 'android' and (recovered_android_signing or steam_android):
        # Igor leaves the CLI keystore settings blank in Gradle. Complete the already
        # compiled project using environment-backed signing; never write the password.
        gradle = module / 'build.gradle'
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
            if not recovered_android_signing:
                break
            if source.count(old) != 1:
                raise RuntimeError(f'Unexpected Android signing template: {old}')
            source = source.replace(old, new)
        # AAB needs no APK ABI splits. Steam's Android depot also needs one
        # installable universal APK, rather than separate per-ABI APKs.
        source, split_count = re.subn(r'(splits\s*\{\s*abi\s*\{\s*enable\s+)(?:true|false)',
            r'\1false', source, count=1)
        if split_count != 1:
            raise RuntimeError('Expected exactly one Android ABI split setting')
        gradle.write_text(source)
        task = 'assembleRelease' if steam_android else 'bundleRelease'
        run([str(module / 'gradle/gradlew'), '-p', str(gradle_root),
            'clean', ':' + package_name + ':' + task, '--no-daemon'], 'gradle-package.log')
    if target == 'android':
        android_version = android_options['option_android_version']
        suffix = 'apk' if steam_android else 'aab'
        artifact_folder = 'apk' if steam_android else 'bundle'
        bundles = list((module / f'build/outputs/{artifact_folder}/release').glob('*.' + suffix))
        if len(bundles) != 1:
            raise RuntimeError(f'Expected one signed {suffix.upper()}, found {bundles}')
        artifact = product_dir / f'TCC-{args.configuration}-{android_version}.{suffix}'
        shutil.copy2(bundles[0], artifact)
        evidence['android_' + suffix] = {'path': str(artifact), 'package': package_name,
            'sha256': hashlib.sha256(artifact.read_bytes()).hexdigest()}
        if steam_android:
            evidence['steam_android'] = {'services': 'local only', 'ads_and_google_auth': 'disabled',
                'native_steam_sdk': 'not available in installed extension',
                'steam_frame_device_compatibility': 'not tested',
                'depot_layout': 'Place this APK at the top level of the Android depot',
                'packaging_reference': 'https://partner.steamgames.com/doc/steamhardware/steamframe/apk_upload'}
        evidence['compile.log']['recovered_empty_signing_config'] = recovered_android_signing
        (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
        return
    if target == 'mac' and args.runtime == 'VM':
        # VM Compile supplies the bytecode/assets zip rather than an Xcode
        # project. Package that unchanged payload with the pinned native runner.
        app = output / 'DerivedData/Build/Products/Release/The_Colorful_Creature.app'
        if app.exists():
            shutil.rmtree(app)
        shutil.copytree(runtime / 'mac/YoYo Runner.app', app)
        resources = app / 'Contents/Resources'
        with zipfile.ZipFile(product_dir / 'game.zip') as archive:
            for entry in archive.infolist():
                if entry.is_dir():
                    continue
                relative = Path(entry.filename)
                if relative.parts[0] != 'assets' or '..' in relative.parts:
                    raise RuntimeError(f'Unexpected VM payload path: {entry.filename}')
                destination = resources.joinpath(*relative.parts[1:])
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_bytes(archive.read(entry))
        for filename in ['game.ini', 'options.ini']:
            path = resources / filename
            if path.is_file():
                path.write_text(re.sub(r'^Splash=.*$', 'Splash=""', path.read_text(), flags=re.MULTILINE))
        mac_options = read_yy(compile_root / 'options/mac/options_mac.yy')
        mac_options.update(mac_options.get('ConfigValues', {}).get(args.configuration, {}))
        plist_path = app / 'Contents/Info.plist'
        plist = plistlib.loads(plist_path.read_bytes())
        executable = app / 'Contents/MacOS' / plist['CFBundleExecutable']
        executable.rename(executable.with_name('The_Colorful_Creature'))
        plist.update(CFBundleExecutable='The_Colorful_Creature',
                     CFBundleIdentifier=mac_options['option_mac_app_id'],
                     CFBundleName=mac_options['option_mac_display_name'],
                     CFBundleDisplayName=mac_options['option_mac_display_name'], NSAppSleepDisabled=True)
        plist_path.write_bytes(plistlib.dumps(plist))
        subprocess.run(['codesign', '--force', '--deep', '--sign', '-', str(app)], check=True,
                       stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        evidence['native_runner'] = {'path': str(runtime / 'mac/YoYo Runner.app'),
                                     'diagnostic_package': str(app)}
        record_native(app)
        return
    project_dir = product_dir / 'The_Colorful_Creature'
    if target in ['mac', 'ios']:
        evidence['included_file_destination_repairs'] = normalize_included_file_destinations(
            project_dir / 'The_Colorful_Creature.xcodeproj/project.pbxproj')
    if target == 'mac':
        support = project_dir / 'The_Colorful_Creature/Supporting Files'
        # GameMaker 2026.0.0.23 exports its stock green icon.icns even when
        # option_mac_icon_png points at the project's shared artwork.
        icon_source = compile_root / 'options/shared/icon.png'
        ios_icon_source = compile_root / 'options/ios/icons/itunes/itunes_1024.png'
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
            with zipfile.ZipFile(compile_root / 'extensions' / name / 'iOSSourceFromMac' / f'{name}.zip') as archive:
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
            app = output / 'DerivedData/Build/Products/Release-iphonesimulator/The_Colorful_Creature.app'
            info = plistlib.loads((app / 'Info.plist').read_bytes())
            evidence['ios_simulator_app'] = str(app)
            evidence['executable_sha256'] = hashlib.sha256((app / info['CFBundleExecutable']).read_bytes()).hexdigest()
            evidence['artifact_identity'] = artifact_identity(app)
            (output / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
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
        record_native(app)


if __name__ == '__main__':
    main()
