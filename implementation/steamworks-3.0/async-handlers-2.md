# Async-Steam handlers (group 2): analysis for the Steamworks 2.1.6 -> 3.0.0 port

Scope: `objects/o_onlineleaderboardsmini`, `o_fullscreensystem`, `o_customlevelsbrowser`, `o_workshopERloading`, `o_publishworkshopchallenge` (all `Other_69.gml`).
Project root: `/Users/infi/Documents/Github/TheColorfulCreature` (paths below are relative to it unless absolute).
Scratch roots used for evidence (abbreviated below):
- `API` = `scripts/Steamworks_API/Steamworks_API.gml` (3.0 GML wrappers + structs)
- `CORE` = `scripts/ExtensionCore_api/ExtensionCore_api.gml` (callback registry and dispatcher)
- `SRC` = `<scratchpad>/gmext/src/source/Steamworks_gml/extensions/steamworks/source/src/` (3.0 native C++)
- `DOC3` = `<scratchpad>/gmext/src/docs/*.js` and `getting_started.md`
- `OLD` = `<scratchpad>/port/txt/old_*.txt` (text dump of the 2.x HTML docs, built for this task)
where `<scratchpad>` = `<scratchpad>`.

Nothing in the project was modified. Where something is inferred, not verified, it is marked **(inferred)** or **(UNVERIFIED)**.

---------------------------------------------------------------------------------------------------

## 0. What changes at the mechanism level (applies to all five handlers)

Read this first: points 0.1 and 0.2 change the design, not just the syntax.

### 0.1 Async calls return nothing, so every "match by request id" idea disappears
- `DOC3/getting_started.md` ("Calling a function"): asynchronous functions "return nothing useful"; the result arrives later as a single struct argument.
- Every 3.0 async wrapper in `API` ends with `return __return_value__;` of a native `void` function (e.g. `steam_matchmaking_create_lobby` API L22797-22826, `steam_ugc_*`, `steam_userstats_*`). There is no async id to store, compare, or key a ds_map by.
- Consequences for existing project code that treats the return value as a handle or success flag:
  - `net_host_lobby()` does `if (!tcc_steam_lobby_create(...)) { net_create_pending=false; host_retry_at=+15000 }` (`scripts/scr_online_multiplayer/scr_online_multiplayer.gml` L437-440). A pass-through wrapper that returns `undefined`/nothing makes that branch fire on every call, and the real reply later arrives with `_create_owned == false`, so the lobby is created and immediately left every 15 s.
  - `workshopER_query_catalog()` does `global.workshopER_query_id = tcc_steam_ugc_send_query(qh); if (id <= 0) { scan_done = true }` (`scripts/scr_workshopER/scr_workshopER.gml` L88-92). With no id the scan is declared finished immediately.
  - `net_join_lobby()` L453, `o_publishworkshopchallenge/Create_0.gml` L176 (`create_request = ...`), `reloadleaderboardsmini.gml` L20-25 (`score_get = ...`), `o_customlevelsbrowser/Create_0.gml` L58 and L122 (`browse_query_id`, `async_details[? req_id]`) all rely on a returned id.
- Replacement: a **request token** (serial number) that the caller increments and captures in the callback's bound context; the callback compares it to the owner's current token (section 0.5).

### 0.2 Callbacks can silently never fire, so every "pending" state needs a GML-side deadline
Evidence (native C++):
- `SRC/steam_async_common.h` L12-56: `steam_async::CallResult<Payload, SteamStruct, bool ReportIoFailure = false>`. On Steam I/O failure the handler only calls the GML callback when `ReportIoFailure == true`; otherwise it `delete this` and drops the callback.
- Instantiations with the default `false` for exactly the calls these handlers use: lobby create/join (`gm_steam_matchmaking.cpp` L195, L213), leaderboard find/download (`gm_steam_userstats.cpp` L717, L736, L763, L796), UGC query/create/submit/subscribe/unsubscribe (`gm_steam_ugc.cpp` L1482, L1494, L1509, L1522, L1533). Only a few remote-storage, apps and user-stats-received calls pass `true`.
- Dispatch failure: `userstats` and `matchmaking` natives check `call == k_uAPICallInvalid`, call `steam_set_last_error(...)` and return without ever invoking the callback (`gm_steam_userstats.cpp` L755-761, `gm_steam_matchmaking.cpp` L190-193, L208-211). The UGC natives do not even check (`gm_steam_ugc.cpp` L1479-1483: `h->set(call)` with a possibly invalid call).
- `STEAM_GUARD()` (`SRC/GMSteamworks.h` L14-18) returns early when Steam is not initialised: no callback.
- On iOS/Android/MAS the native library is not copied (`tools/check_port.py` L21-33: `copyToTargets == '0'`), so `platform_steam()` must remain the gate. `__Steamworks_is_available()` is just `extension_exists("Steamworks")` (`API` L24764-24768) and each wrapper does `if (!available) return;`, again with no callback.
- **Every state that waits for a reply must therefore get a deadline**, otherwise it deadlocks:
  - `global.net_create_pending` / `global.net_join_pending_id` (comment at `scr_online_multiplayer.gml` L286: "Clear only on their reply" becomes a permanent deadlock; `net_host_lobby` L430-436 and `net_tick` L557-564 then never create or join again).
  - publish `result` 0.1 / 0.5 (no `timer` set while waiting, so the "Uploading..." overlay never ends except by Escape, and `net_follow_can_enter` L509 keeps returning false for the whole time).
  - browser `browse_state = "loading"` (blocks Load More and the tab-switch auto-load, which require `loaded` / `idle`).
  - mini leaderboard "LOADING" text; workshopER `global.workshopER_query_id` / `scan_done`.

### 0.3 A callback argument is mandatory and must be callable
Every async wrapper does `if (!is_callable(_callback)) show_error(..., true)` (e.g. `API` L22814-22816, L19937-19940). Fire-and-forget uses must pass an explicit no-op:
`tcc_steam_ugc_subscribe_item(...)` at `o_customlevelsbrowser/Step_0.gml` L181, `scr_workshopER.gml` L199, `scr_online_session.gml` L906/L915/L999, and `tcc_steam_ugc_unsubscribe_item(...)` at `scr_workshopER.gml` L319 and `scr_online_session.gml` L927. Either the `tcc_` wrapper defaults the callback or every call site passes one.

### 0.4 Delivery mechanics (affects lifetime reasoning)
- Pump: `steam_api_run_callbacks()` must be called every frame (`DOC3/getting_started.md` "Running the callbacks"). Today the old pump `tcc_steam_update()` is called only from `objects/o_fullscreensystem/Step_0.gml` L4, after `if (!timing_instance_step()) exit;` (L1), i.e. on logical ticks only. `o_fullscreensystem` is persistent (`o_fullscreensystem.yy` L23) and is the natural host for the new pump, but the decision whether to call it before the timing gate is open. `instance_deactivate_*` is not applied to any of the five objects in this task (grep of all `instance_deactivate_*` calls), so deactivation is not a hazard here; it would be one in general because a deactivated owner fails `instance_exists`.
- Drain: native completions go into a queue; GML drains it from a **global time source** created in `__GMNativeFunctionDispatcher` (`CORE` L240-262: `time_source_create(time_source_global, 1, time_source_units_frames, ...)`), which runs `__ext_core_function_dispatch_calls` (`CORE` L298-371). So callbacks run **outside any instance event**, independent of whether the instance that requested still exists, in the same frame or the frame after the pump.
- Invocation: `with (_dummy_context) method_call(_ref[0], _args)` (`CORE` L350). `_ref[0]` is exactly the callable the caller passed. A bare script/anonymous function therefore runs with `self` = ExtensionCore's dummy struct: `instance_destroy()`, `x`, `alarm[0]`, any instance variable in the body will not refer to the requesting instance. A function literal written in an object event is bound to that instance by GML; whether calling such a method after the instance was destroyed is safe is **UNVERIFIED** (do not rely on it; use the pattern in 0.5).
- Handle/refcount: `__ext_core_function_register` keys the callable by `int64(ptr(_callable))` and, if that handle already exists, only increments the refcount and **keeps the first callable** (`CORE` L271-291). Never reuse one callable value for requests that must run different code; create a fresh bound method per request (0.5).
- Failed dispatch: when the native function returns early, the `GMFunction` goes out of scope, which releases the handle (command 2), so the registry does not leak; the GML code just never hears back.
- Ids are plain numbers: all Steam ids in arguments and result structs are `Real` (decoded from `buffer_u64`), e.g. `SteamUserStatsDownloadedLeaderboardEntry.steam_id_user` (`API` L3098-3110), `SteamUgcQueryResult.owner_steam_id`, `SteamMatchmakingLobbyCreated.lobby_id`, `SteamFriendsAvatarImageLoaded.steam_id_64`. The `SteamId` struct (`API` L1686) is only returned by `steam_user_decode_steam_id` (`API` L14744-14765). Existing `string(id)` map keys and `int64` comparisons stay valid.

### 0.5 Required callback shape (applies to every handler below)
GML function literals do not capture local variables. The state a callback needs must travel in a context struct bound with `method(ctx, fn)`:

```gml
// sketch, not project code
var _ctx = { owner: id, token: ++req_token };           // id = instance reference
steam_x(..., method(_ctx, function(_r) {
    if (!instance_exists(owner)) return;                 // owner destroyed / deactivated
    if (owner.req_token != token) return;                // superseded by a newer request
    with (owner) { /* apply _r to instance state here */ }
}));
```
Rules derived from the handlers below: (1) always check owner existence **and** token; (2) all `_r` data must be copied into owner state inside the callback; (3) any Steam resource obtained for the callback (UGC query handle) must be released on every path, including the "owner gone / stale" paths; (4) destroy events must bump or invalidate the token; (5) for state that must survive the owner (workshopER, lobby), use global state and plain script callbacks instead of an instance.

