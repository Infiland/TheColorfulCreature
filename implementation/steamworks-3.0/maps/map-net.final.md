# FINAL migration map: legacy P2P networking (steam_net_*) -> Networking Messages (steam_networking_messages_*)

Project: /Users/infi/Documents/Github/TheColorfulCreature, branch feat/steamworks-3-0. Steamworks extension 2.1.6 -> 3.0.0 (SDK 1.65).
Read-only phase: nothing in the project was edited. All project line numbers are the project as it is today.
This file replaces map-net.md. The 9 entries are in section 5; section 2 records what was decided on every dispute.

Abbreviations (all paths absolute under the project or the scratchpad `SP` =
<scratchpad>):
- API  = scripts/Steamworks_API/Steamworks_API.gml (never print its last line)
- CPP  = SP/gmext/src/source/Steamworks_gml/extensions/steamworks/source/src/gm_steam_networking_messages.cpp (ground truth where the 3.0 docs are wrong/silent)
- WIRE = SP/gmext/src/source/Steamworks_gml/extensions/steamworks/source/code_gen/core/GMExtWire.h
- CORE = scripts/ExtensionCore_api/ExtensionCore_api.gml (how GML callbacks are actually run)
- DOC  = SP/gmext/src/docs/networking.js (3.0 docs source)
- OLD  = 2.x C++ source SP/port/old2x_head/steam_networking.cpp (new in this pass; ground truth for 2.x behaviour) and 2.x docs SP/port/old2x/extensions/Steamworks/docs/networking.html
- HDR  = /Users/infi/Documents/sdk/public/steam/steamnetworkingtypes.h and isteamnetworkingmessages.h. This local SDK is v1.61 (Readme.txt, Nov 2024); the extension needs 1.65 (gmext README.md:28). The flag/enum values used here (1, 8, 9, 32) are identical in the 3.0 enum at API:1622, but the header text is 1.61 text.
- CORE-MAP = SP/port/map-core.md (owns steam_api_run_callbacks, the guard helper and the game_restart risk)

## 1. TL;DR

1. All nine in-scope old identifiers (7 functions + 2 constants) are GONE in 3.0. Every project use goes through `tcc_steam_net_*` wrappers (scripts/scr_steam_safe/scr_steam_safe.gml:186-217) except ONE raw use of the two constants at scripts/scr_online_multiplayer/scr_online_multiplayer.gml:607.
2. IDs do NOT become structs here. Every Networking Messages function takes/returns a plain UInt64 number (`buffer_u64`, `is_numeric` check). `SteamNetworkingMessage.steam_id_remote` is an int64-like number (API:11929), the same kind of value as `steam_user_get_steam_id()` (API:14730). `string(_sender)` map keys and `== global.net_my_steam_id` keep working.
3. The pull model survives but changes shape: `steam_net_packet_receive()` + 3 getters becomes ONE call `steam_networking_messages_receive_messages_on_channel(0, buffer, 1)` returning an ARRAY of `SteamNetworkingMessage` structs; payload bytes are copied into a non-growing buffer YOU own.
4. There is no auto-accept switch. 2.x accepted requests from members of the live Steam lobby (OLD:12, 31-38). In 3.0 nothing is accepted unless you call `accept_session_with_user`, or you SEND to that peer (which implicitly accepts, HDR isteamnetworkingmessages.h:46). The project pings every lobby member every 2 s (NET_PING_INTERVAL_MS, scr_online_multiplayer.gml:679-680), so the session-request callback is a latency optimisation plus an explicit membership gate, not a hard requirement.
5. Silent-breakage traps that compile fine: (a) omitting `_buffer_count` on send transmits the WHOLE ALLOCATED buffer; (b) send returns an EResult number, not a bool: `if (!net_send_to(...)) break;` at scripts/scr_online_levelshare/scr_online_levelshare.gml:177 would treat every failure as success unless the wrapper compares `== SteamApiResult.Ok`; (c) the receive buffer must be pre-sized to 524288 bytes or every 8236-byte level chunk is dropped; (d) a non-numeric id / missing buffer makes the 3.0 wrapper call `show_error(..., true)` (fatal) where 2.x returned false; (e) every raw old constant reference left anywhere fails the build.
6. Callbacks are NOT run inside `steam_api_run_callbacks()` (see D1): Steam posts them there, the extension queues them, and the GML body runs later from a `time_source_global` ticker with `self` = an empty struct. The project design below therefore keeps the callback body trivial (push the id on a global queue) and decides in `net_tick`.
7. No Other_69 (Async Steam event) handler consumes anything from this domain (objects/o_networkmanager/Other_69.gml -> net_handle_async_steam, scr_online_multiplayer.gml:1017-1150, handles lobby/avatar/ugc events only).
8. Required release item: bump `NET_PROTOCOL` 2 -> 3 (scr_online_multiplayer.gml:14). Legacy ISteamNetworking and ISteamNetworkingMessages are different transports; see D11.
9. Recommendation unchanged: Networking Messages is the right 1:1 replacement (section 7).

## 2. Decisions on the disputes

Verdict key: ACCEPT = dispute right, map changed as proposed; PARTIAL = right in part; REJECT = dispute wrong, map keeps its position (reason given).

**D1 Callback delivery (disputes 1, 8, 9; severity nit/risky): ACCEPT.**
Native `STEAM_CALLBACK` handlers (CPP:55-86, `cb.call(...)` at 71 and 83) only enqueue: `GMFunction::call` -> `call_with_args` -> `DispatchQueue::dispatch` (WIRE:1782-1820, 1684-1693; native export SteamworksInternal_native.cpp:9-16). The GML body runs later from the ticker `time_source_create(time_source_global, 1, time_source_units_frames, ...)` (CORE:245-252), which calls `__ext_core_function_dispatch_calls` (CORE:298) and executes `with (_dummy_context) method_call(_ref[0], _args)` (CORE:350, `_dummy_context = {}`). `steam_api_run_callbacks()` is still REQUIRED, because `SteamAPI_RunCallbacks` is what makes Steam fire the C++ handler (SP/gmext/.../src/gm_steam_api.cpp:300-304), but the GML function does not run inside that call. The statements "Every registered callback runs during this call, on the calling thread" (DOC api.js:75) and "delivered by steam_api_run_callbacks" (getting_started.md:41-45) are inaccurate for GML. CORE-MAP section 7.6 reached the same conclusion independently. Consequences for this domain: (1) `self` inside `net_on_session_request` is an empty struct, use only globals and script functions; (2) the callback runs at the time-source phase, not inside `o_networkmanager` Step and not behind `timing_instance_step()`; do not assume `timing_tick_id()` advanced since the last `net_tick`; (3) expect >= 1 frame latency; (4) the ticker only runs while a callback is registered (`pending > 0`, CORE:246-251), which is always true while the session-request callback is set.

