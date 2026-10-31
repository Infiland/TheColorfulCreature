# FINAL netcode design: legacy P2P -> Steam Networking Messages (Steamworks 2.1.6 -> 3.0.0)

Project `/Users/infi/Documents/Github/TheColorfulCreature`, branch `feat/steamworks-3-0`. This is the implementation spec for the networking part of the port. Nothing under the project was edited to write it. Baseline: design A (minimal transport swap), reconciled with `wrapper-contract.md` (the contract wins wherever they disagree), with the judges' required grafts applied or explicitly declined.

Abbreviations. `M` = `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`, `S` = `scripts/scr_online_session/scr_online_session.gml`, `L` = `scripts/scr_online_levelshare/scr_online_levelshare.gml`, `F` = `scripts/scr_online_friends/scr_online_friends.gml`, `PS` = `objects/o_pausescreen/Draw_73.gml`, `SAFE` = `scripts/scr_steam_safe/scr_steam_safe.gml`, `API` = `scripts/Steamworks_API/Steamworks_API.gml` (its last line is enormous: never print it), `EXT` = `scripts/ExtensionCore_api/ExtensionCore_api.gml`, `NAT` = `extensions/Steamworks/source/src/gm_steam_networking_messages.cpp`, `HDR` = `/Users/infi/Documents/sdk/public/steam/isteamnetworkingmessages.h` and `steamnetworkingtypes.h` (local SDK, v1.61 text; the extension needs 1.65), `SP` = the `port` scratchpad folder, `WC` = `contract` = the wrapper contract `SP/wrapper-contract.md` (not the folder `SP/wc`, which holds its generated tables and the proposed gate script), `SPEC` = `SP/netcode-spec.md`, `MNET`/`MLOB`/`MCORE` = `SP/map-{net,lobby,core}.final.md`. Line numbers are today's working tree.

---------------------------------------------------------------------------------------------------

## 0. Verdict

Networking Messages on channel 0 is a one-to-one replacement for how the game uses legacy P2P (connectionless, symmetric, send to a Steam id, poll one channel). The protocol bytes, the message catalog, the session state machine, the tick order, the budgets and the four peer-loss paths do not change. What changes:

1. Three net wrappers are rewritten, one is new for acceptance, two are new for the callbacks, three are deleted (section 5). They keep the contract's shapes (bool send, struct-or-`undefined` receive) plus four small, flagged additions (section 11).
2. `global.net_recv_buffer` becomes a fixed 524288-byte buffer; the receive loop pulls ONE message per call (`count = 1`), so every payload sits at buffer offset 0 and no decoder, no level-share reader and no existing self-check changes (4.3).
3. Send flags: reliable `41` (ReliableNoNagle | AutoRestartBrokenSession), unreliable `33` (UnreliableNoNagle | AutoRestartBrokenSession), channel 0, explicit offset 0 and count, result compared with `SteamApiResult.Ok` (3).
4. Session acceptance: the callback only records the requester; `net_tick` accepts lobby members, with one forced membership refresh per tick when an unknown requester is fresh (6).
5. A bounded outbox retries small reliable control packets refused with `LimitExceeded`; level chunks keep the existing retry-same-chunk flow control; the level sender gets a stall timeout (7.3, 8.4).
6. `NET_PROTOCOL` 2 -> 3, `host_name` cache, a restart/diagnostic log, and a Steam-free test harness (mock seam, scenarios, golden vectors, static gates) (10).

Everything that cannot be settled without Steam is listed in section 12; the dominant one is `game_restart()` versus the extension `final` function.

---------------------------------------------------------------------------------------------------

## 1. Decisions

### 1.1 Reconciliation of design A with the contract (each conflict settled once)

| # | A said | Contract says | Decision here | Why |
|---|---|---|---|---|
| R1 | `net_on_session_request` is handed straight to the Steam setter | Steam only ever receives the private relay function; user callbacks live in a listener registry and are invoked by `__tcc_steam_deliver` under `try/catch` (WC 1 X1, 10.3, 10.5, 11.3) | Use the contract: `tcc_steam_net_set_session_request_callback(_cb)` sets listener `net_session_request` and registers the relay natively | One callable ever reaches the extension, so the `int64(ptr(callable))` uniqueness question (EXT:271-290) cannot matter; the relay's `try/catch` is exactly the "callback bodies never throw into the dispatcher" graft (the dispatch loop at EXT:325-367 has no `try/catch`) |
| R2 | register `session_failed` with a named function | the relay has no route for `SteamNetworkingMessagesSessionFailed` | Register it (log-only) and add the three contract items: listener kind `net_session_failed`, a native-register case, a relay `case` (CONTRACT ADDITIONS CA-4). A decoder for the type exists (`__SteamNetworkingMessagesSessionFailed_decode`, API:11847; listed in the decoder array at API:24744) | Field diagnosis of relay/NAT failures needs the reason text; nothing depends on it, so dropping it later is a deletion |
| R3 | re-register in `net_register_steam_callbacks()` at every manager `Create_0`; no second `was_up` | contract 10.4: `tcc_steam_update()` re-installs every native slot that has a listener on each Steam-ready edge, and `o_fullscreensystem/Create_0` calls `tcc_steam_register_callbacks(true)` | Keep ONE call site (`net_register_steam_callbacks()` from `o_networkmanager/Create_0.gml`); do NOT add a `was_up` self-heal in `net_tick` (the contract already has it) | Two self-heal mechanisms would double-register on every edge. The `Create_0` call stays because it re-runs after `game_restart` even if the contract's global state were lost |
| R4 | `CleanUp_0` restart branch clears the callbacks (map-net D10) | `tcc_steam_net_clear_session_callbacks()` exists as optional | NOT called anywhere; mark the contract wrapper UNUSED (CA-5) | In case B of the restart analysis (dispatcher statics reset, native handle kept) clear + re-register can delete the freshly registered entry. Nothing in this design needs it: `steam_api_shutdown` clears the native slots itself (`gm_steam_api.cpp:113-150`) |
| R5 | `tcc_steam_net_packet_send` returns the EResult | returns bool, `true` only for `Ok` | Keep the bool; add the accessor `tcc_steam_net_last_send_result()` (CA-2). `net_send_to` reads it immediately after the call | Public signature unchanged; diagnostics and the outbox need the reason (`LimitExceeded` vs the rest) |
| R6 | n/a (A returns `undefined` only) | `tcc_steam_net_packet_receive(_buffer)` returns the struct or `undefined` | Add a third value `TCC_NET_RX_DROPPED` (-1: "a message was consumed and discarded by the native, keep looping"). The loop counts it against the 128 budget and `continue`s (CA-1) | Without it an "output buffer exhausted" drop looks like an empty queue and ends the tick (INV-A1 violation if the runtime receive bound ever exceeds 524288) |
| R7 | receive buffer allocated unconditionally | allocated only when `platform_steam()` | Unconditional `NET_RECV_BUFFER_BYTES` = 524288 (CA-1) | 512 KB is negligible on every platform (it is allocated once per process), and it makes the Check configuration, where `platform_steam()` is false, exercise the production allocation and the 8236-byte chunk path. The contract's saving of 512 KB on mobile is not worth a configuration-dependent test gap |
| R8 | contract 17.2 names `net_tick:532-536` as the registration site | same | Amend: registration site is `net_register_steam_callbacks()` (called from `o_networkmanager/Create_0.gml`); acceptance site is `net_accept_pending_sessions()` called from `net_tick` (CA-6) | The old `net_tick` one-shot and the `global.net_p2p_accept` flag are deleted |
| R9 | `variable_struct_exists(_request,"steam_id_remote")` and `{steam_id_remote: ...}` fixtures outside SAFE | gate 2 `unknown_steam_token` flags every `steam_\w+` token whose lookbehind is not `[\w$.]`, strings and comments included (verified in `SP/wc/check_port_steam.py` `scan`) | Outside SAFE: read fields by DOT access only (`_request.steam_id_remote`), assign fixtures by dot (`_m.steam_id_remote = ...`), never write a `steam_`-prefixed word in a comment or a string. The scratch run in 10.7 confirms the code in this document is clean | Keeps the allow-list untouched |
| R10 | mock replaces nothing in the guard | judge 2: route `tcc_steam_ready()` through the mock so `net_tick` runs | NOT adopted. `tcc_steam_ready()` stays the contract's single definition (X6); tests call the individual net functions directly (A's harness) | A mock-backed `tcc_steam_ready()` would also open the guard of every unstubbed wrapper in Check and let it reach a raw native that does not exist there. Making that safe needs B's whole wrapper-classification gate and a mock stubbing ~15 wrappers: more surface than this port should add. Tick order is protected statically instead (gate N-3 in 10.6) |
| R11 | mock fires the callback through the relay | gate 4b: `tcc_steam_relay` and `__tcc_steam_*` are forbidden outside SAFE | The mock (outside SAFE) stores the USER callback directly and emulates the dispatcher with `with ({}) method_call(cb, [arg])`. The relay routing of the two net structs is asserted in SAFE's own `tcc_steam_selfcheck()` (CA-7) | Two separate guarantees: relay routing (SAFE self-check) and callback-body semantics with a dummy `self` (transport self-check) |
| R12 | `net_send_to` guard `ds_map_exists(global.net_members, ...)` | n/a | `net_lobby_member(_member)` | BUG IN A: `net_refresh_members` stores our own id in `net_members` (M:499-518: `global.net_members[? string(_member)] = _member` for every member; only `net_member_list` skips self), so A's guard let self-sends through and its "own id is refused" claim (A 9.5 #4) was false. `net_lobby_member` (M:519-522) rejects our own id |

### 1.2 Decisions on the judges' conflicts

| Topic | Judge 1 | Judge 2 | Decision |
|---|---|---|---|
| Level-share back-pressure | H1 + H2 in the baseline | conditional on a two-account test | Baseline contains H1 (sender stall timeout) AND the small-reliable outbox (7.3). LEVEL_ACK, a new packet and a window protocol stay deferred. Deciding facts below |
| Session accept | cache-based; forced refresh optional | add one forced refresh per tick | Both: A's bounded queue + TTL + ignore window, plus ONE forced refresh per tick for a still-fresh unknown requester, sharing `net_refresh_forced_tick` with the receive loop (6.2). The forced refresh can use up the receive loop's refresh for that tick |
| `host_name` cache | required | optional | Required. Removes the per-Draw native call (8.5) |
| Mock-backed `tcc_steam_ready()` | not requested | take it | Declined (R10) |
| H3 deferred close | contingent | contingent | Contingent on the BYE-loss measurement, with B's cancel rule and the skip-at-exit rule (8.6) |

Deciding facts for the level-share decision, all checked in the code:

* All reliable traffic to one peer shares one connection and one send queue (default `SendBufferSize` 512 KB, `steamnetworkingtypes.h:1138-1143`). `LimitExceeded` is a property of that queue, not of the packet type. There is no queue-depth getter in the 3.0 Messages API (`get_session_connection_info` is absent from `API`), so the sender cannot see headroom.
* `L:176-177` retries the same chunk every tick until it is accepted, so for a level larger than the queue (up to `NET_SHARE_MAX_TEXT` = 16 MiB) the queue stays filled to within one chunk (< 8236 bytes) for the whole transfer.
* Only `L:177` reads a send result. Every other send ignores it: `net_broadcast` (M:609-611, returns nothing), HELLO (M:615), BYE (M:621), STATE (M:674), PING (M:680), PONG (M:752), ER_PICKS (S:1034), LEVEL_REQUEST (L:115) and LEVEL_DENY (L:124). A refused HELLO, ER_PICKS, REQUEST or DENY is therefore lost without a trace.
* Honest sizing: the queue is drained between ticks and the small packets of a tick (STATE, PING, replies) are sent BEFORE `net_levelshare_tick` refills it, so for a typical level.json (well below 512 KB, the whole file fits in the queue) nothing is refused. The exposure is real for large levels and for sends issued outside `net_tick` while a transfer to the same peer is running (an Endless-run pick, a LEVEL_REQUEST). That is a bounded, rare window, so the fix is also bounded: ~45 lines, reachable only on `LimitExceeded`, zero change on every healthy path.

---------------------------------------------------------------------------------------------------

## 2. What stays exactly as it is

Packet ids 16-24 and every byte layout (SPEC 2); the 128-messages-per-tick budget; the per-message `net_lobby_member` gate with its once-per-tick forced `net_refresh_members()` (M:698-704); sends-before-receives tick order (INV-B3); all four peer-loss paths (lobby chat update, 30-tick member prune, 10 s silence, BYE) and their constants; the close-session triggers (`net_leave_lobby` for every member, `net_remove_player`); the lobby as the membership/rendezvous layer; `net_players`/`net_members` keyed by `string(steam_id)`; the Friends panel; level-share chunk size (8192), per-tick budget (16 chunks) and deadlines; ER picks; the public `net_*` API (SPEC 1.2). The decoders keep reading absolute offsets from 0 and bound by the packet `_size`, never by the buffer size (so the large receive buffer cannot expose stale bytes: `net_packet_string_end`, M:111-116, checks `_size`).

---------------------------------------------------------------------------------------------------

## 3. Verified API facts (every doubt re-read in `API` / `NAT` / `EXT` / headers)

