#!/usr/bin/env python3
"""Inspect a locally built SteamAndroid APK; this never installs or uploads it."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import zipfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('apk', type=Path)
    parser.add_argument('--build-tools', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    apk = args.apk.resolve()
    signature = subprocess.run([str(args.build_tools / 'apksigner'), 'verify', '--verbose', str(apk)],
                               text=True, capture_output=True, env=os.environ)
    badging = subprocess.check_output([str(args.build_tools / 'aapt2'), 'dump', 'badging', str(apk)], text=True)
    manifest = subprocess.check_output([str(args.build_tools / 'aapt2'), 'dump', 'xmltree', str(apk),
                                        '--file', 'AndroidManifest.xml'], text=True)
    with zipfile.ZipFile(apk) as archive:
        names = archive.namelist()
        libraries = sorted(name for name in names if name.startswith('lib/') and name.endswith('.so'))
        abis = sorted({name.split('/')[1] for name in libraries})
        dex_names = sorted(name for name in names if re.fullmatch(r'classes\d*\.dex', name))
        dex = b''.join(archive.read(name) for name in dex_names)
        forbidden = {
            'ads': b'Lcom/google/android/gms/ads/',
            'ad-consent': b'Lcom/google/android/ump/',
            'google-games': b'Lcom/google/android/gms/games/',
            'google-sign-in': b'Lcom/google/android/gms/auth/api/signin/',
            'GMAdMob-extension': b'/GMAdMob;',
            'GMGooglePlayServices-extension': b'/GMGooglePlayServices;',
        }
        findings = [name for name, marker in forbidden.items() if marker in dex]
        safe_area = b'/TCCAndroidSafeArea;' in dex
    package = re.search(r"^package: name='([^']+)'", badging, re.MULTILINE)
    checks = {
        'signatureValid': signature.returncode == 0,
        'steamPackage': bool(package and package[1] == 'com.infiland.tccsteam'),
        'requiredArchitectures': {'arm64-v8a', 'x86_64'}.issubset(abis),
        'dexPresent': bool(dex_names),
        'noAdsOrGoogleAuthenticationClasses': not findings,
        'localWindowInsetsPresent': safe_area,
    }
    report = dict(apk=str(apk), sha256=hashlib.sha256(apk.read_bytes()).hexdigest(),
                  passed=all(checks.values()), checks=checks, abis=abis, libraries=libraries,
                  forbiddenClassFindings=findings, badging=badging,
                  internetPermission='android.permission.INTERNET' in manifest,
                  networkUse='The existing public news viewer downloads Steam news and images over HTTP; platform services remain local.',
                  signatureOutput=signature.stdout + signature.stderr,
                  deviceCompatibility='not tested', nativeSteamServices='not supplied by installed extension',
                  storeOperation='none')
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'passed': report['passed'], 'checks': checks, 'abis': abis, 'report': str(args.output.resolve())}))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
