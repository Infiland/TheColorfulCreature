# The Colorful Creature: online multiplayer, authoritative netcode specification

Subject: the behaviour of the online layer (protocol 2) as it exists on branch `feat/steamworks-3-0` before any port work, written so that a rewrite onto Steamworks 3.0.0 (SDK 1.65 line) can be checked against it. Nothing under the project was edited to produce this document.

This file supersedes the three readings in the same folder (`netcode-read-transport.md`, `netcode-read-session.md`, `netcode-read-consumers.md`). Where it disagrees with them, section 8 says why. Where the readings could not know something (the real 2.x native code, the Steam SDK headers), those sources were opened and are cited here.

---------------------------------------------------------------------------------------------------

## Reading guide and evidence tags

Every non-trivial statement carries one tag so a reader can tell fact from inference.

| Tag | Meaning | Where it lives |
|---|---|---|
| `[R]` | Project working tree, cited `file:line` | `...` |
| `[N2]` | The **2.1.6 native C++** that the game ran on, read from git HEAD (`git show HEAD:extensions/Steamworks/steamworks_cpp/GMLSteam/<file>`; copies in `scratchpad/port/old2x_head/`) | `steam_networking.cpp`, `steam_matchmaking.cpp`, `steam_misc.cpp`, `gml_glue.h`, `steam_lobby_chat.cpp`, `steam_user.cpp`, `steam_glue.cpp` |
| `[N3]` | The **3.0.0 native C++** | `scratchpad/gmext/src/source/Steamworks_gml/extensions/steamworks/source/src/` (`gm_steam_networking_messages.cpp`, `gm_steam_matchmaking.cpp`, `steam_async_common.h`) |
| `[SDK]` | Steam SDK headers on this machine | `/Users/infi/Documents/sdk/public/steam/` (`isteamnetworking.h`, `isteamnetworkingmessages.h`, `steamnetworkingtypes.h`, `isteamnetworkingsockets.h`, `isteammatchmaking.h`). The tree states no version number; the header declares interface `SteamNetworkingMessages002` and the Readme says 1996-2024. That it is the SDK 1.65 line is **not proven**. |
| `[API]` | The 3.0 GML API file `scripts/Steamworks_API/Steamworks_API.gml` | cited by line; the last line (~24773) is enormous and must never be printed |
| `[DOC3]` | 3.0 docs sources | `scratchpad/gmext/src/docs/*.js` |
| `[GM]` | GameMaker runtime behaviour that cannot be checked from files in this repo | needs a test on a real build |
| `[UNV]` | Not verified anywhere on disk | listed again in section 9 |

File abbreviations (all under the project root unless stated):

| Abbrev | File |
|---|---|
| `M` | `scripts/scr_online_multiplayer/scr_online_multiplayer.gml` (1264 lines) |
| `S` | `scripts/scr_online_session/scr_online_session.gml` (1089 lines) |
| `F` | `scripts/scr_online_friends/scr_online_friends.gml` (334 lines) |
| `L` | `scripts/scr_online_levelshare/scr_online_levelshare.gml` (271 lines) |
| `W` | `scripts/scr_steam_safe/scr_steam_safe.gml` (the `tcc_steam_*` wrappers) |
| `PS` | `objects/o_pausescreen/Draw_73.gml` |
| `NM` | `objects/o_networkmanager/` |
| `FS` | `objects/o_fullscreensystem/` |

---------------------------------------------------------------------------------------------------

## 0. Summary and the seven most likely breakages

**What the system is.** Every player with Online Multiplayer enabled owns a friends-only Steam lobby (created at capacity 250) for as long as the game runs. The lobby is only the membership and rendezvous layer plus a small key/value store (game name, protocol, host name, a JSON "session descriptor"). All gameplay traffic is a full-mesh peer-to-peer exchange over the legacy `ISteamNetworking` P2P API, exposed to GML as `steam_net_packet_*`: ghost state at up to 60 Hz, keepalive/location pings every 2 s, identity, leave, shared Endless Run picks and file transfer of custom levels. The lobby owner is the "host": it publishes what it is playing; others "follow" it. There is no ready check and no start button (3.10).

**What changes in the port.** The extension is a full rewrite. `steam_net_packet_*` has **zero** matches in `Steamworks_API.gml` (`grep -c steam_net_packet` returns 0 [R]). Lobby calls take explicit lobby ids and callbacks instead of an implicit current lobby and an Async event. The online layer's wrappers (`tcc_steam_*`) isolate most call sites, but the *semantics* the callers depend on are broader than the call signatures (section 5).

**The seven things most likely to break** (each is expanded in section 5 and turned into a testable requirement in section 6):

1. **Session establishment.** 2.x accepted P2P sessions automatically, but only for users in its live current lobby ([N2] `steam_networking.cpp:23-40`), reopened broken sessions silently ([SDK] `isteamnetworking.h:319-322`) and never delayed sends (no Nagle). 3.0 Networking Messages needs a session-request callback that accepts members, `AutoRestartBrokenSession` on every send, and `*NoNagle` flags, otherwise peers can go permanently invisible to each other and 60 Hz state gets coalesced (G1-G5).
2. **Receive buffering.** 2.x delivered one packet at a time, always at buffer offset 0, growing the buffer ([N2] `steam_networking.cpp:177-193`). 3.0 returns a batch packed back-to-back from offset 0 of a buffer that is **never grown**, and **releases (drops) every remaining fetched message** once the buffer is exhausted ([N3] `gm_steam_networking_messages.cpp:195-199`). The existing 1024-byte `net_recv_buffer` would drop every level chunk, and one oversized message could erase other peers' reliable messages (G8, INV-A1/A2).
3. **Send result.** 2.x returned a boolean. 3.0 returns an `EResult` number (OK = 1; every failure is also non-zero, i.e. truthy) and `undefined` when Steam is unavailable ([N3] `gm_steam_networking_messages.cpp:116-157`, [API] 23674). `if (!net_send_to(...)) break;` in level share (`L:177`) would never fire and the transfer stream would silently skip chunks (G10).
4. **Create/join replies.** 2.x always produced exactly one reply per create/join, including on IO failure ([N2] `steam_matchmaking.cpp:407-413, 484-491`). 3.0 does **not** call the callback on IO failure or dispatch failure ([N3] `steam_async_common.h` default `ReportIoFailure=false`; `gm_steam_matchmaking.cpp:181-215`), and the create/join functions return nothing usable. The code's pending flags ("clear only on their reply", `M:286`) would hang forever and auto-hosting would stop (G12).
5. **Implicit current lobby.** 2.x kept one `steam_lobby_current` ([N2] `steam_glue.cpp:7`) that create/list-join also *left* before acting (`steam_matchmaking.cpp:420, 499`). 3.0 needs `global.net_lobby_id` passed to every call; passing `-1` is a bug (G13, INV-A9).
6. **Callback timing and re-entrancy.** 2.x queued events and ran handlers in the Async-Steam event stage after Step ([N2] `gml_glue.h:24-26`). 3.0 runs callbacks synchronously inside `steam_api_run_callbacks()`, possibly in the middle of whatever code calls it, and the callback must not be bound to a destroyable instance (G15, INV-A11).
7. **Steam-free half and non-Steam builds.** `net_init`, `net_session_update`, launch-argument parsing, banners and the pause line run on every build including iOS/Android/Mac App Store/QA where no Steam binary exists. Nothing that runs there may call a 3.0 function (section 1.6, INV-A12).

---------------------------------------------------------------------------------------------------

## 1. Components and public API surface

### 1.1 Layers

```
 gameplay hooks   randomlevel, o_player door code, credits/boss unlocks, editor play-test
        |
 S  scr_online_session     own session id (sid), descriptor publish, follow/enter state machine,
        |                   Workshop fetch for follows, Endless Run pick sharing
 L  scr_online_levelshare  peer-to-peer transfer of local level.json (editor play-tests, custom challenges)
 F  scr_online_friends     friends list, friend rich-presence text, avatars, Friends panel UI
        |
 M  scr_online_multiplayer lobby lifecycle, membership, P2P send/receive, peer table, ghosts, wire format,
        |                   Steam async dispatcher (net_handle_async_steam), rich-presence group
 W  scr_steam_safe         tcc_steam_* wrappers:  if (platform_steam() && steam_initialised()) return steam_X(..); return <default>;
        |
 Steamworks extension      2.1.6 (legacy)  ->  3.0.0
```

Drivers:

| Object | Role | Evidence |
|---|---|---|
| `NM` `o_networkmanager` | Persistent. Created once by `net_ensure_manager()` (`M:311-314`) from `o_loading/Create_0.gml:14`, `o_title/Create_0.gml:118` and `net_request_join` (`M:409`). `Create_0` calls `net_init()` (`Create_0.gml:6`). `Step_0`: line 1 `if (!timing_instance_step()) exit;`, then `net_session_update(); net_tick();` (lines 11-12), then notice timers (14-17). `Other_69`: `net_handle_async_steam(async_load)` (line 3). `Draw_0`: ghosts. `Draw_64`: HUD. `CleanUp_0`: skips `net_cleanup()` when `global.net_restarting` (lines 2-5). | [R] |
| `FS` `o_fullscreensystem` | Persistent. `Step_0.gml:4` `if (platform_steam()) tcc_steam_update();` (after its own `timing_instance_step()` guard, line 1) is the **event pump**. `Other_69.gml:1-6` is a fallback that routes only `lobby_created` / `lobby_joined` to `net_handle_async_steam` when `o_networkmanager` does not exist, so a reply that outlives a destroyed manager is still settled (and the stray lobby left). | [R] |
| `o_friendsbutton`, `o_friendspanel` | Main-menu button (label "Friends (N)" refreshed every 120 ticks) and the modal panel (list refreshed every 90 ticks while open). `o_friendsbutton/Create_0.gml:3` destroys itself under `TCC_GAMEPLAY_QA \|\| TCC_STEAM_ANDROID \|\| !platform_steam()`. | [R] consumer audit |
| `PS` `o_pausescreen/Draw_73.gml:17-33` | Online status line in the pause menu (3.13). | [R] |

Timing model. `TCC_SIM_HZ = 60` (`scripts/scr_timing/scr_timing.gml:4`). `timing_instance_step()` returns `timing_is_tick()` (`scr_timing.gml:493-511`), set once per engine frame as `accumulator_us + 0.0001 >= tick_us` and then one tick consumed (`scr_timing.gml:565-568`). So render-only frames never run `net_tick`, at most one simulation tick runs per engine frame, and every "per tick" number below is per 1/60 s of simulation time, independent of render FPS (if the engine runs below 60 FPS, ticks per second fall proportionally). `timing_tick_id()` (`scr_timing.gml:47`) is the tick counter used by every tick-based timer.

### 1.2 Public API surface (functions other code calls)

All are plain global functions (no `online_*` API exists; the family is `net_*`).

| Function | Defined | Called from | Notes |
|---|---|---|---|
| `net_init()` | `M:255` | `scr_loading.gml:407`; `NM/Create_0.gml:6`; `net_ensure_manager` | Idempotent: returns at once if `net_ready` (`M:258`). Allocates 3 ds_maps (+`net_avatars`), 2 buffers, calls `net_session_init`, `net_levelshare_init`. **No Steam call.** |
| `net_ensure_manager()` | `M:311` | `o_loading/Create_0.gml:14`, `o_title/Create_0.gml:118`, `M:409` | |
| `net_cleanup()` | `M:330` | `NM/CleanUp_0.gml:7` | Game end only: `net_leave_lobby(false)`, free everything. |
| `net_game_restart()` | `M:323` | `o_endingreq/Alarm_0.gml:2`, `o_endingslides/Alarm_0.gml:28`, `scr_timing_ui.gml:311` | Sets `global.net_restarting`, `game_restart()`. Lobby, maps, buffers, sessions survive. |
| `net_enabled()` | `M:316` | many | `onlinemultiplayersettings == 1 && platform_steam() && tcc_steam_initialised() && !TCC_GAMEPLAY_QA`. |
| `net_session_update()` | `S:152` | `NM/Step_0.gml:11` | Runs every tick **even offline**, gated only on `net_ready`. |
| `net_tick()` | `M:528` | `NM/Step_0.gml:12` | Returns at `M:529-530` unless `net_ready && platform_steam() && tcc_steam_initialised()`. |
| `net_handle_async_steam(map)` | `M:1017` | `NM/Other_69.gml:3`; `FS/Other_69.gml:6` | The only consumer of Steam async events in the online layer. |
| `net_draw_ghosts()` | `M:906` | `NM/Draw_0.gml:3` | |
| `net_member_count()`, `net_get_ghost_count()`, `net_follow_can_enter()`, `net_session_text(desc)`, `net_field(s,k,d)`, `net_clean_name(s)` | `M:523`, `M:848`, `S:504`, `S:1067`, `S:76`, `M:121` | `NM/Draw_64.gml:19-56`; `PS:24,26` | Pure (no Steam). |
| `net_friends_list()` | `F:8` | `o_friendsbutton/Step_0.gml:7`; `o_friendspanel/Create_0.gml:26`, `Step_0.gml:9` | Needs Steam. |
| `net_friends_panel_layout/hover/action/draw` | `F:128/178/187/...` | `o_friendspanel` events | Layout recomputed every Step. |
| `net_request_join(lobby_id)` | `M:405` | `F:205` (panel Join), `M:1132` (overlay Join Game / invite), `M:545` (cold launch) | Returns false unless Steam is up; turns Online Multiplayer on and saves settings if it was off (`M:410-414`). |
| `net_leave_lobby(announce)` | `M:375` | `F:202`, `M:397`, `M:549`, `M:332` | |
| `net_follow_now()` | `S:479` | `F:199`; `M:417` | |
| `net_session_host_desc()` | `S:409` | `F:145`; internal follow logic (`S:447,481,526`) | One `lobby_get_data("session")` per call, JSON-cached. |
| Gameplay hooks | see below | | |

Gameplay hooks (call into the online layer on **every** platform; all are inert offline):

| Hook | Call sites |
|---|---|
| `net_er_resolve_room`, `net_er_difficulty_reward_allowed` | `scripts/randomlevel/randomlevel.gml:68, 82` |
| `net_er_resolve_workshop`, `net_er_goto_workshop`, `net_er_record_workshop` | `scripts/scr_workshopER/scr_workshopER.gml:101, 103, 120` |
| `net_follow_entered_this_tick`, `net_door_override` | `objects/o_player/Step_0.gml:710, 719` |
| `net_editor_playmode(true/false)` | `scripts/PLAYMODELE/PLAYMODELE.gml:12, 37` |
| `net_campaign_reward_allowed` | `scr_credits_entry.gml:18`; `o_hammer/Alarm_0.gml:59`; `o_evilhotdog/Collision_o_bulletright.gml:19`; `o_pianoboss/Step_0.gml:9,15`; `rooms/r_theend/InstanceCreationCode_inst_23879049.gml:26`, `..._inst_4CB540F2.gml:1` |
| `net_game_restart` | see above |

(The set of files outside `scr_online_*` that touch `global.net_*` or these functions was re-verified by grep: `o_evilhotdog`, `o_hammer`, `o_networkmanager`, `o_pausescreen`, `o_pianoboss`, `o_player`, `r_theend` creation code x2, `randomlevel`, `scr_credits_entry`, `scr_loading`, `scr_timing_gameplay`, `scr_workshopER`.)

### 1.3 Global state (all created by `net_init` / `net_session_init` unless noted)

Lobby / identity layer:

| Variable | Init | Meaning |
|---|---|---|
| `net_ready` | true after init | module initialised (`M:259`) |
| `net_active` | false | we are in a **validated** lobby, own or someone else's |
| `net_lobby_id` | `-1` | id of that lobby, taken from the create/join **reply** (`M:1035`, `M:1074`). **The only record of the current lobby id.** `-1` = none. |
| `net_is_host`, `net_owner_id` (`int64(0)`), `net_my_steam_id` (`int64(0)`) | | owner flag; owner id re-read from Steam every 30 ticks (`M:576-587`); own id |
| `net_join_time` | 0 | `current_time` at create/join; written into HELLO |
| `net_follow_host` | false | this player joined someone else, so follows that owner's sessions |
| `net_host_retry_at` | 0 | `current_time` before which auto-create is not retried (15 s after immediate failure `M:439`, 30 s after failed reply `M:1045`) |
| `net_lobby_joinable` | -1 | cache of the last `set_joinable` value (-1 unknown) |
| `net_lobby_data` | ds_map | write-through cache of lobby values **we wrote** (`M:467-473`) |
| `net_members` (ds_map `string(id)->id`, incl. self), `net_member_list` (array, **excludes self**), `net_players` (ds_map `string(id)->peer struct`) | | membership and per-peer state; keyed by `string(steam_id)` |
| `net_p2p_accept` | false | one-shot "auto-accept switched on" flag (`M:532-536`), never reset |
| `net_refresh_tick`, `net_refresh_forced_tick` | 0, -1 | member refresh scheduler; one forced refresh per tick for unknown senders (`M:700`) |
| `net_send_buffer`, `net_recv_buffer` | `buffer_create(1024, buffer_grow, 1)` (`M:302-303`) | the **single** shared outgoing and incoming buffers |
| `net_send_timer`, `net_send_seq` (16-bit wrapping), `net_send_signature`, `net_send_idle` | 0, 0, "", 0 | STATE throttling |
| `net_ping_at` | 0 | `current_time` deadline of the next PING |
| `net_last_skin` | 0 | skin used while dead |
| `net_presence_group` | "" | last rich-presence group string |

Pending-operation machine (comment `M:286`: "Native create/join calls outlive rooms. Clear only on their reply."):

| Variable | Init | Meaning |
|---|---|---|
| `net_create_pending` | false | a `lobby_create` is in flight |
| `net_host_intent` | false | we asked to create; the reply is honoured only if still true |
| `net_pending_join` | -1 | queued lobby id waiting to be joined |
| `net_join_pending_id` | -1 | lobby id of an in-flight `lobby_join_id` |
| `net_join_defer_tick` | -1 | a join/create must wait one tick after leaving (`M:368, 399`) |
| `net_join_announced` | false | assigned at `M:292, 424`; **no reader exists** |

UI feedback: `net_connect_state` (0 idle, 2 joining, 3 success, 4 failure; **1 "creating" is never assigned**), `net_connect_timer`, `net_connect_flash`, `net_connect_msg`, `net_notices` (max 4 entries, 300 ticks each). Decay in `scripts/scr_timing_gameplay/scr_timing_gameplay.gml:254-259`.

Session layer (`S`): `net_session_sid` ("" before gameplay), `net_session_in_menu`, `net_session_adopt`, `net_sid_counter`, `net_level_key`, `net_shared_md5`, `net_editor_md5`, `net_challenge_md5`, `net_challenge_share_path`, `net_room_followed`, `net_er_keep_sid`, `net_cer_own`, `net_er_picks` (ds_map), `net_er_index`, `net_ugc_subscribed`, `net_ugc_failed`.
Follow layer: `net_host_desc`, `net_host_desc_json`, `net_host_sid_seen` (sentinel `"*"` right after joining, `S:427`), `net_follow_poll_tick`, `net_follow_quiet_until`, `net_follow_waiting_notice`, `net_follow_pending_sid/own`, `net_follow_job` (`{sid, desc, state:"countdown"/"wait", timer, deadline, own_sid}`), `net_follow_entered_tick`, `net_published_json`, `net_publish_tick`.
Level share (`L`): `net_share_texts`, `net_share_order`, `net_share_out`, `net_share_in`, `net_share_denied`.
Outside `net_init`: `net_launch_lobby` (set once per process by `scr_loading.gml:409-421`), `net_restarting`.