| Fact | Evidence |
|---|---|
| `steam_networking_messages_send_message_to_user(_steam_id_remote, _data, _send_flags, _remote_channel, _buffer_offset, _buffer_count)`: `show_error(..., true)` on a non-number id, missing buffer, non-number flags/channel; offset and count are optional (`undefined` -> not sent); returns the native value untouched; returns `undefined` when the extension is missing | API:23674-23722 |
| Native send: uninitialised -> `Fail` (2); offset >= length -> `InvalidParam` (8); omitted count = `length - offset` of the WHOLE ALLOCATED buffer; count 0 or `offset + count > length` -> 8; else the SDK result (`Ok` 1, `LimitExceeded` 25, `NoConnection` 3, ...) | NAT:116-157 |
| The pointer handed to the SDK is the GML buffer memory read at call time (`__Steamworks_queue_buffer(buffer_get_address(_data), buffer_get_size(_data))` queues address+size for the next native call); `SendMessageToUser` takes `const void*` with no ownership transfer, so it must copy. Not stated in the header: UNVERIFIED but implied (section 12) | API:23690; native queue `SteamworksInternal_native.cpp:19-27`; HDR `isteamnetworkingmessages.h:38-57` |
| `steam_networking_messages_receive_messages_on_channel(_local_channel, _out_data, _count)` -> `Array[SteamNetworkingMessage]`; `[]` when empty or Steam not initialised; `undefined` if the extension is missing. Payloads are packed back to back from offset 0; the buffer is NEVER grown; when a message does not fit, that message and every later FETCHED one are released, last error `"...output buffer exhausted."`, and the messages that fit are returned (for `count = 1`: `[]`) | API:23733-23768; NAT:161-229 (overflow branch 195-201, fields 211-220, Release 225) |
| `STEAM_GUARD` clears the last error on entry and sets `"Steam API not initialized"` when not initialised; `steam_api_is_initialized()` and `steam_api_last_error()` are raw natives with no `extension_exists` guard and do not clear anything | `GMSteamworks.h:59-66`; API:12453 ("no wrapper is required"); SteamworksInternal_native.cpp:27-40 |
| `SteamNetworkingMessage` fields: `offset, size, steam_id_remote, conn (0 for Messages), channel, flags, usec_time_received, message_number, conn_user_data`; `steam_id_remote` is `buffer_read(buffer_u64)` (a plain number, NOT a `SteamId` struct); the decoder assigns `_inst = new SteamNetworkingMessage();` WITHOUT `var` (API:11933), so every receive writes an instance variable named `_inst` on the calling instance: no project variable in `o_networkmanager` or in the receive path may be called `_inst` (grep: none in project code; the only `_inst` outside `API` is the Game Center API script) | API:3970, 11929-11960 |
| `SteamNetworkingMessagesSessionRequest { steam_id_remote }`, `SteamNetworkingMessagesSessionFailed { steam_id_remote, end_reason, debug_msg }`; both have decoders in the dispatcher decoder array | API:3938, 3953, 11795, 11847, 24743-24744 |
| `set_callback_session_request/_failed(_callback)`: GML wrapper returns early without the extension, `show_error` on a non-callable; the native setters only store the callable (no `STEAM_GUARD`), so registering before init is valid; one slot per kind, a second call replaces the first | API:23618-23660; NAT:88-114 |
| `clear_callback_session_request/_failed()` are raw natives without `extension_exists` guard; `steam_api_shutdown` (extension `final`) already clears both | API:23637, 23662; `gm_steam_api.cpp:113-150, 314-318` |
| `accept_session_with_user` / `close_session_with_user` -> `Bool` (`bool(native)`); `undefined` without the extension | API:23770-23808 |
| Callbacks are only ENQUEUED natively (`cb.call(...)`, NAT:62-83) and run later from a `time_source_global` ticker as `with (_dummy_context) method_call(_ref[0], _args)` where `_dummy_context` is a shared static empty struct; an unknown handle `continue`s without consuming its argument bytes. The 3.0 docs' "synchronous inside `steam_api_run_callbacks()`" is wrong for GML; SPEC G15/INV-A11 is superseded | EXT:245-252, 300, 333-338, 350 |
| Enums: `SteamNetworkingSendFlags` Unreliable 0, UnreliableNoNagle 1, NoDelay 4, UnreliableNoDelay 5, Reliable 8, ReliableNoNagle 9, UseCurrentThread 16, AutoRestartBrokenSession 32; `SteamApiResult` None 0, Ok 1, Fail 2, NoConnection 3, InvalidParam 8, LimitExceeded 25; macro `STEAM_NETWORKING_SOCKETS_MAX_MESSAGE_SIZE_SEND` = 524288 | API:1622-1633, 314-340, 195 |
| Header semantics: first send creates a session implicitly; SENDING TO A USER ALSO ACCEPTS any pending incoming session from it; requests are re-posted periodically while the peer keeps sending; reliable messages on one channel to one peer are exactly-once and ordered, nothing else is; `NoConnection` after a broken/peer-closed session unless `AutoRestartBrokenSession`; close frees resources immediately and a later message from the peer posts a new request; idle sessions time out after a few minutes | HDR `isteamnetworkingmessages.h:38-110` |
| `ReliableNoNagle` "is equivalent to k_EP2PSendReliable"; plain `Reliable` is "more like ReliableWithBuffering"; plain `Unreliable` "is not exactly the same as k_EP2PSendUnreliable, you probably want UnreliableNoNagle"; `SendBufferSize` and `RecvMaxMessageSize` default to 524288 (a larger message makes Steam close the connection) | `steamnetworkingtypes.h:943-1012, 1138-1167` |
| Check is a child of Apple in the config tree (`Default > Apple > {iOS > iOSCheck, MacAppStore, Check, QA}`, verified by parsing the `.yyp`); `#macro Apple:TCC_STEAM false` + `platform_steam()` (scr_platform.gml:12,17) make `platform_steam()` false in Check, so SPEC 1.6/INV-A12 ("Check has `platform_steam()` true") is wrong. Inheritance of the macro override to child configurations is GameMaker behaviour that this repo already relies on (scr_platform.gml:12) but no Check run has proven | `.yyp` config tree; scr_platform.gml:5-17 |

---------------------------------------------------------------------------------------------------

## 4. Architecture, message catalog, buffers

### 4.1 Layers after the swap

```
 gameplay hooks / S / L / F          unchanged: they call net_send_to / net_broadcast and read net_players
        |
 M  net_send_to (+outbox), net_receive_packets, net_on_session_request, net_accept_pending_sessions,
    net_register_steam_callbacks                         project logic, no raw Steam call, no steam_-prefixed token
        |
 SAFE  tcc_steam_net_packet_send / _receive / _accept_session / _close_p2p_session /
       _set_session_request_callback / _set_session_failed_callback / _classify / _last_send_result / _mock
        |                                                argument hygiene + readiness guard + Check-only mock seam
 API   steam_networking_messages_*  ->  extension 3.0.0  (raw natives are called ONLY from SAFE; check_port enforces)
```

Registration path: `net_register_steam_callbacks()` -> `tcc_steam_net_set_*_callback(net_on_*)` -> listener table (`global.tcc_steam.listeners`) + `__tcc_steam_native_register` -> `steam_networking_messages_set_callback_*( tcc_steam_relay )`. Delivery path: native queue -> ExtensionCore ticker (next time-source tick after `steam_api_run_callbacks()`) -> `with (_dummy_context) method_call(tcc_steam_relay, [struct])` -> `tcc_steam_relay` routes by `instanceof` -> `__tcc_steam_deliver(listener, [struct])` (owner check + `try/catch`) -> `net_on_session_request(struct)`.

### 4.2 Message catalog, channel and flag table

One channel for everything: `#macro TCC_NET_CHANNEL 0`. Reliable ordering (level transfer relies on it, L:215-222) is per host and per channel, and the 512 KB send queue is per connection, so extra channels buy no isolation; a bulk channel stays a later tuning option.

```gml
#macro TCC_NET_SEND_RELIABLE   (SteamNetworkingSendFlags.ReliableNoNagle   | SteamNetworkingSendFlags.AutoRestartBrokenSession)   // 9 | 32 = 41  (contract 10.2)
#macro TCC_NET_SEND_UNRELIABLE (SteamNetworkingSendFlags.UnreliableNoNagle | SteamNetworkingSendFlags.AutoRestartBrokenSession)   // 1 | 32 = 33
```

| Id | Packet | Class | Flags | Max size | Sender | Receiver / notes |
|---|---|---|---|---|---|---|
| 16 | STATE | unreliable | 33 | 302 typical, 1024 accepted | `net_send_player_state` (M:627-675), same-level members only | `net_decode_state`; seq filter `net_seq_newer` tolerates loss/reorder/duplicates |
| 17 | HELLO | reliable | 41 | 150 | `net_send_hello` (M:612-616): broadcast once per validated join, unicast reply | `net_decode_hello`; proto byte = `NET_PROTOCOL` (3). Outbox-eligible |
| 18 | BYE | reliable | 41 | 1 | `net_send_bye` (M:617-622) | `_size == 1`; best effort (8.6). NOT outbox-eligible |
| 19 | PING | unreliable | 33 | ~330 produced, 1024 accepted | `net_send_ping` (M:677-681), every 2 s | each valid PING yields one PONG |
| 20 | PONG | unreliable | 33 | 5 | inline in the receive loop (M:749-752) | RTT |
| 21 | ER_PICKS | reliable | 41 | 1024 | `net_er_send_picks` (S:1013-1040) | first pick wins. Outbox-eligible |
| 22 | LEVEL_REQUEST | reliable | 41 | 34 | `net_levelshare_request` (L:102-117) | Outbox-eligible |
| 23 | LEVEL_CHUNK | reliable | 41 | 8236 | `net_levelshare_tick` (L:147-191) | `LimitExceeded` is the flow-control signal (retry the same chunk). NOT outbox-eligible |
| 24 | LEVEL_DENY | reliable | 41 | 34 | `net_levelshare_send_deny` (L:119-125) | Outbox-eligible |

Why these values: `NoDelay` (4/5) is forbidden because it discards unreliable messages while the route is still being found, i.e. the first STATE/PING to a new peer. `AutoRestartBrokenSession` (32) is mandatory because the game closes sessions in two places and relies on silent recovery: without it a closed or disrupted session makes every later send return `NoConnection` until `close_session` is called, and a mutually-closed pair could stay invisible while both remain lobby members. Messages has no flush call in 3.0, so the NoNagle variants are the only way to keep 2.x's "never Nagle-delayed" behaviour; plain `Reliable`/`Unreliable` are never used (gate N-5). The 2.x default when the type was omitted was reliable, so the wrapper default is `TCC_NET_SEND_RELIABLE`.

Golden byte vectors (little endian, protocol 3, computed in Python from the layouts in `net_write_state`, `net_write_hello`, `net_write_ping`, `net_levelshare_*`, `net_er_send_picks`; the STATE, HELLO and REQUEST strings of design A were re-derived independently and match byte for byte):

```
STATE  60 B  seq 7, x 96, y 128, image_index 7, blend 16777215, scale 1/1, angle 0, alpha 1, color 3, room "r_lvl1", key "r_lvl1", skin 0, hat 1, item 2, hsp 4, vsp -3, alive, zerogrv 0
  1007000000c0420000004307ffffff000000803f0000803f000000000000803f03725f6c766c3100725f6c766c310000010200008040000040c00000
HELLO  20 B  proto 3, reply 0, name "Player", join_time 123.0, skin 0, hat 0
  110300506c61796572000000000000c05e400000
BYE    1 B   12
PING   20 B  stamp 0x0A0B0C0D, room "r_lvl1", key "r_lvl1", sid ""
  130d0c0b0a725f6c766c3100725f6c766c310000
PONG   5 B   stamp 0x01020304
  1404030201
ER_PICKS 18 B  sid "sid1", count 1, index 3, key "r_lvl1"
  1573696431000103000000725f6c766c3100
LEVEL_REQUEST 34 B  md5 "0123456789abcdef0123456789abcdef"
  16303132333435363738396162636465663031323334353637383961626364656600
LEVEL_DENY    34 B  same md5
  18303132333435363738396162636465663031323334353637383961626364656600
LEVEL_CHUNK   48 B  same md5, total 10, offset 0, length 4, data "abcd"
  173031323334353637383961626364656630313233343536373839616263646566000a00000000000000040061626364
```

### 4.3 Buffers: how bytes get in and out, and who owns what

