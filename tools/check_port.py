#!/usr/bin/env python3
"""Static release configuration checks. Runtime self-check is in scr_port_selfcheck.

The Steam section (steam_invariants) keeps the Steamworks 3.0 port honest: raw extension calls only inside
scripts/scr_steam_safe, no 2.x names or Steam async handlers left, a single relay for every native callback and
the invariants of the multiplayer transport. `python3 -I tools/check_port.py --steam-report` lists every Steam
problem and exits without running the configuration assertions.
"""
import json
from collections import defaultdict
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]


def load_yy(root, path):
    return json.loads(re.sub(r',\s*([}\]])', r'\1', (root / path).read_text()))


def yy(path):
    return load_yy(ROOT, path)


# ---------------------------------------------------------------------------------------------------------------------
# Steamworks 3.0 invariants (wrapper contract section 14, netcode design section 10.6). Only scripts/scr_steam_safe may
# call the extension; every other file talks to the tcc_steam_* wrappers. The gates are lexical: GameMaker reports an
# unknown function or constant only when the line RUNS, so this is the only static protection.
# ---------------------------------------------------------------------------------------------------------------------
SAFE_DIR = 'scripts/scr_steam_safe'
SAFE_FILE = SAFE_DIR + '/scr_steam_safe.gml'
API_FILE = 'scripts/Steamworks_API/Steamworks_API.gml'
GENERATED_DIRS = frozenset({'Steamworks_API', 'ExtensionCore_api'})        # extension scripts, never scanned
SOURCE_BASES = ('scripts', 'objects', 'rooms', 'timelines')

# Scripts the port added; GameMaker silently ignores a script that is not listed in the .yyp.
PORT_SCRIPTS = ('scr_steam_safe', 'scr_net_mock', 'scr_online_transport_selfcheck')
# Files that may use the check-only transport mock seam (CA-3, gate N-6).
MOCK_FILES = ('scr_steam_safe', 'scr_net_mock', 'scr_online_transport_selfcheck')
# Configurations that are never shipped; every other configuration must keep the extension Debug option off.
DEV_CONFIGS = frozenset({'Check', 'QA', 'iOSCheck'})
# Flags the transport may use: ReliableNoNagle / UnreliableNoNagle, always with AutoRestartBrokenSession (design 4.1).
ALLOWED_SEND_FLAGS = frozenset({'ReliableNoNagle', 'UnreliableNoNagle', 'AutoRestartBrokenSession'})

# 3.0 interface prefixes (one per Steamworks interface).
INTERFACE_PREFIXES = ('api|apps|friends|input|inventory|matchmaking|music|networking|parties|'
                  'remote_storage|screenshots|timeline|ugc|user|userstats|utils')

# (1) Raw 3.0 call. The lookbehind rejects `tcc_steam_x(` (preceded by a word char) and `obj.steam_x(`.
RAW_STEAM_30 = re.compile(r'(?<![\w$.])steam_(?:%s)_\w+\s*\(' % INTERFACE_PREFIXES)

# (2) Every other bare `steam_*` token must be a project-local name; anything else is a stale 2.x name
#     (the pre-3.0 initialised, lobby, net packet and getter/setter families) or an invented one. Comments and strings are
#     scanned too, so outside the wrapper no `steam_`-prefixed word may be written at all (design R9).
LOCAL_STEAM_NAMES = frozenset({
    'steam_api',                # flag name in a self-check text
    'steam_display',            # rich presence KEY string (Steam-reserved)
    'steam_player_group',       # rich presence KEY string
    'steam_player_group_size',  # rich presence KEY string
    'steam_is_available',       # availability flag
    'steam_id',                 # net player record member
    'steam_list',               # instance ds_list of subscribed ids
    'steam_name', 'steam_rank', 'steam_score', 'steam_userid',   # leaderboard row arrays
})
ANY_STEAM_TOKEN = re.compile(r'(?<![\w$.])steam_\w+')

# (3) Removed 2.x constants.
STALE_CONSTANTS = re.compile(
    r'(?<![\w$.])(?:ugc_(?:result|filetype|visibility|match|query)_\w+|lb_(?:sort|disp)_\w+|'
    r'ov_(?:friends|community|players|settings|gamegroup|achievements)|'
    r'steam_(?:lobby|net_packet|inventory_result)_\w+)\b')

