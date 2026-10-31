# Steamworks 2.1.6 -> 3.0.0 migration map: matchmaking / lobbies (FINAL, after verifier disputes)

Scope: every `steam_lobby_*` function and constant the project uses, the `tcc_steam_lobby_*` wrappers around them, and the lobby async events (`lobby_created`, `lobby_joined`, `lobby_chat_update`, `lobby_join_requested`).
Read-only analysis. Nothing under the project was changed. Supersedes `map-lobby.md`; machine-readable twin: `map-lobby.final.json` (17 entries).

Evidence key:
- `API:n` = `scripts/Steamworks_API/Steamworks_API.gml` line n
- `DOC:n` = `.../scratchpad/gmext/src/docs/matchmaking.js` line n (friends: `friends.js`; `getting_started.md` in the same dir)
- `NAT:` = `.../scratchpad/gmext/src/source/Steamworks_gml/extensions/steamworks/source/src/gm_steam_matchmaking.cpp` (same dir: `steam_async_common.h`, `GMSteamworks.h`, `GMSteamworks_core.cpp`, `gm_steam_api.cpp`, `gm_steam_friends.cpp`) and `.../source/code_gen/native/SteamworksInternal_native.cpp`
- `OLD:` = `.../scratchpad/port/old_lobbies.txt` (text dump of the 2.x `lobbies.html`) and `old2x/Steamworks.yy`
- The scratch source is 3.0.0 and the installed extension is `extensionVersion 3.0.0`, so the native behaviour quoted below applies to the installed binary.

---------------------------------------------------------------------------------------------------

## Decisions on the disputes (all 14 checked against source)

| # | Dispute | Verdict | Evidence / what changed |
|---|---|---|---|
| 1 | `steam_api_last_error() == ""` is a reliable dispatch check; two silent `return`s exist (`if (!mm) return;` native, `if (!__available__) return;` GML) | **Partly right.** The check is best-effort; the native half of the evidence is wrong. | `steam_matchmaking_iface()` sets a last error on BOTH null paths (NAT:15-25), so `if (!mm) return;` (NAT:185-186) is NOT silent. `steam_api_last_error` is a pure getter (GMSteamworks_core.cpp:23-27) and `steam_api_is_initialized` too (gm_steam_api.cpp:221-224), STEAM_GUARD clears at call start (GMSteamworks.h:55-63). The GML `if (!__available__) return;` (API:22797-22802) IS silent but needs `extension_exists("Steamworks")` false, which the `platform_steam() && steam_api_is_initialized()` guard already excludes. Real hole: CallResult IO failure after dispatch (`ReportIoFailure=false`, steam_async_common.h:11/:35-46) -> watchdog. Wording changed to "best-effort"; the 20 s was wrongly attributed to Steam: the documented 20 s timeout is only for `request_lobby_list` (DOC:186), so 20 s is now "a conservative choice". |
| 2 | "anonymous function bound to a destroyed instance errors" is asserted, not proven | **Accepted (reworded).** | Dispatch is `with (_dummy_context) method_call(...)` (ExtensionCore_api.gml:350). `getting_started.md` itself shows inline anonymous callbacks. What GameMaker does with a method bound to a destroyed instance cannot be confirmed from source. Recommendation kept (named global script functions touching only `global.*`) because it is safe either way; reason is now "avoids any dependence on instance lifetime". |
| 3 | create `call_sites` omit the two `Other_69` files | **Accepted.** | Read both: `objects/o_fullscreensystem/Other_69.gml` is 6 lines, all lobby forwarding (delete the file and its `eventNum 69` entry, o_fullscreensystem.yy:5); `objects/o_networkmanager/Other_69.gml:3` is `net_handle_async_steam(async_load)` (keep until `avatar_image_loaded` and `ugc_subscribe_item` move; entry in o_networkmanager.yy:8). Added to create, join, lobby_created, lobby_joined. |
| 4 | join wrapper must not use `tcc_steam_lobby_resolve` (undefined -> current lobby) | **Accepted.** | Joining "the current lobby" is meaningless and a stray `undefined` would silently join the current lobby or no-op. Wrapper now `if (!is_numeric(_lobby_id) || _lobby_id <= 0) return false;`. Only caller (:453) always passes an int64 (net_request_join does `int64(_lobby_id)`). |
| 5 | leave `doc_refs` is malformed | **Accepted.** | Correct refs: NAT gm_steam_matchmaking.cpp:287-292; export SteamworksInternal_native.cpp:6276-6285 (both re-read). |
| 6 | "2.x silently returned false on non-string" is unbacked | **Accepted.** | Not in OLD (only "convert numeric values to string", old_lobbies.txt:511-520) and no old source in the scratchpad. Marked UNVERIFIED in the set_data entry and in section 0 item 8. No impact: `net_lobby_set` already `string()`s the value, keys are literals. |
| 7 | lobby_created `call_sites` omit the two `Other_69` files | **Accepted.** | Same as #3. |
| 8 | lobby_joined `call_sites` omit them and the `net_discard_lobby_reply` sites | **Accepted, with a correction to the dispute.** | The discard calls are at scr_online_multiplayer.gml **:1031 (created), :1055 and :1061 (joined)**, plus the definition at :461-465. The dispute said 1053; the file says 1055. |
| 9 | the NET_SESSION_UNAVAILABLE mapping is not optional, and NotAllowed is missing | **Accepted.** | `NET_SESSION_UNAVAILABLE` = "That session is full or no longer exists", `NET_JOIN_FAILED` = "Could not join that session" (datafiles/Languages/english.lang:1055-1056). The project caps Max Players with `set_lobby_joinable(false)` (:493-496). DOC:874 documents `NotAllowed` only as "General Denied", so the exact response for a joinable=false lobby is not confirmable statically (-> unresolved, one runtime test). Mapping is now part of the handler: DoesntExist, Full, NotAllowed -> UNAVAILABLE; every other non-Success -> JOIN_FAILED. Safe whichever code the capped lobby really returns. |
| 10 | restart: `final = steam_api_shutdown` may leave `global.net_active` stuck true | **Accepted in part.** | Confirmed: `final` is `steam_api_shutdown` (extensions/Steamworks/Steamworks.yy:20), shutdown clears all callbacks (gm_steam_api.cpp:113, :307-318), and net_tick returns at :530 BEFORE `!net_enabled()` -> `net_leave_lobby`, so a dead Steam leaves `net_active` true. Adopted (safe either way): in net_tick, before the :530 return, reset the session and pending flags when Steam is gone. Callback re-registration relies on `o_networkmanager/Create_0.gml` (the manager is recreated via `net_ensure_manager()` in o_loading/Create_0.gml:14 and o_title/Create_0.gml:118). NOT adopted: an unconditional `net_leave_lobby(false)` in `net_game_restart` (would break the design at :320-326 if Steam survives); make it conditional on the runtime test. Re-initialising Steam is the core domain's job (map-core.md section 7 item 1). |
| 11 | registration wrapper guard `steam_api_is_initialized()` is unnecessary and risks never registering | **Accepted.** | `set_callback_*` natives only clear the error and store the callback, no STEAM_GUARD (gm_steam_matchmaking.cpp:149-150; gm_steam_friends.cpp:1118-1123). Wrapper guard is now `platform_steam()` only (iOS/Android/MAS ship no binary). Lazy registration from net_tick was not adopted: Create_0 runs once per boot/recreate and re-registering is harmless; the registration is wrapped in `net_register_steam_callbacks()` so a Steam re-init path can call it again. |
| 12 | leave entry vs lobby_joined entry contradict on :1066 | **Accepted.** | Non-Success enter response = not in the lobby, so :1066 has no leave. :463 (discard), :1080 and :1086 (after a SUCCESSFUL enter) pass the reply id. |
| 13 | join "returned Bool in 2.x" is not confirmed by the .yy | **Accepted.** | old2x/Steamworks.yy:387 says `@returns {Undefined}`; the HTML docs say Boolean "whether the API was correctly initialised" (old_lobbies.txt:321-322). The project only used truthiness. Reworded; code unchanged. |
| 14 | "2.x reported IO success for full/vanished lobbies" is inferred | **Accepted.** | Only evidence is the project comment at :1072-1073 (2.x callback source absent: old2x_cpp/steam_callbacks.cpp has no implementation). Marked "inferred"; migration unaffected (3.0 enum is strictly more informative, member/game/proto checks stay). |