* `global.net_recv_buffer` (M:302): `buffer_create(NET_RECV_BUFFER_BYTES, buffer_fixed, 1)`, `NET_RECV_BUFFER_BYTES` = 524288 (Steam's default receive bound, HDR 1160-1167; equal to `STEAM_NETWORKING_SOCKETS_MAX_MESSAGE_SIZE_SEND`, API:195). Allocated unconditionally (R7), freed in `net_cleanup` (M:339), survives `game_restart` with the other globals.
* Receive with `count = 1`: the native `current_offset` starts at 0 (NAT:186), so `msg.offset` is always 0. A message always fits (at most 524288 bytes by Steam's own bound), the in-GML cap `NET_CHUNK_MAX_SIZE` (8448) discards oversize one message at a time exactly as 2.x did, and the classifier (5.2) covers the case where the runtime bound is larger than the buffer. With `count > 1` one oversized message would take every later fetched message with it (NAT:195-201): never batch.
* Payload lifetime: the payload sits in `net_recv_buffer[0 .. size)` until the NEXT receive call overwrites it. Handlers run synchronously inside the loop iteration, copy what they keep (the level-share reader `buffer_copy`s chunks into its own buffer, ER picks and names are parsed into strings) and must never call the receive wrapper (none does). Bytes beyond `size` are stale and are never read (all decoders bound by `_size`).
* `SteamNetworkingMessage` struct lifetime: a plain GML struct built by the decoder from copied metadata. The native message object was already `Release()`d inside the call (NAT:225); there is nothing to free and no handle to leak. Nothing stores the struct (the peer table keeps decoded fields).
* Send: `global.net_send_buffer` (grow buffer, 1024 initial, `buffer_resize`d by `L:168`) is larger than any packet and holds stale tail bytes, so the wrapper ALWAYS passes `offset 0` and `count = size` (clamped to `buffer_get_size`). The address is read at call time, and the shared send buffer is overwritten several times per tick (STATE then PING; PONG/HELLO replies inside the receive loop; up to 16 chunks): safe because each send has handed its bytes to the SDK before the next write (implied, section 12).
* Outbox copies (7.3) are fixed buffers created with exactly `size` bytes, owned by the outbox entry, freed on success, expiry, peer departure, overflow eviction, lobby reset and cleanup.
* Ids: every id is a plain 64-bit number end to end (`steam_id_remote`, lobby member ids, `tcc_steam_get_user_steam_id()`); `string(id)` map keys and `==` across sources only stay exact if they are `int64` (Steam64 ~7.6e16 > 2^53). No `real()` anywhere in the transport. `buffer_read(buffer_u64)` returning `int64` is inferred, not proven: one-time log on the first received message (7.5) and the contract's `tcc_steam_register_callbacks` diagnostic.

---------------------------------------------------------------------------------------------------

## 5. SAFE: the networking wrappers (final code, contract shape)

Everything in this section lives in `SAFE` (the only file allowed to contain raw `steam_*` calls). It replaces the old net wrappers at SAFE:186-217. Guard rules: the readiness guard is `tcc_steam_ready()` (contract X6, unchanged); the two persistent-callback setters use `platform_steam()` only (contract X2: the native setters have no `STEAM_GUARD`, they only store the callable, and iOS/Android/MAS builds ship no Steam binary). Every wrapper first asks the Check-only mock seam (5.3); in production `TCC_SELF_CHECK` is the literal `false`, so the seam is never consulted. Gate 6 of the contract is respected: no line that contains a raw 3.0 call also contains `method(` or `function(`.

### 5.1 Macros and state

```gml
// gate-scan: safe
#macro TCC_NET_CHANNEL     0
#macro TCC_NET_RX_DROPPED  (-1)        // receive: a message was consumed and discarded by the native; keep looping
// TCC_NET_SEND_RELIABLE (41) / TCC_NET_SEND_UNRELIABLE (33): contract 10.2, unchanged

// __tcc_steam_state() (contract 10.2): add one field to the struct literal
//     net_last_send: 0,                 // EResult of the last tcc_steam_net_packet_send call (SteamApiResult.None = not attempted)
```

### 5.2 Wrappers

```gml
// gate-scan: safe
/// Test seam (Check configuration only). Returns the mock struct or undefined.
function tcc_steam_net_mock() {
    if (!TCC_SELF_CHECK) return undefined;
    if (!variable_global_exists("tcc_net_mock")) return undefined;
    return is_struct(global.tcc_net_mock) ? global.tcc_net_mock : undefined;
}

/// Pure. Turns the result of ONE count=1 receive into the wrapper's return value:
/// [message] -> the struct; [] + "output buffer exhausted" -> TCC_NET_RX_DROPPED (the native consumed and released a message
/// that did not fit); anything else empty (queue empty, Steam not ready, extension missing) -> undefined.
function tcc_steam_net_classify(_messages, _last_error) {
    if (!is_array(_messages)) return undefined;
    if (array_length(_messages) > 0) return _messages[0];
    return (string_pos("output buffer exhausted", string(_last_error)) > 0) ? TCC_NET_RX_DROPPED : undefined;
}

/// EResult of the most recent tcc_steam_net_packet_send call. Read it immediately after the send; nothing else writes it.
function tcc_steam_net_last_send_result() {
    return __tcc_steam_state().net_last_send;
}

/// Contract signature. true ONLY when the SDK returned SteamApiResult.Ok (queued, not delivered; 2.x's true meant the same).
/// _size is mandatory: an omitted count would send the whole allocated buffer. Flags default to reliable (the 2.x default).
function tcc_steam_net_packet_send(_steam_id, _buffer, _size, _flags = undefined) {
    var _st = __tcc_steam_state();
    _st.net_last_send = SteamApiResult.None;
    var _mock = tcc_steam_net_mock();
    if (!is_struct(_mock) && !tcc_steam_ready()) return false;
    // The 3.0 GML wrapper show_error()s fatally on a non-number id or a missing buffer; 2.x returned false.
    if (!is_numeric(_steam_id) || _steam_id <= 0 || !is_numeric(_buffer) || !buffer_exists(_buffer) || !is_numeric(_size)) {
        _st.net_last_send = SteamApiResult.InvalidParam;
        return false;
    }
    var _count = min(floor(_size), buffer_get_size(_buffer));      // 2.x clamped to the buffer as well
    if (_count < 1) { _st.net_last_send = SteamApiResult.InvalidParam; return false; }   // 0 bytes is InvalidParam natively
    var _use = is_undefined(_flags) ? TCC_NET_SEND_RELIABLE : _flags;
    var _result = is_struct(_mock)
        ? _mock.send(_steam_id, _buffer, _use, TCC_NET_CHANNEL, 0, _count)
        : steam_networking_messages_send_message_to_user(_steam_id, _buffer, _use, TCC_NET_CHANNEL, 0, _count);
    if (!is_numeric(_result)) _result = SteamApiResult.Fail;       // undefined = extension missing
    _st.net_last_send = _result;
    return _result == SteamApiResult.Ok;
}

/// Pulls at most ONE message on the game channel into _buffer (payload at offset 0, a fixed 524288-byte buffer).
/// Returns the SteamNetworkingMessage struct, undefined (nothing to read / Steam not ready), or TCC_NET_RX_DROPPED.
function tcc_steam_net_packet_receive(_buffer) {
    var _mock = tcc_steam_net_mock();
    if (!is_struct(_mock) && !tcc_steam_ready()) return undefined;
    if (!is_numeric(_buffer) || !buffer_exists(_buffer)) return undefined;
    var _messages;
    var _error = "";
    if (is_struct(_mock)) {
        _messages = _mock.receive(TCC_NET_CHANNEL, _buffer, 1);
        _error = _mock.last_error();
    } else {
        _messages = steam_networking_messages_receive_messages_on_channel(TCC_NET_CHANNEL, _buffer, 1);
        // Nothing guarded may run between the receive and this read: every guarded native clears the last error on entry.
        if (is_array(_messages) && array_length(_messages) == 0) _error = string(steam_api_last_error());
    }
    return tcc_steam_net_classify(_messages, _error);
}

function tcc_steam_net_accept_session(_steam_id) {
    var _mock = tcc_steam_net_mock();
    if (!is_struct(_mock) && !tcc_steam_ready()) return false;
    if (!is_numeric(_steam_id) || _steam_id <= 0) return false;
    var _accepted = is_struct(_mock) ? _mock.accept(_steam_id) : steam_networking_messages_accept_session_with_user(_steam_id);
    return _accepted == true;
}

function tcc_steam_net_close_p2p_session(_steam_id) {            // name and arity kept: M:389 and M:820 do not change
    var _mock = tcc_steam_net_mock();
    if (!is_struct(_mock) && !tcc_steam_ready()) return false;
    if (!is_numeric(_steam_id) || _steam_id <= 0) return false;
    var _closed = is_struct(_mock) ? _mock.close(_steam_id) : steam_networking_messages_close_session_with_user(_steam_id);
    return _closed == true;
}

/// Persistent listener "net_session_request" (contract 11.3). The callback runs from the extension's time-source tick with
/// self = a shared empty struct: it must be a named global script function that touches only globals.
function tcc_steam_net_set_session_request_callback(_callback) {
    if (!is_callable(_callback)) return false;
    var _mock = tcc_steam_net_mock();
    if (is_struct(_mock)) return _mock.set_session_request_callback(_callback);
    if (!platform_steam()) return false;
    __tcc_steam_listener_set("net_session_request", _callback, noone);
    return __tcc_steam_native_register("net_session_request");
}

/// Persistent listener "net_session_failed" (CA-4). Diagnostics only: membership never depends on it.
function tcc_steam_net_set_session_failed_callback(_callback) {
    if (!is_callable(_callback)) return false;
    var _mock = tcc_steam_net_mock();
    if (is_struct(_mock)) return _mock.set_session_failed_callback(_callback);
    if (!platform_steam()) return false;
    __tcc_steam_listener_set("net_session_failed", _callback, noone);
    return __tcc_steam_native_register("net_session_failed");
}
```

Deleted: `tcc_steam_net_packet_get_data`, `tcc_steam_net_packet_get_sender_id`, `tcc_steam_net_packet_get_size` (SAFE:190-201), `tcc_steam_net_set_auto_accept_p2p_sessions` (SAFE:214-217). `tcc_steam_net_clear_session_callbacks` stays defined per the contract but is UNUSED (R4). Leftover references are a runtime "function not found", which gate 4 (`removed_wrapper`) catches statically.

### 5.3 Contract-internal edits that the wrappers above need (SAFE only)

```gml
// gate-scan: safe
// __tcc_steam_native_register(_kind): add a case next to "net_session_request"
        case "net_session_failed":   steam_networking_messages_set_callback_session_failed(tcc_steam_relay); break;
// __tcc_steam_native_unregister(_kind): replace the single "net_session_request" case (it cleared BOTH slots) by two cases
        case "net_session_request":  steam_networking_messages_clear_callback_session_request(); break;
        case "net_session_failed":   steam_networking_messages_clear_callback_session_failed(); break;
// tcc_steam_relay(_r): add a route next to SteamNetworkingMessagesSessionRequest
            case "SteamNetworkingMessagesSessionFailed":  __tcc_steam_deliver(_s.listeners[$ "net_session_failed"], [_r]); break;
```

Mock seam in the three lobby READ wrappers (needed so `net_refresh_members()` can be driven without Steam; one line at the top of each body, before the readiness guard):

```gml
// gate-scan: safe
//   tcc_steam_lobby_get_member_count : var _mock = tcc_steam_net_mock(); if (is_struct(_mock)) return _mock.lobby_member_count();
//   tcc_steam_lobby_get_member_id    : var _mock = tcc_steam_net_mock(); if (is_struct(_mock)) return _mock.lobby_member_id(_index);
//   tcc_steam_lobby_get_owner_id     : var _mock = tcc_steam_net_mock(); if (is_struct(_mock)) return _mock.lobby_owner_id();
```
Every other wrapper keeps only its `platform_steam()`/`tcc_steam_ready()` guard. In Check (`platform_steam()` false) they are inert, which is what the harness relies on; the first assertion of the transport self-check (10.2) is `!tcc_steam_ready()` so a Check configuration where that is not true fails loudly instead of reaching a missing native.

---------------------------------------------------------------------------------------------------

## 6. Accepting sessions: members only

### 6.1 Model

3.0 has no auto-accept. 2.x accepted only requesters that were members of the live current lobby, and the game added a per-message member gate on top. The port keeps both layers:

1. Session layer (new): a pending session is accepted only if the requester is a lobby member.
2. Message layer (unchanged): messages from non-members are dropped, with one forced refresh per tick (M:698-704). Still required, because acceptance persists after a user leaves the lobby.

Convergence does not depend on the callback: our own sends accept pending sessions implicitly (HDR `isteamnetworkingmessages.h:46`) and the game pings every member every 2 s (`NET_PING_INTERVAL_MS`, M:677-681), so a member pair converges within one ping interval even if the callback never fires. The callback is a latency optimisation (next tick instead of up to 2 s) and an explicit policy gate. Whether messages sent before acceptance are held or dropped is not documented (section 12).

### 6.2 Code (in `M`)

The callback bodies run from the extension's time-source tick with `self` = a shared empty struct, outside `net_tick` and outside the `timing_instance_step()` gate (EXT:300, 350). They therefore touch only `global.*` and script functions and mutate no lobby/peer state; the contract relay already isolates exceptions (`__tcc_steam_deliver`, `try/catch`).

```gml
// gate-scan: project
#macro NET_RECV_BUFFER_BYTES        524288
#macro NET_SESSION_REQUEST_MAX      32       // pending requesters kept
#macro NET_SESSION_REQUEST_TTL_MS   10000    // how long an unknown requester may wait for membership
#macro NET_SESSION_FRESH_MS         1000     // an unknown requester younger than this may force a membership refresh
#macro NET_SESSION_IGNORE_MS        30000    // after expiry the same id is dropped at the door

/// Registered through the relay by net_register_steam_callbacks(). Records the requester only.
function net_on_session_request(_request) {
    if (!variable_global_exists("net_ready") || !global.net_ready) return;
    // is_struct first (the relay does the same before instanceof), then instanceof instead of a field-name string: a typed struct always has the field, and no steam_-prefixed string may appear outside SAFE (R9)
    if (!is_struct(_request) || instanceof(_request) != "SteamNetworkingMessagesSessionRequest") return;
    net_session_request_add(_request.steam_id_remote, current_time);
}

/// Split out so the self-check can drive time. Returns true when a new entry was queued.
function net_session_request_add(_id, _now) {
    if (!is_numeric(_id) || _id <= 0 || _id == global.net_my_steam_id) return false;
    var _queue = global.net_session_requests;
    // Steam re-posts while the peer keeps sending: a re-post keeps the ORIGINAL timestamp so the TTL can expire.
    for (var _i = 0; _i < array_length(_queue); ++_i) if (_queue[_i].user == _id) return false;
    if (!net_lobby_member(_id)) {
        var _until = global.net_session_ignored[$ string(_id)];
        if (is_numeric(_until) && _now < _until) return false;
    }
    if (array_length(global.net_session_requests) >= NET_SESSION_REQUEST_MAX) array_delete(global.net_session_requests, 0, 1);
    array_push(global.net_session_requests, {user:_id, first:_now});
    global.net_session_stats.requests += 1;
    return true;
}

/// Diagnostics only (2.x had no equivalent and the game never reacted to connect failures; membership stays lobby-driven, INV-B6).
function net_on_session_failed(_failed) {
    if (!variable_global_exists("net_ready") || !global.net_ready) return;
    if (!is_struct(_failed) || instanceof(_failed) != "SteamNetworkingMessagesSessionFailed") return;
    var _stats = global.net_session_stats;
    _stats.failed += 1;
    _stats.last_failure = {user:string(_failed.steam_id_remote), reason:_failed.end_reason, text:string_copy(string(_failed.debug_msg), 1, 128), at:current_time};
    if (current_time - _stats.failure_logged_at < 5000) return;
    _stats.failure_logged_at = current_time;
    show_debug_message("[NET] session failed: " + json_stringify(_stats.last_failure));
}

/// Called from net_tick right after the 30-tick member refresh block and before any send.
/// Accept members, expire strangers. At most ONE forced net_refresh_members() per tick, only while some unknown requester is
/// still fresh (a newcomer can beat the membership cache); the budget is shared with the receive loop through
/// net_refresh_forced_tick, so on a tick where this function refreshed, the receive loop will not refresh again.
function net_accept_pending_sessions(_now = current_time) {
    if (!global.net_active || array_length(global.net_session_requests) == 0) return;   // entries wait (TTL) while we are out of a lobby
    var _fresh_unknown = false;
    for (var _i = 0; _i < array_length(global.net_session_requests); ++_i) {
        var _entry = global.net_session_requests[_i];
        if (!net_lobby_member(_entry.user) && _now - _entry.first <= NET_SESSION_FRESH_MS) _fresh_unknown = true;
    }
    if (_fresh_unknown && global.net_refresh_forced_tick != timing_tick_id()) {
        global.net_refresh_forced_tick = timing_tick_id();
        net_refresh_members();
    }
    for (var _j = array_length(global.net_session_requests) - 1; _j >= 0; --_j) {
        var _req = global.net_session_requests[_j];
        if (net_lobby_member(_req.user)) {
            if (tcc_steam_net_accept_session(_req.user)) global.net_session_stats.accepted += 1;   // false = nothing pending (our own send already accepted it)
            array_delete(global.net_session_requests, _j, 1);
        } else if (_now - _req.first > NET_SESSION_REQUEST_TTL_MS) {
            if (variable_struct_names_count(global.net_session_ignored) >= 128) global.net_session_ignored = {};
            global.net_session_ignored[$ string(_req.user)] = _now + NET_SESSION_IGNORE_MS;
            array_delete(global.net_session_requests, _j, 1);
        }
    }
}

/// ONE definition in the project: the lobby domain's function (MLOB 6) extended with the two net lines.
function net_register_steam_callbacks() {
    // lobby domain: tcc_steam_set_lobby_callbacks(net_on_lobby_chat_update, net_on_lobby_join_requested);
    tcc_steam_net_set_session_request_callback(net_on_session_request);
    tcc_steam_net_set_session_failed_callback(net_on_session_failed);
}
```

All array mutations go through `global.net_session_requests` directly (no mutation through a local alias), so the code is independent of GameMaker's copy-on-write details.

Why a forced refresh and not the cache alone: 2.x checked the LIVE lobby member list at request time, and the first HELLO of a newcomer is one-shot (INV-B8); losing it costs the "player joined" notice. Why bounded: the forced refresh is `net_refresh_members()` (up to 250 member lookups), so it is limited to one per tick (the same cost the receive loop already accepts for a non-member sender, M:698-704), to requesters younger than `NET_SESSION_FRESH_MS`, and a stranger that expires is ignored for 30 s, so a flood of ids costs at most one refresh per tick while NEW ids keep arriving and zero Steam calls otherwise. `lobby_chat_update` sets `net_refresh_tick = 0` (M:1124), so a legitimate joiner is normally already in the cache.

### 6.3 Threat model

| Threat | Handling |
|---|---|
| Non-member sends to us | no accept; Steam keeps re-posting; each id is queued once, expires after 10 s, then ignored for 30 s |
| Non-member floods many distinct ids | queue capped at 32 (drop-oldest), ignore map capped at 128, at most one forced refresh per tick |
| Former member keeps an open session | the message gate drops them; sessions are closed on BYE / chat-update leave / timeout / prune (INV-A7); idle sessions time out in minutes |
| Spoofed sender id | none exists: the sender identity comes from Steam, packets carry none |
| We talk to a non-member and thereby accept them | `net_send_to` refuses non-members (7.3) |
| Hostile member | size caps (8448), per-type decoders, 128/tick budget unchanged; Steam closes the connection of a peer exceeding the receive bound |

---------------------------------------------------------------------------------------------------

## 7. `M` (scr_online_multiplayer.gml): function-level changes

### 7.1 Edit table

| Lines (today) | Function | Change |
|---|---|---|
| 1-3, 24 (comments) | header | "protocol 2" -> "protocol 3" (cosmetic) |
| 14 | `NET_PROTOCOL` | `3`. Every consumer uses the macro: HELLO writer M:196, decoder M:216, lobby `proto` M:485 (stringified by `net_lobby_set`), join validation M:1085, self-check M:1251, session descriptor `v` S:295, 370, 400. No literal `2`/`"2"` is compared anywhere |
| after 36 | macros | add the 5 macros of 6.2 and `NET_OUTBOX_MAX`, `NET_OUTBOX_AGE_MS` (7.3) |
| 255-306 | `net_init` | replace `global.net_p2p_accept = false;` (274) by the new globals (7.2); receive buffer (302) -> `buffer_create(NET_RECV_BUFFER_BYTES, buffer_fixed, 1)` |
| 323-326 | `net_game_restart` | add the restart log (7.5) |
| 330-343 | `net_cleanup` | add `net_outbox_clear();` before the buffers are deleted. NO clear_callback call |
| 357-372 | `net_reset_lobby_state` | add the resets (7.2) |
| 528-600 | `net_tick` | delete 532-536; insert `net_cache_host_name();` after 589; insert `net_accept_pending_sessions();` after the refresh block (before 592); insert `net_outbox_pump();` before `net_send_player_state()` (595). The guard at 530 is left as is |
| 605-611 | `net_send_to`, `net_broadcast` | `net_send_to` per 7.3; `net_broadcast` unchanged |
| 689-706 | `net_receive_packets` | loop head per 7.4; the `switch` (707-771) untouched |
| 1104-1105 | join success | `global.net_host_name = net_clean_name(_host);` |
| new | `net_outbox_*`, `net_note_send_failure`, `net_cache_host_name`, `net_check_ids`, `net_log_transport`, `net_on_session_*`, `net_session_request_add`, `net_accept_pending_sessions`, `net_register_steam_callbacks` | added |
| 612-622, 627-681, 777-805, 812-820, 862-896 | HELLO/BYE/STATE/PING senders, `net_register_player`, `net_remove_player`, `net_update_ghosts` | no change (the id given to `tcc_steam_user_set_played_with` is the int64 `steam_id_remote`) |

### 7.2 State

```gml
// gate-scan: project
// net_init (replaces `global.net_p2p_accept = false;` at M:274)
	global.net_session_requests = [];     // [{user, first}]
	global.net_session_ignored = {};      // string(id) -> ignore-until (current_time)
	global.net_session_stats = {requests:0, accepted:0, failed:0, rx:0, rx_dropped:0, last_failure:undefined, failure_logged_at:-10000};
	global.net_send_stats = {failed:0, limit:0, limit_by_type:{}, last_result:0, logged_at:-10000, outbox_pushed:0, outbox_sent:0, outbox_dropped:0, stalled:0};
	global.net_outbox = [];               // [{user, size, buffer, at}] small reliable packets refused with LimitExceeded
	global.net_host_name = "";            // cleaned host_name, refreshed with the member refresh (8.5)
	global.net_ids_checked = false;
	global.net_boot_logged = false;
// net_init (M:302)
	global.net_recv_buffer = buffer_create(NET_RECV_BUFFER_BYTES, buffer_fixed, 1);
// net_reset_lobby_state (add)
    global.net_session_requests = [];
    global.net_session_ignored = {};
    global.net_host_name = "";
    net_outbox_clear();
```

These live inside the body of `net_init`, after its early return, so they persist across `game_restart` like every other `global.net_*`.

### 7.3 Send path and the outbox

```gml
// gate-scan: project
#macro NET_OUTBOX_MAX        16
#macro NET_OUTBOX_AGE_MS     30000

function net_send_to(_member, _size, _reliable) {
    // Sending to a user ALSO accepts any pending session from it, which would bypass the member-only accept policy; this
    // makes "we only ever send to members" an invariant. net_lobby_member also rejects our own id (R12).
    if (!net_lobby_member(_member)) return false;
    var _type = buffer_peek(global.net_send_buffer, 0, buffer_u8);
    var _sent = tcc_steam_net_packet_send(_member, global.net_send_buffer, _size, _reliable ? TCC_NET_SEND_RELIABLE : TCC_NET_SEND_UNRELIABLE);
    if (_sent) return true;                                  // L:177 `if (!net_send_to(...)) break;` keeps working
    var _result = tcc_steam_net_last_send_result();
    net_note_send_failure(_member, _type, _result);
    if (_result == SteamApiResult.LimitExceeded && _reliable && net_outbox_eligible(_type)) net_outbox_push(_member, _size);
    return false;
}

function net_outbox_eligible(_type) {
    return _type == NET_PACKET_HELLO || _type == NET_PACKET_ER_PICKS || _type == NET_PACKET_LEVEL_REQUEST || _type == NET_PACKET_LEVEL_DENY;
}

function net_note_send_failure(_member, _type, _result) {
    var _s = global.net_send_stats;
    _s.failed += 1;
    if (_result == SteamApiResult.LimitExceeded) {            // normal back-pressure: counted per packet type, never logged
        _s.limit += 1;
        var _k = string(_type);
        _s.limit_by_type[$ _k] = variable_struct_exists(_s.limit_by_type, _k) ? _s.limit_by_type[$ _k] + 1 : 1;
        return;
    }
    _s.last_result = _result;
    if (current_time - _s.logged_at < 5000) return;
    _s.logged_at = current_time;
    show_debug_message("[NET] send failed: EResult " + string(_result) + " type " + string(_type) + " to " + string(_member));
}

/// Copy the packet currently in net_send_buffer into the outbox. Bounded (16 entries, drop-oldest).
function net_outbox_push(_member, _size, _now = current_time) {
    if (array_length(global.net_outbox) >= NET_OUTBOX_MAX) {
        buffer_delete(global.net_outbox[0].buffer);
        array_delete(global.net_outbox, 0, 1);
        global.net_send_stats.outbox_dropped += 1;
    }
    var _copy = buffer_create(_size, buffer_fixed, 1);
    buffer_copy(global.net_send_buffer, 0, _size, _copy, 0);
    array_push(global.net_outbox, {user:_member, size:_size, buffer:_copy, at:_now});
    global.net_send_stats.outbox_pushed += 1;
}

/// First thing of the send phase of net_tick. Retries in insertion order; a peer that is still full keeps its order (later entries
/// for it wait). Entries die when the peer left the lobby, after NET_OUTBOX_AGE_MS, or on any failure other than LimitExceeded.
/// Calls the wrapper directly (never net_send_to), so a refused retry cannot re-queue itself.
function net_outbox_pump(_now = current_time) {
    if (array_length(global.net_outbox) == 0) return;
    var _blocked = {};
    var _i = 0;
    while (_i < array_length(global.net_outbox)) {
        var _entry = global.net_outbox[_i];
        var _key = string(_entry.user);
        var _drop = !net_lobby_member(_entry.user) || _now - _entry.at > NET_OUTBOX_AGE_MS;
        if (!_drop && !variable_struct_exists(_blocked, _key)) {
            if (tcc_steam_net_packet_send(_entry.user, _entry.buffer, _entry.size, TCC_NET_SEND_RELIABLE)) {
                _drop = true;
                global.net_send_stats.outbox_sent += 1;
            } else if (tcc_steam_net_last_send_result() == SteamApiResult.LimitExceeded) {
                _blocked[$ _key] = true;
            } else {
                _drop = true;
                global.net_send_stats.outbox_dropped += 1;
            }
        }
        if (_drop) {
            buffer_delete(_entry.buffer);
            array_delete(global.net_outbox, _i, 1);
        } else {
            ++_i;
        }
    }
}

function net_outbox_clear() {
    for (var _i = 0; _i < array_length(global.net_outbox); ++_i) {
        var _b = global.net_outbox[_i].buffer;
        if (buffer_exists(_b)) buffer_delete(_b);
    }
    global.net_outbox = [];
}
```

Semantics. A refused HELLO, ER_PICKS, LEVEL_REQUEST or LEVEL_DENY is delivered later instead of being lost; `net_send_to` still returns `false` for it. Chunks are excluded (their retry is the sender's own, L:176-177). BYE is excluded: it is sent at leave, right before the sessions are closed and the lobby state is reset, so a retry would reopen a session with an ex-member. Retried HELLOs may arrive after later reliable messages; this is harmless, STATE/PING already lazily register a peer before its HELLO today (M:713-718, 739-741). Healthy paths never reach the outbox (it is only entered on `LimitExceeded`), so behaviour is byte-for-byte A's elsewhere. `net_cleanup` and `net_reset_lobby_state` free every buffer (7.2); `NET_OUTBOX_MAX` bounds memory at 16 packets of at most 1024 bytes.

### 7.4 Receive loop

```gml
// gate-scan: project
function net_receive_packets() {
    if (!global.net_active) return;
    var _buf = global.net_recv_buffer;
    var _processed = 0;
    while (_processed < 128) {
        var _message = tcc_steam_net_packet_receive(_buf);
        if (is_undefined(_message)) break;                     // nothing left (or Steam not ready)
        ++_processed;                                           // every dequeued message counts against the budget, as in 2.x
        if (!is_struct(_message)) { global.net_session_stats.rx_dropped += 1; continue; }   // TCC_NET_RX_DROPPED: consumed, unusable, keep looping
        var _sender = _message.steam_id_remote;
        var _size = _message.size;
        if (!global.net_ids_checked) net_check_ids(_sender);
        // sender 0 = the peer identity is not a Steam id; offset != 0 cannot happen with count 1 (defensive)
        if (!is_numeric(_sender) || _sender <= 0 || _message.offset != 0) { global.net_session_stats.rx_dropped += 1; continue; }
        if (!net_finite(_size) || _size < 1 || _size > NET_CHUNK_MAX_SIZE) continue;
        if (!net_lobby_member(_sender)) {
            // A newcomer's first packet can beat Steam's membership callback. One forced refresh per tick, shared with
            // net_accept_pending_sessions (which may already have used it this tick).
            if (global.net_refresh_forced_tick == timing_tick_id()) continue;
            global.net_refresh_forced_tick = timing_tick_id();
            net_refresh_members();
            if (!net_lobby_member(_sender)) continue;
        }
        // M:705-706 (get_data + the `_size > buffer_get_size(_buf)` check) are gone: the payload is already at offset 0.
        global.net_session_stats.rx += 1;
        var _type = buffer_peek(_buf, 0, buffer_u8);
        var _key = string(_sender);
        switch (_type) {
            // cases NET_PACKET_STATE .. NET_PACKET_LEVEL_DENY: unchanged (M:709-771)
        }
    }
}
```

The loop terminates: each iteration either breaks on `undefined`, consumes one message (struct or `TCC_NET_RX_DROPPED`) and increments `_processed`, so at most 128 iterations. The head-of-line behaviour of 2.x is preserved: an oversize or non-member message is consumed, counted and skipped, and the loop continues with the next message in the same tick (INV-A1).

### 7.5 Diagnostics: ids check, restart log

```gml
// gate-scan: project
/// One-time, log only (never disables online): ids must be int64 with 17 digits or string() keys and == comparisons lose precision.
function net_check_ids(_id) {
    global.net_ids_checked = true;
    if (!is_int64(_id) || string_length(string(_id)) != 17)
        show_debug_message("[NET] WARNING: remote ids are " + typeof(_id) + " (" + string(_id) + "), expected a 17 digit int64");
}

function net_log_transport(_tag) {
    var _s = global.net_session_stats;
    show_debug_message("[NET] " + _tag + ": ready=" + string(tcc_steam_ready()) + " active=" + string(global.net_active)
        + " req=" + string(_s.requests) + " accepted=" + string(_s.accepted) + " session_failed=" + string(_s.failed)
        + " rx=" + string(_s.rx) + " rx_dropped=" + string(_s.rx_dropped) + " tx_failed=" + string(global.net_send_stats.failed)
        + " tx_limit=" + string(global.net_send_stats.limit) + " outbox=" + string(array_length(global.net_outbox)));
}

function net_game_restart() {
    global.net_restarting = true;
    global.net_boot_logged = false;          // the first net_tick after the restart logs again
    net_log_transport("restart");
    game_restart();
}
```
`net_tick` logs once per process/restart: after its Steam guard, `if (!global.net_boot_logged) { global.net_boot_logged = true; net_log_transport("first tick"); }`. Together they make the `game_restart` / `final` question observable in the first real run: after a restart `ready=false` means Steam was shut down; `ready=true` with `req` not increasing after a second account sends first means the callback registration died.

### 7.6 `net_tick` (final order; INV-B3 preserved)

```gml
// gate-scan: project
function net_tick() {
    if (!variable_global_exists("net_ready") || !global.net_ready) return;
    if (!platform_steam() || !tcc_steam_initialised()) return;                       // M:530, unchanged
    if (!global.net_boot_logged) { global.net_boot_logged = true; net_log_transport("first tick"); }
    if (global.net_my_steam_id == 0) global.net_my_steam_id = tcc_steam_get_user_steam_id();
    // M:532-536 (session auto-accept one-shot) DELETED: callbacks are registered by net_register_steam_callbacks()
    // ... cold-launch join, net_enabled() block, pending join, auto-host: unchanged ...
    if (!global.net_active) return;
    if (timing_tick_id() >= global.net_refresh_tick) {
        // ... member refresh, ownership, net_apply_member_limit(), net_presence_update(false): unchanged ...
        net_cache_host_name();                                                       // new (8.5)
    }
    net_accept_pending_sessions();                                                   // new: after the refresh, before any send
    if (global.net_is_host) net_session_publish(false);
    else net_follow_poll();
    net_outbox_pump();                                                               // new: first thing of the send phase
    net_send_player_state();
    net_send_ping();
    net_receive_packets();
    net_update_ghosts();
    net_levelshare_tick();
}
```

---------------------------------------------------------------------------------------------------

## 8. The other files

### 8.1 `objects/o_networkmanager/`

* `Create_0.gml`: `net_init(); net_register_steam_callbacks();` (the lobby plan already adds the second call; this design only adds its two lines to the function). Create_0 runs at every boot and again after `game_restart`, because the manager is recreated by `net_ensure_manager`; registering is idempotent (refcount +1/-1 on the same relay key in EXT:271-290).
* `CleanUp_0.gml`: unchanged. The restart branch does NOT clear callbacks (R4).
* `Step_0.gml`, `Draw_*`: unchanged. `Other_69.gml`: removed by the lobby/social/UGC ports (not a net change).
* Do not name any variable `_inst` in this object or in the receive path (API:11933).

### 8.2 `S` (scr_online_session.gml)

No transport change: `net_er_send_picks` writes into `global.net_send_buffer` and calls `net_broadcast`/`net_send_to` (S:1016, 1034); `net_er_receive_picks` reads absolute offsets from 0 (S:1037-1054); S:1057-1062 unicasts to a gated sender. `NET_PROTOCOL` uses at S:295, 370, 400 follow the macro. The other Steam-facing lines in this file belong to other domains.

### 8.3 Wiring and new scripts

* `scripts/scr_port_selfcheck/scr_port_selfcheck.gml:108`: add `scr_online_transport_selfcheck();` after `scr_online_cosmetics_selfcheck();`.
* New scripts (each needs its `.yy` and a `.yyp` resource entry; `tools/check_port.py` asserts every resource file exists): `scripts/scr_net_mock/scr_net_mock.gml`, `scripts/scr_online_transport_selfcheck/scr_online_transport_selfcheck.gml`.
* `tools/check_port.py` / `SP/wc/check_port_steam.py`: the `net_invariants` extension of 10.6.
* `SAFE`: section 5, plus the S-2 additions of CA-7 inside `tcc_steam_selfcheck()`.

### 8.4 `L` (scr_online_levelshare.gml): sender stall timeout (H1)

`L:176-177` retries the same chunk for as long as the peer remains a lobby member. With 2.x that could already be forever (peer frozen); 3.0 makes it observable. Add a progress stamp; healthy transfers never reach it (the receiver's own deadline is 30 s per chunk and 60 s for the first).

```gml
// gate-scan: project
// L:142 net_levelshare_serve : array_push(global.net_share_out, {peer:_peer, md5:_md5, buffer:-1, size:0, offset:0, progress_at:current_time});
// L:132   (repeated request restarts the transfer)         if (_out.md5 == _md5) { _out.offset = 0; _out.progress_at = current_time; return; }
// L:~161  (the branch that creates the data buffer = the transfer becomes ACTIVE)   _out.size = _bytes;  _out.progress_at = current_time;
// L:~178  after `_out.offset += _length;`                   _out.progress_at = current_time;
// L:~181  after the inner `for (var _n ...)` loop, before `if (_done) {`:
        if (!_done && current_time - _out.progress_at > 2 * NET_SHARE_TIMEOUT_MS) {
            _done = true;                                     // no chunk accepted for 60 s: drop the transfer, free its buffer
            global.net_send_stats.stalled += 1;
        }
```
Setting `progress_at` when the transfer becomes active (not when it is queued) matters: entries beyond `NET_SHARE_ACTIVE` (8) wait unprocessed and would otherwise time out on activation. `net_levelshare_lobby_reset` is unchanged (it already frees queued buffers). Nothing else in `L` changes: it calls `net_send_to(peer, size, true)` (L:115, 124, 177), decodes at absolute offsets 0 (L:194-234), and L:177 now sees the strict boolean (`LimitExceeded` -> `false`), which is the intended 2.x flow control.

`NET_SHARE_CHUNKS_PER_TICK` (16) is deliberately NOT lowered: an open-loop lower rate cannot create headroom on a slow link (the queue still reaches the cap), and INV-B15 fixes the number. If the large-file test shows control-packet latency behind chunks to be a problem, the next step is a byte-per-tick cap in `net_levelshare_tick` (measured, not guessed), then B's LEVEL_ACK window as a protocol 4 change.

### 8.5 `host_name` cache (M, F, PS)

`tcc_steam_lobby_get_data("host_name")` runs EVERY Draw while paused as a client (PS:26) and every frame the Friends panel draws (F:124); with the 3.0 wrapper (args buffer) that is heavier than in 2.x and risks passing an invalid lobby id from a Draw event. Cache it:

```gml
// gate-scan: project
/// Refreshed with the 30-tick member refresh, at join success and cleared with the lobby. Owners show the HOSTING text, not this.
function net_cache_host_name() {
    if (!global.net_active || global.net_is_host) return;
    var _name = tcc_steam_lobby_get_data("host_name");
    global.net_host_name = net_clean_name(is_string(_name) ? _name : "");
}
// M:1104-1105 join success, after `var _host = tcc_steam_lobby_get_data("host_name");`
			global.net_host_name = net_clean_name(_host);
// F:124 net_friends_session_text
    return string_replace(string_replace(loc("NET_SESSION_JOINED"), "{NAME}", global.net_host_name), "{COUNT}", string(net_member_count()));
// PS:26 (after this the file contains no Steam call at all; the outer guard `onlinemultiplayersettings == 1 && net_ready` stays)
			_online_text = string_replace(loc("NET_PAUSE_JOINED"), "{NAME}", global.net_host_name)
```
`global.net_host_name` is created in `net_init` (runs on every platform), reset in `net_reset_lobby_state`. When the owner changes, the new owner rewrites `host_name` in `net_become_host` (M:482) and followers pick it up at the next 30-tick refresh (<= 0.5 s).

### 8.6 BYE race and the deferred close (contingency H3, NOT in the baseline)

`net_leave_lobby` sends BYE and closes every session in the same call (M:377-389). `CloseSessionWithUser` "immediately frees up resources" and the header says nothing about flushing queued reliable data, so the BYE may never leave the machine: the same exposure as 2.x, limited to the "player left" notice, which `lobby_chat_update`, the member prune and the 10 s timeout also produce. If the two-account test (10.9 #4) shows lost BYEs, add:

```gml
// gate-scan: project
// global.net_close_queue = [];   // [{user, at}] in net_init and net_reset_lobby_state
function net_close_session_later(_user, _now = current_time) {            // used ONLY by net_leave_lobby (replaces the direct close)
    array_push(global.net_close_queue, {user:_user, at:_now});
}
function net_close_queue_pump(_now = current_time) {                       // net_tick, after the send phase
    for (var _i = array_length(global.net_close_queue) - 1; _i >= 0; --_i) {
        var _e = global.net_close_queue[_i];
        // B's cancel rule: the id is a member again (we re-joined a lobby with the same friends) -> keep the session
        if (net_lobby_member(_e.user)) { array_delete(global.net_close_queue, _i, 1); continue; }
        if (_now - _e.at >= 200) { tcc_steam_net_close_p2p_session(_e.user); array_delete(global.net_close_queue, _i, 1); }
    }
}
```
and `net_cleanup` (process exit) skips the explicit close entirely (B's exit rule): at exit the process teardown frees the sessions and an immediate close can only discard the BYE. Keep the same triggers as today (INV-A7); only the timing of the close changes. Not in the baseline because it changes timing and may be unnecessary.

---------------------------------------------------------------------------------------------------

## 9. Behaviour: errors, disconnects, restart, Steam unavailable

### 9.1 Send result taxonomy

| EResult | Meaning | Game reaction |
|---|---|---|
| `Ok` 1 | queued (not delivered, same as 2.x `true`) | `net_send_to` true |
| `LimitExceeded` 25 | the per-peer send queue is full (512 KB default) | `false`; counted per type; the level sender stops its burst and retries the SAME chunk next tick (the 2.x signal); small reliable control packets go to the outbox (7.3) |
| `NoConnection` 3 | session broken and no restart flag | cannot happen (flag always set); counted and logged if seen |
| `InvalidParam` 8 / `None` 0 | wrapper bug / not attempted | counted and logged (rate limited) |
| `Fail` 2, `undefined` | Steam unavailable / extension missing | mapped to `Fail`, counted, nothing throws |

### 9.2 Peer loss, host leaving (unchanged logic, constants unchanged)

Four detection paths: `lobby_chat_update` flags (M:1110-1125), 30-tick member prune (M:499-518), 10 s silence (`net_update_ghosts`, M:862-871), BYE (`_size == 1`). A session closed on timeout reopens on the next send of either side (`AutoRestartBrokenSession`) and our callback re-accepts a still-listed member; our own 2 s ping reaccepts implicitly anyway. Voluntary host leave: BYE broadcast, owner handoff to the earliest first-seen member, `lobby_leave`, close every session, reset. Host crash: lobby events and the member prune remove the ghost within ~0.5 s of Steam noticing, the silence timeout within 10 s. In-flight level transfers die on both sides when the peer leaves the lobby (L:152, S:442), and now also after 60 s without progress (8.4).

### 9.3 `game_restart` and the extension `final` (dominant risk R1)

The project depends on the lobby, maps, buffers and sessions surviving `net_game_restart()` (INV-B16). 3.0 has `final = steam_api_shutdown` (`Steamworks.yy:20`) and a `call_once` init hook; whether the runner calls `final` on `game_restart()` cannot be settled from sources (MCORE 7 item 1).

| Case | What happens | Effect here |
|---|---|---|
| A: `final` not run, statics survive | nothing changes | re-registering bumps a refcount; fine |
| B: dispatcher statics reset, native handle kept | the contract's global state survives, but EXT's function map does not: an Execute packet for an unknown handle logs "BAD PACKET" and `continue`s without consuming its argument bytes (EXT:333-338), desyncing that frame's packet | cannot be fixed from here; the only callback exposed is session request/failed; the 2 s ping is the fallback. `net_register_steam_callbacks()` at the next manager Create re-registers |
| C: `final` runs, Steam shut down | all native slots cleared, `steam_api_is_initialized()` false, init hook never re-runs | `tcc_steam_update()` sees the ready edge false -> `__tcc_steam_on_lost()`; `net_tick` is inert; the party is lost regardless of this design. The core decision (blank `final` in the local `Steamworks.yy`, or re-init) is the real fix |

Required runtime test: after an ending restart with a live party, read the `[NET] restart:` / `[NET] first tick:` lines, then have the second account send first; `req` must increase and "BAD PACKET" must be absent. Also note (pre-existing, not a regression): `o_endingreq/Create_0.gml:3` destroys the pump owner `o_fullscreensystem` and `o_loading/Create_0.gml:13` recreates it, so no callback (session requests included) is delivered while it is absent; our own 2 s pings cover session requests.

### 9.4 Steam unavailable

| Configuration | `platform_steam()` | What runs |
|---|---|---|
| Steam release, client running | true | everything |
| Steam desktop, client not running | true | with Debug on Auto the extension relaunches through Steam and exits when the process was not started by Steam (MCORE 2.1); if the process survives with `steam_api_is_initialized() == false`: `net_tick` returns at its guard, wrappers return inert values, no raw call |
| `Apple`, `Mobile`, `SteamAndroid`, `QA`, `iOSCheck`, `Check`, `MacAppStore` | false | `net_init` allocates the buffers; `net_register_steam_callbacks()` and every wrapper return at `platform_steam()`/`tcc_steam_ready()`; no `steam_networking_*` symbol is ever called |
| Steam goes away mid-session | true | next refresh sees `member_count <= 0` -> `net_reset_lobby_state()` + `NET_DISCONNECTED`; sends return `Fail`, nothing throws; the contract's `__tcc_steam_on_lost()` resets its registries |

---------------------------------------------------------------------------------------------------

## 10. Test plan

### 10.1 What the harness can and cannot prove

All online state is global singletons (`global.net_*`, ds_maps, shared buffers, session globals), so the system under test is the REAL net layer acting as the only node, and every remote peer is a script that feeds bytes into a mock and reads what the node sent. Protocol writers and decoders are pure functions that run on both sides of the wire, so round trips cover the remote half. The mock replaces only the raw natives (it sits inside the `tcc_steam_net_*` wrappers and the three lobby read wrappers, section 5); argument hygiene, clamping, result mapping, the classifier and every `net_*` function run for real.

The harness deliberately does NOT make `tcc_steam_ready()` answer through the mock (R10): `net_tick` itself is not driven (it returns at its Steam guard in Check). Tests call `net_receive_packets`, `net_send_to`, `net_outbox_pump`, `net_accept_pending_sessions`, `net_on_session_request`, `net_send_hello/_bye/_ping`, `net_leave_lobby`, `net_remove_player` and `net_levelshare_tick/_receive` directly. The tick ORDER (INV-B3) is protected statically (gate N-3). Time is driven through `_now` parameters of the new timers and by writing fields (`last_update`, `progress_at`), never by sleeping; "a new tick" is `global.net_refresh_forced_tick = -1`.

### 10.2 Mock spec and harness (code)

```gml
// gate-scan: project
// scripts/scr_net_mock/scr_net_mock.gml
function net_test_hex(_buffer, _offset, _count) {
    static _digits = "0123456789abcdef";
    var _out = "";
    for (var _i = 0; _i < _count; ++_i) {
        var _b = buffer_peek(_buffer, _offset + _i, buffer_u8);
        _out += string_char_at(_digits, (_b >> 4) + 1) + string_char_at(_digits, (_b & 15) + 1);
    }
    return _out;
}
function net_test_from_hex(_hex) {
    static _digits = "0123456789abcdef";
    var _n = string_length(_hex) div 2;
    var _buffer = buffer_create(_n, buffer_fixed, 1);
    for (var _i = 0; _i < _n; ++_i) {
        var _hi = string_pos(string_char_at(_hex, _i * 2 + 1), _digits) - 1;
        var _lo = string_pos(string_char_at(_hex, _i * 2 + 2), _digits) - 1;
        buffer_poke(_buffer, _i, buffer_u8, _hi * 16 + _lo);
    }
    return _buffer;
}

/// Models ISteamNetworkingMessages behind the tcc_steam_net_* wrappers. Quirks reproduced from the native (each cited):
/// payload written at offset 0, never grown, overflow releases that and every later fetched message and sets the error text (NAT:195-201);
/// send results 1/25/3/8/2/undefined (NAT:116-157); a per-peer queue model that yields 25 organically; NoConnection after a peer-closed
/// session unless AutoRestartBrokenSession is in the flags; implicit accept on send; session requests posted for unaccepted senders and
/// re-posted on demand; unaccepted-sender policy "hold" or "drop" (the real behaviour is unverified, tests run both); deferred callbacks.
function TccNetMock(_my_id) constructor {
    my_id = _my_id;
    members = [_my_id];             // lobby seam; includes our own id exactly like the real member list
    owner = _my_id;
    inbox = [];                     // [{from, buf, size, held}]
    send_log = [];                  // [{user, count, offset, channel, flags, result, hex}]
    receive_log = [];               // [{channel, count}]
    accept_log = [];
    close_log = [];
    results = [];                   // scripted send results, consumed first; may contain undefined
    default_result = 1;
    cap = 524288;                   // per-peer send queue model (SendBufferSize default)
    queued = {};                    // string(user) -> queued bytes
    accepted = {};
    requested = {};
    closed_by_peer = {};
    policy_unaccepted = "hold";     // "hold" | "drop"
    error_text = "";
    request_cb = undefined;
    failed_cb = undefined;
    pending_callbacks = [];
    refresh_calls = 0;              // number of times the lobby seam was asked for the member count = net_refresh_members() calls
    max_native_count = 0;           // largest `count` ever passed to receive; must stay 1

    last_error = function() { return error_text; };
    lobby_member_count = function() { refresh_calls += 1; return array_length(members); };
    lobby_member_id = function(_index) { return (_index >= 0 && _index < array_length(members)) ? members[_index] : int64(0); };
    lobby_owner_id = function() { return owner; };

    send = function(_user, _buffer, _flags, _channel, _offset, _count) {
        var _length = buffer_get_size(_buffer);
        var _key = string(_user);
        var _result = default_result;
        if (_offset >= _length || _count == 0 || _offset + _count > _length) {
            _result = 8;
        } else if (variable_struct_exists(closed_by_peer, _key) && (_flags & 32) == 0) {
            _result = 3;
        } else if (array_length(results) > 0) {
            _result = results[0];
            array_delete(results, 0, 1);
        } else {
            var _q = variable_struct_exists(queued, _key) ? queued[$ _key] : 0;
            if (_q + _count > cap) _result = 25; else queued[$ _key] = _q + _count;
        }
        if (_result == 1) {
            accepted[$ _key] = true;                        // sending implicitly accepts
            variable_struct_remove(closed_by_peer, _key);   // and AutoRestartBrokenSession reopens a dead session
        }
        array_push(send_log, {user:_user, count:_count, offset:_offset, channel:_channel, flags:_flags, result:_result,
            hex:net_test_hex(_buffer, _offset, min(_count, _length - _offset))});
        return _result;
    };

    receive = function(_channel, _out, _count) {
        array_push(receive_log, {channel:_channel, count:_count});
        max_native_count = max(max_native_count, _count);
        error_text = "";
        var _fetched = [];
        for (var _i = 0; _i < array_length(inbox) && array_length(_fetched) < _count; ++_i) {
            if (!inbox[_i].held) array_push(_fetched, inbox[_i]);
        }
        for (var _f = 0; _f < array_length(_fetched); ++_f) {      // fetched messages leave the queue even if they do not fit
            for (var _j = 0; _j < array_length(inbox); ++_j) if (inbox[_j] == _fetched[_f]) { array_delete(inbox, _j, 1); break; }
        }
        var _result = [];
        var _offset = 0;
        var _capacity = buffer_get_size(_out);
        for (var _m = 0; _m < array_length(_fetched); ++_m) {
            var _msg = _fetched[_m];
            if (_offset + _msg.size > _capacity) {
                error_text = "mock: output buffer exhausted.";
                for (var _k = _m; _k < array_length(_fetched); ++_k) buffer_delete(_fetched[_k].buf);   // this and every later fetched message
                break;
            }
            buffer_copy(_msg.buf, 0, _msg.size, _out, _offset);
            var _info = new SteamNetworkingMessage();
            _info.offset = _offset;
            _info.size = _msg.size;
            _info.steam_id_remote = _msg.from;
            _info.conn = 0;
            _info.channel = _channel;
            _info.flags = 0;
            array_push(_result, _info);
            _offset += _msg.size;
            buffer_delete(_msg.buf);
        }
        return _result;
    };

    accept = function(_user) {
        var _key = string(_user);
        array_push(accept_log, _user);
        var _known = variable_struct_exists(accepted, _key) || variable_struct_exists(requested, _key);
        accepted[$ _key] = true;
        for (var _i = 0; _i < array_length(inbox); ++_i) if (inbox[_i].from == _user) inbox[_i].held = false;
        return _known;
    };
    close = function(_user) {
        array_push(close_log, _user);
        variable_struct_remove(accepted, string(_user));
        return true;
    };

    post_request = function(_from) {
        requested[$ string(_from)] = true;
        if (!is_callable(request_cb)) return;
        var _r = new SteamNetworkingMessagesSessionRequest();
        _r.steam_id_remote = _from;
        array_push(pending_callbacks, {cb:request_cb, arg:_r});
    };
    /// A message from _from arrives (copied from _source[0 .. _size)). Unaccepted senders post a session request.
    inject = function(_from, _source, _size) {
        var _ok = variable_struct_exists(accepted, string(_from));
        if (!_ok) post_request(_from);
        if (!_ok && policy_unaccepted == "drop") return;
        var _copy = buffer_create(_size, buffer_fixed, 1);
        buffer_copy(_source, 0, _size, _copy, 0);
        array_push(inbox, {from:_from, buf:_copy, size:_size, held:!_ok});
    };
    inject_hex = function(_from, _hex) {
        var _b = net_test_from_hex(_hex);
        inject(_from, _b, buffer_get_size(_b));
        buffer_delete(_b);
    };
    set_session_request_callback = function(_cb) { request_cb = _cb; return true; };
    set_session_failed_callback = function(_cb) { failed_cb = _cb; return true; };
    fire_session_request = function(_id) {                    // queued like the native does; runs only in pump()
        var _r = new SteamNetworkingMessagesSessionRequest();
        _r.steam_id_remote = _id;
        array_push(pending_callbacks, {cb:request_cb, arg:_r});
    };
    fire_session_failed = function(_id, _reason, _text) {
        var _r = new SteamNetworkingMessagesSessionFailed();
        _r.steam_id_remote = _id;
        _r.end_reason = _reason;
        _r.debug_msg = _text;
        array_push(pending_callbacks, {cb:failed_cb, arg:_r});
    };
    /// One "time-source tick": runs every queued callback the way the dispatcher does (EXT:350): with a shared empty `self`.
    pump = function() {
        var _list = pending_callbacks;
        pending_callbacks = [];
        for (var _i = 0; _i < array_length(_list); ++_i) {
            var _cb = _list[_i].cb;
            var _arg = _list[_i].arg;
            if (is_callable(_cb)) with ({}) method_call(_cb, [_arg]);
        }
        return array_length(_list);
    };
    drain = function() { queued = {}; };
    free = function() {
        for (var _i = 0; _i < array_length(inbox); ++_i) if (buffer_exists(inbox[_i].buf)) buffer_delete(inbox[_i].buf);
        inbox = [];
    };
}
```

```gml
// gate-scan: project
// scripts/scr_online_transport_selfcheck/scr_online_transport_selfcheck.gml
#macro NET_TEST_STATE   "1007000000c0420000004307ffffff000000803f0000803f000000000000803f03725f6c766c3100725f6c766c310000010200008040000040c00000"
#macro NET_TEST_HELLO   "110300506c61796572000000000000c05e400000"
#macro NET_TEST_PING    "130d0c0b0a725f6c766c3100725f6c766c310000"
#macro NET_TEST_PONG    "1404030201"
#macro NET_TEST_REQUEST "16303132333435363738396162636465663031323334353637383961626364656600"

// Ids above 2^53 must be built from strings: a numeric literal would already be a rounded double.
function net_test_ids() {
    return [int64("76561198000000001"), int64("76561198000000002"), int64("76561198000000003"), int64("76561198999999999")];
}
function net_test_state() {
    return {seq:7, x:96, y:128, image_index:7, image_blend:c_white, image_xscale:1, image_yscale:1, image_angle:0, image_alpha:1,
        color:3, room_name:"r_lvl1", level_key:"r_lvl1", skin:0, hat:1, item:2, hsp:4, vsp:-3, is_dead:0, zerogrv:0};
}
function net_test_begin(_my_id, _others) {
    timing_boot();                                   // as scr_confirmation_modal_selfcheck does; timing_tick_id() needs a clock
    // net_write_hello reads the equipped cosmetics; the self-check can start before the customizables are loaded
    if (!variable_global_exists("skinselected")) global.skinselected = 0;
    if (!variable_global_exists("hatselected")) global.hatselected = 0;
    net_init();                                      // Steam-free
    var _mock = new TccNetMock(_my_id);
    for (var _i = 0; _i < array_length(_others); ++_i) array_push(_mock.members, _others[_i]);
    global.tcc_net_mock = _mock;
    global.net_my_steam_id = _my_id;
    global.net_active = true;
    global.net_is_host = false;
    global.net_lobby_id = int64("109775240000000001");
    global.net_refresh_forced_tick = -1;
    net_refresh_members();
    _mock.refresh_calls = 0;
    net_register_steam_callbacks();                  // goes through the mock: stores the two USER callbacks
    return _mock;
}
function net_test_end() {
    if (variable_global_exists("tcc_net_mock") && is_struct(global.tcc_net_mock)) global.tcc_net_mock.free();
    global.tcc_net_mock = undefined;
    net_reset_lobby_state();
    global.net_my_steam_id = int64(0);
    global.net_active = false;
}

function scr_online_transport_selfcheck() {
    scr_port_assert(!tcc_steam_ready(), "transport self-check expects an inert Steam layer (Check configuration)");
    net_test_classify();
    net_test_send_args();
    net_test_receive_isolation();
    net_test_budget();
    net_test_accept();
    net_test_outbox();
    net_test_level_stall();
    show_debug_message("TCC_ONLINE_TRANSPORT_SELF_CHECK_PASS");
}

function net_test_classify() {
    var _m = new SteamNetworkingMessage();
    scr_port_assert(tcc_steam_net_classify([_m], "") == _m, "classify: a message is returned");
    scr_port_assert(tcc_steam_net_classify([], "x: output buffer exhausted.") == TCC_NET_RX_DROPPED, "classify: exhaustion is a consumed message");
    scr_port_assert(is_undefined(tcc_steam_net_classify([], "")), "classify: empty queue");
    scr_port_assert(is_undefined(tcc_steam_net_classify([], "Steam API not initialized")), "classify: Steam not ready is not exhaustion");
    scr_port_assert(is_undefined(tcc_steam_net_classify(undefined, "")), "classify: extension missing");
}

function net_test_send_args() {
    var _ids = net_test_ids();
    scr_port_assert(is_int64(_ids[0]) && string_length(string(_ids[0])) == 17, "fixture ids are exact 17 digit int64");
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    buffer_resize(global.net_send_buffer, 8236);                      // grown buffer with a stale tail (L:168)
    var _size = net_write_state(global.net_send_buffer, net_test_state());
    scr_port_assert(_size == 60, "golden STATE fixture is 60 bytes");
    scr_port_assert(net_send_to(_ids[1], _size, false), "unreliable send to a member succeeds");
    var _sent = _mock.send_log[0];
    scr_port_assert(_sent.count == 60 && _sent.offset == 0 && _sent.channel == 0 && _sent.flags == 33, "STATE: offset 0, count = packet size, channel 0, flags 33");
    scr_port_assert(_sent.hex == NET_TEST_STATE, "STATE bytes equal the golden vector");
    scr_port_assert(!net_send_to(_ids[0], _size, false) && !net_send_to(_ids[3], _size, false) && array_length(_mock.send_log) == 1,
        "own id and non-members are refused without a native call");
    _mock.results = [25];
    scr_port_assert(!net_send_to(_ids[1], _size, false) && tcc_steam_net_last_send_result() == SteamApiResult.LimitExceeded,
        "LimitExceeded is false, and the reason is available");
    _mock.results = [undefined];
    scr_port_assert(!net_send_to(_ids[1], _size, false) && tcc_steam_net_last_send_result() == SteamApiResult.Fail, "undefined maps to Fail, no exception");
    scr_port_assert(!tcc_steam_net_packet_send(_ids[1], global.net_send_buffer, 0) && tcc_steam_net_last_send_result() == SteamApiResult.InvalidParam,
        "size 0 is refused before the native");
    scr_port_assert(!tcc_steam_net_packet_send(_ids[1], -1, 5) && !tcc_steam_net_packet_send(undefined, global.net_send_buffer, 5),
        "bad buffer / bad id are refused without show_error");
    net_send_hello(_ids[1], true);
    net_send_bye();
    var _n = array_length(_mock.send_log);
    scr_port_assert(_mock.send_log[_n - 2].flags == 41 && _mock.send_log[_n - 1].flags == 41 && _mock.send_log[_n - 1].hex == "12", "HELLO and BYE: flags 41; BYE is one byte 0x12");
    net_test_end();
}

function net_test_receive_isolation() {
    var _ids = net_test_ids();
    // Run twice: with the production buffer, and with a 2048-byte buffer that forces the "output buffer exhausted" path.
    for (var _pass = 0; _pass < 2; ++_pass) {
        var _mock = net_test_begin(_ids[0], [_ids[1], _ids[2], _ids[3]]);
        scr_port_assert(buffer_get_size(global.net_recv_buffer) == NET_RECV_BUFFER_BYTES, "production receive buffer is 524288 bytes");
        var _production = global.net_recv_buffer;
        var _small = -1;
        if (_pass == 1) { _small = buffer_create(2048, buffer_fixed, 1); global.net_recv_buffer = _small; }
        _mock.accepted[$ string(_ids[1])] = true; _mock.accepted[$ string(_ids[2])] = true; _mock.accepted[$ string(_ids[3])] = true;
        var _garbage = buffer_create(9000, buffer_fixed, 1);
        buffer_poke(_garbage, 0, buffer_u8, 16);
        _mock.inject_hex(_ids[1], NET_TEST_STATE);
        _mock.inject(_ids[2], _garbage, 9000);
        _mock.inject_hex(_ids[3], NET_TEST_PING);
        net_receive_packets();
        scr_port_assert(ds_map_exists(global.net_players, string(_ids[1])), "valid STATE before the oversized message is processed");
        scr_port_assert(ds_map_exists(global.net_players, string(_ids[3])), "valid PING after the oversized message is processed in the SAME tick");
        scr_port_assert(array_length(_mock.inbox) == 0 && _mock.max_native_count == 1, "queue drained; native count was always 1");
        var _last = _mock.send_log[array_length(_mock.send_log) - 1];
        scr_port_assert(string_copy(_last.hex, 1, 2) == "14" && _last.flags == 33, "the PING was answered with an unreliable PONG");
        buffer_delete(_garbage);
        if (_pass == 1) { buffer_delete(_small); global.net_recv_buffer = _production; }
        net_test_end();
    }
}

function net_test_budget() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    _mock.accepted[$ string(_ids[1])] = true;
    repeat (200) _mock.inject_hex(_ids[1], NET_TEST_PING);
    net_receive_packets();
    scr_port_assert(array_length(_mock.receive_log) == 128 && array_length(_mock.inbox) == 72, "exactly 128 messages per tick; the rest stays queued");
    net_test_end();
}

function net_test_accept() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    var _t0 = 100000;
    _mock.fire_session_request(_ids[1]);
    scr_port_assert(array_length(global.net_session_requests) == 0, "callbacks are deferred: nothing happens before pump()");
    _mock.pump();                                                     // runs net_on_session_request with a dummy self
    scr_port_assert(array_length(global.net_session_requests) == 1, "member request queued by the callback");
    net_accept_pending_sessions(_t0);
    scr_port_assert(array_length(_mock.accept_log) == 1 && _mock.accept_log[0] == _ids[1] && array_length(global.net_session_requests) == 0, "member accepted once, queue empty");
    // stranger: fresh -> one forced refresh, never accepted, expires, ignored for 30 s
    global.net_refresh_forced_tick = -1;
    _mock.refresh_calls = 0;
    net_session_request_add(_ids[3], _t0);
    net_accept_pending_sessions(_t0);
    scr_port_assert(_mock.refresh_calls == 1 && array_length(_mock.accept_log) == 1 && array_length(global.net_session_requests) == 1, "fresh stranger: one forced refresh, not accepted");
    net_accept_pending_sessions(_t0);
    scr_port_assert(_mock.refresh_calls == 1, "the forced refresh is limited to one per tick");
    net_accept_pending_sessions(_t0 + NET_SESSION_REQUEST_TTL_MS + 1);
    scr_port_assert(array_length(global.net_session_requests) == 0, "stranger expired");
    scr_port_assert(!net_session_request_add(_ids[3], _t0 + 20000), "re-post inside the ignore window is not queued");
    scr_port_assert(net_session_request_add(_ids[3], _t0 + NET_SESSION_REQUEST_TTL_MS + NET_SESSION_IGNORE_MS + 2), "ignore window ends");
    // the budget is shared with the receive loop
    global.net_refresh_forced_tick = timing_tick_id();
    _mock.refresh_calls = 0;
    _mock.accepted[$ string(_ids[3])] = true;
    _mock.inject_hex(_ids[3], NET_TEST_PING);
    net_receive_packets();
    scr_port_assert(_mock.refresh_calls == 0, "a tick whose forced refresh was spent does not refresh again for a non-member sender");
    // malformed requests and bounds
    net_on_session_request(undefined); net_on_session_request({});
    var _bad = new SteamNetworkingMessagesSessionRequest();
    net_on_session_request(_bad);
    scr_port_assert(!net_session_request_add(0, _t0) && !net_session_request_add(_ids[0], _t0) && !net_session_request_add("x", _t0), "id 0, own id and strings are ignored");
    global.net_session_requests = [];
    for (var _i = 0; _i < 40; ++_i) net_session_request_add(int64("765611981000000" + string(10 + _i)), _t0);
    scr_port_assert(array_length(global.net_session_requests) <= NET_SESSION_REQUEST_MAX, "queue is bounded");
    net_test_end();
}

function net_test_outbox() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    _mock.results = [25];
    net_send_hello(_ids[1], true);                                    // refused with LimitExceeded -> outbox
    scr_port_assert(array_length(global.net_outbox) == 1, "refused HELLO enters the outbox");
    var _kept = global.net_outbox[0].buffer;
    net_outbox_pump();
    scr_port_assert(array_length(global.net_outbox) == 0 && !buffer_exists(_kept), "retry succeeds, entry and buffer freed");
    var _n = array_length(_mock.send_log);
    scr_port_assert(_mock.send_log[_n - 1].hex == _mock.send_log[_n - 2].hex && _mock.send_log[_n - 1].flags == 41, "the retry carries the identical bytes");
    _mock.results = [25, 25];                                         // the chunk and the BYE are refused: neither is ever queued
    buffer_seek(global.net_send_buffer, buffer_seek_start, 0); buffer_write(global.net_send_buffer, buffer_u8, NET_PACKET_LEVEL_CHUNK);
    net_send_to(_ids[1], NET_SHARE_HEADER, true);
    net_send_bye();
    scr_port_assert(array_length(global.net_outbox) == 0, "chunks and BYE are not outbox-eligible");
    _mock.results = [25];
    net_send_hello(_ids[1], true);
    net_outbox_pump(current_time + NET_OUTBOX_AGE_MS + 1);
    scr_port_assert(array_length(global.net_outbox) == 0, "entries expire");
    _mock.results = [25];
    net_send_hello(_ids[1], true);
    array_delete(_mock.members, 1, 1);
    net_refresh_members();
    net_outbox_pump();
    scr_port_assert(array_length(global.net_outbox) == 0, "entries for a peer that left are dropped");
    _mock.cap = 0;                                                    // organic LimitExceeded from the queue model
    array_push(_mock.members, _ids[2]);
    net_refresh_members();
    repeat (NET_OUTBOX_MAX + 4) net_send_hello(_ids[2], true);
    scr_port_assert(array_length(global.net_outbox) <= NET_OUTBOX_MAX, "outbox is bounded");
    net_test_end();
}

function net_test_level_stall() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    _mock.cap = 0;                                                    // every send is refused
    var _data = buffer_create(100, buffer_fixed, 1);
    global.net_share_out = [{peer:_ids[1], md5:"0123456789abcdef0123456789abcdef", buffer:_data, size:100, offset:0, progress_at:current_time - 70000}];
    net_levelshare_tick();
    scr_port_assert(array_length(global.net_share_out) == 0 && !buffer_exists(_data), "a transfer with no accepted chunk for 60 s is dropped and its buffer freed");
    net_test_end();
}
```

Notes on the code above: all fixture fields are assigned by dot access, no `steam_`-prefixed word appears outside `SAFE` (R9). In `net_test_receive_isolation` the production buffer is restored after the small-buffer pass; the harness never leaks a replaced `global.net_recv_buffer`. Every scenario installs and removes the mock inside one synchronous function; a failing `scr_port_assert` throws and the Check run aborts anyway. The two assertions on the PONG are deliberately loose about the stamp (it is `current_time`-derived): the first byte `0x14` is what matters, the exact PONG bytes are covered by the golden vector round trip below.

### 10.3 Test cases

| ID | What | Assertions | Inv |
|---|---|---|---|
| T-S1 | STATE from a send buffer grown to 8236 bytes | native args offset 0, count 60, channel 0, flags 33, bytes == golden STATE | A3, A8 |
| T-S2 | every packet type via its real sender (`net_send_hello` x2, `net_send_bye`, `net_send_ping`, PONG inside the receive path, `net_er_send_picks`, level request/deny/chunk) | flags 41 for 17, 18, 21, 22, 23, 24 and 33 for 16, 19, 20; never 4/5; channel 0 | A4, B19 |
| T-S3 | scripted results 1, 25, 3, `undefined`, 8 | `net_send_to` true only for 1; no exception for `undefined`; reason available through `tcc_steam_net_last_send_result()`; no log spam for 25 | A5 |
| T-S4 | send to a non-member and to our own id | false, native not called (R12 regression) | N2 |
| T-S5 | size 0 / non-numeric id / missing buffer | no native call, no `show_error` | A3 |
| T-C1 | `tcc_steam_net_classify` four cases (plus extension missing) | per 10.2 | A1 |
| T-R1 | queue `[STATE A, 9000-byte B, PING C]` with the production buffer AND with a forced 2048-byte buffer | A and C processed in the SAME tick in both passes; native `count` always 1 | A1, A14 |
| T-R2 | 200 queued valid messages | exactly 128 processed, 72 remain | B3 |
| T-R3 | 8236-byte LEVEL_CHUNK through the production buffer | delivered whole (buffer >= 524288), reader accepts it; a 600000-byte injected message is consumed and dropped (classifier path), loop terminates | A2 |
| T-R4 | message from a non-member | dropped with exactly one forced refresh per tick; none if the tick's refresh was spent by the accept pass | B7 |
| T-R5 | HELLO(reply 0) -> reply HELLO(reply 1) to the sender; BYE size 1; PING -> 5-byte PONG | reply flags 41, PONG flags 33, `net_remove_player` closes exactly once | B8 |
| T-R6 | a 62-byte STATE after a 200-byte packet through the same buffer | decodes, no stale-byte reads (existing fuzz still passes) | A2 |
| T-R7 | message with `offset != 0`, sender 0 | dropped, counted | A2 |
| T-A1 | `fire_session_request` -> (nothing) -> `pump()` -> accept pass | callback deferred; runs with a dummy `self`; member accepted once | A6, A11 |
| T-A2 | stranger: fresh -> one forced refresh; expires after the TTL; ignore window; window ends | per the code above; cached member overrides the ignore window | A6 |
| T-A3 | 40 distinct ids; malformed requests (`undefined`, `{}`, missing/zero/own id, string id) | queue <= 32, no exception | A6 |
| T-A4 | requests while `net_active == false`; `net_reset_lobby_state` | nothing accepted, entries kept until TTL; reset clears queue and ignore map | A6 |
| T-A5 | `net_register_steam_callbacks()` twice | mock holds exactly one callback per kind | A11 |
| T-A6 | `fire_session_failed` | `session_failed` stats incremented, last failure recorded, log rate limited, membership untouched | B6 |
| T-A7 | unaccepted-sender policy `drop` and `hold`, sender in the member list | node consistent in both; first message flows after the accept pass (hold) or after the sender's re-send (drop) | A6 |
| T-O1 | outbox: HELLO refused with 25 | enters the outbox, delivered once with identical bytes, freed | N-outbox |
| T-O2 | chunk, BYE, STATE refused with 25 | never queued | B15 |
| T-O3 | expiry, peer left, overflow (cap 16), lobby reset | buffers freed (`buffer_exists` false), bounded | |
| T-L1 | `net_leave_lobby` with 3 members | one BYE per member (flags 41), closes == members, no accept | A7 |
| T-L2 | close triggers: BYE, 10 s timeout (`last_update` edited), refresh prune close; lobby-lost reset, kick, failed-join paths do not | counters per scenario | A7 |
| T-L3 | level-share round trip: serve a minimal valid level to a scripted requester, feed the mock's chunks back through the reader | md5 matches, file cached; with a scripted `25` on the 3rd chunk the same chunk is resent and the final bytes are identical | B15 |
| T-L4 | stalled transfer (`cap = 0`, `progress_at` 70 s old) | dropped, buffer freed, `stalled == 1`; a healthy transfer is untouched | |
| T-W1 | golden vectors (4.2) | encoder output equals the vector for STATE, HELLO, BYE, PING, PONG, REQUEST, DENY, CHUNK header, ER_PICKS; each decoder accepts its vector and rejects it truncated at every length | A14 |
| T-I1 | ids | `is_int64` on fixtures and on every `steam_id_remote` produced by the mock; `string(id)` has 17 digits; sender == member id for the same user | A13 |
| T-H1 | host name cache | `net_reset_lobby_state` clears it; `net_cache_host_name()` is a no-op for an owner; PS and F read only the global | B18 |
| T-P1 | production allocation / inert layer | `buffer_get_size(global.net_recv_buffer) == NET_RECV_BUFFER_BYTES`, type fixed after `net_init()`; wrappers with no mock return inert values (`false`, `undefined`) and never throw | A12 |

Inside SAFE's own `tcc_steam_selfcheck()` (CA-7): a `SteamNetworkingMessagesSessionRequest` delivered through `with ({}) method_call(tcc_steam_relay, [struct])` reaches the `net_session_request` listener twice (not consumed); a `SteamNetworkingMessagesSessionFailed` reaches `net_session_failed`; a throwing listener does not escape the relay and `relay_errors` increments (contract S-3 already covers the throw case generically).

### 10.4 Existing self-checks stay green

`scr_online_cosmetics_selfcheck()` (M:1176-1264) builds packets in its own local buffers at offset 0, uses the `NET_PROTOCOL` macro and needs no edit; call it, do not edit it. `tools/build.py --self-check` already runs the Check self-check and requires `TCC_PORT_SELF_CHECK_PASS`; the new function prints `TCC_ONLINE_TRANSPORT_SELF_CHECK_PASS` before it for log greps.

### 10.5 Check-configuration preconditions (verified at the first Check run)

`Steamworks_API.gml` enums and constructors (`SteamApiResult`, `SteamNetworkingSendFlags`, `SteamNetworkingMessage`, `SteamNetworkingMessagesSessionRequest/Failed`) are plain GML declarations and are assumed to compile and run in Check and on iOS/Android/MAS where the extension is absent (same open question as inventory U3). If the first Check run shows otherwise, replace the enum uses in `M`, `SAFE` and the mock by the numeric literals 1, 25, 3, 41, 33 and build the two request/failed structs as `{}` with a `steam_id_remote` member assigned by dot.

### 10.6 Static gates: extension of the contract's `steam_invariants`

Written as additions to `SP/wc/check_port_steam.py` (`steam_invariants(root, yy)` calls `net_invariants(root)`), not as a second scan loop. The contract's gates 1-7 apply unchanged (raw 3.0 call outside SAFE, unknown `steam_*` token, stale constants, removed wrappers, relay/private names outside SAFE, no closure on a raw-call line). Net additions:

```python
def _function_body(text, name):
    m = re.search(r'\bfunction\s+%s\s*\(' % re.escape(name), text)
    if not m:
        return None
    i = text.index('{', m.end())
    depth = 0
    for j in range(i, len(text)):
        depth += (text[j] == '{') - (text[j] == '}')
        if depth == 0:
            return text[i:j + 1]
    return None


def net_invariants(root):
    problems = []
    mp = (root / 'scripts/scr_online_multiplayer/scr_online_multiplayer.gml').read_text(encoding='utf-8')
    safe = (root / 'scripts/scr_steam_safe/scr_steam_safe.gml').read_text(encoding='utf-8')
    # N-1 protocol and buffers
    m = re.search(r'#macro\s+NET_PROTOCOL\s+(\d+)', mp)
    if not m or m.group(1) != '3':
        problems.append('net_protocol: NET_PROTOCOL must be 3')
    m = re.search(r'#macro\s+NET_RECV_BUFFER_BYTES\s+(\d+)', mp)
    if not m or int(m.group(1)) < 524288:
        problems.append('net_recv_buffer: NET_RECV_BUFFER_BYTES must be >= 524288')
    if not re.search(r'global\.net_recv_buffer\s*=\s*buffer_create\(\s*NET_RECV_BUFFER_BYTES\s*,\s*buffer_fixed', mp):
        problems.append('net_recv_buffer: must be a fixed NET_RECV_BUFFER_BYTES buffer')
    # N-2 exactly one native send and one native receive, on the game channel, count 1
    if len(re.findall(r'steam_networking_messages_send_message_to_user\(', safe)) != 1 or 'TCC_NET_CHANNEL, 0, _count)' not in safe:
        problems.append('net_send: exactly one native send, channel TCC_NET_CHANNEL, offset 0, explicit count')
    if len(re.findall(r'steam_networking_messages_receive_messages_on_channel\(', safe)) != 1 or 'TCC_NET_CHANNEL, _buffer, 1)' not in safe:
        problems.append('net_receive: exactly one native receive, count 1')
    # N-3 INV-B3 tick order, and accept before any send
    body = _function_body(mp, 'net_tick') or ''
    order = ['net_accept_pending_sessions(', 'net_outbox_pump(', 'net_send_player_state(', 'net_send_ping(',
             'net_receive_packets(', 'net_update_ghosts(', 'net_levelshare_tick(']
    pos = [body.find(x) for x in order]
    if -1 in pos or pos != sorted(pos):
        problems.append('net_tick_order: accept -> outbox -> state -> ping -> receive -> ghosts -> levelshare')
    # N-4 sends go only to members (not the net_members map, which contains our own id)
    send_body = _function_body(mp, 'net_send_to') or ''
    if 'net_lobby_member(' not in send_body or 'net_members' in send_body:
        problems.append('net_send_to: guard must be net_lobby_member(), not the net_members map')
    # N-5 flags: never NoDelay, never plain Reliable/Unreliable
    for p in list((root / 'scripts').rglob('*.gml')) + list((root / 'objects').rglob('*.gml')):
        if p.parent.name.endswith('_API') or p.parent.name == 'ExtensionCore_api':
            continue
        text = p.read_text(encoding='utf-8', errors='replace')
        if re.search(r'SteamNetworkingSendFlags\.(?:NoDelay|UnreliableNoDelay|Reliable|Unreliable|NoNagle)\b', text):
            problems.append(f'net_flags: {p.relative_to(root).as_posix()}: only ReliableNoNagle/UnreliableNoNagle | AutoRestartBrokenSession')
        # N-6 the mock seam is private to SAFE, the mock script and the transport self-check
        if p.parent.name not in ('scr_steam_safe', 'scr_net_mock', 'scr_online_transport_selfcheck') and 'tcc_steam_net_mock(' in text:
            problems.append(f'net_mock: {p.relative_to(root).as_posix()}: tcc_steam_net_mock() outside its allowed files')
    # N-7 buffers owned by the outbox are freed with the lobby and at exit
    for fn in ('net_reset_lobby_state', 'net_cleanup'):
        if 'net_outbox_clear(' not in (_function_body(mp, fn) or ''):
            problems.append(f'net_outbox: {fn} must call net_outbox_clear()')
    return problems
```

Add `problems += net_invariants(root)` inside `steam_invariants`. The gate `removed_wrapper` of the contract already covers `tcc_steam_net_packet_get_data/_get_sender_id/_get_size/net_set_auto_accept_p2p_sessions`.

### 10.7 Result of running the contract gate on this document's code

The tagged code blocks of this document (4 SAFE blocks, 11 project blocks: the net wrappers, the `M` functions, the outbox, the accept pass, the `L` and host_name edits, the mock and the transport self-check) were extracted into a throwaway scratch tree (deleted afterwards) and scanned with `scan()` of `SP/wc/check_port_steam.py` plus contract gate 6. Result: `raw_30_call` 0, `removed_wrapper` 0, `stale_constant` 0, `async_load_event_type` 0, `private_name_used_outside_safe` 0, `unknown_steam_token` 0, `closure_handed_to_steam` 0. Negative control: gate 2 does flag `variable_struct_exists(_r,"steam_id_remote")` (the pattern ignores string literals' quotes), which is why the code reads fields by dot access and uses `instanceof` for type checks (R9). The `net_invariants` function of 10.6 was executed on a synthetic tree built from the same blocks: 0 problems; with `NET_PROTOCOL 2` and the `net_outbox_pump()` call removed it reports exactly those two problems. The golden vectors of 4.2 were recomputed with a Python encoder from the layouts in the code; the STATE, HELLO and REQUEST strings of design A match byte for byte. What this does NOT prove: none of the GML in this document has been compiled or run by GameMaker; the Check self-check is the first compile.

### 10.8 One Steam account, one machine (feasible, no second client)

1. `steam_api_is_initialized()` true; the `[NET]` / `[STEAM]` diagnostics report `ids_int64` true and a 17-digit `string()`.
2. Register the callbacks; `steam_api_last_error()` is empty (read it immediately; every guarded native clears it).
3. `tcc_steam_net_packet_receive(<524288-byte fixed buffer>)` returns `undefined` with an empty last error: the native accepts the production buffer.
4. Create the lobby: pause line `HOSTING (1)`, `net_active`, member count 1; `net_send_to(own id)` returns false and the native is not called (R12).
5. Experiment, result unknown (tag UNV): send a 1-byte message to the own Steam id and poll the channel; log the EResult and whether it loops back. If it works it becomes a free single-account loopback for the exhaustion and offset mechanics; if not, nothing is lost. Optional low-priority variant (from design C): a dev-only SAFE probe built on `steam_networking_sockets_create_socket_pair(false)` (API:24122) to run one count=1 receive into a 524288-byte buffer; it exercises the shared `SteamNetworkingMessage` decode pipeline but NOT Messages, so it adds little and is not required.
6. Callback timing: log `current_time` at `steam_api_run_callbacks()` and at the first session-request callback body to confirm the next-tick dispatch (section 3).

### 10.9 Two accounts, two machines (release gate; nothing above replaces it)

SPEC 7.4 subset: #1 create/join/HELLO/names; #3 cold launch; #4 ghosts at 60 Hz, level change fade; #5 host leaves (BYE or fallback within 10 s, handoff); #6 host killed; #7 peer frozen > 10 s then recovers without leaving the lobby; #8 session closed from one side while the other keeps sending; #10 level share with a large file, network cut mid-transfer, back-pressure; #11 Endless picks; #13 `NET_VERSION_MISMATCH` against a 1.3.x build; #14 a third account that is not in the lobby sends to us: nothing processed, no session accepted; #16 `game_restart` with a party (R1); #17 hostile oversized message while another member sends a reliable message. New for this design:

* (a) first-message latency after join with the callback registered versus deliberately not registered (pure implicit accept; expect <= 2 s);
* (b) confirm in the log that `net_on_session_request` runs on the tick after the pump;
* (c) measure BYE loss with and without H3 (decides 8.6);
* (d) large-file transfer (> 1 MB) to a throttled link: read `tx_limit` per packet type from `net_log_transport`, confirm no lost HELLO/ER_PICKS (outbox) and that the transfer completes or is dropped after 60 s without progress;
* (e) held-or-dropped before accept: with the callback not registered, is anything sent before acceptance lost?

---------------------------------------------------------------------------------------------------

## 11. CONTRACT ADDITIONS

Each item names the part of `SP/wrapper-contract.md` it amends. Items CA-1 to CA-7 change the interface the SAFE implementer or the call-site agents see; CA-8 is tooling; CA-9 records a deliberate non-change.

**CA-1. Receive return domain, classifier, buffer rule (contract section 6 row `tcc_steam_net_packet_receive`, section 10.2 macros).**
* `tcc_steam_net_packet_receive(_buffer)` now returns one of: the `SteamNetworkingMessage` struct; `undefined` (nothing to read, Steam not ready, extension missing); `TCC_NET_RX_DROPPED` (-1: the native consumed and released a message that did not fit the buffer, "output buffer exhausted"). The only caller (`net_receive_packets`) counts `-1` against the 128 budget and `continue`s. Reading the last error uses the raw native `steam_api_last_error()` inside the wrapper, only after `tcc_steam_ready()` (or the mock) said yes, and only when the array is empty.
* New public pure function `tcc_steam_net_classify(_messages, _last_error)` (unit-tested outside SAFE); new macros `TCC_NET_RX_DROPPED` (-1) and `TCC_NET_CHANNEL` (0).
* Buffer rule replaced: the row says the receive buffer is a fixed 524288-byte buffer "on Steam builds (`platform_steam() ? ... : 1024`)". Now: unconditional `NET_RECV_BUFFER_BYTES` (524288) in `M`, so Check exercises the production allocation. The sentence "Loop `while (!is_undefined(_m = ...))` is not legal GML" stays valid.

**CA-2. Send diagnostics accessor (section 6 row `tcc_steam_net_packet_send`, section 10.2 `__tcc_steam_state`).**
* Signature and return of `tcc_steam_net_packet_send(_steam_id, _buffer, _size, _flags = undefined)` are UNCHANGED (bool, `true` only for `SteamApiResult.Ok`).
* New `tcc_steam_net_last_send_result()` returns the EResult number of the most recent send call (`SteamApiResult.None` = not attempted; `InvalidParam` = refused by the wrapper before the native; `Fail` = Steam down or `undefined` from the extension). New state field `net_last_send: 0` in `__tcc_steam_state()`. Callers must read it immediately after the send.

**CA-3. Check-only mock seam (new subsection 10.6, section 6 rows, lobby rows).**
* `tcc_steam_net_mock()` (public; allowed names outside SAFE only in `scr_net_mock` and `scr_online_transport_selfcheck`, gate N-6) returns `global.tcc_net_mock` only when `TCC_SELF_CHECK` is true, `undefined` otherwise (the macro is the literal `false` outside Check).
* First statement(s) of `tcc_steam_net_packet_send`, `_receive`, `_accept_session`, `_close_p2p_session`, `_set_session_request_callback`, `_set_session_failed_callback`: consult the mock before the readiness guard; of `tcc_steam_lobby_get_member_count`, `_get_member_id`, `_get_owner_id`: return the mock's answer. No other wrapper changes.
* `tcc_steam_ready()` (X6) is NOT routed through the mock (CA-9). Consequence: tests call individual `net_*` functions, never `net_tick`.

**CA-4. `SteamNetworkingMessagesSessionFailed` route (section 6 table, 10.4 `__tcc_steam_native_register/_unregister`, 10.5 relay, decoder audit).**
* New wrapper `tcc_steam_net_set_session_failed_callback(_cb)`: `platform_steam()` only; sets listener `net_session_failed`, registers natively.
* `__tcc_steam_native_register("net_session_failed")` -> `steam_networking_messages_set_callback_session_failed(tcc_steam_relay)`. `__tcc_steam_native_unregister`: split the single `"net_session_request"` case (which cleared both slots) into one case per slot.
* `tcc_steam_relay`: `case "SteamNetworkingMessagesSessionFailed": __tcc_steam_deliver(_s.listeners[$ "net_session_failed"], [_r]); break;`
* The "16 routed types" decoder audit becomes 17; `__SteamNetworkingMessagesSessionFailed_decode` exists (API:11847) and is in the decoder array (API:24744), and builds the struct with `new SteamNetworkingMessagesSessionFailed()`.
* Diagnostics only. Dropping the feature later = deleting these items and `net_on_session_failed`.

**CA-5. `tcc_steam_net_clear_session_callbacks()` is UNUSED (section 6 row, section 17.2 row for it, work package "net").** Keep the definition, never call it; remove `objects/o_networkmanager/CleanUp_0.gml` from the net work package (no edit). Reason: in the restart case where the dispatcher statics reset while the native handle survives, clear + re-register can delete the freshly registered entry; the extension's own `final` already clears the native slots.

**CA-6. Call-site rows (sections 17.1, 17.2, 17.4).**
* `tcc_steam_net_set_session_request_callback`: registration site is `net_register_steam_callbacks()` (called from `objects/o_networkmanager/Create_0.gml` after `net_init()`), NOT `scr_online_multiplayer.gml:532-536` (that one-shot is deleted together with `global.net_p2p_accept`). `tcc_steam_net_accept_session`: `net_accept_pending_sessions()`. `tcc_steam_net_close_p2p_session`: unchanged callers (M:389, 820).
* New rows: `tcc_steam_net_set_session_failed_callback` (`net_register_steam_callbacks`), `tcc_steam_net_last_send_result` (`net_send_to`, `net_outbox_pump`), `tcc_steam_net_classify` (self-check), `tcc_steam_net_mock` (SAFE, `scr_net_mock`, `scr_online_transport_selfcheck`).
* Work package "net" files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml` (as listed + outbox, accept pass, host_name cache, logs), `scripts/scr_online_levelshare/scr_online_levelshare.gml` (stall timeout), `scripts/scr_online_friends/scr_online_friends.gml:124` and `objects/o_pausescreen/Draw_73.gml:26` (read `global.net_host_name`), `scripts/scr_port_selfcheck/scr_port_selfcheck.gml:108`, two NEW scripts with `.yy` and `.yyp` entries; `o_networkmanager/Create_0.gml` stays in the lobby package.

**CA-7. SAFE self-check S-2 additions (section 15).** Inside `tcc_steam_selfcheck()`: (a) a `SteamNetworkingMessagesSessionRequest` built with `new` and delivered through `with ({}) method_call(tcc_steam_relay, [_r])` reaches the `net_session_request` listener twice (not consumed); (b) a `SteamNetworkingMessagesSessionFailed` reaches `net_session_failed`; (c) both are delivered with `self` = a struct, so a listener that relied on instance variables would fail. S-7 (manual) additionally: after a two-account session `__tcc_steam_state().unrouted == 0 && relay_errors == 0` also proves the codec alignment of these two types.

**CA-8. `tools/check_port.py` (section 14).** Add `net_invariants(root)` (10.6) to `steam_invariants`: protocol 3, fixed 524288 receive buffer, exactly one native send and one native receive in SAFE with the game channel and count 1, `net_tick` call order, `net_send_to` guarded by `net_lobby_member` and not by the `net_members` map, no `NoDelay`/plain `Reliable`/`Unreliable` flags, the mock seam confined to its files, outbox buffers freed with the lobby and at exit. No allow-list change: the implementer rule (R9) for every non-SAFE file is "no `steam_`-prefixed word in a code line, comment or string; read struct fields by dot access".

**CA-9 (deliberate non-addition).** `tcc_steam_ready()` stays the single definition of X6 and is not routed through any mock. `tcc_steam_net_clear_session_callbacks` is not called. `LEVEL_ACK`, extra channels, quarantine/strike logic and STATE back-off (design B) are not added.

---------------------------------------------------------------------------------------------------

## 12. What is NOT verifiable without Steam (and how each is settled)

| # | Unverified | Why it matters | How to settle |
|---|---|---|---|
| U1 | `game_restart()` versus the extension `final` (`steam_api_shutdown`), the `call_once` init hook and EXT's function-map statics | If Steam is shut down on restart the lobby, all callbacks and the party are gone after the ending; if only the dispatcher resets, a stale handle desyncs that frame's callback batch ("BAD PACKET", EXT:333-338) | Runtime test 10.9 #16: read `[NET] restart:` / `[NET] first tick:`, then a second account sends first. Core decides the fix (blank `final` locally, or re-init) |
| U2 | `buffer_read(buffer_u64)` returns `int64`, not a double (ids ~7.6e16 > 2^53) | `string(id)` keys, `==` across lobby/message/own ids, `set_played_with` silently break | One-time `[NET] WARNING` log (7.5), the contract's registration diagnostic, T-I1 on fixtures; a coordinated fix across domains if it fails |
| U3 | Runtime `RecvMaxMessageSize` for SDK 1.65 (the local header is 1.61 text; 3.0 sets no config) | The "a fetched message always fits in 524288" argument | The classifier (CA-1) turns a violation into a counted, skipped message instead of a lost tick; `rx_dropped` is logged |
| U4 | Whether Steam holds or drops messages sent before the receiver accepts | First HELLO/PING burst after a join | Two-account latency test 10.9 (a)/(e); fallbacks: implicit accept by our own sends, the 2 s ping, re-sent HELLO reply logic |
| U5 | Whether `CloseSessionWithUser` flushes a just-sent reliable BYE | "Player left" notice only | 10.9 (c); contingency H3 (8.6); other detection paths exist |
| U6 | That the SDK copies the payload during `SendMessageToUser` (implied, not stated in the Messages header) | Immediate reuse of `net_send_buffer` between sends | Rapid HELLO/PING/PONG sequence in the two-account test: every packet type must decode |
| U7 | `platform_steam()` is false in Check (inheritance of `Apple:TCC_STEAM false` by the child configuration) and the API enums/constructors compile and run in Check/iOS/Android/MAS without the extension | The whole Steam-free test plan, and iOS/Android startup | The first Check run: the first assertion of the transport self-check and contract S-1; fallback literals in 10.5 |
| U8 | Typed-struct delivery to the relay for the two net result types (codec-id/decoder-index alignment, never sent untyped) | If untyped, `instanceof` is `"struct"` and the relay logs `unrouted` | Contract S-7 acceptance `unrouted == 0`; fallback: one named relay function per kind |
| U9 | Callback timing: next time-source tick after `steam_api_run_callbacks()` (code) versus "inside the call" (docs) | Callback bodies are written for the worst case (dummy `self`, outside `net_tick`), so correctness does not depend on it | 10.8 #6 log |
| U10 | `LimitExceeded` behaviour under a real throttled link: actual Steam send rate, whether the 512 KB cap applies to unreliable messages too, how long control packets wait behind chunks | Sizes the exposure behind the outbox and H1 | 10.9 (d): `tx_limit` per packet type, completion or stall drop |
| U11 | Legacy P2P (1.3.x) and Messages cannot interoperate | Mixed lobbies | Assumed; `NET_PROTOCOL` 3 turns the question moot (`NET_VERSION_MISMATCH`) |
| U12 | First-contact latency: no `InitRelayNetworkAccess` is exposed by the 3.0 extension (not found in `API` or `Steamworks.yy`) | Join feels slower than legacy | 10.9 (a) |
| U13 | Whether `receive_messages_on_channel` itself needs `steam_api_run_callbacks()` | If yes, nothing is received while the pump owner is absent (ending) | Observe `rx` while `o_fullscreensystem` is absent; pre-existing gap otherwise |
| U14 | A self-send loopback (10.8 #5) | A free single-account test, if it works | Experiment only |
| U15 | Pump owner `o_fullscreensystem` is destroyed by `o_endingreq/Create_0.gml:3` and recreated by `o_loading/Create_0.gml:13`: no callback is delivered meanwhile | Session requests, lobby events | Pre-existing in 2.x; our own pings cover session requests; core decides about the pump |
| U16 | GML semantics not relied upon: array alias copy-on-write (all mutations go through `global.*`), `bool(undefined)` (comparisons with `== true` instead), `id` as a struct member name (renamed `user`) | Silent behaviour differences | Avoided by construction; compile and run the Check self-check |

Corrections to the input documents, made explicit: SPEC 1.6/INV-A12 (Check has `platform_steam()` false); SPEC G15/INV-A11 and the 3.0 docs (callbacks are not run inside `steam_api_run_callbacks()`); `docs/networking.js` `@returns` of `send_message_to_user` ("number of messages") is a copy-paste error, the value is an EResult; MNET's `net_tick` one-shot registration (replaced by the single `net_register_steam_callbacks()` site); SPEC INV-A6 "live membership" (cache plus one forced refresh per tick for fresh requesters); design A's `net_members` send guard and the `int64(76561198000000001)` fixture literal (a numeric literal is already a rounded double; fixtures use `int64("...")`).

---------------------------------------------------------------------------------------------------

## 13. Risks, ranked

| # | Risk | Mitigation / test |
|---|---|---|
| R1 | `game_restart()` vs `final` / dispatcher statics (U1) | log lines (7.5), runtime test, core decision; the net layer re-registers at every manager Create and keeps the 2 s ping fallback |
| R2 | Ids may not be int64 (U2) | one-time warning, T-I1, no `real()` in the transport |
| R3 | Receive-bound assumption (U3) | classifier + fixed 524288 buffer + per-message cap in GML |
| R4 | Held or dropped before accept (U4) | implicit accept by our sends; callback only an optimisation |
| R5 | BYE / close race (U5) | best effort as in 2.x; H3 ready |
| R6 | Mixed-version lobbies | `NET_PROTOCOL` 3 gates the join; do not ship without it |
| R7 | Callback bodies run asynchronously with a dummy `self` | push-only bodies; relay `try/catch`; T-A1 runs them through a dummy-`self` pump |
| R8 | Send semantic traps (omitted count sends the whole allocated buffer; EResult is not a bool) | wrapper always passes offset 0 and count; strict `== Ok`; T-S1/T-S3; gate N-2 |
| R9 | Level-share throughput versus control-message latency (U10) | outbox for small reliable packets; H1 stall timeout; counters per packet type; LEVEL_ACK deferred |
| R10 | New code in the send path (outbox) | only entered on `LimitExceeded`; bounded (16 entries, 30 s); T-O1..T-O3; chunks and BYE excluded |
| R11 | Check-configuration assumptions (U7) | first Check run; literal fallbacks |
| R12 | Forced refresh in the accept pass uses the tick's refresh budget | one per tick, fresh requesters only, shared with the receive loop; T-A2, T-R4 |

---------------------------------------------------------------------------------------------------

## 14. Order of work (each step independently reviewable and revertible)

1. SAFE: the wrappers of section 5 plus the contract edits CA-1..CA-5 (signatures change, so land them with their only caller in the same change set).
2. `M`: state (7.2), `net_send_to` + outbox (7.3), receive loop (7.4), accept pass + registration (6.2), `net_tick` (7.6), `NET_PROTOCOL` 3, host_name cache (8.5), logs (7.5). `L`: stall timeout (8.4). `F:124`, `PS:26`.
3. `scr_net_mock` + `scr_online_transport_selfcheck` + wiring (8.3) + `net_invariants` (10.6); run the Check self-check BEFORE any Steam run. The first Check run also settles U7.
4. One-account Steam smoke (10.8), then the two-account acceptance (10.9). H3 only if 10.9 (c) shows lost BYEs.

---------------------------------------------------------------------------------------------------

## 15. Traceability: judge grafts

| Required graft | Where |
|---|---|
| callback bodies push-only, exceptions isolated (B 7.3) | relay `__tcc_steam_deliver` `try/catch` (contract 10.3) + push-only bodies (6.2); T-A1, contract S-3 |
| exhaustion classifier in the receive wrapper, gated by readiness, unit-tested (B 5.2) | 5.2 `tcc_steam_net_classify`, CA-1, T-C1, T-R1 second pass |
| `host_name` cache, required (B 11.4) | 8.5 |
| level-share back-pressure baseline | outbox 7.3 + H1 8.4; LEVEL_ACK / new packet deferred; counters; 1.2 explains the sizing |
| re-register on Steam down/up, restart diagnostic log (B 7.2/7.6) | contract ready edge (R3) + `[NET] restart` / `first tick` log (7.5) |
| static classification gate and mock quirks (B 12.1a/12.2) | declined as a gate (R10); mock quirks implemented: deferred callbacks via `pump()`, per-peer queue model giving 25 organically, `NoConnection` without flag 32, re-posted requests, drop/hold policy; time through `_now` parameters |
| H3 cancel rule and no close at exit (B 8.3/8.5) | 8.6 |
| `_inst` leak in `__SteamNetworkingMessage_decode` (C) | section 3, 8.1 |
| no NoDelay / plain flags, no flush in Messages (C) | 4.2, gate N-5 |
| pump-owner destruction note (C 4.5) | 9.3, U15 |
| forced refresh once per tick shared with the receive loop (judge 2) | 6.2, T-A2, T-R4 |
| one-time production int64 log (judge 2) | 7.5 `net_check_ids` |
| optional single-account native probe (C 12.3) | 10.8 #5, optional |
| not taken: three channels, quarantine/strikes, idle drain, STATE back-off, LEVEL_ACK baseline, star relay | CA-9 |