# (4) Wrappers that were removed: a leftover caller is a runtime error, not a compile error.
REMOVED_WRAPPERS = re.compile(
    r'(?<![\w$.])tcc_steam_(?:get_user_persona_name|net_packet_get_data|net_packet_get_sender_id|'
    r'net_packet_get_size|net_set_auto_accept_p2p_sessions|ugc_get_item_update_progress)\b')

# (4a) The Async-Steam payload is gone: no "event_type" key literal (the built-in event_type variable is untouched).
ASYNC_KEY = re.compile(r'["\']event_type["\']')

# (4b) The relay and every __tcc_steam_ helper are private to scr_steam_safe.gml.
PRIVATE_NAMES = re.compile(r'(?<![\w$.])(?:tcc_steam_relay|__tcc_steam_\w+)')

WRAPPER_TOKEN = re.compile(r'(?<![\w$.])tcc_steam_\w+')
CALL_PAREN = re.compile(r'[ \t]*\(')
WRAPPER_DEF = re.compile(r'\bfunction\s+(tcc_steam_\w+)\s*\(')
PORT_MACRO = re.compile(r'(?<![\w$.])TCC_(?:STEAM_|AVATAR_|OVERLAY_|NET_)\w+')
RAW_STEAM_CALL_ANY = re.compile(r'(?<![\w$.])(steam_\w+)\s*\(')
SEND_FLAG = re.compile(r'\bSteamNetworkingSendFlags\.(\w+)')

_NOISE = re.compile(r'//[^\n]*|/\*.*?(?:\*/|\Z)|"(?:\\.|[^"\\\n])*"?|\'(?:\\.|[^\'\\\n])*\'?', re.S)


def strip_noise(src):
    """Comments and string contents blanked; offsets and line breaks are kept."""
    def blank(m):
        s = m.group(0)
        if s[0] == '/':
            return re.sub(r'[^\n]', ' ', s)
        if len(s) > 1 and s[-1] == s[0]:
            return s[0] + re.sub(r'[^\n]', ' ', s[1:-1]) + s[-1]
        return re.sub(r'[^\n]', ' ', s)
    return _NOISE.sub(blank, src)


def match_close(code, open_idx):
    """Index of the bracket that closes the one at open_idx, or -1."""
    depth = 0
    for i in range(open_idx, len(code)):
        c = code[i]
        if c in '([{':
            depth += 1
        elif c in ')]}':
            depth -= 1
            if depth == 0:
                return i
    return -1


def split_args(text):
    """Top-level comma split of an argument or parameter list; '' gives no entries."""
    parts, depth, cur = [], 0, []
    for c in text:
        if c in '([{':
            depth += 1
        elif c in ')]}':
            depth -= 1
        if c == ',' and depth == 0:
            parts.append(''.join(cur).strip())
            cur = []
        else:
            cur.append(c)
    last = ''.join(cur).strip()
    if parts or last:
        parts.append(last)
    return parts


def line_of(code, idx):
    return code.count('\n', 0, idx) + 1


def calls_of(code, name_regex):
    """Yield (name, line, args) for every call `name(...)` found by name_regex (group 1 = name) in a stripped code view."""
    for m in name_regex.finditer(code):
        open_idx = m.end() - 1
        close_idx = match_close(code, open_idx)
        if close_idx < 0:
            yield m.group(1), line_of(code, m.start()), None
        else:
            yield m.group(1), line_of(code, m.start()), split_args(code[open_idx + 1:close_idx])


def function_body(code, name):
    """Text between the braces of `function name(...) { ... }` in a stripped code view, or None."""
    m = re.search(r'\bfunction\s+%s\s*\(' % re.escape(name), code)
    if not m:
        return None
    close_paren = match_close(code, m.end() - 1)
    if close_paren < 0:
        return None
    i = code.find('{', close_paren)
    if i < 0:
        return None
    j = match_close(code, i)
    return code[i:j + 1] if j >= 0 else None


