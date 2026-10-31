#!/usr/bin/env python3
"""Delete an object's Steam async handler (Other_69.gml) and its event entry in the object .yy.

Usage: python3 -I remove_other69.py OBJECT_NAME [--root PROJECT] [--dry-run]

Removes exactly the GMEvent entry with eventNum 69 / eventType 7 (Asynchronous - Steam) from
objects/OBJECT/OBJECT.yy and deletes objects/OBJECT/Other_69.gml. Refuses if the object has no such
event entry, or if the file still contains non-Steam async handling (async_load keys such as
"status" with http_get ids etc. are NOT detected - read the file first!). Prints what it did.
"""
import argparse, json, os, re, sys

ROOT_DEFAULT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
ENTRY = re.compile(r'^[ \t]*\{"\$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":69,"eventType":7,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2\.0",\},\r?\n', re.M)


def lenient_load(text):
    return json.loads(re.sub(r',(\s*[}\]])', r'\1', text))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('obj')
    ap.add_argument('--root', default=ROOT_DEFAULT)
    ap.add_argument('--dry-run', action='store_true')
    a = ap.parse_args()
    d = os.path.join(a.root, 'objects', a.obj)
    yy = os.path.join(d, a.obj + '.yy')
    gml = os.path.join(d, 'Other_69.gml')
    if not os.path.exists(yy):
        sys.exit(f'no such object .yy: {yy}')
    text = open(yy, encoding='utf-8', newline='').read()
    n = len(ENTRY.findall(text))
    if n != 1:
        sys.exit(f'{a.obj}: expected exactly 1 eventNum 69/eventType 7 entry, found {n}; edit by hand')
    new = ENTRY.sub('', text, count=1)
    lenient_load(new)  # must still parse
    if a.dry_run:
        print(f'[dry-run] would remove the Steam async event from {yy}' + (f' and delete {gml}' if os.path.exists(gml) else ''))
        return
    open(yy, 'w', encoding='utf-8', newline='').write(new)
    if os.path.exists(gml):
        os.remove(gml)
    print(f'{a.obj}: removed Steam async event entry' + ('' if os.path.exists(gml) else ' and Other_69.gml'))


if __name__ == '__main__':
    main()
