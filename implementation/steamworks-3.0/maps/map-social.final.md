# Migration map (FINAL): friends / overlay / avatars / images / rich presence (Steamworks 2.1.6 -> 3.0.0)

Domain: `steam_activate_overlay*`, persona names, avatars, Steam images, rich presence, friends game info, played-with.
Status: READ-ONLY analysis. Nothing under the project was edited. Code blocks marked "reference" are suggestions, not applied.
This file supersedes `map-social.md` (same structure; 17 verifier disputes were each re-checked at the source, see section 6).

Abbreviations used for evidence:
- `API.gml` = `scripts/Steamworks_API/Steamworks_API.gml`
- `yy` = `extensions/Steamworks/Steamworks.yy` (3.0)
- `native` = `extensions/Steamworks/source/src/gm_steam_friends.cpp` / `gm_steam_utils.cpp` (3.0 C++, ships inside the installed extension)
- `friends.js` / `utils.js` = `<scratchpad>/gmext/src/docs/friends.js` / `utils.js` (3.0 doc sources)
- `old-src` = old 2.1.6 C++ recovered from git (`<scratchpad>/port/oldsrc/steam_friends.cpp`, `steam_user.cpp`). The only way to know exact OLD behaviour; it contradicts the old docs in places.
- `safe` = `scripts/scr_steam_safe/scr_steam_safe.gml`

---------------------------------------------------------------------------------------------------

## 0. Cross-cutting facts (read first)

### 0.1 Steam ids are plain numbers, NOT `SteamId` structs
Every friends/utils function takes `UInt64` ids as a GML number: the wrapper does `if (!is_numeric(_steam_id)) show_error(..., true); buffer_write(buf, buffer_u64, _steam_id)` (e.g. `API.gml:13158-13175`, `13252-13270`, `13688-13706`). Returns are `buffer_read(buf, buffer_u64)` = GML int64 (`API.gml:12959-12985`). The `SteamId` struct (`API.gml:1688`) only comes from `steam_user_decode_steam_id` and is never needed here.
- Keep ids as int64. Never route them through `real()`: Steam64 ids are about 7.6e16, above 2^53 (about 9.0e15), so a double silently changes the id. The two leaderboard handlers do exactly that today: `objects/o_onlineleaderboards/Other_69.gml:35` and `objects/o_onlineleaderboardsmini/Other_69.gml:39` call `tcc_steam_get_user_avatar(real(entry_user_id), ...)`. Note the id there is read from `json_decode`'d leaderboard entries (Other_69.gml:6, 26-30) and may already be a double (unverified; some runtimes keep large JSON integers as int64): the stats/leaderboard domain must guarantee the id as int64 (entry struct `steam_id`) for the avatar request AND for the `string(steam_userid[i])` key used by `Draw_0.gml:15-16` (mini: `Draw_0.gml:30-31`) to match.
- Passing a non-number (`undefined`, a string) to a typed wrapper is a FATAL `show_error`, not a soft failure. `0` is "no id": guard it (`lvl.owner_id` / `mOwner` start at 0).
- When the extension is not available every wrapper does `if (!__available__) return;` (returns `undefined`, not `false`/`""`). The `tcc_steam_*` wrappers must keep the `platform_steam() && steam_api_is_initialized()` guard so the project never sees `undefined`.

### 0.2 Some functions have NO GML wrapper ("Skipping function ... no wrapper is required")
For these, `API.gml` only has a comment; the callable is the raw extension function declared in the yy. They have NO `extension_exists("Steamworks")` guard, so on iOS/Android/Mac App Store builds (no Steam binaries; `copyToTargets` is 0 for Apple/Mobile, `tools/check_port.py:22-23`) calling them is a runtime error. `platform_steam() &&` MUST stay the first condition in every `tcc_steam_*` wrapper.

| raw function | yy line | args | returns |
|---|---|---|---|
| `steam_friends_activate_game_overlay(dialog)` | 28 | String | Real (C++ is void; value meaningless) |
| `steam_friends_set_rich_presence(key, value)` | 91 | String, String | Real (1/0, bool) |
| `steam_friends_clear_rich_presence()` | 33 | - | Real |
| `steam_friends_get_persona_name()` | 75 | - | String |
| `steam_friends_clear_callback_avatar_image_loaded()` | 38 | - | Real (yy `@returns {Real}`, returnType 2; value not meaningful) |
| `steam_friends_clear_callback_persona_state_change()` | 93 | - | Real (same; value not meaningful) |
| `steam_api_is_initialized()` | 22 | - | Real (1/0) |
| `steam_utils_get_app_id()` | 211 | - | Real |
| `steam_utils_is_overlay_enabled()` | 224 | - | Real |

Every `tcc_steam_*` guard in `safe` currently ends in `steam_initialised()`, which does not exist in 3.0. Replace with `steam_api_is_initialized()` (cross-domain, see open questions). `platform_steam() && steam_api_is_initialized()` short-circuits, so the raw call is never reached off-Steam.

### 0.3 Required, type-checked arguments (a miss is a fatal `show_error`, even where docs claim a default)
- `steam_friends_activate_game_overlay_to_web_page(_url, _mode)` (`API.gml:12550`): `_mode` has NO default in the wrapper although `friends.js:63-70` says "Defaults to ...Default". Omitting it crashes. Pass `SteamFriendsOverlayToWebpageMode.Default`.
- `steam_friends_activate_game_overlay_to_store(_app_id, _flag)` (`API.gml:12500`): pass `SteamFriendsOverlayToStoreFlag.None`.
- `steam_friends_get_friend_count(_friend_flags)` / `steam_friends_get_friend_by_index(_i, _flags)`: flags required.
- `steam_friends_request_user_information(_id, _require_name_only)` (`API.gml:13688`): second arg is checked with `is_bool`. Pass the literals `true` / `false`, never `1` / `0`.
- `_url` / `_key` / `_dialog` must be strings (`is_string`).

### 0.4 Callback delivery rules (apply to avatar + persona-state callbacks)
- Each `steam_friends_set_callback_*` has exactly ONE global slot: `native` `g_cb_avatar_image_loaded = callback` (gm_steam_friends.cpp:40-80). A second registration REPLACES the first. The project has three would-be avatar consumers (`o_onlineleaderboards`, `o_onlineleaderboardsmini`, `net_friends_avatar_loaded` in `scr_online_friends.gml:79`); if each registers its own, only the last one ever fires. Same for `steam_friends_set_callback_persona_state_change`.
  -> Register ONCE from one persistent place (the same controller that calls `steam_api_run_callbacks()`), and fan out from there. Do not register from room objects.
- Nothing is delivered unless `steam_api_run_callbacks()` runs every frame (getting_started.md). Cross-domain dependency; if it is missing, avatars/names silently never arrive.
- Dispatch is `with (_dummy_context) method_call(_ref[0], _args)` (`scripts/ExtensionCore_api/ExtensionCore_api.gml:350`). An unbound script function therefore runs with `self` = a dummy struct: instance variables are NOT visible (use `global.` state). A callback that is a method bound to an instance (an anonymous `function(){}` written in a Create event) keeps pointing at that instance after `instance_destroy()`; calling it then is a runtime fault. The handle is the function pointer (`int64(ptr(_callable))`, line 274) and registering the same function again only bumps a refcount. Use named script-level functions registered once.
- **Sprite ownership rule (new, from dispute D9):** the shared avatar callback must NOT create or store sprites. It may only record plain integer image handles (`global.tcc_avatar_handles[$ string(id)] = handle`). Every consumer builds and later deletes its OWN sprite. Reason: three owners already delete sprites on their own schedule (`reloadleaderboards.gml:39-46`, `reloadleaderboardsmini.gml:10-17`, `net_avatars_free` `scr_online_friends.gml:87-98`); a sprite id stored in two maps would dangle after the first reload/free and could be double-deleted or hit a reused id.
- `PersonaStateChange_t` fires for every friend status/game change, i.e. very frequently. If a persona callback is used at all, it must be tiny (flag test + cache invalidation only). The recommended design below does not use it.
- `game_restart` keeps globals but the extension's registered handles/statics may not survive; see open questions.