**D2 "each set call registers a new native handle" (disputes 2, 11): ACCEPT (wording).**
`__ext_core_function_register` keys the handle on `int64(ptr(_callable))` and only bumps a ref count when the same callable is registered again (CORE:271-290; API:23627 uses it). The native side stores ONE `GMFunction` per kind (CPP:88-114); replacing it destroys the old `Handle`, which queues a Release (WIRE:1811 `Handle::release`, command 2, CORE:352-358). So re-setting the same function is refcount +1 then -1: no leak, but pointless. Keep the one-shot guard.

**D3 clear_* natives need a guard (disputes 3, 10): ACCEPT.**
`steam_networking_messages_clear_callback_session_request/_failed` are raw extension natives (extensions/Steamworks/Steamworks.yy:589, 591; API:23637 and 23662 "Skipping function ... (no wrapper is required)"), as are `steam_api_is_initialized` (Steamworks.yy:22) and `steam_api_run_callbacks` (Steamworks.yy:26). The set_callback_* functions are protected by `__Steamworks_is_available()` (API:23618-23635, 24764), the clear_* natives are not. iOS/Android/MAS builds ship no Steam binary (tools/check_port.py:22-23 asserts `copyToTargets == '0'` for Apple and Mobile) and `net_cleanup` runs on every platform (objects/o_networkmanager/CleanUp_0.gml:7). Any call must go through a wrapper whose FIRST term is `platform_steam()`. NEW fact: the extension's `final` function `steam_api_shutdown` already clears both session callbacks (gm_steam_api.cpp:113-150, 314), so the clear in `net_cleanup` is NOT needed; this map does not call it from `net_cleanup`. The guarded clear wrapper is kept only for the game_restart mitigation (D10).

**D4 raw accept call inside the callback (dispute 4): ACCEPT.**
The project convention (and mobile safety) is: Steam is reached only through `tcc_steam_*` wrappers. tools/check_port.py:79 only covers a fixed prefix list that includes neither `steam_net_` nor `steam_networking_`, so a raw call would pass the check yet break the convention. Added wrapper `tcc_steam_net_accept_session`. The regex extension is already proposed by CORE-MAP section 6 (`steam_(?:api|apps|...|networking|...)_\w*\(`), reference it; do not add a second one.

**D5 header evidence for AutoRestartBrokenSession / NoNagle (dispute 5): ACCEPT, with a version caveat.**
The local header describes the flag (HDR steamnetworkingtypes.h:1029-1048) and the NoConnection consequence (isteamnetworkingmessages.h:76-81). It also states: `ReliableNoNagle` "is equivalent to k_EP2PSendReliable" (steamnetworkingtypes.h:1011-1012), plain `Reliable` is "more like k_EP2PSendReliableWithBuffering" (1006-1007), and `Unreliable` "is not exactly the same as k_EP2PSendUnreliable! You probably want ... UnreliableNoNagle" (952-954). Caveat: the local SDK is v1.61 and 1.65 is required; the integer values 0/1/8/9/32 match the 3.0 enum (API:1622) so the semantics carry over. Confidence of both constant entries raised to HIGH. Only the 3.0 gml docs are silent on the flag.

**D6 "macros defined in scr_steam_safe.gml" (dispute 6): ACCEPT.**
`grep TCC_NET_SEND` finds nothing outside the proposal. They are to be defined (section 4). The wrapper's current 4th parameter `_a3` (packet type, scr_steam_safe.gml:206) becomes the SendFlags argument; the raw `steam_net_packet_type_*` constants at scr_online_multiplayer.gml:607 are replaced by the macros.

**D7 call-site completeness (dispute 7): ACCEPT.**
Added indirect callers of `net_send_to`: `net_send_hello` at scr_online_multiplayer.gml:728 (inside the HELLO handler) and 1097 (`net_send_hello(-1,false)`), `net_send_bye` at 377, and the Endless Run picks senders scripts/scr_online_session/scr_online_session.gml:962, 980, 1061 (all via `net_er_send_picks`, whose single send is 1034). Corrected a line in the original: `net_broadcast` is defined at 609-611 (the loop is on 610). Only levelshare.gml:177 uses the return value. No send is missed because everything funnels through `net_send_to` (605).

**D8 C++ line citations and the "{}" wording (disputes 8/13): ACCEPT.**
Verified with `cat -n`: send_message_to_user 116-158 (offset check 130-133, `actual_count == 0` at 143, range check 145-148, SendMessageToUser at 156); receive 161-229 (STEAM_GUARD_RET at 165, cap 65536 at 174-178, "output buffer exhausted" at 195-201, write at 203-208, fields 211-220, Release at 225); accept 231-240; close_session 242-251; close_channel 253-262; callback class 55-86; set/clear 88-114. "Not initialised" returns an EMPTY ARRAY on the GML side (`STEAM_GUARD_RET({})` is an empty std::vector, GMSteamworks.h:20-24; GML wrapper API:23752-23760 builds `[]`); "extension missing" returns `undefined`. `steam_user_get_steam_id` is typed `Real` in the JSDoc but returns `buffer_read(buffer_u64)` (API:14742); harmless for this domain.

