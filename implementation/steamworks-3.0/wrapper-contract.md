# Wrapper contract: `scripts/scr_steam_safe` (the `tcc_steam_*` layer) for Steamworks 3.0.0

Project: `/Users/infi/Documents/Github/TheColorfulCreature`, branch `feat/steamworks-3-0`. Read-only design pass: nothing under the project was edited. This file is the single interface between (A) the ~50 call-site files and (B) the one agent that rewrites `scripts/scr_steam_safe/scr_steam_safe.gml`. Where a domain map and this contract disagree, **this contract wins**; section 1 lists every disagreement that was found and how it was settled.

Abbreviations: `SAFE` = `scripts/scr_steam_safe/scr_steam_safe.gml`; `API` = `scripts/Steamworks_API/Steamworks_API.gml` (never print its last line); `EXT` = `scripts/ExtensionCore_api/ExtensionCore_api.gml`; `SP` = `<scratchpad>/port`; maps = `SP/map-{core,social,lobby,stats,ugc,inventory,net}.final.md`; `H1`/`H2` = `SP/async-handlers-1.md` / `-2.md`. Generated data used for the tables: `SP/wc/callers.json` (every `tcc_steam_*` use outside SAFE, all files), `SP/wc/raw_identifiers.json` (every bare `steam_*`, `ov_*`, `lb_*`, `ugc_*` token outside SAFE), `SP/wc/check_port_steam.py` (the proposed gate, run on the current tree).

How to read it:

* **Part A (sections 2-9)**: for call-site agents. Every wrapper has an exact signature, a return value, the value when Steam is not ready, whether a callback can fire and its payload, and a status: **UNCHANGED** (call sites compile and behave as today), **EDIT** (call sites must change, reason given), **REMOVED** (callers must migrate), **NEW**.
* **Part B (sections 10-11)**: for the implementer of `scr_steam_safe.gml`: infrastructure code, per-domain implementation sources and the overrides to apply to them.
* **Part C (sections 12-17)**: handler replacement, constants, `tools/check_port.py`, self-check, final tables, open questions.

---

## 1. Decisions on cross-map conflicts (one line each)

| # | Conflict | Decision |
|---|---|---|
| X1 | **Callback form.** Stats map hands `method(...)` closures to `steam_userstats_*`; ugc/lobby/inventory/net maps hand Steam named globals; core map says "bind to a struct". | **Steam only ever receives ONE private named function, `tcc_steam_relay`** (defined in SAFE). Per-request context lives in a GML registry (persistent listener / single-flight slot / key-indexed entry / serial queue). User callbacks are invoked by our code (`__tcc_steam_deliver`), under an owner check and try/catch. No closure, `method()`, literal or instance function is ever passed to a `steam_*` extension function (enforced by `check_port.py`, section 14). Result: the `int64(ptr(callable))` uniqueness question (map-inventory U2 / map-ugc U2 / H1 1.4) **cannot affect correctness**: the registry (`EXT:271-290`) stays correct whether `ptr(tcc_steam_relay)` is stable (ref-count path) or not (separate entries), because only a collision between DIFFERENT callables is harmful and there is exactly one callable. Residual smoke test only (section 15, S-7). |
| X2 | **Registration guard** for `steam_*_set_callback_*`: lobby map `platform_steam()` only; inventory map also `steam_api_is_initialized()`. | **`platform_steam()` only** for every set/clear of a persistent native callback (the natives only store the pointer, no STEAM_GUARD; map-lobby decision 11), plus **re-registration on every Steam-ready edge** (section 10.4). All per-call async functions and all getters use `tcc_steam_ready()`. |
| X3 | **Inventory result-ready slot**: owner-only register/clear in `Create_0`/`CleanUp_0` vs boot-time relay. | **Owner-only rule kept, implemented in GML on top of the relay.** `tcc_steam_inventory_set_callback_result_ready(_cb)` / `..._clear_callback_result_ready()` keep the names and edit sites of map-inventory section 7 (`o_getallinventoryitems/Create_0.gml` after line 9, `CleanUp_0.gml` inside `if (owns_inventory)`), but they set/clear the `inv_result_ready` *listener* and (un)register the native slot with the relay. Per-call exchange/drop results are routed by `result_handle` to their own entry first, otherwise to the listener (this reproduces "per-call callbacks never reach the global slot", map-inventory 0.2). |
| X4 | **Inventory return type**: handle-or-`-1` (inventory map) vs bool (H1 2.3). | **Handle `>= 1` or `-1`** for `get_all_items`, `exchange_items`, `trigger_item_drop` (the trade code validates handles; o_title ignores the value). `request_prices` returns **bool**. |
| X5 | **Avatar unavailable value** `-1` vs `0`, and who retries. | Wrapper returns exactly one of: **`> 0` ready handle, `TCC_AVATAR_PENDING` (-1) not available yet (raw Steam `0` or `-1` for small/medium), `TCC_AVATAR_NONE` (0) Steam not ready / invalid id**. Old fallback `-1` becomes `0`; the three consumer families are normalised in the same change (section 4.2). The `avatar_image_loaded` callback is **NOT registered**; consumers poll with a bounded retry (`TCC_AVATAR_RETRY_MAX` x `TCC_AVATAR_RETRY_MS`), and the wrapper asks Steam to fetch unknown users (`steam_friends_request_user_information(id, false)`, throttled). This removes the single-slot fan-out problem of map-social 0.4 / map-stats 8. |
| X6 | **`tcc_steam_ready()`** inlined in four maps with slightly different text. | Defined **once** in SAFE: `platform_steam() && steam_api_is_initialized() != 0`. `tcc_steam_initialised()` is `bool(tcc_steam_ready())`. Nobody else re-spells the expression. |
| X7 | **`Other_69` deletion order.** | All 18 `objects/*/Other_69.gml` files and their `"eventNum":69,"eventType":7` entries in the object `.yy` go **in the same change** as the wrapper swap (the 2.x event can no longer fire, so each handler is dead code and several are still reading `async_load`). Order inside the change: SAFE first, then call sites (section 12 gives the replacement for each handler), then delete handler + yy entry, then `check_port.py`. |
| X8 | **Persona name**: async `tcc_steam_get_user_persona_name` + event vs sync. | One function: `tcc_steam_get_user_persona_name_sync(_id)` (UNCHANGED name, 3 callers) returns `""` while unknown and issues a throttled `steam_friends_request_user_information(id, true)`. The async wrapper is REMOVED (8 uses migrate to a polling lookup from Alarm/Step, never Draw). map-social's `tcc_steam_user_name` is this same function. |
| X9 | **Leaderboard rows**: stats map has callers call `steam_friends_get_friend_persona_name` inside the callback (a raw call outside SAFE). | Wrapper delivers **normalised rows `{steam_id (int64), name, score, rank}`** (name resolved inside SAFE). Callers never touch `SteamUserStatsDownloadedLeaderboardEntry`. |
| X10 | **Pump owner and gap.** | Pump = `tcc_steam_update()` called from `objects/o_fullscreensystem/Step_0.gml:4` (**unchanged line**, persistent object, runs in menus). Known gap, accepted: `o_endingreq/Create_0.gml:3` destroys the object until `o_loading/Create_0.gml:13` recreates it; native results simply stay queued in Steam meanwhile. A global-time-source pump was considered and **not adopted** (restart semantics unverified). `tcc_steam_register_callbacks(true)` is called from `o_fullscreensystem/Create_0.gml` (NEW line, runs again after every `game_restart` because the object is recreated). |
| X11 | **Game-restart / `final=steam_api_shutdown`** (map-core 7.1, not settleable offline). | Contract is safe under all three outcomes: all registry state lives in `global.tcc_steam` (re-created lazily if missing); persistent natives are re-registered on every ready edge and on the forced call from `o_fullscreensystem/Create_0`; per-call entries are swept after their TTL; a Steam-lost edge fails the leaderboard queue and drops other entries (section 10.4). Mitigation choice (blank `final` vs re-init) stays the user's decision. |
| X12 | **Constants**: old names removed by 3.0. | Replacement constants get new `TCC_`-prefixed names where a project-level alias is useful (`TCC_OVERLAY_*`, `TCC_STEAM_AVATAR_*`, `TCC_AVATAR_*`, `TCC_NET_SEND_*`); UGC/leaderboard/lobby call sites use the 3.0 enums directly (`SteamApiResult.Ok`, ...). The stale-name gate in `check_port.py` keeps the old names out (section 10). |
| X13 | **Unavailable-value for ids / counts.** Old fallbacks mixed `false`, `0`, `int64(0)`. | Ids -> `int64(0)`; counts -> `0`; strings -> `""`; arrays -> `[]`; booleans -> `false`; handles -> `-1`; `tcc_steam_get_app_id()` keeps `false` (core map: `!= 1749610` must stay true when Steam is down). |
| X14 | **Raw calls in `scr_platform_services`** (`steam_get_achievement`, `steam_set_achievement`, `steam_upload_score_ext`). | Moved behind wrappers (`tcc_steam_get_achievement`, `tcc_steam_set_achievement`, `tcc_steam_upload_score`). The `scr_platform_services` exemption in `check_port.py` is dropped; only `scr_steam_safe` may contain raw Steam calls. |

---

# PART A: the call-site contract (sections 2-9)

## 2. Conventions every call site must follow

### 2.1 Steam ids

* **A Steam id (user, lobby, published file, owner, sender, leaderboard user) is a plain 64-bit integer, NOT a `SteamId` struct.** Verified: `steam_user_get_steam_id()` returns `buffer_read(buffer_u64)` (API:14730-14742); every `_steam_id*` parameter is `UInt64`, `is_numeric`-checked and written with `buffer_u64` (e.g. API:13158, 13252, 13688, 13735); result-struct fields `lobby_id`, `steam_id_user`, `owner_steam_id`, `steam_id_remote`, `user_changed_id` are `buffer_u64` reads (decoders API:11096, 9034, ...). The `SteamId` struct exists only as the return of `steam_user_decode_steam_id` (API:14748), which the project does not use. No wrapper in this contract returns or accepts a `SteamId` struct.
* **In memory: `int64`.** Compare with `==`. Test "is a usable id" with `tcc_steam_id_valid(_v)` (`is_numeric(_v) && _v > 0`). `0` means "no id". `-1` is never an id (it would be written as u64 max).
* **Keys, text and files: `string(id)`.** ds_map / struct keys (`string(_id)`, as `global.net_avatars`, `avatar_sprites`, `global.net_ugc_failed` already do), lobby data, session-descriptor JSON and save files carry the id as a **decimal string**; parse back with the existing `net_parse_id(_text)` (`scripts/scr_online_session/scr_online_session.gml:84-91`). JSON numbers must never carry an id (a double holds 2^53 = 9.0e15; Steam64 ids are about 7.6e16, lobby ids about 1.8e17).
* **Never `real(id)`.** It rounds ids above 2^53. The two known offenders (`objects/o_onlineleaderboards/Other_69.gml:35`, `objects/o_onlineleaderboardsmini/Other_69.gml:39`) disappear with those files; the stale gate has no rule for `real(` so reviewers must check.
* **Wrappers normalise at the boundary.** Every wrapper that returns an id returns `int64(...)` via `__tcc_steam_id(_v)` (`is_numeric(_v) ? int64(_v) : int64(0)`; plain `int64(undefined)` would throw). Every wrapper that takes an id rejects non-numeric / `0` / negative **before** calling the 3.0 function, because the generated 3.0 wrappers call `show_error(..., true)` (game abort) on a non-number and where 2.x coerced silently.
* **Open item (single):** that `buffer_read(buffer_u64)` hands back a GameMaker `int64` (not a double) is inferred from the decoders and from `EXT:165-168` (which treats `is_int64` values as u64), not run. `tcc_steam_register_callbacks` logs a warning and the self-check asserts `is_int64(steam_user_get_steam_id())` when Steam is up.

### 2.2 Return values and "Steam not ready"

* `tcc_steam_ready()` false (desktop without Steam, Steam not initialised, QA/self-check/mobile-smoke builds, **and every iOS / Android / Mac App Store / GX build, which contain no Steam binary: `Steamworks.yy` `ConfigValues` Apple/Mobile `copyToTargets "0"`, asserted by `check_port.py:22-23`**) => the wrapper does **not call any `steam_*` function** and returns its documented fallback immediately. This is also the answer to the startup crash in `docs/release/STATUS.md:27` (`steam_inventory_get_all_items` without Steam): in 3.0 the native itself returns `-1` when not initialised (map-inventory 4), and the wrapper never reaches it.
* Booleans from natives arrive as `1.0/0.0`; wrappers return real GML `bool` (`bool(...)`) for every yes/no question so `is_bool` and `===` style tests are safe.
* Getters never return `undefined` (the GML wrappers of 3.0 return `undefined` when `extension_exists("Steamworks")` is false and some natives return `undefined` for unknown names): wrappers map `undefined` to the documented fallback.
* Action wrappers return **"attempted"**: `true` (or a handle `>= 1`) when the 3.0 call was issued, `false` (or `-1`) when it was not. A `true` never proves success; success arrives through the callback or a later getter.

### 2.3 Asynchronous wrappers (the callback convention, project-wide)

