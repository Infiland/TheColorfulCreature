#!/usr/bin/env python3
"""Audit room creation order, layers, masks and creation-code risks before cloning.

This reports source facts only. A clean report is not completion/playability evidence.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

from tcc_project import ROOT, PROJECT, read_yy


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def layers(room):
    pending = list(room.get('layers', []))
    while pending:
        layer = pending.pop(0)
        yield layer
        pending.extend(layer.get('layers', []))


def audit():
    project = read_yy(PROJECT)
    resources = {entry['id']['name']: ROOT / entry['id']['path'] for entry in project['resources']}
    objects = {name: read_yy(path) for name, path in resources.items() if path.parent.parent.name == 'objects'}
    masks = {}
    for name, definition in objects.items():
        sprite = definition.get('spriteMaskId') or definition.get('spriteId')
        if sprite and sprite['name'] in resources:
            asset = read_yy(resources[sprite['name']])
            masks[name] = {key: asset.get(key) for key in ['name', 'width', 'height', 'bboxMode',
                'bbox_left', 'bbox_top', 'bbox_right', 'bbox_bottom', 'collisionKind']}
            masks[name]['origin'] = {key: asset.get('sequence', {}).get(key) for key in ['xorigin', 'yorigin']}
        else:
            masks[name] = None
    result = []
    for name, path in resources.items():
        if path.parent.parent.name != 'rooms':
            continue
        room = read_yy(path)
        codes = []
        missing = []
        dependencies = set()
        listed = []
        room_layers = []
        creation = room.get('creationCodeFile', '')
        if creation:
            codepath = path.parent / creation
            (codes if codepath.is_file() else missing).append(codepath)
        for layer in layers(room):
            instances = layer.get('instances', [])
            room_layers.append({'name': layer['name'], 'type': layer['resourceType'],
                                'depth': layer.get('depth'), 'visible': layer.get('visible'),
                                'instances': len(instances)})
            for instance in instances:
                listed.append(instance['name'])
                obj = instance.get('objectId')
                if obj:
                    dependencies.add(obj['name'])
                    if obj['name'] not in resources:
                        missing.append(ROOT / obj['path'])
                if instance.get('hasCreationCode'):
                    codepath = path.parent / ('InstanceCreationCode_' + instance['name'] + '.gml')
                    (codes if codepath.is_file() else missing).append(codepath)
        texts = '\n'.join(p.read_text() for p in codes)
        ordered = [entry['name'] for entry in room.get('instanceCreationOrder', [])]
        risks = []
        if missing:
            risks.append('unresolved-reference')
        if room.get('parentRoom'):
            risks.append('inherited-room')
        if len(listed) != len(set(listed)) or len(ordered) != len(set(ordered)):
            risks.append('duplicate-instance-name')
        if set(ordered) != set(listed):
            risks.append('creation-order-differs-from-layer-instances')
        if re.search(r'global\.(?:hardmode|hardmodedifficulty|deaths|endless)', texts):
            risks.append('difficulty-or-death-dependent-creation')
        if re.search(r'achievement|submit_score|savegame|worldProgression|global\.skin|global\.hat', texts):
            risks.append('progression-side-effects')
        if re.search(r'room_goto|room_restart|instance_destroy|instance_change', texts):
            risks.append('creation-mutation')
        result.append({'room': name, 'source': path.relative_to(ROOT).as_posix(), 'sha256': sha(path),
            'dimensions': room['roomSettings'], 'parentRoom': room.get('parentRoom'),
            'creationOrder': ordered, 'layers': room_layers,
            'creationCode': [{'path': p.relative_to(ROOT).as_posix(), 'sha256': sha(p)} for p in codes],
            'missing': [p.relative_to(ROOT).as_posix() for p in missing], 'reviewFlags': risks,
            'objects': [{'name': obj, 'parent': objects.get(obj, {}).get('parentObjectId'),
                         'mask': masks.get(obj)} for obj in sorted(dependencies)]})
    return {'format': 'tcc.source-room-audit', 'schemaVersion': 1,
            'claim': 'Structural audit only; no playability claim', 'rooms': result}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = audit()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(f'{len(result["rooms"])} rooms audited; '
          f'{sum(bool(room["missing"]) for room in result["rooms"])} contain unresolved references')


if __name__ == '__main__':
    main()