class Sources:
    """Every project GML file that must obey the Steam rules (the generated extension scripts are skipped)."""

    def __init__(self, root):
        self.root = root
        self.files = {}
        for base in SOURCE_BASES:
            for p in sorted((root / base).rglob('*.gml')):
                rel = p.relative_to(root)
                if any(part in GENERATED_DIRS for part in rel.parts):
                    continue
                self.files[rel.as_posix()] = p
        self._raw, self._code = {}, {}

    def raw(self, rel):
        if rel not in self._raw:
            self._raw[rel] = self.files[rel].read_text(encoding='utf-8', errors='replace')
        return self._raw[rel]

    def code(self, rel):
        if rel not in self._code:
            self._code[rel] = strip_noise(self.raw(rel))
        return self._code[rel]

    @staticmethod
    def in_safe(rel):
        return rel.startswith(SAFE_DIR + '/')

    @staticmethod
    def script_of(rel):
        parts = rel.split('/')
        return parts[1] if parts[0] == 'scripts' and len(parts) > 2 else None


def steam_scan(src):
    """Lexical gates 1-4b over every file outside SAFE. Returns kind -> [(path, line, text)]."""
    out = defaultdict(list)
    for rel in src.files:
        if src.in_safe(rel):
            continue
        for n, line in enumerate(src.raw(rel).split('\n'), 1):
            if RAW_STEAM_30.search(line):
                out['raw_30_call'].append((rel, n, line.strip()))
            stale = [m.span() for m in STALE_CONSTANTS.finditer(line)]
            for m in ANY_STEAM_TOKEN.finditer(line):
                if m.group(0) in LOCAL_STEAM_NAMES or RAW_STEAM_30.match(line, m.start()):
                    continue
                if any(a <= m.start() < b for a, b in stale):
                    continue                    # reported as stale_constant
                out['unknown_steam_token'].append((rel, n, m.group(0)))
            if stale:
                out['stale_constant'].append((rel, n, line.strip()))
            if REMOVED_WRAPPERS.search(line):
                out['removed_wrapper'].append((rel, n, line.strip()))
            if ASYNC_KEY.search(line):
                out['async_load_event_type'].append((rel, n, line.strip()))
            if PRIVATE_NAMES.search(line):
                out['private_name_used_outside_safe'].append((rel, n, line.strip()))
    return out


def api_callback_params(root):
    """Function name -> index of its `_callback` parameter, from the generated 3.0 GML API."""
    path = root / API_FILE
    if not path.is_file():
        return None
    text = path.read_text(encoding='utf-8', errors='replace').split('#export', 1)[0]
    out = {}
    for m in re.finditer(r'^function (steam_\w+)\(([^)]*)\)', text, re.M):
        params = [p.split('=')[0].strip() for p in m.group(2).split(',') if p.strip()]
        if '_callback' in params:
            out[m.group(1)] = params.index('_callback')
    return out


def relay_problems(src, callbacks):
    """Gate 6: Steam only ever receives the one named relay function, never a closure, method or other callable."""
    problems = []
    if callbacks is None:
        return [f'relay_rule: {API_FILE} is missing, the callback parameters cannot be checked']
    code = src.code(SAFE_FILE)
    for name, n, args in calls_of(code, RAW_STEAM_CALL_ANY):
        where = f'{SAFE_FILE}:{n}: {name}'
        if args is None:
            problems.append(f'unbalanced_steam_call: {where}')
            continue
        if any(re.search(r'\b(?:method|function)\b', a) for a in args):
            problems.append(f'closure_handed_to_steam: {where}')
        idx = callbacks.get(name)
        if idx is not None and idx < len(args) and args[idx] != 'tcc_steam_relay':
            problems.append(f'non_relay_callback: {where}: argument {idx + 1} is "{args[idx]}", expected tcc_steam_relay')
    return problems


