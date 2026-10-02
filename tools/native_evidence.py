"""Preserve completed native evidence bytes with transparent macOS compression."""
import hashlib
import subprocess
import sys
import tempfile
from pathlib import Path


def file_hash(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def compress_completed_runtime(path):
    """Call only after normal native termination and successful JSON parsing.

    Keep the same path and logical bytes. Never replace a hard-linked file or
    a file that changed while compression was in progress.
    """
    path = Path(path)
    if sys.platform != 'darwin':
        return {'status': 'not-applicable'}
    before = path.stat()
    if path.is_symlink() or before.st_nlink != 1 or before.st_flags & 32 or before.st_size < 16384:
        return {'status': 'unchanged'}
    sha = file_hash(path)
    try:
        with tempfile.TemporaryDirectory(prefix='.tcc-evidence-compression-', dir=path.parent) as directory:
            compressed = Path(directory) / path.name
            subprocess.run(['ditto', '--hfsCompression', '--noclone', str(path), str(compressed)],
                           check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
            after = compressed.stat()
            if file_hash(compressed) != sha:
                raise ValueError('Compression changed native evidence bytes')
            current = path.stat()
            if (current.st_ino != before.st_ino or current.st_mtime_ns != before.st_mtime_ns
                    or current.st_nlink != 1 or file_hash(path) != sha):
                raise ValueError('Native evidence changed during compression')
            if after.st_blocks >= before.st_blocks:
                return {'status': 'unchanged', 'sha256': sha}
            compressed.replace(path)
            if file_hash(path) != sha:
                raise ValueError('Replaced native evidence bytes differ')
            return dict(status='compressed', sha256=sha, logicalBytes=before.st_size,
                        allocatedBytesSaved=(before.st_blocks - after.st_blocks) * 512,
                        method='ditto --hfsCompression --noclone; byte-checked atomic replacement')
    except (OSError, subprocess.CalledProcessError) as error:
        # Storage optimization must not discard an otherwise complete result.
        return dict(status='compression-unavailable', reason=str(error))