**D9 receive cap "512 KB, DOC RecvMaxMessageSize" (dispute 13): PARTIAL.**
Right that DOC networking.js:663 gives no number. But the figure IS documented locally: HDR steamnetworkingtypes.h:1160-1167 "Default is 512k (524288 bytes)" for RecvMaxMessageSize, and "if a client attempts to send us a message larger than this, the connection will be immediately closed"; send buffer default 512k at 1142-1145; max send size 512*1024 at 832; API:195 `STEAM_NETWORKING_SOCKETS_MAX_MESSAGE_SIZE_SEND = 524288`. Status: verified against the 1.61 header, not re-verified for 1.65, and it cannot be changed from GML (no SetConfigValue exposed). Design is unchanged and safe either way: a 524288-byte buffer holds anything Steam accepts by default, and the existing `_size > NET_CHUNK_MAX_SIZE -> continue` discards oversize in GML. A peer that sends > 512 KB gets its connection closed by Steam (never reaches GML).

**D10 game_restart / re-register (disputes 2/8, severity risky): ACCEPT the criticism, DOWNGRADE the original remedy to unverified.**
The original said resetting `global.net_p2p_accept = false` in `net_game_restart` re-registers after a restart. Analysis of CORE: the handle map (`__ext_core_function_map`, CORE:227) and the dispatcher (`__Steamworks_get_dispatcher`, API:24758) are function statics. Case A (statics + time source survive restart, `steam_api_shutdown` NOT run): nothing is needed, a re-register of the same global function only bumps the refcount. Case B (statics reset while native still holds the old handle): a later Execute for the unknown handle logs "BAD PACKET" and `continue`s WITHOUT consuming its argument bytes (CORE:333-338), which desyncs the rest of that frame's packet; and re-registering the same function would create a fresh entry with refcount 1 that the old native handle's Release then drops to 0 (callback dead). Case C (the runner calls the extension `final` = `steam_api_shutdown` on restart): all native callback slots are cleared, `steam_api_is_initialized()` becomes false (CORE-MAP section 7.1, HIGH RISK, runtime test pending), and `global.net_p2p_accept` (still true) would prevent re-registration. So whether any reset helps depends on an unverifiable runtime fact. Reasoned best-effort mitigation, NOT a verified fix: in `objects/o_networkmanager/CleanUp_0.gml`, inside the existing `net_restarting` branch, call `tcc_steam_net_clear_session_callbacks()` and set `global.net_p2p_accept = false`, so `net_tick` registers again on the first tick after the restart. Effect per case: helps in C (re-registers after the shutdown wiped the slot), neutral in A (the same global function only bumps the refcount), and in B it is NOT a fix: the native dispatch queue lives in the loaded DLL and survives a restart, the clear queues a Release for handle X that probably is still pending after the restart, the fresh ref map then gets X with refcount 1 from the re-register, and the stale Release can drop it to 0 (entry deleted) so the next request logs BAD PACKET and desyncs that frame (CORE:271-290, 333-338, 352-358). Whether that Release is drained before the re-register depends on boot order and on `ptr(fn)` being stable across the restart; neither is knowable statically. (Putting the mitigation in `net_game_restart` is wrong: the same step's `net_tick` would re-register before the restart takes effect.) Failure mode if the callback ends up dead: no accept callback after the ending; the project still works because outgoing pings implicitly accept lobby members within NET_PING_INTERVAL_MS (2 s). The cross-domain hazard (every 3.0 callback after restart, not just this one) is recorded in section 9 and is decided only by the runtime test in section 8.5.

**D11 NET_PROTOCOL / mixed lobbies (dispute 12): ACCEPT, required for the release.**
`NET_PROTOCOL` is `2` at scr_online_multiplayer.gml:14. It is written into the lobby (`proto`, 485), compared on join (1078-1085, "NET_VERSION_MISMATCH"), written in HELLO (196) and checked on decode (216), and is the `v` field of the session descriptor (scripts/scr_online_session/scr_online_session.gml:295, 370, 400; mismatch returns false). Bump to 3 in the release that switches transport, so a 1.3.x client (legacy P2P) and a 3.0 client never share a lobby in which neither hears the other. The smoke test at scr_online_multiplayer.gml:1251 uses the macro and needs no edit. (That the legacy and Messages transports cannot interoperate is assumed, not verifiable locally.)

**D12 "UnreliableNoNagle is the documented equivalence" (dispute 14): REJECT the proposed fix (keep NoNagle), accept the nuance.**
The proposal says plain `Unreliable` (0) is "the documented 1:1 match". It is the numeric match, but Valve's migration note says the opposite for behaviour: HDR steamnetworkingtypes.h:952-954 "This is not exactly the same as k_EP2PSendUnreliable! You probably want k_ESteamNetworkingSendType_UnreliableNoNagle". 2.x passed the constant straight into `SendP2PPacket` as `k_EP2PSendUnreliable` (OLD:78-83, 104-109, 131). So `UnreliableNoNagle` stays the migration mapping. Nuance accepted: the 2.x docs promise no immediacy for `unreliable`, and the header's own NOTE (964-968) says not to disable Nagle just to be faster; plain `Unreliable` is a legitimate later tuning choice for the 20 Hz state packets, not the equivalence.

**D13 packet_send/receive entries silent on version compat (dispute 12 second part): ACCEPT** (folded into D11 and into the send/receive entries' gotchas).

### New findings of this pass (not raised by the verifiers)

- N1 (resolves an old unknown): the 2.x default packet type when the argument is omitted is `k_EP2PSendReliable` (OLD:73, `EP2PSend steam_net_packet_type = k_EP2PSendReliable;`). So the wrapper default must be reliable, which matches `TCC_NET_SEND_RELIABLE`.
- N2: 2.x auto-accept checked the LIVE Steam lobby member list at request time (OLD:31-38, `GetLobbyMemberByIndex(steam_lobby_current, i)`), and also raised an async event `p2p_session_request` that no project code read. 3.0 gating should likewise consult fresh membership: `net_refresh_members()` (throttled) before deciding.
- N3: implicit accept by sending (HDR isteamnetworkingmessages.h:46) plus the 2 s ping broadcast means the session-request callback only shortens the first delivery to a joiner from <= 2 s to < 1 tick.
- N4: "requests are re-posted periodically while the peer keeps sending" is stated in the local header (isteamnetworkingmessages.h:93-95), not only in DOC.
- N5: the 2.x receive had no size cap (`malloc(size)` per packet, OLD:157) and `get_data` auto-grew the destination (`BufferWriteContent(..., true)`, OLD:184); both are gone in 3.0 (non-growing, fixed 524288 buffer).
- N6: `session_failed` registration is optional. `AutoRestartBrokenSession` already covers recovery and the project reacts to nothing in it; register it, if at all, as log-only through a guarded wrapper. Not registering it means one fewer callback exposed to the restart question in D10. This map does NOT register it.

## 3. Design of the session handling (replaces the direct-accept sketch of the original map)

Because the callback body runs outside the simulation phase with an empty `self` (D1), it only records the requester; `net_tick` decides. No `net_refresh_members()` or `net_remove_player()` is ever invoked from the extension's dispatcher.

```gml
// scr_online_multiplayer.gml  (init next to global.net_p2p_accept in net_init, 274; also reset in net_reset_lobby_state, 357)
global.net_session_requests = [];

/// Registered once through tcc_steam_net_set_session_request_callback(). Runs from the extension's time-source
/// dispatcher with an empty `self`: touch only globals/script functions and defer the decision to net_tick.
function net_on_session_request(_request) {
    if (!variable_global_exists("net_ready") || !global.net_ready || !global.net_active) return;
    if (!is_struct(_request)) return;
    var _id = _request.steam_id_remote;
    if (!is_numeric(_id) || _id == 0) return;
    var _queue = global.net_session_requests;
    if (array_length(_queue) >= 32) return;                 // Steam re-posts while the peer keeps sending
    for (var _i = 0; _i < array_length(_queue); ++_i) if (_queue[_i] == _id) return;
    array_push(_queue, _id);
}

/// Called from net_tick (simulation phase), after the registration block.
function net_accept_pending_sessions() {
    var _queue = global.net_session_requests;
    if (array_length(_queue) == 0) return;
    global.net_session_requests = [];
    for (var _i = 0; _i < array_length(_queue); ++_i) {
        var _id = _queue[_i];
        if (!net_lobby_member(_id)) {
            // A newcomer can beat Steam's membership update: refresh at most once per tick (same throttle as net_receive_packets, 700-702).
            if (global.net_refresh_forced_tick == timing_tick_id()) { array_push(global.net_session_requests, _id); continue; }
            global.net_refresh_forced_tick = timing_tick_id();
            net_refresh_members();
        }
        if (net_lobby_member(_id)) tcc_steam_net_accept_session(_id);
    }
}
```
and the one-shot block in `net_tick` (scr_online_multiplayer.gml:532-536) becomes:
```gml
if (!global.net_p2p_accept) {
    // Nothing is auto-accepted in 3.0: lobby members are accepted in net_accept_pending_sessions().
    if (tcc_steam_net_set_session_request_callback(net_on_session_request)) global.net_p2p_accept = true;
}
net_accept_pending_sessions();
```
Non-members are never accepted (the old lobby-only rule), and since the project never sends to non-members they are not implicitly accepted either. Keep the `net_lobby_member` check in `net_receive_packets` (defence in depth: a member removed after acceptance still has an open session until `net_remove_player` closes it).

## 4. Wrapper layer (scripts/scr_steam_safe/scr_steam_safe.gml)

All wrappers keep `platform_steam()` FIRST: `steam_api_is_initialized` and the clear_* functions are raw natives (D3). `steam_initialised()` does not exist in 3.0; the guard text is `platform_steam() && steam_api_is_initialized()` as in CORE-MAP.

```gml
#macro TCC_NET_SEND_RELIABLE   (SteamNetworkingSendFlags.ReliableNoNagle   | SteamNetworkingSendFlags.AutoRestartBrokenSession)   // 41
#macro TCC_NET_SEND_UNRELIABLE (SteamNetworkingSendFlags.UnreliableNoNagle | SteamNetworkingSendFlags.AutoRestartBrokenSession)   // 33

// Replaces 186-189 (same name, same arity)
function tcc_steam_net_close_p2p_session(_a0) {
    if (platform_steam() && steam_api_is_initialized() && is_numeric(_a0) && _a0 != 0) return steam_networking_messages_close_session_with_user(_a0);
    return false;
}
// DELETE tcc_steam_net_packet_get_data (190-193), _get_sender_id (194-197), _get_size (198-201): fields of the message struct now.

// Replaces 202-205. Pulls at most ONE packet on channel 0 into _a0 (must be allocated at 524288, see section 5.2). Returns the SteamNetworkingMessage struct or undefined.
function tcc_steam_net_packet_receive(_a0) {
    if (platform_steam() && steam_api_is_initialized() && buffer_exists(_a0)) {
        var _messages = steam_networking_messages_receive_messages_on_channel(0, _a0, 1);
        if (is_array(_messages) && array_length(_messages) > 0) return _messages[0];
    }
    return undefined;
}

// Replaces 206-213. _a2 = byte count (REQUIRED, >= 1). _a3 = SteamNetworkingSendFlags; default reliable as in 2.x (OLD:73). Returns true only when the result is Ok.
function tcc_steam_net_packet_send(_a0, _a1, _a2, _a3 = undefined) {
    if (platform_steam() && steam_api_is_initialized()) {
        if (!is_numeric(_a0) || _a0 == 0 || !buffer_exists(_a1) || !is_numeric(_a2)) return false;   // 3.0 would show_error() fatally
        var _count = min(_a2, buffer_get_size(_a1));                                                  // 2.x clamped to the buffer (OLD:125)
        if (_count < 1) return false;                                                                 // 0 bytes = InvalidParam
        var _flags = is_undefined(_a3) ? TCC_NET_SEND_RELIABLE : _a3;
        return steam_networking_messages_send_message_to_user(_a0, _a1, _flags, 0, 0, _count) == SteamApiResult.Ok;
    }
    return false;
}

// Replaces tcc_steam_net_set_auto_accept_p2p_sessions (214-217): registers the callback. Returns true when set.
function tcc_steam_net_set_session_request_callback(_a0) {
    if (platform_steam() && steam_api_is_initialized() && is_callable(_a0)) { steam_networking_messages_set_callback_session_request(_a0); return true; }
    return false;
}
function tcc_steam_net_accept_session(_a0) {
    if (platform_steam() && steam_api_is_initialized() && is_numeric(_a0) && _a0 != 0) return steam_networking_messages_accept_session_with_user(_a0);
    return false;
}
// Only used by the game_restart mitigation (D10). Never call the raw clear_* natives from project code.
function tcc_steam_net_clear_session_callbacks() {
    if (platform_steam() && steam_api_is_initialized()) {
        steam_networking_messages_clear_callback_session_request();
        steam_networking_messages_clear_callback_session_failed();
        return true;
    }
    return false;
}
```

## 5. Entries

### 5.1 steam_net_packet_send  ->  steam_networking_messages_send_message_to_user

New call (API:23674): `steam_networking_messages_send_message_to_user(_steam_id_remote, _data, _send_flags, _remote_channel, _buffer_offset, _buffer_count)`.
Project call (inside the wrapper above): `... (_a0, _a1, _flags, 0, 0, _count) == SteamApiResult.Ok`, `_flags` = `TCC_NET_SEND_RELIABLE` / `TCC_NET_SEND_UNRELIABLE` (macros TO BE DEFINED in scr_steam_safe.gml, D6). scr_online_multiplayer.gml:605-608 becomes:
```gml
function net_send_to(_member,_size,_reliable) {
    return tcc_steam_net_packet_send(_member,global.net_send_buffer,_size,_reliable ? TCC_NET_SEND_RELIABLE : TCC_NET_SEND_UNRELIABLE);
}
```
Arguments: user_id Int64 -> `_steam_id_remote` UInt64 number (unchanged value); buffer -> `_data` (must exist); size (-1 = whole) -> `_buffer_count` which MUST be passed, with `_buffer_offset` 0; packet_type -> `_send_flags`; channel -> `_remote_channel` mandatory, 0; returns Boolean -> returns EResult number (`SteamApiResult`: Ok 1, Fail 2, NoConnection 3, InvalidParam 8, LimitExceeded 25; API:314).
Result delivery: synchronous. Ok means queued, not delivered (2.x `true` meant the same). Session-setup failures arrive later through `steam_networking_messages_set_callback_session_failed` (struct `SteamNetworkingMessagesSessionFailed` {steam_id_remote, end_reason, debug_msg}, API:3953), which this map does not register (N6).
Call sites: wrapper 206-213; net_send_to 605-608 (the only direct user; raw constants at 607); net_broadcast 609-611 (callers: hello 615, bye 621 via net_send_bye, ping 680); state 674 (unreliable); pong 752 (unreliable); net_send_hello callers 728 and 1097; net_send_bye caller 377; levelshare.gml:115, 124, 177 (chunk send, return value used for flow control); scr_online_session.gml:1034 (picks; callers 962, 980, 1061).
Gotchas:
1. `_buffer_count` omitted sends the WHOLE ALLOCATED buffer (`buffer_get_size`, API:23687, 23746; CPP:135-141), not `buffer_tell`. `global.net_send_buffer` is a >= 1024-byte `buffer_grow`. Always pass the size.
2. Return is an EResult. The wrapper must return `== SteamApiResult.Ok`; otherwise levelshare.gml:177 treats LimitExceeded (25, the old "reliable queue full" signal; send buffer default 512k, HDR 1142-1145)/NoConnection(3)/Fail(2) as success.
3. Zero bytes or offset >= length is InvalidParam (CPP:130-133, 143).
4. Max message 524288 bytes (API:195, HDR 832); project max is 8236. An UNRELIABLE message larger than one MTU is lost entirely if any fragment is lost (HDR 943-945); state/ping/pong are < 1024.
5. Nagle applies by default to reliable AND unreliable in 3.0 (HDR 955-971); 2.x reliable was not Nagled. Use the NoNagle flags (matters for BYE). There is no flush function for Messages in the 3.0 API.
6. `AutoRestartBrokenSession` (HDR 1029-1048, local, v1.61): without it, once a session is disrupted or closed by the peer every send returns `NoConnection` until `close_session_with_user` (HDR isteamnetworkingmessages.h:76-81), and levelshare.gml:177 would retry the same chunk forever (the sender has no timeout, it gives up only when `net_lobby_member(_out.peer)` turns false). With it, the session restarts but reliable messages queued on the broken one may be lost (the header says it is impossible to know which). That is fail-safe for level sharing: `net_levelshare_receive` rejects any chunk whose offset is not contiguous and `net_levelshare_finish` verifies the md5. A lost HELLO/BYE/picks message is likewise lost either way (without the flag it is lost AND the sender gets NoConnection); picks have a catch-up path only when the peer's session id changes (scr_online_session.gml:1061).
7. Unreliable messages sent while the route is still being found are discarded (DOC SteamNetworkingConnectionState.FindingRoute); reliable ones are queued. First state/ping after a join can be lost; HELLO is reliable.
8. Send copies the bytes; reusing `global.net_send_buffer` immediately is safe.
9. Keep the `platform_steam() && steam_api_is_initialized()` guard: when the extension is missing every 3.0 wrapper returns `undefined`; `undefined == SteamApiResult.Ok` is false.
10. Wire compatibility with 1.3.x builds: bump `NET_PROTOCOL` 2 -> 3 (D11).
Confidence: high.

### 5.2 steam_net_packet_receive  ->  steam_networking_messages_receive_messages_on_channel

New call (API:23733): `steam_networking_messages_receive_messages_on_channel(_local_channel, _out_data, _count)` -> `Array[Struct.SteamNetworkingMessage]` (`[]` when nothing is pending or Steam is not initialised; `undefined` when the extension is missing). Project call: `steam_networking_messages_receive_messages_on_channel(0, global.net_recv_buffer, 1)` via `tcc_steam_net_packet_receive(_buffer)` (section 4), which returns `_messages[0]` or `undefined`.
Signature change: old returned Boolean and kept a hidden "current packet" read by three getters (OLD:139-168); new returns an array and keeps no state. `count = 1` keeps every payload at offset 0, which every decoder (`net_decode_state/hello/ping`, `net_er_receive_picks`, `net_levelshare_receive`) assumes. GML cannot assign inside a condition, so the loop is rewritten:
```gml
function net_receive_packets() {
    if (!global.net_active) return;
    var _buf = global.net_recv_buffer;
    var _processed = 0;
    while (_processed < 128) {
        var _message = tcc_steam_net_packet_receive(_buf);
        if (is_undefined(_message)) break;
        ++_processed;
        var _sender = _message.steam_id_remote;
        var _size = _message.size;
        if (!net_finite(_size) || _size < 1 || _size > NET_CHUNK_MAX_SIZE) continue;
        if (!net_lobby_member(_sender)) { /* unchanged: throttled net_refresh_members() then re-check, 698-704 */ }
        // tcc_steam_net_packet_get_data(_buf) (705) is gone: the payload is already at offset 0 of _buf
        if (_size > buffer_get_size(_buf)) continue;      // dead code now, harmless
        ... rest unchanged ...
    }
}
```
REQUIRED companion change: `global.net_recv_buffer` (scr_online_multiplayer.gml:302, today `buffer_create(1024, buffer_grow, 1)`) becomes `buffer_create(platform_steam() ? STEAM_NETWORKING_SOCKETS_MAX_MESSAGE_SIZE_SEND : 1024, buffer_fixed, 1)` (API:195 = 524288; the platform test avoids a 512 KB allocation on mobile builds, where `net_init` also runs; the existing `buffer_delete` at 339 releases it).
Why 524288: 3.0 never grows the out buffer. If the head message is larger than `buffer_get_size`, it is already popped from Steam's queue, then Released (CPP:195-201) and the call returns an EMPTY array (`steam_api_last_error()` says "output buffer exhausted"); the loop cannot tell that from "queue empty", breaks, and a peer that keeps sending oversize messages stalls the queue every tick. With 524288 bytes (the default receive cap, HDR 1160-1167, D9) native never drops, and the existing `_size > NET_CHUNK_MAX_SIZE -> continue` (697) discards oversize in GML.
Call sites: wrapper 202-205; scr_online_multiplayer.gml:693 (`net_receive_packets`, 689-); buffer created 302, deleted 339.
Gotchas:
1. Messages from a not-yet-accepted peer are not delivered (assumed: DOC says to "ignore" the request; whether Steam holds or drops them is not documented). See 5.8.
2. `count > 1` puts later payloads at non-zero offsets and breaks every absolute-offset decoder.
3. GML never holds or releases a native message (CPP:225 Releases each).
4. Reliable same-channel messages are exactly-once and ordered; unreliable may drop, reorder or duplicate (`net_seq_newer` already handles it).
5. Whether receive itself needs `steam_api_run_callbacks()` is not stated in the docs; the pump runs every frame anyway (owner: CORE-MAP 3.3 `tcc_steam_update`, called from objects/o_fullscreensystem/Step_0.gml:4; do not add a competing call).
6. The returned `SteamNetworkingMessage` fields: offset, size, steam_id_remote, conn (always 0 for Messages), channel, flags, usec_time_received, message_number, conn_user_data (API:3970, decode 11929).
7. Cost: one native call per packet (was 4), plus one array and one struct allocation.
8. Bump `NET_PROTOCOL` (D11).
Confidence: high.

### 5.3 steam_net_packet_get_data  ->  no function

The payload is already in the buffer passed to the receive call, at `msg.offset` for `msg.size` bytes (offset 0 with count 1). Delete `tcc_steam_net_packet_get_data` (scr_steam_safe.gml:190-193) and its caller scr_online_multiplayer.gml:705. If a copy is ever needed: `buffer_copy(_src, _msg.offset, _msg.size, _dst, 0)` after `buffer_resize(_dst, ...)` if `_dst` is smaller.
Difference: 2.x copied to the start of a buffer and grew it automatically (OLD:184, `BufferWriteContent(..., true)`), without moving the tell position; 3.0 writes into a caller-allocated, non-growing buffer. A leftover reference to the removed name fails the build. Stale bytes beyond `_size` remain in the buffer exactly as before.
Call sites: 190-193 (wrapper); 705 (caller); 706 `if (_size > buffer_get_size(_buf)) continue;` becomes dead code.
Confidence: high.

### 5.4 steam_net_packet_get_size  ->  `SteamNetworkingMessage.size`

Read the field of the struct returned by the receive call; delete `tcc_steam_net_packet_get_size` (198-201); replace scr_online_multiplayer.gml:696 with `var _size = _message.size;` and keep the validation at 697. Same meaning (payload bytes of that packet, UInt32 read). Fallback changes from `false` to "no message" (`undefined`), so read it only after the receive call returned a message.
Confidence: high.

### 5.5 steam_net_packet_get_sender_id  ->  `SteamNetworkingMessage.steam_id_remote`

Read the field; delete `tcc_steam_net_packet_get_sender_id` (194-197); replace line 695 with `var _sender = _message.steam_id_remote;`. Plain UInt64 number (API:11929 `buffer_read(buffer_u64)`), not a SteamId struct, used like the old Int64: `string(_sender)`, `ds_map_exists`, `== global.net_my_steam_id`, `net_lobby_member(_sender)` (519), `net_send_to(_sender,5,false)` (752), `net_send_hello(_sender,true)` (728), `net_levelshare_receive(_sender, ...)`. C++ `GetSteamID64()` returns 0 for a non-Steam-ID peer (CPP:214); `net_lobby_member` rejects it. The sender is the authenticated Steam identity, same trust level as before; keep the `net_lobby_member` gate.
Confidence: high.

### 5.6 steam_net_packet_type_reliable  ->  SteamNetworkingSendFlags.ReliableNoNagle (| AutoRestartBrokenSession)

Old constant 2 = `k_EP2PSendReliable` (OLD:69, 81). New (enum, API:1622): `SteamNetworkingSendFlags.ReliableNoNagle` (9); recommended `(ReliableNoNagle | AutoRestartBrokenSession)` = 41 as `TCC_NET_SEND_RELIABLE`. HDR steamnetworkingtypes.h:1011-1012: ReliableNoNagle "is equivalent to k_EP2PSendReliable". Unused sibling `steam_net_packet_type_reliable_buffer` (3 = `k_EP2PSendReliableWithBuffering`) -> `SteamNetworkingSendFlags.Reliable` (8) (HDR 1006). Values differ (2 vs 8/9/41), so no numeric literal may be carried over.
Call site: scr_online_multiplayer.gml:607 (RAW use outside any wrapper). The enum lives in Steamworks_API.gml, a script that compiles on every platform, so the macro compiles on mobile; only the wrapper actually sends.
Caveats: NoDelay (4) is invalid on reliable messages; reliable messages are exactly-once and ordered per channel up to 524288 bytes; `AutoRestartBrokenSession` consequences as in 5.1 gotcha 6. HDR text is v1.61.
Confidence: high (raised from medium, D5).

### 5.7 steam_net_packet_type_unreliable  ->  SteamNetworkingSendFlags.UnreliableNoNagle (| AutoRestartBrokenSession)

Old constant 0 = `k_EP2PSendUnreliable` (OLD:65, 78-79). New: `SteamNetworkingSendFlags.UnreliableNoNagle` (1), recommended `(UnreliableNoNagle | AutoRestartBrokenSession)` = 33 as `TCC_NET_SEND_UNRELIABLE`. Plain `Unreliable` (0) is the numeric match, but Valve's migration note says it is not the same as `k_EP2PSendUnreliable` and recommends `UnreliableNoNagle` (HDR 952-954); D12. Unused sibling `steam_net_packet_type_unreliable_nodelay` (1 = `k_EP2PSendUnreliableNoDelay`) -> `SteamNetworkingSendFlags.UnreliableNoDelay` (5; drops instead of queueing, returns `Ignored`/41 when dropped, HDR 984-996). Values differ (0/1 vs 33), do not carry numeric literals.
Call site: scr_online_multiplayer.gml:607 (RAW, ternary else-branch). Used for NET_PACKET_STATE (674), PING (680), PONG (752).
Caveats: can be dropped, reordered, duplicated (`net_seq_newer`); messages above one MTU are lost entirely if any fragment drops; messages sent before the route is found are discarded.
Confidence: high (raised from medium, D5).

### 5.8 steam_net_set_auto_accept_p2p_sessions  ->  session-request callback (queue, then accept in net_tick)

No setter in 3.0. New calls: `steam_networking_messages_set_callback_session_request(_callback)` (API:23618, register once, global script function), `steam_networking_messages_accept_session_with_user(_steam_id_remote)` (API:23770, returns Bool). Optional, not used by this map: `steam_networking_messages_set_callback_session_failed(_callback)` (API:23643). Cleanup natives `steam_networking_messages_clear_callback_session_request/_failed()` (raw natives, zero args, NEED a guarded wrapper, D3) are NOT called from `net_cleanup` (the extension clears them at shutdown, D3); only from the restart mitigation (D10). Full code: sections 3 and 4.
Callback argument: ONE struct `SteamNetworkingMessagesSessionRequest {steam_id_remote}` (API:3938; CPP:71 `cb.call(snm_fromNative(*p))`; the docs label it "result" but the shipped demo reads `data.steam_id_remote` directly: SP/gmext/src/source/Steamworks_gml/objects/Obj_Steam_Networking_Messages/Create_0.gml). One callback per kind is kept natively; setting again replaces it.
Project mapping: the registration moves to the one-shot block in `net_tick` (scr_online_multiplayer.gml:532-536, guard `global.net_p2p_accept`, init at 274); the old return value was ignored (534).
Semantics:
- 2.x: a flag, on by default, accepting requests from members of the live Steam lobby (OLD:12, 31-38). 3.0: nothing auto-accepted; the lobby check moves into the project (`net_accept_pending_sessions`).
- Sending to a peer implicitly accepts it (HDR isteamnetworkingmessages.h:46), and the project pings all members every 2 s, so even without the callback a joiner's session opens within <= 2 s; the callback shortens that to the next tick.
- Requests are re-posted periodically while the peer keeps sending (HDR 93-95); a dropped/throttled request is therefore harmless.
- A removed or kicked peer can no longer reopen a session through the callback because the membership check happens at accept time.
Delivery (D1): Steam posts the request inside `steam_api_run_callbacks()`; the GML function runs afterwards from the time-source ticker with `self` = `{}`. Prerequisite: `steam_api_run_callbacks()` must be called every frame (CORE-MAP 3.3 `tcc_steam_update`). Pass a global script function (stable `ptr`, no bound instance), register once.
Gotchas:
1. The early-out on `net_ready` / `net_active` in the callback is mandatory: the callback can run during teardown or without a session.
2. After `game_restart` (net_init returns early, globals survive) the callback may be dead or stale; see D10 and section 9. Mitigation placement: `objects/o_networkmanager/CleanUp_0.gml`, inside the `net_restarting` branch (`tcc_steam_net_clear_session_callbacks(); global.net_p2p_accept = false;`). Unverified.
3. check_port.py does not cover `steam_networking_`; CORE-MAP section 6 already proposes the extended regex.
4. Without Steam (mobile, MAS, QA): `platform_steam()` is false, the wrapper returns false and `net_tick` returns earlier anyway (line 530).
Confidence: medium (design is sound; delivery after game_restart is unverified).

### 5.9 steam_net_close_p2p_session  ->  steam_networking_messages_close_session_with_user

New call (API:23790): `steam_networking_messages_close_session_with_user(_steam_id_remote)` -> Bool. Wrapper in section 4 (same name/arity; guard changes to `platform_steam() && steam_api_is_initialized() && is_numeric(_a0) && _a0 != 0`). Both callers ignore the return value. Only channel 0 is used, so `close_channel_with_user` (API:23811) is not needed.
Call sites: wrapper 186-189; scr_online_multiplayer.gml:389 (loop in `net_leave_lobby`, after `net_send_bye` at 377 and `tcc_steam_lobby_leave` at 388); 820 (end of `net_remove_player`, also for peers pruned by `net_refresh_members` and on BYE).
Gotchas:
1. After the close, the peer's next message posts a NEW session request (HDR isteamnetworkingmessages.h:105-108) which the callback accepts only for lobby members: desired.
2. Sessions unused for a few minutes time out on their own (same header text), as in 2.x.
3. BYE race (UNVERIFIED): `net_leave_lobby` sends a reliable BYE (377) and closes all sessions in the same tick (389). The header says close frees resources "immediately" and says nothing about flushing queued reliable data. Use the NoNagle reliable flag for BYE (done via `TCC_NET_SEND_RELIABLE`), test with two accounts, and if BYEs are lost either defer the close a few ticks or rely on the existing fallbacks (`lobby_chat_update` removal, `net_refresh_members` pruning, NET_PEER_TIMEOUT_MS 10 s, scr_online_multiplayer.gml:34). The only loss is the "player left" notice.
4. `net_remove_player` closes the session for any removed peer; a still-member peer that keeps sending is re-accepted through the callback.
Confidence: medium.

## 6. Edit checklist (for the implementation phase)

1. scripts/scr_steam_safe/scr_steam_safe.gml: add the two macros; replace 186-189, 202-217; delete 190-201; add `tcc_steam_net_set_session_request_callback`, `tcc_steam_net_accept_session`, `tcc_steam_net_clear_session_callbacks` (section 4).
2. scripts/scr_online_multiplayer/scr_online_multiplayer.gml: line 14 `NET_PROTOCOL` 2 -> 3; init `global.net_session_requests = []` (net_init ~274 and net_reset_lobby_state 357); line 302 receive buffer (section 5.2); lines 532-536 registration + `net_accept_pending_sessions()`; add `net_on_session_request` and `net_accept_pending_sessions`; lines 605-608 `net_send_to`; lines 689-706 `net_receive_packets`.
3. objects/o_networkmanager/CleanUp_0.gml: restart branch gets the clear + `net_p2p_accept = false` (unverified mitigation, D10).
4. scripts/scr_online_levelshare/scr_online_levelshare.gml:177 needs NO change as long as the wrapper returns `== Ok`.
5. No change: Other_69 handlers; scripts/scr_online_session/scr_online_session.gml (sends go through `net_send_to`); NET_PACKET_* ids and formats.
6. tools/check_port.py:79 regex: per CORE-MAP section 6.
7. Grep gate afterwards: no `steam_net_` and no raw `steam_networking_` outside scr_steam_safe.gml (and the Steamworks_API script).

## 7. Networking Sockets vs Messages (unchanged conclusion)

Messages is the right replacement: it keeps the connectionless, symmetric, lobby-gated model of the legacy API (send to a Steam id, poll one channel), needs one registered callback, and the wire format (HELLO/BYE/STATE/PING/PONG) maps 1:1. Sockets API in 3.0 (API:23834-24200): `steam_networking_sockets_connect_p2p`, `..._accept_connection`, `..._send_message_to_connection`, `..._receive_messages_on_connection`, poll groups, `..._get_connection_info`, `set_callback_connection_status_changed`. Move to Sockets only for: (1) a host-as-hub redesign (today every client holds up to NET_MAX_LOBBY-1 = 249 Messages sessions), (2) explicit connection lifecycle events instead of NET_PEER_TIMEOUT_MS polling, (3) per-peer diagnostics or `linger` flush-on-close for a guaranteed final reliable message, (4) non-Steam-ID peers (IP). Costs: connection handles, mandatory accept/close in the status callback, same `steam_api_run_callbacks()` requirement.

## 8. Test plan (two accounts; cannot be run in this read-only phase)

1. B joins A's lobby: HELLO reaches both ways within a tick or two (callback path) and, with the callback deliberately not registered, within <= 2 s (implicit accept).
2. An 8 KB level chunk arrives (receive buffer sized); the level share completes and md5 passes.
3. Saturate a level transfer: `send` eventually returns LimitExceeded (25), the sender retries the same chunk, and the transfer resumes (flow control).
4. Leave: the other side sees BYE (or the fallback within 10 s). Kicked / non-member cannot reopen a session.
5. After the ending restart (`net_game_restart` from objects/o_endingreq/Alarm_0.gml:2): log `steam_api_is_initialized()` (CORE-MAP 7.1), then trigger a session request from the second account and confirm `net_on_session_request` fires and ids get queued; watch the log for "BAD PACKET".
6. Smoke on iOS/Android/MAS builds: no Steam binary present, no call reaches an unguarded native (grep gate in section 6).

## 9. Unresolved (could not be settled from the sources available)

1. Whether the extension's callback dispatcher (function statics, ref map, `time_source_global` ticker) survives `game_restart()`, and whether the runner runs the extension `final` (`steam_api_shutdown`) on restart (CORE-MAP 7.1). Unobservable statically; if either fails, EVERY 3.0 callback and async result is affected after the ending, not only this domain (and an in-flight Execute packet for an unknown handle desyncs that frame, CORE:333-338). Needs the runtime test in section 8.5. The mitigation in D10 is reasoned, not run: it helps if the runner runs `final` on restart (case C), is neutral if everything survives (case A), and is NOT a fix if the statics reset while native keeps the old handle (case B: the stale Release can delete the freshly registered entry; outcome depends on drain order and boot order).
2. Whether `CloseSessionWithUser` flushes pending reliable data (BYE race). Not in the local header or docs; Steam internals.
3. Whether messages from a not-yet-accepted peer are held or dropped by Steam while the request is pending.
4. Whether the legacy P2P and Messages transports interoperate (assumed not; the NET_PROTOCOL bump makes the question moot).
5. SDK header caveat: the local header text is SDK v1.61; the extension requires 1.65 (flag values are identical in the 3.0 enum; the 512 KB defaults, the Nagle text and the AutoRestartBrokenSession text are not re-verified for 1.65).
6. `InitRelayNetworkAccess` / SteamNetworkingUtils is not exposed by the 3.0 extension (no such function in API or Steamworks.yy), so the first contact may take longer to establish.
7. The 3.0 docs claim (api.js:75, getting_started.md:41-45) that callbacks run inside `steam_api_run_callbacks()` contradicts the GML implementation; this map follows the implementation (D1). Whether `receive_messages_on_channel` itself depends on `steam_api_run_callbacks()` is not stated.