def wrapper_problems(src):
    """Every tcc_steam_* name used outside SAFE is defined in SAFE and called with an argument count it accepts."""
    problems = []
    safe_code = src.code(SAFE_FILE)
    defs = {}
    for name, n, params in calls_of(safe_code, WRAPPER_DEF):
        if params is not None:
            defs[name] = (sum(1 for p in params if '=' not in p), len(params))
    for rel in src.files:
        if src.in_safe(rel):
            continue
        if 'tcc_steam_' not in src.raw(rel):
            continue
        code = src.code(rel)
        for m in WRAPPER_DEF.finditer(code):
            problems.append(f'wrapper_defined_outside_safe: {rel}:{line_of(code, m.start())}: {m.group(1)}')
        for m in WRAPPER_TOKEN.finditer(code):
            name, n = m.group(0), line_of(code, m.start())
            if code[:m.start()].rstrip().endswith('function'):
                continue
            if name not in defs:
                if not REMOVED_WRAPPERS.match(code, m.start()):          # already reported as removed_wrapper
                    problems.append(f'undefined_wrapper: {rel}:{n}: {name}')
                continue
            paren = CALL_PAREN.match(code, m.end())
            if not paren:
                continue
            open_idx = paren.end() - 1
            close_idx = match_close(code, open_idx)
            if close_idx < 0:
                continue
            count = len(split_args(code[open_idx + 1:close_idx]))
            lo, hi = defs[name]
            if not lo <= count <= hi:
                problems.append(f'wrapper_arity: {rel}:{n}: {name} called with {count}, expects {lo}..{hi}')
    return problems


def macro_problems(src):
    """The TCC_ constants the port introduced must exist wherever they are used."""
    defined = set()
    for rel in src.files:
        for m in re.finditer(r'^[ \t]*#macro[ \t]+(?:\w+:)?(\w+)', src.raw(rel), re.M):
            defined.add(m.group(1))
    problems = []
    for rel in src.files:
        if 'TCC_' not in src.raw(rel):
            continue
        code = src.code(rel)
        for m in PORT_MACRO.finditer(code):
            if m.group(0) not in defined:
                problems.append(f'undefined_macro: {rel}:{line_of(code, m.start())}: {m.group(0)}')
    return problems


def steam_api_index(root):
    """Functions {name: (min, max args)}, enums {name: members}, struct names and macros of the installed 3.0 API, or None."""
    path = root / API_FILE
    if not path.is_file():
        return None
    text = path.read_text(encoding='utf-8', errors='replace').split('#export', 1)[0]
    funcs = {}
    for m in re.finditer(r'^function (steam_\w+)\(([^)]*)\)', text, re.M):
        params = [p for p in m.group(2).split(',') if p.strip()]
        funcs[m.group(1)] = (sum(1 for p in params if '=' not in p), len(params))
    for f in load_yy(root, 'extensions/Steamworks/Steamworks.yy').get('files', []):
        for fn in f.get('functions', []):                    # the few natives called directly (steam_api_*)
            if fn['name'].startswith('steam_') and fn['name'] not in funcs:
                funcs[fn['name']] = (0, 99) if fn.get('argCount', 0) < 0 else (fn['argCount'], fn['argCount'])
    enums = {m.group(1): set(re.findall(r'^\s*([A-Za-z_]\w*)\s*(?:=|,|$)', m.group(2), re.M))
             for m in re.finditer(r'^enum (Steam\w+)\s*\{(.*?)^\}', text, re.M | re.S)}
    structs = set(re.findall(r'^function (Steam\w+)\(', text, re.M))
    macros = set(re.findall(r'^#macro (STEAM_\w+)', text, re.M))
    return funcs, enums, structs, macros