1. **Signature shape:** `tcc_steam_x(<args>, _callback, _owner = noone)`. `_callback` may be a script function, a `method(ctx, fn)` or a function literal: it is called by our relay, never by Steam.
2. **Never synchronous, never on a `false` return.** If the wrapper returns `false`/`-1`, the callback will **never** be called (no failure struct is faked). If it returns `true`, the callback is called **later, from the Steam pump** (the next `time_source_global` tick after `tcc_steam_update()` ran `steam_api_run_callbacks()`; `EXT:245,340-350`), never inside the caller's own event and never before the wrapper returned.
3. **`_owner`** = the requesting instance (`id` from an object event) or `noone` (default; scripts, global functions). When the result arrives and `_owner != noone && !instance_exists(_owner)` the result is **dropped silently**. A function literal written directly inside an instance event is bound to that instance by GameMaker: it is allowed **only together with `_owner = id`**.
4. **Context** travels in a struct, because literals do not capture locals: `method({inst: id, token: _t}, function(_r) { if (inst.token != token) return; ... })`. Inside the body `self` is the struct; reach the instance with `inst.var` or `with (inst) { }`. **Token rule:** the *caller* bumps its own request counter before each request and compares it in the callback (latest wins). The wrappers never coalesce or cancel.
5. **Deadline rule:** a callback **may never arrive** for most 3.0 calls (IO failure drops the callback, `steam_async_common.h:11-44`; a failed dispatch returns early; Steam down). Each wrapper below states its guarantee: **G** = the wrapper itself calls back exactly once (success payload or documented failure value, including its own 20 s watchdog); **N** = may never call back, the caller keeps its own deadline (value given). UI states must not wait on an N wrapper without a deadline.
6. **Errors are isolated.** The relay wraps every user-callback invocation in `try/catch` (an exception escaping the extension's time-source tick would abort the game and desync the packet reader, `EXT:300-361`). A throwing callback is logged (`[STEAM] callback failed: ...`) and counted; other callbacks still run.
7. **Payload:** either the raw 3.0 result struct (documented per wrapper; fields are read, never mutated) or a normalised value; no callback ever receives a `ds_map`, `async_load`, or `event_type`.

### 2.4 Pump, registration, who calls what

* `tcc_steam_update()` (UNCHANGED name, 0 args): called every simulation tick from `objects/o_fullscreensystem/Step_0.gml:4` (`if (platform_steam()) tcc_steam_update();`, unchanged). Does: ready-edge detection, `steam_api_run_callbacks()`, throttled `steam_userstats_store_stats()` flush, leaderboard-queue watchdog, registry sweep. **Nobody else calls `steam_api_run_callbacks()` and nobody else adds a pump.**
* `tcc_steam_register_callbacks(_force = false)` (NEW, idempotent): (re)registers `tcc_steam_relay` with every persistent native slot that currently has a listener (`platform_steam()` guard only), and logs one-time diagnostics. Callers: `objects/o_fullscreensystem/Create_0.gml` (`tcc_steam_register_callbacks(true);`, runs again after each `game_restart` because the object is recreated by `o_loading`), `tcc_steam_update()` on each ready edge, and the `set_*callback*` wrappers when they add a listener. Call sites do not need to call it anywhere else.
* `tcc_steam_relay(_r)` is **private to SAFE**: no file outside SAFE may reference it (gate 4b in section 14).

### 2.5 Naming rules

* `tcc_steam_<old name>` is kept wherever the semantics still fit. A new capability gets `tcc_steam_<verb>_<noun>`. Private helpers start `__tcc_steam_` and are not callable from outside SAFE.
* Constants: `TCC_STEAM_*` (platform/limits), `TCC_AVATAR_*`, `TCC_OVERLAY_*`, `TCC_NET_SEND_*`.
* Raw 3.0 identifiers (`steam_<interface>_...(`) exist only inside `scr_steam_safe.gml`. 3.0 **enums and struct constructors** (`SteamApiResult`, `SteamMatchmakingLobbyType`, `SteamUgcQuery`, `new SteamInventoryItemDefQuantity()`) are data, compile on every platform (the API script is not config-gated), and may appear anywhere.


---


Legend. **NR** = value returned when `tcc_steam_ready()` is false (no Steam call is made). **Cb** = callback guarantee (**G** the wrapper always calls back exactly once; **N** may never call back, caller keeps a deadline; **-** no callback). Status: **U** UNCHANGED, **E** EDIT, **R** REMOVED, **NEW**. "n uses" is from `SP/wc/callers.json`; the full file lists are in section 17.

## 3. Core, identity, apps

| Wrapper | St | 3.0 call (inside SAFE) | Returns | NR | Notes |
|---|---|---|---|---|---|
| `tcc_steam_ready()` | NEW | `platform_steam() && steam_api_is_initialized() != 0` | bool | false | The only place this expression is spelled. Public: call sites may use it instead of `platform_steam() && tcc_steam_initialised()`. |
| `tcc_steam_initialised()` | U (29 uses, 18 files) | `bool(tcc_steam_ready())` | bool | false | Replaces `steam_initialised()`. The 77 internal `platform_steam() && steam_initialised()` guards in SAFE become `tcc_steam_ready()`. |
| `tcc_steam_init()` | U (1 use: `o_profilepicture/Create_0.gml:7`) | same as `tcc_steam_initialised()` | bool | false | 3.0 initialises itself before the first frame (native pre-graphics hook, `gm_steam_api.cpp:206-219`); nothing to call. `steam_api_init` is hidden and is NOT used. Kept only so the one caller compiles. |
| `tcc_steam_update()` | U (1 use: `o_fullscreensystem/Step_0.gml:4`) | section 10.4 | bool pumped | false | The only pump. |
| `tcc_steam_register_callbacks(_force = false)` | NEW | section 10.4 | bool | false | Idempotent; see 2.4. |
| `tcc_steam_get_app_id()` | U (41 uses, 40 files) | `steam_utils_get_app_id()` | real (uint32) | **`false`** | Keep the `false` fallback: `!= 1749610` must stay true and `= 1749610` false when Steam is down. The value is the *launching* app (demo 1749610), not the extension option 1651680. `global.appid` (`o_title/Create_0.gml:28`) is overwritten with this at every o_title Create and must stay numeric. |
| `tcc_steam_get_user_steam_id()` | U sig (8 uses) | `int64(steam_user_get_steam_id())` | **int64** | `int64(0)` | Also `int64(0)` if the GML wrapper returned `undefined`. |
| `tcc_steam_is_user_logged_on()` | U (3) | `bool(steam_user_logged_on())` | bool | false | |
| `tcc_steam_get_persona_name()` | U (5) | `steam_friends_get_persona_name()` | string | `""` | Raw native, `undefined`-proof (`is_string` else `""`). |
| `tcc_steam_is_overlay_enabled()` | U (1) | `bool(steam_utils_is_overlay_enabled())` | bool | false | Can be false for a few seconds after start. |
| `tcc_steam_user_owns_dlc(_app_id)` | U (13 uses, 6 files) | `bool(steam_apps_is_subscribed_app(_app_id))` | bool | false | `_app_id` must be numeric else `false` (3.0 raw native, no coercion). "Owns", not "installed". |
| `tcc_steam_user_installed_dlc(_app_id)` | U (1, commented out) | `bool(steam_apps_is_dlc_installed(_app_id))` | bool | false | |
| `tcc_steam_send_screenshot(_abs_file, _w, _h)` | E (0 callers) | `steam_screenshots_add_screenshot_to_library(_abs_file, "", _w, _h)` | handle `> 0`, else `false` | false | 4th-arg shape changed: the file must be an **absolute** JPG/PNG/TGA, `_w/_h > 0`. Import result would arrive via `steam_screenshots_set_callback_screenshot_ready`, which is **not registered** (no caller). |

## 4. Social: overlay, friends, persona, avatars, images, rich presence

### 4.1 Wrappers

| Wrapper | St | 3.0 call | Returns | NR | Notes |
|---|---|---|---|---|---|
| `tcc_steam_activate_overlay(_dialog)` | **E** (2 uses) | `steam_friends_activate_game_overlay(string(_dialog))` | bool issued | false | Callers replace `ov_friends` / `ov_achievements` with `TCC_OVERLAY_FRIENDS` (`"friends"`) / `TCC_OVERLAY_ACHIEVEMENTS` (`"achievements"`). Lowercase per Valve docs; runtime acceptance unproven (map-social D5): if the overlay does not open, change the two macros to `"Friends"` / `"Achievements"`. |
| `tcc_steam_activate_overlay_user(_dialog, _steam_id)` | U (1) | `steam_friends_activate_game_overlay_to_user(string(_dialog), _steam_id)` | bool issued | false | `_steam_id` int64 > 0 else `false`. Caller passes the literal `"steamid"`. |
| `tcc_steam_activate_overlay_browser(_url)` | U (5) | `steam_friends_activate_game_overlay_to_web_page(string(_url), SteamFriendsOverlayToWebpageMode.Default)` | bool issued | false | The 2nd argument is mandatory in 3.0; SAFE supplies it. |
| `tcc_steam_activate_overlay_store(_app_id)` | U (1) | `steam_friends_activate_game_overlay_to_store(_app_id, SteamFriendsOverlayToStoreFlag.None)` | bool issued | false | Flag is mandatory in 3.0; SAFE supplies it. |
| `tcc_steam_lobby_activate_invite_overlay(_lobby_id = undefined)` | U (1) | `steam_friends_activate_game_overlay_invite_dialog(lobby)` | bool issued | false | `undefined` -> `global.net_lobby_id`; no lobby -> `false`. |
| `tcc_steam_set_rich_presence(_key, _value)` | U (78 uses, 2 files) | `steam_friends_set_rich_presence(string(_key), string(_value))` | bool (native 1/0) | false | `""` value deletes the key. Keys `steam_display`, `steam_player_group`, `steam_player_group_size` are Steam-reserved strings: unchanged. |
| `tcc_steam_get_friend_rich_presence(_steam_id, _key)` | U (2) | `steam_friends_get_friend_rich_presence(_steam_id, string(_key))` | string | `""` | `undefined` -> `""`. |
| `tcc_steam_get_friends_game_info()` | U (1) | composed: `steam_friends_get_friend_count(SteamFriendsFriendFlag.Immediate)`, `steam_friends_get_friend_by_index(i, flags)`, `steam_friends_get_friend_game_played(id)`, `steam_friends_get_friend_persona_name(id)` | array of `{friendId: int64, gameId: (game_id & 0xFFFFFF), lobbyId: int64 (lobby_steam_id_64), name: string}`, only friends currently in a game | `[]` | Same legacy shape `net_friends_list()` (`scr_online_friends.gml:7-30`) reads. Called every 90-120 frames; local data only. |
| `tcc_steam_user_set_played_with(_steam_id)` | U (1: `scr_online_multiplayer.gml:805`) | `steam_friends_set_played_with(_steam_id)` | bool issued | false | **Guard `is_numeric(id) && id > 0`**: 3.0 aborts the game on a non-number. The id must be the int64 `steam_id_remote` of the packet sender (net domain obligation). |
| `tcc_steam_get_user_persona_name_sync(_steam_id)` | U name (3 uses), semantics tightened | `steam_friends_get_friend_persona_name(id)` + throttled `steam_friends_request_user_information(id, true)` | string, **`""` while unknown** (also maps `"[unknown]"` to `""`) | `""` | Callers keep their placeholder ("Unknown") and overwrite only on a non-empty result. Throttle: one request per id per `TCC_STEAM_PERSONA_RETRY_MS` (5000). **Never call from a Draw event**; poll from Alarm / throttled Step. No callback exists; names arrive in Steam's cache and the next poll sees them. |
| `tcc_steam_get_user_persona_name(_steam_id)` | **R** (8 uses, 5 files) | n/a | n/a | n/a | Async + `Other_69` is gone. Migrate to `tcc_steam_get_user_persona_name_sync` polled (section 12 rows 15-16: `o_customlevelsbrowser`, `o_customlevelworkshopbuttonplay`). Gate: `REMOVED_WRAPPERS`. |
| `tcc_steam_get_user_avatar(_steam_id, _size)` | **E** (5 uses incl. 1 comment) | `steam_friends_get_small/medium/large_friend_avatar(id)` chosen by `_size` (default branch = small, exactly as 2.x `steam_user.cpp:252-273`) | `> 0` ready handle; `TCC_AVATAR_PENDING` (-1) if Steam returned `0` or `-1`; `TCC_AVATAR_NONE` (0) | `TCC_AVATAR_NONE` (**was -1**) | See 4.2. `_size` is `TCC_STEAM_AVATAR_SMALL/MEDIUM/LARGE` (0/1/2); `steam_user_avatar_size_*` no longer exist. For a non-local id the wrapper also issues a throttled `steam_friends_request_user_information(id, false)` so Steam fetches the avatar. |
| `tcc_steam_image_get_size(_image)` | U (4) | `steam_utils_get_image_size(handle)` | `[w, h]` or `undefined` | `undefined` | 3.0 returns a struct; SAFE adapts. `undefined` for handle `<= 0`. |
| `tcc_steam_image_get_rgba(_image, _buffer, _size = 0)` | U (4) | `steam_utils_get_image_rgba(handle, buffer)` | bool | false | `_size` is **ignored**; the buffer must be exactly `w*h*4` bytes (size it from `tcc_steam_image_get_size`, never a hard-coded avatar size). |
| `tcc_steam_image_to_sprite(_image)` | NEW | get_size + get_rgba + `surface_create`/`buffer_set_surface`/`sprite_create_from_surface` | sprite id, or `-1` | `-1` | **The caller owns the sprite** (`sprite_delete`). Replaces the four local copies: `steam_image_create_sprite` in `o_onlineleaderboards/Create_0.gml`, `o_onlineleaderboardsmini/Create_0.gml`, `o_profilepicture/Create_0.gml`, and `net_avatar_from_image` (`scr_online_friends.gml:49`). Rejects dimensions `<= 0` or `> 512`. |

### 4.2 Avatar protocol (one contract for all consumers)

```
var h = tcc_steam_get_user_avatar(id, TCC_STEAM_AVATAR_MEDIUM);
if (h > 0)                          -> build/own a sprite with tcc_steam_image_to_sprite(h)
else if (h == TCC_AVATAR_PENDING)   -> retry later: at most TCC_AVATAR_RETRY_MAX (8) times, TCC_AVATAR_RETRY_MS (1000) apart, from Alarm/Step; then settle on "no avatar"
else  (h == TCC_AVATAR_NONE)        -> settle on "no avatar" now (Steam not ready / invalid id)
```
Never cache a non-positive handle permanently (pre-existing weakness of `net_avatar_sprite`). Consumers that must change in the same commit: `scr_online_friends.gml:67-85` (`net_avatar_sprite`: `PENDING` -> its existing "-2 loading" state **plus a poll**; delete `net_friends_avatar_loaded` and the `avatar_image_loaded` case of `net_handle_async_steam`, `scr_online_multiplayer.gml:1135-1137`), `objects/o_onlineleaderboards` and `...mini` (rows callback, section 12), `objects/o_profilepicture/Create_0.gml:36` (test `av > 0`, poll from Step until ready or retry budget spent), comment-only `objects/o_version/Draw_0.gml:36`. The two leaderboard objects currently read `0` as pending and `-1` as none: **opposite to the new contract**, so they must be converted, not just renamed.

## 5. Lobbies (matchmaking)

`L` = lobby id. Optional trailing `_lobby_id = undefined` resolves to `global.net_lobby_id` (never `-1`; `-1`, `0`, non-numbers -> no lobby -> NR value). Details and rationale: map-lobby sections 3-7.

| Wrapper | St | 3.0 call | Returns | NR | Cb / payload |
|---|---|---|---|---|---|
| `tcc_steam_lobby_create(_type, _max_members, _callback, _owner = noone)` | **E** (1: `scr_online_multiplayer.gml:437`) | `steam_matchmaking_create_lobby(_type, _max, tcc_steam_relay)` | bool issued (= `steam_api_last_error() == ""` read immediately after the call; native is void) | false | **N** (caller watchdog 20000 ms, map-lobby 5.4). `_callback(_r)`, `_r` = `SteamMatchmakingLobbyCreated {result, lobby_id}`; success = `_r.result == SteamApiResult.Ok && _r.lobby_id != 0`. **Persistent listener**: stored per call (last writer wins), **not consumed**: a late reply after the caller gave up still reaches it (required by `net_discard_lobby_reply`). Call site passes `SteamMatchmakingLobbyType.FriendsOnly` instead of `steam_lobby_type_friends_only`. |
| `tcc_steam_lobby_join_id(_lobby_id, _callback, _owner = noone)` | **E** (1: `:453`) | `steam_matchmaking_join_lobby(id, tcc_steam_relay)` | bool issued | false | **N** (20000 ms). `_r` = `SteamMatchmakingLobbyEnter {lobby_id, chat_permissions, locked, response}`; success = `_r.response == SteamMatchmakingChatRoomEnterResponse.Success`; map DoesntExist/Full/NotAllowed -> `NET_SESSION_UNAVAILABLE`, others -> `NET_JOIN_FAILED`. `_lobby_id` is required (no current-lobby default), numeric `> 0`. Persistent listener `lobby_entered`. |
| `tcc_steam_lobby_leave(_lobby_id = undefined)` | U for `:388`; **E** at `:463`, `:1080`, `:1086` (pass the reply id) and `:1066` (**delete**: a non-Success enter means not in the lobby) | `steam_matchmaking_leave_lobby(L)` | bool issued | false | - |
| `tcc_steam_lobby_set_data(_key, _value, _lobby_id = undefined)` | U (1) | `steam_matchmaking_set_lobby_data(L, string(_key), string(_value))` | bool | false | Owner only. |
| `tcc_steam_lobby_get_data(_key, _lobby_id = undefined)` | U (6) | `steam_matchmaking_get_lobby_data(L, string(_key))` | string | `""` | |
| `tcc_steam_lobby_set_joinable(_joinable, _lobby_id = undefined)` | U (1) | `steam_matchmaking_set_lobby_joinable(L, bool(_joinable))` | bool | false | `is_bool` is enforced by 3.0, SAFE coerces. |
| `tcc_steam_lobby_set_owner_id(_user_id, _lobby_id = undefined)` | U (1) | `steam_matchmaking_set_lobby_owner(L, id)` | bool | false | id numeric `> 0`. |
| `tcc_steam_lobby_get_owner_id(_lobby_id = undefined)` | U (2) | `steam_matchmaking_get_lobby_owner(L)` | **int64** | `int64(0)` | `0` if not a member. |
| `tcc_steam_lobby_is_owner(_lobby_id = undefined)` | U (0 callers) | `owner != 0 && owner == steam_user_get_steam_id()` | bool | false | |
| `tcc_steam_lobby_get_member_count(_lobby_id = undefined)` | U (1) | `steam_matchmaking_get_num_lobby_members(L)` | real | **`0`** (was `false`) | Includes the local user. |
| `tcc_steam_lobby_get_member_id(_index, _lobby_id = undefined)` | U (1) | `steam_matchmaking_get_lobby_member_by_index(L, _index)` | **int64** | **`int64(0)`** (was `false`) | 0-based. |
| `tcc_steam_set_lobby_callbacks(_chat_update, _join_requested)` | NEW (called from `net_register_steam_callbacks()` in `o_networkmanager/Create_0.gml` after `net_init()`) | `steam_matchmaking_set_callback_lobby_chat_update(tcc_steam_relay)`, `steam_friends_set_callback_game_lobby_join_requested(tcc_steam_relay)` | bool | false (only `platform_steam()` is tested) | Persistent listeners `lobby_chat_update`, `lobby_join_requested`. `_chat_update(_r)`, `_r` = `SteamMatchmakingLobbyChatUpdate {lobby_id, user_changed_id, making_change_id, chat_member_state_change}`; `_join_requested(_r)`, `_r` = `SteamFriendsGameLobbyJoinRequested {steam_id_friend, steam_id_lobby}` (**not** `lobby_id`). Callbacks must be **named global script functions** that touch only `globals` (they run for the whole session, `_owner` is always `noone`). Re-calling replaces the listeners and re-registers. |

## 6. Networking (legacy P2P -> Networking Messages)

All details and rationale: map-net sections 3-5. `NET_PROTOCOL` 2 -> 3 is part of the same release (map-net D11).

| Wrapper | St | 3.0 call | Returns | NR | Notes |
|---|---|---|---|---|---|
| `tcc_steam_net_packet_receive(_buffer)` | **E** (1: `scr_online_multiplayer.gml:693`) | `steam_networking_messages_receive_messages_on_channel(0, _buffer, 1)` | the first `SteamNetworkingMessage` struct `{offset, size, steam_id_remote, ...}` or `undefined` | `undefined` | Payload is already **in `_buffer` at offset 0** (count 1). `_buffer` must be a **fixed 524288-byte buffer on Steam builds** (`global.net_recv_buffer`, `scr_online_multiplayer.gml:302`: EDIT to `buffer_create(platform_steam() ? STEAM_NETWORKING_SOCKETS_MAX_MESSAGE_SIZE_SEND : 1024, buffer_fixed, 1)`). Read `_message.size` and `_message.steam_id_remote` (int64) from the struct. Loop `while (!is_undefined(_m = ...))` is not legal GML: assign then test, as in map-net 5.2. |
| `tcc_steam_net_packet_send(_steam_id, _buffer, _size, _flags = undefined)` | **E** (1: `scr_online_multiplayer.gml:606`) | `steam_networking_messages_send_message_to_user(id, _buffer, flags, 0, 0, count) == SteamApiResult.Ok` | bool, `true` **only if** the result is `Ok` (queued, not delivered) | false | `_size` is **mandatory** (omitted count would send the whole allocated buffer); `count = min(_size, buffer_get_size)`, `< 1` -> `false`. Default flags `TCC_NET_SEND_RELIABLE`. `scr_online_levelshare.gml:177` depends on `false` for LimitExceeded/NoConnection. |
| `tcc_steam_net_close_p2p_session(_steam_id)` | U (2) | `steam_networking_messages_close_session_with_user(id)` | bool | false | id numeric `> 0`. |
| `tcc_steam_net_set_session_request_callback(_callback)` | NEW (replaces `..._set_auto_accept_p2p_sessions`; call site `scr_online_multiplayer.gml:532-536`) | `steam_networking_messages_set_callback_session_request(tcc_steam_relay)` | bool | false | Persistent listener `net_session_request`. `_callback(_r)`, `_r` = `SteamNetworkingMessagesSessionRequest {steam_id_remote}`. **Named global script function; body only queues the id** (map-net 3: decision in `net_tick`). |
| `tcc_steam_net_accept_session(_steam_id)` | NEW | `steam_networking_messages_accept_session_with_user(id)` | bool | false | |
| `tcc_steam_net_clear_session_callbacks()` | NEW (only `o_networkmanager/CleanUp_0.gml` restart branch, map-net D10; optional) | `steam_networking_messages_clear_callback_session_request()` and `..._session_failed()` | bool | false | Also removes the `net_session_request` listener. Never call the raw clear natives elsewhere. |
| `tcc_steam_net_packet_get_data`, `tcc_steam_net_packet_get_sender_id`, `tcc_steam_net_packet_get_size` | **R** | n/a | n/a | n/a | Bytes are already in the buffer passed to `tcc_steam_net_packet_receive`; sender and size are `_message.steam_id_remote` and `_message.size`. |
| `tcc_steam_net_set_auto_accept_p2p_sessions` | **R** | n/a | n/a | n/a | No auto-accept in 3.0: use the session-request callback + `tcc_steam_net_accept_session`. |
| macros `TCC_NET_SEND_RELIABLE`, `TCC_NET_SEND_UNRELIABLE` | NEW | `(SteamNetworkingSendFlags.ReliableNoNagle \| SteamNetworkingSendFlags.AutoRestartBrokenSession)` = 41; `(UnreliableNoNagle \| AutoRestartBrokenSession)` = 33 | | | Replace `steam_net_packet_type_reliable/unreliable` at `scr_online_multiplayer.gml:607`. |

## 7. Leaderboards, achievements, stats, player count

Details: map-stats sections 0, 3, 4. **All achievement and score functions were raw calls in `scr_platform_services`; they now live here.**

| Wrapper | St | 3.0 calls | Returns | NR | Cb / payload |
|---|---|---|---|---|---|
| `tcc_steam_get_achievement(_name)` | NEW (caller: `scr_platform_services.gml:181`) | `steam_userstats_get_achievement(string(_name))` | **bool** (`undefined` -> `false`) | false | - Evaluated up to twice per achievement per Draw (`draw_achievement.gml:8,51`); cheap. |
| `tcc_steam_set_achievement(_name)` | NEW (caller: `:188`) | `steam_userstats_set_achievement(string(_name))`; on success sets `stats_dirty` | bool (native 1/0) | false | The native only stores in memory; `tcc_steam_update()` flushes with `steam_userstats_store_stats()` (first try immediately, retry every 30 ticks while it returns 0). Without the flush there is no popup and nothing reaches Steam until process exit. |
| `tcc_steam_reset_all_stats_achievements()` | U (1) | `steam_userstats_reset_all_stats(true)` (auto-stores) | bool | false | Debug key combo, reachable in shipped builds (unchanged). |
| `tcc_steam_upload_score(_board, _score, _force = false)` | NEW (caller: `scr_platform_services.gml:205`) | queue job: `steam_userstats_find_leaderboard` -> `steam_userstats_upload_leaderboard_score(handle, _force ? ForceUpdate : KeepBest, clamp(floor(_score), 0, 2147483647), [], relay)` | bool queued | false | **-** (fire and forget; failure only logged). Needs `steam_user_logged_on()` like 2.x. Serialised: one leaderboard request in flight (two same-frame uploads exist in `o_playerdead`). Behaviour change: the first forced upload per board per session now really forces (map-stats 3.5). |
| `tcc_steam_create_leaderboard(_name, _sort, _display)` | **E** (2 uses) | queue job: `steam_userstats_find_or_create_leaderboard(name, sort, display, relay)` | bool queued | false | **-**. Call sites pass `SteamLeaderboardSortMethod.Ascending`, `SteamLeaderboardDisplayType.TimeMilliSeconds` instead of `lb_sort_ascending`, `lb_disp_time_ms`. Handle is cached so a following upload in the same frame (`scr_saveworkshopmedals.gml:19-20`) finds it. |
| `tcc_steam_download_scores(_board, _start, _end, _callback, _owner = noone)` | **E** (3 uses) | queue job: find -> `steam_userstats_download_leaderboard_entries(h, SteamLeaderboardDataRequest.Global, start, end, relay)` | bool queued | false | **G**. `_callback(_rows)`: `_rows` = array (length `<= 100`, may be empty) of `{steam_id: int64, name: string, score: int, rank: int}` (rank 1-based), or **`undefined`** on any failure (board missing, dispatch failure, Steam lost, 20 s watchdog). Entries are read inside the wrapper; callers never see `entries_handle`. |
| `tcc_steam_download_scores_around_user(_board, _from, _to, _callback, _owner = noone)` | **E** (3 uses) | same with `GlobalAroundUser` | bool queued | false | **G**, same payload. |
| `tcc_steam_download_friends_scores(_board, _callback, _owner = noone)` | **E** (1 use) | same with `Friends`, range `0, 0` | bool queued | false | **G**, same payload (cap 100). |
| `tcc_steam_get_number_of_current_players()` | U sig (4 uses) | `steam_userstats_number_of_current_players(tcc_steam_relay)` | bool **issued** (`false` while a previous request is in flight, TTL 30 s) | false | **-**; the wrapper itself writes `global.playercount = _r.players` on success. `busy`/`success`/`players` instance variables in `o_version` / `o_checkplayercount` are dead (their `Other_69` is deleted; delete the `o_version/Step_0.gml:8-22` polling block with it). |

Jobs are only queued by the wrappers; the first Steam call of a job is issued by the next `tcc_steam_update()` (at most one tick later), so no callback, not even a watchdog failure of an older job, ever runs inside the requesting instance's event (rule 2.3.2). A create job queued before an upload for the same board in the same frame still runs first (serial queue).

Caller rule for the three downloads: bump a per-instance request counter first and compare it in the callback (`method({inst: id, token: n}, fn)` + `_owner = id`); stale and destroyed-owner answers must not overwrite newer rows (map-stats 5.1).

## 8. Inventory

Details: map-inventory sections 0-8. Handles are small positive ints; `-1` = none (`STEAM_INVENTORY_RESULT_INVALID`).

| Wrapper | St | 3.0 call | Returns | NR | Cb / payload |
|---|---|---|---|---|---|
| `tcc_steam_inventory_get_all_items()` | U (1: `scr_tradeup.gml:83`) | `steam_inventory_get_all_items()` | handle `>= 1`, else `-1` | `-1` | Result reaches the **listener** set with `tcc_steam_inventory_set_callback_result_ready`. |
| `tcc_steam_inventory_set_callback_result_ready(_callback)` | NEW (1: `o_getallinventoryitems/Create_0.gml` after line 9, **only when `owns_inventory`**) | stores listener `inv_result_ready`; `steam_inventory_set_callback_result_ready(tcc_steam_relay)` | bool | false | `_callback(_r)`, `_r` = `SteamInventoryResultReady {result_handle, result}`; success = `_r.result == SteamApiResult.Ok` (Fail = 2 is truthy: never test truthiness). One owner only (single native slot): register after `owns_inventory = true`, clear only inside `if (owns_inventory)`; the `r_skinmenu` duplicate must never register or clear. The callback is a named global (`tradeup_inventory_event`). Late results for destroyed handles still arrive: the handler ignores non-current handles (`tradeup_result_matches`). Guard is `platform_steam()` only (X2). |
| `tcc_steam_inventory_clear_callback_result_ready()` | NEW (1: `o_getallinventoryitems/CleanUp_0.gml`, inside `if (owns_inventory)`) | removes listener; `steam_inventory_clear_callback_result_ready()` | bool | false | |
| `tcc_steam_inventory_exchange_items(_create, _destroy, _callback, _owner = noone)` | **E** (1: `scr_tradeup.gml:170`; plus commented `o_title/Other_69.gml:13`) | builds `new SteamInventoryItemDefQuantity()` / `new SteamInventoryItemInstanceQuantity()` (plain struct literals abort the game), `steam_inventory_exchange_items(gen, del, tcc_steam_relay)` | handle `>= 1`, else `-1` | `-1` | **N** (trade code needs its own timeout). `_create` = `[{item_def, quantity}]`, `_destroy` = `[{item_id: int64, quantity}]` (project plan shape; converted inside). `_callback(_r)`, `_r` = `SteamInventoryResultReady`, delivered by `result_handle` to **this** call's entry only, never to the listener. The result handle must then be destroyed with `tcc_steam_inventory_result_destroy`. |
| `tcc_steam_inventory_trigger_item_drop(_item_def, _callback = undefined, _owner = noone)` | U (1: `o_title/Create_0.gml:4`) | `steam_inventory_trigger_item_drop(def, tcc_steam_relay)` | handle `>= 1`, else `-1` | `-1` | **N**. Default callback `tcc_steam_inventory_release_result` destroys `_r.result_handle` unconditionally. |
| `tcc_steam_inventory_request_prices(_callback = undefined, _owner = noone)` | U (1: `o_title/Create_0.gml:5`) | `steam_inventory_request_prices(tcc_steam_relay)` | bool issued | false | **N**, may never fire. `_r` = `SteamInventoryRequestPricesResult {result, currency}`. Default callback `tcc_steam_inventory_ignore_result`. Never gate state on it. |
| `tcc_steam_inventory_get_item_price(_item_def)` | U (0 live) | `steam_inventory_get_item_price(def)` | `current_price` or `undefined` | `undefined` | ASSUMPTION: "price" = `current_price` (no 2.x source). |
| `tcc_steam_inventory_result_get_status(_handle)` | U (0) | `steam_inventory_get_result_status(h)` | `SteamApiResult` | `SteamApiResult.Fail` | |
| `tcc_steam_inventory_result_get_items(_handle)` | **E** (1: `scr_tradeup.gml:111`) | `steam_inventory_get_result_items(h)` mapped to the old shape `[{item_id, item_def, quantity, flags}]` | array; **`undefined` = failure** (not ready, or status not Ok); `[]` = genuinely empty inventory | `undefined` (was `[]`) | The old fallback `[]` would publish an "ok" empty inventory and zero `global.itemdef`; the single caller already runs only after a successful callback. Item fields are `item_instance_id` / `item_def_id` in 3.0 (`item_id` / `item_def` in the mapped shape). |
| `tcc_steam_inventory_result_get_item_property(_handle, _index, _name)` | U (0) | `steam_inventory_get_result_item_property(h, i, name)` | string | `""` | |
| `tcc_steam_inventory_result_get_unix_timestamp(_handle)` | U (0) | `steam_inventory_get_result_timestamp(h)` | real | `0` | |
| `tcc_steam_inventory_result_destroy(_handle)` | U (5, all in `scr_tradeup.gml`) | `steam_inventory_destroy_result(h)` (raw return is a meaningless 0, never forwarded) | `true` after issuing, `false` for `h < 1` or NR | false | |
| `tcc_steam_inventory_release_result(_r)`, `tcc_steam_inventory_ignore_result(_r)` | NEW (default callbacks) | n/a | - | - | Plain script functions. |

## 9. UGC / Workshop

Signatures and behaviour: map-ugc sections 1-4 (code in map-ugc section 2). Query/update handles are `u64` read as int64: **never** test `> 0`; use `tcc_steam_ugc_handle_valid(h)` (numeric, `!= 0`, `!= -1`). File ids stay `> 0`, int64. App id argument `0`/`false` resolves at call time to `steam_utils_get_app_id()` (`global.appid` can be `false`, `o_title/Create_0.gml:28`).

| Wrapper | St | Returns | NR | Cb / payload |
|---|---|---|---|---|
| `tcc_steam_ugc_create_item(_app_id, _file_type, _callback, _owner = noone)` (2 uses) | **E** | bool attempted | false | **N** (caller deadline 120 s). `_r` = `SteamUgcCreateItemResult {result, published_file_id, legal_agreement_required}`. Single-flight slot `create` (a second call while pending -> `false`). `_file_type` = `SteamRemoteStorageWorkshopFileType.Community`. |
| `tcc_steam_ugc_start_item_update(_app_id, _file_id)` (2) | U | update handle or `-1` | `-1` | - |
| `tcc_steam_ugc_set_item_title(_h, _text)`, `tcc_steam_ugc_set_item_description(_h, _text)`, `tcc_steam_ugc_set_item_tags(_h, _tags)`, `tcc_steam_ugc_set_item_preview(_h, _path)`, `tcc_steam_ugc_set_item_content(_h, _path)`, `tcc_steam_ugc_set_item_visibility(_h, _visibility)` (2 uses each) | U (title, description, tags, preview, content); **E** for visibility (callers pass `SteamRemoteStoragePublishedFileVisibility.Public` instead of `ugc_visibility_public`) | bool | false | - Strings are `string()`-coerced; tags an array of strings; preview needs `file_exists`, content needs `directory_exists` (else `false`, as 2.x). Paths are passed through unmodified (U1: Windows path form unverified). |
| `tcc_steam_ugc_submit_item_update(_h, _note, _callback, _owner = noone)` (2) | **E** | bool attempted | false | **N** (120 s). `_r` = `SteamUgcSubmitItemUpdateResult {result, legal_agreement_required}`. Single-flight slot `submit`. |
| `tcc_steam_ugc_subscribe_item(_file_id)` (5) | U | bool attempted | false | Internal shared handler (keeps both jobs of the old `ugc_subscribe_item` event: the `o_workshopERloading` skip and `global.net_ugc_failed` bookkeeping). Callers pass nothing. |
| `tcc_steam_ugc_unsubscribe_item(_file_id)` (2) | U | bool attempted | false | internal no-op |
| `tcc_steam_ugc_num_subscribed_items()` (2) | U | real | `false` | `steam_ugc_get_num_subscribed_items(false)` |
| `tcc_steam_ugc_get_subscribed_items(_list)` (7) | U | ds_list size, or `false` | false | fills the **ds_list** with int64 ids (3.0 returns an array; SAFE adapts) |
| `tcc_steam_ugc_get_item_install_info(_file_id, _map)` (11) | U | bool | false | ds_map keys `size_on_disk`, `legacy_item`, `folder` |
| `tcc_steam_ugc_get_item_update_info(_file_id, _map)` (7) | U | bool | false | ds_map keys `needs_update, is_downloading, bytes_downloaded, bytes_total, is_legacy, is_download_pending, is_installed` (shim over `get_item_state` + `get_item_download_info`) |
| `tcc_steam_ugc_create_query_all(_query_type, _match_type, _page)` (2) | **E** (enum args) | query handle or `-1` | `-1` | Callers pass `SteamUgcQuery.RankedByVote` / `.RankedByPublicationDate`, `SteamUgcMatchingUgcType.Items`. |
| `tcc_steam_ugc_query_set_search_text(_qh, _text)` (1) | U | bool | false | |
| `tcc_steam_ugc_send_query(_qh, _callback, _owner = noone)` (2) | **E** | bool attempted | false | **N**. `_callback(_ok, _items, _completed)`; `_items` = array of `SteamUgcQueryResult {published_file_id, title, owner_steam_id, votes_up, votes_down., banned, handle_preview_file, tags, ...}` (only entries with `result == SteamApiResult.Ok`), `_completed` = `SteamUgcQueryCompleted {query_handle, result, num_results_returned, total_matching_results, cached_data}`. The wrapper releases the query handle itself on every path (callers must not). |
| `tcc_steam_ugc_request_item_details(_file_ids, _max_age_seconds, _callback, _owner = noone)` (7) | **E** | bool (at least one query sent) | false | **N**. `_file_ids` = one id or an array; chunked by `STEAM_UGC_NUM_RESULTS_PER_PAGE` (50); the callback fires **once per chunk** with the same `(_ok, _items, _completed)`; match results by `_item.published_file_id`. Replaces the 2.x request id (`steam_details`, `map_id == ...`). |
| `tcc_steam_ugc_handle_valid(_h)` | NEW | bool | - | pure GML |
| `tcc_steam_ugc_get_item_update_progress` | **R** (0 callers) | | | delete |

The `steam_id_owner` map key of the old events is `item.owner_steam_id` (int64) on `SteamUgcQueryResult`, read inside the query callback (map-core 3.12); compare it with `tcc_steam_get_user_steam_id()` (`o_workshopchallengecreator/Step_0.gml:29,37`).


---

# PART B: implementer notes for `scripts/scr_steam_safe/scr_steam_safe.gml`

Everything here is private to SAFE. Code is GML written for this contract and **not compiled**: the implementer must compile it and run the self-check (section 15). Internals that the maps already specify are cited, not repeated; every place where this contract overrides a map is listed in section 11.

## 10. Infrastructure

### 10.1 File layout (in this order)

1. macros (10.2); 2. state, id helpers, guard (10.2); 3. registry + `__tcc_steam_deliver` (10.3); 4. `tcc_steam_relay` + route table (10.5); 5. pump: `tcc_steam_update`, `tcc_steam_register_callbacks`, ready-edge, sweep (10.4); 6. wrappers by domain (sections 3-9). All 79 old wrapper definitions are replaced; none of the old bodies (`platform_steam() && steam_initialised()` + raw 2.x call) survives.

### 10.2 Macros, state, ids, guard

```gml
#macro TCC_STEAM_SLOT_TTL_MS        180000   // single-flight / keyed entry lifetime (longer than every caller deadline, 120 s)
#macro TCC_STEAM_LB_WATCHDOG_MS      20000   // one leaderboard job; Steam gives no callback on IO failure
#macro TCC_STEAM_PLAYERS_TTL_MS      30000
#macro TCC_STEAM_PERSONA_RETRY_MS     5000   // per id, persona and avatar fetch requests
#macro TCC_STEAM_SWEEP_MS             2000
#macro TCC_STEAM_STORE_RETRY_TICKS      30   // StoreStats retry spacing while it keeps returning 0
#macro TCC_STEAM_AVATAR_SMALL   0
#macro TCC_STEAM_AVATAR_MEDIUM  1
#macro TCC_STEAM_AVATAR_LARGE   2            // unused today; sizes come from tcc_steam_image_get_size, never hard-coded
#macro TCC_AVATAR_PENDING      (-1)
#macro TCC_AVATAR_NONE          0
#macro TCC_AVATAR_RETRY_MAX     8
#macro TCC_AVATAR_RETRY_MS   1000
#macro TCC_OVERLAY_FRIENDS      "friends"
#macro TCC_OVERLAY_ACHIEVEMENTS "achievements"
#macro TCC_NET_SEND_RELIABLE    (SteamNetworkingSendFlags.ReliableNoNagle   | SteamNetworkingSendFlags.AutoRestartBrokenSession)  // 41
#macro TCC_NET_SEND_UNRELIABLE  (SteamNetworkingSendFlags.UnreliableNoNagle | SteamNetworkingSendFlags.AutoRestartBrokenSession)  // 33

/// All registry state. Lives in a global so it survives game_restart like every other project global; re-created lazily.
function __tcc_steam_state() {
    if (!variable_global_exists("tcc_steam") || !is_struct(global.tcc_steam)) {
        global.tcc_steam = {
            was_ready: false, diag_done: false, tick: 0, sweep_at: 0,
            listeners: {},            // kind -> {cb, owner}              persistent, last writer wins, NOT consumed
            slots: {},                // kind -> {cb, owner, expires}     single flight, consumed on delivery
            keyed: {},                // kind -> { string(key) -> {cb, owner, expires} }   consumed on delivery
            native_registered: {},    // kind -> true: relay is installed in that native slot
            lb: { handles: {}, queue: [], cur: undefined },
            stats_dirty: false, stats_next_tick: 0,
            persona_req: {}, avatar_req: {},
            relay_errors: 0, unrouted: 0, ids_int64: undefined
        };
    }
    return global.tcc_steam;
}
function __tcc_steam_id(_v)       { return is_numeric(_v) ? int64(_v) : int64(0); }   // int64(undefined) would throw
function tcc_steam_id_valid(_v)   { return is_numeric(_v) && _v > 0; }
function tcc_steam_ready()        { return platform_steam() && steam_api_is_initialized() != 0; }
function tcc_steam_initialised()  { return bool(tcc_steam_ready()); }
function tcc_steam_init()         { return bool(tcc_steam_ready()); }
```

### 10.3 Registry and delivery

```gml
function __tcc_steam_log(_what, _e) {
    show_debug_message("[STEAM] " + _what + ": " + ((is_struct(_e) && variable_struct_exists(_e, "message")) ? string(_e.message) : string(_e)));
}
function __tcc_steam_owner_alive(_owner) { return is_undefined(_owner) || _owner == noone || instance_exists(_owner); }

/// The only place a user callback is invoked. Returns true if it ran.
function __tcc_steam_deliver(_entry, _args) {
    if (!is_struct(_entry) || !is_callable(_entry.cb) || !__tcc_steam_owner_alive(_entry.owner)) return false;
    try { method_call(_entry.cb, _args); return true; }
    catch (_e) { var _st = __tcc_steam_state(); _st.relay_errors += 1; __tcc_steam_log("callback failed", _e); return false; }
}

// persistent listeners (lobby_created, lobby_entered, lobby_chat_update, lobby_join_requested, net_session_request, inv_result_ready)
function __tcc_steam_listener_set(_kind, _cb, _owner) { var _st = __tcc_steam_state(); _st.listeners[$ _kind] = { cb: _cb, owner: _owner }; }
function __tcc_steam_listener_clear(_kind)             { variable_struct_remove(__tcc_steam_state().listeners, _kind); }

// single-flight slots (ugc_create, ugc_submit, inv_prices, players): the result carries no key
function __tcc_steam_slot_take(_kind, _cb, _owner, _ttl = TCC_STEAM_SLOT_TTL_MS) {
    var _slots = __tcc_steam_state().slots;
    var _old = _slots[$ _kind];
    if (is_struct(_old) && current_time < _old.expires) return false;      // previous request still pending
    _slots[$ _kind] = { cb: _cb, owner: _owner, expires: current_time + _ttl };
    return true;
}
function __tcc_steam_slot_release(_kind) {                                // returns the entry (or undefined) and frees the slot BEFORE the callback runs
    var _slots = __tcc_steam_state().slots;
    var _e = _slots[$ _kind];
    variable_struct_remove(_slots, _kind);
    return _e;
}

// key-indexed entries (inv: result_handle, ugc_query: query_handle)
function __tcc_steam_keyed_put(_kind, _key, _cb, _owner) {
    var _k = __tcc_steam_state().keyed;
    if (!variable_struct_exists(_k, _kind)) _k[$ _kind] = {};
    var _table = _k[$ _kind];
    _table[$ _key] = { cb: _cb, owner: _owner, expires: current_time + TCC_STEAM_SLOT_TTL_MS };
}
function __tcc_steam_keyed_take(_kind, _key) {
    var _table = __tcc_steam_state().keyed[$ _kind];
    if (!is_struct(_table)) return undefined;
    var _e = _table[$ _key];
    variable_struct_remove(_table, _key);
    return _e;
}
```

### 10.4 Pump, registration, ready edge, sweep

```gml
/// Persistent native slots. Guard is platform_steam() ONLY (the natives just store the pointer; iOS/Android/MAS have no binary).
function __tcc_steam_native_register(_kind) {
    if (!platform_steam()) return false;
    switch (_kind) {
        case "lobby_chat_update":    steam_matchmaking_set_callback_lobby_chat_update(tcc_steam_relay); break;
        case "lobby_join_requested": steam_friends_set_callback_game_lobby_join_requested(tcc_steam_relay); break;
        case "net_session_request":  steam_networking_messages_set_callback_session_request(tcc_steam_relay); break;
        case "inv_result_ready":     steam_inventory_set_callback_result_ready(tcc_steam_relay); break;
        default: return false;
    }
    var _st = __tcc_steam_state();
    _st.native_registered[$ _kind] = true;
    return true;
}
function __tcc_steam_native_unregister(_kind) {
    if (!platform_steam()) return false;
    switch (_kind) {
        case "lobby_chat_update":    steam_matchmaking_clear_callback_lobby_chat_update(); break;
        case "net_session_request":  steam_networking_messages_clear_callback_session_request(); steam_networking_messages_clear_callback_session_failed(); break;
        case "inv_result_ready":     steam_inventory_clear_callback_result_ready(); break;
        default: return false;       // lobby_join_requested has no clear call in the project; shutdown clears it
    }
    variable_struct_remove(__tcc_steam_state().native_registered, _kind);
    return true;
}

/// Idempotent. _force re-installs the relay in every native slot that has a listener (refcount +1/-1 on the same registry key: harmless).
function tcc_steam_register_callbacks(_force = false) {
    if (!platform_steam()) return false;
    var _s = __tcc_steam_state();
    var _kinds = variable_struct_get_names(_s.listeners);
    for (var _i = 0; _i < array_length(_kinds); ++_i)
        if (_force || !variable_struct_exists(_s.native_registered, _kinds[_i])) __tcc_steam_native_register(_kinds[_i]);
    if (!_s.diag_done) {
        if (tcc_steam_ready()) {
            _s.diag_done = true;
            var _me = steam_user_get_steam_id();
            _s.ids_int64 = is_int64(_me);
            if (!_s.ids_int64) show_debug_message("[STEAM] WARNING: steam ids are " + typeof(_me) + ", not int64 (precision loss above 2^53)");
        } else {
            _s.diag_done = true;     // read the failure text now: every guarded native clears steam_api_last_error()
            show_debug_message("[STEAM] not initialised: " + string(steam_api_last_error()));
        }
    }
    return true;
}

function tcc_steam_update() {
    if (!platform_steam()) return false;
    var _s = __tcc_steam_state();
    _s.tick += 1;
    var _ready = tcc_steam_ready();
    if (_ready != _s.was_ready) {                       // Steam came up, or went away (shutdown / restart)
        _s.was_ready = _ready;
        if (_ready) { _s.diag_done = false; tcc_steam_register_callbacks(true); }
        else __tcc_steam_on_lost();
    }
    if (!_ready) return false;
    steam_api_run_callbacks();
    if (_s.stats_dirty && _s.tick >= _s.stats_next_tick) {          // achievements: SetAchievement only stores in memory
        if (steam_userstats_store_stats() != 0) _s.stats_dirty = false;
        else _s.stats_next_tick = _s.tick + TCC_STEAM_STORE_RETRY_TICKS;
    }
    __tcc_steam_lb_pump();                                          // leaderboard watchdog + next job
    if (current_time >= _s.sweep_at) { _s.sweep_at = current_time + TCC_STEAM_SWEEP_MS; __tcc_steam_sweep(); }
    return true;
}

function __tcc_steam_on_lost() {
    var _s = __tcc_steam_state();
    _s.native_registered = {};          // shutdown cleared every native slot; listeners stay and are re-installed on the next ready edge
    _s.slots = {};
    _s.keyed = {};                      // nothing pending can complete any more
    __tcc_steam_lb_fail_all();          // callers waiting for rows get `undefined`
}

function __tcc_steam_sweep() {
    var _s = __tcc_steam_state();
    var _names = variable_struct_get_names(_s.slots);
    for (var _i = 0; _i < array_length(_names); ++_i)
        if (current_time >= _s.slots[$ _names[_i]].expires) variable_struct_remove(_s.slots, _names[_i]);
    var _kinds = variable_struct_get_names(_s.keyed);
    for (var _k = 0; _k < array_length(_kinds); ++_k) {
        var _table = _s.keyed[$ _kinds[_k]];
        var _keys = variable_struct_get_names(_table);
        for (var _j = 0; _j < array_length(_keys); ++_j) {
            if (current_time < _table[$ _keys[_j]].expires) continue;
            if (_kinds[_k] == "ugc_query") steam_ugc_release_query_ugc_request(int64(_keys[_j]));   // the callback never came: free the handle
            variable_struct_remove(_table, _keys[_j]);
        }
    }
    if (variable_struct_names_count(_s.persona_req) > 512) _s.persona_req = {};   // cap growth
    if (variable_struct_names_count(_s.avatar_req) > 512)  _s.avatar_req = {};
}
```

### 10.5 The relay

`tcc_steam_relay` is the only callable that ever reaches a `steam_*` extension function. The dispatcher calls it as `with (_dummy_context) method_call(fn, [struct])` (`EXT:350`), so `self` is a shared empty struct: it touches only globals and static state. It never throws (an exception there would abort the dispatcher loop and leave the packet buffer half-read, `EXT:300-361`). Routing is by constructor name (`instanceof`); the decoders build every result with `new SteamX()` (e.g. API:11096-11112).

```gml
function tcc_steam_relay(_r = undefined) {
    var _s = __tcc_steam_state();
    if (!is_struct(_r)) { _s.unrouted += 1; show_debug_message("[STEAM] unrouted non-struct callback argument: " + typeof(_r)); return; }
    var _type = instanceof(_r);
    try {
        switch (_type) {
            // ---- persistent listeners ----
            case "SteamMatchmakingLobbyCreated":          __tcc_steam_deliver(_s.listeners[$ "lobby_created"],        [_r]); break;
            case "SteamMatchmakingLobbyEnter":            __tcc_steam_deliver(_s.listeners[$ "lobby_entered"],        [_r]); break;
            case "SteamMatchmakingLobbyChatUpdate":       __tcc_steam_deliver(_s.listeners[$ "lobby_chat_update"],    [_r]); break;
            case "SteamFriendsGameLobbyJoinRequested":    __tcc_steam_deliver(_s.listeners[$ "lobby_join_requested"], [_r]); break;
            case "SteamNetworkingMessagesSessionRequest": __tcc_steam_deliver(_s.listeners[$ "net_session_request"],  [_r]); break;
            // ---- inventory: this call's entry (by result_handle) first, else the owner's listener ----
            case "SteamInventoryResultReady": {
                var _entry = __tcc_steam_keyed_take("inv", string(_r.result_handle));
                if (is_struct(_entry)) __tcc_steam_deliver(_entry, [_r]);
                else __tcc_steam_deliver(_s.listeners[$ "inv_result_ready"], [_r]);
                break;
            }
            case "SteamInventoryRequestPricesResult":     __tcc_steam_deliver(__tcc_steam_slot_release("inv_prices"), [_r]); break;
            // ---- UGC ----
            case "SteamUgcCreateItemResult":              __tcc_steam_deliver(__tcc_steam_slot_release("ugc_create"), [_r]); break;
            case "SteamUgcSubmitItemUpdateResult":        __tcc_steam_deliver(__tcc_steam_slot_release("ugc_submit"), [_r]); break;
            case "SteamUgcSubscribeItemResult":           __tcc_steam_ugc_on_subscribed(_r); break;
            case "SteamUgcUnsubscribeItemResult":         break;
            case "SteamUgcQueryCompleted":                __tcc_steam_ugc_on_query_done(_r); break;
            // ---- leaderboards (serial queue, section 11.7) and player count ----
            case "SteamUserStatsLeaderboardFindResult":   __tcc_steam_lb_on_find(_r); break;
            case "SteamUserStatsScoresDownloadedResult":  __tcc_steam_lb_on_downloaded(_r); break;
            case "SteamUserStatsScoreUploadedResult":     __tcc_steam_lb_on_uploaded(_r); break;
            case "SteamUserStatsNumberOfCurrentPlayersResult":
                __tcc_steam_slot_release("players");
                if (_r.success) global.playercount = _r.players;
                break;
            default:
                _s.unrouted += 1;
                show_debug_message("[STEAM] unrouted callback struct: " + _type + " fields=" + string(variable_struct_get_names(_r)));
        }
    } catch (_e) {
        _s.relay_errors += 1;
        __tcc_steam_log("relay failed (" + _type + ")", _e);
    }
}
```

GML note: the code assigns through a local (`var _st = __tcc_steam_state(); _st.x = ...`), never through a call-result chain.

**Why this removes the `ptr` gate (U2).** Registration key is `int64(ptr(callable))` and a repeated key keeps the FIRST callable (`EXT:274-290`). With one callable, either `ptr(tcc_steam_relay)` is stable (every registration bumps the ref count of the same entry, which is exactly what the ref-count branch is for) or it is not (every registration creates its own entry). Both deliver to `tcc_steam_relay`. Closures and method-bound callables are never registered, so "the second closure silently never fires" cannot happen. Residual smoke test: three concurrent requests (e.g. 3 `request_item_details` chunks) each deliver once (section 15, item S-7).

**Decoder audit (static, done for this contract).** The relay switches on `instanceof(_r)`, which is only the constructor name if the result arrives as a typed struct. Checked in `API`: `__Steamworks_get_decoders()` (a 144-entry array) contains `__<Type>_decode` for **all 16 routed types** (`SteamMatchmakingLobbyCreated`, `...LobbyEnter`, `...LobbyChatUpdate`, `SteamFriendsGameLobbyJoinRequested`, `SteamNetworkingMessagesSessionRequest`, `SteamInventoryResultReady`, `...RequestPricesResult`, `SteamUgcCreateItemResult`, `...SubmitItemUpdateResult`, `...SubscribeItemResult`, `...UnsubscribeItemResult`, `...QueryCompleted`, `SteamUserStatsLeaderboardFindResult`, `...ScoresDownloadedResult`, `...ScoreUploadedResult`, `...NumberOfCurrentPlayersResult`), and each of the 16 decoders builds its struct with `new <Type>()` (16/16). The native side writes every registered `gm_struct` as `GMKind::TypedStruct` + codec id (`extensions/Steamworks/source/code_gen/core/GMExtWire.h:1282-1291`), which `EXT:76-80` feeds to `_decoders[id]`. Not provable offline: that codec ids line up with the decoder array order (the extension's own contract) and that no routed callback is ever sent as an untyped `{}` (then `instanceof` is `"struct"`). Runtime acceptance: after every manual Steam flow, `__tcc_steam_state().unrouted == 0 && relay_errors == 0` (section 15, S-7); the `default:` log prints the struct's field names so a miss is diagnosable from one line. **Fallback if an extension update ever drops a decoder:** field shapes are NOT unique (`SteamUgcCreateItemResult` and `SteamUgcSubscribeItemResult` both carry `result` + `published_file_id`), so do not route by shape; instead split `tcc_steam_relay` into one private named function per kind (`__tcc_steam_relay_ugc_create`, ...), each calling the same route body. That reintroduces the `ptr` uniqueness question (map-inventory U2 / map-ugc U2) for exactly those functions, to be settled by a two-registration smoke test.

**Adding a new Steam callback type later:** add one `case` here, one registry choice (listener / slot / keyed / queue) and one wrapper; do not pass anything else to Steam.

## 11. Domain implementation sources and overrides

Every helper that the maps name `tcc_steam_*` but that is not listed in Part A (`tcc_steam_lobby_resolve`, `tcc_steam_ugc_app_id`, `tcc_steam_ugc_path`, `tcc_steam_ugc_slot_*`, `tcc_steam_ugc_on_*`, `tcc_steam_state`, `tcc_steam_lb_*`, `tcc_steam_social_*`, ...) is renamed `__tcc_steam_*` when copied, so the public surface of SAFE is exactly Part A (+ section 2.1/2.4 helpers). In table cells below, `\|\|` stands for the GML operator `||` (escaped only for Markdown). Source = the reference code in the domain map; **Overrides** = what to change when copying it so it obeys this contract. Anything not listed is taken verbatim.

| # | Domain | Source | Overrides |
|---|---|---|---|
| 11.1 | Core / identity / apps | map-core 6 (bodies) | `steam_initialised()` -> `tcc_steam_ready()` everywhere; `tcc_steam_get_user_steam_id` returns `__tcc_steam_id(steam_user_get_steam_id())`; getters wrap `bool(...)`; `tcc_steam_update` / `tcc_steam_register_callbacks` / `tcc_steam_init` / `tcc_steam_initialised` are 10.2-10.4 (they supersede map-core 6 and map-stats 4 `tcc_steam_update`). |
| 11.2 | Lobby | map-lobby 6 | (1) drop its `tcc_steam_ready` copy; (2) `tcc_steam_lobby_create(_type, _max_members, _callback, _owner = noone)`: `if (!tcc_steam_ready() \|\| !is_callable(_callback)) return false; __tcc_steam_listener_set("lobby_created", _callback, _owner); steam_matchmaking_create_lobby(_type, _max_members, tcc_steam_relay); return steam_api_last_error() == "";` (read `steam_api_last_error()` immediately, nothing may run between); (3) `tcc_steam_lobby_join_id(_lobby_id, _callback, _owner = noone)`: same with listener `lobby_entered` and `steam_matchmaking_join_lobby(_lobby_id, tcc_steam_relay)`; (4) `tcc_steam_set_lobby_callbacks(_chat_update, _join_requested)`: `if (!platform_steam()) return false; __tcc_steam_listener_set("lobby_chat_update", _chat_update, noone); __tcc_steam_listener_set("lobby_join_requested", _join_requested, noone); __tcc_steam_native_register("lobby_chat_update"); __tcc_steam_native_register("lobby_join_requested"); return true;`; (5) `tcc_steam_lobby_get_member_count` NR value `0`, `tcc_steam_lobby_get_member_id` and `..._get_owner_id` return `__tcc_steam_id(...)`; (6) the `net_on_lobby_*`, `net_discard_lobby_reply`, watchdog (5.4) and restart net (5.5) code of map-lobby sections 5.2-5.5 are call-site code, taken verbatim. |
| 11.3 | Networking | map-net 4 (wrappers) and 3 (session design) | `tcc_steam_net_set_session_request_callback(_cb)`: `if (!platform_steam() \|\| !is_callable(_cb)) return false; __tcc_steam_listener_set("net_session_request", _cb, noone); return __tcc_steam_native_register("net_session_request");` (platform guard only, X2; **do not** pass `_cb` to Steam); `tcc_steam_net_clear_session_callbacks()`: `__tcc_steam_listener_clear("net_session_request"); return __tcc_steam_native_unregister("net_session_request");`; all others (`packet_receive`, `packet_send` with `== SteamApiResult.Ok`, `accept_session`, `close_p2p_session`) verbatim but guard `tcc_steam_ready()`; macros are in 10.2. |
| 11.4 | Inventory | map-inventory 6 | (1) callables to Steam are `tcc_steam_relay`; (2) `tcc_steam_inventory_exchange_items(_create, _destroy, _callback, _owner = noone)` / `trigger_item_drop(_item_def, _callback = undefined, _owner = noone)`: after a valid handle `>= 1` call `__tcc_steam_keyed_put("inv", string(_handle), _callback, _owner)` (trigger: default `_callback = tcc_steam_inventory_release_result`) and return the handle; (3) `tcc_steam_inventory_request_prices(_callback = undefined, _owner = noone)`: `if (!tcc_steam_ready()) return false; if (!is_callable(_callback)) _callback = tcc_steam_inventory_ignore_result; if (!__tcc_steam_slot_take("inv_prices", _callback, _owner)) return false; steam_inventory_request_prices(tcc_steam_relay); return true;`; (4) `tcc_steam_inventory_set_callback_result_ready(_cb)`: `if (!platform_steam() \|\| !is_callable(_cb)) return false; __tcc_steam_listener_set("inv_result_ready", _cb, noone); return __tcc_steam_native_register("inv_result_ready");`; `..._clear_callback_result_ready()`: `__tcc_steam_listener_clear("inv_result_ready"); return __tcc_steam_native_unregister("inv_result_ready");`; (5) `result_get_items` NR value `undefined`. |
| 11.5 | UGC | map-ugc 2 (code block) | (1) delete `tcc_steam_ready` comment, `tcc_ugc_slots`, `tcc_steam_ugc_slot_take/deliver`, `tcc_steam_ugc_on_create_item`, `_on_submit_item`, `tcc_steam_ugc_noop`, `tcc_ugc_queries`, `tcc_steam_ugc_query_sweep` (their jobs are `__tcc_steam_slot_take("ugc_create"/"ugc_submit", cb, owner)` + the relay routes + `__tcc_steam_sweep`); (2) pass `tcc_steam_relay` as the callable in `steam_ugc_create_item`, `steam_ugc_submit_item_update`, `steam_ugc_subscribe_item`, `steam_ugc_unsubscribe_item`, `steam_ugc_send_query_ugc_request`; (3) `tcc_steam_ugc_create_item` / `_submit_item_update`: `if (!__tcc_steam_slot_take("ugc_create", _callback, _owner)) return false;` before the Steam call (and `"ugc_submit"`); (4) `tcc_steam_ugc_on_subscribed` is renamed `__tcc_steam_ugc_on_subscribed`; (5) `tcc_steam_ugc_on_query_done` is renamed `__tcc_steam_ugc_on_query_done`, looks its entry up with `__tcc_steam_keyed_take("ugc_query", string(_completed.query_handle))`, still ALWAYS calls `steam_ugc_release_query_ugc_request(_completed.query_handle)` first, and delivers through `__tcc_steam_deliver(_entry, [_ok, _items, _completed])`; (6) `tcc_steam_ugc_send_query` stores with `__tcc_steam_keyed_put("ugc_query", string(_qh), _callback, _owner)`. `tcc_steam_ugc_handle_valid`, `_app_id`, `_path`, the sync shims and the `create_query_all` / `search_text` / `request_item_details` bodies are verbatim. |
| 11.6 | Social | map-social 3 | (1) avatar: use 11.8 below, **delete** `tcc_steam_social_init` and `tcc_steam_on_avatar_image_loaded` (no avatar callback is registered); (2) persona: only `tcc_steam_get_user_persona_name_sync` (11.8); `tcc_steam_user_name` is not a separate function; (3) guard `tcc_steam_ready()`; (4) `tcc_steam_activate_overlay(_dialog)` passes `string(_dialog)`; (5) ids in `tcc_steam_get_friends_game_info` rows are `__tcc_steam_id(...)`; rest verbatim. |
| 11.7 | Stats | map-stats 4 | Replaced as a whole by the code below (no closure is handed to Steam; rows are normalised; callbacks take `_owner`). |

### 11.7 Leaderboards, achievements, player count (replaces map-stats section 4)

```gml
function __tcc_steam_lb_available() { return tcc_steam_ready() && steam_user_logged_on() != 0; }   // 2.x refused leaderboard calls when not logged on

function __tcc_steam_lb_enqueue(_job) {      // ONLY queues: jobs start (and watchdog callbacks run) from the pump in tcc_steam_update, never inside the caller's event
    var _lb = __tcc_steam_state().lb;
    array_push(_lb.queue, _job);
}
function __tcc_steam_lb_pump() {
    var _lb = __tcc_steam_state().lb;
    if (is_struct(_lb.cur)) {
        if (current_time < _lb.cur.deadline) return;
        var _lost = _lb.cur;                       // IO / dispatch failure: Steam never calls back
        _lb.cur = undefined;
        __tcc_steam_lb_complete(_lost, undefined);
        if (is_struct(_lb.cur)) return;            // the callback enqueued work and a nested pump already started it
    }
    if (array_length(_lb.queue) == 0) return;
    var _job = _lb.queue[0];
    array_delete(_lb.queue, 0, 1);
    _job.deadline = current_time + TCC_STEAM_LB_WATCHDOG_MS;
    _lb.cur = _job;
    __tcc_steam_lb_run(_job);
}
function __tcc_steam_lb_complete(_job, _data) {    // download jobs call back with rows or undefined; create/upload have no caller callback
    if (_job.kind == "download") __tcc_steam_deliver({ cb: _job.cb, owner: _job.owner }, [_data]);
}
function __tcc_steam_lb_done(_job, _data) {
    var _lb = __tcc_steam_state().lb;
    if (_lb.cur == _job) _lb.cur = undefined;
    __tcc_steam_lb_complete(_job, _data);
    __tcc_steam_lb_pump();
}
function __tcc_steam_lb_fail_all() {               // Steam lost
    var _lb = __tcc_steam_state().lb;
    var _jobs = _lb.queue;
    _lb.queue = [];
    if (is_struct(_lb.cur)) { array_insert(_jobs, 0, _lb.cur); _lb.cur = undefined; }
    for (var _i = 0; _i < array_length(_jobs); ++_i) __tcc_steam_lb_complete(_jobs[_i], undefined);
}
function __tcc_steam_lb_run(_job) {
    var _lb = __tcc_steam_state().lb;
    var _h = _lb.handles[$ _job.board];
    if (!is_undefined(_h)) { __tcc_steam_lb_have_handle(_job, _h); return; }
    _job.step = "find";
    if (_job.kind == "create") steam_userstats_find_or_create_leaderboard(_job.board, _job.sort, _job.display, tcc_steam_relay);
    else steam_userstats_find_leaderboard(_job.board, tcc_steam_relay);       // plain find: never auto-create wrongly typed boards (2.x behaviour)
}
function __tcc_steam_lb_have_handle(_job, _h) {
    switch (_job.kind) {
        case "create": __tcc_steam_lb_done(_job, _h); break;
        case "download":
            _job.step = "download"; _job.handle = _h;
            steam_userstats_download_leaderboard_entries(_h, _job.request, _job.range_a, _job.range_b, tcc_steam_relay);
            break;
        case "upload":
            _job.step = "upload"; _job.handle = _h;
            steam_userstats_upload_leaderboard_score(_h, _job.how, _job.value, [], tcc_steam_relay);
            break;
    }
}
function __tcc_steam_lb_on_find(_r) {
    var _lb = __tcc_steam_state().lb;
    var _job = _lb.cur;
    if (!is_struct(_job) || _job.step != "find") return;                       // late answer of an abandoned job
    if (!_r.leaderboard_found) { __tcc_steam_lb_done(_job, undefined); return; }   // board does not exist: nothing is cached (a later request may retry)
    if (steam_userstats_leaderboard_name(_r.leaderboard_handle) != _job.board) return;   // answer belongs to another job
    _lb.handles[$ _job.board] = _r.leaderboard_handle;
    __tcc_steam_lb_have_handle(_job, _r.leaderboard_handle);
}
function __tcc_steam_lb_on_downloaded(_r) {
    var _job = __tcc_steam_state().lb.cur;
    if (!is_struct(_job) || _job.step != "download" || _r.leaderboard_handle != _job.handle) return;
    var _rows = [];
    var _n = min(_r.entry_count, 100);                                          // 2.x kMaxEntries; read INSIDE this call: entries_handle is valid for the most recent download only
    for (var _i = 0; _i < _n; ++_i) {
        var _e = steam_userstats_downloaded_leaderboard_entry(_r.entries_handle, _i);
        if (!is_struct(_e)) continue;
        array_push(_rows, { steam_id: __tcc_steam_id(_e.steam_id_user), name: tcc_steam_get_user_persona_name_sync(_e.steam_id_user), score: _e.score, rank: _e.global_rank });
    }
    __tcc_steam_lb_done(_job, _rows);
}
function __tcc_steam_lb_on_uploaded(_r) {
    var _job = __tcc_steam_state().lb.cur;
    if (!is_struct(_job) || _job.step != "upload" || _r.leaderboard_handle != _job.handle) return;
    if (!_r.success) show_debug_message("[STEAM] leaderboard upload failed: " + _job.board);
    __tcc_steam_lb_done(_job, undefined);
}

function tcc_steam_create_leaderboard(_name, _sort, _display) {
    if (!__tcc_steam_lb_available()) return false;
    __tcc_steam_lb_enqueue({ kind: "create", board: string(_name), sort: _sort, display: _display, step: "", handle: 0, deadline: 0 });
    return true;
}
function __tcc_steam_lb_download(_board, _request, _a, _b, _callback, _owner) {
    if (!is_callable(_callback) || !__tcc_steam_lb_available()) return false;
    __tcc_steam_lb_enqueue({ kind: "download", board: string(_board), request: _request, range_a: _a, range_b: _b, cb: _callback, owner: _owner, step: "", handle: 0, deadline: 0 });
    return true;
}
function tcc_steam_download_scores(_board, _start, _end, _callback, _owner = noone)             { return __tcc_steam_lb_download(_board, SteamLeaderboardDataRequest.Global,          _start, _end, _callback, _owner); }
function tcc_steam_download_scores_around_user(_board, _from, _to, _callback, _owner = noone)   { return __tcc_steam_lb_download(_board, SteamLeaderboardDataRequest.GlobalAroundUser, _from,  _to,  _callback, _owner); }
function tcc_steam_download_friends_scores(_board, _callback, _owner = noone)                   { return __tcc_steam_lb_download(_board, SteamLeaderboardDataRequest.Friends,         0,      0,    _callback, _owner); }
function tcc_steam_upload_score(_board, _score, _force = false) {
    if (!__tcc_steam_lb_available() || !is_numeric(_score) || is_nan(_score)) return false;
    __tcc_steam_lb_enqueue({ kind: "upload", board: string(_board), value: clamp(floor(_score), 0, 2147483647),
        how: (_force ? SteamLeaderboardUploadScoreMethod.ForceUpdate : SteamLeaderboardUploadScoreMethod.KeepBest), step: "", handle: 0, deadline: 0 });
    return true;
}

function tcc_steam_get_achievement(_name) {
    if (!tcc_steam_ready()) return false;
    var _r = steam_userstats_get_achievement(string(_name));       // Bool, or undefined (stats unavailable / unknown name)
    return is_bool(_r) ? _r : false;
}
function tcc_steam_set_achievement(_name) {
    if (!tcc_steam_ready()) return false;
    var _ok = (steam_userstats_set_achievement(string(_name)) != 0);   // direct native, Real 1/0, in-memory only
    if (_ok) { var _st = __tcc_steam_state(); _st.stats_dirty = true; }   // flushed by tcc_steam_update
    return _ok;
}
function tcc_steam_reset_all_stats_achievements() {
    if (!tcc_steam_ready()) return false;
    return steam_userstats_reset_all_stats(true) != 0;                 // 3.0 stores automatically
}
function tcc_steam_get_number_of_current_players() {
    if (!tcc_steam_ready()) return false;
    if (!__tcc_steam_slot_take("players", undefined, noone, TCC_STEAM_PLAYERS_TTL_MS)) return false;   // 2.x IsActive() rejection
    steam_userstats_number_of_current_players(tcc_steam_relay);
    return true;
}
```

### 11.8 Persona names and avatars

```gml
function __tcc_steam_throttle(_table, _key, _interval_ms) {        // true when a new request is allowed now
    var _last = _table[$ _key];
    if (!is_undefined(_last) && current_time - _last < _interval_ms) return false;
    _table[$ _key] = current_time;
    return true;
}
function tcc_steam_get_user_persona_name_sync(_steam_id) {
    if (!tcc_steam_ready()) return "";
    var _id = __tcc_steam_id(_steam_id);
    if (_id <= 0) return "";
    var _name = steam_friends_get_friend_persona_name(_id);
    if (is_string(_name) && _name != "" && _name != "[unknown]") return _name;
    if (__tcc_steam_throttle(__tcc_steam_state().persona_req, string(_id), TCC_STEAM_PERSONA_RETRY_MS))
        steam_friends_request_user_information(_id, true);         // literal bool: is_bool is enforced by 3.0
    return "";
}
function tcc_steam_get_user_avatar(_steam_id, _size) {
    if (!tcc_steam_ready()) return TCC_AVATAR_NONE;
    var _id = __tcc_steam_id(_steam_id);
    if (_id <= 0) return TCC_AVATAR_NONE;
    var _h;
    switch (_size) {                                               // default = SMALL, as 2.x steam_user.cpp:252-273
        case TCC_STEAM_AVATAR_LARGE:  _h = steam_friends_get_large_friend_avatar(_id);  break;
        case TCC_STEAM_AVATAR_MEDIUM: _h = steam_friends_get_medium_friend_avatar(_id); break;
        default:                      _h = steam_friends_get_small_friend_avatar(_id);  break;
    }
    if (is_numeric(_h) && _h > 0) return _h;
    if (_id != steam_user_get_steam_id() && __tcc_steam_throttle(__tcc_steam_state().avatar_req, string(_id), TCC_STEAM_PERSONA_RETRY_MS))
        steam_friends_request_user_information(_id, false);        // false = also fetch the avatar
    return TCC_AVATAR_PENDING;                                     // raw 0 or -1: not available yet; the caller retries (4.2)
}
```


---

# PART C: handler replacement, constants, gates, self-check, tables

## 12. Async-Steam handlers: every one goes, and what replaces it

The Steam async event (`eventNum 69, eventType 7` in the object `.yy`, `Other_69.gml`) cannot fire any more (the 3.0 source never raises a GameMaker async event, map-core 2.2). All 18 files below and their `.yy` event entries are deleted **in the same change as the wrapper swap** (X7); keeping any of them is dead code that still reads `async_load[? "event_type"]`. `tools/check_port.py` fails if any remains (section 14, gates 5 and 4a). Per-handler detail: `H1` (first five), `H2` (next five), and the domain maps.

| # | Handler (`objects/<obj>/Other_69.gml`) | Replacement |
|---|---|---|
| 1 | `o_checkplayercount` | Deleted. `global.playercount` is written by SAFE (relay route `SteamUserStatsNumberOfCurrentPlayersResult`). `Create_0.gml:19` / `Alarm_0.gml:8` keep `if (tcc_steam_get_number_of_current_players()) busy = true;`. |
| 2 | `o_version` | Deleted, **and** delete the polling block `o_version/Step_0.gml:8-22` (otherwise one spurious request and a transient `playercount = 1`, map-stats 3.9). |
| 3 | `o_title` | Deleted. Its body was a no-op for `inventory_request_prices`; `Create_0.gml:4-5` keep `tcc_steam_inventory_trigger_item_drop(99)` / `tcc_steam_inventory_request_prices()` (default callbacks). Reword the comment about lobby join requests (now `tcc_steam_set_lobby_callbacks`). |
| 4 | `o_tradeup_menu` | Deleted (comments only). |
| 5 | `o_getallinventoryitems` | Deleted. `tradeup_inventory_event(_result)` is registered with `tcc_steam_inventory_set_callback_result_ready` in `Create_0.gml` (owner only) and cleared in `CleanUp_0.gml` inside `if (owns_inventory)`. |
| 6 | `o_fullscreensystem` | Deleted (it only forwarded `lobby_created` / `lobby_joined` while the manager was absent). The create/join callbacks are persistent listeners held by SAFE and fire regardless of which instances exist. |
| 7 | `o_networkmanager` | Deleted **last**: after `net_handle_async_steam` is split into `net_on_lobby_created`, `net_on_lobby_entered`, `net_on_lobby_chat_update`, `net_on_lobby_join_requested`, its `avatar_image_loaded` case is dropped (polling) and its `ugc_subscribe_item` case is dropped (shared handler in SAFE). |
| 8 | `o_onlineleaderboards` | Deleted. `reloadleaderboards()` passes a rows callback (`method({inst: id, token: n}, fn)`, `_owner = id`) to `tcc_steam_download_scores` / `_friends_scores`; avatars via the polling protocol (4.2). |
| 9 | `o_onlineleaderboardsmini` | Deleted. Same through `reloadleaderboardsmini()` (`tcc_steam_download_scores_around_user`). Its hard-mode destroy at `Other_69:2-4` is redundant (`Create_0:1-4`). |
| 10 | `o_onlineleaderboardCH` | Orphan (absent from the `.yyp`): delete the whole folder; `check_port` scans it. |
| 11 | `o_settings` | Deleted. `Create_0.gml:35` -> `tcc_steam_download_scores("Cog Distance", 1, 10, method({owner: id}, fn), id)` filling `steam_name/score/rank[0..10]` (map-stats 5.4). |
| 12 | `o_profilepicture` | Deleted (dead). `Create_0.gml` polls `tcc_steam_get_user_avatar` and uses `tcc_steam_image_to_sprite`. |
| 13 | `o_publishinghappenshere` | Deleted. `Create_0.gml` issues `tcc_steam_ugc_create_item(global.appid, SteamRemoteStorageWorkshopFileType.Community, on_create_result, id)`; `on_create_result` / `on_submit_result` are instance methods holding today's `Other_69` bodies behind the existing `state` gates; 120 s deadline kept (map-ugc 3). |
| 14 | `o_publishworkshopchallenge` | Deleted. Same pattern; the whole `set_item_*` chain currently in `Other_69.gml:20-32` moves into the create callback; add the missing deadline for `result` 0.1 / 0.5. |
| 15 | `o_customlevelsbrowser` | Deleted. `send_browse_query` uses `tcc_steam_ugc_send_query(qh, method({inst: id, seq: browse_seq}, fn), id)`; details via ONE `tcc_steam_ugc_request_item_details(ids, 30, cb, id)`; owner names via `tcc_steam_get_user_persona_name_sync` from a throttled Step loop. |
| 16 | `o_customlevelworkshopbuttonplay` | Deleted. Details callback sets `mTitle, mDesc, mTags, mPubFileId, mOwner = _item.owner_steam_id, ...`; owner name resolved from `Alarm_0` (30-tick cadence already exists). |
| 17 | `o_workshoplevelselectbutton` | Deleted. Details callback sets `mTitle, mTags, owner_id = _item.owner_steam_id, loaded = 1` plus the difficulty block. |
| 18 | `o_workshopERloading` | Deleted. Subscribe skip is the shared handler inside `tcc_steam_ugc_subscribe_item`; catalog is the callback of `workshopER_query_catalog`. |

## 13. Constants and enums

| Old | New | Notes |
|---|---|---|
| `ov_friends`, `ov_achievements` | `TCC_OVERLAY_FRIENDS` (`"friends"`), `TCC_OVERLAY_ACHIEVEMENTS` (`"achievements"`) | Lowercase per docs; fallback `"Friends"` / `"Achievements"` if the overlay does not open. |
| `steam_user_avatar_size_small/medium/large` | `TCC_STEAM_AVATAR_SMALL/MEDIUM/LARGE` (0/1/2) | Selects `steam_friends_get_small/medium/large_friend_avatar`. No pixel sizes anywhere. |
| (avatar return `0` / `-1` semantics) | `TCC_AVATAR_NONE` (0), `TCC_AVATAR_PENDING` (-1), `TCC_AVATAR_RETRY_MAX` (8), `TCC_AVATAR_RETRY_MS` (1000) | Section 4.2. |
| `steam_lobby_type_friends_only` | `SteamMatchmakingLobbyType.FriendsOnly` (=1) | Same value. |
| `steam_net_packet_type_reliable` (2) | `TCC_NET_SEND_RELIABLE` = `ReliableNoNagle \| AutoRestartBrokenSession` (41) | Do not carry numeric literals over. |
| `steam_net_packet_type_unreliable` (0) | `TCC_NET_SEND_UNRELIABLE` = `UnreliableNoNagle \| AutoRestartBrokenSession` (33) | |
| `lb_sort_ascending` / `lb_disp_time_ms` | `SteamLeaderboardSortMethod.Ascending` / `SteamLeaderboardDisplayType.TimeMilliSeconds` | 2 call sites. |
| (bool `force_update`) | `SteamLeaderboardUploadScoreMethod.ForceUpdate` / `.KeepBest` | Inside `tcc_steam_upload_score`; passing the old bool maps `false` to the invalid `None`. |
| `ugc_result_success` | `SteamApiResult.Ok` | Never test results for truthiness (`Fail` = 2 is truthy). |
| `ugc_filetype_community` | `SteamRemoteStorageWorkshopFileType.Community` | |
| `ugc_visibility_public` | `SteamRemoteStoragePublishedFileVisibility.Public` | |
| `ugc_match_Items` | `SteamUgcMatchingUgcType.Items` | |
| `ugc_query_RankedByVote` / `ugc_query_RankedByPublicationDate` | `SteamUgcQuery.RankedByVote` / `.RankedByPublicationDate` | |
| `steam_inventory_result_status_*`, `steam_inventory_result_invalid` | `SteamApiResult.*` (same numbers 1/2/8/20/22/25/27), `STEAM_INVENTORY_RESULT_INVALID` (-1) | map-inventory 5. |
| (lobby create success) | `_r.result == SteamApiResult.Ok && _r.lobby_id != 0` | not truthiness |
| (lobby join success) | `_r.response == SteamMatchmakingChatRoomEnterResponse.Success` | not truthiness |
| (chat update flags) | `SteamMatchmakingChatMemberStateChange.Left \| Disconnected \| Kicked \| Banned` (2/4/8/16 as before) | field names `user_changed_id`, `chat_member_state_change` |
| `STEAM_NETWORKING_SOCKETS_MAX_MESSAGE_SIZE_SEND` (524288), `STEAM_UGC_NUM_RESULTS_PER_PAGE` (50), `STEAM_UGC_QUERY_HANDLE_INVALID` (-1) | 3.0 macros, usable anywhere | |

## 14. `tools/check_port.py`: keep "raw Steam calls only in the wrapper" true for the new names

The current gate (`check_port.py:78-79`) only covers `steam_(inventory_|ugc_|get_achievement|set_achievement|upload_score|initialised)`: **it does not match `steam_matchmaking_`, `steam_friends_`, `steam_userstats_`, `steam_utils_`, `steam_api_`, `steam_networking_`, `steam_user_`, `steam_apps_`, `steam_screenshots_`**, so after the migration raw 3.0 calls outside SAFE would pass silently, and `scr_platform_services` is exempt although it holds three raw calls. The complete replacement is `SP/wc/check_port_steam.py` (function `steam_invariants(root, yy)`; it also runs standalone in report mode). Patch `tools/check_port.py` as follows:

1. Paste the constants and functions of `check_port_steam.py` above `main()`.
2. In `main()` delete lines 78-79 (`if p.parent.name not in ['scr_steam_safe', 'scr_platform_services']:` and its `assert`); keep lines 73-77 (the AdMob/Google Play check).
3. After the `for p in ...` loop add:
```python
    problems = steam_invariants(ROOT, yy)
    assert not problems, 'Steam invariants failed:\n  ' + '\n  '.join(problems)
```

Gates (all in `steam_invariants`, only `scripts/scr_steam_safe/` is exempt; `*_API` and `ExtensionCore_api` directories are never scanned):

| # | Kind | Pattern / rule |
|---|---|---|
| 1 | `raw_30_call` | `(?<![\w$.])steam_(?:api\|apps\|friends\|input\|inventory\|matchmaking\|music\|networking\|parties\|remote_storage\|screenshots\|timeline\|ugc\|user\|userstats\|utils)_\w+\s*\(` |
| 2 | `unknown_steam_token` | every other bare `steam_\w+` token (`(?<![\w$.])steam_\w+`) must be in the allow-list `{steam_api, steam_display, steam_player_group, steam_player_group_size, steam_is_available, steam_id, steam_list, steam_name, steam_rank, steam_score, steam_userid}`. This catches `steam_initialised`, `steam_lobby_*`, `steam_net_*`, `steam_get_*`, `steam_set_*`, `steam_user_avatar_size_*`, `steam_image_create_sprite`, `steam_id_owner`, `steam_details` and any invented name |
| 3 | `stale_constant` | `(?<![\w$.])(?:ugc_(?:result\|filetype\|visibility\|match\|query)_\w+\|lb_(?:sort\|disp)_\w+\|ov_(?:friends\|community\|players\|settings\|gamegroup\|achievements)\|steam_(?:lobby\|net_packet\|inventory_result)_\w+)\b` |
| 4 | `removed_wrapper` | `tcc_steam_(?:get_user_persona_name\|net_packet_get_data\|net_packet_get_sender_id\|net_packet_get_size\|net_set_auto_accept_p2p_sessions\|ugc_get_item_update_progress)\b` (a leftover caller is a runtime error in GameMaker, not a compile error) |
| 4a | `async_load_event_type` | `\[\?\s*"event_type"\s*\]` (the built-in `event_type` variable used by the QA scripts is not matched) |
| 4b | `private_name_used_outside_safe` | `tcc_steam_relay` or `__tcc_steam_*` outside SAFE (so `tcc_steam_selfcheck()` and every test that touches the relay or the registries must live in SAFE) |
| 5 | `async_steam_event_file` / `_entry` | no `objects/**/Other_69.gml`; no object `.yy` event with `eventType 7` and `eventNum 69` |
| 6 | `closure_handed_to_steam` | in `scr_steam_safe.gml`, no line with a raw 3.0 call also contains `method(` or `function(` (the relay rule; multi-line Steam calls are not allowed in SAFE) |
| 7 | `steam_debug_enabled` | `options/extensions/Steamworks.json` Debug GUID `96a61e5d-c4ac-4104-b5ac-c8ef936e2609` must not be `Enabled` for `Default` or `Steam` (shipping config stays Auto; developers opt in locally) |

**Evidence that the patterns do not hit project-local names** (run on the unmigrated tree, `SP/wc/check_port_report.txt`): `raw_30_call` 0 hits; the allow-listed locals (`global.steam_api`, `steam_userid[i]`, `steam_name[0]`, `steam_rank`, `steam_score`, `steam_list`, `steam_id`, `global.steam_is_available`, the 54 `"steam_display"` strings, `steam_player_group*`) produce **no** hit in any gate; `tcc_steam_*` never matches (the lookbehind rejects `_steam_`); `obj.steam_api_x(1)` and `global.steam_api` are rejected by the `.` in the lookbehind. Synthetic samples confirmed the same (`steam_ugc_get_query_ugc_result(h,i)` -> raw, `steam_initialised()` -> unknown token, `ov_friends` -> stale constant, `tcc_steam_ugc_create_item(1,2)` -> clean).

**Hit list on the current tree = the migration to-do list** (133 problems): `unknown_steam_token` 35 (tally: `steam_details` 10, `steam_image_create_sprite` 8, `steam_id_owner` 5, `steam_user_avatar_size_small` 2, `..._medium` 3, `steam_lobby_type_friends_only` 1, `steam_net_packet_type_reliable` 1, `..._unreliable` 1, `steam_get_achievement` 1, `steam_set_achievement` 1, `steam_upload_score_ext` 1, `steam_inventory_exchange_items` 1 (doc comment `scr_tradeup.gml:165`)); `stale_constant` 28 (`ugc_result_success` 16 in 9 files, `ugc_filetype_community` 2, `ugc_visibility_public` 2, `ugc_match_Items` 2, `ugc_query_RankedByVote` 1, `ugc_query_RankedByPublicationDate` 1, `lb_sort_ascending` 2, `lb_disp_time_ms` 2 (same lines), `ov_friends` 1, `ov_achievements` 1, `steam_lobby_type_friends_only` 1, `steam_net_packet_type_*` 1 line); `async_load_event_type` 22; `async_steam_event_file` 18 and `async_steam_event_entry` 18; `removed_wrapper` 12 (4 in `scr_online_multiplayer.gml`, 8 persona-name sites). File:line detail for each hit: `SP/wc/check_port_report.txt` and section 17.3. After the migration the gate must print nothing.

## 15. Self-check

Add `tcc_steam_selfcheck()` **inside `scripts/scr_steam_safe/scr_steam_safe.gml`** (it calls `tcc_steam_relay` and the private `__tcc_steam_*` helpers, which gate 4b forbids anywhere else; no `EXEMPT_DIRS` change is needed) and call only that one public function from `scr_port_selfcheck()` (`scripts/scr_port_selfcheck/scr_port_selfcheck.gml`, uses `scr_port_assert`, which throws a string). It runs in the `Check` configuration **without Steam** because the relay and registries are pure GML:

| # | Assertion |
|---|---|
| S-1 | With `!platform_steam()` (Check/QA/iOS): `tcc_steam_ready() == false`; `tcc_steam_initialised() == false`; `tcc_steam_get_user_steam_id() == 0 && is_int64(tcc_steam_get_user_steam_id())`; `tcc_steam_get_app_id() != 1749610`; `tcc_steam_get_user_avatar(1, TCC_STEAM_AVATAR_MEDIUM) == TCC_AVATAR_NONE`; `tcc_steam_get_user_persona_name_sync(1) == ""`; `!tcc_steam_lobby_create(SteamMatchmakingLobbyType.FriendsOnly, 4, function(_r){}, noone)`; `!tcc_steam_download_scores("x", 1, 10, function(_r){})`; `tcc_steam_inventory_get_all_items() == -1`; `!tcc_steam_update()`; none of these may call a `steam_*` function (a call would throw "function not found" on iOS builds). |
| S-2 | Relay routing with synthetic structs (build each with `new SteamX()` and set fields): a `SteamMatchmakingLobbyCreated` reaches the `lobby_created` listener **twice** (listener is not consumed); `SteamInventoryResultReady{result_handle: 7}` reaches the keyed entry `"7"` once and the second delivery with the same handle falls through to the `inv_result_ready` listener; `SteamUgcCreateItemResult` consumes slot `ugc_create` (second delivery dropped; a second `__tcc_steam_slot_take("ugc_create", ...)` while pending returns `false`); a plain `{}` and an unknown struct increment `unrouted` without throwing. |
| S-3 | Isolation: a listener whose callback `throw`s does not escape `tcc_steam_relay`; `relay_errors` increments; the next delivery still works. |
| S-4 | Owner guard: `__tcc_steam_owner_alive(noone)`; an entry whose `owner` is the id of an instance that was created and destroyed (pick any harmless object) is dropped without calling the callback. |
| S-5 | Leaderboard queue (no Steam needed): inject `{kind:"download", cb, owner:noone, ...}` into `__tcc_steam_state().lb.queue`, call `__tcc_steam_lb_fail_all()`: the callback receives `undefined` exactly once. |
| S-6 | Ids: `__tcc_steam_id(undefined) == 0`, `__tcc_steam_id("x") == 0`, `__tcc_steam_id(int64("76561198000000000")) == int64("76561198000000000")` and `string(...)` round-trips through `net_parse_id`; `tcc_steam_id_valid(0) == false`, `tcc_steam_id_valid(-1) == false`. |
| S-7 (manual, Steam build) | **After every manual flow below: `__tcc_steam_state().unrouted == 0 && __tcc_steam_state().relay_errors == 0`** (read them through a debug overlay or `show_debug_message` in `tcc_steam_selfcheck`). `is_int64(steam_user_get_steam_id())` (also logged by `tcc_steam_register_callbacks`); three concurrent `tcc_steam_ugc_request_item_details` chunks each deliver once (relay registered 3 times); a second `tcc_steam_lobby_create` while one is pending still routes both replies to the listener; award an achievement and see the overlay toast within ~1 s (flush); full lists: map-stats 7, map-net 8, map-lobby 5, map-inventory 9. |

Also update the existing fixtures that build `ds_map` events (`scr_tradeup.gml:324-330`, `scr_workshopER.gml:419-499`, `scr_level_document.gml:923-936`) to synthetic result structs (the gate in section 14 rejects `[? "event_type"]`).


## 16. Open questions (none blocks writing or reviewing this contract)

1. **`game_restart()` vs `final = steam_api_shutdown`** (map-core 7.1): unknown whether the runner calls the extension `final` function on restart and whether the extension dispatcher statics survive. The contract is safe under all outcomes (X11) but cannot make Steam come back if `final` runs and nothing re-initialises. Needs the runtime test: log `steam_api_is_initialized()` right after an ending restart with a live lobby. Mitigation choice (blank `final` in the project's `Steamworks.yy` vs re-init + re-register) is the user's decision.
2. **`ptr()` of callables (U2)** is no longer a correctness gate (one relay); only smoke item S-7 (three concurrent registrations) remains.
3. **`buffer_read(buffer_u64)` returns `int64`?** (single open id item): inferred, logged and self-checked on a Steam build.
4. **Overlay dialog string case** (`"friends"` vs `"Friends"`): runtime check; swap the two macros if needed.
5. **Windows UGC paths** (map-ugc U1, blocking before merge): raw `level_directory()` / `directory_set` paths vs 2.x's `SaveFileName` pass-through; fallback is normalising inside the single hook `__tcc_steam_ugc_path`.
6. **Debug extension option per configuration** (map-core 7.2): Auto everywhere today, so an IDE run or a Steam-config build started outside Steam exits before the first frame; the user decides which configuration gets `Enabled` (gate 7 only forbids the shipping `Default`/`Steam`).
7. **SDK 1.65** must replace the 1.61 SDK at `/Users/infi/Documents/sdk` or every 3.0 build fails the hash assertion (map-core 2.6).
8. **Pump gap**: `o_fullscreensystem` is destroyed by `o_endingreq/Create_0.gml:3` until `o_loading/Create_0.gml:13`; results stay queued in Steam meanwhile. A `time_source_global` pump would close it but its restart behaviour is unverified, so it was not adopted.
9. **Untested semantics inherited from the maps**: small/medium avatar `0` vs `-1` and whether Steam fetches data for non-friends after `request_user_information(id, false)` (map-social 2.8); `NotAllowed` response for a `set_lobby_joinable(false)` lobby (map-lobby U1); whether `CloseSessionWithUser` flushes a pending BYE (map-net D5/9); inventory `get_item_price` meaning (map-inventory U4).
10. **Typed-struct delivery at runtime**: statically all 16 routed result types have decoders and are built with `new <Type>()`, but codec-id/decoder-index alignment and "never sent untyped" are only provable on a Steam build: acceptance is `unrouted == 0 && relay_errors == 0` after each manual flow (section 15, S-7); fallback in section 10.5.
11. **`yy`/resource files** are out of scope for the wrappers but part of the same change: removing the 18 `Other_69` events from object `.yy` files and the orphan `o_onlineleaderboardCH` folder.

## 17. Final tables: old wrapper -> new wrapper -> callers

Generated from `SP/wc/callers.json` (every `tcc_steam_*` reference in `scripts/`, `objects/`, `rooms/` outside SAFE and the `_API` scripts; `file:line,line`). **St**: U unchanged call sites, E callers must edit, R removed. A wrapper that is only referenced inside SAFE shows "(none outside SAFE)".

### 17.1 Old wrapper -> new wrapper -> callers

| Old wrapper (`SAFE` line today) | St | New wrapper / change | Callers (files) |
|---|---|---|---|
| `tcc_steam_activate_overlay` (2) | E | `tcc_steam_activate_overlay(_dialog)` -> `steam_friends_activate_game_overlay(string(_dialog))`; callers pass `TCC_OVERLAY_FRIENDS` / `TCC_OVERLAY_ACHIEVEMENTS` instead of `ov_friends` / `ov_achievements` | 2 uses in 2 files: `objects/o_showachievementspage/Mouse_4.gml`:1; `scripts/scr_online_friends/scr_online_friends.gml`:196 |
| `tcc_steam_activate_overlay_user` (6) | U | same; `steam_friends_activate_game_overlay_to_user` | 1 uses in 1 files: `scripts/scr_online_friends/scr_online_friends.gml`:197 |
| `tcc_steam_get_friend_rich_presence` (10) | U | same; `steam_friends_get_friend_rich_presence` | 2 uses in 1 files: `scripts/scr_online_friends/scr_online_friends.gml`:35,43 |
| `tcc_steam_get_friends_game_info` (14) | U | same name and legacy row shape; composed from `steam_friends_get_friend_*` | 1 uses in 1 files: `scripts/scr_online_friends/scr_online_friends.gml`:12 |
| `tcc_steam_get_user_persona_name_sync` (18) | U | same name; returns `""` while unknown (+ throttled `steam_friends_request_user_information`) | 3 uses in 2 files: `scripts/scr_online_friends/scr_online_friends.gml`:267; `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:715,740 |
| `tcc_steam_is_overlay_enabled` (22) | U | same; `steam_utils_is_overlay_enabled` | 1 uses in 1 files: `scripts/scr_online_friends/scr_online_friends.gml`:141 |
| `tcc_steam_lobby_activate_invite_overlay` (26) | U | same; optional `_lobby_id`; `steam_friends_activate_game_overlay_invite_dialog` | 1 uses in 1 files: `scripts/scr_online_friends/scr_online_friends.gml`:195 |
| `tcc_steam_lobby_get_owner_id` (30) | U | same; optional `_lobby_id`; returns int64 | 2 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:576,1094 |
| `tcc_steam_lobby_set_joinable` (34) | U | same; optional `_lobby_id`; `bool()` coerced | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:496 |
| `tcc_steam_user_set_played_with` (38) | U | same; `steam_friends_set_played_with`; guarded `is_numeric && > 0` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:805 |
| `tcc_steam_activate_overlay_browser` (42) | U | same; mode `Default` supplied inside | 5 uses in 5 files: `objects/o_customviewworkshop/Mouse_4.gml`:2; `objects/o_getskinmasteries/Mouse_4.gml`:8; `objects/o_openskinmarket/Mouse_4.gml`:1; `objects/o_visitlevelbutton/Mouse_4.gml`:1; `scripts/scr_timing_gameplay/scr_timing_gameplay.gml`:331 |
| `tcc_steam_activate_overlay_store` (46) | U | same; flag `None` supplied inside | 1 uses in 1 files: `objects/o_demoask/KeyPress_89.gml`:2 |
| `tcc_steam_create_leaderboard` (50) | E | same name; callers pass `SteamLeaderboardSortMethod.*` / `SteamLeaderboardDisplayType.*` instead of `lb_sort_*` / `lb_disp_*`; queued, returns bool | 2 uses in 2 files: `objects/o_onlineleaderboardCH/Create_0.gml`:4; `scripts/scr_saveworkshopmedals/scr_saveworkshopmedals.gml`:19 |
| `tcc_steam_download_friends_scores` (54) | E | `(_board, _callback, _owner = noone)`; callback gets normalised rows or `undefined` | 1 uses in 1 files: `scripts/reloadleaderboards/reloadleaderboards.gml`:52 |
| `tcc_steam_download_scores` (58) | E | `(_board, _start, _end, _callback, _owner = noone)`; callback gets normalised rows or `undefined` | 3 uses in 3 files: `objects/o_onlineleaderboardCH/Other_69.gml`:2; `objects/o_settings/Create_0.gml`:35; `scripts/reloadleaderboards/reloadleaderboards.gml`:50 |
| `tcc_steam_download_scores_around_user` (62) | E | `(_board, _from, _to, _callback, _owner = noone)`; callback gets normalised rows or `undefined` | 3 uses in 1 files: `scripts/reloadleaderboardsmini/reloadleaderboardsmini.gml`:20,23,25 |
| `tcc_steam_get_app_id` (66) | U | same; `steam_utils_get_app_id()`; fallback stays `false` | 41 uses in 40 files: `objects/o_LEBackground/Mouse_4.gml`:1; `objects/o_LEDiamondMedal/Mouse_4.gml`:1; `objects/o_LEFog/Mouse_4.gml`:1; `objects/o_LELevelExpand/Mouse_4.gml`:3; `objects/o_LELiquid/Mouse_4.gml`:1; `objects/o_LELoad/Mouse_4.gml`:1; `objects/o_LEMusic/Mouse_4.gml`:11; `objects/o_LEName/Mouse_4.gml`:1; `objects/o_LEPublish/Mouse_4.gml`:1; `objects/o_LESave/Mouse_4.gml`:1; `objects/o_LESceneryChange/Mouse_4.gml`:1; `objects/o_LEStarBackground/Mouse_4.gml`:1; `objects/o_LEText/Mouse_4.gml`:1; `objects/o_LEThumbnail/Mouse_4.gml`:1; `objects/o_autothumbnailsettings/Mouse_4.gml`:3; `objects/o_customlevelsbutton/Mouse_4.gml`:1; `objects/o_endlessbutton/Mouse_4.gml`:1; `objects/o_fullversiongame/Create_0.gml`:3; `objects/o_hardmode/Mouse_4.gml`:2; `objects/o_levelselectbutton/Mouse_4.gml`:2; `objects/o_load/Create_0.gml`:1; `objects/o_load/Mouse_4.gml`:1; `objects/o_localmultiplayerbutton/Mouse_4.gml`:1; `objects/o_monthbuttonC/Mouse_4.gml`:6; `objects/o_player/Step_0.gml`:835; `objects/o_settingbutton/Mouse_4.gml`:24; `objects/o_title/Create_0.gml`:28; `objects/o_version/Create_0.gml`:23; `objects/o_workshopERbutton/Mouse_4.gml`:1; `objects/o_workshopchallengesbutton/Mouse_4.gml`:1; `rooms/r_lvl41/InstanceCreationCode_inst_381A65E0.gml`:1; `rooms/r_lvl42/InstanceCreationCode_inst_6A3350E6.gml`:1; `scripts/loadstatschallenge/loadstatschallenge.gml`:459; `scripts/scr_levelselect_data/scr_levelselect_data.gml`:104; `scripts/scr_loaddaily/scr_loaddaily.gml`:2; `scripts/scr_loadsettings/scr_loadsettings.gml`:2,73; `scripts/scr_online_friends/scr_online_friends.gml`:11; `scripts/scr_online_session/scr_online_session.gml`:568; `scripts/scr_savegame/scr_savegame.gml`:2; `scripts/scr_settings_definitions/scr_settings_definitions.gml`:53 |
| `tcc_steam_get_number_of_current_players` (70) | U | same 0-arg signature, returns "issued"; wrapper writes `global.playercount`; the `Other_69` / `o_version` Step polling that consumed the event are deleted | 4 uses in 4 files: `objects/o_checkplayercount/Alarm_0.gml`:8; `objects/o_checkplayercount/Create_0.gml`:19; `objects/o_version/Create_0.gml`:18; `objects/o_version/Step_0.gml`:9 |
| `tcc_steam_get_persona_name` (74) | U | same; `steam_friends_get_persona_name` | 5 uses in 4 files: `objects/o_settings/Create_0.gml`:28; `objects/o_version/Draw_0.gml`:22; `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:198,486; `scripts/scr_online_session/scr_online_session.gml`:392 |
| `tcc_steam_get_user_avatar` (78) | E | same name; sizes `TCC_STEAM_AVATAR_*`, returns `> 0` / `TCC_AVATAR_PENDING` (-1) / `TCC_AVATAR_NONE` (0, was -1 when Steam is down); callers poll | 5 uses in 5 files: `objects/o_onlineleaderboards/Other_69.gml`:35; `objects/o_onlineleaderboardsmini/Other_69.gml`:39; `objects/o_profilepicture/Create_0.gml`:36; `objects/o_version/Draw_0.gml`:36; `scripts/scr_online_friends/scr_online_friends.gml`:71 |
| `tcc_steam_get_user_persona_name` (82) | R | REMOVED: use `tcc_steam_get_user_persona_name_sync` polled from Alarm/Step (no event, no request id) | 8 uses in 5 files: `objects/o_customlevelsbrowser/Other_69.gml`:78,130; `objects/o_customlevelworkshopbuttonplay/Alarm_0.gml`:3,42; `objects/o_customlevelworkshopbuttonplay/Create_0.gml`:22,34; `objects/o_customlevelworkshopbuttonplay/Draw_73.gml`:1; `objects/o_version/Draw_0.gml`:22 |
| `tcc_steam_get_user_steam_id` (86) | U | same; returns int64 (`steam_user_get_steam_id`) | 8 uses in 5 files: `objects/o_profilepicture/Create_0.gml`:36; `objects/o_version/Draw_0.gml`:21; `objects/o_workshopchallengecreator/Step_0.gml`:29; `scripts/badge_system/badge_system.gml`:199; `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:433,450,531,1075 |
| `tcc_steam_image_get_rgba` (90) | U | same; 3rd argument ignored | 4 uses in 4 files: `objects/o_onlineleaderboards/Create_0.gml`:21; `objects/o_onlineleaderboardsmini/Create_0.gml`:23; `objects/o_profilepicture/Create_0.gml`:19; `scripts/scr_online_friends/scr_online_friends.gml`:57 |
| `tcc_steam_image_get_size` (94) | U | same; still `[w, h]` or `undefined` | 4 uses in 4 files: `objects/o_onlineleaderboards/Create_0.gml`:13; `objects/o_onlineleaderboardsmini/Create_0.gml`:15; `objects/o_profilepicture/Create_0.gml`:11; `scripts/scr_online_friends/scr_online_friends.gml`:52 |
| `tcc_steam_init` (98) | U | same; returns `tcc_steam_initialised()` (3.0 auto-initialises) | 1 uses in 1 files: `objects/o_profilepicture/Create_0.gml`:7 |
| `tcc_steam_initialised` (102) | U | same; `bool(tcc_steam_ready())` (`steam_api_is_initialized`) | 29 uses in 18 files: `objects/o_customlevelsbrowser/Other_69.gml`:1; `objects/o_fullscreensystem/Other_69.gml`:3; `objects/o_getallinventoryitems/Create_0.gml`:2; `objects/o_getallinventoryitems/Other_69.gml`:1; `objects/o_onlineleaderboardCH/Other_69.gml`:1; `objects/o_onlineleaderboards/Other_69.gml`:1; `objects/o_onlineleaderboardsmini/Other_69.gml`:1; `objects/o_publishinghappenshere/Create_0.gml`:35; `objects/o_publishworkshopchallenge/Other_69.gml`:1; `objects/o_title/Create_0.gml`:17,24; `objects/o_title/Other_69.gml`:1; `objects/o_version/Create_0.gml`:8; `scripts/badge_system/badge_system.gml`:190; `scripts/scr_online_friends/scr_online_friends.gml`:10,119,134,294; `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:318,406,446,530,1161; `scripts/scr_platform_services/scr_platform_services.gml`:181,188,205; `scripts/scr_rich_presence/scr_rich_presence.gml`:8; `scripts/scr_tradeup/scr_tradeup.gml`:81,167 |
| `tcc_steam_inventory_exchange_items` (106) | E | `(_create, _destroy, _callback, _owner = noone)` -> handle or -1; callback gets `SteamInventoryResultReady` | 2 uses in 2 files: `objects/o_title/Other_69.gml`:13; `scripts/scr_tradeup/scr_tradeup.gml`:170 |
| `tcc_steam_inventory_get_all_items` (110) | U | same; handle or -1; result via `tcc_steam_inventory_set_callback_result_ready` | 1 uses in 1 files: `scripts/scr_tradeup/scr_tradeup.gml`:83 |
| `tcc_steam_inventory_get_item_price` (114) | U | same; `current_price` or `undefined` | 1 uses in 1 files: `objects/o_title/Other_69.gml`:12 |
| `tcc_steam_inventory_request_prices` (118) | U | same 0-arg call works (default callback); optional `(_callback, _owner)` | 1 uses in 1 files: `objects/o_title/Create_0.gml`:5 |
| `tcc_steam_inventory_result_destroy` (122) | U | same; explicit true/false | 5 uses in 1 files: `scripts/scr_tradeup/scr_tradeup.gml`:100,112,132,144,145 |
| `tcc_steam_inventory_result_get_item_property` (126) | U | same | (none outside SAFE) |
| `tcc_steam_inventory_result_get_items` (130) | E | same name and item shape; NR / failure value is now `undefined` (was `[]`) | 1 uses in 1 files: `scripts/scr_tradeup/scr_tradeup.gml`:111 |
| `tcc_steam_inventory_result_get_status` (134) | U | same; returns `SteamApiResult` | (none outside SAFE) |
| `tcc_steam_inventory_result_get_unix_timestamp` (138) | U | same; `steam_inventory_get_result_timestamp` | (none outside SAFE) |
| `tcc_steam_inventory_trigger_item_drop` (142) | U | same 1-arg call works (default callback releases the handle); optional `(_item_def, _callback, _owner)` | 1 uses in 1 files: `objects/o_title/Create_0.gml`:4 |
| `tcc_steam_is_user_logged_on` (146) | U | same; `steam_user_logged_on` | 3 uses in 3 files: `objects/o_publishinghappenshere/Create_0.gml`:35; `objects/o_publishworkshopchallenge/Create_0.gml`:21; `scripts/scr_timing_ui/scr_timing_ui.gml`:32 |
| `tcc_steam_lobby_create` (150) | E | `(_type, _max_members, _callback, _owner = noone)`; type is `SteamMatchmakingLobbyType.FriendsOnly`; callback gets `SteamMatchmakingLobbyCreated` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:437 |
| `tcc_steam_lobby_get_data` (154) | U | same; optional `_lobby_id` | 6 uses in 4 files: `objects/o_pausescreen/Draw_73.gml`:26; `scripts/scr_online_friends/scr_online_friends.gml`:124; `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:1077,1078,1104; `scripts/scr_online_session/scr_online_session.gml`:411 |
| `tcc_steam_lobby_get_member_count` (158) | U | same; optional `_lobby_id`; NR value `0` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:502 |
| `tcc_steam_lobby_get_member_id` (162) | U | same; optional `_lobby_id`; int64, NR `int64(0)` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:505 |
| `tcc_steam_lobby_is_owner` (166) | U | same (no callers) | (none outside SAFE) |
| `tcc_steam_lobby_join_id` (170) | E | `(_lobby_id, _callback, _owner = noone)`; callback gets `SteamMatchmakingLobbyEnter` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:453 |
| `tcc_steam_lobby_leave` (174) | U | same; optional `_lobby_id`; the 4 callers outside `net_leave_lobby` pass the reply id (EDIT there, see map-lobby 5.3) | 5 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:388,463,1066,1080,1086 |
| `tcc_steam_lobby_set_data` (178) | U | same; optional `_lobby_id` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:470 |
| `tcc_steam_lobby_set_owner_id` (182) | U | same; optional `_lobby_id` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:386 |
| `tcc_steam_net_close_p2p_session` (186) | U | same; `steam_networking_messages_close_session_with_user` | 2 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:389,820 |
| `tcc_steam_net_packet_get_data` (190) | R | REMOVED: payload is already in the buffer passed to `tcc_steam_net_packet_receive` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:705 |
| `tcc_steam_net_packet_get_sender_id` (194) | R | REMOVED: `_message.steam_id_remote` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:695 |
| `tcc_steam_net_packet_get_size` (198) | R | REMOVED: `_message.size` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:696 |
| `tcc_steam_net_packet_receive` (202) | E | `(_buffer)` -> `SteamNetworkingMessage` or `undefined`; buffer must be a fixed 524288-byte buffer | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:693 |
| `tcc_steam_net_packet_send` (206) | E | `(_steam_id, _buffer, _size, _flags = undefined)`; flags `TCC_NET_SEND_RELIABLE/UNRELIABLE`; `true` only for `SteamApiResult.Ok` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:606 |
| `tcc_steam_net_set_auto_accept_p2p_sessions` (214) | R | REMOVED -> `tcc_steam_net_set_session_request_callback(_cb)` + `tcc_steam_net_accept_session(_id)` | 1 uses in 1 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:534 |
| `tcc_steam_reset_all_stats_achievements` (218) | U | same; `steam_userstats_reset_all_stats(true)` | 1 uses in 1 files: `objects/o_steamachievementreset/KeyPress_65.gml`:3 |
| `tcc_steam_send_screenshot` (222) | E | same name; absolute path required (no callers) | (none outside SAFE) |
| `tcc_steam_set_rich_presence` (226) | U | same; `steam_friends_set_rich_presence(string, string)` | 78 uses in 2 files: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:1167,1168,1170,1171; `scripts/scr_rich_presence/scr_rich_presence.gml`:18,23,28,33,38,43,48,53,58,63,68,73,78,83,88,93,98,103,108,113,123,124,126,136,137,146,156,160,163,166,169,185,186,192,198,209,210,221,222,228,229,233,234,238,239,243,244,248,249,256,257,264,265,274,275,284,285,293,294,300,301,307,313,314,320,326,332,333,343,344,352,359,360,367 |
| `tcc_steam_ugc_create_item` (230) | E | `(_app_id, _file_type, _callback, _owner = noone)`; file type `SteamRemoteStorageWorkshopFileType.Community`; callback gets `SteamUgcCreateItemResult` | 2 uses in 2 files: `objects/o_publishinghappenshere/Create_0.gml`:45; `objects/o_publishworkshopchallenge/Create_0.gml`:176 |
| `tcc_steam_ugc_create_query_all` (234) | E | same 3 args; callers pass `SteamUgcQuery.*` / `SteamUgcMatchingUgcType.Items`; returns handle or -1 | 2 uses in 2 files: `objects/o_customlevelsbrowser/Create_0.gml`:54; `scripts/scr_workshopER/scr_workshopER.gml`:83 |
| `tcc_steam_ugc_get_item_install_info` (238) | U | same (ds_map shim) | 11 uses in 8 files: `objects/o_customlevelsbrowser/Create_0.gml`:70; `objects/o_publishworkshopchallenge/Create_0.gml`:91; `objects/o_workshopERloading/Step_0.gml`:37; `objects/o_workshopchallengecreator/Create_0.gml`:37; `objects/o_workshopchallengesplay/Mouse_4.gml`:17; `scripts/scr_online_session/scr_online_session.gml`:884; `scripts/scr_workshopER/scr_workshopER.gml`:19,182,225; `scripts/scr_workshopchallenge/scr_workshopchallenge.gml`:113,157 |
| `tcc_steam_ugc_get_item_update_info` (242) | U | same (ds_map shim) | 7 uses in 5 files: `objects/o_customlevelsbrowser/Create_0.gml`:114; `objects/o_customlevelsbrowser/Other_69.gml`:70; `objects/o_customlevelsbrowser/Step_0.gml`:142,208,225; `objects/o_workshopERloading/Step_0.gml`:30; `scripts/scr_online_session/scr_online_session.gml`:879 |
| `tcc_steam_ugc_get_item_update_progress` (246) | R | REMOVED (no callers) | (none outside SAFE) |
| `tcc_steam_ugc_get_subscribed_items` (250) | U | same (ds_list shim, int64 ids) | 7 uses in 6 files: `objects/o_customlevelsbrowser/Create_0.gml`:64; `objects/o_showsubscribedlevels/Draw_73.gml`:11; `objects/o_workshopchallengecreator/Create_0.gml`:24; `objects/o_workshopchallengesplay/Mouse_4.gml`:11; `scripts/scr_online_session/scr_online_session.gml`:912,995; `scripts/scr_workshopER/scr_workshopER.gml`:13 |
| `tcc_steam_ugc_num_subscribed_items` (254) | U | same | 2 uses in 2 files: `objects/o_customlevelsplay/Create_0.gml`:6; `scripts/scr_timing_ui/scr_timing_ui.gml`:349 |
| `tcc_steam_ugc_query_set_search_text` (258) | U | same | 1 uses in 1 files: `objects/o_customlevelsbrowser/Create_0.gml`:56 |
| `tcc_steam_ugc_request_item_details` (262) | E | `(_file_ids, _max_age_seconds, _callback, _owner = noone)`; callback `(_ok, _items, _completed)` once per 50-id chunk | 7 uses in 6 files: `objects/o_customlevelsbrowser/Create_0.gml`:122; `objects/o_customlevelworkshopbuttonplay/Alarm_0.gml`:2,39; `objects/o_customlevelworkshopbuttonplay/Create_0.gml`:21; `objects/o_customlevelworkshopbuttonplay/Other_10.gml`:1; `objects/o_playmostrecentlevelCL/Mouse_4.gml`:1; `objects/o_workshoplevelselectbutton/Alarm_0.gml`:7 |
| `tcc_steam_ugc_send_query` (266) | E | `(_qh, _callback, _owner = noone)`; callback `(_ok, _items, _completed)`; wrapper releases the handle | 2 uses in 2 files: `objects/o_customlevelsbrowser/Create_0.gml`:58; `scripts/scr_workshopER/scr_workshopER.gml`:88 |
| `tcc_steam_ugc_set_item_content` (270) | U | same | 2 uses in 2 files: `objects/o_publishinghappenshere/Create_0.gml`:27; `objects/o_publishworkshopchallenge/Other_69.gml`:30 |
| `tcc_steam_ugc_set_item_description` (274) | U | same | 2 uses in 2 files: `objects/o_publishinghappenshere/Create_0.gml`:23; `objects/o_publishworkshopchallenge/Other_69.gml`:22 |
| `tcc_steam_ugc_set_item_preview` (278) | U | same | 2 uses in 2 files: `objects/o_publishinghappenshere/Create_0.gml`:26; `objects/o_publishworkshopchallenge/Other_69.gml`:28 |
| `tcc_steam_ugc_set_item_tags` (282) | U | same | 2 uses in 2 files: `objects/o_publishinghappenshere/Create_0.gml`:25; `objects/o_publishworkshopchallenge/Other_69.gml`:26 |
| `tcc_steam_ugc_set_item_title` (286) | U | same | 2 uses in 2 files: `objects/o_publishinghappenshere/Create_0.gml`:22; `objects/o_publishworkshopchallenge/Other_69.gml`:21 |
| `tcc_steam_ugc_set_item_visibility` (290) | E | same; callers pass `SteamRemoteStoragePublishedFileVisibility.Public` instead of `ugc_visibility_public` | 2 uses in 2 files: `objects/o_publishinghappenshere/Create_0.gml`:24; `objects/o_publishworkshopchallenge/Other_69.gml`:23 |
| `tcc_steam_ugc_start_item_update` (294) | U | same; handle or -1 (use `tcc_steam_ugc_handle_valid`) | 2 uses in 2 files: `objects/o_publishinghappenshere/Create_0.gml`:20; `objects/o_publishworkshopchallenge/Other_69.gml`:20 |
| `tcc_steam_ugc_submit_item_update` (298) | E | `(_h, _note, _callback, _owner = noone)`; callback gets `SteamUgcSubmitItemUpdateResult` | 2 uses in 2 files: `objects/o_publishinghappenshere/Create_0.gml`:31; `objects/o_publishworkshopchallenge/Other_69.gml`:32 |
| `tcc_steam_ugc_subscribe_item` (302) | U | same; shared internal result handler | 5 uses in 3 files: `objects/o_customlevelsbrowser/Step_0.gml`:181; `scripts/scr_online_session/scr_online_session.gml`:906,915,999; `scripts/scr_workshopER/scr_workshopER.gml`:199 |
| `tcc_steam_ugc_unsubscribe_item` (306) | U | same | 2 uses in 2 files: `scripts/scr_online_session/scr_online_session.gml`:927; `scripts/scr_workshopER/scr_workshopER.gml`:319 |
| `tcc_steam_update` (310) | U | same; `steam_api_run_callbacks()` + stats flush + queue watchdog + sweep | 1 uses in 1 files: `objects/o_fullscreensystem/Step_0.gml`:4 |
| `tcc_steam_user_installed_dlc` (314) | U | same; `steam_apps_is_dlc_installed` | 1 uses in 1 files: `objects/o_commentarynodegame/Create_0.gml`:4 |
| `tcc_steam_user_owns_dlc` (318) | U | same; `steam_apps_is_subscribed_app` | 13 uses in 6 files: `objects/o_commentarynodegame/Create_0.gml`:3; `objects/o_devcommentarysettings/Mouse_4.gml`:3; `objects/o_settingbutton/Mouse_4.gml`:19; `objects/o_settingbutton/Step_0.gml`:41; `scripts/badge_system/badge_system.gml`:172,173,174,175,176,178,179,180; `scripts/scr_commentary/scr_commentary.gml`:7 |

### 17.2 New wrappers and helpers (no old counterpart) and who calls them

| New | Callers / edit site |
|---|---|
| `tcc_steam_ready()` | optional: any `platform_steam() && tcc_steam_initialised()` pair may be shortened; no edit required |
| `tcc_steam_register_callbacks(_force = false)` | `objects/o_fullscreensystem/Create_0.gml` (add `tcc_steam_register_callbacks(true);`); called internally by `tcc_steam_update()` on ready edges and by the `set_*callback*` wrappers |
| `tcc_steam_set_lobby_callbacks(_chat_update, _join_requested)` | `net_register_steam_callbacks()` (new, `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`), called from `objects/o_networkmanager/Create_0.gml` after `net_init()` |
| `tcc_steam_inventory_set_callback_result_ready(_cb)` | `objects/o_getallinventoryitems/Create_0.gml` (after line 9, only when `owns_inventory`) |
| `tcc_steam_inventory_clear_callback_result_ready()` | `objects/o_getallinventoryitems/CleanUp_0.gml` (inside `if (owns_inventory)`) |
| `tcc_steam_inventory_release_result(_r)`, `tcc_steam_inventory_ignore_result(_r)` | default callbacks used inside SAFE only |
| `tcc_steam_get_achievement(_name)` | `scripts/scr_platform_services/scr_platform_services.gml:181` (`achievement_earned`) |
| `tcc_steam_set_achievement(_name)` | `scripts/scr_platform_services/scr_platform_services.gml:188` (`achievement_award`) |
| `tcc_steam_upload_score(_board, _score, _force = false)` | `scripts/scr_platform_services/scr_platform_services.gml:205` (`platform_submit_score_ext`) |
| `tcc_steam_net_set_session_request_callback(_cb)` | `scripts/scr_online_multiplayer/scr_online_multiplayer.gml:532-536` (`net_tick`, replaces the auto-accept call) |
| `tcc_steam_net_accept_session(_steam_id)` | `net_accept_pending_sessions()` (new, `scr_online_multiplayer.gml`, map-net 3) |
| `tcc_steam_net_clear_session_callbacks()` | `objects/o_networkmanager/CleanUp_0.gml` restart branch (optional, map-net D10) |
| `tcc_steam_image_to_sprite(_image)` | `objects/o_onlineleaderboards/Create_0.gml`, `objects/o_onlineleaderboardsmini/Create_0.gml`, `objects/o_profilepicture/Create_0.gml` (replace the local `steam_image_create_sprite`), `scripts/scr_online_friends/scr_online_friends.gml:49` (`net_avatar_from_image`), and the rows callbacks in `scripts/reloadleaderboards/reloadleaderboards.gml`, `scripts/reloadleaderboardsmini/reloadleaderboardsmini.gml` |
| `tcc_steam_ugc_handle_valid(_h)` | `objects/o_publishinghappenshere/Create_0.gml:21`, `objects/o_publishworkshopchallenge/*`, `objects/o_customlevelsbrowser/Create_0.gml:54-58`, `scripts/scr_workshopER/scr_workshopER.gml:83-95` (replace `<= 0` / `== -1` tests) |
| `tcc_steam_id_valid(_v)` | optional helper for id checks in call-site code |
| `macros `TCC_OVERLAY_*`, `TCC_STEAM_AVATAR_*`, `TCC_AVATAR_*`, `TCC_NET_SEND_*`` | see section 13 |

### 17.3 Identifiers used outside any wrapper (must be migrated or are allowed to stay)

Generated from `SP/wc/raw_identifiers.json` (bare tokens `steam_*`, `ov_*`, `lb_sort_*`/`lb_disp_*`, `ugc_*` outside SAFE). The `check_port_steam.py` gate (section 14) fails on every row of groups 1-4 until it is migrated.


**1. Removed 2.x constants -> replacement (EDIT)**

| Identifier | Replacement / action | Uses |
|---|---|---|
| `ov_friends` | `TCC_OVERLAY_FRIENDS` | 1 uses: `scripts/scr_online_friends/scr_online_friends.gml`:196 |
| `ov_achievements` | `TCC_OVERLAY_ACHIEVEMENTS` | 1 uses: `objects/o_showachievementspage/Mouse_4.gml`:1 |
| `steam_user_avatar_size_small` | `TCC_STEAM_AVATAR_SMALL` | 2 uses: `objects/o_onlineleaderboards/Create_0.gml`:7; `objects/o_onlineleaderboardsmini/Create_0.gml`:9 |
| `steam_user_avatar_size_medium` | `TCC_STEAM_AVATAR_MEDIUM` | 3 uses: `objects/o_profilepicture/Create_0.gml`:36; `objects/o_version/Draw_0.gml`:36; `scripts/scr_online_friends/scr_online_friends.gml`:71 |
| `steam_lobby_type_friends_only` | `SteamMatchmakingLobbyType.FriendsOnly` | 1 uses: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:437 |
| `steam_net_packet_type_reliable` | `TCC_NET_SEND_RELIABLE` (via `net_send_to`, map-net 5.1) | 1 uses: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:607 |
| `steam_net_packet_type_unreliable` | `TCC_NET_SEND_UNRELIABLE` | 1 uses: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:607 |
| `lb_sort_ascending` | `SteamLeaderboardSortMethod.Ascending` (`o_onlineleaderboardCH` is an orphan: delete it) | 2 uses: `objects/o_onlineleaderboardCH/Create_0.gml`:4; `scripts/scr_saveworkshopmedals/scr_saveworkshopmedals.gml`:19 |
| `lb_disp_time_ms` | `SteamLeaderboardDisplayType.TimeMilliSeconds` | 2 uses: `objects/o_onlineleaderboardCH/Create_0.gml`:4; `scripts/scr_saveworkshopmedals/scr_saveworkshopmedals.gml`:19 |
| `ugc_result_success` | `SteamApiResult.Ok` (16 uses; most disappear with the handlers) | 16 uses in 9 files: `objects/o_customlevelsbrowser/Other_69.gml`; `objects/o_customlevelworkshopbuttonplay/Other_69.gml`; `objects/o_playmostrecentlevelCL/Mouse_4.gml`; `objects/o_publishworkshopchallenge/Other_69.gml`; `objects/o_workshopERloading/Other_69.gml`; `objects/o_workshoplevelselectbutton/Other_69.gml`; `scripts/scr_level_document/scr_level_document.gml`; `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`; `scripts/scr_workshopER/scr_workshopER.gml` |
| `ugc_filetype_community` | `SteamRemoteStorageWorkshopFileType.Community` | 2 uses: `objects/o_publishinghappenshere/Create_0.gml`:45; `objects/o_publishworkshopchallenge/Create_0.gml`:176 |
| `ugc_visibility_public` | `SteamRemoteStoragePublishedFileVisibility.Public` | 2 uses: `objects/o_publishinghappenshere/Create_0.gml`:24; `objects/o_publishworkshopchallenge/Other_69.gml`:23 |
| `ugc_match_Items` | `SteamUgcMatchingUgcType.Items` | 2 uses: `objects/o_customlevelsbrowser/Create_0.gml`:54; `scripts/scr_workshopER/scr_workshopER.gml`:83 |
| `ugc_query_RankedByVote` | `SteamUgcQuery.RankedByVote` | 1 uses: `objects/o_customlevelsbrowser/Create_0.gml`:54 |
| `ugc_query_RankedByPublicationDate` | `SteamUgcQuery.RankedByPublicationDate` | 1 uses: `scripts/scr_workshopER/scr_workshopER.gml`:83 |

**2. Raw 2.x function names outside SAFE (move behind wrappers / reword)**

| Identifier | Replacement / action | Uses |
|---|---|---|
| `steam_get_achievement` | `tcc_steam_get_achievement` | 1 uses: `scripts/scr_platform_services/scr_platform_services.gml`:181 |
| `steam_set_achievement` | `tcc_steam_set_achievement` | 1 uses: `scripts/scr_platform_services/scr_platform_services.gml`:188 |
| `steam_upload_score_ext` | `tcc_steam_upload_score` | 1 uses: `scripts/scr_platform_services/scr_platform_services.gml`:205 |
| `steam_inventory_exchange_items` | doc comment only (`scr_tradeup.gml:165`): reword so it does not look like a call | 1 uses: `scripts/scr_tradeup/scr_tradeup.gml`:165 |

**3. Keys / state of the removed Async-Steam events (disappear with the handlers)**

| Identifier | Replacement / action | Uses |
|---|---|---|
| `steam_id_owner` | `item.owner_steam_id` of the UGC query callback (Other_69 keys; `o_playmostrecentlevelCL` is dead) | 5 uses: `objects/o_customlevelsbrowser/Other_69.gml`:29,100; `objects/o_customlevelworkshopbuttonplay/Other_69.gml`:13; `objects/o_playmostrecentlevelCL/Mouse_4.gml`:11; `objects/o_workshoplevelselectbutton/Other_69.gml`:7 |
| `steam_details` | async request id of `tcc_steam_ugc_request_item_details`: removed, the per-call callback replaces `map_id == steam_details` | 10 uses: `objects/o_customlevelworkshopbuttonplay/Alarm_0.gml`:2,39; `objects/o_customlevelworkshopbuttonplay/Create_0.gml`:21; `objects/o_customlevelworkshopbuttonplay/Other_10.gml`:1; `objects/o_customlevelworkshopbuttonplay/Other_69.gml`:6; `objects/o_playmostrecentlevelCL/Mouse_4.gml`:1,5; `objects/o_workshoplevelselectbutton/Alarm_0.gml`:7; `objects/o_workshoplevelselectbutton/Create_0.gml`:21; `objects/o_workshoplevelselectbutton/Other_69.gml`:4 |
| `ugc_query` | string `event_type` literal: deleted handlers AND the fixture/matcher code in `scr_workshopER.gml:344-345,450-480` (rewrite with synthetic `SteamUgcQueryCompleted` / `SteamUgcQueryResult` structs, map-ugc 3) | 5 uses: `objects/o_customlevelsbrowser/Other_69.gml`:9; `scripts/scr_workshopER/scr_workshopER.gml`:345,450,461,480 |
| `ugc_subscribe_item` | string `event_type` literal (deleted handlers) | 2 uses: `objects/o_workshopERloading/Other_69.gml`:5; `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:1139 |
| `ugc_create_item` | string `event_type` literal: deleted handlers and `scr_level_document.gml:764-770,924-929` (use `new SteamUgcCreateItemResult()` fixtures) | 3 uses: `objects/o_publishworkshopchallenge/Other_69.gml`:5; `scripts/scr_level_document/scr_level_document.gml`:767,924 |
| `ugc_update_item` | string `event_type` literal: deleted handlers and `scr_level_document.gml` fixtures (use `new SteamUgcSubmitItemUpdateResult()`) | 3 uses: `objects/o_publishworkshopchallenge/Other_69.gml`:37; `scripts/scr_level_document/scr_level_document.gml`:770,929 |
| `ugc_download_item` | selfcheck fixture string in `scr_workshopER.gml:459` (rewrite fixture to synthetic 3.0 structs) | 1 uses: `scripts/scr_workshopER/scr_workshopER.gml`:459 |

**4. Local copy of a Steam helper**

| Identifier | Replacement / action | Uses |
|---|---|---|
| `steam_image_create_sprite` | `tcc_steam_image_to_sprite` (local definitions in `o_onlineleaderboards/Create_0.gml:11`, `o_onlineleaderboardsmini/Create_0.gml:13`, `o_profilepicture/Create_0.gml:9`, plus the separate copy `net_avatar_from_image`, `scr_online_friends.gml:49`) | 8 uses: `objects/o_onlineleaderboards/Create_0.gml`:11; `objects/o_onlineleaderboards/Other_69.gml`:37,63; `objects/o_onlineleaderboardsmini/Create_0.gml`:13; `objects/o_onlineleaderboardsmini/Other_69.gml`:41,67; `objects/o_profilepicture/Create_0.gml`:9,38 |

**5. Project-local names that STAY (allow-listed by the gate; not Steam API)**

| Identifier | Replacement / action | Uses |
|---|---|---|
| `steam_api` | `global.steam_api` flag | 1 uses: `scripts/scr_workshopER/scr_workshopER.gml`:421 |
| `steam_is_available` | `global.steam_is_available` | 2 uses: `objects/o_checkplayercount/Alarm_0.gml`:7; `objects/o_checkplayercount/Create_0.gml`:18 |
| `steam_display` | Steam-reserved rich-presence key string | 54 uses in 2 files: `scripts/scr_online_friends/scr_online_friends.gml`; `scripts/scr_rich_presence/scr_rich_presence.gml` |
| `steam_player_group` | rich-presence key string | 2 uses: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:1167,1170 |
| `steam_player_group_size` | rich-presence key string | 2 uses: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:1168,1171 |
| `steam_id` | net player record member / docs | 3 uses: `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`:775,789,810 |
| `steam_list` | ds_list of subscribed ids | 24 uses in 5 files: `objects/o_customlevelsbrowser/Create_0.gml`; `objects/o_showsubscribedlevels/Draw_73.gml`; `objects/o_workshopchallengecreator/Create_0.gml`; `objects/o_workshopchallengesplay/Mouse_4.gml`; `scripts/scr_workshopER/scr_workshopER.gml` |
| `steam_name` | leaderboard row array | 22 uses in 12 files: `objects/o_onlineleaderboardCH/Create_0.gml`; `objects/o_onlineleaderboardCH/Draw_0.gml`; `objects/o_onlineleaderboardCH/Other_69.gml`; `objects/o_onlineleaderboards/Draw_0.gml`; `objects/o_onlineleaderboards/Other_69.gml`; `objects/o_onlineleaderboardsmini/Draw_0.gml`; `objects/o_onlineleaderboardsmini/Other_69.gml`; `objects/o_settings/Alarm_0.gml`; `objects/o_settings/Create_0.gml`; `objects/o_settings/Other_69.gml`; `scripts/reloadleaderboards/reloadleaderboards.gml`; `scripts/reloadleaderboardsmini/reloadleaderboardsmini.gml` |
| `steam_rank` | leaderboard row array | 27 uses in 11 files: `objects/o_onlineleaderboardCH/Create_0.gml`; `objects/o_onlineleaderboardCH/Draw_0.gml`; `objects/o_onlineleaderboardCH/Other_69.gml`; `objects/o_onlineleaderboards/Draw_0.gml`; `objects/o_onlineleaderboards/Other_69.gml`; `objects/o_onlineleaderboardsmini/Draw_0.gml`; `objects/o_onlineleaderboardsmini/Other_69.gml`; `objects/o_settings/Create_0.gml`; `objects/o_settings/Other_69.gml`; `scripts/reloadleaderboards/reloadleaderboards.gml`; `scripts/reloadleaderboardsmini/reloadleaderboardsmini.gml` |
| `steam_score` | leaderboard row array | 19 uses in 11 files: `objects/o_onlineleaderboardCH/Create_0.gml`; `objects/o_onlineleaderboardCH/Draw_0.gml`; `objects/o_onlineleaderboardCH/Other_69.gml`; `objects/o_onlineleaderboards/Draw_0.gml`; `objects/o_onlineleaderboards/Other_69.gml`; `objects/o_onlineleaderboardsmini/Draw_0.gml`; `objects/o_onlineleaderboardsmini/Other_69.gml`; `objects/o_settings/Create_0.gml`; `objects/o_settings/Other_69.gml`; `scripts/reloadleaderboards/reloadleaderboards.gml`; `scripts/reloadleaderboardsmini/reloadleaderboardsmini.gml` |
| `steam_userid` | leaderboard row array; holds int64, key with `string(...)` | 10 uses: `objects/o_onlineleaderboards/Create_0.gml`:8; `objects/o_onlineleaderboards/Draw_0.gml`:15,16; `objects/o_onlineleaderboards/Other_69.gml`:30; `objects/o_onlineleaderboardsmini/Create_0.gml`:10; `objects/o_onlineleaderboardsmini/Draw_0.gml`:30,31; `objects/o_onlineleaderboardsmini/Other_69.gml`:34; `scripts/reloadleaderboards/reloadleaderboards.gml`:36; `scripts/reloadleaderboardsmini/reloadleaderboardsmini.gml`:7 |

**5b. `async_load[? "event_type"]` literal reads (gate `async_load_event_type`)**

| Site | Action |
|---|---|
| 18 `objects/*/Other_69.gml` handlers | deleted (section 12) |
| `scripts/scr_online_multiplayer/scr_online_multiplayer.gml:1019` (`net_handle_async_steam`) | function removed |
| `scripts/scr_tradeup/scr_tradeup.gml:74, 325, 328` | struct matcher + synthetic fixtures (map-inventory 7) |
| `scripts/scr_workshopER/scr_workshopER.gml:344-345, 450-480`, `scripts/scr_level_document/scr_level_document.gml:764-765, 924-929` | callback struct parsers + fixtures (map-ugc 3) |

**6. `real()` applied to a Steam id (lossy above 2^53): both die with their handlers**

| Site | Action |
|---|---|
| `objects/o_onlineleaderboards/Other_69.gml:35` | `tcc_steam_get_user_avatar(real(entry_user_id), ...)` -> pass `row.steam_id` (int64) unchanged inside the rows callback |
| `objects/o_onlineleaderboardsmini/Other_69.gml:39` | same |

**7. Other code that reads Steam async results without being a handler (EDIT, no wrapper involved)**

| Site | Action |
|---|---|
| `scripts/scr_online_multiplayer/scr_online_multiplayer.gml:1017-1150` `net_handle_async_steam(_map)` | split into `net_on_lobby_created`, `net_on_lobby_entered`, `net_on_lobby_chat_update`, `net_on_lobby_join_requested` (map-lobby 5.2); `avatar_image_loaded` case deleted (polling); `ugc_subscribe_item` case deleted (shared handler in SAFE); then delete the function |
| `scripts/scr_workshopER/scr_workshopER.gml:340-417` `workshopER_catalog_callback` / `workshopER_handle_async_catalog` | take `(_ok, _items, _completed)` from `tcc_steam_ugc_send_query` (map-ugc 3) |
| `scripts/scr_level_document/scr_level_document.gml:761-778` `level_publish_callback` (+ fixtures 923-936) | take the `SteamUgcCreateItemResult` / `SteamUgcSubmitItemUpdateResult` struct (map-ugc 3) |
| `scripts/scr_online_friends/scr_online_friends.gml:67-85` `net_avatar_sprite`, `net_friends_avatar_loaded` | avatar protocol, section 4.2 |
| `scripts/scr_tradeup/scr_tradeup.gml:72-126, 165-170, 324-330` | struct matcher, `tradeup_inventory_event(_result)`, exchange argument, selfcheck fixtures (map-inventory 7) |

### 17.4 Edit work packages (files that must change, grouped by domain; parallelisable)

A file may appear in more than one package (e.g. `scr_online_multiplayer.gml`: lobby + net); coordinate those two. **No edit is needed** in the remaining callers of wrappers marked U (for example the 40 files that only call `tcc_steam_get_app_id()` and the 18 that only call `tcc_steam_initialised()`).

**core** (1 files)

* `objects/o_fullscreensystem/Create_0.gml`: add tcc_steam_register_callbacks(true)

**social** (13 files)

* `objects/o_customlevelsbrowser/Other_69.gml`: get_user_persona_name
* `objects/o_customlevelworkshopbuttonplay/Alarm_0.gml`: get_user_persona_name
* `objects/o_customlevelworkshopbuttonplay/Create_0.gml`: get_user_persona_name
* `objects/o_customlevelworkshopbuttonplay/Draw_73.gml`: get_user_persona_name
* `objects/o_onlineleaderboards/Create_0.gml`: steam_image_create_sprite, steam_user_avatar_size_small
* `objects/o_onlineleaderboards/Other_69.gml`: get_user_avatar, steam_image_create_sprite
* `objects/o_onlineleaderboardsmini/Create_0.gml`: steam_image_create_sprite, steam_user_avatar_size_small
* `objects/o_onlineleaderboardsmini/Other_69.gml`: get_user_avatar, steam_image_create_sprite
* `objects/o_profilepicture/Create_0.gml`: get_user_avatar, steam_image_create_sprite, steam_user_avatar_size_medium
* `objects/o_profilepicture/Other_69.gml`: delete handler + yy event
* `objects/o_showachievementspage/Mouse_4.gml`: activate_overlay, ov_achievements
* `objects/o_version/Draw_0.gml`: get_user_avatar, get_user_persona_name, steam_user_avatar_size_medium
* `scripts/scr_online_friends/scr_online_friends.gml`: activate_overlay, avatar protocol, overlay constants, get_user_avatar, ov_friends, steam_user_avatar_size_medium

**lobby** (4 files)

* `objects/o_fullscreensystem/Other_69.gml`: delete handler + yy event
* `objects/o_networkmanager/Create_0.gml`: net_register_steam_callbacks()
* `objects/o_networkmanager/Other_69.gml`: delete handler + yy event
* `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`: lobby callbacks, net_discard_lobby_reply, watchdog, restart net, lobby_create, lobby_join_id, steam_lobby_type_friends_only

**net** (2 files)

* `objects/o_networkmanager/CleanUp_0.gml`: restart branch (optional)
* `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`: net_packet_get_data, net_packet_get_sender_id, net_packet_get_size, net_packet_receive, net_packet_send, net_set_auto_accept_p2p_sessions, steam_net_packet_type_reliable, steam_net_packet_type_unreliable, transport rewrite, NET_PROTOCOL 3, receive buffer

**stats** (13 files)

* `objects/o_checkplayercount/Other_69.gml`: delete handler + yy event
* `objects/o_onlineleaderboardCH/Create_0.gml`: create_leaderboard, lb_disp_time_ms, lb_sort_ascending
* `objects/o_onlineleaderboardCH/Other_69.gml`: delete handler + yy event, download_scores
* `objects/o_onlineleaderboards/Other_69.gml`: delete handler + yy event
* `objects/o_onlineleaderboardsmini/Other_69.gml`: delete handler + yy event
* `objects/o_settings/Create_0.gml`: download_scores
* `objects/o_settings/Other_69.gml`: delete handler + yy event
* `objects/o_version/Other_69.gml`: delete handler + yy event
* `objects/o_version/Step_0.gml`: delete lines 8-22 player-count polling
* `scripts/reloadleaderboards/reloadleaderboards.gml`: download_friends_scores, download_scores, rows callback + token
* `scripts/reloadleaderboardsmini/reloadleaderboardsmini.gml`: download_scores_around_user, rows callback + token
* `scripts/scr_platform_services/scr_platform_services.gml`: achievement/score wrappers, steam_get_achievement, steam_set_achievement, steam_upload_score_ext
* `scripts/scr_saveworkshopmedals/scr_saveworkshopmedals.gml`: create_leaderboard, lb_disp_time_ms, lb_sort_ascending

**inventory** (6 files)

* `objects/o_getallinventoryitems/CleanUp_0.gml`: clear listener inside owns_inventory
* `objects/o_getallinventoryitems/Create_0.gml`: set result-ready listener
* `objects/o_getallinventoryitems/Other_69.gml`: delete handler + yy event
* `objects/o_title/Other_69.gml`: delete handler + yy event, inventory_exchange_items
* `objects/o_tradeup_menu/Other_69.gml`: delete handler + yy event
* `scripts/scr_tradeup/scr_tradeup.gml`: inventory_exchange_items, inventory_result_get_items, matcher, event callback, exchange arg, selfcheck, steam_inventory_exchange_items

**ugc** (18 files)

* `objects/o_customlevelsbrowser/Create_0.gml`: ugc_create_query_all, ugc_match_Items, ugc_query_RankedByVote, ugc_request_item_details, ugc_send_query
* `objects/o_customlevelsbrowser/Other_69.gml`: delete handler + yy event, steam_id_owner, ugc_query, ugc_result_success
* `objects/o_customlevelworkshopbuttonplay/Alarm_0.gml`: steam_details, ugc_request_item_details
* `objects/o_customlevelworkshopbuttonplay/Create_0.gml`: steam_details, ugc_request_item_details
* `objects/o_customlevelworkshopbuttonplay/Other_10.gml`: steam_details, ugc_request_item_details
* `objects/o_customlevelworkshopbuttonplay/Other_69.gml`: delete handler + yy event, steam_details, steam_id_owner, ugc_result_success
* `objects/o_playmostrecentlevelCL/Mouse_4.gml`: steam_details, steam_id_owner, ugc_request_item_details, ugc_result_success
* `objects/o_publishinghappenshere/Create_0.gml`: ugc_create_item, ugc_filetype_community, ugc_set_item_visibility, ugc_submit_item_update, ugc_visibility_public
* `objects/o_publishinghappenshere/Other_69.gml`: delete handler + yy event
* `objects/o_publishworkshopchallenge/Create_0.gml`: ugc_create_item, ugc_filetype_community
* `objects/o_publishworkshopchallenge/Other_69.gml`: delete handler + yy event, ugc_create_item, ugc_result_success, ugc_set_item_visibility, ugc_submit_item_update, ugc_update_item, ugc_visibility_public
* `objects/o_workshopERloading/Other_69.gml`: delete handler + yy event, ugc_result_success, ugc_subscribe_item
* `objects/o_workshoplevelselectbutton/Alarm_0.gml`: steam_details, ugc_request_item_details
* `objects/o_workshoplevelselectbutton/Create_0.gml`: steam_details
* `objects/o_workshoplevelselectbutton/Other_69.gml`: delete handler + yy event, steam_details, steam_id_owner, ugc_result_success
* `scripts/scr_level_document/scr_level_document.gml`: level_publish_callback + fixtures, ugc_create_item, ugc_result_success, ugc_update_item
* `scripts/scr_online_multiplayer/scr_online_multiplayer.gml`: ugc_result_success, ugc_subscribe_item
* `scripts/scr_workshopER/scr_workshopER.gml`: catalog callback, enums, fixtures, ugc_create_query_all, ugc_download_item, ugc_match_Items, ugc_query, ugc_query_RankedByPublicationDate, ugc_result_success, ugc_send_query

Total distinct files to edit or delete: 50.
