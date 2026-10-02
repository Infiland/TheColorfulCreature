"""Package a quiet host window for task-owned Mac diagnostic builds."""
import hashlib
from pathlib import Path
import plistlib
import subprocess


def prepare_quiet_bundle(app):
    app = Path(app).resolve()
    owned = Path.home() / 'Library/Caches/TCC130'
    if owned not in app.parents:
        raise ValueError('Quiet host packaging is limited to task-owned TCC130 diagnostics')
    path = app / 'Contents/Info.plist'
    plist = plistlib.loads(path.read_bytes())
    if plist.get('CFBundleIdentifier') not in ['com.infiland.tcc.qa', 'com.infiland.tcc.check']:
        raise ValueError('Quiet host packaging requires the QA or Check application')
    source = Path(__file__).with_name('diagnostic_quiet.m')
    library = app / 'Contents/Frameworks/TCCDiagnosticQuiet.dylib'
    library.parent.mkdir(exist_ok=True)
    subprocess.run(['clang', '-fobjc-arc', '-dynamiclib', '-arch', 'arm64', '-arch', 'x86_64',
                    '-framework', 'AppKit', str(source), '-o', str(library)], check=True)
    # Accessory policy permits the native render context; the small diagnostic
    # library suppresses activation/ordering before the runner creates it.
    plist.pop('LSBackgroundOnly', None)
    plist['LSUIElement'] = True
    path.write_bytes(plistlib.dumps(plist))
    subprocess.run(['codesign', '--force', '--deep', '--sign', '-', str(app)], check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    return {'path': str(library), 'sha256': hashlib.sha256(library.read_bytes()).hexdigest(),
            'sourceSha256': hashlib.sha256(source.read_bytes()).hexdigest(),
            'policy': 'Accessory app; suppress host activation/window ordering only'}