def api_problems(root, src):
    """Names the code uses exist in the installed 3.0 API: natives and their arity (only SAFE calls them), enum members,
    constructors and STEAM_ macros (any file). GameMaker would only fail when the line runs."""
    index = steam_api_index(root)
    if index is None:
        return [f'steam_api_missing: {API_FILE}']
    funcs, enums, structs, macros = index
    problems = []
    safe = src.code(SAFE_FILE)
    for m in re.finditer(r'(?<![\w$.])steam_\w+', safe):
        if m.group(0) not in funcs and m.group(0) not in LOCAL_STEAM_NAMES:
            problems.append(f'unknown_native: {SAFE_FILE}:{line_of(safe, m.start())}: {m.group(0)}')
    for name, n, args in calls_of(safe, RAW_STEAM_CALL_ANY):
        if name in funcs and args is not None and not funcs[name][0] <= len(args) <= funcs[name][1]:
            problems.append(f'native_arity: {SAFE_FILE}:{n}: {name} called with {len(args)}, expects {funcs[name][0]}..{funcs[name][1]}')
    for rel in src.files:
        if 'Steam' not in src.raw(rel) and 'STEAM_' not in src.raw(rel):
            continue
        code = src.code(rel)
        for m in re.finditer(r'(?<![\w$.])(Steam[A-Z]\w*)\.(\w+)', code):
            if m.group(1) not in enums:
                problems.append(f'unknown_steam_enum: {rel}:{line_of(code, m.start())}: {m.group(1)}')
            elif m.group(2) not in enums[m.group(1)]:
                problems.append(f'unknown_enum_member: {rel}:{line_of(code, m.start())}: {m.group(1)}.{m.group(2)}')
        for m in re.finditer(r'\bnew\s+(Steam\w+)\s*\(', code):
            if m.group(1) not in structs:
                problems.append(f'unknown_steam_struct: {rel}:{line_of(code, m.start())}: {m.group(1)}')
        for m in re.finditer(r'(?<![\w$.])STEAM_\w+', code):
            if m.group(0) not in macros:
                problems.append(f'unknown_steam_macro: {rel}:{line_of(code, m.start())}: {m.group(0)}')
    return problems


def pump_problems(src):
    """One pump (design X10): SAFE calls the extension pump exactly once, o_fullscreensystem drives it."""
    problems = []
    pump = [n for name, n, _ in calls_of(src.code(SAFE_FILE), RAW_STEAM_CALL_ANY) if name == 'steam_api_run_callbacks']
    if len(pump) != 1:
        problems.append(f'pump: {SAFE_FILE} must call the extension pump exactly once, found {len(pump)}')
    step, create = 'objects/o_fullscreensystem/Step_0.gml', 'objects/o_fullscreensystem/Create_0.gml'
    if step not in src.files or not re.search(r'(?<![\w$.])tcc_steam_update\s*\(', src.code(step)):
        problems.append(f'pump: {step} must call tcc_steam_update() every step')
    if create not in src.files or not re.search(r'(?<![\w$.])tcc_steam_register_callbacks\s*\(\s*true\s*\)', src.code(create)):
        problems.append(f'pump: {create} must call tcc_steam_register_callbacks(true)')
    for rel in src.files:
        if not src.in_safe(rel) and rel != step and re.search(r'(?<![\w$.])tcc_steam_update\s*\(', src.code(rel)):
            problems.append(f'pump: {rel}: only {step} may call tcc_steam_update()')
    return problems