**Caveat that decides whether this pattern is safe (UNVERIFIED): is `ptr()` distinct for every `method(ctx, fn)` value?** `__ext_core_function_register` keys the callback by `int64(ptr(_callable))` and, on a key collision, keeps the **first** callable and only bumps a refcount (`CORE` L271-291). If two methods created from the same function literal give the same `ptr()`, two concurrent requests would both run the first request's context, and the token check would compare against the wrong token (stale handling silently broken, e.g. the two minis in `r_gameoverscreen` showing the same board). The 3.0 examples do not settle it: they pass inline literals or one shared named handler (e.g. `obj_steam_ugc_query_*/Mouse_7.gml` use the shared `obj_steam_ugc.items_query_handler`; `obj_steam_leaderboard_*/Mouse_7.gml` use inline `function(data){...}`; none use `method(ctx, ...)` with overlapping requests). Required before relying on the pattern: a smoke test with two overlapping requests that must produce different results (two minis, or two UGC queries with different pages). **Fallback that does not depend on `ptr()`:** make the callback a single shared function and match by a key that is known *before* the reply is read: `query_handle` (returned by `create_query_*` before sending, and echoed in `SteamUgcQueryCompleted.query_handle`), `leaderboard_handle` (echoed in `SteamUserStatsScoresDownloadedResult`), `published_file_id` for subscribe replies, `lobby_id` for join replies; keep a global `request_table[key] = {owner, token}`. For calls with no prior key (`steam_ugc_create_item`, `steam_matchmaking_create_lobby`, `steam_userstats_find_leaderboard` by name) allow exactly one outstanding request per kind (FIFO queue) and match in order.

### 0.6 Single-slot callbacks (affects avatars and persona names)
`steam_friends_set_callback_avatar_image_loaded` and `..._persona_state_change` store one `GMFunction` in a static (`SRC/gm_steam_friends.cpp` L40, L74-79, L949, L979-983): a second `set_callback` **replaces** the first. The project has at least four consumers of avatar/persona events (`o_onlineleaderboardsmini`, `o_onlineleaderboards`, `o_networkmanager` -> `net_friends_avatar_loaded`, `o_customlevelsbrowser`). They need **one** registered dispatcher (in `scr_steam_safe`) that fans out to subscribers. In 2.x every instance with an Async-Steam event received every event; this is the replacement.

### 0.7 Static-check constraint
`tools/check_port.py` L78-79 rejects raw `steam_(inventory_|ugc_|get_achievement|set_achievement|upload_score|initialised)...(` outside `scr_steam_safe` and `scr_platform_services`. UGC results must be decoded inside `scr_steam_safe` and handed to the object as plain structs (e.g. `{ok, total, items:[...]}`). The regex does not cover the new prefixes `steam_userstats_`, `steam_friends_`, `steam_matchmaking_`, `steam_utils_`; it should be extended, and handlers must only call `tcc_*` wrappers (preserving `platform_steam() && steam_api_is_initialized()`).