### 0.5 Id/handle conventions in the new image API
- Avatar and image handles are `Int32` (`API.gml:13457-13475`, `15587-15608`).
- `steam_utils_get_image_size` returns a STRUCT `{width, height}` (`API.gml:2418`) or `undefined`; old `steam_image_get_size` returned an ARRAY `[w, h]` (or the real `0` on failure, old-src `steam_user.cpp` `steam_image_get_size`).
- `steam_utils_get_image_rgba(_image_handle, _dest)` has NO size argument; the byte count is `buffer_get_size(_dest)` (`API.gml:15587-15608`, `native gm_steam_utils.cpp:219-238`). The buffer must be exactly `width * height * 4`.
- Do not hard-code avatar pixel sizes anywhere: 3.0 docs say small 32 / medium 64 / large 128 (`friends.js:600-650`) but Valve's own text may say 184 for large (unverifiable offline). Always size from `steam_utils_get_image_size` (D8).

### 0.6 Undefined-identifier failure mode (D6)
`ov_friends`, `ov_achievements`, `steam_user_avatar_size_small`, `steam_user_avatar_size_medium` do not exist in 3.0 (`grep -c GMExtensionConstant yy` = 0; no match in `API.gml`). This map's earlier wording "compile error" was unsupported. GameMaker resolves an unknown bare identifier as an instance variable at run time, so the failure is a runtime "variable not set before reading it" error on the first execution of the line (on click for `ov_*`; at instance creation for the avatar-size constants: `o_onlineleaderboards/Create_0.gml:7`, `o_onlineleaderboardsmini/Create_0.gml:9`, `o_profilepicture/Create_0.gml:36`; on first friends-panel avatar draw for `scr_online_friends.gml:71`). Do not rely on the compiler; use a grep gate (section 5, item 5).

---------------------------------------------------------------------------------------------------

## 1. Quick table (old -> new)

| old (2.x) | new (3.0) | delivery |
|---|---|---|
| `steam_activate_overlay(ov_x)` | `steam_friends_activate_game_overlay("friends"\|"achievements"\|...)` (raw) | sync |
| `steam_activate_overlay_browser(url)` | `steam_friends_activate_game_overlay_to_web_page(url, SteamFriendsOverlayToWebpageMode.Default)` | sync |
| `steam_activate_overlay_store(app_id)` | `steam_friends_activate_game_overlay_to_store(app_id, SteamFriendsOverlayToStoreFlag.None)` | sync |
| `steam_activate_overlay_user(dialog, id)` | `steam_friends_activate_game_overlay_to_user(dialog, steam_id)` | sync |
| `ov_friends`, `ov_achievements` (consts) | string literals `"friends"`, `"achievements"` | const removed |
| `steam_get_persona_name()` | `steam_friends_get_persona_name()` (raw) | sync |
| `steam_get_user_persona_name(id)` (async, request id) | `steam_friends_get_friend_persona_name(id)` + `steam_friends_request_user_information(id, true)` (throttled, no callback needed; JSON `result_delivery` = "sync") | sync (polled) |
| `steam_get_user_persona_name_sync(id)` | `steam_friends_get_friend_persona_name(steam_id_friend)` | sync |
| `steam_get_user_avatar(id, size)` | `steam_friends_get_small_/medium_/large_friend_avatar(steam_id_friend)` | sync (+ callback, large only documented) |
| `steam_user_avatar_size_small/medium(/large)` | removed; pick the function (macro suggested) | const removed |
| async `avatar_image_loaded` | `steam_friends_set_callback_avatar_image_loaded(callback)` (ONE registration, handles only) | callback |
| `steam_image_get_size(h)` | `steam_utils_get_image_size(image_handle)` -> struct | sync |
| `steam_image_get_rgba(h, buf, size)` | `steam_utils_get_image_rgba(image_handle, dest)` | sync |
| project-local `steam_image_create_sprite(h)` | one shared helper over the two calls above | sync |
| `steam_set_rich_presence(k, v)` | `steam_friends_set_rich_presence(key, value)` (raw) | sync |
| `steam_get_friend_rich_presence(id, key)` | `steam_friends_get_friend_rich_presence(steam_id_friend, key)` | sync |
| `steam_get_friends_game_info()` | loop over `steam_friends_get_friend_count/_by_index/_get_friend_game_played/_get_friend_persona_name` | sync (composed) |
| `steam_user_set_played_with(id)` | `steam_friends_set_played_with(steam_id_user_played_with)` | sync |

---------------------------------------------------------------------------------------------------

## 2. Entries

### 2.1 `steam_activate_overlay(overlay_type)`
- Wrapper: `safe:2-5` `tcc_steam_activate_overlay(_a0)`.
- Callers: `scripts/scr_online_friends/scr_online_friends.gml:196` (`tcc_steam_activate_overlay(ov_friends)`), `objects/o_showachievementspage/Mouse_4.gml:1` (`tcc_steam_activate_overlay(ov_achievements)`).
- OLD: takes a Real index 0..5; old-src maps it to the TitleCase names `"Friends","Community","Players","Settings","OfficialGameGroup","Achievements"` (old-src steam_friends.cpp:10-35, activate at :131-153) and calls `ActivateGameOverlay`. Old yy constants: `ov_friends=0, ov_community=1, ov_players=2, ov_settings=3, ov_gamegroup=4, ov_achievements=5`.
- NEW: `steam_friends_activate_game_overlay(dialog)` raw, String. Valid dialogs (friends.js:5-14, lowercase): `"friends"`, `"community"`, `"players"`, `"settings"`, `"officialgamegroup"`, `"stats"`, `"achievements"`. The 3.0 native passes the string through unchanged (`gm_steam_friends.cpp:95-96`, `ActivateGameOverlay(dlg.c_str())`).
- Mapping: `ov_friends` -> `"friends"`, `ov_community` -> `"community"`, `ov_players` -> `"players"`, `ov_settings` -> `"settings"`, `ov_gamegroup` -> `"officialgamegroup"`, `ov_achievements` -> `"achievements"`.
- Signature change: wrapper parameter becomes a dialog string; change both call sites to `tcc_steam_activate_overlay("friends")` / `tcc_steam_activate_overlay("achievements")`.
- **Confidence MEDIUM on the string spelling (D5).** Lowercase is what Valve/3.0 docs list, but the only spelling proven at runtime in the shipped game is the old TitleCase table. If the smoke test on a real Steam client shows the lowercase dialog does not open, switch the two literals to `"Friends"` / `"Achievements"` (the pass-through native makes this a one-line change). Smoke test: Friends panel "Steam Friends" button and the achievements button (`o_showachievementspage`).
- Gotchas: raw function (no extension_exists guard), keep `platform_steam()`. Return value unused by both callers. The overlay is silently inert if disabled (`steam_utils_is_overlay_enabled()`), same as before.

