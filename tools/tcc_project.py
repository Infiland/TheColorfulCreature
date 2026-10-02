"""Small, formatting-preserving helpers for explicit GameMaker registration."""
import json
import hashlib
import os
import re
from collections import OrderedDict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / 'The Colorful Creature.yyp'
_FILE_HASHES = OrderedDict()
_FILE_HASH_LIMIT = 100000
_HASH_CACHE_SUPPORTED = os.name == 'posix'


def _file_sha256(path):
    """Reuse bytes only while fresh filesystem metadata still identifies them.

    Every caller still stats every file. ctime catches writes even when mtime
    is restored; inode/device catch atomic replacements and symlink retargets.
    No digest cache is persisted across Python processes. Platforms whose
    ctime denotes creation time always read the bytes again.
    """
    path = Path(path)
    key = str(path.absolute())

    def signature():
        info = path.stat()
        return (info.st_dev, info.st_ino, info.st_mode, info.st_size,
                info.st_mtime_ns, info.st_ctime_ns)

    for _ in range(3):
        before = signature()
        cached = _FILE_HASHES.get(key) if _HASH_CACHE_SUPPORTED else None
        if cached is not None and cached[0] == before:
            _FILE_HASHES.move_to_end(key)
            return cached[1]
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        if signature() != before:
            continue
        if _HASH_CACHE_SUPPORTED:
            _FILE_HASHES[key] = (before, digest)
            _FILE_HASHES.move_to_end(key)
            if len(_FILE_HASHES) > _FILE_HASH_LIMIT:
                _FILE_HASHES.popitem(last=False)
        return digest
    raise RuntimeError(f'File changed repeatedly while hashing: {path}')


def artifact_identity(app):
    """Bind the runner, extensions and compiled room/assets payload together."""
    hashes = {p.relative_to(app).as_posix(): _file_sha256(p)
              for p in sorted(app.rglob('*')) if p.is_file() and p.name != '.DS_Store'}
    return {'sha256': hashlib.sha256(json.dumps(hashes, sort_keys=True).encode()).hexdigest(),
            'fileCount': len(hashes)}


# Runtime asset coverage is independent of file suffix. GameMaker sound
# payloads can be extensionless; extension proxies/fonts/shaders are binary or
# use suffixes outside the former code/image whitelist. Notes are editor-only.
_RUNTIME_RESOURCE_ROOTS = frozenset(('scripts', 'objects', 'sprites', 'sequences',
    'paths', 'animcurves', 'timelines', 'particles', 'shaders', 'fonts', 'sounds',
    'tilesets', 'extensions'))
_SOURCE_IDENTITY_SCHEME = 'project-runtime-assets-v2'


def _runtime_resource_roots(root):
    project = read_yy(root / PROJECT.name)
    roots = set(_RUNTIME_RESOURCE_ROOTS)
    for entry in project.get('resources', []):
        path = entry.get('id', {}).get('path')
        if (not isinstance(path, str) or not path or '\\' in path
                or Path(path).is_absolute() or '..' in Path(path).parts
                or len(Path(path).parts) < 2):
            raise ValueError('Invalid project resource path')
        resource_root = Path(path).parts[0]
        if resource_root != 'notes':
            roots.add(resource_root)
        if not (root / path).is_file():
            raise ValueError('Registered resource is missing: ' + path)
    return roots


def _source_identity_legacy_v1(root):
    """Original v1 algorithm, retained byte-for-byte in semantics for old builds."""
    files = [root / PROJECT.name]
    for folder in ['scripts', 'objects', 'rooms', 'sprites', 'options', 'datafiles', 'extensions']:
        files.extend(p for p in (root / folder).rglob('*') if p.is_file() and
                     p.suffix.lower() in {'.gml', '.yy', '.png', '.json', '.sav', '.ini', '.lang',
                                         '.cpp', '.mm', '.m', '.h', '.java', '.ext', '.gradle', '.xml'})
    hashes = {p.relative_to(root).as_posix(): _file_sha256(p)
              for p in sorted(files)}
    digest = hashlib.sha256(json.dumps(hashes, sort_keys=True).encode()).hexdigest()
    physics = {name: value for name, value in hashes.items()
               if name.startswith(('scripts/', 'objects/', 'sprites/'))}
    return {'sourceSha256': digest,
            'physicsSha256': hashlib.sha256(json.dumps(physics, sort_keys=True).encode()).hexdigest(),
            'fileCount': len(hashes)}