def net_problems(root, src):
    """Gates N-1..N-8 (netcode design 10.6, CA-8)."""
    problems = []
    mp_rel = 'scripts/scr_online_multiplayer/scr_online_multiplayer.gml'
    if mp_rel not in src.files:
        return [f'net: {mp_rel} is missing']
    mp, safe = src.code(mp_rel), src.code(SAFE_FILE)
    # N-1 protocol and receive buffer
    m = re.search(r'#macro\s+NET_PROTOCOL\s+(\d+)', mp)
    if not m or m.group(1) != '3':
        problems.append('net_protocol: NET_PROTOCOL must be 3')
    m = re.search(r'#macro\s+NET_RECV_BUFFER_BYTES\s+(\d+)', mp)
    if not m or int(m.group(1)) < 524288:
        problems.append('net_recv_buffer: NET_RECV_BUFFER_BYTES must be >= 524288')
    if not re.search(r'global\.net_recv_buffer\s*=\s*buffer_create\(\s*NET_RECV_BUFFER_BYTES\s*,\s*buffer_fixed', mp):
        problems.append('net_recv_buffer: global.net_recv_buffer must be a fixed NET_RECV_BUFFER_BYTES buffer')
    # N-2 exactly one native send and one native receive, on the game channel
    sends = [a for name, n, a in calls_of(safe, RAW_STEAM_CALL_ANY) if name == 'steam_networking_messages_send_message_to_user']
    if len(sends) != 1 or sends[0] is None or len(sends[0]) != 6 or sends[0][3:5] != ['TCC_NET_CHANNEL', '0'] \
            or not re.fullmatch(r'[A-Za-z_]\w*', sends[0][5]):
        problems.append('net_send: exactly one native send, channel TCC_NET_CHANNEL, buffer offset 0, explicit count')
    recvs = [a for name, n, a in calls_of(safe, RAW_STEAM_CALL_ANY) if name == 'steam_networking_messages_receive_messages_on_channel']
    if len(recvs) != 1 or recvs[0] is None or len(recvs[0]) != 3 or recvs[0][0] != 'TCC_NET_CHANNEL' or recvs[0][2] != '1':
        problems.append('net_receive: exactly one native receive, channel TCC_NET_CHANNEL, count 1')
    # N-3 tick order (INV-B3): accept sessions before any send, receive after the sends
    body = function_body(mp, 'net_tick') or ''
    order = ['net_accept_pending_sessions', 'net_outbox_pump', 'net_send_player_state', 'net_send_ping',
             'net_receive_packets', 'net_update_ghosts', 'net_levelshare_tick']
    pos = []
    for fn in order:
        found = re.search(r'(?<![\w$.])%s\s*\(' % fn, body)
        pos.append(found.start() if found else -1)
    if -1 in pos or pos != sorted(pos):
        problems.append('net_tick_order: net_tick must call ' + ' -> '.join(order))
    # N-4 sends go only to lobby members (net_members also holds our own id)
    send_body = function_body(mp, 'net_send_to') or ''
    if not re.search(r'(?<![\w$.])net_lobby_member\s*\(', send_body) or re.search(r'\bnet_members\b', send_body):
        problems.append('net_send_to: the guard must be net_lobby_member(), not the net_members map')
    # N-5 send flags: only the NoNagle variants combined with AutoRestartBrokenSession
    for rel in src.files:
        if 'SteamNetworkingSendFlags' not in src.raw(rel):
            continue
        for flag in SEND_FLAG.findall(src.code(rel)):
            if flag not in ALLOWED_SEND_FLAGS:
                problems.append(f'net_flags: {rel}: SteamNetworkingSendFlags.{flag} (only ReliableNoNagle / UnreliableNoNagle | AutoRestartBrokenSession)')
    # N-6 the mock seam exists only in the Check configuration and only in its own files
    mock_body = function_body(safe, 'tcc_steam_net_mock') or ''
    if 'TCC_SELF_CHECK' not in mock_body:
        problems.append('net_mock: tcc_steam_net_mock() must return the mock only when TCC_SELF_CHECK is true')
    for rel in src.files:
        if src.script_of(rel) in MOCK_FILES:
            continue
        if re.search(r'(?<![\w$.])tcc_steam_net_mock\s*\(|\btcc_net_mock\b', src.code(rel)):
            problems.append(f'net_mock: {rel}: the transport mock seam is private to {", ".join(MOCK_FILES)}')
    # N-7 buffers owned by the outbox are freed with the lobby and at exit
    for fn in ('net_reset_lobby_state', 'net_cleanup'):
        if not re.search(r'(?<![\w$.])net_outbox_clear\s*\(', function_body(mp, fn) or ''):
            problems.append(f'net_outbox: {fn} must call net_outbox_clear()')
    # N-8 both new self-checks run from scr_port_selfcheck (the Check configuration is their only runner)
    sc_rel = 'scripts/scr_port_selfcheck/scr_port_selfcheck.gml'
    sc = src.code(sc_rel) if sc_rel in src.files else ''
    for fn in ('tcc_steam_selfcheck', 'scr_online_transport_selfcheck'):
        if not re.search(r'(?<![\w$.])%s\s*\(' % fn, sc):
            problems.append(f'selfcheck_wiring: {sc_rel} must call {fn}()')
    return problems