### 2.2 `steam_activate_overlay_browser(url)`
- Wrapper: `safe:42-45`. Callers: `scripts/scr_timing_gameplay/scr_timing_gameplay.gml:331`, `objects/o_openskinmarket/Mouse_4.gml:1`, `objects/o_getskinmasteries/Mouse_4.gml:8`, `objects/o_visitlevelbutton/Mouse_4.gml:1`, `objects/o_customviewworkshop/Mouse_4.gml:2`. All pass fully-qualified `https://` URLs.
- NEW: `steam_friends_activate_game_overlay_to_web_page(_url, _mode)` (`API.gml:12550`) with `_mode = SteamFriendsOverlayToWebpageMode.Default` (enum `API.gml:456`: Default=0, Modal=1). Old behaviour was the default mode (old-src steam_friends.cpp:211-225).
- Gotcha: `_mode` is mandatory (0.3). The wrapper must add it; callers keep `tcc_steam_activate_overlay_browser(url)`.

### 2.3 `steam_activate_overlay_store(app_id)`
- Wrapper `safe:46-49`. Caller: `objects/o_demoask/KeyPress_89.gml:2` (`1651680`).
- NEW: `steam_friends_activate_game_overlay_to_store(_app_id, _flag)` (`API.gml:12500`) with `_flag = SteamFriendsOverlayToStoreFlag.None` (enum `API.gml:449`: None=0, AddToCart=1, AddToCartAndShow=2). Old passed `k_EOverlayToStoreFlag_None` (old-src steam_friends.cpp:247-262): identical.
- `STEAM_API_APP_ID_INVALID` (0) opens the store front page (friends.js:27-38).

### 2.4 `steam_activate_overlay_user(dialog, steamid)`
- Wrapper `safe:6-9`. Caller: `scr_online_friends.gml:197` (`"steamid"`, `_button.arg` = friend id built at `:172`).
- NEW: `steam_friends_activate_game_overlay_to_user(_dialog, _steam_id)` (`API.gml:12525`). Same dialog names as before (`"steamid"`, `"chat"`; old-src passed the string through unchanged, :228-244), plus `"stats"`, `"achievements"`, `"friendadd"`, ... (friends.js:40-61). id is a plain UInt64 number.
- Gotcha: `_steam_id` must be numeric (fatal otherwise). `_button.arg` is always `_friend.id` in the current code, which is int64.

### 2.5 `steam_get_persona_name()`
- Wrapper `safe:74-77` (returns `""` when unavailable). Callers: `scr_online_session.gml:392`, `scr_online_multiplayer.gml:198, 486`, `objects/o_version/Draw_0.gml:22` (every Draw frame), `objects/o_settings/Create_0.gml:28`.
- NEW: `steam_friends_get_persona_name()` raw, returns String (`native gm_steam_friends.cpp:626-635` returns `""` when Steam guard fails). Declared yy:75.
- Gotchas: raw (no extension guard). `o_version/Draw_0.gml:22` calls it every frame; cheap, but consider caching in `o_version` Create/room start.

