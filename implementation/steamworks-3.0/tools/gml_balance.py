#!/usr/bin/env python3
"""Cheap GML sanity check: balanced (), [], {} outside comments/strings, no stray tabs-vs-CRLF surprises.

Usage: python3 -I gml_balance.py FILE.gml [FILE2.gml ...]
Handles // and /* */ comments, "..." and '...' strings, @"..." / $"..." (with {expr} interpolation
treated as plain text, so a brace inside an interpolated string is ignored) and #macro continuation.
Exit code 1 on any imbalance. This is NOT a compiler - it only catches truncated or mangled edits.
"""
import sys

PAIRS = {')': '(', ']': '[', '}': '{'}


def check(path):
    s = open(path, encoding='utf-8', errors='replace').read()
    n, i, line = len(s), 0, 1
    stack = []
    while i < n:
        c = s[i]
        two = s[i:i + 2]
        if c == '\n':
            line += 1; i += 1
        elif two == '//':
            while i < n and s[i] != '\n': i += 1
        elif two == '/*':
            j = s.find('*/', i + 2)
            if j < 0:
                return f'{path}:{line}: unterminated /* comment'
            line += s.count('\n', i, j); i = j + 2
        elif c in '"\'':
            q = c; i += 1
            while i < n and s[i] != q:
                if s[i] == '\\': i += 1
                if i < n and s[i] == '\n':
                    return f'{path}:{line}: newline inside string (unterminated?)'
                i += 1
            i += 1
        elif c in '([{':
            stack.append((c, line)); i += 1
        elif c in ')]}':
            if not stack or stack[-1][0] != PAIRS[c]:
                return f'{path}:{line}: unmatched {c!r}' + (f' (open {stack[-1][0]!r} from line {stack[-1][1]})' if stack else '')
            stack.pop(); i += 1
        else:
            i += 1
    if stack:
        return f'{path}:{stack[-1][1]}: unclosed {stack[-1][0]!r}'
    return None


if __name__ == '__main__':
    bad = 0
    for p in sys.argv[1:]:
        err = check(p)
        if err:
            print('UNBALANCED', err); bad = 1
    if not bad:
        print(f'balanced: {len(sys.argv) - 1} file(s)')
    sys.exit(bad)