def project_problems(root):
    """Async event 69 is gone from every object, port scripts are in the project, Debug stays off for shipping."""
    problems = []
    for p in sorted((root / 'objects').rglob('Other_69.gml')):
        problems.append(f'async_steam_event_file: {p.relative_to(root).as_posix()}')
    for p in sorted((root / 'objects').rglob('*.yy')):
        rel = p.relative_to(root).as_posix()
        try:
            data = load_yy(root, rel)
        except ValueError as e:
            problems.append(f'unreadable_yy: {rel}: {e}')
            continue
        for ev in data.get('eventList', []):
            if ev.get('eventType') == 7 and ev.get('eventNum') == 69:
                problems.append(f'async_steam_event_entry: {rel}')
    project = load_yy(root, 'The Colorful Creature.yyp')
    listed = {r['id']['path'] for r in project['resources']}
    for name in PORT_SCRIPTS:
        path = f'scripts/{name}/{name}.yy'
        if path not in listed:
            problems.append(f'port_script_not_in_project: {path} is missing from The Colorful Creature.yyp')
        elif not (root / path).is_file() or not (root / f'scripts/{name}/{name}.gml').is_file():
            problems.append(f'port_script_missing_file: {path}')
    # (7) The Steam extension Debug option: Auto (or unset) in every shipped configuration. 3.0 relaunches a game that
    #     was not started by Steam unless Debug is Enabled, so developers enable it locally and never commit it.
    extension = load_yy(root, 'extensions/Steamworks/Steamworks.yy')
    option = next((o for o in extension.get('options', []) if o.get('name') == 'debug'), None)
    if option is None:
        problems.append('steam_debug_option: extensions/Steamworks/Steamworks.yy has no option named debug')
    else:
        values = (load_yy(root, 'options/extensions/Steamworks.json').get('configurables', {}).get(option['guid']) or {})
        effective = {}

        def walk(node, inherited):
            value = (values.get(node['name']) or {}).get('value', inherited)
            effective[node['name']] = value
            for child in node.get('children', []):
                walk(child, value)
        walk(project['configs'], option.get('defaultValue', 'Auto'))
        for cfg, value in sorted(effective.items()):
            if value == 'Enabled' and cfg not in DEV_CONFIGS:
                problems.append(f'steam_debug_enabled: options/extensions/Steamworks.json: configuration {cfg} resolves Debug to Enabled')
    return problems


def steam_invariants(root):
    """All Steam problems as 'kind: detail' strings; empty when every gate holds."""
    src = Sources(root)
    problems = []
    for kind, hits in steam_scan(src).items():
        problems += [f'{kind}: {rel}:{n}: {text[:140]}' for rel, n, text in hits]
    if SAFE_FILE not in src.files:
        return problems + [f'safe_missing: {SAFE_FILE}']
    problems += relay_problems(src, api_callback_params(root))
    problems += api_problems(root, src)
    problems += wrapper_problems(src)
    problems += macro_problems(src)
    problems += pump_problems(src)
    problems += net_problems(root, src)
    problems += project_problems(root)
    return problems


def steam_report():
    problems = steam_invariants(ROOT)
    kinds = defaultdict(list)
    for p in problems:
        kinds[p.split(':', 1)[0]].append(p)
    for kind, items in sorted(kinds.items()):
        print(f'== {kind}: {len(items)}')
        for item in items[:40]:
            print('   ' + item)
    print(f'{len(problems)} Steam problem(s)')
    return 1 if problems else 0