def source_identity(root=ROOT, *, version=2):
    """Hash all project runtime asset bytes under an explicit identity scheme.

    External compiler/runtime dependencies (including vendor prefabs) belong
    to separate build-environment evidence, not this project source identity.

    version=1 is an explicit historical rehash only and preserves the original
    three-field identity shape. It must never qualify as complete/current v2.
    """
    root = Path(root)
    if type(version) is not int or version not in (1, 2):
        raise ValueError('Unsupported source identity version')
    if version == 1:
        return _source_identity_legacy_v1(root)
    runtime_roots = _runtime_resource_roots(root)
    folders = runtime_roots | {'rooms', 'options', 'datafiles'}
    files = {root / PROJECT.name}
    for folder in sorted(folders):
        tree = root / folder
        if tree.is_symlink():
            raise ValueError('Runtime resource directory symlinks need an explicit binding: ' + str(tree))
        for path in tree.rglob('*'):
            if path.is_symlink() and path.is_dir():
                raise ValueError('Runtime resource directory symlinks need an explicit binding: ' + str(path))
            if path.is_file() and path.name != '.DS_Store':
                files.add(path)
    # Included-file descriptors can point outside the usual datafiles tree.
    # Keep their bytes bound too; missing/escaping paths must fail closed.
    project = read_yy(root / PROJECT.name)
    for entry in project.get('IncludedFiles', []):
        folder, name = entry.get('filePath'), entry.get('name')
        if not isinstance(folder, str) or not isinstance(name, str):
            raise ValueError('Malformed included-file descriptor')
        relative = Path(folder) / name
        if (relative.is_absolute() or '..' in relative.parts or '\\' in str(relative)
                or not name or Path(name).name != name or not (root / relative).is_file()):
            raise ValueError('Missing/invalid included file: ' + str(relative))
        files.add(root / relative)
    hashes = {path.relative_to(root).as_posix(): _file_sha256(path) for path in sorted(files)}
    # Rooms retain the existing independent per-content identity. All other
    # runtime assets, including native extensions, belong to shared behavior;
    # an old/current flag must not ignore a changed sequence, shader or font.
    shared_roots = runtime_roots - {'rooms', 'options', 'datafiles'}
    physics = {name: value for name, value in hashes.items()
               if name.split('/', 1)[0] in shared_roots}
    digest = lambda values: hashlib.sha256(json.dumps(
        {'identityVersion': 2, 'identityScheme': _SOURCE_IDENTITY_SCHEME, 'files': values},
        sort_keys=True).encode()).hexdigest()
    return {'identityVersion': 2, 'identityScheme': _SOURCE_IDENTITY_SCHEME,
            'sourceSha256': digest(hashes), 'physicsSha256': digest(physics), 'fileCount': len(hashes)}


def verify_frozen_source_identity(root, expected, *, legacy_version=None):
    """Rehash a frozen source under its declared original scheme, never migrate it.

    Unversioned records require the caller's explicit legacy_version=1. The
    result makes their incomplete runtime coverage/current exclusion visible;
    no old native JSON/hash/clock is rewritten to claim expanded binding.
    """
    if not isinstance(expected, dict):
        raise ValueError('Missing source identity')
    if (type(expected.get('fileCount')) is not int or expected['fileCount'] < 1
            or any(not isinstance(expected.get(key), str) or not re.fullmatch(r'[0-9a-f]{64}', expected[key])
                   for key in ('sourceSha256', 'physicsSha256'))):
        raise ValueError('Malformed source identity digest/count')
    if set(expected) == {'sourceSha256', 'physicsSha256', 'fileCount'}:
        if type(legacy_version) is not int or legacy_version != 1:
            raise ValueError('Unversioned evidence needs explicit original legacy_version=1')
        version = 1
    elif (expected.get('identityVersion') == 2 and type(expected.get('identityVersion')) is int
          and expected.get('identityScheme') == _SOURCE_IDENTITY_SCHEME
          and set(expected) == {'identityVersion', 'identityScheme', 'sourceSha256', 'physicsSha256', 'fileCount'}):
        if legacy_version is not None:
            raise ValueError('Do not relabel versioned evidence with a legacy scheme')
        version = 2
    else:
        raise ValueError('Unsupported/malformed source identity schema')
    observed = source_identity(Path(root), version=version)
    if observed != expected:
        raise ValueError('Frozen source hash differs under its original identity scheme')
    return {'identity': observed, 'identityVersion': version,
            'completeProjectRuntimeCoverage': version == 2,
            'compilerDependenciesBound': False,
            'currentQualificationPermitted': version == 2,
            'qualification': 'Coverage permission only; native payload/log/state and fresh current source/content bindings still required.'}