Extra findings while checking (not raised by the verifiers):
- `o_fullscreensystem/Other_69.gml` has no other content, so the whole file (and its event entry in the `.yy`) can go, not just lines 3-6.
- The discard call site line numbers were corrected (see #8).
- The extension has NO persistent lobby-enter callback (only data_update, chat_update, chat_msg, game_created, invite; gm_steam_matchmaking.cpp:27-31 (callback slots), :141-153 (set/clear)), so the implicit `LobbyEnter_t` after create is never delivered to GML.
- `steam_api_clear_all_callbacks` also clears `avatar_image_loaded` (gm_steam_api.cpp:119): after a Steam shutdown the friends/avatar callback must be re-registered too (friends domain).
- ExtensionCore_api.gml:334-337: an unknown callback handle logs "BAD PACKET" and `continue`s without consuming the packet's args. If a restart wiped the function map while native replies were in flight this could desync the packet reader (speculative, listed under unresolved).

---------------------------------------------------------------------------------------------------

## 0. Verdict in ten lines

1. **IDs stay plain numbers.** Lobby ids, member ids and owner ids are `Real` typed in GML and are read with `buffer_read(.., buffer_u64)`, which is an int64 (e.g. API:22967 `get_lobby_by_index`, :23029 `get_lobby_owner`, :23074 `get_lobby_member_by_index`). The `SteamId` struct (API:1688) only comes out of `steam_user_decode_steam_id`. So `int64(0)`, `== 0`, `string(id)` map keys and `==` between ids all keep working. Lobby/user ids are below 2^63 (universe byte = 1), so the unsigned read cannot go negative. (int64 vs double is inferred, see unresolved.)
2. **The "current lobby" concept is gone.** 2.x had an implicit current lobby (`steam_lobby_get_data(key)`, `steam_lobby_leave()`). Every 3.0 matchmaking call takes an explicit `lobby_id` as its first argument. The project already tracks `global.net_lobby_id`, but several code paths need a lobby id *before* that global is set (section 5.3).
3. **Results are callbacks, not async events.** `steam_lobby_create` / `steam_lobby_join_id` get a callback as the last argument. Lobby membership changes and overlay joins come from `steam_matchmaking_set_callback_lobby_chat_update` and `steam_friends_set_callback_game_lobby_join_requested`. The `Other_69` lobby cases disappear.
4. **`create_lobby` / `join_lobby` / `leave_lobby` return NOTHING useful.** The native exports are `void` and return the literal `0` (SteamworksInternal_native.cpp:6167-6196, 6276-6285). The project does `if (!tcc_steam_lobby_create(...))` and `if (!tcc_steam_lobby_join_id(...))` (scr_online_multiplayer.gml:437, :453); a wrapper that returns the raw 3.0 value would take the failure branch every time. The wrapper must compute its own boolean: `steam_api_last_error() == ""` straight after the call, as a **best-effort dispatch check** (decision #1), with the watchdog (5.4) as backstop.
5. **Success is no longer a bool.** Create: `_result.result == SteamApiResult.Ok` (Ok = 1; failures are non-zero too, so truthiness is wrong). Join: `_result.response == SteamMatchmakingChatRoomEnterResponse.Success` (Success = 1; every failure code is non-zero).
6. **No callback on IO failure.** The create/join `CallResult` is created with `ReportIoFailure = false`, so an IO failure just `delete this`s without calling GML (steam_async_common.h:11, :35-46; used with default template args at gm_steam_matchmaking.cpp:195 (create) and :213 (join)). `global.net_create_pending` / `global.net_join_pending_id` would then stay set forever. Add a watchdog.
7. **`steam_initialised()`, `steam_update()` and `steam_get_friends_game_info()` no longer exist** (0 hits in `Steamworks.yy`, 0 `function` declarations). Every in-scope wrapper guard `steam_initialised()` must become `steam_api_is_initialized()` (an extension function returning a Real, no GML wrapper, API:12456). The per-frame pump is `steam_api_run_callbacks()`; nothing in the project calls it yet (the old pump `tcc_steam_update()` at scr_steam_safe.gml:310-313, called from o_fullscreensystem/Step_0.gml:4, wraps the removed `steam_update`).
8. **Type mismatches are now fatal.** The generated wrappers use `show_error(..., true)` (e.g. `_joinable expected bool`, `_key expected string`, `_lobby_id expected number`; verified API:22797-22826, 23104-23126). What 2.x did on a wrong type is **unverified**. `steam_matchmaking_set_lobby_joinable` needs a real bool.
9. **Callbacks run with a dummy `self`** (`with (_dummy_context) method_call(...)`, ExtensionCore_api.gml:350). Register named global script functions that touch only `global.*`; this avoids any dependence on instance lifetime (inline anonymous callbacks are valid per getting_started.md, so this is a safe choice rather than a proven requirement).
10. **Field renames to copy exactly:** `lobby_join_requested` -> `SteamFriendsGameLobbyJoinRequested.steam_id_lobby` (not `lobby_id`); `lobby_chat_update` -> `user_changed_id` (was `user_id`), `chat_member_state_change` (was `change_flags`, same bit values 1/2/4/8/16).

---------------------------------------------------------------------------------------------------

## 1. Project inventory

### 1.1 Wrapper definitions (scripts/scr_steam_safe/scr_steam_safe.gml)

All use the guard `platform_steam() && steam_initialised()` and return a safe default otherwise.

| Wrapper | Def line | Old inner call | Fallback returned when Steam off |
|---|---|---|---|
| `tcc_steam_lobby_activate_invite_overlay()` | 26-29 | `steam_lobby_activate_invite_overlay()` | `false` |
| `tcc_steam_lobby_get_owner_id()` | 30-33 | `steam_lobby_get_owner_id()` | `int64(0)` |
| `tcc_steam_lobby_set_joinable(_a0)` | 34-37 | `steam_lobby_set_joinable(_a0)` | `false` |
| `tcc_steam_lobby_create(_a0, _a1)` | 150-153 | `steam_lobby_create(_a0, _a1)` | `false` |
| `tcc_steam_lobby_get_data(_a0)` | 154-157 | `steam_lobby_get_data(_a0)` | `""` |
| `tcc_steam_lobby_get_member_count()` | 158-161 | `steam_lobby_get_member_count()` | `false` |
| `tcc_steam_lobby_get_member_id(_a0)` | 162-165 | `steam_lobby_get_member_id(_a0)` | `false` |
| `tcc_steam_lobby_is_owner()` | 166-169 | `steam_lobby_is_owner()` | `false` |
| `tcc_steam_lobby_join_id(_a0)` | 170-173 | `steam_lobby_join_id(_a0)` | `false` |
| `tcc_steam_lobby_leave()` | 174-177 | `steam_lobby_leave()` | `false` |
| `tcc_steam_lobby_set_data(_a0, _a1)` | 178-181 | `steam_lobby_set_data(_a0, _a1)` | `false` |
| `tcc_steam_lobby_set_owner_id(_a0)` | 182-185 | `steam_lobby_set_owner_id(_a0)` | `false` |

`tcc_steam_initialised()` is at scr_steam_safe.gml:102-105 (`platform_steam()` then `steam_initialised()`), used by `net_enabled()`, `net_request_join`, `net_join_lobby`, `net_tick`, `net_presence_update`, `net_friends_list`, ...

### 1.2 Real callers (grep of scripts/, objects/, rooms/; Steamworks_API excluded)

| Call | File:line | Context |
|---|---|---|
| `tcc_steam_lobby_set_owner_id(_successor)` | scr_online_multiplayer.gml:386 | `net_leave_lobby`, hand ownership to longest-standing member before leaving |
| `tcc_steam_lobby_leave()` | scr_online_multiplayer.gml:388 | `net_leave_lobby` (global.net_lobby_id valid here) |
| `tcc_steam_lobby_create(steam_lobby_type_friends_only, NET_MAX_LOBBY)` | scr_online_multiplayer.gml:437 | `net_host_lobby`; return value tested with `!` |
| `tcc_steam_lobby_join_id(_lobby_id)` | scr_online_multiplayer.gml:453 | `net_join_lobby`; return value tested with `!` |
| `tcc_steam_lobby_leave()` | scr_online_multiplayer.gml:463 | `net_discard_lobby_reply(_success)`; **global.net_lobby_id is NOT set on this path** |
| `tcc_steam_lobby_set_data(_key,_value)` | scr_online_multiplayer.gml:470 | `net_lobby_set` (value already `string()`ed) |
| `tcc_steam_lobby_set_joinable(_open)` | scr_online_multiplayer.gml:496 | `net_apply_member_limit`; `_open` is the result of a `<` comparison |
| `tcc_steam_lobby_get_member_count()` | scr_online_multiplayer.gml:502 | `net_refresh_members` |
| `tcc_steam_lobby_get_member_id(_i)` | scr_online_multiplayer.gml:505 | `net_refresh_members`, 0-based loop |
| `tcc_steam_lobby_get_owner_id()` | scr_online_multiplayer.gml:576 | `net_tick` (every NET_REFRESH_TICKS=30) |
| `tcc_steam_lobby_leave()` | scr_online_multiplayer.gml:1066 | `lobby_joined` handler, `!success` branch; **global.net_lobby_id still -1** (leave is dropped, see 3.2) |
| `tcc_steam_lobby_get_data("game_name")` / `("proto")` | scr_online_multiplayer.gml:1077-1078 | `lobby_joined` handler, after `global.net_lobby_id = _reply_id` |
| `tcc_steam_lobby_leave()` | scr_online_multiplayer.gml:1080, :1086 | `lobby_joined` handler: no members / version mismatch |
| `tcc_steam_lobby_get_owner_id()` | scr_online_multiplayer.gml:1094 | `lobby_joined` handler |
| `tcc_steam_lobby_get_data("host_name")` | scr_online_multiplayer.gml:1104 | `lobby_joined` handler |
| `tcc_steam_lobby_get_data("session")` | scr_online_session.gml:411 | `net_session_host_desc` (guarded by `global.net_active`) |
| `tcc_steam_lobby_get_data("host_name")` | scr_online_friends.gml:124 | `net_friends_session_text` (after `!global.net_active` return) |
| `tcc_steam_lobby_activate_invite_overlay()` | scr_online_friends.gml:195 | Friends panel "invite" button; enabled only when `global.net_active` (line 139) |
| `tcc_steam_lobby_get_data("host_name")` | objects/o_pausescreen/Draw_73.gml:26 | inside `if (global.net_active)` |
| `steam_lobby_type_friends_only` | scr_online_multiplayer.gml:437 | constant, argument of create |
| `net_discard_lobby_reply(_map[? "success"])` | scr_online_multiplayer.gml:1031, :1055, :1061 (def :461-465) | all three need the new `(lobby_id, success)` signature |
| `tcc_steam_lobby_is_owner()` | **no callers** | wrapper only (scr_steam_safe.gml:166) |

Raw (non-wrapper) `steam_lobby_*` use anywhere else in the project: none (grep over every file type outside `extensions/`, `docs/`, `.git`).

### 1.3 Async consumers

| File | What it does with lobby events |
|---|---|
| objects/o_networkmanager/Other_69.gml:3 | `net_handle_async_steam(async_load)` (all events) |
| objects/o_fullscreensystem/Other_69.gml:1-6 | When the manager is destroyed (menus/editor) and `net_create_pending` exists, forwards only `lobby_created`/`lobby_joined` to `net_handle_async_steam` so cancelled native replies still settle. The whole file is this forwarder. |
| objects/o_title/Other_69.gml:2 | **comment only** ("lobby_join_requested handled by o_networkmanager"); the rest of the file is inventory pricing (not this domain) |
| scripts/scr_online_multiplayer/scr_online_multiplayer.gml:1017-1146 `net_handle_async_steam(_map)` | the real consumer. Cases: `lobby_created` (1022), `lobby_joined` (1050), `lobby_chat_update` (1110), `lobby_join_requested` (1127), plus **`avatar_image_loaded` (1135, friends domain) and `ugc_subscribe_item` (1139, UGC domain)** |

---------------------------------------------------------------------------------------------------

## 2. Cross-cutting prerequisites (owned by other domains but the lobby code depends on them)

| # | Requirement | Evidence |
|---|---|---|
| P1 | `steam_api_run_callbacks()` must run regularly (>= 10 Hz) from a persistent object that also exists in menus and the editor. No callback ever fires otherwise (docs `api.js:70-82`, `getting_started.md` "Running the callbacks"). Today `tcc_steam_update()` is called from o_fullscreensystem/Step_0.gml:4 (persistent, runs in menus; behind the same `timing_instance_step()` gate as every Step here, fine because the 2.x pump ran there too). Re-point it to `steam_api_run_callbacks()`. **Do not** move it into o_networkmanager/Step_0.gml: the manager may not exist (it is destroyed/recreated around `game_restart`, and the create/join replies must still be pumped without it). | scr_steam_safe.gml:310-313; o_fullscreensystem/Step_0.gml:4; `steam_update` yy count 0 |
| P2 | Guard must become `platform_steam() && steam_api_is_initialized()` (except the callback-registration wrapper, which keeps only `platform_steam()`, decision #11). `steam_api_is_initialized` is an extension function with no GML wrapper (API:12456) and returns a Real (0/1), not a Bool. `platform_steam()` must stay: iOS/Android/Mac-App-Store builds ship no Steam binary (check_port.py:22-23 asserts `copyToTargets == '0'` for Apple and Mobile) and the 3.0 GML wrappers only test `extension_exists("Steamworks")` (API:24764). | scr_steam_safe.gml:102-105; scr_platform.gml:17 |
| P3 | Callbacks are dispatched by ExtensionCore's `time_source_global` ticker (1-frame period), not inside `steam_api_run_callbacks()` itself: SteamAPI_RunCallbacks queues native results, the ticker then calls the GML function with `method_call`. Expect up to one frame of extra latency; nothing in the project pauses `time_source_global`. | ExtensionCore_api.gml:245 (ticker), :298-350 (dispatch) |
| P4 | `set_callback_*` registrations are **per boot** and must run from a place that re-executes after `net_game_restart()`. `net_init()` returns early when `global.net_ready` is true (scr_online_multiplayer.gml:258), so registering inside `net_init()` would be skipped on a restart. Register from `o_networkmanager/Create_0.gml` (after `net_init()`) via `net_register_steam_callbacks()` (see 6). The manager is recreated after a restart by `net_ensure_manager()` (o_loading/Create_0.gml:14, o_title/Create_0.gml:118). Re-registering is harmless: the native side overwrites its stored callback (gm_steam_matchmaking.cpp:141-153) and the old handle is released. | scr_online_multiplayer.gml:258, :311-313, :323-326; o_networkmanager/CleanUp_0.gml |
| P5 | Cross-domain id type: the Friends panel gets `_friend.lobby` from `steam_get_friends_game_info()` (removed). In 3.0 the lobby id is `SteamFriendsFriendGamePlayed.lobby_steam_id_64` (API:1851-1865), also a u64 Real. It is compared with `global.net_lobby_id` (scr_online_friends.gml:166, 305) and fed to `net_request_join`; both are int64 so `==` works, but the friends migration must keep it a number (not a string/struct). | scr_online_friends.gml:7-30 |
| P6 | Restart (decision #10): `final = steam_api_shutdown` (Steamworks.yy:20). If `game_restart()` runs it, Steam is gone for the rest of the process. Owned by the core domain (map-core.md section 7 item 1); this map adds only the lobby-side safety net in 5.5. | extensions/Steamworks/Steamworks.yy:20; gm_steam_api.cpp:307-318 |

---------------------------------------------------------------------------------------------------

## 3. Function-by-function map

Legend for "lobby id": `L` = the lobby id (for this project `global.net_lobby_id`, or the reply's `lobby_id` on the paths marked in section 5).

| 2.x | 3.0 (exact) | Result | Notes |
|---|---|---|---|
| `steam_lobby_create(type, max_members)` -> Bool | `steam_matchmaking_create_lobby(_lobby_type, _max_members, _callback)` (API:22797, DOC:140) | callback `SteamMatchmakingLobbyCreated {result, lobby_id}` | returns nothing useful (native `return 0`); see 3.1 |
| `steam_lobby_join_id(lobby_id)` -> Bool (docs) / Undefined (.yy) | `steam_matchmaking_join_lobby(_lobby_id, _callback)` (API:22829, DOC:160) | callback `SteamMatchmakingLobbyEnter {lobby_id, chat_permissions, locked, response}` | returns nothing useful; see 3.2 |
| `steam_lobby_leave()` | `steam_matchmaking_leave_lobby(_lobby_id)` (API:22984, DOC:275) | sync, no return | explicit id; takes effect immediately, others get `LobbyChatUpdate` |
| `steam_lobby_set_data(key, value)` -> Bool | `steam_matchmaking_set_lobby_data(_lobby_id, _key, _value)` (API:23104, DOC:345) | sync Bool | owner only; both args must be strings |
| `steam_lobby_get_data(key)` -> String | `steam_matchmaking_get_lobby_data(_lobby_id, _key)` (API:23135, DOC:364) | sync String | `""` for unknown key/lobby (NAT: returns `""` when `GetLobbyData` is null) |
| `steam_lobby_set_joinable(joinable)` -> Bool | `steam_matchmaking_set_lobby_joinable(_steam_id_lobby, _joinable)` (API:23420, DOC:520) | sync Bool | `_joinable` must satisfy `is_bool` |
| `steam_lobby_set_owner_id(user_id)` -> Bool | `steam_matchmaking_set_lobby_owner(_lobby_id, _new_owner_id)` (API:23005, DOC:285) | sync Bool | owner only; new owner must be a member |
| `steam_lobby_get_owner_id()` -> Int64 | `steam_matchmaking_get_lobby_owner(_lobby_id)` (API:23029, DOC:299) | sync Real (u64) | 0 if not a member / unknown lobby |
| `steam_lobby_is_owner()` -> Bool | **no equivalent**: `(steam_matchmaking_get_lobby_owner(_lobby_id) == steam_user_get_steam_id())` (API:14730) | sync | no project callers |
| `steam_lobby_get_member_count()` -> Real | `steam_matchmaking_get_num_lobby_members(_lobby_id)` (API:23053, DOC:314) | sync Real | includes the local user; 0 if unknown |
| `steam_lobby_get_member_id(index)` -> Int64 | `steam_matchmaking_get_lobby_member_by_index(_lobby_id, _member_index)` (API:23074, DOC:329) | sync Real (u64) | 0-based like 2.x; call `get_num_lobby_members` first (project does) |
| `steam_lobby_activate_invite_overlay()` -> Bool | `steam_friends_activate_game_overlay_invite_dialog(_steam_id_lobby)` (API:12480, friends.js:17) | sync, native void (returns 0) | needs the lobby id; Friends interface, not Matchmaking |
| const `steam_lobby_type_friends_only` (=1) | `SteamMatchmakingLobbyType.FriendsOnly` (=1) (API:1522-1528, DOC:812) | enum | same numeric value |
| event `lobby_created` | callback of `steam_matchmaking_create_lobby` | see 4.1 | |
| event `lobby_joined` | callback of `steam_matchmaking_join_lobby` | see 4.2 | |
| event `lobby_chat_update` | `steam_matchmaking_set_callback_lobby_chat_update(_callback)` (API:22695, DOC:32) | see 4.3 | |
| event `lobby_join_requested` | `steam_friends_set_callback_game_lobby_join_requested(_callback)` (API:13832, friends.js:985) | see 4.4 | |

### 3.1 create

Old (OLD lines ~100-160): `steam_lobby_create(type, max_members)` returned Bool "task successfully created"; async event `lobby_created {lobby_id, success, result}`; Steam selected the new lobby as "current".

New:
```gml
steam_matchmaking_create_lobby(SteamMatchmakingLobbyType.FriendsOnly, NET_MAX_LOBBY, net_on_lobby_created);
```
- `_max_members` is `Int32` (`buffer_s32`), 250 max (docs: "can not be above 250"); `NET_MAX_LOBBY` is 250 (scr_online_multiplayer.gml:16).
- **Dispatch check is best-effort.** The native sets `steam_set_last_error(...)` on every native failure path and returns without calling back: not initialised (`GMSteamworks.h:steam_guard_failed`), `steam_matchmaking_iface()` null (NAT:15-25, sets an error on both null paths), invalid API call (NAT:190-193 create, :208-211 join). The only silent return is the generated GML `if (!__available__) return;` (API:22797-22802), already excluded by the wrapper guard. `STEAM_GUARD()` clears the last error at the start of every guarded call, so read `steam_api_last_error()` immediately after the call, never later (`steam_api_run_callbacks()` also calls `STEAM_GUARD()`). What the check cannot see is an IO failure after dispatch: that is the watchdog's job (5.4).
- Steam creates the lobby *and joins it*; a `LobbyEnter_t` is generated by Steam but the extension has no persistent lobby-enter callback, so only the CreateLobby CallResult reaches GML.
- On failure `result != SteamApiResult.Ok` and `lobby_id == 0` (DOC:663-672).

### 3.2 join

Old: `steam_lobby_join_id(lobby_id)`; the HTML docs say it returns a Boolean ("API was correctly initialised", OLD:321-322), the 2.x `.yy` says `@returns {Undefined}` (Steamworks.yy:387), the project only used truthiness; event `lobby_joined {lobby_id, success, result}`; the id in the event could have modified instance bits (old docs note).

New:
```gml
steam_matchmaking_join_lobby(_lobby_id, net_on_lobby_entered);
```
- `_lobby_id`: `UInt64`, `is_numeric` check; `int64` passes. The reply's `lobby_id` is the id Steam actually reports; keep using the reply id (as the code already does with `_reply_id`).
- **`success` semantics changed for the better.** 3.0 gives the real enter response: `Success=1, DoesntExist=2, NotAllowed=3, Full=4, Error=5, Banned=6, Limited=7, ClanDisabled=8, CommunityBan=9, MemberBlockedYou=10, YouBlockedMember=11, RatelimitExceeded=15` (API:1557-1570). The project's 2.x workaround (scr_online_multiplayer.gml:1070-1088 validates member count + game_name/proto, comment says "Steam reports IO success even for a full or vanished lobby") suggests 2.x did not expose the enter response; that is **inferred from the comment**, not from 2.x source. Keep the member-count and game/proto checks as belt and braces.
- **Message mapping is part of the handler** (decision #9): DoesntExist, Full, NotAllowed -> `loc("NET_SESSION_UNAVAILABLE")`; all other non-Success responses -> `loc("NET_JOIN_FAILED")`.
- On a non-Success response you are **not** in the lobby: no leave is needed. The old unconditional `tcc_steam_lobby_leave()` on failure (line 1066) is removed (leaving a lobby the client is not in is undocumented, so the design never relies on it).
- `locked` (true = invite-only) and `chat_permissions` (always 0) are new/unused.

### 3.3 set_data / get_data

- `steam_matchmaking_set_lobby_data(_lobby_id, _key, _value)`: `_key` and `_value` are checked with `is_string` -> `show_error(..., true)` on a non-string. `net_lobby_set` already does `_value = string(_value)` and keys are literals, so fine. Limits: key <= `STEAM_MATCHMAKING_MAX_LOBBY_KEY_LENGTH` (255, API:181), value <= `STEAM_FRIENDS_CHAT_METADATA_MAX` (8192, API:77); the project already truncates descriptors to 8000/8192 bytes (scr_online_session.gml:395-401).
- 3.0 batches: "There is a slight delay before sending the data ... automatically batched". Only the owner may set. The project reads the owner's data from other members via `get_data`, and keeps its own cache `global.net_lobby_data` for the owner, so nothing relies on read-after-write of the same key by the writer.
- `steam_matchmaking_get_lobby_data` returns a String; only valid for lobbies the client knows about (joined, in a list result, or fetched with `steam_matchmaking_request_lobby_data`). After a successful join the data is available immediately (DOC join_lobby callback: "Lobby metadata is available to use immediately after receiving this"), so the enter handler reading `game_name`/`proto`/`host_name` right away is still correct.

### 3.4 owner / members

- `steam_matchmaking_get_lobby_owner` doc: "You must be a member of the lobby to access this." Returns 0 otherwise. `net_tick` only calls it while `global.net_active`.
- `steam_matchmaking_set_lobby_owner` also triggers `LobbyDataUpdate_t` for everyone (DOC:285); the project does not register `steam_matchmaking_set_callback_lobby_data_update` and instead polls the owner every `NET_REFRESH_TICKS` (30 ticks) and also resets `global.net_refresh_tick = 0` on chat-update. Optional: register `steam_matchmaking_set_callback_lobby_data_update` and set `global.net_refresh_tick = 0` when `_result.member_id == _result.lobby_id` for faster host migration. Not required for parity.
- Member iteration contract is unchanged: `n = steam_matchmaking_get_num_lobby_members(L)`, then `steam_matchmaking_get_lobby_member_by_index(L, i)` for `i = 0..n-1`. Indices are not sorted by join time in either version; the project sorts by its own `join_time`.

### 3.5 invite overlay

`steam_lobby_activate_invite_overlay()` -> `steam_friends_activate_game_overlay_invite_dialog(_steam_id_lobby)`. It lives in the Friends interface. The old doc listed a `lobby_join_requested` event as a "trigger" of this call; in 3.0 that is the separate registered callback in 4.4. The caller (scr_online_friends.gml:195) ignores the return value; the wrapper returns `true` when it called through.

---------------------------------------------------------------------------------------------------

## 4. Async event -> callback payload mapping

### 4.1 `lobby_created`  ->  callback of `steam_matchmaking_create_lobby`

| 2.x `_map[? key]` | 3.0 `_result.field` | Type / notes |
|---|---|---|
| `"event_type" == "lobby_created"` | (implicit: it is the create callback) | |
| `"lobby_id"` | `lobby_id` | u64 Real (int64). 0 on failure |
| `"success"` (bool) | `result == SteamApiResult.Ok` | `result` is an `enum SteamApiResult` (Ok=1, Fail=2, NoConnection=3, AccessDenied=15, Timeout=16, LimitExceeded=25, ...; API:314-). **Use `== SteamApiResult.Ok`, never truthiness.** Safe test: `_result.result == SteamApiResult.Ok && _result.lobby_id != 0` |
| `"result"` (EResult code) | `result` | same numeric EResult values |

Struct: `SteamMatchmakingLobbyCreated` (API:3731, decoder API:11096): `result`, `lobby_id`. Docs DOC:663.

### 4.2 `lobby_joined`  ->  callback of `steam_matchmaking_join_lobby`

| 2.x | 3.0 | Notes |
|---|---|---|
| `"lobby_id"` | `lobby_id` | the id Steam actually entered |
| `"success"` | `response == SteamMatchmakingChatRoomEnterResponse.Success` | `response` is an enum (see 3.2). **Not** `if (_result.response)` -> that accepts every failure |
| `"result"` | `response` | different enum domain (EChatRoomEnterResponse, not EResult) |
| (none) | `locked`, `chat_permissions` | new, unused |

Struct: `SteamMatchmakingLobbyEnter` (API:3747, decoder API:11154). Docs DOC:674.

### 4.3 `lobby_chat_update`  ->  `steam_matchmaking_set_callback_lobby_chat_update(callback)`

| 2.x | 3.0 | Notes |
|---|---|---|
| `"lobby_id"` | `lobby_id` | |
| `"user_id"` | `user_changed_id` | the member whose state changed |
| `"change_id"` | `user_changed_id` | old doc: "same as user_id" |
| (none) | `making_change_id` | actor of a kick/ban; can differ from `user_changed_id` |
| `"change_flags"` (1/2/4/8/16) | `chat_member_state_change` | enum bitfield `SteamMatchmakingChatMemberStateChange`: `Entered=1, Left=2, Disconnected=4, Kicked=8, Banned=16` (API:1548-1555). Same values, so `& (2|4|8|16)` still works; prefer the enum names |

Struct: `SteamMatchmakingLobbyChatUpdate` (API:3797, decoder API:11316). Docs DOC:709. The registration is global (not per lobby) and persists until `steam_matchmaking_clear_callback_lobby_chat_update()` (extension function, no args) or `steam_api_shutdown`.

### 4.4 `lobby_join_requested`  ->  `steam_friends_set_callback_game_lobby_join_requested(callback)`

| 2.x | 3.0 | Notes |
|---|---|---|
| `"lobby_id"` | `steam_id_lobby` | **different name** |
| `"success"`, `"result"` | (dropped) | always true in practice; the 3.0 struct only has two fields |
| (none) | `steam_id_friend` | the friend whose lobby it is |

Struct: `SteamFriendsGameLobbyJoinRequested` (API:1935, decoder API:5050). Docs friends.js:985 and :1220. Fired when the user chooses "Join Game" on a friend or accepts an invite while the game is running. The cold-launch path (`+connect_lobby <id>`, parsed with `parameter_string` in scr_loading.gml:409-418 and consumed in `net_tick`) is independent of the extension and needs **no change**.
The other join callback, `steam_friends_set_callback_game_rich_presence_join_requested` (API:13807, `SteamFriendsGameRichPresenceJoinRequested`), is not used by the project; no action.

---------------------------------------------------------------------------------------------------

## 5. Handler changes (what each consumer reads now vs. what the callback receives)

### 5.1 Structure

| File | Today | After migration |
|---|---|---|
| `net_handle_async_steam(_map)` (scr_online_multiplayer.gml:1017) | one switch over `_map[? "event_type"]` | split the lobby cases into four global script functions (names below). Keep the `avatar_image_loaded` and `ugc_subscribe_item` cases in whatever survives of `net_handle_async_steam` **until the friends and UGC domains migrate them**; do not delete the function or `o_networkmanager/Other_69.gml` before that. |
| objects/o_networkmanager/Other_69.gml | calls `net_handle_async_steam(async_load)` | lobby part no longer needed; file (and its event entry, o_networkmanager.yy:8) removable only after friends (avatar) and UGC (subscribe) migrations |
| objects/o_fullscreensystem/Other_69.gml | forwards `lobby_created`/`lobby_joined` when the manager is gone | **delete the whole file and its `eventNum 69` entry (o_fullscreensystem.yy:5).** Create/join callbacks are global script functions held by the native CallResult, so they fire regardless of which instances exist (this was the whole reason for the proxy). Requires P1 so the pump keeps running without the manager. |
| objects/o_title/Other_69.gml:2 | comment mentions `lobby_join_requested` | reword the comment (now the friends join-request callback); rest of file is inventory, untouched |
| objects/o_networkmanager/Create_0.gml | `net_init()` only | add `net_register_steam_callbacks();` after `net_init()` |

### 5.2 Proposed callbacks (global script functions, all state in `global.*`)

Copy-ready sketches that keep the existing logic of `net_handle_async_steam` verbatim except for the marked lines. Each starts with the same `net_ready` guard the old function had.

```gml
/// lobby_created
function net_on_lobby_created(_result) {
    if (!variable_global_exists("net_ready") || !global.net_ready) return;
    var _ok = (_result.result == SteamApiResult.Ok && _result.lobby_id != 0);   // was _map[? "success"]
    var _create_owned = global.net_create_pending;
    global.net_create_pending = false;
    var _host_wanted = global.net_host_intent;
    global.net_host_intent = false;
    if (!_create_owned || !_host_wanted || global.net_pending_join != -1
        || global.net_active || !net_enabled()) {
        net_discard_lobby_reply(_result.lobby_id, _ok);                         // new first arg: id to leave; no `net_active` gate (it moved inside)
        return;
    }
    if (_ok) {
        global.net_lobby_id = _result.lobby_id;                                // was _map[? "lobby_id"]
        // ... unchanged: net_active/join_time/owner/refresh_tick/net_refresh_members/net_become_host
    } else {
        // ... unchanged: retry in 30 s
    }
}

/// lobby_joined
function net_on_lobby_entered(_result) {
    if (!variable_global_exists("net_ready") || !global.net_ready) return;
    var _reply_id = _result.lobby_id;                                           // was _map[? "lobby_id"]
    var _ok = (_result.response == SteamMatchmakingChatRoomEnterResponse.Success); // was _map[? "success"]
    var _expected_id = global.net_join_pending_id;
    if (_expected_id == -1) { net_discard_lobby_reply(_reply_id, _ok); return; }                    // was gated by !global.net_active
    global.net_join_pending_id = -1;
    if (global.net_pending_join != _expected_id) { net_discard_lobby_reply(_reply_id, _ok); return; }
    global.net_pending_join = -1;
    if (!_ok) {
        // Not in the lobby: nothing to leave (old code called tcc_steam_lobby_leave() here, with no id available).
        net_reset_lobby_state();
        var _unavailable = (_result.response == SteamMatchmakingChatRoomEnterResponse.DoesntExist
            || _result.response == SteamMatchmakingChatRoomEnterResponse.Full
            || _result.response == SteamMatchmakingChatRoomEnterResponse.NotAllowed);
        net_flash(false, loc(_unavailable ? "NET_SESSION_UNAVAILABLE" : "NET_JOIN_FAILED"));
        return;
    }
    global.net_lobby_id = _reply_id;
    // ... unchanged until the two early-outs (members <= 0, version mismatch); there use
    //     tcc_steam_lobby_leave(_reply_id) instead of tcc_steam_lobby_leave()
}

/// lobby_chat_update
function net_on_lobby_chat_update(_result) {
    if (!variable_global_exists("net_ready") || !global.net_ready) return;
    if (!global.net_active || _result.lobby_id != global.net_lobby_id) return;
    var _flags = _result.chat_member_state_change;                              // was _map[? "change_flags"]
    var _uid = _result.user_changed_id;                                         // was _map[? "user_id"]
    if (_flags & (SteamMatchmakingChatMemberStateChange.Left | SteamMatchmakingChatMemberStateChange.Disconnected
                | SteamMatchmakingChatMemberStateChange.Kicked | SteamMatchmakingChatMemberStateChange.Banned)) {
        if (_uid == global.net_my_steam_id) { net_reset_lobby_state(); net_notice(loc("NET_DISCONNECTED")); return; }
        net_remove_player(_uid, true);
    }
    global.net_refresh_tick = 0;
}

/// lobby_join_requested
function net_on_lobby_join_requested(_result) {
    if (!variable_global_exists("net_ready") || !global.net_ready) return;
    var _lobby_id = _result.steam_id_lobby;                                     // was _map[? "lobby_id"]
    show_debug_message("[NET] Join request received for lobby: " + string(_lobby_id));
    net_request_join(_lobby_id);
}
```

`net_discard_lobby_reply` becomes `net_discard_lobby_reply(_lobby_id, _success)`:
```gml
function net_discard_lobby_reply(_lobby_id, _success) {
    // 3.0 has no implicit "current lobby": leave exactly the lobby this reply is about, even when a
    // different lobby is already active (a late reply after the watchdog fired, 5.4).
    if (_success && _lobby_id != 0 && _lobby_id != global.net_lobby_id) tcc_steam_lobby_leave(_lobby_id);
    // Only wipe the session state when no live session exists; otherwise a stray reply would destroy it.
    if (!global.net_active) net_reset_lobby_state();
}
```
Why the `net_active` gate moved *inside*: in 2.x a stray reply replaced the single current lobby, so skipping the discard while active was safe. In 3.0 it leaves the client in a second, orphan lobby (possibly as owner of an empty friends-only lobby), and the 5.4 watchdog makes that reachable: create/join times out, `net_tick` auto-hosts or another join completes, then the late reply arrives with `_ok` while `global.net_active` is already true. The `_lobby_id != global.net_lobby_id` guard prevents leaving the lobby we are really in. The `:1061` branch ("a newer invite replaced this one") is only reachable while inactive, so conditioning the reset there changes nothing.

Registration (called from `o_networkmanager/Create_0.gml` after `net_init()`, P4; also callable by the core domain after a Steam re-init):
```gml
function net_register_steam_callbacks() { tcc_steam_set_lobby_callbacks(net_on_lobby_chat_update, net_on_lobby_join_requested); }
```
The create/join callbacks are passed per call (`net_on_lobby_created` / `net_on_lobby_entered`), not registered globally.

### 5.3 Leave before the global is set (where a plain "current lobby" leave no longer works)

1. `net_discard_lobby_reply` (scr_online_multiplayer.gml:462-465, leave at :463): `global.net_lobby_id` is -1 (or another lobby). Must leave the reply's `lobby_id`.
2. `lobby_joined` `!success` (:1065-1066): `global.net_lobby_id` is still -1 and a failed response means not in the lobby: **no leave at all** (corrected from the first draft).
3. `lobby_joined` early-outs at :1080 and :1086: `global.net_lobby_id = _reply_id` was assigned at :1073 after a SUCCESSFUL enter, so `global.net_lobby_id` works, but pass `_reply_id` explicitly for clarity.

`-1` is never a valid argument: it is written with `buffer_u64` as 0xFFFF_FFFF_FFFF_FFFF. Wrappers must map `-1`/`0`/non-numeric to "no lobby" and return the old fallback.

### 5.4 Watchdog for the missing IO-failure callback

```gml
// in net_host_lobby() after tcc_steam_lobby_create succeeds:  global.net_create_started_at = current_time;
// in net_join_lobby() before issuing the join:                global.net_join_started_at   = current_time;
// in net_init(): global.net_create_started_at = 0; global.net_join_started_at = 0;
// in net_tick(), right after the Steam-gone check (5.5) and before the `!net_enabled()` early-out:
if (global.net_create_pending && current_time - global.net_create_started_at > 20000) {
    global.net_create_pending = false; global.net_host_intent = false;
    global.net_host_retry_at = current_time + 30000;
}
if (global.net_join_pending_id != -1 && current_time - global.net_join_started_at > 20000) {
    global.net_join_pending_id = -1; global.net_pending_join = -1; global.net_follow_host = false;
    net_flash(false, loc("NET_JOIN_FAILED"));
}
```
20 s is a **conservative choice**, not a documented limit: the only timeout the docs state is "a timeout of 20 seconds" for `request_lobby_list` (DOC:186). A reply that arrives after the watchdog fired is handled by the "unexplained reply" branches (`_expected_id == -1` / `!_create_owned`), which now leave that exact lobby by id (5.2).

### 5.5 Steam gone while a session is active (restart safety net, decision #10)

```gml
// net_tick(), replacing the single line `if (!platform_steam() || !tcc_steam_initialised()) return;` (:530):
if (!platform_steam()) return;
if (!tcc_steam_initialised()) {
    // Steam is gone (never started, or shut down by the extension's final function after game_restart):
    // the lobby and every pending native reply are gone with it, and no callback can arrive any more.
    if (global.net_create_pending || global.net_join_pending_id != -1 || global.net_pending_join != -1) {
        global.net_create_pending = false; global.net_join_pending_id = -1; global.net_pending_join = -1;
        global.net_host_intent = false; global.net_follow_host = false;
    }
    if (global.net_active) { net_reset_lobby_state(); net_notice(loc("NET_DISCONNECTED")); }
    return;
}
```
This is safe whichever way the runtime test goes (when Steam survives the restart the branch never runs). It does not change `net_game_restart` (:323-326): whether to add `net_leave_lobby(false)` before `game_restart()` depends on the test (unresolved #2).

---------------------------------------------------------------------------------------------------

## 6. Proposed wrapper layer (scripts/scr_steam_safe/scr_steam_safe.gml)

Design: keep the `tcc_steam_lobby_*` names. For calls made only while `global.net_active`, add an optional trailing `_lobby_id = undefined` that defaults to `global.net_lobby_id`; this leaves 8 of the callers unchanged. Create/join take callbacks (join takes an explicit id only), leave takes an explicit id where `global.net_lobby_id` is not the target. Raw `steam_matchmaking_*` / `steam_friends_*` calls stay inside this file (the repo's rule that raw Steam calls live in scr_steam_safe / scr_platform_services).

```gml
function tcc_steam_ready() { return platform_steam() && steam_api_is_initialized() != 0; }

/// undefined -> the lobby the game is in; anything not a positive number -> 0 (no lobby)
function tcc_steam_lobby_resolve(_lobby_id) {
    if (is_undefined(_lobby_id)) _lobby_id = variable_global_exists("net_lobby_id") ? global.net_lobby_id : -1;
    if (!is_numeric(_lobby_id) || _lobby_id <= 0) return int64(0);
    return _lobby_id;
}

function tcc_steam_lobby_create(_type, _max_members, _callback) {
    if (!tcc_steam_ready()) return false;
    steam_matchmaking_create_lobby(_type, _max_members, _callback);
    return steam_api_last_error() == "";          // native returns void; best-effort dispatch check (watchdog is the backstop)
}
function tcc_steam_lobby_join_id(_lobby_id, _callback) {
    if (!tcc_steam_ready()) return false;
    if (!is_numeric(_lobby_id) || _lobby_id <= 0) return false;   // explicit id only: no "current lobby" default for a join
    steam_matchmaking_join_lobby(_lobby_id, _callback);
    return steam_api_last_error() == "";
}
function tcc_steam_lobby_leave(_lobby_id = undefined) {
    if (!tcc_steam_ready()) return false;
    _lobby_id = tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby_id == 0) return false;
    steam_matchmaking_leave_lobby(_lobby_id);
    return true;
}
function tcc_steam_lobby_set_data(_key, _value, _lobby_id = undefined) {
    if (!tcc_steam_ready()) return false;
    _lobby_id = tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby_id == 0) return false;
    return steam_matchmaking_set_lobby_data(_lobby_id, string(_key), string(_value)) == true;
}
function tcc_steam_lobby_get_data(_key, _lobby_id = undefined) {
    if (!tcc_steam_ready()) return "";
    _lobby_id = tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby_id == 0) return "";
    var _value = steam_matchmaking_get_lobby_data(_lobby_id, string(_key));
    return is_string(_value) ? _value : "";
}
function tcc_steam_lobby_set_joinable(_joinable, _lobby_id = undefined) {
    if (!tcc_steam_ready()) return false;
    _lobby_id = tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby_id == 0) return false;
    return steam_matchmaking_set_lobby_joinable(_lobby_id, bool(_joinable)) == true;   // is_bool is enforced
}
function tcc_steam_lobby_set_owner_id(_user_id, _lobby_id = undefined) {
    if (!tcc_steam_ready()) return false;
    _lobby_id = tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby_id == 0 || !is_numeric(_user_id) || _user_id <= 0) return false;
    return steam_matchmaking_set_lobby_owner(_lobby_id, _user_id) == true;
}
function tcc_steam_lobby_get_owner_id(_lobby_id = undefined) {
    if (!tcc_steam_ready()) return int64(0);
    _lobby_id = tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby_id == 0) return int64(0);
    var _owner = steam_matchmaking_get_lobby_owner(_lobby_id);
    return is_numeric(_owner) ? _owner : int64(0);
}
function tcc_steam_lobby_is_owner(_lobby_id = undefined) {          // no callers today
    var _owner = tcc_steam_lobby_get_owner_id(_lobby_id);
    return _owner != 0 && _owner == steam_user_get_steam_id();
}
function tcc_steam_lobby_get_member_count(_lobby_id = undefined) {
    if (!tcc_steam_ready()) return false;                           // keep old fallback (callers use net_finite)
    _lobby_id = tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby_id == 0) return 0;
    var _count = steam_matchmaking_get_num_lobby_members(_lobby_id);
    return is_numeric(_count) ? _count : 0;
}
function tcc_steam_lobby_get_member_id(_index, _lobby_id = undefined) {
    if (!tcc_steam_ready()) return false;
    _lobby_id = tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby_id == 0) return false;
    return steam_matchmaking_get_lobby_member_by_index(_lobby_id, _index);
}
function tcc_steam_lobby_activate_invite_overlay(_lobby_id = undefined) {
    if (!tcc_steam_ready()) return false;
    _lobby_id = tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby_id == 0) return false;
    steam_friends_activate_game_overlay_invite_dialog(_lobby_id);
    return true;
}
/// Registered once per boot from o_networkmanager Create (re-registering just overwrites the native slot).
/// Guard is platform_steam() only: the set_callback natives have no STEAM_GUARD and iOS/Android/MAS have no binary.
function tcc_steam_set_lobby_callbacks(_chat_update, _join_requested) {
    if (!platform_steam()) return false;
    steam_matchmaking_set_callback_lobby_chat_update(_chat_update);
    steam_friends_set_callback_game_lobby_join_requested(_join_requested);
    return true;
}
```
Call-site edits implied: `scr_online_multiplayer.gml:437` -> `tcc_steam_lobby_create(SteamMatchmakingLobbyType.FriendsOnly, NET_MAX_LOBBY, net_on_lobby_created)`; `:453` -> `tcc_steam_lobby_join_id(_lobby_id, net_on_lobby_entered)`; `:386` keeps `tcc_steam_lobby_set_owner_id(_successor)`; `:388` keeps `tcc_steam_lobby_leave()` (`global.net_lobby_id` is still valid there because `net_reset_lobby_state()` runs after); `:463` is the rewritten `net_discard_lobby_reply(_lobby_id, _success)`; `:1066` leave is removed; `:1080`, `:1086` pass `_reply_id`. All other callers need no signature change.

`tools/check_port.py:79` currently looks for raw `steam_(inventory_|ugc_|get_achievement|set_achievement|upload_score|initialised)\w*\(` outside scr_steam_safe / scr_platform_services. It does not cover `steam_matchmaking_` / `steam_friends_` / `steam_api_`; since `initialised` will be gone after migration, that alternation should be updated by whoever owns the checker (out of scope here; map-core.md section 6 proposes a pattern).

---------------------------------------------------------------------------------------------------

## 7. Gotchas that would silently break behaviour (checklist)

1. **Void natives**: create/join/leave return `0` always. Raw return value in a wrapper = always "failed" for the two callers that test it. (SteamworksInternal_native.cpp:6167-6196, 6276-6285.)
2. **Explicit lobby id everywhere**; `-1` is written as u64 max and is never valid. Map -1/0/undefined to the old fallbacks. Passing `undefined` where a number/bool/string is required is a fatal `show_error` in the generated wrappers. A join never defaults to the current lobby.
3. **Strict arg types**: `_joinable` must be bool (use `bool(...)`; do not rely on what `<` returns); `_key`/`_value` strings; `_lobby_type` numeric; `_callback` callable.
4. **Success tests**: `result == SteamApiResult.Ok`; `response == SteamMatchmakingChatRoomEnterResponse.Success`. Both are enums, not bools.
5. **No callback on IO failure** -> watchdog (5.4) or `net_create_pending` / `net_join_pending_id` stick, hosting never retries and the Friends panel shows "connecting" forever (scr_online_friends.gml:121). The `steam_api_last_error() == ""` check only covers dispatch failures and is best-effort.
6. **Callback context**: dispatched via `with (_dummy_context) method_call(fn, args)` inside ExtensionCore's frame ticker. Use named global script functions that touch only `global.*`; this avoids any dependence on instance lifetime (the exact situation o_fullscreensystem/Other_69.gml guards against today). Passing the same script function twice only bumps a refcount in `__ext_core_function_register`.
7. **Callbacks never fire without `steam_api_run_callbacks()`** (P1) and have ~1 frame extra latency (P3).
8. **Registration lifetime** (P4): `set_callback_*` slots are single, global and overwritten by each call; register after every boot; they are cleared by `steam_api_shutdown()` (`steam_api_clear_all_callbacks`, gm_steam_api.cpp:113, called from :314). The registration wrapper must not require `steam_api_is_initialized()`.
9. **Two lobbies possible**: 2.x kept a single current lobby; Steam itself allows being in several. A stray successful create/join reply must be left by id (5.2 `net_discard_lobby_reply`), otherwise the client stays in an orphan lobby.
10. **Ownership transfer** (`set_lobby_owner`) is a request: the `get_lobby_owner` value changes after Steam round-trips; the project already polls, same as before. `set_lobby_owner` returns false for non-owners and for non-members.
11. **Steam unavailable**: desktop with Steam not running -> `steam_api_is_initialized()` false -> wrapper fallbacks. Non-Steam platforms -> `platform_steam()` false. The 3.0 GML wrappers return bare `undefined` when `extension_exists("Steamworks")` is false; never let that escape (is_numeric(undefined) false, `show_error` paths).
12. **`steam_api_last_error()` is volatile**: any later guarded call (including `steam_api_run_callbacks`) clears it. Read it immediately after `create`/`join`.
13. **`LobbyChatUpdate` field rename** (`user_changed_id`, `chat_member_state_change`) and **`GameLobbyJoinRequested.steam_id_lobby`** (not `lobby_id`): reading the wrong name on a struct yields a "variable not set" runtime error, not undefined.
14. **`o_networkmanager/Other_69.gml` also carries `avatar_image_loaded` and `ugc_subscribe_item`** - owned by the friends and UGC migrations. Do not delete the handler until both are moved. `o_fullscreensystem/Other_69.gml` is lobby-only and can be deleted now.
15. **Obsolete comment**: scr_online_multiplayer.gml:394 "Copy the requested ID while async_load is live; never retain its DS map" no longer applies (callbacks receive a struct); harmless but can be reworded.
16. **Restart**: Steam may be shut down by `final` after `game_restart()`; see 5.5. `global.net_active` can otherwise stay true forever because net_tick returns before the reset path.
17. **Enter-failure messages**: DoesntExist/Full/NotAllowed -> NET_SESSION_UNAVAILABLE, everything else -> NET_JOIN_FAILED (3.2).

---------------------------------------------------------------------------------------------------

## 8. Unused 2.x lobby identifiers (not referenced by the project; for completeness)

| 2.x | 3.0 |
|---|---|
| `steam_lobby_get_lobby_id()` | no equivalent (no current lobby): track the id yourself |
| `steam_lobby_set_type(type)` | `steam_matchmaking_set_lobby_type(_steam_id_lobby, _lobby_type)` (API:23445), returns Bool |
| `steam_lobby_send_chat_message(text)` / `_buffer(buf,size)` | `steam_matchmaking_send_lobby_chat_msg(_lobby_id, _msg, _buffer_offset, _buffer_count)` (API:23307), `_msg` is a **buffer** (text must be written with its null terminator) |
| `steam_lobby_get_chat_message_text/size/data` | `steam_matchmaking_get_lobby_chat_entry(_lobby_id, _chat_id, _out_buffer)` (API:23357) inside `steam_matchmaking_set_callback_lobby_chat_msg` (API:22720); `chat_id` is valid only inside the callback |
| `steam_lobby_list_request()` + filters | `steam_matchmaking_add_request_lobby_list_*` then `steam_matchmaking_request_lobby_list(_callback)` (API:22855), results via `steam_matchmaking_get_lobby_by_index(_index)` (API:22967); callback struct `SteamMatchmakingLobbyMatchList {lobbies_count}`; filters reset after each request |
| `steam_lobby_list_get_*`, `_list_join(index)` | `steam_matchmaking_get_lobby_data(id, key)`, `steam_matchmaking_get_lobby_owner(id)`, `steam_matchmaking_get_num_lobby_members(id)`, `steam_matchmaking_get_lobby_member_by_index(id, i)` on the id from `get_lobby_by_index`; join with `steam_matchmaking_join_lobby` |
| `steam_lobby_type_private=0, friends_only=1, public=2, invisible=3` | `SteamMatchmakingLobbyType.Private/FriendsOnly/Public/Invisible` = 0/1/2/3 (same values) |
| `steam_lobby_type_private_unique` (4) | **no equivalent** |
| `steam_lobby_list_filter_eq/ne/lt/gt/le/ge` (0/3/-1/1/-2/2) | `SteamMatchmakingLobbyComparison.Equal/NotEqual/LessThan/GreaterThan/EqualToOrLessThan/EqualToOrGreaterThan` (0/3/-1/1/-2/2, same values) |
| `steam_lobby_list_distance_filter_close/default/far/worldwide` (0..3) | `SteamMatchmakingLobbyDistanceFilter.Close/Default/Far/Worldwide` (0..3) |
| `steam_lobby_member_change_entered/left/disconnected/kicked/banned` (1/2/4/8/16) | `SteamMatchmakingChatMemberStateChange.Entered/Left/Disconnected/Kicked/Banned` |
| `steam_lobby_max_chat_message_size` (4096) | no constant; 4096-byte limit is hard-coded in the native code |

---------------------------------------------------------------------------------------------------

## 9. Unresolved / could not be settled statically

1. **Which `SteamMatchmakingChatRoomEnterResponse` a `set_lobby_joinable(false)` lobby returns** (the project caps Max Players that way, :493-496). DOC:874 documents `NotAllowed` only as "General Denied"; the project mapping (DoesntExist/Full/NotAllowed -> SESSION_UNAVAILABLE) is safe either way, but one runtime test (join a capped lobby, log `_result.response`) confirms which code appears.
2. **`game_restart()` vs `final = steam_api_shutdown`.** Not confirmable from source whether the runner runs the extension final function (and whether the pre-graphics init hook runs again) on `game_restart()`. Also unknown: whether ExtensionCore's static function map and the native-held callback registrations survive a restart, and what happens to native replies in flight across one (ExtensionCore_api.gml:334-337 `continue`s on an unknown handle without consuming the packet's args, a potential reader desync; speculative). Test: log `steam_api_is_initialized()` right after an ending -> restart with a live lobby. If Steam is shut down: add `net_leave_lobby(false)` before `game_restart()` in `net_game_restart` and have the core domain re-init Steam and call `net_register_steam_callbacks()`; 5.5 already covers the stuck-active-state symptom either way.
3. **int64 vs double for `buffer_read(buffer_u64)`.** The 3.0 docs do not say; ExtensionCore itself treats `is_int64` values as u64 (ExtensionCore_api.gml:165-168) and all lobby-domain ids come from the same read, so comparisons are mutually consistent. Doubles would lose precision above 2^53 (lobby ids are ~1.8e17), so a one-time smoke check `is_int64(steam_user_get_steam_id())` is worthwhile (map-core.md section 7 item 5).
4. **Whether `LeaveLobby` on a lobby the client is not in is a harmless no-op**: undocumented; the design avoids relying on it.
5. **Whether the owner can read `SetLobbyData` immediately after writing**: Steam behaviour, not documented by the extension; the project does not depend on it (own cache).
6. **Real Steam-side timeouts for CreateLobby/JoinLobby** are not documented; the 20 s watchdog is a tunable, conservative choice and late replies are handled by id.
7. **2.x behaviours that are inferred, not verified** (do not affect the port): that 2.x reported IO success for full/vanished lobbies (only the project comment at :1072-1073), and that 2.x returned `false` rather than something else for non-string `set_data` arguments.
8. **Rich-presence join** (`GameRichPresenceJoinRequested`) is unused by the project; if the Steam launch config uses a `connect` rich-presence key it would arrive via `steam_friends_set_callback_game_rich_presence_join_requested`, not the lobby callback. No evidence the project sets such a key.
9. `steam_api_run_callbacks` placement (P1) and the `steam_initialised` -> `steam_api_is_initialized` guard change (P2) are owned by the api/init domain; this map only states the dependency.