### 2.6 `steam_get_user_persona_name(steamID)` (ASYNC, returned a request id)
- Wrapper `safe:82-85`. REQUEST sites: `objects/o_customlevelworkshopbuttonplay/Create_0.gml:22` (with `mOwner = 0` at that time!) and `Alarm_0.gml:3` (re-requested every 30 ticks, `Alarm_0.gml:36`); `objects/o_customlevelsbrowser/Other_69.gml:78` and `:130`. Commented-out copies (ignore): `o_customlevelworkshopbuttonplay/Create_0.gml:34`, `Alarm_0.gml:42`, `Draw_73.gml:1`, `o_version/Draw_0.gml:22`.
- CONSUMER sites (D1, were missing from the first call_sites list): `objects/o_customlevelworkshopbuttonplay/Other_69.gml:21-24` (`async_load[?"id"] == requestname` then `ownername = async_load[?"persona_name"]`) and `objects/o_customlevelsbrowser/Other_69.gml:138-159` (`async_names` -> `levels[_idx].owner_name` / `browse_levels[_idx].owner_name`). Related state: `o_customlevelworkshopbuttonplay/Create_0.gml:10` (`ownername = "Unknown"`), `Draw_73.gml:20` (draws `string(ownername)` unconditionally), `o_customlevelsbrowser/Create_0.gml:39` (creates `async_names`), `CleanUp_0.gml:18` (destroys it), `Create_0.gml:83` and `Other_69.gml:28` (`owner_name = "Unknown"`), `Draw_75.gml:229` (draws `string(_lvl.owner_name)` per tile).
- OLD semantics (old-src steam_friends.cpp:284-313, NOT the docs): returns an async request id N. It calls `RequestUserInformation(id, true)`. If that returns false (data already cached) it immediately queues ONE Steam async event: `async_load[? "id"]=N`, `"event_type"="user_persona_name"`, `"steamid"`, `"persona_name"`. If it returns true (data must be downloaded) the listener `CPersonaStateChangeListener` is COMMENTED OUT (old-src :311), so NO event fires for THAT call.
- Corrected "net effect today" (D11): a call made while the name is not cached starts the download but yields no event; a LATER call (after the download finished) returns false and fires the event. So `o_customlevelworkshopbuttonplay` DID recover, through its 30-tick polling (`Alarm_0.gml:3,36`; `requestname` is overwritten with the latest id each time, so the id matches). Only `o_customlevelsbrowser` (one request per item, `Other_69.gml:78,130`) stayed at "Unknown" until a later reload. Polling the workshop button is therefore behaviour parity, not an improvement; the browser site is the real improvement.
- NEW (no request id; correlate by steam id), recommended design = poll with a throttle, no callback:
  1. `steam_friends_get_friend_persona_name(id)`; if it is neither `""` nor `"[unknown]"` the name is known.
  2. Otherwise call `steam_friends_request_user_information(id, true)` (literal `true`) at most once per id per few seconds (per-id memo, see helper below), return `""`, and look again at the next refresh.
  3. The caller only overwrites its placeholder when the helper returns a non-empty string (D12): `ownername`/`owner_name` start as `"Unknown"` and are drawn unconditionally, so assigning `""` would show "Made by " with nothing after it.
  4. Do the lookup from a throttled Step/Alarm (workshop button: its existing `Alarm_0` 30-tick loop; levels browser: a counter in `Step_0.gml` every ~30 steps over the active tab's levels whose `owner_name == "Unknown"` and `owner_id != 0`), NOT from Draw: the helper can call a native request on each miss, and Draw would do that per tile per frame (D7).
- Optional callback route (not recommended): `steam_friends_set_callback_persona_state_change(callback)` (`API.gml:13757`). Arg `SteamFriendsPersonaStateChange{steam_id, change_flags}` (`API.gml:1886`, decoder `:4894`). Test `(r.change_flags & (SteamFriendsPersonaChange.Name | SteamFriendsPersonaChange.NameFirstSet)) != 0` (D13; enum `API.gml:518-534`: Name=1, Status=2, ComeOnline=4, GoneOffline=8, GamePlayed=16, GameServer=32, Avatar=64, JoinedSource=128, LeftSource=256, RelationshipChanged=512, NameFirstSet=1024, Broadcast=2048, Nickname=4096, SteamLevel=8192, RichPresence=16384) or simply invalidate on any change for that steam id. Key pending work by owner steam id, never by array index (browse results reset `browse_levels` on page 1, so the old `"browse:N"`/`"sub:N"` indices go stale). One global slot (0.4).
- Gotchas: treat BOTH `""` and `"[unknown]"` as "not known yet" (friends.js:451-466). Guard `id == 0` and non-numeric ids. `is_bool` rule for the second arg. The wrapper returns `undefined` if the extension is unavailable (0.1), but the guard prevents it.
- Handlers affected: `o_customlevelworkshopbuttonplay/Other_69.gml:21-24`, `o_customlevelsbrowser/Other_69.gml:76-79, 128-131, 138-159`. After the port these blocks are deleted; `requestname`, `async_names`, `_name_req` go away (`o_customlevelsbrowser/Create_0.gml:39`, `CleanUp_0.gml:18`).

### 2.7 `steam_get_user_persona_name_sync(steamID)`
- Wrapper `safe:18-21`. Callers: `scr_online_friends.gml:267`, `scr_online_multiplayer.gml:715, 740`.
- NEW: `steam_friends_get_friend_persona_name(_steam_id_friend)` (`API.gml:13158`), returns String. Same underlying `GetFriendPersonaName` (old-src steam_user.cpp:186-191), so identical behaviour: `""` (guard failed) or `"[unknown]"` (id not known to this client).
- Name cleaning (D16): `scr_online_friends.gml:267` wraps it in `net_clean_name`; at `scr_online_multiplayer.gml:715/740` the raw value is passed to `net_register_player`, which cleans and truncates it itself (`username: net_clean_name(_username)`, `scr_online_multiplayer.gml:790`). No code change needed; only `""`/`"[unknown]"` can still become a display name (unchanged behaviour).
- Gotcha: lobby members' names can lag behind joining; they arrive via PersonaStateChange (friends.js:459).

### 2.8 `steam_get_user_avatar(userID, avatar_size)`
- Wrapper `safe:78-81` (fallback `-1`). Callers: `scr_online_friends.gml:71` (medium, `net_avatar_sprite`), `objects/o_onlineleaderboards/Other_69.gml:35` (small), `objects/o_onlineleaderboardsmini/Other_69.gml:39` (small), `objects/o_profilepicture/Create_0.gml:36` (medium, local user via `tcc_steam_get_user_steam_id()`). Comment only: `objects/o_version/Draw_0.gml:36`.
- OLD (old-src steam_user.cpp:252-273): `switch(size) large->GetLargeFriendAvatar, medium->GetMediumFriendAvatar, default->GetSmallFriendAvatar`; returns the raw Steam handle. Docs: `>0` ready, `0` none, `-1` pending + `avatar_image_loaded` event.
- NEW: three separate functions, each `(steam_id_friend)` returning the raw Int32 handle: `steam_friends_get_small_friend_avatar` (API.gml:13457), `steam_friends_get_medium_friend_avatar` (:13371), `steam_friends_get_large_friend_avatar` (:13351). `native` returns the SDK value unchanged and `-1` when the Steam guard fails (gm_steam_friends.cpp: large :570, medium :581, small :660).
- Meaning of the return, MEDIUM confidence (Valve docs not available offline; based on friends.js:600-650 and `AvatarImageLoaded_t`, friends.js:1126-1134): `>0` ready; `-1` = still loading (this protocol, with the callback, is documented for the LARGE avatar only); `0` = nothing cached / no avatar. For small/medium treat `0` AND `-1` as "not ready yet" and re-ask later. For users unknown to the client call `steam_friends_request_user_information(id, false)` (false = also fetch avatar) first; friends, lobby members and leaderboard-requested users are known automatically (friends.js:605).
- Consequences for existing code:
  - `net_avatar_sprite` (`scr_online_friends.gml:67-77`) treats `-1` as pending (`-2`) and `0` as "none", then CACHES the result permanently in `global.net_avatars` until `net_avatars_free`. This is PRE-EXISTING (D15): the 2.x code returned the same raw SDK handle (old-src steam_user.cpp:252-273) and cached `0` the same way, and the 3.0 small/medium functions are the same SDK calls. It is not a 3.0 regression. Hardening is still worthwhile: do not cache non-positive handles permanently (re-ask with an expiry/retry cap).
  - `o_onlineleaderboards` / `...mini` `Other_69` treat `0` as pending (`-2`) and `-1` as none: the reverse convention. Normalise all consumers to one contract.
  - `tcc_steam_get_user_avatar` returns `-1` when Steam is unavailable, which collides with "pending". Decide once. Recommendation (own addition, not required by any dispute): unavailable -> `0`, only Steam itself reports `-1`, consumers retry both `0` and `-1` a bounded number of times and then settle on "none". Apply this ONLY in the same edit that normalises all three consumers: the leaderboard handlers map `0` -> `-2` (pending) and `-1` -> none, `net_avatar_sprite` maps `0` -> none (`-1`) and `-1` -> pending (`-2`), and `o_profilepicture` only skips on `-1` (it survives `0` through the `_image > 0` guard in `tcc_steam_image_get_size`). Changing the fallback alone would flip behaviour in the leaderboards.
  - `real(entry_user_id)` at the two leaderboard sites must go (0.1).
- Size constants: `steam_user_avatar_size_small` (0), `_medium` (1), `_large` (2) do not exist in 3.0. LIVE uses (D3): small x2 (`o_onlineleaderboards/Create_0.gml:7`, `o_onlineleaderboardsmini/Create_0.gml:9`), medium x2 (`o_profilepicture/Create_0.gml:36`, `scr_online_friends.gml:71`) = 4 live uses; plus one comment (`o_version/Draw_0.gml:36`); large is unused. Suggested: keep `tcc_steam_get_user_avatar(_steam_id, _size)` and add project macros `TCC_STEAM_AVATAR_SMALL 0`, `TCC_STEAM_AVATAR_MEDIUM 1`, `TCC_STEAM_AVATAR_LARGE 2` in `safe` (no pixel sizes in comments, D8), then switch inside the wrapper. The switch must mirror the old mapping: explicit LARGE and MEDIUM cases, DEFAULT = SMALL (D2/D14).

### 2.9 Async event `avatar_image_loaded`
- OLD event (old-src steam_user.cpp:234-242): `async_load[?"event_type"]="avatar_image_loaded"`, `"success"` (always true), `"user_id"` (Int64), `"image"` (handle), `"width"`, `"height"`. Delivered to every Async-Steam handler.
- NEW: `steam_friends_set_callback_avatar_image_loaded(_callback)` (`API.gml:12659`); clear with raw `steam_friends_clear_callback_avatar_image_loaded()` (yy:38, returns Real, ignore). Callback receives a `SteamFriendsAvatarImageLoaded` struct (`API.gml:1799`, decoder `:4586`): `steam_id_64` (UInt64), `image_handle` (Int32), `width`, `height`. There is NO `event_type` and NO `success` field; validate with `image_handle > 0`. Documented for the LARGE avatar only (friends.js:134-149, 1126-1134).
- Single global slot (0.4). Revised recommended shape (D9): ONE registration in the persistent controller that records ONLY the integer handle into `global.tcc_avatar_handles[$ string(r.steam_id_64)]` (a struct, so nothing leaks across `game_restart`). It never creates or stores sprites. Each consumer (`net_avatar_sprite`/`net_friends_avatar_loaded`, the `avatar_sprites` map of each leaderboard object) builds its OWN sprite from that handle with `tcc_steam_image_to_sprite` and deletes it on its own schedule. Because small/medium may never trigger the callback, ALSO re-ask `tcc_steam_get_user_avatar` periodically (bounded retries) or the placeholder ("?" in the leaderboards, blank square in the friends panel) can stay forever. If the polling alone is judged enough, the callback can be skipped entirely.
- Handlers affected: `objects/o_onlineleaderboards/Other_69.gml:51-69`, `objects/o_onlineleaderboardsmini/Other_69.gml:55-73`, `scripts/scr_online_multiplayer/scr_online_multiplayer.gml:1135-1137` (`case "avatar_image_loaded": net_friends_avatar_loaded(_map)`, reached through `objects/o_networkmanager/Other_69.gml:3` -> `net_handle_async_steam`, `scr_online_multiplayer.gml:1017`) and the helper `scr_online_friends.gml:79-85` (reads `_map[? "user_id"]`, `_map[? "image"]`). `objects/o_profilepicture/Other_69.gml` only draws the sprite inside the async event: dead code, delete.
- Sprite lifecycle scripts that must be considered when touching `avatar_sprites` (D9, were missing): `scripts/reloadleaderboards/reloadleaderboards.gml:39-46` and `scripts/reloadleaderboardsmini/reloadleaderboardsmini.gml:10-17` (delete every sprite in `avatar_sprites` then `ds_map_clear`), called from `o_onlineleaderboards/Step_0.gml:4,9,15,19`, `Create_0.gml:37`, `o_reloadleaderboardsbutton/Mouse_4.gml:4,8`, `o_friendleaderboardsettings/Mouse_4.gml:5`, `o_onlineleaderboardsmini/Create_0.gml:89`, `Alarm_0.gml:14,23,32`; and `net_avatars_free()` (`scr_online_friends.gml:87-98`, called at `scr_online_multiplayer.gml:335`).

### 2.10 `steam_image_get_size(steam_image_id)`
- Wrapper `safe:94-97` (returns `undefined` when unavailable). Callers: `scr_online_friends.gml:52`; the three local copies of `steam_image_create_sprite`: `o_onlineleaderboards/Create_0.gml:13`, `o_onlineleaderboardsmini/Create_0.gml:15`, `o_profilepicture/Create_0.gml:11`.
- OLD: array `[w, h]`, or the real `0` on failure (old-src steam_user.cpp:275-298).
- NEW: `steam_utils_get_image_size(_image_handle)` (`API.gml:15611`) returns a `SteamUtilsImageSize` struct `{width, height}` or `undefined` (`API.gml:2418`, `native gm_steam_utils.cpp:240-259`).
- Breakage if copied verbatim: `net_avatar_from_image` does `is_array(_size)` -> always false -> every avatar returns `-1` (silent). The three `steam_image_create_sprite` copies do `l_dims[0]`/`l_dims[1]` on a struct -> runtime error. The old `l_dims == undefined` guard never fired (old returned `0`, not `undefined`; `0[0]` would have failed for a missing image, e.g. `o_profilepicture` with handle `0`); the new `undefined` makes it correct.
- Recommended: make `tcc_steam_image_get_size` return the legacy array `[w, h]` (or `undefined`), so no caller changes. Reference below.

### 2.11 `steam_image_get_rgba(steam_image_id, buffer, size)`
- Wrapper `safe:90-93`. Callers: `scr_online_friends.gml:57`, `o_onlineleaderboards/Create_0.gml:21`, `o_onlineleaderboardsmini/Create_0.gml:23`, `o_profilepicture/Create_0.gml:19`.
- NEW: `steam_utils_get_image_rgba(_image_handle, _dest)` (`API.gml:15587`), returns Bool. The `size` argument is gone; the extension uses `buffer_get_size(_dest)` and fails if `<= 0` (native gm_steam_utils.cpp:226-229). Allocate the buffer as exactly `w * h * 4` (all current callers already do, with `buffer_fixed`). Pixel order is RGBA as before; `buffer_set_surface` usage unchanged.
- Wrapper: keep `tcc_steam_image_get_rgba(_image, _buffer, _size)` accepting 3 args and ignore `_size`, or drop it and edit the 4 callers.
- Gotcha: `buffer_exists(_dest)` is enforced (fatal otherwise). Expensive and uncached: call once per handle.

### 2.12 Project-local `steam_image_create_sprite(l_img)`  (NOT an extension function)
- Three duplicate definitions: instance-variable function at `o_onlineleaderboards/Create_0.gml:11`, `o_onlineleaderboardsmini/Create_0.gml:13`, and `function steam_image_create_sprite` at `o_profilepicture/Create_0.gml:9`. Calls: `o_onlineleaderboards/Other_69.gml:37, 63`; `o_onlineleaderboardsmini/Other_69.gml:41, 67`; `o_profilepicture/Create_0.gml:38`. `scr_online_friends.gml:51-65` (`net_avatar_from_image`) is a fourth variant with a 512px cap.
- No 3.0 symbol named `steam_image_create_sprite` exists (API.gml has none), so no name collision.
- Port: replace the 4 copies with ONE shared helper in `safe` (reference below) built from `steam_utils_get_image_size` + `steam_utils_get_image_rgba`. All 3 definitions must change because they index the size as an array (unless the legacy-array adapter is used, in which case they work unchanged).
- Lifecycle (D10, reworded): the leaderboard objects DO free their avatar sprites on every reload (`reloadleaderboards.gml:39-46`, `reloadleaderboardsmini.gml:10-17`: `sprite_delete` each, then `ds_map_clear`). What leaks is only the `avatar_sprites` ds_map itself and whichever sprites it holds when the instance is destroyed, because neither object has a CleanUp event (`ls objects/o_onlineleaderboards*`: Alarm_0, Create_0, Draw_0, Other_69, Step_0 only). Optional fix: add CleanUp events that reuse the reload deletion loop and `ds_map_destroy(avatar_sprites)`. `o_profilepicture` never deletes `avatar_sprite` either (pre-existing).

### 2.13 `steam_set_rich_presence(key, value)`
- Wrapper `safe:226-229`. Callers: `scripts/scr_rich_presence/scr_rich_presence.gml` (74 `tcc_steam_set_rich_presence` lines; keys `steam_display`, `level`, `boss`, `levelname`, `challengename`), `scripts/scr_online_multiplayer/scr_online_multiplayer.gml:1167-1171` (`steam_player_group`, `steam_player_group_size`).
- `set_rich_presence()` (D17, completeness) is invoked from `scripts/loadhud/loadhud.gml:22`, `objects/o_title/Create_0.gml:8` and 18 room InstanceCreationCode files (`rooms/r_soundtestmenu`, `r_workshopchallengemenu`, `r_customlevelmenu`, `r_levelselectmenu`, `r_support`, `r_gameoverscreen`, `r_challenges`, `r_credits`, `r_calendar`, `r_settings`, `r_onlineleaderboard`, `r_endlessrunmenu`, `r_achievements`, `r_skinmenu`, `r_funmodemenu`, `r_stats`, `r_gamemode`, `r_hatmerchantroom`). They all call the project function only and reach Steam through `tcc_steam_set_rich_presence`, so NO per-site edit is needed: the guard/coercion changes live in the wrapper (and `scr_rich_presence.gml:8` uses `tcc_steam_initialised()`, cross-domain).
- NEW: `steam_friends_set_rich_presence(key, value)` raw, both String, returns Real 1/0 (`native gm_steam_friends.cpp:773-787`; yy:91). Same SDK call as before (old-src steam_user.cpp:197-213).
- Limits (now documented, `API.gml:65-69`): key <= `STEAM_FRIENDS_MAX_RICH_PRESENCE_KEY_LENGTH` (64), value <= `STEAM_FRIENDS_MAX_RICH_PRESENCE_VALUE_LENGTH` (256), at most `STEAM_FRIENDS_MAX_RICH_PRESENCE_KEYS` (20) keys; `""` value removes the key (`net_presence_update` relies on this). On failure it returns 0 and sets `steam_api_last_error()`. The project uses 7 distinct keys. Long Workshop titles in multi-byte UTF-8 could exceed 256 bytes and be rejected (unchanged SDK limit).
- Gotchas: raw function with declared string args: coerce defensively in the wrapper (`string(_key)`, `string(_value)`). Localisation tokens (`#MainMenu`, `steam_display`) and the VDF file are extension-independent: unchanged.

### 2.14 `steam_get_friend_rich_presence(steamID, key)`
- Wrapper `safe:10-13` (returns `""`). Callers: `scr_online_friends.gml:35, 43`.
- NEW: `steam_friends_get_friend_rich_presence(_steam_id_friend, _key)` (`API.gml:13252`), returns String (`""` when absent or Steam unavailable). Both args type-checked (fatal if wrong).
- Not needed here: `steam_friends_request_friend_rich_presence` (only for non-friends such as lobby peers). The old `friend_rich_presence_update` event was never handled by the project (no matches in scripts/objects/rooms), so nothing to port.

### 2.15 `steam_get_friends_game_info()`
- Wrapper `safe:14-17` (returns `[]`). Caller: `scr_online_friends.gml:12` inside `net_friends_list()`, which runs every 120 frames (`objects/o_friendsbutton/Step_0.gml`) and every 90 frames (`objects/o_friendspanel/Step_0.gml`, plus `Create_0.gml:26`).
- OLD (old-src steam_user.cpp:107-148): flags default `k_EFriendFlagImmediate`; for EVERY friend appended `{friendId: Int64, gameId: double (m_gameID.AppID()), lobbyId: Int64 (0 if none), name: String}`; non-playing friends had `gameId = 0, lobbyId = 0`.
- NEW: no aggregate exists; compose the sync calls (friends.js:346-395, 426-436, 451-466):
  - `steam_friends_get_friend_count(SteamFriendsFriendFlag.Immediate)` (`API.gml:13028`; enum `API.gml:478`: Immediate = 4)
  - `steam_friends_get_friend_by_index(_i, SteamFriendsFriendFlag.Immediate)` (`API.gml:12959`)
  - `steam_friends_get_friend_game_played(_steam_id_friend)` (`API.gml:13098`) -> `SteamFriendsFriendGamePlayed{game_id, game_ip_v4, game_port, query_port, lobby_steam_id_64}` (`API.gml:1851`) or `undefined` when the friend is not in a game
  - `steam_friends_get_friend_persona_name(_steam_id_friend)`
- Field differences: `friendId` -> id from `get_friend_by_index`; `gameId` -> `game_id` is now the full 64-bit CGameID (`ToUint64()`, native gm_steam_friends.cpp:395-415), the old value was only `AppID()`; mask with `& 0xFFFFFF` (AppID = low 24 bits) for exact parity before comparing with the app id. `lobbyId` -> `lobby_steam_id_64` (0 = none). `name` -> separate persona-name call.
- Recommended: rebuild the legacy shape inside `tcc_steam_get_friends_game_info()` so `net_friends_list` (reads `friendId`, `gameId`, `lobbyId`, `name` through `net_field`) stays untouched; only list friends that are in a game (the project already skips `gameId == 0`).
- Cost: 2-3 native crossings per friend every 90-120 frames; fine. The comparison uses `tcc_steam_get_app_id()` (`safe:66`); its 3.0 replacement is raw `steam_utils_get_app_id()` (yy:211): cross-domain.

### 2.16 `steam_user_set_played_with(steamID)`
- Wrapper `safe:38-41`. Caller: `scr_online_multiplayer.gml:805` (`net_register_player`), return value unused.
- NEW: `steam_friends_set_played_with(_steam_id_user_played_with)` (`API.gml:13735`). Returns nothing useful (C++ is void; old returned 1.0/0). Wrapper should call it and `return true`.
- Gotcha: the SDK only records the association if both players are in the same game session/lobby (friends.js:872-883): unchanged.

### 2.17 Overlay-related neighbours (not in scope, listed so they are not missed)
- `tcc_steam_lobby_activate_invite_overlay()` (`safe:26`, caller `scr_online_friends.gml:195`) lives in the matchmaking domain, but its 3.0 equivalent is here: `steam_friends_activate_game_overlay_invite_dialog(_steam_id_lobby)` (`API.gml:12480`), which now REQUIRES the lobby id.
- `tcc_steam_is_overlay_enabled()` (`safe:22`) -> raw `steam_utils_is_overlay_enabled()` (yy:224).

---------------------------------------------------------------------------------------------------

## 3. Reference code (suggested, not applied)

```gml
// ---- scr_steam_safe.gml (reference) -----------------------------------------------------------
#macro TCC_STEAM_AVATAR_SMALL  0
#macro TCC_STEAM_AVATAR_MEDIUM 1
#macro TCC_STEAM_AVATAR_LARGE  2   // the only size the avatar_image_loaded callback is documented for
// No pixel sizes on purpose: always size buffers from steam_utils_get_image_size.

function tcc_steam_activate_overlay(_dialog) {        // "friends" | "achievements" | ... (Valve-documented lowercase; see 2.1 smoke test)
    if (platform_steam() && steam_api_is_initialized()) { steam_friends_activate_game_overlay(_dialog); return true; }
    return false;
}
function tcc_steam_activate_overlay_user(_dialog, _steam_id) {
    if (platform_steam() && steam_api_is_initialized()) { steam_friends_activate_game_overlay_to_user(_dialog, _steam_id); return true; }
    return false;
}
function tcc_steam_activate_overlay_browser(_url) {
    if (platform_steam() && steam_api_is_initialized()) { steam_friends_activate_game_overlay_to_web_page(_url, SteamFriendsOverlayToWebpageMode.Default); return true; }
    return false;
}
function tcc_steam_activate_overlay_store(_app_id) {
    if (platform_steam() && steam_api_is_initialized()) { steam_friends_activate_game_overlay_to_store(_app_id, SteamFriendsOverlayToStoreFlag.None); return true; }
    return false;
}
function tcc_steam_get_persona_name() {
    if (platform_steam() && steam_api_is_initialized()) return steam_friends_get_persona_name();
    return "";
}
function tcc_steam_get_user_persona_name_sync(_steam_id) {
    if (platform_steam() && steam_api_is_initialized()) return steam_friends_get_friend_persona_name(_steam_id);
    return "";
}
function tcc_steam_get_user_avatar(_steam_id, _size) {
    if (platform_steam() && steam_api_is_initialized()) {
        switch (_size) {                                   // mirrors old-src steam_user.cpp:252-273 (default = SMALL)
            case TCC_STEAM_AVATAR_LARGE:  return steam_friends_get_large_friend_avatar(_steam_id);
            case TCC_STEAM_AVATAR_MEDIUM: return steam_friends_get_medium_friend_avatar(_steam_id);
            default:                      return steam_friends_get_small_friend_avatar(_steam_id);
        }
    }
    return 0;   // unavailable. Was -1, which collides with Steam's own "pending" (see 2.8); decide once for all consumers
}
function tcc_steam_image_get_size(_image) {            // legacy contract: [w, h] or undefined
    if (platform_steam() && steam_api_is_initialized() && _image > 0) {
        var _s = steam_utils_get_image_size(_image);
        if (is_struct(_s)) return [_s.width, _s.height];
    }
    return undefined;
}
function tcc_steam_image_get_rgba(_image, _buffer, _size = 0) {   // _size ignored: taken from buffer_get_size
    if (platform_steam() && steam_api_is_initialized()) return steam_utils_get_image_rgba(_image, _buffer);
    return false;
}
function tcc_steam_image_to_sprite(_image) {           // replaces the 4 local steam_image_create_sprite copies; caller OWNS the sprite
    var _dims = tcc_steam_image_get_size(_image);
    if (!is_array(_dims) || _dims[0] <= 0 || _dims[1] <= 0 || _dims[0] > 512 || _dims[1] > 512) return -1;
    var _bytes = _dims[0] * _dims[1] * 4;
    var _buffer = buffer_create(_bytes, buffer_fixed, 1);
    var _sprite = -1;
    if (tcc_steam_image_get_rgba(_image, _buffer)) {
        var _surface = surface_create(_dims[0], _dims[1]);
        buffer_set_surface(_buffer, _surface, 0);
        _sprite = sprite_create_from_surface(_surface, 0, 0, _dims[0], _dims[1], false, false, 0, 0);
        surface_free(_surface);
    }
    buffer_delete(_buffer);
    return _sprite;
}
function tcc_steam_set_rich_presence(_key, _value) {
    if (platform_steam() && steam_api_is_initialized()) return steam_friends_set_rich_presence(string(_key), string(_value));
    return false;
}
function tcc_steam_get_friend_rich_presence(_steam_id, _key) {
    if (platform_steam() && steam_api_is_initialized()) return steam_friends_get_friend_rich_presence(_steam_id, _key);
    return "";
}
function tcc_steam_user_set_played_with(_steam_id) {
    if (platform_steam() && steam_api_is_initialized()) { steam_friends_set_played_with(_steam_id); return true; }
    return false;
}
function tcc_steam_get_friends_game_info() {          // legacy shape [{friendId, gameId, lobbyId, name}], only friends in a game
    var _result = [];
    if (!(platform_steam() && steam_api_is_initialized())) return _result;
    var _flags = SteamFriendsFriendFlag.Immediate;
    var _count = steam_friends_get_friend_count(_flags);
    for (var _i = 0; _i < _count; ++_i) {
        var _friend = steam_friends_get_friend_by_index(_i, _flags);
        var _game = steam_friends_get_friend_game_played(_friend);
        if (!is_struct(_game)) continue;
        array_push(_result, {
            friendId: _friend,
            gameId:   _game.game_id & 0xFFFFFF,
            lobbyId:  _game.lobby_steam_id_64,
            name:     steam_friends_get_friend_persona_name(_friend)
        });
    }
    return _result;
}
```

Persona name by steam id, throttled and de-duplicated (replaces the first draft; D7/D12). Returns `""` while unknown; the CALLER keeps its "Unknown" placeholder unless the result is non-empty:

```gml
#macro TCC_STEAM_PERSONA_RETRY_MS 5000
function tcc_steam_user_name(_steam_id) {
    if (!(platform_steam() && steam_api_is_initialized()) || !is_numeric(_steam_id) || _steam_id == 0) return "";
    var _name = steam_friends_get_friend_persona_name(_steam_id);
    if (_name != "" && _name != "[unknown]") return _name;
    if (!variable_global_exists("tcc_persona_requested")) global.tcc_persona_requested = {};
    var _key = string(_steam_id);
    var _last = global.tcc_persona_requested[$ _key];
    if (is_undefined(_last) || current_time - _last >= TCC_STEAM_PERSONA_RETRY_MS) {
        global.tcc_persona_requested[$ _key] = current_time;
        steam_friends_request_user_information(_steam_id, true);   // literal true: is_bool is enforced
    }
    return "";
}
// Call sites (from Alarm_0 / throttled Step_0, never Draw):
//   var _n = tcc_steam_user_name(mOwner);          if (_n != "") ownername = _n;
//   var _n = tcc_steam_user_name(_lvl.owner_id);   if (_n != "") _lvl.owner_name = _n;
```

Shared avatar callback (only if the callback route is kept; ONE registration from the persistent controller; stores integers only, never sprites):

```gml
function tcc_steam_social_init() {                    // once, next to the steam_api_run_callbacks() controller
    if (!(platform_steam() && steam_api_is_initialized())) return;
    global.tcc_avatar_handles = {};
    steam_friends_set_callback_avatar_image_loaded(tcc_steam_on_avatar_image_loaded);
}
function tcc_steam_on_avatar_image_loaded(_r) {       // self = dummy struct: globals only
    if (_r.image_handle > 0) global.tcc_avatar_handles[$ string(_r.steam_id_64)] = _r.image_handle;
}
// Consumers read global.tcc_avatar_handles[$ string(id)] (or just re-call tcc_steam_get_user_avatar) and build/delete their OWN sprite.
```

---------------------------------------------------------------------------------------------------

## 4. Async-Steam handlers affected (what they read today vs what arrives)

| handler | reads today | replacement |
|---|---|---|
| `objects/o_onlineleaderboards/Other_69.gml:51-69` | `event_type == "avatar_image_loaded"`, `success`, `user_id`, `image` | delete the block; consumer reads the shared integer-handle cache or re-polls `tcc_steam_get_user_avatar`; builds and owns its sprite |
| `objects/o_onlineleaderboardsmini/Other_69.gml:55-73` | same | same |
| `objects/o_onlineleaderboards/Other_69.gml:33-47` and `o_onlineleaderboardsmini/Other_69.gml:37-51` (avatar REQUEST, nested in the leaderboard handler) | `tcc_steam_get_user_avatar(real(entry_user_id), small)` | `steam_friends_get_small_friend_avatar(entry id)`; drop `real()`; runs from the leaderboard callback (other domain) |
| `scr_online_multiplayer.gml:1135-1137` via `o_networkmanager/Other_69.gml:3` | `case "avatar_image_loaded": net_friends_avatar_loaded(_map)` | delete the case; `net_friends_avatar_loaded` (`scr_online_friends.gml:79-85`) is replaced by a poll/handle-cache read inside `net_avatar_sprite` |
| `objects/o_customlevelworkshopbuttonplay/Other_69.gml:21-24` | `async_load[?"id"] == requestname`, `persona_name` | none: resolve `ownername` with `tcc_steam_user_name(mOwner)` in `Alarm_0.gml` (only overwrite when non-empty) |
| `objects/o_customlevelsbrowser/Other_69.gml:76-79, 128-131, 138-159` | request id -> `"browse:N"`/`"sub:N"` in `async_names`, `persona_name` | none: throttled Step loop over the active tab resolving by owner steam id |
| `objects/o_profilepicture/Other_69.gml` | draws a sprite in the async event | delete (dead code) |

`objects/o_fullscreensystem/Other_69.gml` only forwards lobby events and does not touch this domain.

---------------------------------------------------------------------------------------------------

## 5. Open questions / cross-domain dependencies
1. `steam_initialised()` / `tcc_steam_initialised()` / `steam_init()` (`safe:98-105`, used by `o_profilepicture/Create_0.gml:7`, `scr_rich_presence.gml:8`, many others) do not exist in 3.0; replace by `steam_api_is_initialized()`; the 3.0 extension initialises itself.
2. `steam_api_run_callbacks()` must run every frame from a persistent controller or no avatar callback fires (owner: core/api domain).
3. `game_restart`: `scr_online_friends.gml:96` notes that globals survive a restart. Whether the extension's registered callback handles (`__ext_core_function_map`, native `g_cb_*`) survive a restart is unverified; a stale handle would call a dead function. Re-register after restart (or clear in `net_cleanup`); `tcc_steam_social_init` re-creates the handle struct.
4. Real behaviour of small/medium avatar handles for uncached users (0 vs -1) and whether the avatar callback fires for non-large sizes cannot be verified offline; verify on a Steam client with a non-friend lobby member.
5. `tools/check_port.py:79` forbids raw `steam_(inventory_|ugc_|get_achievement|set_achievement|upload_score|initialised)` calls outside `scr_steam_safe` / `scr_platform_services`, but has no rule for `steam_friends_` / `steam_utils_` nor for the removed names. Recommended post-migration gate (D6): add `ov_(friends|community|players|settings|gamegroup|achievements)`, `steam_user_avatar_size_`, `steam_activate_overlay`, `steam_get_(persona|user_|friend|friends_)`, `steam_image_get_`, `steam_set_rich_presence`, `steam_user_set_played_with`, `steam_friends_`, `steam_utils_` to the "must not appear outside scr_steam_safe / scr_platform_services" regex. Keep all new raw calls inside `scr_steam_safe` regardless.
6. `tcc_steam_lobby_activate_invite_overlay` needs the lobby id now (2.17) - matchmaking domain.
7. Leaderboard entries must expose the user id as int64 (see 0.1) so avatar keys (`string(id)`) match between request and draw.
8. Dialog-string case for `steam_friends_activate_game_overlay` is unverified at runtime (2.1).

---------------------------------------------------------------------------------------------------

## 6. Decisions on the verifier disputes

Each dispute was re-checked against the source, not just accepted.

| # | dispute | verdict | evidence / what changed |
|---|---|---|---|
| D1 | persona_name call_sites omit the consumers | ACCEPT (risky) | Confirmed: `o_customlevelworkshopbuttonplay/Other_69.gml:21-24`, `o_customlevelsbrowser/Other_69.gml:138-159`, `Draw_73.gml:20`, `Draw_75.gml:229`, `Create_0.gml:10`. Added to entry and section 2.6/4. Alarm_0.gml:42 / Create_0.gml:34 confirmed to be inside comments. |
| D2 | avatar reference wrapper default -> LARGE | ACCEPT | old-src steam_user.cpp:252-273: `default: GetSmallFriendAvatar`. Reference switch now has explicit LARGE and MEDIUM cases and `default` = SMALL. |
| D3 | "3 call sites" for the size constants | ACCEPT | Grep: small x2 (`o_onlineleaderboards/Create_0.gml:7`, `o_onlineleaderboardsmini/Create_0.gml:9`), medium x2 live (`o_profilepicture/Create_0.gml:36`, `scr_online_friends.gml:71`) + 1 comment (`o_version/Draw_0.gml:36`), large 0. 4 live uses in total. |
| D4 | clear-callback returns listed as "-" | ACCEPT | yy:38 and yy:93: `@returns {Real}`, `returnType` 2. Table corrected (value not meaningful). |
| D5 | lowercase overlay dialogs only doc-proven | PARTIAL | Native passes the string through (`gm_steam_friends.cpp:95-96`); old table was TitleCase (old-src :24-31); docs list lowercase (friends.js:5-14). Both likely work, none of this is runtime-proven for lowercase. Kept lowercase (Valve-documented), confidence lowered to MEDIUM, smoke test required, TitleCase named as one-line fallback. |
| D6 | "compile error" is unsupported | ACCEPT in substance | `grep -c GMExtensionConstant yy` = 0 and no `ov_*` / `steam_user_avatar_size*` in `API.gml`, but nothing proves the compiler rejects them; GameMaker resolves unknown identifiers at run time. Wording changed to "undefined identifier, runtime error at first execution" (0.6), grep gate added (5.5). Could not verify compile behaviour offline. |
| D7 | "once per id" in prose but code requests on every miss; resolving in Draw = request per tile per frame | ACCEPT | Old helper had no memo; `request_user_information` has no dedupe (`API.gml:13688-13706`). Helper now keeps a per-id timestamp (5 s retry); lookup moved to Alarm/throttled Step, never Draw. |
| D8 | large avatar is 184x184, not 128x128 | ACCEPT as moot | friends.js:600-605 says 128; the verifier's 184 cannot be checked offline. Irrelevant to the port because the project sizes buffers from `steam_utils_get_image_size` and caps at 512 (`scr_online_friends.gml:53`). Pixel sizes removed from macros/comments; left as unresolved fact only. |
| D9 | shared global sprite cache vs per-owner deletion (risky) | ACCEPT | Confirmed `reloadleaderboards.gml:39-46` and `reloadleaderboardsmini.gml:10-17` delete every sprite then `ds_map_clear`; `net_avatars_free` (`scr_online_friends.gml:87-98`) deletes all of `global.net_avatars`. Recommendation changed: the single callback stores integer handles only; each consumer owns its sprites (0.4, 2.9). Both reload scripts added to the affected list. |
| D10 | "never delete avatar_sprites" is wrong | ACCEPT | Reload scripts free sprites and clear the map; `ls` shows no CleanUp event in either object, so only the map and the sprites held at destroy time leak. Reworded (2.12). |
| D11 | "old left uncached owners Unknown forever / new cannot be worse" | ACCEPT (partial) | old-src :296-303 emits the event whenever `RequestUserInformation` returns false, and `o_customlevelworkshopbuttonplay/Alarm_0.gml:3,36` re-calls every 30 ticks, so the workshop button recovered. Only the browser's one-shot requests stayed Unknown. Text corrected; workshop polling = parity, browser = improvement. |
| D12 | helper returns "" and callers would draw an empty name | ACCEPT (risky) | `Create_0.gml:10` / `Other_69.gml:28` / `Create_0.gml:83` initialise "Unknown"; `Draw_73.gml:20` and `Draw_75.gml:229` draw unconditionally. Callers now overwrite only on a non-empty result. |
| D13 | persona callback must also test NameFirstSet | ACCEPT (precaution) | Enum has `NameFirstSet = 1024` separately (`API.gml:518-534`, friends.js:1371). Only relevant for the optional callback route; test `Name | NameFirstSet` or invalidate on any change. |
| D14 | (duplicate of D2) default case | ACCEPT | See D2. |
| D15 | transient 0 -> permanent blank avatar is pre-existing | ACCEPT | Old code returned the raw SDK handle too (old-src :252-273) and `net_avatar_sprite` already cached 0 as -1 (`scr_online_friends.gml:72-75`). Reworded as pre-existing; hardening kept as optional. |
| D16 | `net_register_player` does clean the name | ACCEPT | `scr_online_multiplayer.gml:790` `username: net_clean_name(_username)`. Gotcha text corrected; no code change. |
| D17 | `set_rich_presence()` has more invokers | ACCEPT (completeness) | Also `objects/o_title/Create_0.gml:8` and 18 room creation codes (grep). All go through `tcc_steam_set_rich_presence`; no per-site edits. `scr_rich_presence.gml` has 74 wrapper calls (grep -c). |

Nothing in the first draft was rejected outright; D5 and D11 are partial.

---------------------------------------------------------------------------------------------------

## 7. Unresolved (cannot be settled from the repository)
- Runtime acceptance of lowercase dialog strings in `steam_friends_activate_game_overlay` (needs a Steam client smoke test; TitleCase fallback ready).
- Exact return semantics (0 vs -1) of small/medium avatar handles for not-yet-cached users, and whether `AvatarImageLoaded_t` fires for small/medium.
- Exact pixel size of the large avatar (3.0 docs: 128; possibly 184 per Valve). Irrelevant to the port.
- Whether GameMaker flags an undefined identifier at compile time on any target (assumed runtime only; the grep gate covers both).
- Whether extension callback registrations survive `game_restart`.
- Whether `json_decode` of the leaderboard entries already truncates 17-digit Steam64 ids to doubles (assumed possible; the stats domain must guarantee int64 ids regardless).
- Whether Steam delivers `PersonaStateChange_t` with `Name` vs `NameFirstSet` for strangers (only matters for the optional callback route).