def main():
    project = yy('The Colorful Creature.yyp')
    resources = [r['id'] for r in project['resources']]
    names = [r['name'] for r in resources]
    assert len(names) == len(set(names)), 'Duplicate project resources'
    assert all((ROOT / r['path']).is_file() for r in resources), 'Missing resource'
    assert project['MetaData']['IDEVersion'] == '2026.0.0.16'
    steam = yy('extensions/Steamworks/Steamworks.yy')
    assert steam['ConfigValues']['Apple']['copyToTargets'] == '0'
    assert steam['ConfigValues']['Mobile']['copyToTargets'] == '0'
    assert steam['extensionVersion'] == '3.0.0'
    for extension, version in [('GMAdMob','2.0.2'),('GMGameCenter','2.0.2'),('GMGooglePlayServices','3.0.2')]:
        assert yy(f'extensions/{extension}/{extension}.yy')['extensionVersion'] == version
    android_release = next(c for c in project['configs']['children'] if c['name'] == 'Mobile')
    android_release = next(c for c in android_release['children'] if c['name'] == 'Android')
    assert any(c['name'] == 'AndroidRelease' for c in android_release['children'])
    assert any(c['name'] == 'SteamAndroid' for c in android_release['children'])
    for extension in ['GMAdMob', 'GMGooglePlayServices', 'TCCPrivacy']:
        assert yy(f'extensions/{extension}/{extension}.yy')['ConfigValues']['SteamAndroid']['copyToTargets'] == '0'
    assert yy('extensions/TCCAndroidSafeArea/TCCAndroidSafeArea.yy')['ConfigValues']['SteamAndroid']['copyToTargets'] == '8'
    admob = yy('options/extensions/GMAdMob.json')['configurables']
    production_ad_ids = {
        'fb7dfcc4-8a4f-480d-80a1-4353f93c9a2d': 'ca-app-pub-7108130195717311~2960588105',
        'b9284c2f-2652-43e0-8857-83c4b381d452': 'ca-app-pub-7108130195717311/1705849205',
        '4253cbf6-25ef-47ab-a865-b33f15272ba6': 'ca-app-pub-7108130195717311/1322705824',
        'b19aeb11-226a-4d31-a7b2-1960aa422c5d': 'ca-app-pub-7108130195717311/8981703993',
    }
    assert all(admob[guid] == {'AndroidRelease': {'value': ad_id}}
               for guid, ad_id in production_ad_ids.items())
    assert 'AdMob' not in names and 'GooglePlayServices' not in names
    ios = yy('options/ios/options_ios.yy')
    assert ios['option_ios_min_version'] == '15.0'
    assert ios['option_ios_orientation_landscape'] and ios['option_ios_orientation_landscape_flipped']
    assert not ios['option_ios_orientation_portrait'] and not ios['option_ios_orientation_portrait_flipped']
    assert ios['option_ios_launchscreen_image'] == '${options_dir}/shared/launch.png'
    assert ios['option_ios_launchscreen_image_landscape'] == '${options_dir}/shared/launch.png'
    mac = yy('options/mac/options_mac.yy')
    assert mac['option_mac_icon_png'] == '${options_dir}/shared/icon.png'
    assert mac['option_mac_splash_png'] == '${options_dir}/shared/launch.png'
    android = yy('options/android/options_android.yy')
    assert android['option_android_target_sdk'] == '36'
    assert android['option_android_minimum_sdk'] == '23'
    assert android['option_android_splash_time'] == 0
    assert android['option_android_gamepad_support'] is True
    steam_android = android['ConfigValues']['SteamAndroid']
    assert steam_android['option_android_package_product'] == 'tccsteam'
    assert steam_android['option_android_google_dynamic_asset_delivery'] == 'False'
    assert steam_android['option_android_google_services_app_id'] == ''
    assert steam_android['option_android_permission_internet'] == 'True'
    for path in (ROOT / 'options/ios/icons').rglob('*.png'):
        # PNG IHDR color type 2 is RGB without an alpha channel, required by Apple.
        assert path.read_bytes()[25] == 2, f'Apple icon must be opaque: {path}'
    assert '.'.join(android['option_android_package_' + k] for k in ['domain','company','product']) == 'com.infiland.tcc'
    catalog = json.loads((ROOT / 'docs/release/apple-achievements.json').read_text())
    assert len(catalog) <= 100
    assert len({c['apple_id'] for c in catalog}) == len(catalog)
    assert all(c['game_id'] not in ['OOPS','MAKE_LEVEL','PUBLISHER','RACES_MULTI','WORKSHOP_MASTER'] for c in catalog)
    ads = (ROOT / 'objects/Obj_AdMob/Create_0.gml').read_text()
    assert 'AdMobConsentDebugGeography.Disabled' in ads
    for p in list((ROOT/'scripts').rglob('*.gml')) + list((ROOT/'objects').rglob('*.gml')) + list((ROOT/'rooms').rglob('*.gml')):
        if p.parent.name.endswith('_API'):
            continue
        source = p.read_text()
        assert not re.search(r'\b(?:AdMob_|GooglePlayServices_)\w+\s*\(', source), f'Obsolete SDK call: {p}'
    problems = steam_invariants(ROOT)
    if problems:
        sys.exit(f'{len(problems)} Steam invariant(s) failed:\n  ' + '\n  '.join(problems))
    print(f'Configuration checks passed; {len(catalog)} Apple achievement candidates. Device/store checks remain separate.')


if __name__ == '__main__':
    sys.exit(steam_report() if '--steam-report' in sys.argv[1:] else main())