def level_content_identity(spec, root=ROOT):
    """Hash playable room content independently of its evidence/catalog metadata.

    Physics still includes every object, script and sprite. A catalog gaining
    evidence references must not invalidate the room it describes recursively.
    """
    if 'specialIndex' in spec:
        raise ValueError('Special-level diagnostics are not part of this release')
    room = ('r_challengelevel' if 'challenge' in spec else
            spec.get('room', 'r_gameplay_qa'))
    if not re.fullmatch(r'[A-Za-z0-9_]+', room):
        raise ValueError('Invalid room resource name')
    files = set()
    visited = set()
    while room:
        if room in visited:
            raise ValueError('Cyclic room inheritance')
        visited.add(room)
        folder = root / 'rooms' / room
        resource = folder / (room + '.yy')
        if not resource.is_file():
            raise ValueError(f'Missing room resource: {room}')
        files.update(p for p in folder.rglob('*') if p.is_file())
        parent = read_yy(resource).get('parentRoom')
        room = parent['name'] if parent else None
    if 'challenge' in spec:
        # Include every bundled definition: overrides and ordered level_dirs can
        # change the loaded challenge even when the generic room is unchanged.
        files.update(p for p in (root / 'datafiles/Challenges').rglob('*') if p.is_file())
    hashes = {p.relative_to(root).as_posix(): _file_sha256(p)
              for p in sorted(files)}
    return hashlib.sha256(json.dumps(hashes, sort_keys=True).encode()).hexdigest()


def room_object_types(name, root=ROOT):
    """Read all authored object types, including inherited room layers."""
    found, visited = set(), set()
    while name:
        if name in visited or not re.fullmatch(r'[A-Za-z0-9_]+', name):
            raise ValueError('Invalid or cyclic room inheritance')
        visited.add(name)
        definition = read_yy(root / 'rooms' / name / (name + '.yy'))
        pending = list(definition.get('layers', []))
        while pending:
            layer = pending.pop()
            pending.extend(layer.get('layers', []))
            found.update(item['objectId']['name'] for item in layer.get('instances', []) if item.get('objectId'))
        parent = definition.get('parentRoom')
        name = parent['name'] if parent else None
    if 'o_door' in found:
        found.add('o_lockeddoor')
    return sorted(found)


def validate_events(root=ROOT):
    for entry in read_yy(root / PROJECT.name)['resources']:
        path = root / entry['id']['path']
        if path.parent.parent.name != 'objects':
            continue
        seen = set()
        for event in read_yy(path)['eventList']:
            collision = event.get('collisionObjectId') or {}
            key = (event['eventType'], event['eventNum'], collision.get('name'))
            if key in seen:
                raise ValueError(f'Duplicate object event {key}: {path}')
            seen.add(key)


def read_yy(path):
    # GameMaker's serializer permits trailing commas, but never alters strings.
    text = Path(path).read_text()
    text = re.sub(r'("(?:\\.|[^"\\])*"\s*)|,\s*(?=[}\]])',
                  lambda match: match[1] or '', text)
    return json.loads(text)


def register(paths):
    source = PROJECT.read_text()
    project = read_yy(PROJECT)
    existing = {entry['id']['path'] for entry in project['resources']}
    additions = []
    room_additions = []
    for path in paths:
        path = Path(path).as_posix()
        resource = read_yy(ROOT / path)
        if path in existing:
            continue
        existing.add(path)
        name = resource['name']
        additions.append(f'    {{"id":{{"name":"{name}","path":"{path}",}},}},\n')
        if resource['resourceType'] == 'GMRoom':
            room_additions.append(f'    {{"roomId":{{"name":"{name}","path":"{path}",}},}},\n')
    source = source.replace('  "resources":[\n', '  "resources":[\n' + ''.join(additions), 1)
    # Append new rooms after the existing campaign order; never shift its next-room routes.
    if room_additions:
        start = source.index('  "RoomOrderNodes":[')
        end = source.index('\n  ],', start)
        source = source[:end] + '\n' + ''.join(room_additions).rstrip('\n') + source[end:]
    PROJECT.write_text(source)
    return additions


if __name__ == '__main__':
    import sys
    print(f'Registered {len(register(sys.argv[1:]))} resources')