Per-peer struct (`net_players[string(id)]`, built at `M:788-803`): `steam_id, username, x, y, prev_x, prev_y, target_x, target_y, sprite_index, image_index, image_blend, image_xscale, image_yscale, image_angle, image_alpha, color, room_name, level_key, sid, skin, hat, item, hsp, vsp, is_dead, zerogrv, seq (-1), recv_tick (-1), predict (0), snap (true), rtt (-1), join_time (local first-seen clock), last_update, announced (false), ghost_alpha (0)`.

### 1.4 Constants

| Constant | Value | Where |
|---|---|---|
| `NET_PROTOCOL` | 2 | `M:14` |
| `NET_GAME_NAME` | `"TheColorfulCreature"` | `M:15` |
| `NET_MAX_LOBBY` | 250 | `M:16` |
| `NET_PACKET_STATE/HELLO/BYE/PING/PONG/ER_PICKS/LEVEL_REQUEST/LEVEL_CHUNK/LEVEL_DENY` | 16,17,18,19,20,21,22,23,24 | `M:20-28` |
| `NET_PACKET_MAX_SIZE` | 1024 | `M:30` |
| `NET_CHUNK_DATA_SIZE` / `NET_CHUNK_MAX_SIZE` | 8192 / 8448 | `M:31-32` |
| `NET_STATE_HEADER` | 33 | `M:33` |
| `NET_PEER_TIMEOUT_MS` / `NET_PING_INTERVAL_MS` / `NET_REFRESH_TICKS` | 10000 / 2000 / 30 | `M:34-36` |
| `NET_SHARE_HEADER` / `NET_SHARE_MAX_TEXT` / `NET_SHARE_TIMEOUT_MS` / `NET_SHARE_CHUNKS_PER_TICK` / `NET_SHARE_ACTIVE` | 44 / 16777216 / 30000 / 16 / 8 | `L:12-16` |
| `NET_ROOM_MENU/PLAY/TRANSIT/EDITOR/LOCAL` | 0..4 | `S:13-17` |
| `NET_FOLLOW_COUNTDOWN` / `NET_FOLLOW_TIMEOUT_MS` | 180 ticks / 90000 | `S:19-20` |
| hard-coded in the receive loop | 128 packets per tick | `M:693` (not a macro) |

Protocol 1 used packet ids 1-7; ids 16-24 were chosen so protocol-1 clients ignore protocol-2 packets and vice versa (`M:18-19`).

Settings: `global.onlinemultiplayersettings` (default `platform_steam()`, ini `Settings/Online Multiplayer`, forced 0 off Steam at `scr_loadsettings.gml:65, 236`); `global.netmaxplayers` (default 8, UI slider 2..256, loaded range 2..256, enforced clamp 2..`NET_MAX_LOBBY`=250 at `M:495`; hidden on mobile).

### 1.5 Where Steam is involved (summary; full table in section 4)

Lobby create/join/leave/data/members/owner/joinable, the P2P packet API, friends/rich presence/avatars/overlay, UGC subscribe/poll for follows, and six async events. All behind `tcc_steam_*` wrappers except six raw identifiers (4.C). `S` contains **no** raw `steam_*` call (grep re-verified: the only raw Steam symbols in the four online scripts are `steam_lobby_type_friends_only` `M:437`, `steam_net_packet_type_reliable/unreliable` `M:607`, `steam_user_avatar_size_medium` `F:71`, `ov_friends` `F:196`, `ugc_result_success` `M:1142`).

### 1.6 What runs where: Steam-free vs Steam-dependent, and build configurations

Runs on **every** build (no Steam dependency; must stay so):
`net_init` (`scr_loading.gml:407`); `+connect_lobby` argv parsing (`scr_loading.gml:409-421`, once per process, guarded by `variable_global_exists`); `net_ensure_manager`; `NM/Step_0` calling `net_session_update` (room class, sid minting, level key, editor hash) and then `net_tick` (which returns at `M:530`); `NM/Draw_0` and `Draw_64`; banner timers; the hooks in 1.2; `net_game_restart`; settings plumbing; `scr_online_cosmetics_selfcheck` (pure buffer round trips, no Steam).

Needs a live Steam client: everything in `net_tick` after `M:530`, all lobby/P2P/avatar/friends/overlay/UGC calls, `net_presence_update`, the panel actions, `set_rich_presence()` (`scr_rich_presence.gml:8`).

| Config | `platform_steam()` | `net_enabled()` | Note |
|---|---|---|---|
| Steam release (mac/win) | true | true iff setting on and a Steam client runs | normal |
| Steam desktop, no Steam client | true | false | wrappers inert because `steam_initialised()` is false |
| `Apple`, `Mobile` (iOS, MAS, Google Play) | false | false | Steamworks `copyToTargets=0` (`tools/check_port.py:22-23`); macOS packages must not contain `*steam*.dylib` (`tools/build.py:448-452`) |
| `SteamAndroid` | false (`platform_mobile()`) | false | friends button self-destroys |
| `QA` (`TCC_GAMEPLAY_QA`) | false | false | manager still created |
| `Check` (`TCC_SELF_CHECK`) | **true** | false unless a client runs | Only `steam_initialised()` returning false keeps it inert. Wrappers still call the extension. |
| `iOSCheck` (`TCC_MOBILE_SMOKE`) | false | false | |

`platform_steam()` = `!TCC_GAMEPLAY_QA && !TCC_MOBILE_SMOKE && TCC_STEAM && !platform_mobile() && os_type != os_gxgames` (`scripts/scr_platform/scr_platform.gml:17`; `TCC_STEAM` false under `Apple`/`Mobile`, lines 11-13).

Demo build: `platform_steam() && tcc_steam_get_app_id() == 1749610` makes `net_session_enter` return `"fail"` (`S:568`); ~40 other files gate on the same app id (out of scope).

---------------------------------------------------------------------------------------------------

## 2. Message catalog

### 2.0 Conventions

* All integers are native GameMaker buffer types (little-endian in the runner) [GM]. Strings are `buffer_string`: UTF-8 bytes plus one `0x00`. There is **no framing and no length prefix**: the packet length is the transport's message length (`steam_net_packet_get_size()` today). Byte 0 is always the packet type. Channel is never specified (0 both ways). Unknown types are silently ignored (no `default` case, `M:709-771`).
* Sender identity is **not in the packet**: it is the authenticated Steam id supplied by the transport (G9).
* Writers use the one shared `net_send_buffer`: `buffer_seek(buf, buffer_seek_start, 0)`, write, return `buffer_tell` as the size, then `net_send_to(member, size, reliable)`. The buffer is a grow buffer that is never shrunk, so its allocated size is **not** the packet size; the size is always passed explicitly (G6).
* Readers use the shared `net_recv_buffer` with the packet at offset 0 and always bound every string search and field read by the packet `_size`, never by the buffer size, because bytes beyond `_size` are stale (`net_packet_string_end`, `M:115-120`).
* Every receive-path failure is a **silent drop**: no log, no reply, no peer penalty.

### 2.1 Summary

| Id | Name | Delivery | Direction / fan-out | Cadence | Accepted size | Sender precondition |
|---|---|---|---|---|---|---|
| 16 | STATE | unreliable | each peer -> every lobby member whose last-known `level_key` equals ours (unicast loop) | 60/30/20/15 Hz by crowd, 5 Hz when idle (2.3) | 48..1024 (typical 62) | lobby member |
| 17 | HELLO | reliable | joiner -> all members (`reply=0`); each member -> joiner (`reply=1`) | once per join, one reply per announce | 14..150 | lobby member |
| 18 | BYE | reliable | leaver -> all members | once per `net_leave_lobby` | exactly 1 | lobby member |
| 19 | PING | unreliable | every peer -> all members | every 2000 ms; immediately on join and on `net_level_key` change | 8..1024 | lobby member |
| 20 | PONG | unreliable | PING receiver -> PING sender | 1 per valid PING | exactly 5 | lobby member and already in `net_players` |
| 21 | ER_PICKS | reliable | unicast (to a peer whose sid just became ours) or broadcast (we picked) | event driven | 4..1024 | lobby member |
| 22 | LEVEL_REQUEST | reliable | follower -> lobby owner | once per download (a repeat restarts it) | exactly 34 | lobby member |
| 23 | LEVEL_CHUNK | reliable | owner -> requester | up to 16 chunks/tick across <= 8 transfers | 44..8236 (global cap 8448) | lobby member, and the active transfer must name this sender |
| 24 | LEVEL_DENY | reliable | owner -> requester | on failure | exactly 34 | lobby member and the active transfer must name this sender |

"Lobby member" = in `global.net_members`, not us (`net_lobby_member`, `M:519-522`). The universal receive gate (`M:693-706`) is:

```
while (processed < 128 && receive()):                      ++processed counts EVERY dequeued packet
    sender = sender_id(); size = size()
    if (!finite(size) || size < 1 || size > 8448) continue                    // M:697  (that packet only)
    if (!net_lobby_member(sender)):
        if (net_refresh_forced_tick == timing_tick_id()) continue             // one forced refresh per tick
        net_refresh_forced_tick = timing_tick_id(); net_refresh_members()
        if (!net_lobby_member(sender)) continue                               // M:698-704
    get_data(recv_buffer)  ;  if (size > buffer_get_size(recv_buffer)) continue   // M:705-706
    switch (peek_u8(recv_buffer, 0)) { 16..24 as below; default: ignored }
```

### 2.2 STATE (16): `net_write_state` `M:128-151`, `net_decode_state` `M:152-192`

| Offset | Type | Field | Source on the sender (`M:646-656`) |
|---|---|---|---|
| 0 | u8 | type = 16 | |
| 1 | u16 | `seq` | `net_send_seq` captured **before** it is incremented (first packet carries 0); `& $FFFF` |
| 3 | f32 | `x` | `o_player.x` (`o_playerdead.x` when dead) |
| 7 | f32 | `y` | |
| 11 | u8 | `image_index` | `floor(image_index) & $FF` |
| 12 | s32 | `image_blend` | `c_white` if `customskin == 1` and alive, else `image_blend` |
| 16 | f32 | `image_xscale` | 1 if dead |
| 20 | f32 | `image_yscale` | 1 if dead |
| 24 | f32 | `image_angle` | 0 if dead |
| 28 | f32 | `image_alpha` | `clamp(,0,1)` |
| 32 | u8 | `color` | `net_cosmetic_id(global.color,4)` |
| 33 (`NET_STATE_HEADER`) | string | `room_name` | `room_get_name(room)`, <= 127 bytes + NUL |
| after NUL | string | `level_key` | `global.net_level_key`, 1..127 bytes + NUL |
| +0 | u8 | `skin` | `net_cosmetic_id(global.skinselected,49)`; 0 if `customskin == 1`; `net_last_skin` when dead |
| +1 | u8 | `hat` | `net_cosmetic_id(global.hatselected,67)` |
| +2 | u8 | `item` | `net_cosmetic_id(global.itemselected,3)` |
| +3 | f32 | `hsp` | 0 if dead |
| +7 | f32 | `vsp` | 0 if dead |
| +11 | u8 | `is_dead` | 1 if only `o_playerdead` exists |
| +12 | u8 | `zerogrv` | 0 if dead |

Size = `33 + len(room)+1 + len(key)+1 + 13`. Example: room `r_lvl12` and key `r_lvl12` = 62 bytes. Practical maximum with 127-byte strings is 302. Offsets confirmed against the self-check probe (`M:1198-1201`).

Decoder rejects (returns `undefined`, nothing else happens) unless **all** hold (`M:152-191`): `48 <= size <= 1024` and `size <= buffer size`; byte 0 == 16; room NUL found in `[33, size)` within 127 bytes; key NUL found within 127 bytes after it; `key_end + 14 == size` exactly; all eight floats finite; `|x|,|y| <= 1048576`; `|hsp|,|vsp| <= 10000`; `0.0001 < |xscale|,|yscale| <= 16`; `|angle| <= 1e6`; `0 <= alpha <= 1`; `color <= 4`; `is_dead, zerogrv <= 1`; `0 <= blend <= 16777215`; `net_room_asset(room)` resolves to an `asset_room` (name <= 127 bytes); `net_key_valid(level_key)` (1..127 bytes). Cosmetics are **clamped, not rejected** (skin > 49, hat > 67, item > 3 become 0). The sprite is derived locally: `sprite_index = net_builtin_skin_sprite(skin,color,is_dead)`, `image_index mod max(1, sprite_get_number(sprite))`. No sprite handle, PNG path or custom skin crosses the wire.

### 2.3 STATE send policy (`net_send_player_state`, `M:627-675`)

* Not sent at all if not active, `net_level_key == ""`, there is no `o_player` and no `o_playerdead`, or no peer is on the same level. Targets = members of `net_member_list` whose `net_players[...].level_key == global.net_level_key` (a member not yet in `net_players` gets nothing).
* Interval in ticks by the number of same-level peers `n`: `n<=8` -> 1; `<=16` -> 2; `<=32` -> 3; else 4.
* Idle: a string signature of `x, y, image_index, image_xscale, image_angle, image_alpha, is_dead, color, image_blend, level_key`. Unchanged since the last evaluation -> `net_send_idle++` (cap 1000); once `net_send_idle > 2` the interval becomes `max(interval, 12)` (5 Hz). Changed -> idle 0 and signature stored. The signature is evaluated on every call that reaches it, including non-sending ticks. (`image_yscale, hsp, vsp, skin, hat, item, zerogrv, room_name` are not in it.)
* `net_send_timer++` per call; send when `timer >= interval`; then timer 0, `net_send_seq = (seq+1) & $FFFF`, write **once** and send the **same bytes** to every target.
* A `net_level_key` change resets `net_send_signature` and forces a PING (`S:180-185`).

### 2.4 HELLO (17): `M:193-218`

| Offset | Type | Field |
|---|---|---|
| 0 | u8 | 17 |
| 1 | u8 | `NET_PROTOCOL` (2) |
| 2 | u8 | `reply` (0 = announcement, 1 = reply) |
| 3 | string | persona name = `net_clean_name(tcc_steam_get_persona_name())` (CR/LF -> space, first **64 characters**) |
| after NUL | f64 | `global.net_join_time` |
| +8 | u8 | `skin` |
| +9 | u8 | `hat` |

Size = `3 + len(name)+1 + 10`. Decoder: `14 <= size <= 150`; name NUL within **128 bytes** from offset 3; `end + 11 == size`; `proto == NET_PROTOCOL`; `reply <= 1`; finite time.

Receiver (`M:718-732`): `net_register_player(sender, username, current_time, skin, hat)` (the wire `join_time` is validated but **not used**: the receiver stamps its own clock "first seen" so the leaving owner can rank members). Then updates username/skin/hat/last_update; **only if `reply == 0`** answers with a reliable unicast HELLO `reply=1` and shows the "player joined" notice the first time. Replies are never answered ("replying to replies caused endless ping-pong", `M:726`). Sent exactly once per join as a broadcast right after the join validates (`M:1097`); a freshly created own lobby sends none. Skin/hat/item changes afterwards travel in STATE.

### 2.5 BYE (18): `M:617-622, 733-735`

`[18]`, 1 byte, reliable broadcast on `net_leave_lobby`. Receiver requires `size == 1` and calls `net_remove_player(sender, true)`: deletes the peer record, shows `NET_PLAYER_LEFT` if that peer had `announced`, and closes the P2P session with it.

### 2.6 PING (19): `M:219-246, 677-681, 736-753`