### 0.8 Non-Steam events
All five `Other_69.gml` are the **Asynchronous - Steam** event: each `.yy` has `{"eventNum":69,"eventType":7}` (`o_onlineleaderboardsmini.yy` L6 and the equivalent in the other four). No handler reads HTTP, social, IAP or other async events. Event 69 is broadcast: every instance that owns an Async-Steam event sees every Steam event from every requester (that is why each handler filters by id or `event_type`, and why the mini's avatar branch also consumes avatars requested by `o_networkmanager` / `o_onlineleaderboards`). The 3.0 native code never posts a GML async event (grep of `SRC` for `CreateAsynEventWithDSMap`/`event_perform_async`: only an unused vtable slot `CreateDsMap` in `code_gen/core/GMExtUtils.h` L123), so **after the port none of these five `Other_69` events can fire**; they must be deleted (a leftover handler would silently become dead code).

---------------------------------------------------------------------------------------------------

## 1. `o_onlineleaderboardsmini` (mini leaderboard panel)

Files: `objects/o_onlineleaderboardsmini/{Create_0,Alarm_0,Draw_0,Other_69}.gml`, request in `scripts/reloadleaderboardsmini/reloadleaderboardsmini.gml`. `persistent:false` (`.yy` L18). Events present: Create, Alarm 0, Draw, Async-Steam only. **No CleanUp/Destroy event.**

### 1.1 Keys and event types read (Other_69.gml)
| Line | Key / type | Meaning |
|---|---|---|
| 1 | `tcc_steam_initialised()` | exit if Steam off (mobile/offline) |
| 2-4 | `global.hardmode` | if 1: `instance_destroy()`, exit |
| 6 | `async_load[? "id"]` | request id, compared with `score_get` (L7) |
| 7-53 | no `event_type` check | any event whose `id == score_get` is treated as a leaderboard download. 2.x documents two shapes for these calls: `event_type "leaderboard_download"` (keys `id, status, lb_name, num_entries, entries`) and `"leaderboard_not_found"` (keys `id, status, lb_name`, **no `entries`**) (`OLD/old_leaderboards.txt` L441-475, L534-600) |
| 9 | `entries` | JSON string, decoded with `json_decode` (L10) |
| 11 | map key `"default"` | present when the decoded top-level JSON is not an object (inferred to be the empty/no-entries case) |
| 18 | map key `"entries"` | ds_list of entry ds_maps |
| 24-26 | entry keys `name`, `score`, `rank` | |
| 29-33 | entry keys `userID` (else `steamid`) | Steam id (`OLD/old_leaderboards.txt` L715-735: `rank, score, name, userID Int64, data`) |
| 55 | `event_type != "avatar_image_loaded"` -> exit | all other events are ignored here |
| 57-59 | `success`, `user_id`, `image` | avatar event keys (`OLD/old_social.txt` L184-200: `event_type, success, user_id, image, width, height`) |

### 1.2 State changed
Instance variables (all created in Create_0/`reloadleaderboardsmini`, none global):
- `steam_name[i]`, `steam_score[i]`, `steam_rank[i]`, `steam_userid[i]` for `i < len` (L24-26, L34). `reloadleaderboardsmini.gml` L2-8 pre-fills 100 slots (`""`, 0, 0, `noone`) on every reload; Draw_0 reads 50.
- `avatar_sprites` (ds_map, key `string(user_id)` -> sprite id, or `-1` = pending, `-2` = no avatar) (L38-47, L62-68).
- Avatar event path overwrites the entry **for any user id** (L63-68), including users not on this board (e.g. friends' avatars requested by the network manager), and deletes the previous sprite only if it exists.
- `instance_destroy()` on hardmode (L2).
- Display: `Draw_0.gml` L20-21 shows `loc("LOADING")` while `steam_score[0] == 0 && steam_rank[0] == 0`; row text at L13-14/L26-28 (`numerical` selects `rank. name score` vs `score/1000 s`); avatars L30-48 (grey "?" box when `sprite_exists` is false, including `-1`/`-2`).

### 1.3 Who initiates, and when
- `reloadleaderboardsmini()` (script, runs in the instance) sets `score_get = tcc_steam_download_scores_around_user(lbname, -9, 10)` when `instance_number(o_onlineleaderboardsmini) == 1`, otherwise `(-4, 5)`; for `global.workshop == 1` it uses `"CL_" + lbname` with `(-4, 5)` (`reloadleaderboardsmini.gml` L19-27). Wrapper: `scr_steam_safe.gml` L62-65 (returns `false` when Steam is off).
- Callers: `Create_0.gml` L89; `Alarm_0.gml` L14/L23/L32 (5 ticks after create, `Create_0` L90, only for `r_gameoverscreen`, `r_dailylevelwin`, `r_endlessrunmenu`); `objects/o_reloadleaderboardsbutton/Mouse_4.gml` L6-9 (user presses reload, any time).
- Instances: created from rooms (many `*win` rooms, `r_gameoverscreen` x2, `r_dailylevelwin` x2, `r_endlessrunmenu` x2) and from `rooms/r_workshoplevelwin/InstanceCreationCode_inst_E6C5F01_1_1.gml` L35-36. Destroyed by `objects/o_customendlessbutton/Mouse_4.gml` L14 (`instance_destroy(o_onlineleaderboardsmini)`) and by itself on hardmode / `!platform_steam()` / missing challenge leaderboard (Create_0 L1, L46).
- Two instances share a room (gameover, daily, endless menu). Creation code runs **after** Create_0 and sets `diff`/`lbname` (`rooms/r_gameoverscreen/InstanceCreationCode_inst_7AF81BDA.gml`: `diff = 1`; `rooms/r_dailylevelwin/InstanceCreationCode_inst_35D2D58A.gml`: `diff = 1; lbname = "Current Daily Level Streak"`; `rooms/r_endlessrunmenu/InstanceCreationCode_inst_3EC79D26.gml`: `diff = 1; lbname = "Endless Run 50L"`). So Create_0 issues request #1 with a provisional board and Alarm_0 issues request #2 for the correct one, 5 ticks later. **Request re-issue before the first reply is the normal path, not an edge case.**
- Avatar requests are made synchronously inside the handler, per entry (L39): `tcc_steam_get_user_avatar(real(id), avatar_request_size)` where `avatar_request_size = steam_user_avatar_size_small` (Create_0 L9). Wrappers `scr_steam_safe.gml` L78-80, L90-97.

### 1.4 Resources created / destroyed
- `json_decode` map: destroyed at L13 (default branch) and L52 (normal branch). Not destroyed (and not reachable) if `entries` is missing or invalid, see 1.5.
- `avatar_sprites` ds_map: created Create_0 L11; cleared on every reload (`reloadleaderboardsmini.gml` L10-18, which also `sprite_delete`s the sprites). **Never destroyed**: the object has no CleanUp/Destroy event, so the map and all avatar sprites leak whenever an instance goes away (room change of a non-persistent object, `o_customendlessbutton` L14, hardmode destroy).
- Sprites: `steam_image_create_sprite` (Create_0 L13-37) makes a surface, a buffer (freed), and a sprite per avatar.
- Async avatar branch can add sprites for unrelated users (1.2); nothing frees them until the next reload.

### 1.5 Error / empty behaviour (complete)
| Situation | Behaviour |
|---|---|
| Steam not initialised | exit, no change (L1) |
| hardmode | instance destroyed (L2) |
| Event id != `score_get` and not an avatar event | exit at L55, no change |
| `entries` has top-level `"default"` key | map destroyed, `exit` (L11-15). Arrays stay at their reload defaults, so Draw_0 keeps showing "LOADING" forever (no "empty" message) |
| Normal entries | arrays filled for `i < len`; remaining slots keep defaults |
| `leaderboard_not_found` (same `id`, no `entries` key) | `ds_map_find_value` returns `undefined`, `json_decode(undefined)` (L10) is **very likely a runtime error** (UNVERIFIED: GM manual not consulted offline). Not handled |
| `entries` key present but empty string / invalid JSON | `json_decode` result is `-1`, then `ds_map_exists(-1, "default")` (L11): **very likely a runtime error** (UNVERIFIED) |
| `entries` map without `"entries"` list | `ds_list_size(undefined)` error |
| Entry without `userID`/`steamid` or id 0 | no avatar requested, `steam_userid[i]` = `noone`/0 |
| `get_user_avatar` returns `> 0` | sprite created immediately; `== 0` stored as `-2` (permanent "no avatar"); anything else (`-1` pending) stored as `-1` and waits for the event |
| Avatar event `success != 1` | `show_debug_message("Failed to get user avatar")`; entry stays `-1`, "?" box forever |
| Avatar event `success == 1` but `image <= 0` | silently ignored |
| Stale reply (older request) | ignored purely because its `id != score_get` |

### 1.6 Restructure for 3.0
What the object needs to become:
1. **Two-step request**: `steam_userstats_find_leaderboard(name, cb)` -> `SteamUserStatsLeaderboardFindResult{leaderboard_handle, leaderboard_found}` (`API` L3117-3130; `DOC3/userstats.js` L354-371), then `steam_userstats_download_leaderboard_entries(handle, SteamLeaderboardDataRequest.GlobalAroundUser, -9, 10, cb)` -> `SteamUserStatsScoresDownloadedResult{leaderboard_handle, entries_handle, entry_count}` (`API` L19909-19948, L3133-3146; enum `API` L1421-1426: Global=0, GlobalAroundUser=1, Friends=2). The 2.x single call did both. `leaderboard_found == false` replaces `leaderboard_not_found` (handle is 0) and must render as "empty" (and never reach a decoder). Cache the handle per board name for the session (`DOC3/userstats.js` L336: valid for the game session). Cache rules: never cache a `leaderboard_found == false` result (the `CL_` boards are created at runtime); dedupe finds already in flight for the same name (reload-button spam, two minis in one room); and keep the cache in `scr_steam_safe`, not per instance.
2. **No JSON, no name**: read each row with `steam_userstats_downloaded_leaderboard_entry(entries_handle, i)` -> `{steam_id_user, global_rank, score, details, ugc_handle}` (`API` L3098-3110); it returns `undefined` when the index/handle is invalid (`API` L19988-20020). `rank` = `global_rank`, `userID` = `steam_id_user` (plain number, no more `real()`/precision issues from `json_decode`), `name` is **not in the struct**: resolve with `steam_friends_get_friend_persona_name(id)` (sync; `""` or `"[unknown]"` when not yet known, `DOC3/friends.js` L451-463) and, when unknown, `steam_friends_request_user_information(id, true)` which returns `true` if data was requested and then delivers a persona-state-change with flag `SteamFriendsPersonaChange.Name = 1` (`SteamFriendsPersonaChange` enum, `API` L518; `DOC3/friends.js` L843-855, L904-919). Names that arrive late must update `steam_name[i]` through the single fan-out dispatcher.
3. **Read entries inside the callback, and serialize downloads.** `entries_handle` is "obtained from the most recently received LeaderboardScoresDownloaded_t call result" (`DOC3/userstats.js` L475-485) and the native converter only copies the handle (`gm_steam_userstats.cpp` L625+). Native completion and GML dispatch are separated (0.4). Rooms with two minis plus `o_onlineleaderboards` have 2-3 downloads in flight; if two complete in one pump, the first callback may find its `entries_handle` already superseded (UNVERIFIED against the SDK, but the doc wording makes it the safe assumption). Mitigation: a single download queue in `scr_steam_safe` (one outstanding download, next started from the previous callback after it copied its rows) and treat `undefined` from `steam_userstats_downloaded_leaderboard_entry` as "retry/empty".
4. **Avatars** (`steam_friends_get_small_friend_avatar(id)` -> handle, `steam_utils_get_image_size(h)` -> `SteamUtilsImageSize{width,height}`, `steam_utils_get_image_rgba(h, buffer)` -> bool; `API` L13457, L15587, L15611). Wrapper `tcc_steam_image_get_size`/`get_rgba` must change signature (`scr_steam_safe.gml` L90-97 pass 3 args and expect an array). Behavioural changes:
   - `steam_friends_set_callback_avatar_image_loaded` is documented for **large** avatars only (`DOC3/friends.js` L137-146; struct has no `success`, only `steam_id_64, image_handle, width, height`, L1126-1136). The mini uses the **small** avatar, so a pending small avatar may never produce a callback (UNVERIFIED in the SDK, but the doc says large only).
   - The 3.0 doc says `get_small_friend_avatar` only works for users the local user "knows"; otherwise call `steam_friends_request_user_information(id, false)` (`DOC3/friends.js` L644) and wait for a persona change with `Avatar = 64`. The current mini stores `img == 0` as permanent `-2`; with 3.0, `0` can mean "unknown yet", so treat it as retryable (bounded retries via the persona-change fan-out or a short poll in Step), cache `-2` only after the info request completed.
   - Restrict the late-avatar branch to ids present in `steam_userid` (today it adds unrelated users, 1.2).
5. **Request token + owner check** (0.5). Each `reloadleaderboardsmini()` call increments `req_token`; both the find callback and the download callback capture `{owner, token}`; stale replies (request #1 of the gameover/daily/endless rooms, reload-button spam, ids from before a `lbname` change) are dropped. This matters for correctness, not just tidiness: in `r_gameoverscreen` request #1 is for the global board (`Create_0` L52-53) and #2 for "Seasonal Endless Run" (Alarm_0 L12); without the token, a late #1 would fill the "Seasonal" panel with the wrong board, because Draw_0 labels rows with the current `lbname`.
6. **Lifetime hazards**
   - Instance destroyed (room change, `o_customendlessbutton` L14, hardmode) before either callback: owner check; also bump `req_token` and free `avatar_sprites` + sprites in a new CleanUp event (fixes the pre-existing leak, 1.4).
   - Callback after room change but the instance still exists (not persistent, so it cannot).
   - Callback #1 after `reloadleaderboardsmini()` has cleared arrays (L2-8): token drops it.
   - Deadline: if neither callback arrives within N seconds, set a failure state; Draw_0 currently has no failure/empty text (always "LOADING"). Add an "empty / unavailable" state so `leaderboard_found == false`, `entry_count == 0` and timeout are distinguishable.
   - Multiple instances share the process-wide avatar/persona callback slots (0.6).
   - *Create-then-read ordering for `CL_` boards (new in 3.0).* `rooms/r_workshoplevelwin/InstanceCreationCode_inst_E6C5F01_1_1.gml` calls `scr_saveworkshopmedals()` (L31-33), which creates the `"CL_"+Publish_ID` board and uploads the time (`scripts/scr_saveworkshopmedals/scr_saveworkshopmedals.gml` L19-20), and then creates the mini (L35-36). In 2.x the create/upload/download calls were serialised inside the extension. In 3.0 they are independent async chains: the mini's `find_leaderboard` can run before `find_or_create_leaderboard` has finished (first-ever clear shows an empty board, and a cached "not found" would persist), and the download can complete before `steam_userstats_upload_leaderboard_score` so the fresh time is missing. Fix: route create/find/upload/download for one board name through the same per-board FIFO in `scr_steam_safe`, make the mini use find-or-create for `CL_` boards, and start the mini's download only after the pending upload for that board (if any) has completed.
7. `Other_69.gml` is deleted; `Create_0.gml` L9 (`steam_user_avatar_size_small`) is a 2.x constant (check `identifiers.json` for its 3.0 fate; 3.0 has separate small/medium/large functions instead of a size argument).

---------------------------------------------------------------------------------------------------

## 2. `o_fullscreensystem` (persistent owner for lobby replies)

`objects/o_fullscreensystem/Other_69.gml` (6 lines); `persistent:true` (`.yy` L23). It is the persistent controller (window/cursor/stars, `Step_0.gml` L4 also pumps `tcc_steam_update()`).

### 2.1 Keys read
`async_load[? "event_type"]` only (L5). If it is `"lobby_created"` or `"lobby_joined"` it forwards the **whole `async_load` map** to `net_handle_async_steam(async_load)` (L6, `scripts/scr_online_multiplayer/scr_online_multiplayer.gml` L1017). Inside, those two cases read `success`, `lobby_id` (`_map[? "success"]` L1031, L1034, L1055, L1061, L1065; `_map[? "lobby_id"]` L1035, L1051). Early exits at L3-4: Steam off, **a network manager exists** (`instance_exists(o_networkmanager)`, then the manager's own `Other_69` handles it, `objects/o_networkmanager/Other_69.gml` L3), or `global.net_create_pending` does not exist yet (net_init never ran).

### 2.2 State changed
Nothing in the object. Through `net_handle_async_steam` (which first returns if `!global.net_ready`):
- `lobby_created` (L1022-1049): clears `global.net_create_pending`, `global.net_host_intent`; if the reply is unexpected (not owned, host intent withdrawn, pending join, already active, online disabled) it calls `net_discard_lobby_reply(success)`; on success sets `net_lobby_id`, `net_active`, `net_join_time`, `net_owner_id`, `net_refresh_tick`, refreshes members, `net_become_host()`; on failure sets `net_host_retry_at = current_time + 30000`.
- `lobby_joined` (L1050-1100): validates against `global.net_join_pending_id` / `net_pending_join`, clears them, on failure leaves the lobby, resets state and flashes `NET_JOIN_FAILED`; on success re-reads members/data, may leave on version mismatch, then sets active/host flags, sends hello, joins/becomes host, `net_flash`, `net_presence_update`.
- `net_discard_lobby_reply(success)` (L462-465): `tcc_steam_lobby_leave()` if success, then `net_reset_lobby_state()` (L357-372).

### 2.3 Initiators
- Create: `net_host_lobby()` L429-441 -> `tcc_steam_lobby_create(steam_lobby_type_friends_only, NET_MAX_LOBBY)` L437 (wrapper `scr_steam_safe.gml` L150-153), called from `net_tick()` L564 (every logical tick when not active, nothing pending, `current_time >= net_host_retry_at`, not in `r_loading`/`r_logointro`).
- Join: `net_join_lobby()` L445-457 -> `tcc_steam_lobby_join_id(_lobby_id)` L453 (wrapper L170-173), called from `net_tick()` L559 after `net_request_join`/`net_queue_join` (L395-427; also from overlay `lobby_join_requested` and cold-launch `net_launch_lobby`).
- Why this handler exists: the comment at L1-2 ("Native create/join replies can outlive the destroyed manager"). `o_networkmanager` is persistent and destroyed only by `game_restart` (`net_game_restart` L323-326, `objects/o_networkmanager/CleanUp_0.gml` L1-7 skips `net_cleanup` when `net_restarting`); a reply that lands while no manager exists is settled here.

### 2.4 Resources
None created or destroyed.

### 2.5 Error / empty behaviour
- `success == false` on create: retry in 30 s, no user notice (L1044-1048). On join: `NET_JOIN_FAILED` flash and lobby reset (L1065-1070).
- Reply with no matching pending request: `net_discard_lobby_reply` (leave if success, reset local lobby state) unless a lobby is already active (L1030-1032, L1054-1056, L1060-1062).
- Missing `lobby_id` is not checked. `event_type` other than the two names is ignored in this object.

### 2.6 Restructure for 3.0
- **The handler disappears.** Replies come to a callback passed to the call, not to an instance event, so no persistent owner is needed. `steam_matchmaking_create_lobby(type, max, cb)` -> `SteamMatchmakingLobbyCreated{result, lobby_id}` (`API` L22797, L3729-3740; `lobby_id` is 0 on failure, `DOC3/matchmaking.js` L663-670); `steam_matchmaking_join_lobby(id, cb)` -> `SteamMatchmakingLobbyEnter{lobby_id, chat_permissions, locked, response}` (`API` L22829, L3745-3758; `response` is `SteamMatchmakingChatRoomEnterResponse`, `Success = 1`, `API` L1557). `success` becomes `result == SteamApiResult.Ok (1)` for create and `response == SteamMatchmakingChatRoomEnterResponse.Success (1)` for join. The comment in `net_handle_async_steam` L1058-1059 says 2.x "reports IO success even for a full or vanished lobby"; 3.0 gives the real `response`, so the later member-count validation can keep as defence but need no longer be the only check.
- `net_handle_async_steam`'s lobby cases become plain script functions `net_on_lobby_created(_r)` / `net_on_lobby_entered(_r)` that touch only `global.net_*` (they already do), passed as callbacks from `net_host_lobby` / `net_join_lobby`. That removes the "who owns the reply" problem: a plain script callback is independent of every instance, including across the period when `o_networkmanager` does not exist. Both `o_networkmanager/Other_69.gml` (separate handler group) and this `o_fullscreensystem/Other_69.gml` should lose their lobby cases; the other event types handled by the manager (`lobby_chat_update`, `lobby_join_requested`, `avatar_image_loaded`, `ugc_subscribe_item`) become registered callbacks (`steam_matchmaking_set_callback_lobby_chat_update`, `steam_friends_set_callback_game_lobby_join_requested`, etc.; names in `API` L22695, L13832).
- **Request identity** (replaces `_create_owned` / `net_join_pending_id`): give each call a context `{kind, serial}` (`net_create_serial`, `net_join_serial`). `net_discard_lobby_reply` needs no ambient "current lobby" any more: `steam_matchmaking_leave_lobby(_lobby_id)` takes the id (`API` L22984; 2.x `steam_lobby_leave()` had none), so discarding is `if (reply.lobby_id != 0 && entered) leave(reply.lobby_id)`. `tcc_steam_lobby_leave` wrapper must change signature.
- **Return values**: `net_host_lobby` L437-440 and `net_join_lobby` L453-457 test the bool returned by the 2.x call. In 3.0 nothing is returned (0.1). Replace with a pre-flight (`net_enabled()`, `steam_api_is_initialized()`) and a **deadline**: set `global.net_create_pending_at`/`net_join_pending_at` and clear the pending flag plus bump the serial if no reply within ~30 s (0.2). A late reply then arrives with an old serial and is treated as unexpected: it must still leave the lobby it entered (the one thing the old code got for free via `net_discard_lobby_reply`).
- **`game_restart` hazard (UNVERIFIED, must be tested)**: `net_game_restart()` (L323-326) deliberately keeps `global.*` state and the Steam lobby across `game_restart()`. The callback registry is a static `ds_map` inside `__ext_core_function_map()` and the dispatcher `time_source` is a static inside `__Steamworks_get_dispatcher()` (`CORE` L227-230, `API` L24758-24762). If statics are reinitialised by `game_restart` while a native completion is already queued, `__ext_core_function_dispatch_calls` finds no handle ("BAD PACKET ... continue", `CORE` L335) **without consuming that packet's argument bytes**, which can desynchronise the remaining packets of that frame. Test: create/join in flight + `net_game_restart`. Keep the deadline logic regardless.
- The comment at `scr_online_multiplayer.gml` L286 ("Clear only on their reply") and `net_tick`/`net_host_lobby` guards (`global.net_create_pending ...`) must be revisited together with the deadline.

---------------------------------------------------------------------------------------------------

## 3. `o_customlevelsbrowser` (Workshop browser: subscribed levels + browse tab)

`objects/o_customlevelsbrowser/`: `Create_0`, `Step_0`, `Draw_75`, `CleanUp_0`, `KeyPress_27`, `Other_69`. `persistent:false` (`.yy` L20). Only creator: `objects/o_customlevelsplay/Mouse_4.gml` L1-4 (guarded by `global.steam_api = true`).

### 3.1 Keys and event types read (Other_69.gml)
Common: `event_type` (L4), `id` (L5), `result` (L6) with `ugc_result_success`. Three branches, in order, each distinguished only by id (branches B and C have **no** `event_type` check):
- **A (L9-91)**: `event_type == "ugc_query" && id == browse_query_id`. Keys: `result`, `num_results` (read, unused), `total_matching` (L12), `results_list` (ds_list of ds_maps, L19). Per item (`OLD/old_ugc.txt` L1233-1300 for the 2.x schema): `published_file_id`, `title`, `steam_id_owner`, `votes_up`, `votes_down`, `banned`, `handle_preview_file`, `tags` (array or comma string, both parsed, L45-66).
- **B (L94-136)**: `ds_map_exists(async_details, id)`: reply to `steam_ugc_request_item_details` (2.x `event_type "ugc_item_details"`, `OLD/old_ugc.txt` L776-870). Keys: `result`, `title`, `steam_id_owner`, `votes_up`, `votes_down`, `banned`, `tags`.
- **C (L139-159)**: `ds_map_exists(async_names, id)`: reply to `steam_get_user_persona_name` (2.x `event_type "user_persona_name"`, keys `id, steamid, persona_name`, `OLD/old_general.txt` L127-160). Key: `persona_name`.
Tag parsing (both array and string forms) maps `Easy..Impossible` -> difficulty 1-6 and `Level of the Week` -> featured. In 3.0 tags always arrive as a comma-separated string (`SteamUgcQueryResult.tags`, `DOC3/ugc.js` L1570+), so the `is_array` branches are dead.

### 3.2 State changed
- A success: `browse_total` (L12); if `browse_page = 1`: `browse_levels = []`, `browse_count = 0` (L14-17); appends one `lvl` struct per result to `browse_levels[browse_count++]` (L24-83), where `lvl` fields: `file_id, path "", title, owner_name "Unknown", owner_id, likes, dislikes, tags "", difficulty, banned, featured, loaded true, thumb_spr -1, thumb_checked true, thumb_handle, thumb_downloading false, medal_time 9999999, medal_required 999999, download_state` (L24-43, L69-75); `async_names[? request] = "browse:" + index` (L78-79); `browse_state = "loaded"` (L86); `exit` (L90). `thumb_handle` is stored but never read anywhere (grep of `thumb_handle` in `objects scripts`: only this write), browse tiles always show "No Preview" (thumb_checked is already true, path is "").
- A failure (`result != success`): `browse_state = "error"` only (L88). `Draw_75.gml` draws nothing for `error` (grep: only `loading` L113 and `loaded` L298/L336 are drawn), and Load More / auto-load require `loaded` / `idle` (`Step_0.gml` L108, L188), so the tab is a blank grid until the user presses Enter in the search box (`Step_0.gml` L28-38 always re-sends).
- B success: mutates the existing `levels[_idx]` struct in place: `title, owner_id, likes, dislikes, banned, loaded true`, `difficulty`/`featured` from tags; requests the owner name and records `async_names[? req] = "sub:" + idx` (L129-131). B failure: nothing is applied (level keeps `title "Loading..."`, `loaded false`, `owner_name "Unknown"`, set in `Create_0.gml` L82-91). B always `ds_map_delete(async_details, id)` and `exit` (L134-135).
- C: sets `levels[idx].owner_name` or `browse_levels[idx].owner_name` if `idx` is in range of `levels_count` / `browse_count` (L147-154), then `ds_map_delete(async_names, id)` (L158). A non-string or missing `persona_name` leaves the name "Unknown" but still removes the map entry.
- Sync helper calls inside the handler (L69-75): `ds_map_create()` + `tcc_steam_ugc_get_item_update_info(file_id, info)` + `ds_map_destroy(info)` per result for `download_state`.

### 3.3 Initiators
- Subscribed detail queries: `Create_0.gml` L62-138. For each subscribed item that has an installed, valid level folder: `req_id = tcc_steam_ugc_request_item_details(file_id, 30)` (L122, wrapper `scr_steam_safe.gml` L262-265); `async_details[? req_id] = j` (L123). Up to N requests at once, one per level.
- Browse query: `send_browse_query` (`Create_0.gml` L52-59): `qh = tcc_steam_ugc_create_query_all(ugc_query_RankedByVote, ugc_match_Items, browse_page)`, optional `tcc_steam_ugc_query_set_search_text(qh, text)`, `browse_query_id = tcc_steam_ugc_send_query(qh)`; `browse_state = "loading"` is set first (L53). Triggered from: search Enter (`Step_0.gml` L28-38, always allowed, resets page, arrays, scroll), tab switch when `browse_state == "idle"` (L106-111), Load More when `loaded && browse_count < browse_total` (L188-194, `browse_page++`).
- Persona names: requested inside the handler, per result (A L78, B L130), `tcc_steam_get_user_persona_name(owner_id)` (`scr_steam_safe.gml` L82-85).
- Other Steam calls on this object that stay synchronous and are unaffected by the callback change: `tcc_steam_ugc_get_item_update_info` (Step L142, L208, L225; poll every 60 frames L198-231), `tcc_steam_ugc_subscribe_item` (Step L181, no reply consumed here: the tile just flips to `pending` optimistically).

### 3.4 Resources created / destroyed
- `async_details`, `async_names` ds_maps: created Create_0 L38-39, destroyed CleanUp_0 L17-18. Entries are removed when answered; unanswered entries remain until CleanUp.
- Per-result temporary `info` ds_map created/destroyed in the same iteration.
- Query handle `qh` from `create_query_all`: never released by the object. 2.x released it itself before delivering the event (the project already says so for the same call: `scr_workshopER.gml` L338-339, "Steam releases the query itself before delivering this callback").
- `results_list` and the item maps are owned by `async_load`; the handler does not destroy them.
- Sprites: CleanUp_0 L3-14 deletes `thumb_spr` of loaded levels.
- Instance ends: close button (`Step_0.gml` L77-80), Esc (`KeyPress_27.gml` L9), playing a level (`Step_0.gml` L174-175).

### 3.5 Error / empty behaviour (complete)
| Case | Result |
|---|---|
| Steam off | exit (L1) |
| Browse reply, success, `results_list` undefined or 0 results | `browse_state = "loaded"`, page 1: arrays emptied; page > 1: unchanged; status line prints `count / total` (Draw L336-338); no "no results" message |
| Browse reply failure | `browse_state = "error"`, no UI, no retry except Enter |
| Browse reply with a different id (superseded search) | falls through to branches B/C, matches neither, ignored (fully correct staleness handling) |
| Detail reply failure | map entry deleted, level stays "Loading..." |
| Detail reply `_idx` out of range | ignored (still deletes entry) |
| Persona reply `persona_name` undefined/non-string | owner stays "Unknown" |
| **Stale persona reply** | **bug present in 2.x**: key is `"browse:" + index` (L79), and the bounds check (L152) only tests `_idx < browse_count`. After a new search (`Step_0.gml` L31-35 reset `browse_levels`/`browse_count`), a still-in-flight name reply for the old result N is applied to the **new** result N (if `N < browse_count` by then). Not guarded by id/token |
| Duplicate request ids | none |

### 3.6 Restructure for 3.0
1. **Move the Steam calls and decoding into `scr_steam_safe`** and let the object consume plain structs (0.7). Suggested project-local shapes: `tcc_steam_ugc_browse_page(page, search, cb)` -> `{ok, total, items:[{file_id, title, owner_id, likes, dislikes, banned, tags_csv, preview_handle, state}]}`; `tcc_steam_ugc_details(ids, cb)` -> same item shape; `tcc_steam_ugc_item_state(id)` -> `{installed, downloading, pending}`; `tcc_steam_ugc_subscribe(id, cb)` -> `{ok, file_id}`; `tcc_steam_persona_name(id, cb)`.
2. **Browse query.** `steam_ugc_create_query_all_ugc_request(SteamUgcQuery.RankedByVote(0), SteamUgcMatchingUgcType.Items(0), creator_app_id, consumer_app_id, page)` -> query handle (`API` L16289; **both app ids are required**, "Either consumer or creator must be valid", `DOC3/ugc.js` L210-231; use `global.appid` for both). `steam_ugc_set_search_text(handle, text)` (L18082). Validate the returned handle before sending: the native returns `0` when the extension guard/interface fails (`SRC/gm_steam_ugc.cpp` L185-186) and otherwise the raw SDK value (`qh_to_u64`, L35-36, L197), which on failure is the SDK's all-ones invalid handle; the existing project code already tests `qh == 0 || qh == -1` (`scripts/scr_workshopER/scr_workshopER.gml` L84), and how an all-ones `buffer_u64` value reads back in GML (`-1` vs a huge real) is UNVERIFIED, so test for `0`, `-1` and `>= 2^63` / `== 18446744073709551615`. Sending an invalid handle means the callback never fires (0.2). `steam_ugc_send_query_ugc_request(handle, cb)` -> `SteamUgcQueryCompleted{query_handle, result, num_results_returned, total_matching_results, cached_data}` (`API` L17390; `DOC3/ugc.js` L1651-1660). `result` is `SteamApiResult` (`Ok = 1`; the old `ugc_result_success` constant is gone, check `identifiers.json`).
3. **Results are not in the struct.** In the callback loop `i < num_results_returned`: `steam_ugc_get_query_ugc_result(query_handle, i)` -> `SteamUgcQueryResult` (`API` L16635; fields `published_file_id, title, owner_steam_id, votes_up, votes_down, banned (bool), tags (CSV string), handle_preview_file, result`, `DOC3/ugc.js` L1570-1604) which returns `undefined` on failure; skip items whose own `result != Ok`. Then **`steam_ugc_release_query_ugc_request(query_handle)` in a `finally`-style position: on every path including stale, owner-gone, failed (`DOC3/ugc.js` L814-822; 3.0 does not release for you; `gm_steam_ugc.cpp` L1259-1268 only copies the handle).** Max page size is 50 (`DOC3/ugc.js` L218).
4. **Subscribed details.** Replace N x `request_item_details` with one `steam_ugc_create_query_ugc_details_request([ids])` (`API` L16331; single query for all subscribed ids; a 1000-item cap is documented, `DOC3/ugc.js` L233-244; whether that cap is also subject to the 50-results-per-page rule is UNVERIFIED, so send the details request **in batches of 50 ids** (one query per batch, each with its own token and release); then no level can stay "Loading..." because of an unknown page limit). The max-age argument (30 s) becomes `steam_ugc_set_allow_cached_response(handle, 30)` (`API` L17487). Match results to levels by `published_file_id` using a `string(file_id) -> index` lookup, **not** by response order or request id; `async_details` is no longer needed. Failed items (not returned, or their own `result != Ok`) stay "Loading..." as today.
5. **Persona names.** There is no async name request. Use `steam_friends_get_friend_persona_name(owner_id)` immediately; if `""`/`"[unknown]"`, call `steam_friends_request_user_information(owner_id, true)` (returns `true` when data must be fetched) and finish when the shared persona-state-change fan-out reports `Name` for that id (0.6). Key pending names **by owner id** (a set of owner ids waiting, applied to every level whose `owner_id` matches in whichever array is current) instead of by `"browse:index"`; that removes the stale-index bug (3.5).
6. **Install state** `tcc_steam_ugc_get_item_update_info(id, ds_map)` -> `steam_ugc_get_item_state(id)` bit flags (`SteamUgcItemState`: Subscribed 1, Installed 4, NeedsUpdate 8, Downloading 16, DownloadPending 32; `API` enum L783): `installed = state & 4`, `downloading = state & 16`, `pending = state & 32`. This removes the temporary ds_map in the handler and in Step. `tcc_steam_ugc_get_subscribed_items(ds_list)` becomes `steam_ugc_get_subscribed_items(max, false)` returning an array; `get_item_install_info` returns a struct `{size_on_disk, folder, timestamp}` (`DOC3/ugc.js` L1546+) (same wrapper group, other agents).
7. **Subscribe (browse tab).** `steam_ugc_subscribe_item(id, cb)` requires a callback (0.3); use it to correct the optimistic `download_state = "pending"` back to `not_installed` when `result != Ok` (new behaviour; today it stays "pending" for failures). `SteamUgcSubscribeItemResult{result, published_file_id}`. The success path still relies on the 60-frame poll.
8. **Lifetime hazards (all must be handled)**
   - *Instance destroyed with requests in flight* (close button L77-80, Esc `KeyPress_27`, level start L174-175). CleanUp_0 destroys `async_details`/`async_names`; a callback that still referenced them would raise a ds error. Callbacks must check `instance_exists(owner)` and a per-instance `session_token` that CleanUp invalidates, and must still release any query handle they receive.
   - *Superseded browse request.* Enter while loading is possible (L28-38). Use `browse_token` (bumped in `send_browse_query`); a stale reply must not touch `browse_levels`, `browse_count`, `browse_total` or `browse_state`, but must release its query handle. The old code got this from `id == browse_query_id`.
   - *Load More vs page-1 reset.* A page-2 reply that arrives after the user submitted a new search (page 1) is stale; same token rule.
   - *`browse_state` stuck in "loading"* when the reply is dropped (0.2). Add a deadline (e.g. 20-30 s, in Step_0 or a time source) that sets `error`, and draw an error/empty message (today none).
   - *Index validity.* `levels` is built synchronously in Create_0 and never reordered, so file-id lookup is safe for the instance lifetime; `browse_levels` is replaced on each new search, so never carry an index across a request.
   - *Both tabs share the persona fan-out*; unregister/ignore on destroy (0.6).

---------------------------------------------------------------------------------------------------

## 4. `o_workshopERloading` (persistent controller for Workshop Endless Run)

`objects/o_workshopERloading/`: `Create_0`, `Step_0`, `Draw_75`, `Other_69` (12 lines). `persistent:true` (`.yy` L18). Created by `workshopER_start` (`scripts/scr_workshopER/scr_workshopER.gml` L62-64), `scr_online_session.gml` L775 and L1002; destroyed by `workshopER_cleanup()` (`scr_workshopER.gml` L332-335) and `net_enter_begin()` (`scr_online_session.gml` L592). Instance vars: `target_file_id`, `state` ("idle" | "waiting"), `wait_frames`, `max_wait = 1800`, `poll_timer`, `dots` (`Create_0.gml`).

### 4.1 Keys and event types read
- L5-6: `event_type == "ugc_subscribe_item"`, `published_file_id`, `result`, only while `state == "waiting"`.
- Otherwise the whole map goes to `workshopER_handle_async_catalog(_async_load)` (`scr_workshopER.gml` L376-414), which through `workshopER_catalog_callback` (L340-374) reads: `event_type == "ugc_query"`, `id == global.workshopER_query_id`, `result`, `num_results`, `total_matching`, `results_list` (each item `result`, `published_file_id`). It is a pure function of globals; it ignores the instance.

### 4.2 State changed
- Subscribe-failure branch (L5-11): `state = "idle"`, `global.workshopER_loading = false`, `workshopER_skip_level()` (L262-288: removes `global.workshopER_current_file_id` from `workshopER_pool` and `workshopER_catalog_ids`, then `workshopERrandomlevel(true)` (re-picks, may start another subscribe/room change) or `workshopER_game_over()` (L291-313: submits scores, saves, `workshopER_cleanup()` which **destroys this very instance**, `room_goto(r_hardmodedeathroom)`)). So the handler can destroy itself mid-execution; Other_69 does `exit` right after (L10).
- Catalog branch (`workshopER_handle_async_catalog`): requires `global.endless == 1`, `global.endlessrunmode == 4`, `!global.workshopER_catalog_scan_done` (L377-379). On a matching event: `global.workshopER_query_id = -1`; failure or malformed -> `workshopER_catalog_scan_done = true`, return false; success -> append unique non-subscribed ids to `global.workshopER_catalog_ids` (dedupe with a temp ds_map `_seen` keyed by `string(id)` so adjacent Int64 ids stay distinct, L388-405, destroyed L404), then either `global.workshopER_query_page++` + `workshopER_query_catalog()` (issues the next page from inside the handler, L409-410) or `scan_done = true`.
- Not set here but relevant: the 30 s timeout and the download poll live in `Step_0.gml` (L17-22 timeout -> skip level; L24-49 poll `tcc_steam_ugc_get_item_update_info`/`get_item_install_info` and `workshopER_goto_level`).

### 4.3 Initiators
- Catalog query: `workshopER_query_catalog()` (`scr_workshopER.gml` L77-95: `create_query_all(ugc_query_RankedByPublicationDate, ugc_match_Items, global.workshopER_query_page)`, `send_query`), called from `workshopER_start` (L70), the handler itself for the next page, and `scr_online_session.gml` L779.
- Subscribe: `workshopER_pick_catalog_level` -> `tcc_steam_ugc_subscribe_item(file_id)` (L199, then switches this instance to `waiting` for `target_file_id`, L207-215), and `net_er_goto_workshop` -> `tcc_steam_ugc_subscribe_item(_file)` (`scr_online_session.gml` L999) + `waiting` (L1003-1010). The `net_ugc_request` family (L906, L915) also subscribes; that reply is consumed by `o_networkmanager` (`net_handle_async_steam` case `"ugc_subscribe_item"` L1139-1151), **not** here. Both objects therefore see the same broadcast reply in 2.x.

### 4.4 Resources
- Temp ds_map `_seen` created and destroyed inside `workshopER_handle_async_catalog`.
- No instance-owned ds structures. Globals (`workshopER_pool`, `catalog_ids`, `auto_subscribed`, query id/page) are reset by `workshopER_cleanup` (L316-336).
- The query handle (`qh`) is never released by project code (2.x did it).

### 4.5 Error / empty behaviour
- Subscribe reply with `result != success` for the current target while `waiting` -> skip level (avoids the 30 s wait for private/removed items; comment L4). Subscribe success: nothing (the Step poll continues). Stale target (different id) or `state != waiting`: falls through to the catalog handler, where `event_type` mismatch returns false.
- Catalog: wrong mode/`scan_done`/event type/id -> ignored and not consumed (L377-381); query failure or malformed counts (`> 50`, non-integer, `total < count`, nonempty without `results_list`) -> scan marked done, catalog unchanged, fall back to installed levels; empty successful page (`count == 0`) is terminal.
- No timeout for the catalog query itself: a lost reply leaves `scan_done == false` and `workshopER_query_id` set for the rest of the run (in 2.x a reply always came).
- The offline test `workshopER_catalog_selfcheck()` (L419-500, invoked from `scripts/scr_level_document/scr_level_document.gml` L937) builds synthetic `async_load` ds_maps and drives `workshopER_catalog_callback` / `workshopER_handle_async_catalog` directly. It must be rewritten with the handler.

### 4.6 Restructure for 3.0
1. **`Other_69.gml` goes away entirely**; its two jobs become two kinds of callbacks:
   - *Catalog scan*: `workshopER_query_catalog()` creates the query with `steam_ugc_create_query_all_ugc_request(SteamUgcQuery.RankedByPublicationDate (1), SteamUgcMatchingUgcType.Items, global.appid, global.appid, page)` and sends it with a **plain script callback** `workshopER_on_catalog_page(_ctx_serial, _r)` bound to a small context `{serial}`. State is already global, so it survives the loader instance (which `net_enter_begin` / `workshopER_cleanup` destroy); the guards on `global.endless`, `endlessrunmode == 4`, `scan_done` stay. Replace `global.workshopER_query_id` by `global.workshopER_query_serial` (bumped when a page is sent, when `workshopER_cleanup` runs and when the scan is abandoned); a reply whose serial differs is stale (replaces `_event[? "id"] != _request`). Mark `workshopER_query_id <= 0` checks (L89-92) as obsolete: replace by "was the handle valid and did the send call execute", plus a deadline (e.g. 20 s) that sets `scan_done = true`.
   - *Download wait / skip on private item*: pass a callback to every `steam_ugc_subscribe_item` (0.3). Because at least two modules need the reply (this loader for `target_file_id`; `net_handle_async_steam`'s `ugc_subscribe_item` case for `global.net_ugc_failed`), implement **one** `tcc_steam_ugc_subscribe(file_id, cb)` that invokes a shared listener list (workshopER and net) so both observe the same result; do not make each call site pass its own half-duplicate callback. The workshopER listener does exactly the old check: `instance_exists(o_workshopERloading) && o_workshopERloading.state == "waiting" && o_workshopERloading.target_file_id == r.published_file_id && r.result != SteamApiResult.Ok` -> `state = "idle"`, `global.workshopER_loading = false`, `workshopER_skip_level()`.
2. **Decode and release** the query result in `scr_steam_safe`: loop `steam_ugc_get_query_ugc_result(query_handle, i)` for `i < num_results_returned`, keep `published_file_id` (already a full-precision number) of items whose own `result == Ok`, then `steam_ugc_release_query_ugc_request(query_handle)` on all paths. Return `{ok, count, total, ids}` to `workshopER_handle_async_catalog` (keeps its pagination/dedupe logic unchanged). Splitting I/O from logic also makes the self-check feasible: feed synthetic `{ok,count,total,ids}` structs into the pure part instead of fake `async_load` maps; the existing cases (stale serial, wrong mode, duplicate completion, failed request, empty page, adjacent Int64 ids, "callback after leaving Endless") map one-to-one. The self-check call in `scr_level_document.gml` L937 stays.
3. **Lifetime hazards**
   - *Loader destroyed before the callback* (cleanup at run end `workshopER_cleanup`, `net_enter_begin`): subscribe-failure listener must check `instance_exists(o_workshopERloading)` (and not use a method bound to the destroyed instance); catalog callback does not need the instance at all but must be invalidated by the serial bump in `workshopER_cleanup` (today `workshopER_cleanup` sets `workshopER_query_id = -1` L327 and the mode guards do the rest).
   - *Room change mid-request*: neither callback depends on the room; `workshopER_skip_level` is room-safe because `o_workshopERloading` is persistent.
   - *Request re-issue before reply*: catalog pages are strictly sequential (the next page is sent only from the handler of the previous one), plus `net_enter...`'s extra call at `scr_online_session.gml` L779 could overlap with a still-running scan from the previous run; the serial bump on `workshopER_start`/`net_enter_*` makes the earlier reply stale. Subscribe for target A then target B (retry after skip): A's late failure reply must not skip B; the existing `published_file_id == target_file_id` test already covers it and must be kept in 3.0.
   - *Self-destruction inside a callback*: `workshopER_skip_level` -> `workshopER_game_over` -> `workshopER_cleanup` destroys the loader; fine as the last action of the callback, but nothing after it may touch `self`.
   - *Deadlines*: catalog query (above); the subscribe/download wait already has the 30 s `max_wait` in Step_0.
4. `ugc_result_success` becomes `SteamApiResult.Ok`. `target_file_id` comparison stays number vs number.

---------------------------------------------------------------------------------------------------

## 5. `o_publishworkshopchallenge` (publish a Workshop Challenge)

`objects/o_publishworkshopchallenge/`: `Create_0`, `Step_0`, `Draw_0`, `Other_69`. `persistent:false` (`.yy` L18). Only creator: `objects/o_workshopchallengecreatorbutton/Mouse_4.gml` L122-124 (after the beat-signature check at L117-119; `if !instance_exists(o_publishworkshopchallenge)`). Also observed: `scr_online_session.gml` L509 refuses room-follow while it exists.

### 5.1 Keys and event types read
`tcc_steam_initialised()` (L1), `id` (L2), `event_type` (L3). Two branches (2.x docs: `OLD/old_ugc.txt` L195-225 `ugc_create_item`, L532-560 `ugc_update_item`):
- `type == "ugc_create_item" && id == create_request` (L5): keys `legal_agreement_required` (L6), `result` (L12), `published_file_id` (L18).
- `type == "ugc_update_item" && id == submit_request` (L37): keys `legal_agreement_required` (L38), `result` (L44).
Nothing else is read; other events are ignored by falling through.

### 5.2 State changed (instance variables unless noted)
`result` is the UI state used by Draw_0 (0.1 "Preparing", 0.5 "Uploading", 1 published, 2 legal agreement, 3 not logged on, 4 failed; default "Uploading...", `Draw_0.gml` L8-28) and `timer` is a frame countdown after which `Step_0.gml` L7-12 destroys the instance.
- Create reply: legal required -> `result = 2; timer = 600`, exit (L6-11). `result != success` -> `result = 4; timer = 600`, exit (L12-17). Success -> `published_file_id` set (L18); builds the update: `update_handle = tcc_steam_ugc_start_item_update(global.appid, published_file_id)` (L20), `set_item_title`, `set_item_description`, `set_item_visibility(ugc_visibility_public)`, `set_item_tags(update_handle, ["Challenges"])` (array built L24-26), `set_item_preview(preview_path)` only if the file exists (L27-29), `set_item_content(content_dir)` (L30); `submit_request = tcc_steam_ugc_submit_item_update(update_handle, "Initial upload")` (L32); `result = 0.5` (L33).
- Submit reply: legal required -> `result = 2; timer = 600` (L38-43). Success -> `result = 1; timer = 900`; **globals**: `global.workshopchallenge_beaten_signature = ""` and `scr_workshopchallenge_save_progress()` (L45-50), i.e. the one-time "beat the challenge first" gate is consumed only on a confirmed upload. Failure -> `result = 4; timer = 600` (L51-54).
- Not handled: no check that `update_handle` or the individual setters succeeded (the wrappers return `-1` / `false` when Steam is off, `scr_steam_safe.gml` L294-296), no handling of `result` other than `Ok`.

### 5.3 Initiators
- `Create_0.gml` L16-30: early `result = 3/4; timer = 600; exit` when `!global.steam_api`, not logged on (`tcc_steam_is_user_logged_on()` L21) or no draft; otherwise writes `challenge.json`, renders `preview.png` from the first level's thumbnail (L81-157), builds the description (L160-173), then `create_request = tcc_steam_ugc_create_item(global.appid, ugc_filetype_community)` (L176, wrapper `scr_steam_safe.gml` L230-233) and `result = 0.1` (L177). `global.appid = tcc_steam_get_app_id()` is set in `objects/o_title/Create_0.gml` L28.
- Second request created inside the first handler (submit, L32). Mouse event creates the object only if none exists.

### 5.4 Resources
- The handler creates no ds structures. `Create_0.gml` frees its own temporary `wrapper` ds_map/list (L53-78) and thumbnail sprite/surface (L109-157).
- Server-side side effects that outlive the instance: the empty Workshop item created by the first call, then its upload. Neither is rolled back anywhere.
- `update_handle` is a plain number; no release call exists/needed.

### 5.5 Error / empty behaviour and pre-existing gaps
| Case | Behaviour |
|---|---|
| Steam off / not logged on / no draft | Create_0 sets `result` 3/4 with `timer = 600`; no request issued; Other_69 returns at L1 if Steam off |
| Create reply: legal agreement required | `result = 2` ("Legal agreement required..."). The reply carries a `published_file_id`, i.e. the Steam item exists (empty); the code exits before using it, so it is orphaned, no cleanup (Steamworks keeps such an item hidden until the agreement is accepted: UNVERIFIED here) |
| Create reply: failure | `result = 4` |
| Submit reply: legal agreement required | `result = 2` and the beat gate is **not** cleared. By Steamworks semantics (not restated in the extension docs; UNVERIFIED here) the content is uploaded but the item stays hidden until the agreement is accepted, so the UI reports a state that the user can fix in Steam, while the old code treats it like a failure for gate purposes |
| Submit reply: failure | `result = 4`; the empty item created in step 1 remains orphaned |
| Escape at any time | `Step_0.gml` L2-5 destroys the instance. The two requests continue server-side; replies are ignored via id mismatch for the next instance, or never delivered; the upload may succeed but the beat gate is never cleared (user could publish again as a duplicate) |
| No reply ever | `timer == 0` while `result` is 0.1/0.5, so the overlay never expires (only Escape) and `net_follow_can_enter` keeps refusing |
| Stale replies | ignored by `event_id == create_request` / `submit_request` (ids unique per request) |

### 5.6 Restructure for 3.0
1. **Create**: `steam_ugc_create_item(global.appid, SteamRemoteStorageWorkshopFileType.Community, cb)` -> `SteamUgcCreateItemResult{result, published_file_id, legal_agreement_required}` (`API` L16253; `DOC3/ugc.js` L190-207, L1665-1675). Replaces `ugc_filetype_community`.
2. **Update**: `steam_ugc_start_item_update(app, id)` -> handle (L18193); `steam_ugc_set_item_title/description/visibility(SteamRemoteStoragePublishedFileVisibility.Public (0))/preview/content` same shape; **`steam_ugc_set_item_tags(handle, csv)` takes a CSV string** (`API` L17642), not an array: `"Challenges"`. `steam_ugc_submit_item_update(handle, note, cb)` -> `SteamUgcSubmitItemUpdateResult{result, legal_agreement_required}` (`API` L18310; `DOC3/ugc.js` L1360-1378, L1677-1686). The result has no `published_file_id`, so keep the one from step 1 in the context.
3. **Request token and context**: the whole flow is a two-callback chain; bind one context `{owner, token, published_file_id, update_handle, stage}` and reuse it for both (0.5). On each callback: `instance_exists(owner)` and `owner.token == token`. The context (not the instance) carries `published_file_id`/`update_handle` from stage 1 to stage 2, which removes the dependence on instance variables between the two callbacks.
4. **Fix the destroyed-owner case deliberately** (decision needed): if the instance is gone when the *submit* reply arrives with `result == Ok`, the upload really happened. Safer 3.0 behaviour: apply the global effects regardless of the owner (`global.workshopchallenge_beaten_signature = ""; scr_workshopchallenge_save_progress()`), then update the UI only if the owner still exists. If the owner is gone at stage 1 (before submit was issued), do not continue to stage 2 (otherwise an upload nobody asked for would run), and consider deleting the empty item (`steam_ugc_delete_item`, `API` L16418) or at least log it. Same for legal-agreement and failure results (orphaned item cleanup is optional but should be an explicit choice).
5. **Deadlines**: add an upload deadline (e.g. 60-120 s per stage) that sets `result = 4; timer = 600`, and bump the token so a late reply is stale. Optional progress: `steam_ugc_get_item_update_progress(handle)` -> `{status, bytes_processed, bytes_total}` (`API` L16583) can drive Draw_0 instead of the static "Uploading...".
6. **Re-issue**: only one instance can exist at a time (`Mouse_4.gml` L122), so overlap occurs only across destroy + re-create. Escape then re-publish while the first chain is still running produces two chains; with the token each chain only updates its own instance; the stage-2 global effect (4) would be applied by whichever succeeds. De-duplicate with a global `workshopchallenge_publish_serial` if a duplicate item must be prevented.
7. `legal_agreement_required` is checked before `result` in both stages in the old code; keep that order.
8. Wrapper changes needed in `scr_steam_safe`: `tcc_steam_ugc_create_item`, `submit_item_update`, `set_item_tags` (array -> CSV), `start_item_update` return `-1` on failure paths (the native returns `0` from its guard/interface checks and otherwise the raw SDK update handle, `SRC/gm_steam_ugc.cpp` L1203-1212, whose invalid value is all-ones; treat `0`, `-1` and the all-ones value as failure, same UNVERIFIED read-back question as for query handles), and callback parameters (0.3).

---------------------------------------------------------------------------------------------------

## 6. Summary tables

### 6.1 Request/reply map

| Handler | Request (caller) | 2.x reply (event_type / keys) | 3.0 replacement |
|---|---|---|---|
| mini leaderboard | `tcc_steam_download_scores_around_user` in `reloadleaderboardsmini()` (Create L89, Alarm_0, reload button) | `leaderboard_download`/`leaderboard_not_found`; `entries` JSON | `steam_userstats_find_leaderboard` then `steam_userstats_download_leaderboard_entries(GlobalAroundUser)`; read rows via `steam_userstats_downloaded_leaderboard_entry` |
| mini avatars | `tcc_steam_get_user_avatar` per row | `avatar_image_loaded` {success,user_id,image} | `steam_friends_get_small_friend_avatar`; `steam_friends_request_user_information`; `steam_friends_set_callback_avatar_image_loaded` (large only) / persona-state-change `Avatar` |
| fullscreensystem | `tcc_steam_lobby_create`, `tcc_steam_lobby_join_id` (`scr_online_multiplayer.gml` L437, L453) | `lobby_created`/`lobby_joined` {success, lobby_id} | `steam_matchmaking_create_lobby`/`join_lobby` + callback; delete the event |
| browser browse | `send_browse_query` (Create L52; Step L37/L110/L193) | `ugc_query` {result,total_matching,num_results,results_list} | `steam_ugc_create_query_all_ugc_request` + `send_query_ugc_request` + `get_query_ugc_result` + `release_query_ugc_request` |
| browser details | `tcc_steam_ugc_request_item_details` (Create L122) | `ugc_item_details` | `steam_ugc_create_query_ugc_details_request([ids])` |
| browser/others names | `tcc_steam_get_user_persona_name` | `user_persona_name` {persona_name} | `steam_friends_get_friend_persona_name` + `request_user_information` + persona-state-change |
| workshopER catalog | `workshopER_query_catalog` | `ugc_query` | as browse; global serial instead of id |
| workshopER subscribe | `tcc_steam_ugc_subscribe_item` (scr_workshopER L199, scr_online_session L999) | `ugc_subscribe_item` {published_file_id,result} | `steam_ugc_subscribe_item(id, cb)` -> `SteamUgcSubscribeItemResult`; one shared listener list with the net module |
| publish challenge | `tcc_steam_ugc_create_item` (Create L176), `tcc_steam_ugc_submit_item_update` (Other_69 L32) | `ugc_create_item`, `ugc_update_item` | `steam_ugc_create_item(app, Community, cb)`, `steam_ugc_submit_item_update(h, note, cb)` |

### 6.2 Cross-cutting must-dos before/while porting these five
1. Add `steam_api_run_callbacks()` to the persistent host (`o_fullscreensystem` Step, where `tcc_steam_update()` is now) and decide whether it sits before the `timing_instance_step()` gate.
2. In `scr_steam_safe`: callback-defaulting wrappers; project-local result structs; query-handle release; leaderboard handle cache + serialised downloads; shared fan-out for avatar/persona/subscribe replies; central request registry with deadlines.
3. Replace every id-based match with token + owner/liveness checks; add deadlines to all pending states in 0.2.
4. Delete the five `Other_69.gml` events (and their `.yy` event entries) once their logic is moved; add a CleanUp event to `o_onlineleaderboardsmini`.
5. Update `tools/check_port.py` L78-79 for the new prefixes; port `workshopER_catalog_selfcheck`.

### 6.3 Open questions / UNVERIFIED items
- **`ptr()` distinctness for `method(ctx, fn)` values (0.5 caveat): decides whether the per-request context pattern is safe; needs the two-overlapping-requests smoke test, otherwise use the key-matching fallback.**
- Runtime behaviour of calling a GML method bound to a destroyed instance (avoid; use struct-bound methods).
- `game_restart` effect on `CORE` statics (`__ext_core_function_map`, dispatcher `time_source`), see 2.6.
- Whether two leaderboard downloads completing in the same pump invalidate the earlier `entries_handle` (1.6 item 3).
- Whether pending small avatars ever raise `AvatarImageLoaded` (docs say large only).
- `json_decode(undefined)` / `json_decode("")` behaviour in the 2.x handlers (only matters for understanding old behaviour).
- Exact page limit of `steam_ugc_create_query_ugc_details_request` against the 50-per-page rule (mitigated by sending batches of 50, 3.6 item 4).
- Whether the 3.0 persona-state-change callback fires for names of leaderboard/UGC users that are not friends without a prior `request_user_information` (docs say users on leaderboards are "known"; names for UGC owners are not documented as automatically known).

### 6.4 2.x constants used by these five handlers and their 3.0 replacements
`identifiers.json` only inventories `steam_*` names; the `ugc_*` / `lb_*` constants are not in it, but all ten below exist in the 2.x extension (`port/old2x/Steamworks.yy`) and none exists in `API` (grep: not found), so each is **old-only** and must be replaced. Numeric values are identical in all pairs (read from the old `.yy`).

| 2.x constant (old value) | Used in | 3.0 replacement (`API` line) |
|---|---|---|
| `steam_user_avatar_size_small` (0; identifiers.json: old-only, 2 files: `o_onlineleaderboards/Create_0.gml`, `o_onlineleaderboardsmini/Create_0.gml`) | mini Create_0 L9 | no size argument: call `steam_friends_get_small_friend_avatar` / `_medium_` / `_large_friend_avatar` (L13457 / L13371 / L13351) |
| `ugc_result_success` (1) | browser Other_69 L10/L95, workshopER Other_69 L6, publish Other_69 L13/L45, `scr_workshopER.gml` | `SteamApiResult.Ok` (1) (`API` L314-316) |
| `ugc_filetype_community` (0) | publish Create_0 L176 | `SteamRemoteStorageWorkshopFileType.Community` (0) (`API` L1502) |
| `ugc_visibility_public` (0) | publish Other_69 L23 | `SteamRemoteStoragePublishedFileVisibility.Public` (0) (`API` L766) |
| `ugc_query_RankedByVote` (0) | browser Create_0 L54 | `SteamUgcQuery.RankedByVote` (0) (`API` L707) |
| `ugc_query_RankedByPublicationDate` (1) | `scr_workshopER.gml` L83 | `SteamUgcQuery.RankedByPublicationDate` (1) |
| `ugc_match_Items` (0) | browser Create_0 L54, `scr_workshopER.gml` L83 | `SteamUgcMatchingUgcType.Items` (0) (`API` L689) |
| `steam_lobby_type_friends_only` (1; identifiers.json: old-only, 1 file) | `scr_online_multiplayer.gml` L437 | `SteamMatchmakingLobbyType.FriendsOnly` (1) (`API` L1522) |
| `lb_sort_ascending` (1) | `scr_saveworkshopmedals.gml` L19, `o_onlineleaderboardCH/Create_0.gml` L4 | `SteamLeaderboardSortMethod.Ascending` (1) (`API` L1428) |
| `lb_disp_time_ms` (3) | same two files | `SteamLeaderboardDisplayType.TimeMilliSeconds` (3) (`API` L1435) |

### 6.5 API-name verification pass
Every 3.0-style function name cited in this document was checked against `API` as either `^function <name>(` or a `Skipping function <name>` line; the result is recorded at the end of this file (section 7).

---------------------------------------------------------------------------------------------------

## 7. Result of the API-name verification pass (never invent API)

Method: every token matching `steam_[a-z0-9_]+` in this file (58 distinct) was looked up in `scripts/Steamworks_API/Steamworks_API.gml` as `^function <name>(` or `Skipping function <name>`. 35 are real 3.0 functions (found). The 23 not found are all accounted for and none is presented in this document as a 3.0 function:

- Old (2.x) functions/constants, deliberately cited as the thing being replaced: `steam_get_user_persona_name` (replaced by sync `steam_friends_get_friend_persona_name` + `steam_friends_request_user_information` + the persona-state-change callback), `steam_lobby_leave` (replaced by `steam_matchmaking_leave_lobby(lobby_id)`, `API` L22984), `steam_ugc_request_item_details` (replaced by `steam_ugc_create_query_ugc_details_request`), `steam_user_avatar_size_small`, `steam_lobby_type_friends_only` (section 6.4).
- Project-local identifiers: `steam_image_create_sprite` (method defined in `o_onlineleaderboardsmini/Create_0.gml`), `steam_name`/`steam_rank`/`steam_score`/`steam_userid` (instance arrays), `global.steam_api`.
- Native C++ names from `SRC` (not GML): `steam_async` (namespace), `steam_async_common` (header), `steam_set_last_error`.
- Struct field names, not functions: `steam_id_64` (`SteamFriendsAvatarImageLoaded`), `steam_id_user` (`SteamUserStatsDownloadedLeaderboardEntry`), `steam_id_owner` (2.x event key).
- Prefix fragments in prose: `steam_friends_`, `steam_matchmaking_`, `steam_ugc_`, `steam_userstats_`, `steam_utils_`; and the sketch placeholder `steam_x` in section 0.5.

Capitalised struct/enum names cited (e.g. `SteamUgcQueryResult`, `SteamMatchmakingChatRoomEnterResponse`, `SteamFriendsPersonaChange`, `SteamLeaderboardDataRequest`) were verified in `API` as `function Name() constructor` or `enum Name`; the only two tokens not found are `SteamStruct` (C++ template parameter name) and `Steamworks` (the extension name).

Not found anywhere in `API` or the 3.0 docs (and therefore not assumed to exist): a function returning an async request id; a leaderboard entry field containing a persona name; a leaderboard "not found" event (replaced by `leaderboard_found == false`); a success flag on `SteamFriendsAvatarImageLoaded`; any `results_list`-style array on `SteamUgcQueryCompleted`.
