#!/usr/bin/env python3
"""Check every Steamworks 3.0 identifier used by project GML against the installed 3.0 API.

Usage: python3 -I check_steam_names.py [--root PROJECT] [--files f1 f2 ...] [--summary]

Checks (outside scripts/*_API and extension folders):
  * steam_* function calls: name exists in Steamworks_API.gml / Steamworks.yy and the
    argument count fits the declared parameters
  * Steam* enum / struct names and Enum.MEMBER references exist
  * STEAM_* macros exist
  * steam_* identifiers that are still 2.x-only names are reported as OLD-API
Names preceded by '.' (struct fields), names declared in the same file (var / function / assignment)
and tcc_steam_* wrappers are ignored. Exit code 1 if any error is found.
"""
import argparse, json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT_DEFAULT = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
OLD_NAMES = os.path.join(HERE, 'old_api_names.txt')


def load_api(root):
    api = open(os.path.join(root, 'scripts/Steamworks_API/Steamworks_API.gml'), encoding='utf-8').read()
    body = api.split('#export')[0]
    funcs = {}
    for m in re.finditer(r'^function (steam_[A-Za-z0-9_]+)\(([^)]*)\)', body, re.M):
        params = [p.strip() for p in m.group(2).split(',') if p.strip()]
        req = sum(1 for p in params if '=' not in p)
        funcs[m.group(1)] = (req, len(params))
    yy = open(os.path.join(root, 'extensions/Steamworks/Steamworks.yy'), encoding='utf-8').read()
    for m in re.finditer(r'"argCount":(-?\d+),"args":\[[^\]]*\],"documentation":"[^"]*","externalName":"[^"]*","help":"","hidden":(true|false),"kind":\d+,"name":"(steam_[A-Za-z0-9_]+)"', yy):
        n = int(m.group(1))
        name = m.group(3)
        if name not in funcs:
            funcs[name] = (0, 99) if n < 0 else (n, n)
    enums = {}
    for m in re.finditer(r'^enum (Steam[A-Za-z0-9_]+)\s*\{(.*?)^\}', body, re.M | re.S):
        members = set(re.findall(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*(?:=|,|$)', m.group(2), re.M))
        enums[m.group(1)] = members
    structs = set(re.findall(r'^function (Steam[A-Za-z0-9_]+)\(', body, re.M))
    macros = set(re.findall(r'^#macro (STEAM_[A-Za-z0-9_]+)', body, re.M))
    old = set()
    if os.path.exists(OLD_NAMES):
        old = set(open(OLD_NAMES, encoding='utf-8').read().split())
    return funcs, enums, structs, macros, old


def strip_noise(src):
    """Blank out comments and string contents, keep offsets/newlines."""
    out = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        two = src[i:i + 2]
        if two == '//':
            j = src.find('\n', i)
            j = n if j < 0 else j
            out.append(' ' * (j - i)); i = j
        elif two == '/*':
            j = src.find('*/', i + 2)
            j = n if j < 0 else j + 2
            out.append(''.join(ch if ch == '\n' else ' ' for ch in src[i:j])); i = j
        elif c == '"' or c == "'":
            q = c; j = i + 1
            while j < n and src[j] != q and src[j] != '\n':
                if src[j] == '\\': j += 1
                j += 1
            j = min(j + 1, n)
            out.append(q + ' ' * max(0, j - i - 2) + (q if j - i >= 2 else '')); i = j
        else:
            out.append(c); i += 1
    return ''.join(out)


def count_args(code, open_idx):
    depth, i, n, commas, nonempty = 0, open_idx, len(code), 0, False
    while i < n:
        c = code[i]
        if c in '([{':
            depth += 1
        elif c in ')]}':
            depth -= 1
            if depth == 0:
                return (commas + 1) if nonempty else 0
        elif c == ',' and depth == 1:
            commas += 1; nonempty = True
        elif depth >= 1 and not c.isspace() and not (depth == 1 and c == '('):
            nonempty = True
        i += 1
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', default=ROOT_DEFAULT)
    ap.add_argument('--files', nargs='*')
    ap.add_argument('--summary', action='store_true')
    a = ap.parse_args()
    root = a.root
    funcs, enums, structs, macros, old = load_api(root)
    if a.files:
        files = [os.path.join(root, f) if not os.path.isabs(f) else f for f in a.files]
    else:
        files = []
        for d in ('scripts', 'objects', 'rooms'):
            for dp, _, fs in os.walk(os.path.join(root, d)):
                if re.search(r'(_API|Steamworks_[A-Za-z]+)$', dp) and 'scr_' not in dp:
                    continue
                files += [os.path.join(dp, f) for f in fs if f.endswith('.gml')]
    errors, warns = [], []
    for p in sorted(files):
        rel = os.path.relpath(p, root)
        if rel.startswith('scripts/Steamworks_API') or rel.startswith('scripts/ExtensionCore_api'):
            continue
        src = open(p, encoding='utf-8', errors='replace').read()
        code = strip_noise(src)
        declared = set(re.findall(r'(?:\bvar\s+|\bstatic\s+|\bfunction\s+|\bglobalvar\s+)(steam_[A-Za-z0-9_]+)', code))
        declared |= set(re.findall(r'^\s*(steam_[A-Za-z0-9_]+)\s*=[^=]', code, re.M))
        declared |= set(re.findall(r'\bvar\s+[^;]*?\b(steam_[A-Za-z0-9_]+)\s*=', code))
        line_of = lambda idx: code.count('\n', 0, idx) + 1
        for m in re.finditer(r'(?<![A-Za-z0-9_.])(steam_[A-Za-z0-9_]+)\b(\s*\()?', code):
            name = m.group(1)
            if name in declared:
                continue
            is_call = bool(m.group(2))
            if name in funcs:
                if is_call:
                    # skip declarations "function name("
                    pre = code[max(0, m.start() - 12):m.start()]
                    if re.search(r'function\s*$', pre):
                        continue
                    n = count_args(code, m.end() - 1)
                    lo, hi = funcs[name]
                    if n is not None and not (lo <= n <= hi):
                        errors.append(f'{rel}:{line_of(m.start())}: ARGS {name} called with {n}, expects {lo}..{hi}')
                continue
            if name in old and name not in funcs:
                errors.append(f'{rel}:{line_of(m.start())}: OLD-API {name}')
            elif name in macros:
                continue
            else:
                warns.append(f'{rel}:{line_of(m.start())}: UNKNOWN {name}{"(" if is_call else ""}')
        for m in re.finditer(r'(?<![A-Za-z0-9_.])(Steam[A-Z][A-Za-z0-9_]*)\b(?:\.([A-Za-z_][A-Za-z0-9_]*))?', code):
            ename, member = m.group(1), m.group(2)
            if ename in enums:
                if member and member not in enums[ename]:
                    errors.append(f'{rel}:{line_of(m.start())}: ENUM-MEMBER {ename}.{member} does not exist')
            elif ename in structs:
                continue
            else:
                warns.append(f'{rel}:{line_of(m.start())}: UNKNOWN-TYPE {ename}')
        for m in re.finditer(r'(?<![A-Za-z0-9_.])(STEAM_[A-Z0-9_]+)\b', code):
            if m.group(1) not in macros:
                errors.append(f'{rel}:{line_of(m.start())}: UNKNOWN-MACRO {m.group(1)}')
    if a.summary:
        kinds = {}
        for e in errors: kinds.setdefault(e.split(': ')[1].split(' ')[0], 0); kinds[e.split(': ')[1].split(' ')[0]] += 1
        print(json.dumps({'errors': len(errors), 'warnings': len(warns), 'by_kind': kinds, 'files_checked': len(files)}))
    else:
        for e in errors: print('ERROR', e)
        for w in warns: print('WARN ', w)
        print(f'{len(errors)} errors, {len(warns)} warnings, {len(files)} files checked')
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