| Offset | Type | Field |
|---|---|---|
| 0 | u8 | 19 |
| 1 | u32 | `stamp` = `current_time & $FFFFFFFF` (sender's ms clock) |
| 5 | string | `room_get_name(room)` |
| next | string | `global.net_level_key` (may be `""` in menus) |
| next | string | `global.net_session_in_menu ? "" : global.net_session_sid` (<= 64 bytes; format `"<steamid64>-<counter>-<current_time mod 1e6>"`, `S:91-94`) |

Min 8, max 1024. Decoder: room NUL within 127 bytes from offset 5; key NUL within 127; sid NUL within 64; `sid_end + 1 == size`; room must be a valid room asset; key `""` or valid. Receiver: register the sender if unknown (name = `tcc_steam_get_user_persona_name_sync(sender)`, skin/hat 0); if the key changed `ghost_alpha = 0`; store `room_name, level_key, sid, last_update = current_time`; if the `sid` changed call `net_er_peer_joined_run(sender, sid)` (reliable ER_PICKS); then write PONG into the shared send buffer and `net_send_to(sender, 5, false)`.

Purposes: (1) keepalive feeding the 10 s timeout, (2) tells peers which level/session we are in so they know whether to send us STATE, (3) RTT measurement.

### 2.7 PONG (20): written inline `M:749-752`, read `M:754-762`

`[20][u32 stamp]`, 5 bytes, unreliable unicast, echoing the pinger's stamp. Receiver needs `size == 5` and the sender already in `net_players`; `rtt = ((current_time & $FFFFFFFF) - stamp) & $FFFFFFFF`; if `rtt < 60000`, `peer.rtt = peer.rtt < 0 ? rtt : lerp(peer.rtt, rtt, 0.3)`. The only consumer is the Friends panel (`F:271`, shows "<ms> ms"). PONG does **not** refresh `last_update`.

### 2.8 ER_PICKS (21): `S:1013-1062`

`[u8 21][string sid (<=64)][u8 count][count x ([u32 index][string key])]`. Encoder: `count <= 24`; stops when `tell + len(key) + 6 > 1024`; sends nothing when `count == 0` or `net_member_list` is empty or `net_session_sid == ""`; target `-1` = broadcast, else unicast; reliable. Decoder (`S:1037-1054`): `4 <= size <= 1024`; sid NUL within 64 and `sid_end+1 < size`; **ignored unless `sid == global.net_session_sid` and `global.endless == 1`**; for each entry `tell + 5 <= size`, key NUL inside the packet, `net_key_valid(key)`, `1 <= index <= 1000000`; **the first pick for an index wins** (never overwritten). Keys are room names or `"ws:<workshop id>"` (decimal string). Sent when we pick the next level outside `r_endlessrunmenu` (`S:962, 980`) and by `net_er_peer_joined_run` (`S:1057-1062`, windows of 24 from `er_index-2` up to the last contiguous known pick).

### 2.9 LEVEL_REQUEST (22) / LEVEL_DENY (24): `L:102-125, 198-208`

`[u8 type][string md5]` = 34 bytes (32 lowercase hex + NUL), reliable unicast. Receivers require `size == 34`, valid md5 (`net_packet_string_end(buf,1,size,32) == 33`, lowercase hex). REQUEST goes follower -> lobby owner (`S:855` `net_levelshare_request(md5, global.net_owner_id)`); the owner queues a transfer or answers DENY (level unknown / unreadable / md5 mismatch / >= `NET_MAX_LOBBY` queued). A DENY is honoured only if it matches the active incoming transfer's md5 and peer; it marks the md5 denied for 60 s.

### 2.10 LEVEL_CHUNK (23): `L:147-191, 209-238`

| Offset | Type | Field |
|---|---|---|
| 0 | u8 | 23 |
| 1..33 | string | md5 (32 chars + NUL) |
| 34 | u32 | `total` bytes of level.json (UTF-8) |
| 38 | u32 | `offset` of this chunk |
| 42 | u16 | `length` of this chunk (<= 8192) |
| 44 (`NET_SHARE_HEADER`) | bytes | data |

Reliable unicast owner -> requester, max size 44+8192 = 8236 (<= `NET_CHUNK_MAX_SIZE` 8448). Sender: at most 8 active transfers, `NET_SHARE_CHUNKS_PER_TICK`=16 shared (`max(1, 16 div active)` each); **`net_send_to` returning false stops that transfer's burst for this tick and the same chunk is resent next tick** (`L:176-177`); transfers die if the peer leaves the lobby; the send buffer is `buffer_resize`d up to `44+length` when smaller (`L:168`). Receiver: needs the active incoming transfer to match md5 and sender; `size >= 44`; `offset == 0` while a buffer exists restarts the stream; `offset != 0` with no buffer is ignored as "tail of a superseded stream"; otherwise **all** must hold or the transfer is aborted and the md5 marked denied for 60 s: `length <= 8192`, `44 + length == size`, `1 <= total <= 16 MiB`, `offset == received`, `offset + length <= total`, `total` stable. Deadlines: first chunk 60 s (`2 * NET_SHARE_TIMEOUT_MS`), then 30 s after each chunk. On completion: MD5 of the bytes, write `level.json.pending`, `level_parse_json_file`, `level_validate`, rename to `Online Levels/<md5>/level.json`. The receiver relies on **reliable ordered delivery**: "Reliable P2P delivery is ordered: anything else is a broken stream" (`L:215,222`).

### 2.11 Lobby key/value data (Steam lobby metadata, not P2P)

Only the owner writes (Steam rule). All values strings.

| Key | Written | Read | Meaning |
|---|---|---|---|
| `game_name` | `M:484` | `M:1077` | must equal `"TheColorfulCreature"` to be accepted on join |
| `proto` | `M:485` (stringified by `net_lobby_set`, `M:468`) | `M:1078` | compared as `string(NET_PROTOCOL)` = `"2"` |
| `host_name` | `M:486` | `M:1104`; `F:124`; `PS:26` | owner display name for banners |
| `session` | `S:404` | `S:411` | JSON session descriptor (below), <= 8000 bytes |
| `current_room` | `S:405` | **no reader exists** | owner's room name; write-only today |

`net_lobby_set(key, value)` (`M:467-473`) skips the Steam call if the cached value is identical, otherwise calls `set_data` and **updates the cache only when it returns true**. `net_become_host` clears the cache so everything is re-written (`M:483`). No lobby-data-update event is handled: followers poll `session` (3.10).

Session descriptor JSON (`S:293-366` capture; `S:369-384` validation; `S:387-406` publish): common fields `v` (= `NET_PROTOCOL`), `sid`, `mode`, `joinable`, `room`, `key`, `title`; `name` added at publish.

| mode | extra fields | joinable |
|---|---|---|
| `menu` | `sid:""` | false |
| `local` | | false |
| `editor` | | false; becomes `shared` (with `md5`, `title`) while `net_level_key != ""` (play-test), then joinable |
| `endless` | `erm` (1-4), `eri` (level index), `diff` (mode 1), `cer` (mode 3), `ws` (mode 4, decimal string) | PLAY class; mode 4 only in `r_customlevelworkshop` |
| `wschallenge` | `title, index, dt, diff, levels[{id (decimal string), title}]` (<= 64) | false if > 64 levels |
| `workshop` | `ws` (decimal string), `title` | |
| `shared` | `md5`, `title` | |
| `challenge` | `ch, chl, chr, dir, title` | |
| `room` | `hard` | everything else (campaign, level select, hard, daily, calendar, room-based custom challenge) |

`joinable` = room class is PLAY, forced false when `key == ""`. Publish: owner only; throttled to once per 15 ticks unless forced; if > 8000 bytes first drop Workshop challenge level titles, then degrade to a `menu` stub; skipped if unchanged; writes `session` then `current_room`. Reader (`net_session_host_desc`, `S:409-421`): empty/non-string -> none; cached by JSON text; > 8192 bytes rejected; `json_parse` in try/catch; valid iff `v == NET_PROTOCOL`, `sid/mode/room/key` are strings <= 127 bytes; `joinable` normalised; `sid == ""` forces non-joinable. **Steam ids travel in JSON as decimal strings** (`S:83-90`) because JSON doubles cannot hold 64-bit ids; they are parsed back with `int64()` after a `string_digits` check, <= 20 chars.

### 2.12 Rich presence (outgoing) and Steam-delivered inbound messages

Outgoing keys: `steam_player_group` = lobby id string, `steam_player_group_size` = member count, set only while in a lobby with more than one member, else both `""` (`M:1160-1173`, drives Steam friends-list "Playing with"). Local state key `steam_display` plus helper keys `level, boss, challengename, levelname` from `scripts/scr_rich_presence/scr_rich_presence.gml` (called from `o_title/Create_0.gml:8`, `loadhud.gml:22`, 18 room creation codes). **No `connect` key is ever set** (grep).

Inbound Steam events consumed by the online layer, with their exact 2.x encoding [N2]:

| `event_type` | Keys the game reads | 2.x encoding of those keys | Source in [N2] |
|---|---|---|---|
| `lobby_created` | `success`, `lobby_id` | `success` = `(m_eResult == k_EResultOK)`; also `result`; `lobby_id` int64; **dispatched for every create call** | `steam_matchmaking.cpp:484-491`, `gml_glue.h:61-64` |
| `lobby_joined` | `success`, `lobby_id` | `success = !io_failure` only (**not** the enter response); `lobby_id` = the lobby actually entered (may differ from the requested id in instance bits) | `steam_matchmaking.cpp:407-413`, `gml_glue.h:57-60` |
| `lobby_chat_update` | `lobby_id`, `change_flags`, `user_id` | `user_id` = `m_ulSteamIDUserChanged`; `change_flags` = raw `m_rgfChatMemberStateChange` bitfield (1 entered, 2 left, 4 disconnected, 8 kicked, 16 banned) as a double | `steam_lobby_chat.cpp:182-190` |
| `lobby_join_requested` | `lobby_id` (`friend_id` ignored) | int64 each | `steam_matchmaking.cpp:451-456` |
| `avatar_image_loaded` | `user_id`, `image` (`success` **not** read) | | `steam_callbacks.h:22` |
| `ugc_subscribe_item` | `published_file_id`, `result` | `result` compared with the raw constant `ugc_result_success` | |

All 2.x events are created with `CreateAsyncEventWithDSMap(map, 69)` (`gml_glue.h:24-26`): queued, delivered in the Async-Steam stage, to every instance that has an `Other_69` event. All ids are `DsMapAddInt64`, i.e. GML int64 (`gml_glue.h:35-37, 51-56`). Other `Other_69` handlers that share the stream but are not online code: `o_title`, `o_version`, `o_checkplayercount`, leaderboards x3, `o_customlevelsbrowser`, `o_publishworkshopchallenge`, `o_getallinventoryitems`, `o_settings`, `o_tradeup_menu`, `o_profilepicture`, `o_publishinghappenshere`, `o_customlevelworkshopbuttonplay`, `o_workshoplevelselectbutton`, `o_workshopERloading`.

---------------------------------------------------------------------------------------------------

## 3. Session lifecycle

### 3.1 Local membership state machine

```
                 net_enabled(), !active, no pending join/create/join-reply,
                 tick > net_join_defer_tick, now >= net_host_retry_at, room not loading/logo
   OFFLINE ------------------------------------------------------------------------------> CREATING
      ^                                                                                      |  net_create_pending, net_host_intent
      |  (retry 15 s: create call refused)  <--------------------------------------------- +  lobby_create(friends_only, 250)
      |  (retry 30 s: reply failed)         <---- reply: success=false -----------------------+
      |                                                                                      |
      |        reply unwanted (intent withdrawn / join pending / already active / online off)|--> leave created lobby --> OFFLINE
      |                                                                                      |
      |                                     reply: success=true, wanted                      v
      |                                                                                   HOSTING  (active, owner = me)
      |  member_count <= 0 (refresh)  or  chat_update says *I* left/was kicked  --> reset + notice NET_DISCONNECTED
      |  online disabled / Steam gone  --> net_leave_lobby(false), silent
      |
  net_request_join(id)  [panel Join, overlay Join Game/invite, +connect_lobby]
      |   (already in that lobby? -> net_follow_now(); no leave, no rejoin)
      v
   net_queue_join: host_intent=false; net_leave_lobby(false) [BYE, owner handoff, leave, close sessions, reset];
                   pending_join=id; defer 1 tick; banner "joining"
      |  tick > defer, !create_pending, join_pending == -1
      v
   JOINING (net_join_pending_id = id) --lobby_join_id false--> immediate failure: clear, flash NET_JOIN_FAILED
      |  reply:  stale (id mismatch / no pending) --> discard (leave if success, reset)
      |          success=false --> lobby_leave, reset, flash NET_JOIN_FAILED
      |          success=true  --> VALIDATE: net_lobby_id = reply id; refresh members;
      |                              members<=0 -> leave, NET_SESSION_UNAVAILABLE
      |                              game_name != "TheColorfulCreature" or proto != "2" -> leave, NET_VERSION_MISMATCH
      |                              else active, owner = lobby owner, follow = !host, HELLO broadcast, ping now
      v
   JOINED (follower)   or  HOSTING if the owner turned out to be me
```

Two properties of this machine are part of the contract:

1. **Every online player owns a lobby at all times** (auto-host, `M:561-564`). Joining someone therefore means leaving your own lobby after handing it to its longest-standing member (3.6).
2. **Exactly one reply is expected per create and per join**, and the pending flags are only cleared by that reply (or by an immediate falsy return). The code has no timeout for them (G12).

### 3.2 Boot and lifetime

1. `scr_loading` runs `net_init()` (`scr_loading.gml:407`) and parses `+connect_lobby <id>` once per process into `global.net_launch_lobby` (`:409-421`).
2. `o_loading` and `o_title` call `net_ensure_manager()`; the persistent `o_networkmanager` drives everything from `Step_0`.
3. Cold launch: `net_tick` (`M:539-546`) consumes `net_launch_lobby` once the room is not `r_loading`/`r_logointro`, converts with `int64()` in try/catch, calls `net_request_join`. It runs **before** the `net_enabled()` check but after the Steam guard at `M:530`, so it is retained until Steam is up.
4. `game_restart` (the ending): `net_game_restart()` sets `net_restarting`; `CleanUp_0` skips `net_cleanup`; the next boot's `net_init` returns early (`M:258`) so globals, maps, buffers **and the Steam lobby** survive and the party is not broken up. A real game end runs `net_cleanup()` (`M:330-342`: leave lobby without notice, free everything). Whether 3.0 callbacks registered with `steam_*_set_callback_*` survive `game_restart` is **not verified** [UNV] (G15).

### 3.3 Per-tick schedule (`net_tick`, `M:528-600`), in order

1. Return unless `net_ready`, `platform_steam()`, `tcc_steam_initialised()` (`M:529-530`).
2. Lazily cache `global.net_my_steam_id` (`M:531`).
3. First time only: `tcc_steam_net_set_auto_accept_p2p_sessions(true)`, `net_p2p_accept = true` (`M:532-536`).
4. Cold-launch join (`M:539-546`).
5. If `!net_enabled()`: leave lobby if active (silent), clear connecting banner, `net_pending_join = -1`, `net_host_intent = false`, return (`M:548-554`).
6. Issue the queued join if allowed (`M:557-560`). Then auto-host (`M:562-564`). Then return if not active (`M:566`).
7. Every `NET_REFRESH_TICKS` (30 ticks = 0.5 s) (`M:568-590`): `net_refresh_members()`; if it returns <= 0, `net_reset_lobby_state()` + notice `NET_DISCONNECTED`, return. Re-read the lobby owner; if non-zero and changed, update `net_owner_id`/`net_is_host`, then `net_become_host()` (+ notice `NET_YOU_ARE_HOST` if others are present) or `net_session_owner_changed()`. Then `net_apply_member_limit()` and `net_presence_update(false)`.
8. Owner: `net_session_publish(false)`; follower: `net_follow_poll()` (`M:592-593`).
9. `net_send_player_state()` -> `net_send_ping()` -> `net_receive_packets()` -> `net_update_ghosts()` -> `net_levelshare_tick()` (`M:595-599`). **Sends happen before receives within a tick.**

`NM/Step_0` runs `net_session_update()` first (it never needs Steam), then `net_tick()`.

### 3.4 Creating the lobby (`net_host_lobby`, `M:429-441`; reply `M:1022-1048`)

* Preconditions `net_enabled()`, not active, no pending join. Sets `net_host_intent = true`; returns if a create or join reply is outstanding. Caches own id, `net_create_pending = true`.
* `tcc_steam_lobby_create(steam_lobby_type_friends_only, NET_MAX_LOBBY)`. Steam fixes lobby size at creation, but the lobby now lives for the whole game, so it is created at the cap (250) and the owner enforces Max Players with `set_joinable` (3.8). **A falsy return is treated as immediate failure**: clear `net_create_pending` and `net_host_intent`, retry in 15 s (`M:437-440`). In 2.x the call returned true unless `SteamMatchmaking()` was null ([N2] `steam_matchmaking.cpp:494-514`), so this branch practically never fired.
* Reply `lobby_created` (`M:1022-1048`): clear `net_create_pending`; read and clear `net_host_intent`. If the reply is unwanted (not ours, intent withdrawn, a join is pending, already active, or online disabled) and we are not active: `net_discard_lobby_reply(success)` (leave the lobby if the reply was a success, then `net_reset_lobby_state()`) and stop. On `success`: `net_lobby_id = lobby_id`, `net_active = true`, `net_join_time = now`, `net_owner_id = me`, `net_refresh_tick = 0`, `net_refresh_members()`, `net_become_host()`. On failure: `net_host_retry_at = now + 30000`, silent.
* `net_become_host()` (`M:476-490`): `net_is_host = true`, `net_follow_host = false`; cancel any follow job and release follow-only Workshop subscriptions; clear the lobby-data cache; write `game_name`, `proto`, `host_name`; `net_session_publish(true)`; reset `net_lobby_joinable = -1`; `net_apply_member_limit()`.

### 3.5 Joining (`net_request_join` `M:405-425`, `net_queue_join` `M:395-401`, `net_join_lobby` `M:445-458`, reply `M:1050-1108`)

Entry points all converge on `net_request_join(lobby_id)`: Friends panel Join (`F:204-206`, id from the friend's `lobbyId`), overlay "Join Game"/invite accept (`lobby_join_requested`, `M:1127-1133`, in any room or mode), cold launch (3.2).

1. Needs `platform_steam() && tcc_steam_initialised()`; `int64()` the id; 0 rejected. `net_ensure_manager()`. If the online setting was off it is switched on, `scr_savesettings()` called and notice `NET_ONLINE_ENABLED` shown.
2. Already in that lobby (`net_active && net_lobby_id == id`): if not host, set `net_follow_host = true` and `net_follow_now()`; return true. Nothing is left or rejoined.
3. Same id already queued: return true. Else `net_queue_join(id)` then `net_follow_host = true`, `net_join_announced = false`.
4. `net_tick` calls `net_join_lobby(id)` once nothing else is pending and `tick > net_join_defer_tick`: `net_host_intent = false`, own id, banner "joining", `net_join_pending_id = id`, `tcc_steam_lobby_join_id(id)`; **falsy return = immediate failure** (clear both pending ids, `net_follow_host = false`, flash `NET_JOIN_FAILED`).
5. Reply `lobby_joined`: `net_join_pending_id` must be set, else an unexplained reply is discarded (fail closed). If `net_pending_join` no longer equals the expected id (newer invite replaced it) discard. `success == false`: `lobby_leave`, reset, flash `NET_JOIN_FAILED`. Success means only IO success ([N2] `steam_matchmaking.cpp:411`): "Steam reports IO success even for a full or vanished lobby, and it may change the instance bits of the ID" (`M:1072-1073`), so the entered lobby is validated: `net_lobby_id = reply id` (overwrites the requested one), own id, refresh members; `members <= 0` -> `NET_SESSION_UNAVAILABLE`; `game_name != NET_GAME_NAME` or `proto != "2"` -> `NET_VERSION_MISMATCH` (both do `lobby_leave` + reset). Accept: `net_active = true`, `net_join_time = now`, `net_refresh_tick = 0`, owner = `lobby_get_owner_id()`, `net_is_host = (owner == me)`, `net_follow_host = !net_is_host`, **`net_send_hello(-1,false)`** broadcast, `net_ping_at = 0`; owner -> `net_become_host()` else `net_session_joined_lobby()` (`S:426-434`); flash `NET_JOINED_SESSION` with `host_name`; `net_presence_update(true)`.

### 3.6 Leaving, handing over, losing the lobby

`net_leave_lobby(announce = true)` (`M:375-392`), used by Friends Leave (`F:201-203`), `net_queue_join`, `net_cleanup`, and `net_tick` when online is disabled:

1. No-op if not active. `net_send_bye()` (reliable broadcast of packet 18).
2. **Voluntary host handoff**: if we are owner with peers, pick the member whose `net_players[...].join_time` is earliest (members with no record rank `infinity`; the first member wins ties/all-infinity) and `tcc_steam_lobby_set_owner_id(successor)`; return value ignored.
3. `tcc_steam_lobby_leave()`; return ignored.
4. `tcc_steam_net_close_p2p_session(member)` for every member in `net_member_list` — **immediately after the BYE, so BYE delivery is best-effort** (G11).
5. `net_reset_lobby_state()` (`M:357-372`): clear `net_players`, `net_members`, `net_lobby_data`, `net_member_list`; `net_active=false`, `net_lobby_id=-1`, `net_is_host=false`, `net_owner_id=0`, `net_follow_host=false`, `net_lobby_joinable=-1`, `net_join_defer_tick=now`; `net_session_lobby_reset()` (forget host descriptor, cancel follow, clear failed-subscribe map, **`net_er_keep_sid = ""`**, `S:62-74`); `net_levelshare_lobby_reset()` (drop all transfers); `net_presence_update(true)`.
6. Optional notice `NET_LEFT_SESSION`.

Reset **without** closing P2P sessions happens on lobby loss (`M:572`), being kicked/disconnected (`M:1116-1119`), failed join validation and discarded replies (`M:462-465, 1066-1089`). After any reset the auto-host recreates a lobby on the next eligible tick.

### 3.7 Membership, ownership and `lobby_chat_update`

* `net_refresh_members()` (`M:499-518`): `get_member_count` (non-finite -> 0), `get_member_id(i)` for each index (non-numeric or 0 skipped) -> `net_members` (all) and `net_member_list` (all except us); **then removes ghosts** for any `net_players` entry no longer in `net_members` via `net_remove_player(id,false)` (which closes its P2P session). A count `<= 0` means Steam no longer reports us in the lobby.
* Runs every 30 ticks, immediately after `lobby_chat_update` (sets `net_refresh_tick = 0`), after `lobby_created`/`lobby_joined`, and as a forced refresh (max once per tick) when a packet arrives from an unknown sender (`M:698-704`; "a newcomer's first packet can beat Steam's membership callback").
* `lobby_chat_update` (`M:1110-1125`): ignored unless active and `lobby_id == net_lobby_id`. `change_flags & (2|4|8|16)` (left, disconnected, kicked, banned): if `user_id` is us -> `net_reset_lobby_state()` + `NET_DISCONNECTED`; otherwise `net_remove_player(user_id, true)` (announces, closes the session). Flag 1 (entered) only triggers the refresh.
* Owner change (found by polling every 30 ticks, not by event): we became owner -> `net_become_host()`; someone else -> `net_session_owner_changed()` (`S:438-443`): 4 s quiet window (`net_follow_quiet_until`), cancel any follow job, drop the in-flight level download ("levels are only requested from the owner").

### 3.8 Max Players applied live (`net_apply_member_limit`, `M:493-497`)

Owner only: `open = net_member_count() < clamp(round(global.netmaxplayers), 2, 250)`; if different from the cached `net_lobby_joinable` and `tcc_steam_lobby_set_joinable(open)` returns true, update the cache. Called from `net_become_host` (after resetting the cache to -1) and from every 30-tick refresh, so a setting change takes effect within 0.5 s and a new owner re-applies it. The lobby is created at 250 regardless. 3.0 has no member-limit setter (full `steam_matchmaking_*` list checked), so this design remains the only mechanism.

### 3.9 Peer lifecycle (the P2P "session")

```
unknown --STATE | PING | HELLO from a lobby member--> REGISTERED  (net_register_player; tcc_steam_user_set_played_with)
REGISTERED --HELLO--> + username/skin/hat, 'announced' (one "player joined" notice)
REGISTERED --valid newer STATE--> ghost updated (seq filter: see below)       --PING--> room/level/sid, PONG sent
REGISTERED --BYE (size==1)--> removed (notice if announced; close session)
REGISTERED --lobby_chat_update left/disc/kicked/banned--> removed (notice if announced; close session)
REGISTERED --no accepted STATE/HELLO/PING for > 10 000 ms--> removed silently (close session)  [still a lobby member]
REGISTERED --absent from net_members at a refresh--> removed silently (close session)
removed --next valid STATE or PING from a still-listed member--> REGISTERED again (late discovery)
```

* `last_update` is refreshed by accepted STATE, HELLO and PING; **not** by PONG, rejected or stale STATE. Stale/duplicate STATE is rejected before touching `last_update`, so a flood of old packets cannot keep a dead peer alive (`M:830, 842`). PINGs every 2 s keep an idle peer alive.
* Ghost motion (`net_update_ghosts`, `M:862-896`): timeout check; if no state arrived this tick and the peer is alive, up to 3 predicted steps (`target += hsp/vsp`); then `pos += (target - pos) * 0.6`, or snap if `snap` or the gap exceeds 96 px; `ghost_alpha` lerps toward visible (0.05 in, 0.1 out) where visible means `level_key == global.net_level_key`.
* Sequence filter (`net_seq_newer`, `M:824-828`): `last < 0` accept; else `delta = (seq - last) & $FFFF`, accept iff `0 < delta < 32768`.

### 3.10 Session layer: what each player is doing, and following (`S`)

* **Sid.** A new `net_session_sid` is minted when gameplay is entered from a menu-class room (`S:167-176`), unless `net_session_adopt` is set by a follow; editor play-test also mints a new sid (`S:201-214`). Menu rooms set `net_session_in_menu` and clear follow-related state (`S:155-166`).
* **Level key** (`net_level_key_compute`, `S:130-149`): `""` in menus and local rooms; `"lv:<md5>"` for editor play-test (`LEMode == 2`), shared levels and custom challenge levels; `"ws:<publishid>"` for Workshop levels; `"ch:<id>:<dir>"` for built-in challenges; otherwise the room name. A change resets the STATE signature and forces a PING.
* **Publishing** (owner): descriptor in lobby key `session` (2.11).
* **Following** (non-owner, `net_follow_poll` every tick from `net_tick`; descriptor polled every 15 ticks): new owner `sid`, `net_follow_host` true, outside the 4 s quiet window -> not joinable yet: remember `pending_sid` and show a one-time `NET_WAITING_FOR_HOST`; joinable: `net_follow_start` (180-tick countdown "warning", 0 if our own room is not PLAY class, or when invoked by `net_follow_now`). `net_follow_job_tick` cancels when we are no longer a follower, the player started a different session meanwhile, or the owner's latest descriptor has another sid or is an `editor` play-test; it waits while `net_follow_can_enter()` is false (paused, settings/editor-leave menus, death/popup/trade/wheel/Workshop-upload objects, loading rooms, editor and local rooms); at timer 0 it calls `net_session_enter(desc)` in try/catch. Results: `"done"`; `"wait"` (download in progress; deadline now+90 s, retry every 30 ticks, `NET_FOLLOW_TIMEOUT` on expiry); `"fail"` (`NET_FOLLOW_FAILED`). The first descriptor after joining is always followed even if it equals our own sid (sentinel `"*"`, `S:427, 474`).
* **Entering** (`net_enter_*`, `S:567-870`): modes `room` (campaign/level select/hard/daily/calendar, as practice), `challenge`, `endless` (modes 1-4), `workshop`, `wschallenge`, `shared`. All call `net_enter_begin` (settle a live Endless run, reset mode globals) and `net_enter_adopt`, then change room. Workshop-dependent modes require `global.steam_api` (set in `o_title/Create_0.gml:24-27` once `tcc_steam_initialised()`; false until the main menu). `shared` mode obtains the level file via LEVEL_REQUEST to the owner (`S:855`) and returns `"wait"` until cached.
* **Workshop fetch for follows** (`S:876-930`): `net_ugc_folder` (installed and not downloading, then install folder, `level_exists`), `net_ugc_request` (a failed subscribe blocks that item 60 s; learns whether the player already subscribed so only host-driven subscriptions are released), `net_ugc_release` (unsubscribes items the player did not own). The per-call subscribe result arrives as the global async event `ugc_subscribe_item`.
* **Followed calendar/daily rooms** (`net_room_followed`, commit `7365d338`): set only in `net_enter_room` (`S:648`); `net_door_override` (`S:252-256`) sends the player to `r_calendar` via `kickoutofcalendar()` when a followed room is not a campaign room (`net_campaign_room_level(room) == 0`), which also covers daily and room-based custom challenges.
* **Rejoin** (`7365d338`): joining the lobby you are already in does not leave and rejoin (`net_follow_now`). Endless picks survive re-entering the same run only if the player never left the lobby (`S:743-745, 780-781`); `net_er_keep_sid` is cleared by every lobby reset so picks made alone cannot override the party's after a re-join.
* **There is no ready check and no explicit "start".** The only start is: the owner enters gameplay from a menu, minting a sid that is published and followed (3.5-3.10). Do not invent one.

### 3.11 Endless Run picks (`S:932-1062`)

Map `index -> room name or "ws:<id>"`; the **first pick for a level number wins**. `randomlevel()` calls `net_er_resolve_room`; `workshopERrandomlevel` calls `net_er_resolve_workshop`/`goto_workshop`/`record_workshop`. Picks are broadcast (ER_PICKS) when made outside `r_endlessrunmenu`, and replayed to a peer whose PING sid became ours. `net_er_begin_pick` resets them when a run starts from `r_endlessrunmenu`.

### 3.12 Level share lifecycle (`L`)

`net_levelshare_offer(text)` (editor play-test / custom challenge) hashes with `md5_string_utf8` and keeps the 4 most recent texts (`L:61-73`). A follower calls `net_levelshare_request(md5, owner)` (rejected if online off, md5 invalid, denied < 60 s ago, peer is 0/me/non-member); one incoming transfer at a time (`net_share_in`). The owner queues a transfer per requester (a follower downloads one level at a time: a new request replaces the old one; a repeated request restarts from offset 0), creates a fixed buffer of the UTF-8 bytes when the transfer becomes active, and pumps chunks each tick. Ownership change drops the incoming transfer (`S:442`); `net_levelshare_lobby_reset` drops all.

### 3.13 Friends panel, friends list, avatars, pause line

* **Friends list** (`F:8-31`): `[]` unless Steam is up. `tcc_steam_get_app_id()` and `tcc_steam_get_friends_game_info()` (array of structs `{friendId, gameId, lobbyId, name}`); keep entries with `gameId == app id` and `friendId != 0`; build `{id, name, lobby (int64, 0 = none), status}`; joinable (lobby != 0) first. No network request: "Steam keeps friends' game, lobby and rich presence locally". In 2.x [N2] `steam_user.cpp:116-145` this iterates **all immediate friends** (`k_EFriendFlagImmediate`) and fills `lobbyId` from `GetFriendGamePlayed(...).m_steamIDLobby`, `gameId` from `m_gameID.AppID()`, `name` from `GetFriendPersonaName`; for non-players the struct is zero-initialised, which the game's `gameId` filter relies on.
* **Friend status** (`F:34-46`): reads `steam_display`; only values starting with `#` map to localisation key `RP_<token>`, with `%level% %boss% %challengename% %levelname%` substituted from same-named keys. The project **never calls** `steam_request_friend_rich_presence`; it silently relies on whatever Steam has cached.
* **Panel** (`F:128-208`): buttons Enable Online (writes setting), Invite (`tcc_steam_lobby_activate_invite_overlay`, enabled iff `net_active`), Steam Friends (`tcc_steam_activate_overlay(ov_friends)`, enabled iff `tcc_steam_is_overlay_enabled()`), Go to Host (clients only, enabled iff `net_session_host_desc()` is joinable), Leave; up to 4 member lines (name from `net_players[?].username` or `tcc_steam_get_user_persona_name_sync`, host marker via `net_owner_id`, location from `level_key`, RTT from `peer.rtt`); friend rows with Join (hidden if `friend.lobby == global.net_lobby_id`, `F:166`) and profile (`tcc_steam_activate_overlay_user("steamid", id)`). Id equality comparisons: `F:166, 270, 305`.
* **Avatars** (`F:51-108`): `tcc_steam_get_user_avatar(id, steam_user_avatar_size_medium)` once per id; handle `> 0` -> build a sprite from `image_get_size` + `image_get_rgba`; `== -1` -> cache `-2` "pending" until the `avatar_image_loaded` event resolves it; anything else -> `-1` none.
* **Pause line** (`PS:17-33`, requested file): shown when `global.onlinemultiplayersettings == 1 && net_ready`. Default text `NET_PAUSE_OFFLINE` in grey; if `net_active`, green: host -> `NET_PAUSE_HOSTING` with `{COUNT}` = `net_member_count()`; client -> `NET_PAUSE_JOINED` with `{NAME}` = `net_clean_name(tcc_steam_lobby_get_data("host_name"))` (**the only Steam call in the file, line 26, executed every Draw while paused as a client, not cached**). Font `fnt_multiplayerfont`, drawn at `(395+vx, 480+vy)`. Off Steam the guard `onlinemultiplayersettings == 1` is false (forced 0), and `net_active` is false unless a lobby was entered, so no Steam call runs on non-Steam builds; Steam desktop without a client shows `NET_PAUSE_OFFLINE` with no Steam call.

### 3.14 Cadence of Steam-touching work

| Cadence | Work |
|---|---|
| every simulation tick | `tcc_steam_update` (`FS/Step_0.gml:4`); `get_user_steam_id` until non-zero; while a lobby is active up to 128 receives; one `packet_send` per same-level member (rate-limited 1/2/3/4 ticks, idle 12); while a follow job exists `lobby_get_data("session")` (`S:526`) |
| every tick while the Friends panel is open (client) | `lobby_get_data("session")` (`F:145`), `lobby_get_data("host_name")` per Draw |
| every Draw while paused as a client | `lobby_get_data("host_name")` (`PS:26`) |
| 15 ticks | owner `net_session_publish` (`lobby_set_data` only on change); client `net_follow_poll` -> `lobby_get_data("session")` |
| 30 ticks | `net_refresh_members` (count + id per member), `lobby_get_owner_id`, `lobby_set_joinable` if changed, `net_presence_update` |
| 90 ticks (panel open) / 120 ticks (main menu) | `net_friends_list` (`get_friends_game_info` + up to 5 rich-presence reads per friend) |
| 2000 ms | `net_send_ping` broadcast |
| event driven | create/join/leave/handoff, `set_played_with`, `close_p2p_session`, UGC calls, overlay calls, rich presence on every room entry |

---------------------------------------------------------------------------------------------------

## 4. Complete table of Steam calls in the online layer

Built from a fresh `grep` of `M`, `S`, `F`, `L`, `PS`, `NM/*`, `FS/Other_69.gml`, `FS/Step_0.gml`, `o_friendsbutton/*`, `o_friendspanel/*` (not from the readings). "W" is the wrapper's line in `scr_steam_safe.gml`. Every wrapper is `if (platform_steam() && steam_initialised()) return steam_X(...); return <default>;` except `tcc_steam_initialised` (`W:102-105`: `platform_steam() ? steam_initialised() : false`). The raw 2.x name of every row is the wrapper name without the `tcc_` prefix (checked against the `W` bodies: `tcc_steam_X` calls `steam_X`). The "2.x native behaviour" column is from [N2] and is what the caller's contract was actually built on. 3.0 candidates are pointers only (4.D); choosing among them is design work outside this document.

### 4.A Lobby

| # | Old call (wrapper -> raw 2.x) | Purpose | Call sites | What the caller consumes | 2.x native behaviour [N2] (`steam_matchmaking.cpp` unless noted) |
|---|---|---|---|---|---|
| L1 | `tcc_steam_lobby_create(type,max)` W:150 -> `steam_lobby_create` | create own friends-only lobby, cap 250 | `M:437` | raw const `steam_lobby_type_friends_only`; **falsy return = immediate failure** (retry 15 s); reply = event `lobby_created {success, lobby_id}` | `:494-514`: calls `steam_lobby_leave_()` first (`:499`), `CreateLobby`, returns true unless `SteamMatchmaking()` is null. Reply `:484-491` sets `steam_lobby_current` from the reply **even on failure** and always dispatches. |
| L2 | `tcc_steam_lobby_join_id(id)` W:170 -> `steam_lobby_join_id` | join a friend's lobby | `M:453` | int64 id; **falsy = immediate failure**; reply `lobby_joined {success, lobby_id}` | `:436-441`: `JoinLobby`, returns true if interface exists. Does **not** leave first (only the list-join variant does, `:420`). Reply `:407-413`: sets `steam_lobby_current` from the reply, `success = !io_failure`. |
| L3 | `tcc_steam_lobby_leave()` W:174 -> `steam_lobby_leave` | leave the **current** lobby (no id) | `M:388` (leave), `M:463` (`net_discard_lobby_reply`), `M:1066`, `M:1080`, `M:1086` | return ignored | `:19-27`: `LeaveLobby(current)` + clear if valid; harmless no-op otherwise. |
| L4 | `tcc_steam_lobby_set_owner_id(id)` W:182 | hand ownership to the successor before leaving | `M:386` | return ignored | `:66-69` `SetLobbyOwner(current, id)`; 0 if no current lobby. |
| L5 | `tcc_steam_lobby_set_data(key,val)` W:178 | publish `game_name`, `proto`, `host_name`, `session`, `current_room` | `M:470` (inside `net_lobby_set`; keys `M:484-486`, `S:404-405`) | bool; **cache updated only when true** (`M:470-472`); `S:404` updates `net_published_json` only when true | `:523-526` `SetLobbyData(current, k, v)`; false if no current. |
| L6 | `tcc_steam_lobby_get_data(key)` W:154 | read `session`, `game_name`, `proto`, `host_name` | `S:411`; `M:1077, 1078, 1104`; `F:124`; `PS:26` | string, `""` when absent; `S:412` treats `""`/non-string as none | `:540-543` `GetLobbyData(current, k)`; `""` if no current. |
| L7 | `tcc_steam_lobby_set_joinable(bool)` W:34 | close/open at Max Players | `M:496` | bool; cache updated only when true | `:83-86` `SetLobbyJoinable(current, b)`; false if no current. |
| L8 | `tcc_steam_lobby_get_member_count()` W:158 | membership | `M:502` | numeric; non-finite -> 0; **`<= 0` means the lobby is lost** (`M:570`) | `:98` `GetNumLobbyMembers(current)` (0 for an invalid id). |
| L9 | `tcc_steam_lobby_get_member_id(i)` W:162 | membership | `M:505` | numeric, `0` skipped | `:111-115` bounds-checked `GetLobbyMemberByIndex(current, i)` as int64; 0 out of range. |
| L10 | `tcc_steam_lobby_get_owner_id()` W:30 | host detection | `M:576`, `M:1094` | int64; compared to 0 (unknown), `net_owner_id`, `net_my_steam_id` | `:50-55` `GetLobbyOwner(current)`; 0 if no current. |
| L11 | `tcc_steam_lobby_is_owner()` W:166 | — | none | unused wrapper | |
| L12 | `tcc_steam_lobby_activate_invite_overlay()` W:26 | Steam invite UI for the current lobby | `F:195` | return ignored | `:129-130` `ActivateGameOverlayInviteDialog(current)`; false if none. |

### 4.B P2P packets (legacy `ISteamNetworking`)

| # | Old call | Purpose | Call sites | What the caller consumes | 2.x native behaviour [N2] (`steam_networking.cpp`) |
|---|---|---|---|---|---|
| P1 | `tcc_steam_net_set_auto_accept_p2p_sessions(true)` W:214 | accept P2P session requests | `M:534`, once per process | ignored | `:12-21` sets a flag (default **true**, `:12`). The `P2PSessionRequest_t` handler (`:23-40`) dispatches an unhandled `p2p_session_request` event and, if the flag is on, calls `AcceptP2PSessionWithUser(id)` **only if `id` is a member of `steam_lobby_current` at that moment** (loop over `GetLobbyMemberByIndex`). |
| P2 | `tcc_steam_net_packet_send(user,buf,size,type)` W:206 -> `steam_net_packet_send` (4-arg form) | send one packet | **funnel `M:606` (`net_send_to`)**. Senders: HELLO `M:615,728`; BYE `M:621`; STATE `M:674`; PING `M:680`; PONG `M:752`; ER_PICKS `S:1034`; LEVEL_REQUEST `L:115`; LEVEL_DENY `L:124`; LEVEL_CHUNK `L:177` | `type` = raw consts (4.C). **Only `L:177` consumes the bool** (false -> stop this transfer's burst, resend the same chunk next tick). All other callers ignore it. The wrapper's omitted-type branch (`W:209`) is never taken. | `:90-133`. Type argument accepted only if it equals one of the four `k_EP2PSend*` values (0,1,2,3), else default `steam_net_packet_type` which is **`k_EP2PSendReliable`** (`:73`); `steam_net_packet_set_type` is never called by the game. `size`: `argc>2 ? arg : -1`; `size <= -1 || size > buffer_size` -> whole buffer (`:125`). Channel = arg 4, default 0 (`:127-128`). Result = `SteamNetworking() && SendP2PPacket(target, data, size, type, channel)` (`:131`): false for a missing buffer (`:114-121`), a null interface, or whatever the SDK returns false for (G10). |
| P3 | `tcc_steam_net_packet_receive()` W:202 | dequeue the next packet | `M:693` (loop, max 128/tick) | bool | `:144-168` channel arg default 0; `IsP2PPacketAvailable(&size, ch)` then `malloc(size)` (exact) then `ReadP2PPacket` into a static "current packet" (previous one freed). |
| P4 | `tcc_steam_net_packet_get_sender_id()` W:194 | who sent it | `M:695` | numeric used as `string()` key and compared with `==`; must be a lobby member | `:195-199` `VALUE_INT64`, `steam_net_packet_sender.ConvertToUint64()`. |
| P5 | `tcc_steam_net_packet_get_size()` W:198 | size | `M:696` | `net_finite`, `1..8448` | `:171-175` size of the last read packet. |
| P6 | `tcc_steam_net_packet_get_data(buf)` W:190 | copy payload | `M:705` | return ignored; size re-checked at `M:706` | `:177-193` `BufferWriteContent(buf, 0, data, size, true)`: written at **offset 0**, buffer **grown if needed** (trailing `true`; runner API, not in repo [GM]), seek position unchanged. |
| P7 | `tcc_steam_net_close_p2p_session(id)` W:186 | free the session | `M:389` (every member on leave), `M:820` (`net_remove_player`: BYE, left, 10 s timeout, refresh prune) | ignored | `:51-58` `CloseP2PSessionWithUser`. |

Not wrapped, not used: `steam_net_accept_p2p_session`, `steam_net_packet_set_type` (grep: no uses outside `W`).

### 4.C Raw constants (not wrapped; all six absent from 3.0 [R] consumer audit, 0 hits in `Steamworks_API.gml` and in the 3.0 `Steamworks.yy`)

| Identifier | Old value | Used at | Notes |
|---|---|---|---|
| `steam_lobby_type_friends_only` | 1 | `M:437` | 3.0 candidate: `SteamMatchmakingLobbyType.FriendsOnly` = 1 (`API:1522-1527`) |
| `steam_net_packet_type_unreliable` | 0 (`k_EP2PSendUnreliable`) | `M:607` | 3.0 `SteamNetworkingSendFlags.Unreliable` = 0 (`API:1622-1632`) **but not equivalent** (G5) |
| `steam_net_packet_type_reliable` | 2 (`k_EP2PSendReliable`) | `M:607` | 3.0 `SteamNetworkingSendFlags.Reliable` = **8** (different numeric space) **and not equivalent** (G5) |
| `steam_user_avatar_size_medium` | 1 | `F:71` (also `o_profilepicture/Create_0.gml:36`) | 3.0 has per-size functions (`steam_friends_get_medium_friend_avatar`, `API:13371`) |
| `ov_friends` | 0 | `F:196` | no constant in 3.0; `steam_friends_activate_game_overlay` is a native with no wrapper (`API:12474`); the dialog-name enum was not looked up [UNV] |
| `ugc_result_success` | 1 | `M:1142`; also `scr_workshopER.gml:347,360,445,451,481`, `scr_level_document.gml:775,925`, `o_workshopERloading/Other_69.gml:6`, `o_customlevelsbrowser/Other_69.gml:10,95`, `o_publishworkshopchallenge/Other_69.gml:13,45`, `o_customlevelworkshopbuttonplay/Other_69.gml:6`, `o_playmostrecentlevelCL/Mouse_4.gml:5`, `o_workshoplevelselectbutton/Other_69.gml:4` | 3.0 result structs carry `result` typed `SteamApiResult` (`Ok = 1`, `API:314-320`) |

(`identifiers.json` omits `ugc_result_success` and `ov_friends` entirely; treat it as incomplete for raw constants.)

### 4.D Identity, social, presence, overlay, init/pump

| # | Old call | Purpose | Call sites | What the caller consumes | 2.x native behaviour [N2] |
|---|---|---|---|---|---|
| I1 | `tcc_steam_initialised()` W:102 | gate everything | `M:318, 406, 446, 530, 1161`; `F:10, 119, 134, 294`; `scr_rich_presence.gml:8`; `FS/Other_69.gml:3`; `o_title/Create_0.gml:17, 24` | bool; default false | |
| I2 | `tcc_steam_update()` W:310 -> `steam_update` | **event pump** | `FS/Step_0.gml:4` (once per sim tick, `platform_steam()` guard) | none | `steam_misc.cpp:39-44` `steam_gml_update`: `SteamAPI_RunCallbacks()` + lobby-chat housekeeping. Events it triggers are *queued* (`CreateAsyncEventWithDSMap`, `gml_glue.h:25`). |
| I3 | `tcc_steam_get_user_steam_id()` W:86 | own id (cached in `net_my_steam_id`; used for owner compare, member list, sid text `S:93`) | `M:433, 450, 531, 1075` | int64; default `int64(0)` = unknown | |
| I4 | `tcc_steam_get_persona_name()` W:74 | own display name | `M:198` (HELLO), `M:486` (`host_name`), `S:392` (descriptor `name`) | string | |
| I5 | `tcc_steam_get_user_persona_name_sync(id)` W:18 | name of a peer/member when no HELLO yet | `M:715, 740`; `F:267` | string; default `""` | `steam_user.cpp:186-192` returns `GetFriendPersonaName(user)` with **no** `RequestUserInformation`; what Steam returns for an unknown user is not documented in the repo [UNV] |
| I6 | `tcc_steam_user_set_played_with(id)` W:38 | Steam "recently played with" | `M:805` | ignored | |
| I7 | `tcc_steam_set_rich_presence(k,v)` W:226 | group keys + `steam_display` family | `M:1167, 1168, 1170, 1171`; `scr_rich_presence.gml` | ignored | |
| I8 | `tcc_steam_get_friends_game_info()` W:14 | friends running this app | `F:12` | array of structs `{friendId, gameId, lobbyId, name}`; default `[]` | `steam_user.cpp:116-145` (3.13 above) |
| I9 | `tcc_steam_get_app_id()` W:66 | match `gameId`; demo gate 1749610 | `F:11`; `S:568`; `o_title/Create_0.gml:28`; ~40 other files | numeric compared with `==`/`!=` | default `false` (== 0) |
| I10 | `tcc_steam_get_friend_rich_presence(id,key)` W:10 | friend status line | `F:35` (`steam_display`), `F:43` (`level, boss, challengename, levelname`) | string; default `""`; no prior request is ever made | |
| I11 | `tcc_steam_get_user_avatar(id,size)` W:78 | avatar | `F:71` | **`>0` = image handle ready; `-1` = pending (arrives as `avatar_image_loaded`)**; default `-1` | |
| I12 | `tcc_steam_image_get_size(h)` W:94 | dimensions | `F:52` | `[w,h]` array or `undefined`; rejects `<=0` or `>512` | |
| I13 | `tcc_steam_image_get_rgba(h,buf,bytes)` W:90 | pixels | `F:57` | bool; caller allocated `w*h*4` | |
| I14 | `tcc_steam_is_overlay_enabled()` W:22 | enable the Steam Friends button | `F:141` | bool | |
| I15 | `tcc_steam_activate_overlay(ov_friends)` W:2 | open Steam friends | `F:196` | ignored | |
| I16 | `tcc_steam_activate_overlay_user("steamid", id)` W:6 | open a profile | `F:197` | ignored; 2nd arg int64 `friendId` | |

### 4.E UGC used to fetch the host's Workshop levels (`S`, plus callers elsewhere)

| # | Old call | Call sites (online code) | What the caller consumes |
|---|---|---|---|
| U1 | `tcc_steam_ugc_get_item_update_info(file, ds_map)` W:242 | `S:879` | **ds_map out-param**, keys `is_installed`, `is_downloading`, `is_download_pending`, compared `== 1` / `!= 1` |
| U2 | `tcc_steam_ugc_get_item_install_info(file, ds_map)` W:238 | `S:884` | ds_map out-param, key `folder` (string) |
| U3 | `tcc_steam_ugc_get_subscribed_items(ds_list)` W:250 | `S:912, 995` | ds_list out-param of ids, compared with `==` to `file` |
| U4 | `tcc_steam_ugc_subscribe_item(file)` W:302 | `S:906, 915, 999` | return ignored; result arrives as global event `ugc_subscribe_item` |
| U5 | `tcc_steam_ugc_unsubscribe_item(file)` W:306 | `S:927` | ignored |

The same wrappers have many callers outside the online code (`scr_workshopER.gml:13,19,182,199,225,319`, `scr_workshopchallenge.gml:113,157`, `o_customlevelsbrowser/{Step_0,Create_0,Other_69}`, `o_workshopERloading/Step_0.gml:30,37`, `o_workshopchallengecreator/Create_0.gml:24,37`, `o_workshopchallengesplay/Mouse_4.gml:11,17`, `o_showsubscribedlevels/Draw_73.gml:11`, `o_publishworkshopchallenge/Create_0.gml:91`): a signature change for U1-U5 (3.0 returns structs/arrays instead of filling ds_map/ds_list, and takes a callback) is a project-wide change, not an `S`-local one.

### 4.F Async events consumed

Listed with their 2.x encodings in 2.12 (`lobby_created`, `lobby_joined`, `lobby_chat_update`, `lobby_join_requested`, `avatar_image_loaded`, `ugc_subscribe_item`). Consumers: `NM/Other_69.gml:3` handles all of them; `FS/Other_69.gml:3-6` handles only `lobby_created`/`lobby_joined`, only when `o_networkmanager` does not exist and `net_create_pending` is defined; `o_title/Other_69.gml:2` merely notes that join requests are the manager's job.

### 4.G Candidate 3.0 pointers (verified to exist in `Steamworks_API.gml`; a mapping, not a design)

| Old | 3.0 candidate (`API` line) | What is different |
|---|---|---|
| lobby create / join / leave | `steam_matchmaking_create_lobby(_lobby_type,_max_members,_callback)` 22797; `steam_matchmaking_join_lobby(_lobby_id,_callback)` 22829; `steam_matchmaking_leave_lobby(_lobby_id)` 22984 | explicit id; create/join have **no `@returns`** and no failure callback on IO failure (G12); the wrapper returns `undefined` if Steam is unavailable |
| owner / members / data / joinable | `..._set_lobby_owner(id,new)` 23005 (Bool); `..._get_lobby_owner(id)` 23029; `..._get_num_lobby_members(id)` 23053; `..._get_lobby_member_by_index(id,i)` 23074 (docs: same id as the preceding count); `..._set_lobby_data(id,k,v)` 23104 (Bool); `..._get_lobby_data(id,k)` 23135 (String); `..._set_lobby_joinable(_steam_id_lobby,_joinable)` 23420 (Bool) | every call takes the lobby id |
| lobby events | `steam_matchmaking_set_callback_lobby_chat_update(cb)` 22695 -> `SteamMatchmakingLobbyChatUpdate {lobby_id, user_changed_id, making_change_id, chat_member_state_change}` (3797); bit enum `SteamMatchmakingChatMemberStateChange {Entered 1, Left 2, Disconnected 4, Kicked 8, Banned 16}` (1548-1554) matches the `2\|4\|8\|16` mask bit for bit; `steam_friends_set_callback_game_lobby_join_requested(cb)` 13832 -> `SteamFriendsGameLobbyJoinRequested {steam_id_friend, steam_id_lobby}` (1935); create reply `SteamMatchmakingLobbyCreated {result, lobby_id}` (3731); join reply `SteamMatchmakingLobbyEnter {lobby_id, chat_permissions, locked, response}` (3747), `response` enum `SteamMatchmakingChatRoomEnterResponse` (1557-1572) | `success` bool becomes `result` (`SteamApiResult.Ok`=1) / `response` |
| invite overlay | `steam_friends_activate_game_overlay_invite_dialog(_steam_id_lobby)` 12480 | takes the lobby id |
| overlay / profile | `steam_friends_activate_game_overlay` (native, no wrapper, 12474); `steam_friends_activate_game_overlay_to_user(_dialog,_steam_id)` 12525 | `ov_friends` constant gone |
| P2P replacement | `steam_networking_messages_set_callback_session_request` 23618; `..._set_callback_session_failed` 23643; `..._send_message_to_user(id,buf,flags,remote_channel,offset,count)` 23674 (Real); `..._receive_messages_on_channel(local_channel,out_buf,count)` 23733 (array of `SteamNetworkingMessage`, struct 3970); `..._accept_session_with_user` 23770; `..._close_session_with_user` 23790; `..._close_channel_with_user` 23811; flags enum `SteamNetworkingSendFlags` 1622-1633 | There is no auto-accept setter and no flush function for Messages (the export list was checked: `steam_networking_sockets_flush_messages_on_connection` exists only for Sockets) |
| friends / presence | `steam_friends_get_friend_count` 13028; `..._get_friend_by_index` 12959; `..._get_friend_game_played(id)` 13098 -> `SteamFriendsFriendGamePlayed {game_id, game_ip_v4, game_port, query_port, lobby_steam_id_64}`; `..._get_friend_persona_name(id)` 13158; `..._get_friend_rich_presence` 13252; `..._request_friend_rich_presence` 13667; `..._set_callback_friend_rich_presence_update` 13857; `..._set_played_with` 13735; native without wrapper: `steam_friends_get_persona_name` 13413, `steam_friends_set_rich_presence` 13751 | there is no `steam_get_friends_game_info` equivalent: enumeration becomes count + by_index + game_played |
| avatars / images | `steam_friends_get_medium_friend_avatar` 13371 (Real); `steam_friends_set_callback_avatar_image_loaded` 12659; `steam_utils_get_image_size` 15611; `steam_utils_get_image_rgba(_image_handle,_dest)` 15587 | |
| own id, app id, overlay flag | `steam_user_get_steam_id()` 14730 (Real, `buffer_u64`); `steam_utils_get_app_id` native 15531; `steam_utils_is_overlay_enabled` native 15650 | |
| init / pump | `steam_api_is_initialized` native 12456; `steam_api_run_callbacks` native 12468 (no GML wrapper in the API file; present as a native extension function) | **`steam_api_run_callbacks` is not called anywhere in the project yet** (grep) |
| UGC | `steam_ugc_subscribe_item(id,cb)` 18342 -> `SteamUgcSubscribeItemResult {result, published_file_id}` (2689); `steam_ugc_unsubscribe_item(id,cb)` 18372; `steam_ugc_get_subscribed_items(max,include_disabled)` 16611 (array); `steam_ugc_get_item_install_info(id)` 16528 -> `SteamUgcItemInstallInfo {size_on_disk, folder, timestamp}`; `steam_ugc_get_item_state(id)` 16559 bitflags `SteamUgcItemState` (783) | no `is_installed/is_downloading/is_download_pending` ds_map; behaviour of `get_item_install_info` for a not-installed item is unverified [UNV] |

---------------------------------------------------------------------------------------------------

## 5. Implicit guarantees the legacy API gave and the code relies on

These are the behaviours nobody wrote down because the old API made them true. Each entry gives: what 2.x did (with evidence), where the game relies on it, what 3.0 actually provides, what goes wrong if it is ignored, and the requirement that results (cross-referenced to section 6). Entries G1-G11 concern the transport; G12-G18 the lobby; G19-G22 the surrounding platform.

### G1. P2P sessions were accepted automatically, but only for users in the live current lobby

* **2.x.** The default is on (`steam_networking.cpp:12`). The `P2PSessionRequest_t` handler accepts a session **only if the requester is a member of `steam_lobby_current` according to Steam at that instant** (`steam_networking.cpp:31-38`: it loops `GetNumLobbyMembers`/`GetLobbyMemberByIndex`); it also dispatches an unhandled `p2p_session_request` event with `user_id` (`:27-29`). The old documentation ("auto-accept session requests coming from players in the same lobby", `old_networking.txt`) is therefore correct, and the session reading's claim that the Steam-level accept was unconditional is wrong (section 8).
* **Relied on.** `M:532-536` turns it on once; the comment says packets are accepted only from lobby members. The game then adds its own per-message filter (`net_lobby_member`, with a forced refresh, `M:698-704`) on top. Nothing in the game ever accepts a session itself.
* **3.0.** No auto-accept exists. A remote first message posts `SteamNetworkingMessagesSessionRequest_t` ([SDK] `isteamnetworkingmessages.h`), delivered to `steam_networking_messages_set_callback_session_request` ([API] 23618) from inside `steam_api_run_callbacks()`. Ignoring it means the request is re-posted periodically while the user keeps sending; whether messages sent before acceptance are held or dropped is **not stated** in the header [UNV]. Sending to the user implicitly accepts.
* **If ignored.** Members never see each other's STATE/PING until their own first send implicitly accepts (HELLO and PING broadcasts make that happen within <= 2 s for every pair, but anything sent earlier may be lost [UNV]). Accepting *everyone* would let any Steam user open sessions to a player.
* **Requirement.** Register the callback before the first create/join and never clear it; accept iff the requester is a **live** member of the lobby we are in (query Steam, as 2.x did, not the 30-tick cache). The per-message `net_lobby_member` gate and its forced refresh must **stay** in the receive loop: acceptance is per user and persists, so a peer who has left the lobby keeps an open session, and the callback can fire before membership has refreshed. (INV-A6)

### G2. A session was opened implicitly by the first send

* **2.x.** No connect call exists; the first `steam_net_packet_send` creates the session and "may be delayed as the NAT-traversal code runs" ([SDK] `isteamnetworking.h:150-151`). First reliable sends are queued, not lost.
* **Relied on.** The joiner broadcasts HELLO `reply=0` immediately after the join validates (`M:1097`) to every current member, with no prior handshake; replies are unicast the same way.
* **3.0.** Same ("If we don't already have a session with that user, a session is implicitly created. There might be some handshaking... There is no notification when the operation succeeds. (You should have the peer send a reply for this purpose.)", [SDK] `isteamnetworkingmessages.h`). Unreliable messages sent during handshaking are batched until the connection is open **unless** `NoDelay` is used, in which case they are dropped ([SDK] `steamnetworkingtypes.h:943-954, 980-996`).
* **Requirement.** Never use the `NoDelay` flags (4, 5): the first STATE/PING/HELLO to a new peer would be discarded. (INV-A4)

### G3. Closing a session and sending later reopens it; the 10 s timeout path depends on that

* **2.x.** `CloseP2PSessionWithUser` frees resources; "if the remote user tries to send data to you again, another P2PSessionRequest_t callback will be posted" ([SDK] `isteamnetworking.h:176-177`). The game closes a session in exactly two places: `net_leave_lobby` for every member (`M:389`) and `net_remove_player` (`M:820`), reached by BYE (`M:734`), chat-update leave (`M:1121`), the 10 s silence timeout (`M:870-871`) and member-refresh pruning (`M:514`). It is **not** closed on lobby-lost, kicked, failed-join or discarded-reply paths (`M:572, 1116-1119, 1066-1089, 462-465`).
* **Relied on.** A peer removed by timeout is still in the lobby; PINGs keep being broadcast to every member every 2 s, so contact resumes and the peer re-registers from its next STATE/PING ("A peer returning after a timeout can recover from its next valid state", `M:713`). That requires the pair's sends to work again and the receiver to accept again.
* **3.0.** `steam_networking_messages_close_session_with_user` ([API] 23790); "if the remote host sends another message afterwards, a new session request arrives through the callback". Sessions unused for a few minutes time out by themselves with no callback ([SDK] `isteamnetworkingmessages.h`).
* **Requirement.** Close on the same triggers as 2.x and no others (INV-A7); every close must be survivable by the next send or the next incoming request (G1, G4).

### G4. A broken session was restarted silently on the next send

* **2.x.** `P2PSessionConnectFail_t` "all queued packets unsent at this point will be dropped; further attempts to send will retry making the connection" ([SDK] `isteamnetworking.h:319-322`). The 2.x extension has **no handler for it** (grep of the whole HEAD C++ tree: no `P2PSessionConnectFail`), so the game never learned of connect failures and never needed to react: the next send simply retried.
* **3.0.** Without a flag a send to a session that "failed or was closed by the peer" returns `k_EResultNoConnection` and **sends nothing** until you call `CloseSessionWithUser` or "repeat the call with `k_nSteamNetworkingSend_AutoRestartBrokenSession`" ([SDK] `isteamnetworkingmessages.h` return list; flag comment `steamnetworkingtypes.h:1029-1048`). `SteamNetworkingSendFlags.AutoRestartBrokenSession` = 32 exists in [API] 1622-1633. There is also a peer-initiated variant of this: when one side calls `close_session_with_user` (BYE, timeout, prune) the *other* side's session is "proactively closed by the peer" and its next send fails the same way.
* **If ignored.** After any close/timeout/disruption one side's sends silently stop (the game ignores the send result everywhere except level chunks) and the pair can stay mutually invisible until someone leaves and rejoins the lobby, even though both remain lobby members.
* **Requirement.** Every send carries `AutoRestartBrokenSession`. Optionally also handle `session_failed` (diagnostics only; 2.x ignored the equivalent). (INV-A4)
* **Not a regression.** Auto-restarting a session after a disruption can lose an unknown set of in-flight reliable messages ([SDK] `steamnetworkingtypes.h:1029-1048`: "some of those messages will not have been delivered, and it is in general not possible to know which"). Legacy did the same: "all queued packets unsent at this point will be dropped" (`isteamnetworking.h:320`). So `9 | 32` is legacy-equivalent. For level share, the only thing that catches the resulting gap is the exact-offset check `_offset != _in.received` at `L:224`, which aborts the transfer and denies the md5 for 60 s.

### G5. Sends were never Nagle-delayed

* **2.x.** `k_EP2PSendReliable` is immediate; Nagle was a separate opt-in type `k_EP2PSendReliableWithBuffering` ([SDK] `isteamnetworking.h:48-56`), which the game never used. The game's raw constants map exactly: unreliable 0 -> `k_EP2PSendUnreliable`, reliable 2 -> `k_EP2PSendReliable` ([N2] `steam_networking.cpp:65-71, 97-110`).
* **3.0.** The SDK states the numbers are **not** equivalent: `Unreliable` = 0: "Migration note: This is not exactly the same as k_EP2PSendUnreliable! You probably want ... UnreliableNoNagle" (`steamnetworkingtypes.h:943-954`); `Reliable` = 8: "Migration note: This is NOT the same as k_EP2PSendReliable, it's more like k_EP2PSendReliableWithBuffering" (`:998-1007`); `ReliableNoNagle` = 9: "Migration note: This is equivalent to k_EP2PSendReliable" (`:1009-1012`). By default Nagle batches partial packets until a timer expires (`:956-978`). `FlushMessagesToUser` is not exposed to GML for Messages (see 4.G).
* **Relied on.** 60 Hz STATE (one packet per tick per peer), PONG round-trip timing (RTT shown in the Friends panel), level-chunk throughput (up to 16 x 8 KiB per tick) and the 128-packet-per-tick budget all assume immediate sends.
* **Requirement.** Reliable -> `ReliableNoNagle` (9); unreliable -> `UnreliableNoNagle` (1); OR'd with 32 (G4). (INV-A4)

### G6. How reliability, size and channel were chosen

* Reliability is **a boolean per send call**: `net_send_to(member, size, reliable)` (`M:605-608`) maps it to the raw constants; there is no default, no `set_type`, and the wrapper's 4th argument is always supplied (`W:206-213`). If the type were omitted 2.x would have sent **reliable** (`steam_networking.cpp:73`). Reliable classes: HELLO, BYE, ER_PICKS, LEVEL_REQUEST/CHUNK/DENY. Unreliable: STATE, PING, PONG.
* Size is **explicit**: the shared `net_send_buffer` is a grow buffer larger than the packet, and 2.x used the explicit `size` argument (`steam_networking.cpp:95, 125`). 3.0 `steam_networking_messages_send_message_to_user(id, buf, flags, channel, offset, count)` with `offset`/`count` omitted sends `length - offset` = **the whole buffer, stale tail included** ([N3] `gm_steam_networking_messages.cpp:123-146`); `count == 0` returns `InvalidParam`. The wrapper passes the whole buffer address and `buffer_get_size` ([API] 23687).
* Channel is always 0 (send argument 4 omitted; receive argument omitted).
* **Requirement.** Pass `offset = 0` and `count = size` on every send; channel 0 on both ends. (INV-A3, INV-A8)

### G7. Ordering

* **Guaranteed (both APIs).** Reliable messages to the same peer on the same channel arrive exactly once and in send order ([SDK] `isteamnetworkingmessages.h`: "exactly once, and in the same order that they were sent"). Level transfer depends on it (`L:215,222`); it is the reason every reliable packet must use the same channel.
* **Not guaranteed (both APIs).** "NO other order guarantees exist! In particular, unreliable messages may be dropped, received out of order with respect to each other **and with respect to reliable data**, or may be received multiple times." Consequences the game already tolerates and a port must not make worse:
  * STATE or PING can arrive **before** HELLO: handled by lazy registration with a persona-name lookup (`M:714-715, 739-740`).
  * A stale STATE or PING can arrive **after** BYE and re-register the peer. The record then lives until the next membership refresh (<= 0.5 s, or the forced refresh on the next unknown-sender packet) prunes it or the 10 s timeout removes it. That is existing behaviour (a short "ghost resurrection"), not a bug to fix silently.
  * Duplicate/late unreliable STATE is filtered by the 16-bit sequence rule; duplicate PING is harmless; duplicate PONG only skews RTT.
  * PING (unreliable) arriving before ER_PICKS (reliable) or vice versa: ER_PICKS are idempotent (first pick wins) and re-sent whenever a peer's PING sid changes.
* **Not guaranteed across peers.** There is no ordering between two senders; ER_PICKS "first pick wins" is per receiver arrival order.

### G8. Packet-at-a-time receive, oversize skipped individually, remainder left queued

* **2.x.** `steam_net_packet_receive` returns one packet; `get_sender_id`, `get_size`, `get_data` read the "current packet" statics ([N2] `steam_networking.cpp:139-199`). The packet is allocated at its exact size and read whole (`:157-158`), so a local buffer can never truncate or drop it; the payload is then copied to **offset 0** of the game's buffer with growth (`:184`), position untouched.
* **Relied on.** The loop (`M:693-706`) rejects an oversize packet (`> 8448`) or a non-member **individually** (`continue`) after it has been dequeued; every other peer's packets are unaffected. A budget of 128 dequeues per tick; whatever is not dequeued **stays queued inside Steam** for the next tick. The `++_processed` precedes the filters, so rejected packets also consume budget. All decoders and `L:194-234` read from absolute offset 0.
* **3.0.** `receive_messages_on_channel(local_channel, out_buffer, count)` fills one buffer with up to `count` messages packed **back to back from offset 0**, returns an array of `{offset, size, steam_id_remote, conn, channel, flags, ...}` and **never grows the buffer**. If the next message does not fit in `out_data.length()` (= `buffer_get_size`) it **releases that and every remaining fetched message** and sets "output buffer exhausted" ([N3] `gm_steam_networking_messages.cpp:181-225`). Released messages are gone: for reliable data that is permanent loss. On receive "only the Reliable bit [of flags] is valid" ([SDK] `steamnetworkingtypes.h:899-900`).
* **If ignored.** (a) With the current 1024-byte `net_recv_buffer` (`M:302`) the very first 8236-byte LEVEL_CHUNK is dropped and the stream breaks; (b) with a big `count`, one oversized message from peer A discards peer B's reliable HELLO/BYE/ER_PICKS fetched in the same call; (c) decoders given `msg.offset` ranges but reading at 0 parse the wrong bytes.
* **Requirement / options.** The 2.x semantics to reproduce: an oversized or non-member packet is consumed, counts against the 128 budget, is skipped, and the loop **continues with the next packet in the same tick**. A naive port of that loop breaks on one point: with `count = 1` and a receive buffer smaller than the next message, the native code releases that message, sets the last-error string "output buffer exhausted", and returns an **empty array**, which is indistinguishable from "queue empty" ([N3] `gm_steam_networking_messages.cpp:181-199`). A loop that stops on an empty array would end the tick at the first oversized message, where 2.x carried on to the remaining 127; one member sending one oversized message per tick could starve every other member's messages. Two ways to avoid it:
  * **(a) Make exhaustion impossible.** Size the receive buffer to at least the largest message Steam will deliver, so a fetched message always fits and the size check at `M:697` drops oversized messages individually in GML exactly as before. The receive-side bound is `k_ESteamNetworkingConfig_RecvMaxMessageSize`, default 512 KiB = 524288 bytes; a peer attempting to send more has its connection closed ([SDK] `steamnetworkingtypes.h:1161-1167`). The 3.0 native sources set no networking config (grep for `SetConfigValue` / `RecvMaxMessageSize` in `scratchpad/gmext/.../src/*.cpp`: no hits), so the default should apply [runtime value unverified]. A fixed receive buffer of >= 524288 bytes with `count = 1` inside the existing 128-iteration loop therefore reproduces 2.x per-message behaviour. (Keep the in-GML bound of 8448 for processing.)
  * **(b) Tell "dropped" from "empty".** `steam_api_last_error()` ([API] 12453, native with no wrapper; `extensions/Steamworks/Steamworks.yy:21`; documented as "the last error that occurred") is cleared on entry to every guarded native call (`STEAM_GUARD_RET` -> `steam_guard_failed()` -> `steam_clear_last_error()`, `GMSteamworks.h:59-66`) and set to "...output buffer exhausted." when a message is dropped, so a non-empty last error after an empty array means "a message was dropped, keep looping". This depends on matching a native message string and is the weaker option.
  A batched design (`count > 1`) is acceptable only if it keeps INV-A1 (no cross-peer loss) and INV-A2 (decoders see offset 0, or every decoder is audited). (INV-A1, INV-A2)

### G9. Sender id: authenticated, 64-bit integer, not on the wire

* **2.x.** `steam_net_packet_get_sender_id()` returns `VALUE_INT64` ([N2] `steam_networking.cpp:195-199`). No packet carries a sender field (the only ids on any wire are decimal strings in the JSON descriptor and ER_PICKS keys). All lobby getters also return `VALUE_INT64` (`steam_matchmaking.cpp:16-17, 53, 114`), and all event ids are `DsMapAddInt64` (`gml_glue.h:35-37`).
* **Relied on.** `string(sender)` is the key of `net_players`, `net_members`, `net_avatars`, `net_share_*`; equality `==` is used between values from different sources: lobby member ids, owner id, own id, sender id, friend `lobbyId`, event `lobby_id` (`M:415, 420, 507, 520-522, 1111`; `F:166, 270, 305`); `int64(0)` is the "unknown" sentinel and `-1` the "none" sentinel for lobby ids.
* **3.0.** Ids are **numbers**, not `SteamId` structs: `steam_user_get_steam_id` reads `buffer_u64` ([API] 14730-14740), message `steam_id_remote` is `buffer_read(..., buffer_u64)` ([API] 11929-11960), lobby getters/params are `Real`/UInt64. The `SteamId` struct ([API] 1688) is only the result of `steam_user_decode_steam_id`. Whether GameMaker returns an **int64** from a `buffer_u64` read on every platform is a runtime fact that cannot be checked in this repo [GM]. Individual Steam ids (~7.6e16) exceed 2^53, so a double would corrupt them and `string()` keys would stop matching.
* **Requirement.** Keep ids as 64-bit integers end to end; assert at startup (`is_int64`, 17-digit `string()`), see section 7. (INV-A13)

### G10. Send return value: bool in 2.x, `EResult` number in 3.0

* **2.x.** `Result.val = SteamNetworking() && SendP2PPacket(...)` ([N2] `steam_networking.cpp:131`): false for a missing buffer (`:114-121`), a null interface, or anything the SDK refuses. `L:176-177` assumes "false = reliable queue full, resend the same chunk next tick". That reading is the code author's; neither the 2.x extension (no queue logic) nor the legacy header (`isteamnetworking.h:146-157` only mentions `P2PSessionConnectFail_t`) states that a full queue returns false [UNV]. It is also the only flow control the level-share sender has.
* **3.0.** `std::int32_t` EResult ([N3] `gm_steam_networking_messages.cpp:116-157`): `k_EResultOK` = 1 on success; `k_EResultInvalidParam` for bad offset/count/zero count; `k_EResultNoConnection` for a broken session without the restart flag; `k_EResultLimitExceeded` when "there was already too much data queued to be sent" (`isteamnetworkingsockets.h:258-268`, `SendMessageToConnection`); `k_EResultIgnored` for `NoDelay`; `k_EResultFail` if the interface is unavailable. The GML wrapper returns `undefined` when Steam is unavailable ([API] 23674-23680: `if (!__available__) return;`). The `@returns` text in `docs/networking.js` ("The number of messages returned into your list") is a copy-paste error; the native code is authoritative.
* **If ignored.** Every non-zero result is truthy, so `if (!net_send_to(...)) break;` never fires: on a full queue the sender advances `offset` without having sent the chunk, the receiver sees a gap, aborts and marks the level denied for 60 s.
* **Requirement.** Success is `result == SteamApiResult.Ok` (1) exactly; `undefined` and every other value is failure; only level share depends on it, with the same retry-same-chunk behaviour. (INV-A5)

### G11. Peer loss has no transport signal; detection is lobby events, a 30-tick refresh and a 10 s silence timeout; BYE is best-effort

* **2.x.** No handler for `P2PSessionConnectFail_t` (G4). Loss is detected only by (a) `lobby_chat_update` flags 2/4/8/16 (`M:1110-1125`), (b) the member refresh pruning ghosts not in the lobby (`M:510-516`), (c) `last_update` older than `NET_PEER_TIMEOUT_MS` (`M:870`), (d) a BYE with size 1.
* **BYE is not reliable in practice.** `net_leave_lobby` sends a reliable BYE and in the same call leaves the lobby and closes the session with every member (`M:377-389`); a close issued right after a send need not flush it. The lobby event and the timeout are the real backstops.
* **3.0.** `session_failed` fires only for failures; "There is no notification when a peer proactively closes the session" and "if a session times out due to inactivity, no callbacks will be posted" ([SDK] `isteamnetworkingmessages.h`). So the same three mechanisms remain the only signals.
* **Requirement.** Keep all four detection paths and their constants unchanged; do not rely on `session_failed` for membership. (INV-B6)

### G12. Exactly one reply per create and per join call

* **2.x.** `lobby_created` is dispatched for every create call ([N2] `steam_matchmaking.cpp:484-491`, `success = (m_eResult == k_EResultOK)`), `lobby_joined` for every join call with `success = !failed` (`:407-413`). The game's state machine is built on this: `net_create_pending` and `net_join_pending_id` are cleared **only** by the reply (`M:286`, `M:1023-1024`, `M:1058`), and both block auto-host and queued joins (`M:432, 446-448, 557-564`).
* **3.0.** Create and join return nothing usable. The callback is **not** called on IO failure: `steam_async::CallResult<..>` has `ReportIoFailure = false` by default, so `on_result` with `io_failure` just deletes the handle ([N3] `steam_async_common.h`; used with the default at `gm_steam_matchmaking.cpp:195, 213`). A dispatch failure (`k_uAPICallInvalid`) sets a last-error string and returns without ever calling back (`:189-193, 207-211`). The GML wrapper returns `undefined` if Steam is unavailable and raises `show_error(..., true)` if the callback is not callable ([API] 22797-22850).
* **If ignored.** After a network blip during creation, `net_create_pending` stays true forever: no lobby is ever created again, joins never start, and the Friends panel shows "connecting" (`F:121`) indefinitely.
* **Requirement.** Every create/join must resolve by its callback or a watchdog; a watchdog expiry runs the failed-reply path, and a **late** reply for an expired attempt must be recognised (per-attempt token) and treated as an unwanted reply (leave the lobby it names). The old `if (!tcc_steam_lobby_create(...))` immediate-failure test must not be carried over (it would read `undefined`/0 as failure and retry every 15 s, creating lobbies). (INV-A10)

### G13. The implicit "current lobby", including its side effects

* **2.x.** One extension-wide `CSteamID steam_lobby_current` ([N2] `steam_glue.cpp:7`). Every lobby call uses it and no-ops with an inert value if invalid (4.A). It is set from the **reply** of create and join even when the call failed (`steam_matchmaking.cpp:408, 486`). `lobby_create` and list-join **leave the previous current lobby first** (`:499, 420`). `lobby_leave` leaves and clears it (`:19-27`).
* **Relied on.** The game stores only `global.net_lobby_id` (from the reply; for join "Steam may change the instance bits of the ID" so the reply id overwrites the requested one, `M:1072-1074`) and never passes an id. It relies on the leave side effect for `net_discard_lobby_reply` ("The extension has already selected this created lobby", `M:1029-1030`), calls `lobby_leave()` to undo an unexpected reply (`M:462-465`), and relies on `member_count == 0` for a lobby it is no longer in (G17). The reset paths that do **not** call leave (`M:572, 1116-1119`) are safe in 2.x because Steam already removed us, and because the next `lobby_create` would leave the stale lobby anyway.
* **3.0.** Every `steam_matchmaking_*` call takes an explicit lobby id; there is no current lobby; multiple lobbies can be joined at once; nothing leaves implicitly ([API] 22984-23135, 23420; docs: the id passed to `get_lobby_member_by_index` must equal the one passed to the preceding `get_num_lobby_members`).
* **Requirement.** Use `global.net_lobby_id` for every call and never when it is `-1` or `0` (INV-A9); a discarded or unwanted reply is left **by the id in that reply**; every path that forgets a lobby the user may still be in must leave it by id (the implicit leave-before-create is gone). `lobby_chat_update` and every reply id comparison keep using the reply-derived id.

### G14. What the reply fields actually meant

| Field | Meaning in 2.x | Consequence |
|---|---|---|
| `lobby_created.success` | `m_eResult == k_EResultOK` | 3.0 `result == SteamApiResult.Ok` |
| `lobby_joined.success` | **IO success only**, `!failed` (`steam_matchmaking.cpp:411`); not the enter response | The game revalidates (members > 0, `game_name`, `proto`). 3.0's `response` (`Success 1, DoesntExist 2, NotAllowed 3, Full 4, Error 5, Banned 6, ...`) can distinguish a full lobby, but the post-join validation (`M:1072-1090`) must stay as the fallback. |
| `lobby_id` in replies and events | int64, the lobby actually entered | keep overwriting `net_lobby_id` from the reply |
| `lobby_chat_update.user_id` | `m_ulSteamIDUserChanged` (`steam_lobby_chat.cpp:186`) | 3.0 `user_changed_id`; `making_change_id` is the old `change_id` |
| `lobby_chat_update.change_flags` | raw bitfield as a double | 3.0 enum `Entered 1 / Left 2 / Disconnected 4 / Kicked 8 / Banned 16` matches the mask `2 \| 4 \| 8 \| 16` (`M:1115`) one to one |
| `lobby_join_requested` | `lobby_id` (+`friend_id`, ignored) | 3.0 `steam_id_lobby` (+`steam_id_friend`) |
| `avatar_image_loaded.success` | not read by the game | |

### G15. Callback delivery: queued Async events vs synchronous callbacks

* **2.x.** `steam_update()` = `SteamAPI_RunCallbacks()` ([N2] `steam_misc.cpp:39-44`); each Steam callback builds a ds_map and calls `CreateAsyncEventWithDSMap(map, 69)` (`gml_glue.h:24-26`), i.e. the event is **queued** and performed later in the frame's Async stage, in **every** instance that has an `Other_69`, including on render-only frames (the handler is not behind `timing_instance_step()`). Handlers therefore never run inside `net_session_update`/`net_tick`; they run after Step. The pump is in `FS/Step_0.gml:4`, behind the timing guard, so callbacks are pumped once per simulation tick. All lobby replies and events are delivered only when `steam_update` runs, so a stalled pump delays all of them.
* **Relied on.** Handlers mutate `global.net_*` freely (`net_handle_async_steam`) with no thought for being re-entered from inside `net_tick`; `FS/Other_69.gml:1-6` settles replies when the manager instance was destroyed (menus/editor).
* **3.0.** Callbacks run **synchronously inside `steam_api_run_callbacks()`**, on whatever event calls it ([DOC3] `getting_started.md:41-45, 59`), and a registered callback is a GML function handle (`__ext_core_function_register`, [API] 22797-22850). A callback that is a method bound to a destroyed instance is a hazard; whether registrations survive `game_restart` is **not verified** [UNV]. `steam_api_run_callbacks` is not called anywhere in the project yet.
* **Requirement.** One pump call per simulation tick at a place that cannot be nested inside `net_tick`/`net_session_update` (before `net_session_update()` in `NM/Step_0` or at the end of Step, decided once); callbacks are named global functions that touch only `global.*`; they need no manager instance; re-registration after `game_restart` is explicit and idempotent. (INV-A11)

### G16. Lobby data semantics

Owner-only writes (Steam rule); the game never sees a `lobby_data_update` and instead **polls** `session` every 15 ticks (and every tick while a follow job exists, `S:526`), so reads must reflect the owner's latest write without an event; values are strings; `get` returns `""` for an absent key (never an error); `set` and `set_joinable` return bool and the game's write-through cache is updated **only on true**, so a false return means "try again at the next publish/refresh"; descriptor <= 8000 bytes (the code assumes Steam's 8 KB value limit; key limit 255 bytes, [SDK] `isteammatchmaking.h:51`). The cache is cleared on every `net_become_host` so a new owner re-writes everything. (INV-B12)

### G17. `member_count <= 0` means "I am no longer in this lobby"

Lobby loss (kicked, lobby vanished, offline) is detected by `get_member_count() <= 0` at the 30-tick refresh (`M:570`) and after a join (`M:1079`), not by an event. 2.x returns 0 for a lobby it is not in (`GetNumLobbyMembers` of an invalid/left id). 3.0 `steam_matchmaking_get_num_lobby_members(id)` wraps the same SDK call, but must be called with the lobby id we believe we are in; passing a stale or `-1` id gives 0 for the wrong reason. (INV-A9, INV-B7)

### G18. Ownership handover and migration

The leaving owner explicitly hands the lobby to the longest-standing member before leaving (`M:378-387`); Steam also migrates ownership on a crash and the game notices by polling `get_owner_id` every 30 ticks (`M:576-587`), not by event. Both rely on `set_owner`/`get_owner` working on the **current lobby**; 3.0 needs the id. `set_owner` followed immediately by `leave` is existing behaviour and unchanged.

### G19. Platform gating and inert defaults

Every wrapper returns a typed inert default when `!(platform_steam() && steam_initialised())`, so the Steam-free half never faults. Defaults matter: `false` for member count/id, `int64(0)` for ids, `""` for strings, `[]` for the friends array, `-1` for avatars, `undefined` for image size (`W`). The 3.0 wrappers behave differently (they return `undefined`), and the init check changes from `steam_initialised()` to `steam_api_is_initialized()` (native, no wrapper, [API] 12456). `tools/check_port.py:79` only forbids unguarded raw calls for the prefixes `steam_inventory_`, `steam_ugc_`, `steam_get_achievement`, `steam_set_achievement`, `steam_upload_score`, `steam_initialised`; it does **not** cover `steam_lobby_*`, `steam_net_*`, `steam_matchmaking_*`, `steam_networking_*`, `steam_friends_*`, so those prefixes are currently unenforced. (INV-A12)

### G20. Names for peers that sent STATE/PING before HELLO

`tcc_steam_get_user_persona_name_sync(id)` returns Steam's name for any id without requesting it (`steam_user.cpp:186-192`); what Steam returns when the user's info is not yet cached is not documented in the repo [UNV]. The result goes through `net_clean_name`; HELLO later overwrites it.

### G21. Friends list data comes from Steam's local cache

`net_friends_list` assumes the friends array carries each friend's current `lobbyId` and `gameId` without any request, and `net_presence_text` assumes `get_friend_rich_presence` already has data: the project **never** calls `steam_request_friend_rich_presence`. 3.0's equivalents are per-friend `get_friend_game_played` (struct with `lobby_steam_id_64`) and `get_friend_rich_presence`; a port must keep the "no network request" behaviour and may add a request, which would change what the panel shows. The friend's `lobbyId` is compared by value with `net_lobby_id` (`F:166, 305`), valid only because `net_lobby_id` holds the reply id.

### G22. Shared buffers, reuse, and in-loop sends

The one `net_send_buffer` is overwritten many times per tick (STATE then PING; PONG and HELLO replies inside the receive loop `M:728, 752`; `net_er_peer_joined_run` inside it; up to 16 LEVEL_CHUNKs). That is safe only if each send has consumed its bytes before the next write. 2.x copied the buffer inside the call (`BufferGetContent` then `YYFree`, `steam_networking.cpp:112-133`). In 3.0 the extension passes a pointer to the buffer memory to `SendMessageToUser` synchronously ([N3] `gm_steam_networking_messages.cpp:147-156`); the SDK's own wording implies the plain send copies the payload ("Send one or more messages **without copying** the message payload" for the zero-copy variant, `isteamnetworkingsockets.h:270`), but the Messages header does not say so explicitly [SDK, implied]. The same function resizes the shared buffer (`L:168`), so any code holding `buffer_get_address` across a send would go stale (the wrapper re-reads the address per call). (INV-A3)

---------------------------------------------------------------------------------------------------

## 6. Invariants a rewrite must preserve

Hard requirements, each with a way to check it. IDs are written `INV-A1` etc. here and in other sections; inline shorthand such as "A5" means the same invariant. "A" invariants are about the port mechanics (they exist because the legacy API made something true that 3.0 does not). "B" invariants are gameplay-visible behaviour that must be identical. Numbers are the current values; a change to any of them is a behaviour change.

### Group A: port mechanics

| ID | Requirement | Check |
|---|---|---|
| **INV-A1** | **No cross-peer message loss.** A message that is oversized (> 8448), from a non-member, or malformed is dropped **individually** and never causes loss of any other message. Everything not dequeued within the 128-per-tick budget stays queued in Steam. (G8) *Options that satisfy it:* (a) `count = 1` into a receive buffer of >= 524288 bytes (Steam's default receive bound, so exhaustion cannot occur) inside the existing 128-iteration loop, payload at offset 0, with the 8448 bound enforced in GML; or (b) discriminate "dropped" from "empty" with `steam_api_last_error()`. A loop that stops on an empty array **violates** this (an oversized message would end the tick, G8). | Synthetic adapter test: queue `[valid STATE from A, 9000-byte message from B, reliable HELLO from C]` and `[oversized message, valid STATE, valid PING]` for the same tick; **all valid messages must be processed in that same tick** and the oversized one counted against the 128 budget. Real test: A sends 20 KB garbage while B and C exchange HELLO/BYE. |
| **INV-A2** | **Decoders see the packet at offset 0.** Either copy each message to offset 0 of a scratch buffer (decoders and the self-check stay unchanged) or add the offset to every site below. Sites that assume offset 0: `M:707` (`buffer_peek(_buf,0,...)`); `M:155,156,160` (STATE); `M:206,207,209` (HELLO); `M:230,231,237` (PING); `M:756` (PONG stamp at 1); `S:1039,1041` (ER_PICKS); `L:194` (`net_packet_string_end(.,1,.)`), `L:196` (`buffer_peek(.,1,buffer_string)`), `L:212` (u32 @34), `L:213` (u32 @38), `L:214` (u16 @42), `L:234` (`buffer_copy` source offset 44); and `scr_online_cosmetics_selfcheck` (`M:1176-1264`) which writes packets at offset 0. Size comparisons against the buffer size at `M:154, 205, 229, 706` must not use the large receive buffer's size in place of the packet size. | Round-trip every decoder from a buffer holding two packets back to back (offsets 0 and N). |
| **INV-A3** | **Explicit offset and count on every send**: `buffer_offset = 0`, `buffer_count = size`, `size >= 1`. The shared `net_send_buffer` is bigger than the packet and also gets `buffer_resize`d (`L:168`); the address must be read at call time. (G6, G22) | Fake `send` records `(offset,count)`; a 62-byte STATE from a 8236-byte-grown buffer must report count 62. |
| **INV-A4** | **Send flags**: reliable packets (HELLO, BYE, ER_PICKS, LEVEL_REQUEST/CHUNK/DENY) use `ReliableNoNagle` (9) OR `AutoRestartBrokenSession` (32); unreliable (STATE, PING, PONG) use `UnreliableNoNagle` (1) OR 32. Never `NoDelay` (4, 5). Channel 0. (G2, G4, G5) | Fake `send` asserts the flag set per packet type. Two-account: kill one peer's session (close it from one side) and verify the other's next STATE still arrives. |
| **INV-A5** | **Send success** is `result == SteamApiResult.Ok` (1) exactly; `undefined` and every other value are failures. Only `L:177` branches on it, retrying the same chunk next tick; no other caller may start to depend on it. (G10) | Fake `send` returning 25 (`LimitExceeded`): the level sender must not advance `offset`. Fake returning `undefined`: no exception. |
| **INV-A6** | **Session-request callback** is registered before the first create/join and stays registered; it accepts iff the requester is a **live** member (queried from Steam) of the lobby we are in, and online play is enabled. The per-message `net_lobby_member` gate with its once-per-tick forced `net_refresh_members()` **remains** in the receive loop (add, do not move). (G1) | Unit: request from a non-member is not accepted; from a member is. Two-account: third account (not in lobby) cannot get STATE processed. |
| **INV-A7** | **Session close triggers** are those of 2.x: `net_leave_lobby` for every member, and `net_remove_player` (BYE, chat-update leave, 10 s timeout, refresh prune). Not on lobby-lost, kicked, failed-join or discarded-reply paths. (G3) | Fake `close_session` counter per scenario. |
| **INV-A8** | Channel 0 on both send and receive; all packet types share it (reliable ordering for level transfer depends on one channel). (G6, G7) | Fake asserts channel. |
| **INV-A9** | **Lobby id discipline.** Every `steam_matchmaking_*` call receives `global.net_lobby_id`; it is never `-1` or `0` at a call. A discarded/unwanted reply is left by the id **in that reply**. `net_lobby_id` is overwritten with the join reply's id. Every path that forgets a lobby the user may still be in leaves it by id (2.x did that implicitly before create). (G13, G17) | Fake matchmaking asserts `id > 0`; scenario: unexpected `lobby_created` reply while joining must `leave(reply.lobby_id)`. |
| **INV-A10** | **Reply cardinality.** `net_create_pending` and `net_join_pending_id` always get cleared: by the callback or by a watchdog (the longer of the two must exceed Steam's own timeout; value to be chosen, e.g. a few tens of seconds). A late callback for an expired attempt is detected (per-attempt token) and treated as an unwanted reply. No code may treat `undefined`/0 from create/join as "immediate failure". (G12) | Fake: never call back -> pending clears and auto-host retries; then call back late with success -> that lobby is left and no state is corrupted. |
| **INV-A11** | **Callback timing and lifetime.** `steam_api_run_callbacks()` is called exactly once per simulation tick from one place that is not inside `net_tick`/`net_session_update`; callbacks are global functions touching only `global.*` and must work with no `o_networkmanager` instance (replaces `FS/Other_69.gml:1-6`); registrations are idempotent and re-done after `game_restart`. (G15) | Destroy the manager, deliver a create reply: the stray lobby is left. Restart the game via `net_game_restart` and verify lobby events still arrive. |
| **INV-A12** | **Platform gating.** Every 3.0 call is behind `platform_steam()` and `steam_api_is_initialized()`. On `Apple`, `Mobile`, `SteamAndroid`, `QA`, `iOSCheck` nothing on any executed path calls a 3.0 function: `net_init`, `net_session_update`, launch-arg parsing, banners, hooks, `net_game_restart`, the pause line and the friends button (which destroys itself) stay Steam-free. The `Check` config has `platform_steam()` true, so `steam_api_is_initialized()` returning false is the only barrier there. (1.6, G19) | Run `QA`/`iOSCheck`/`Check` builds with no Steam binary: no extension call is made (log/stub). `tools/check_port.py` should be extended to the lobby/net/matchmaking/networking/friends prefixes. |
| **INV-A13** | **Steam ids stay 64-bit integers** end to end; `string(id)` is the map key; `int64(0)` is "unknown", `-1` is "no lobby". (G9) | Startup assertion: `is_int64(steam_user_get_steam_id())` and the `string()` length is 17; message `steam_id_remote` equals the lobby member id for the same user (`==` and string). |
| **INV-A14** | **Size limits stay**: unreliable packets <= 1024 (legacy hard limit was 1200, [SDK] `isteamnetworking.h:37-41`); reliable packets up to 8236 (messages up to 512 KiB are allowed in 3.0, [SDK] `steamnetworkingtypes.h:832`); receive cap 8448; per-type caps (STATE 48..1024, HELLO 14..150, PING 8..1024, PONG 5, BYE 1, ER_PICKS 4..1024, REQUEST/DENY 34, CHUNK 44..8236). | Decoder fuzz at every length (the existing self-check does this for STATE and HELLO). |

### Group B: behaviour identical to today

| ID | Requirement | Where / value |
|---|---|---|
| **INV-B1** | **Wire compatibility.** Byte layouts, ids 16-24, `NET_PROTOCOL = 2`, the lobby `proto` value `"2"`, the HELLO proto byte and the descriptor `v` are consistent with each other. If the layout changes, bump all three together. **Decision for the implementer:** moving from `ISteamNetworking` to `ISteamNetworkingMessages` makes 2.x and 3.0 builds unable to exchange packets (inference: different APIs, [SDK] says Messages runs on Sockets; not tested), but both still publish `game_name`/`proto` identically, so a mixed lobby would **join successfully and then show no ghosts**. Bumping `NET_PROTOCOL` makes the older build report `NET_VERSION_MISMATCH` instead. | `M:14`, `M:216`, `M:484-485`, `M:1085`, `S:370` |
| **INV-B2** | **Topology.** Full mesh; no relay; host = lobby owner; every online player owns a friends-only lobby created at capacity 250; Max Players enforced by `set_joinable(open)`, `open = member_count < clamp(round(netmaxplayers), 2, 250)`, re-evaluated every 30 ticks and on becoming owner. | 3.4, 3.8 |
| **INV-B3** | **Tick order.** `net_session_update` then `net_tick`; inside it refresh/ownership first, then publish/follow, then send STATE -> send PING -> receive (<= 128) -> update ghosts -> level-share tick. Sends before receives. One simulation tick per engine frame at most. | `NM/Step_0`, `M:528-600` |
| **INV-B4** | **STATE policy.** Sent only when active, level key non-empty, a player or death object exists and at least one member reports the same `level_key`; targets = same-key members only; interval 1/2/3/4 ticks for <=8/<=16/<=32/more; idle (`idle > 2`) forces >= 12; seq 16-bit, first packet 0, accepted iff `0 < delta < 32768`, stale/duplicate rejected before touching `last_update`; all field validations and clamps; sprite derived locally. | 2.2, 2.3, 3.9 |
| **INV-B5** | **Keepalive.** PING broadcast to all members every 2000 ms of real time, immediately after join (`net_ping_at = 0`) and on a level-key change; each valid PING yields one PONG; `last_update` refreshed by accepted STATE/HELLO/PING only; peer removed after > 10 000 ms without; PONG RTT = `((now & $FFFFFFFF) - stamp) & $FFFFFFFF`, accepted if `< 60000`, smoothed with `lerp(.,.,0.3)`. | 2.6, 2.7, 3.9 |
| **INV-B6** | **Peer-loss detection**: the four paths of G11 with unchanged constants. BYE stays best-effort; removing a peer by BYE/leave announces it only if it was `announced`; timeout/prune removals are silent. | `M:734, 1121, 870, 514` |
| **INV-B7** | **Membership gate and lost lobby.** Packets from non-members are dropped, with at most one forced refresh per tick; `member_count <= 0` at a refresh resets state and shows `NET_DISCONNECTED`, after which auto-host recreates a lobby; refresh also prunes ghosts that left the lobby. | `M:698-704, 570-575, 510-516` |
| **INV-B8** | **Handshake.** HELLO announcement broadcast exactly once per validated join (`reply=0`); every receiver answers a non-reply HELLO with one reliable unicast `reply=1`; replies are never answered; "player joined" notice once per peer; a fresh own lobby sends none. | `M:1097, 727-731` |
| **INV-B9** | **Join validation and pending machine.** Leave own lobby first (BYE, handoff, leave); one tick defer; join only when no create and no join reply is pending; stale/replaced replies discarded; success revalidated (members > 0, `game_name`, `proto`); wrong ones leave and flash `NET_SESSION_UNAVAILABLE` / `NET_VERSION_MISMATCH` / `NET_JOIN_FAILED`; already-in-that-lobby does not rejoin. | 3.5 |
| **INV-B10** | **INV-Auto-host.** Conditions and timers: retry 15 s after an immediate refusal, 30 s after a failed reply; never while a join is pending; unwanted create replies are discarded; creating never happens in `r_loading`/`r_logointro`. | `M:561-564, 437-440, 1043-1047` |
| **INV-B11** | **Ownership.** Voluntary handoff to the member with the earliest **local first-seen** `join_time`; migration detected by polling every 30 ticks; new owner runs `net_become_host` (clear cache, rewrite `game_name/proto/host_name`, publish, apply member limit; `NET_YOU_ARE_HOST` if others present); non-owners run `net_session_owner_changed` (4 s quiet window, cancel follow, drop in-flight level download). | 3.6, 3.7 |
| **INV-B12** | **Lobby data.** Keys `game_name`, `proto`, `host_name`, `session`, `current_room`; cache updated only when the write returns true; unchanged values not re-sent; descriptor <= 8000 bytes with the two-step degradation; reader caps at 8192 bytes and validates; followers poll (15 ticks; every tick while a job exists). | 2.11, G16 |
| **INV-B13** | **Follow rules.** First descriptor after joining always counts (`"*"` sentinel); new sid followed only if `net_follow_host`, outside the quiet window, joinable; 180-tick countdown (0 when not in a PLAY room or immediate); cancelled when the player starts something else, the host moves to another sid or the editor; blocked while `net_follow_can_enter()` is false; 90 s Workshop/level wait; demo build always fails. | 3.10 |
| **INV-B14** | **Endless picks.** First pick per level number wins; ER_PICKS reliable, <= 24 entries and <= 1024 bytes per packet, accepted only when sid matches and `global.endless == 1`; replayed to a peer whose PING sid changed; reset by lobby reset and by a new run from `r_endlessrunmenu`. | 2.8, 3.11 |
| **INV-B15** | **Level share.** Reliable ordered chunks of <= 8192 bytes; <= 16 chunks/tick across <= 8 transfers; only the lobby owner is asked; in-order exact-offset validation; total in 1..16 MiB; deadlines 60 s then 30 s; MD5 + `level_validate` before caching; failures deny the md5 for 60 s; ownership change drops the incoming transfer; backpressure via the send result (A5). | 2.9, 2.10, 3.12 |
| **INV-B16** | **Survives `game_restart`.** Lobby, maps, buffers, sessions and the cold-launch id (parsed once per process) persist; `net_cleanup` only on a real exit. | 3.2 |
| **INV-B17** | **Settings.** Online off (or Steam unavailable) leaves the lobby silently and clears pending join/intent; `net_request_join` turns online on and saves; `netmaxplayers` applies live. | `M:548-554, 410-414` |
| **INV-B18** | **UI contract.** The Friends panel needs: friends array with `{id, name, lobby, status}`, the member list, `net_active/is_host/owner/lobby_id`, `host_name`, joinability of the owner's descriptor, overlay-enabled flag, avatars with the pending/none/ready protocol. The pause line needs only `net_active`, `net_is_host`, `net_member_count()` and `host_name`, and must make no Steam call when `onlinemultiplayersettings != 1`. | 3.13 |
| **INV-B19** | **Reliability classes** exactly as in 2.1 and G6. | |

### Group C: tooling invariants

* `scr_online_cosmetics_selfcheck` (prints `TCC_GHOST_PACKET_PROBE` and `TCC_ONLINE_COSMETICS_SELF_CHECK_PASS`) must keep passing unchanged; it asserts the STATE offsets x@3, y@7, blend@12, xscale@16, yscale@20, alpha@28, color@32, truncation at every length, NaN, zero scale, bad room name, unknown cosmetics, sequence handling and the HELLO round trip.
* `tools/check_port.py:24` asserts `extensionVersion == '3.0.0'`; it and `tools/build.py --self-check` (`TCC_PORT_SELF_CHECK_PASS`) must still pass; `build.py:448-452` rejects `*steam*.dylib` in non-Steam macOS packages.

---------------------------------------------------------------------------------------------------

## 7. What cannot be tested without Steam (and what can)

### 7.1 Needs a live Steam client; most also need a second account

Lobby create/join/leave, owner handoff and migration, `set_joinable`, lobby data propagation, every async event and callback, session requests and acceptance, every P2P packet, friends list and friend rich presence, avatars, overlay invite/profile, `lobby_join_requested`, cold launch via `+connect_lobby`, UGC subscribe/poll/download for follows, demo-build gating, send flow control (`LimitExceeded` behaviour on a real queue), whether messages sent before acceptance are held or dropped, session timeout/`NoConnection` recovery, and everything about NAT/relay latency. **No tool in `tools/` touches online code**: `gameplay_qa.py`, `native_runner.py`, `pause_qa.py`, etc. run the `QA` config where `platform_steam()` is false, `net_enabled()` false, the friends button destroyed, so no lobby, ghost, panel or pause line ever runs. The only automated coverage is the pure-buffer self-check.

### 7.2 Can be tested without Steam

Already covered: `net_cosmetic_id`, STATE write/decode round trip with truncation/NaN/zero scale/bad room/unknown cosmetics, `net_apply_ghost_state`, HELLO round trip, all 50x5 skins resolve.

Pure GML with **no** test today and testable by stubbing the packet layer: `net_write/decode_ping`, ER_PICKS encode/decode and the pick logic, all `net_levelshare_*` (offer, md5/dir validation, chunk framing and validation, `net_levelshare_finish`), `net_session_capture/valid`, `net_room_class`, `net_level_key_compute`, the `net_follow_job_tick` state machine, `net_enter_*` argument validation, `net_clean_name`, `net_parse_id`, `net_session_text`, panel layout/hover (needs Steam only through `tcc_steam_initialised()`), the 1024/8000/8192-byte limits.

### 7.3 Seams a rewrite should add so the Steam-dependent logic becomes testable

1. **Transport adapter test (no Steam).** Feed the receive path a synthetic result shaped like 3.0's: one buffer with several messages packed back to back plus an array of `{offset, size, steam_id_remote}` structs, including (a) an oversized message in the middle, (b) a message from a non-member, (c) a zero-length or truncated message, (d) mixed types 16-24 from three senders, (e) an oversized message **followed by valid messages in the same tick** (the valid ones must be processed in that tick), and an empty-array result accompanied by a non-empty last error ("dropped", keep looping) versus an empty array with an empty last error ("queue empty", stop). Assert each decoder gets offset-0 bytes and that A1 holds. This tests the adapter and every decoder with no Steam client.
2. **Fake send.** Capture `(target, buffer, offset, count, flags, channel)` and return a configurable result (`1`, `25`, `3`, `undefined`); assert A3, A4, A5 and the level sender's retry.
3. **Fake matchmaking with scripted callbacks.** Drive create/join through: success, failure result, never-called (watchdog), late success after watchdog, stale reply for a replaced join, reply while manager destroyed, wrong `game_name`/`proto`, zero members, lobby id with different instance bits. Assert B9, B10, A9, A10, A11.
4. **Fake membership.** Script `get_member_*` to test the forced refresh, pruning, the session-request accept predicate (A6), `lobby_chat_update` flag handling for each of 1/2/4/8/16 and for self vs other.
5. **Startup assertions** that fail loudly: ids are int64 (A13); callbacks registered; `steam_api_is_initialized()` true before any 3.0 call; the networking receive buffer is large enough.

### 7.4 Two-account scenarios that must be run on real Steam

1. A creates, B joins from the Friends panel; HELLO exchange, names/skins, "player joined" notices, pause lines (HOSTING (2) / JOINED).
2. B joins through the overlay "Join Game" and through an invite accept in a menu and in a level.
3. Cold launch with `+connect_lobby <id>` while A is hosting.
4. Ghosts: same level shows B's ghost at up to 60 Hz; different level hides it; idle drops to 5 Hz; level change fades.
5. Host leaves normally: BYE, handoff to the earliest first-seen member, `NET_YOU_ARE_HOST` on the successor, followers keep playing.
6. Host process killed (no BYE): ghost gone within the refresh or 10 s; ownership migrates; no stuck "connecting".
7. B frozen for > 10 s (debugger/suspend) then resumed: removed by timeout, then **recovers** from its next PING/STATE (G3/G4) without leaving the lobby.
8. Session closed from one side (timeout) while the other keeps sending: both directions work again.
9. Max Players: set 2 with A+B in the lobby; C's join reports IO success but ends in `NET_SESSION_UNAVAILABLE` (0 members after the 'successful' reply: this is the path the post-join validation exists for); raise to 8; C can join within ~0.5 s.
10. Level share: A play-tests a custom level; B follows and receives a 16 MiB-class file; kill the network mid-transfer; a repeated request restarts it; queue-full back-pressure (large file to several followers).
11. Endless Run: both enter, picks agree; B joins mid-run and receives picks; rejoin keeps picks only while in the lobby.
12. Follow edge cases: host in menu then enters a level; host in editor play-test; host changes mode during the 180-tick countdown; B starts its own level during the countdown.
13. Version gate: a build with a different `proto` is refused with `NET_VERSION_MISMATCH`.
14. Third account that is **not** a lobby member sends packets to A: nothing processed; sessions not accepted (A6).
15. Network interruption during create and during join (IO failure) with the game left running: auto-host resumes (A10).
16. `game_restart` (the ending) with a party: lobby and picks survive (B16, A11).
17. Oversize/hostile packet from a member while another member sends a reliable message (A1).

### 7.5 One-account checks possible with a Steam client

Lobby creation and `HOSTING (1)` pause line; Friends panel with an empty list; `is_int64` assertion; callback registration and `steam_api_run_callbacks` pump; own rich presence visible to a friend; the `Check` config with and without a Steam client running.

---------------------------------------------------------------------------------------------------

## 8. Resolved discrepancies between the readings (and what overturned them)

| # | Topic | What the readings said | Evidence opened for this spec | Resolution |
|---|---|---|---|---|
| 1 | **Who the 2.x extension auto-accepted** | Session reading 4.3: "the Steam-level accept is unconditional; the game-level filter is the membership check". | [N2] `steam_networking.cpp:23-40`: accepts only if the requester is in `steam_lobby_current` (live). Old docs agree ("players in the same lobby"). | **Overturned.** The filter was two layers: the extension's live-membership accept, and the game's per-message `net_lobby_member`. |
| 2 | Where membership filtering goes in 3.0 | Session reading H6(c): "should move into the session-request callback". | Acceptance is per user and persists across a lobby change; the callback may fire before membership refreshes. | **Corrected.** It must be *added* to the callback; the per-message gate and forced refresh stay (A6). |
| 3 | 2.x P2P internals | Transport reading 14: not verified; taken from docs. | [N2] real source read from git HEAD. | **Closed.** Send, receive, get_size, get_data, sender id, channel default, session accept, no `P2PSessionConnectFail` handler are now cited (G1-G11). |
| 4 | `get_data` grows the buffer? | Session reading open question 6. | `old_networking.txt` ("resized automatically") and [N2] `steam_networking.cpp:184` `BufferWriteContent(..., 0, ..., size, true)`. | **Resolved: yes**, writes at offset 0 with grow. |
| 5 | Send return value in 3.0 | Docs `networking.js` says "number of messages"; session reading open question 5. | [N3] `gm_steam_networking_messages.cpp:116-157` returns `int32` EResult; `SteamApiResult.Ok = 1`; wrapper `@returns {Real}` ([API] 23674). | **Resolved.** The doc text is a copy-paste error. |
| 6 | "False return = reliable queue full" | Transport/consumers took it as fact. | [N2] `steam_networking.cpp:131` adds no queue logic; [SDK] legacy header does not say the send returns false on a full queue. | **Unverified assumption** of the level-share code (G10). In 3.0 the equivalent is `LimitExceeded`. |
| 7 | What `success` meant in `lobby_joined` | Session reading inferred "IO success". | [N2] `steam_matchmaking.cpp:411` `set_success(!failed)`. | **Confirmed.** |
| 8 | Exactly one reply per create/join | Not stated by any reading. | 2.x dispatches always ([N2] 407-413, 484-491); 3.0 does not on IO failure ([N3] `steam_async_common.h`, `gm_steam_matchmaking.cpp:181-215`). | **New hazard** (G12). |
| 9 | Implicit leave-before-create | Not noted. | [N2] `steam_matchmaking.cpp:499, 420`. | **New** (G13): 2.x left the previous lobby; 3.0 will not. |
| 10 | Nagle / auto-restart | Not noted. | [SDK] migration notes (`steamnetworkingtypes.h:952-953, 1006, 1011`) and `isteamnetworkingmessages.h`/`steamnetworkingtypes.h:1029-1048`. | **New** (G4, G5). |
| 11 | Event timing | Consumers 5.2 said `steam_update` "is required for async events to fire". | [N2] `steam_misc.cpp:39-44`, `gml_glue.h:24-26`: `steam_update` = `SteamAPI_RunCallbacks()`; events are queued with `CreateAsyncEventWithDSMap(.., 69)`. | **Refined** (G15): queued and delivered after Step, on any frame, to all instances. |
| 12 | `p2p_session_request` Async event | Consumers: "the extension has no handler". | [N2] `steam_networking.cpp:27-29` dispatches it with `user_id`; the game has no `Other_69` branch for it. | **Refined:** it exists but is unused. |
| 13 | Receive buffer sizing | Transport noted the "must be pre-sized for the worst case". | [N3] 181-225 drops the rest on exhaustion and never grows; `M:302` creates 1024 bytes. | **Made concrete** (G8, A1). |
| 14 | `identifiers.json` completeness | Consumers 7.6. | `ugc_result_success` and `ov_friends` absent. | **Confirmed** incomplete for raw constants (4.C). |
| 15 | `net_connect_state` 1 "creating" | Session reading 1.1. | Grep: never assigned (`M:279-284, 350-354, 400, 451`). | **Confirmed** dead state. |
| 16 | `steam_get_friends_game_info` content | Consumers: "array of structs". | [N2] `steam_user.cpp:116-145`: all immediate friends, zero-filled for non-players. | **Refined** (3.13). |
| 17 | Sender/lobby id type | Task brief: "SteamId struct probably". | [API] `steam_user_get_steam_id` 14730-14740, `__SteamNetworkingMessage_decode` 11929-11960, `get_lobby_*` return `Real` via `buffer_u64`. | **Resolved:** numbers, not structs. The GM runtime type of a `buffer_u64` read remains [GM]/[UNV] (G9). |

---------------------------------------------------------------------------------------------------

## 9. Open questions and unverified items

1. **Held or dropped?** Whether Messages sent to us before we accept the session are held until acceptance or dropped (the header is silent; `isteamnetworkingmessages.h` says only that requests are re-posted while the user keeps sending). Affects how much of the first burst after a join can be lost. [UNV]
2. **GameMaker runtime type** of `buffer_read(..., buffer_u64)` (int64 vs real) on every target platform; individual Steam ids exceed 2^53. [GM]
3. Whether callbacks registered with `steam_*_set_callback_*` (and `session_request`) **survive `game_restart`**. [UNV]
4. **Order of `FS/Step_0` vs `NM/Step_0`** within a frame (which instance steps first) is not specified in the repo, so where the pump call best sits relative to `net_tick` must be chosen and tested. [UNV]
5. Whether the SDK version of the headers on disk is the 1.65 line shipped with 3.0. The `[SDK]` citations quote comments that are stable across recent versions, but this is not proven. [UNV]
6. Legacy `SendP2PPacket`'s exact conditions for returning false (queue-full is not documented). Level share's flow control rests on it. [UNV]
7. Whether `steam_networking_messages_send_message_to_user` copies the payload before returning (header implies yes; not explicit). [SDK, implied]
8. Whether a `close_session_with_user` right after a reliable send flushes or discards the send (BYE delivery). [UNV]
9. Whether the `LobbyChatUpdate` callback is delivered for the local user's own leave/kick the way the 2.x event was (the game handles both self and other). [UNV]
10. What `steam_friends_get_friend_persona_name` / `steam_get_user_persona_name_sync` return for a user whose data is not yet cached. [UNV]
11. What `steam_ugc_get_item_install_info` returns for an item that is not installed (replaces the ds_map reads at `S:884`). [UNV]
12. The overlay-dialog enum that replaces `ov_friends` (`F:196`). [UNV]
13. Whether 2.x and 3.0 builds can see each other's P2P traffic at all (B1; inferred no). [UNV]
14. Unreliable/Nagle timing numbers under load (60 Hz x N peers) — only measurable on real Steam. [UNV]
15. The runtime value of the receive bound (`RecvMaxMessageSize`, default 524288 per the SDK header): the 3.0 extension sets no networking config in its sources, but this was not observed at runtime. Option (a) in G8 depends on it. [UNV]
16. That `steam_api_last_error()` reliably holds "output buffer exhausted" after a dropped receive (relies on the native clear-on-entry behaviour read in `GMSteamworks.h:59-66`). [UNV]

---------------------------------------------------------------------------------------------------

## Appendix A. Latent quirks in the current code (so they are not copied blindly and not "fixed" silently)

* `net_decode_hello` caps the name at 128 **bytes** while `net_clean_name` caps at 64 **characters** (`M:121-123, 207`); 64 multi-byte characters can exceed 128 bytes and the 150-byte packet cap, and the HELLO is then silently dropped.
* The wire `join_time` in HELLO is decoded and validated but never used; succession ranks by the leaving owner's own first-seen clock (`M:722`).
* BYE then immediate `close_p2p_session` (`M:377-389`): delivery not guaranteed (G11).
* Sequence-reset hazard: if a sender restarts its counter at 0 while a receiver still holds the old record (last seq in 1..32768), every new STATE is rejected until the counter passes the old value; PINGs keep `last_update` fresh so the timeout alone does not clear it. Steam's chat update on the old process's departure removes the record in practice. `net_send_seq` persists across leave/join within a run.
* `NET_CHUNK_MAX_SIZE` (8448) is the receive cap for every type; only LEVEL_CHUNK legitimately exceeds 1024.
* An unwanted `lobby_created` reply while already `net_active` is not discarded (`M:1031` `if (!global.net_active)`): in 2.x that would have repointed `steam_lobby_current` at the stray lobby. Practically unreachable because a join waits for `!net_create_pending` (`M:557-558`).
* `net_levelshare_serve` compares its queue length with `NET_MAX_LOBBY` (250) (`L:137`).
* Write-only or unused: lobby key `current_room`, `tcc_steam_lobby_is_owner`, `net_join_announced`, `net_connect_state == 1`.
* `net_lobby_member(sender)` returns false for our own id; a packet "from ourselves" is dropped as a non-member and, if it arrives, triggers a forced refresh.
* A returning ghost after BYE/prune ("resurrection") is possible for up to ~0.5 s (G7).
* The friend rich-presence reader handles only raw `#Token` values and never requests the data (G21).
* Localisation: 62 `NET_*` and 36 `RP_*` keys exist only in `datafiles/Languages/english.lang:1028-1125`; `loc()` returns the key when untranslated and English is always loaded as base, so other languages fall back to English.

## Appendix B. Where the key evidence lives

| Claim | Evidence |
|---|---|
| 2.x auto-accept only for live current-lobby members | `git show HEAD:extensions/Steamworks/steamworks_cpp/GMLSteam/steam_networking.cpp` lines 23-40 |
| 2.x send/receive/get_data/get_sender | same file lines 90-133, 144-199 |
| 2.x implicit current lobby, leave-before-create, reply encodings | `steam_matchmaking.cpp` lines 19-27, 407-413, 484-491, 494-514; `steam_glue.cpp:7`; `gml_glue.h:24-64` |
| 2.x pump | `steam_misc.cpp:39-44` |
| 3.0 send/receive semantics | `scratchpad/gmext/src/source/Steamworks_gml/extensions/steamworks/source/src/gm_steam_networking_messages.cpp` lines 116-157, 161-228 |
| 3.0 async reply behaviour | `.../steam_async_common.h`; `.../gm_steam_matchmaking.cpp` lines 181-215 |
| Migration notes, session semantics, restart flag | `/Users/infi/Documents/sdk/public/steam/steamnetworkingtypes.h` 943-1048; `isteamnetworkingmessages.h`; `isteamnetworking.h` 33-56, 146-177, 319-322 |
| 3.0 GML wrappers | `scripts/Steamworks_API/Steamworks_API.gml` 23618-23811 (networking messages), 22797-23420 (matchmaking), 11929-11960 (message decode), 14730-14740 (own id) |
