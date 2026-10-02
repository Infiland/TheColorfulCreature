"""Run only the supplied diagnostic app, muted by its GML configuration."""
import os
import hashlib
import json
import signal
from pathlib import Path
import subprocess
import sys
import time
from contextlib import contextmanager


@contextmanager
def native_slot():
    """Run one task-owned native diagnostic at a time."""
    if sys.platform != 'darwin':
        yield
        return
    import fcntl
    directory = Path.home() / 'Library/Caches/TCC130'
    directory.mkdir(parents=True, exist_ok=True)
    def check_testing_enabled():
        control = directory / 'testing-control.json'
        if control.is_file():
            state = json.loads(control.read_text())
            if not state.get('enabled', False):
                raise RuntimeError('Native launch gate disabled: ' + str(state.get('reason', 'Testing paused')))
    check_testing_enabled()
    with (directory / 'native-runtime.lock').open('a+') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        try:
            check_testing_enabled()
            yield
        finally:
            fcntl.flock(lock, fcntl.LOCK_UN)


def run_native(executable, log_path, timeout, env=None, arguments=(), visible=False, headless=False):
    requested_at = time.monotonic()
    with native_slot():
        started_at = time.monotonic()
        result = _run_native(executable, log_path, timeout, env, arguments, visible, headless)
        result['nativeSlotWaitSeconds'] = started_at - requested_at
        result['nativeLaunchStartedMonotonic'] = started_at
        result['nativeLaunchEndedMonotonic'] = time.monotonic()
        return result


def _run_native(executable, log_path, timeout, env=None, arguments=(), visible=False, headless=False):
    executable, log_path = Path(executable).resolve(), Path(log_path).resolve()
    if headless and visible:
        raise ValueError('Choose either headless or a visible window')
    # The Mac runner can activate its NSApplication even with -headless.
    # Launch Services must still request a hidden, non-foreground launch.
    background = sys.platform == 'darwin' and not visible
    quiet_library = executable.parent.parent / 'Frameworks/TCCDiagnosticQuiet.dylib'
    quiet_window = sys.platform == 'darwin' and headless and quiet_library.is_file()
    if quiet_window:
        env = dict(os.environ if env is None else env,
                   TCC_QA_QUIET='1', DYLD_INSERT_LIBRARIES=str(quiet_library))

    def owned_pids():
        processes = subprocess.check_output(['ps', '-axo', 'pid=,command='], text=True)
        matches = set()
        for line in processes.splitlines():
            fields = line.strip().split(None, 1)
            if len(fields) != 2:
                continue
            pid, command = fields
            if command == str(executable) or command.startswith(str(executable) + ' '):
                matches.add(int(pid))
        return matches

    previous = owned_pids() if background else set()
    # GML mutes diagnostics. Disabling the audio subsystem would invalidate
    # gameplay code that reads the water filter's live effect parameters.
    runner_arguments = [*(['-headless'] if headless else []), *arguments]
    command = [str(executable), *runner_arguments]
    destination = log_path
    if background:
        command = ['open', '-n', '-g', '-j', '-W', '--stdout', str(log_path),
                   '--stderr', str(log_path.with_suffix('.stderr.log'))]
        # Launch Services does not inherit the caller's arbitrary environment.
        for key, value in (env or {}).items():
            if key.startswith('TCC_QA_') or (quiet_window and key == 'DYLD_INSERT_LIBRARIES'):
                command += ['--env', key + '=' + value]
        command += [str(executable.parents[2])]
        if runner_arguments:
            command += ['--args', *runner_arguments]
        destination = log_path.with_suffix('.launcher.log')
    start = time.monotonic()
    timed_out = False
    process = None
    launching = False
    cleaning_up = False
    pending_interruption = None
    def stop_owned_app():
        if background:
            for pid in owned_pids() - previous:
                try:
                    os.kill(pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
    def interrupted(signum, frame):
        nonlocal pending_interruption
        # Finish Popen before raising so its child is always owned by cleanup.
        # A signal just after creation otherwise loses the launcher handle.
        if launching or cleaning_up:
            pending_interruption = signum
            return
        raise KeyboardInterrupt('Diagnostic interrupted')

    def stop_launched_app():
        nonlocal cleaning_up
        cleaning_up = True
        try:
            if process is not None:
                try:
                    process.kill()
                except ProcessLookupError:
                    pass
                process.wait()
            if background:
                # Launch Services can deliver a start after its launcher is killed.
                # Hold the slot throughout this bounded, exact-path cleanup.
                for _ in range(40):
                    stop_owned_app()
                    time.sleep(.05)
        finally:
            cleaning_up = False

    old_term = signal.signal(signal.SIGTERM, interrupted)
    old_int = signal.signal(signal.SIGINT, interrupted)
    try:
        try:
            with destination.open('w') as log:
                launching = True
                try:
                    process = subprocess.Popen(command, env=env, cwd=log_path.parent,
                                               stdout=log, stderr=subprocess.STDOUT)
                finally:
                    launching = False
                if pending_interruption is not None:
                    raise KeyboardInterrupt('Diagnostic interrupted during launch')
                code = process.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            timed_out = True
            stop_launched_app()
            if pending_interruption is not None:
                raise KeyboardInterrupt('Diagnostic interrupted during timeout cleanup')
            code = process.returncode
        except BaseException:
            stop_launched_app()
            raise
    finally:
        signal.signal(signal.SIGTERM, old_term)
        signal.signal(signal.SIGINT, old_int)
    normal_end = (not timed_out and code == 0 and log_path.is_file()
                  and '###game_end###0' in log_path.read_text(errors='replace'))
    return {'exitCode': None if background else code, 'launcherExitCode': code if background else None,
            'normalRuntimeEnd': normal_end, 'timedOut': timed_out,
            'wallSeconds': time.monotonic() - start, 'backgroundLaunchRequested': background,
            'headlessRequested': headless, 'quietWindowRequested': quiet_window,
            'quietLibrarySha256': hashlib.sha256(quiet_library.read_bytes()).hexdigest() if quiet_window else None}
