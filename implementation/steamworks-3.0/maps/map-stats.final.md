# Steamworks 2.1.6 -> 3.0.0 migration map (FINAL): leaderboards / achievements / stats / player counts

Resolver output. Supersedes `map-stats.md`. All 17 verifier disputes were checked against the sources; the outcome of each is in section 9 (decisions).
Everything in this file is derived from files that were read, nothing from memory.

Scope: `steam_create_leaderboard`, `steam_download_scores`, `steam_download_scores_around_user`, `steam_download_friends_scores`,
`steam_upload_score_ext`, `steam_set_achievement`, `steam_get_achievement`, `steam_reset_all_stats_achievements`,
`steam_get_number_of_current_players`, the `lb_sort_*` / `lb_disp_*` constants, every stat function (none are used), and the Other_69
handlers that consume them.

Evidence conventions (all absolute paths are under `/Users/infi/Documents/Github/TheColorfulCreature` unless stated):
- `API.gml` = `scripts/Steamworks_API/Steamworks_API.gml`.
- `yy` = `extensions/Steamworks/Steamworks.yy`.
- `new-cpp` = `extensions/Steamworks/source/src/` (native source of the installed 3.0 binary). `new-native` = `extensions/Steamworks/source/code_gen/native/SteamworksInternal_native.cpp`.
- `old-cpp` = `<scratchpad>/port/old2x_cpp/steam_userstats.cpp`, extracted from `git show HEAD:extensions/Steamworks/steamworks_cpp/GMLSteam/steam_userstats.cpp` (the real 2.1.6 implementation).
  `old-init` = `<scratchpad>/port/old2x_cpp/steam_init_new.cpp`, from `git show HEAD:extensions/Steamworks/steamworks_cpp/GMLSteam/steam_init_new.cpp` (saved by the resolver; it IS in git HEAD, the verifier only searched the scratchpad).
- `docs3` = `<scratchpad>/gmext/src/docs/userstats.js`. `<scratchpad>` = `<scratchpad>`.

---------------------------------------------------------------------------------------------------

## 0. The things that break silently (read this first)

1. **Achievements are no longer persisted or shown automatically.** 2.x `steam_set_achievement` did `SetAchievement` and, only when that returned true, set `m_bStoreStats` (old-cpp 1171-1175).
   `steam_update()` is `SteamAPI_RunCallbacks(); Steam_UserStats_Process();` (old-init 22-37), and `Steam_UserStats_Process` called `StoreStats()` and retried until it succeeded (old-cpp 1973-1986; `m_bStoringStats` is never set to true, 54/1942/2003).
   3.0 `steam_userstats_set_achievement` only calls `SetAchievement` (new-cpp gm_steam_userstats.cpp:130-139). Without a later `steam_userstats_store_stats()` there is **no overlay popup and nothing reaches the server until the game exits** (docs3:151: store_stats is called automatically at process end).
   `tcc_steam_update()` (`scripts/scr_steam_safe/scr_steam_safe.gml:310`, called from `objects/o_fullscreensystem/Step_0.gml:4`) must gain a dirty-flag flush in addition to `steam_api_run_callbacks()`.
2. **No result of this domain arrives unless `steam_api_run_callbacks()` runs every frame** (`getting_started.md` "Running the callbacks"; new-cpp gm_steam_api.cpp:300). Today that is `tcc_steam_update()` -> `steam_update()`. Owned by the init/update agent, but every entry below depends on it.
3. **No async id any more, and the return value is meaningless.** The five async functions (`find_or_create_leaderboard`, `find_leaderboard`, `download_leaderboard_entries`, `upload_leaderboard_score`, `number_of_current_players`) return **`0` (a Real) when the extension is present** and `undefined` only through the wrapper's `if (!__available__) return;` (API.gml:19783, 19811, 19942, 20065, 20119; the natives all end in `return 0;`: new-native 4459, 4473, 4549, 4607, 4635). A failed dispatch (`k_uAPICallInvalid`) also yields `0`. **Never use the return value as a success flag and never write `is_undefined()` checks on it.** `getting_started.md:59` says only "return nothing useful".
   `score_get = tcc_steam_download_scores(...)` + `async_load[? "id"] == score_get` stale-response filtering is gone and must be replaced by a request token captured in the callback. Quick left/right presses in `o_onlineleaderboards` would otherwise let a stale board overwrite the current one.
4. **IO failure = callback never fires for find / download / upload / player count** (`steam_async_common.h:11-40`: `ReportIoFailure` defaults to `false`, the result is dropped and the handler deleted). Only **four** calls set `ReportIoFailure=true`: `request_user_stats` (new-cpp gm_steam_userstats.cpp:693), `attach_leaderboard_ugc` (:858-862), `request_global_achievement_percentages` (:900), `request_global_stats` (:918). This project uses none of them.
   2.x behaviour was mixed: a **find/create** IO failure was retried silently with no event (old-cpp 346-361), whereas **download**, **upload** and **player count** DID deliver a failure event (`status=1` at 977-990, `success=0` at 523-570, `success=false,players=0` at 1111-1128). So "busy" flags and "LOADING" rows can now stick forever unless a watchdog exists. A call that fails to dispatch, or runs while Steam is not initialised (`STEAM_GUARD`), also never calls back (new-cpp gm_steam_userstats.cpp:708-880).
   `STEAM_GUARD` clears the last error at the start of every guarded call (`GMSteamworks.h:59-67`), so `steam_api_last_error()` only describes the most recent guarded call: read it immediately after the call you care about, before any other `steam_*` extension call.
5. **Callbacks are bound to whatever `self` the function literal was created in** and run later through `with (_dummy_context) method_call(...)` (`scripts/ExtensionCore_api/ExtensionCore_api.gml`, `__ext_core_function_dispatch_calls`). The leaderboard/settings objects are non-persistent and the mini board can destroy itself, so a plain `function(_r){...}` in an instance event can fire after its instance is gone. Use struct-bound closures (`method({owner:id, req:token}, function(_r){ if (!instance_exists(owner)) return; ... })`), the same pattern `scr_platform_services.gml:240 and :264` already uses. (What GameMaker does when calling a method bound to a destroyed instance was not verified; do not rely on it.)
6. **Callback and array arguments are mandatory and type-checked with `show_error(..., true)` (abort).** `_callback` must satisfy `is_callable`, `_score_details` must be an array (`[]`), `_leaderboard_handle` must satisfy `is_numeric` (API.gml:19752-19783, 19909-19942, 20026-20065). **Only `undefined` or a non-number aborts the game.** A handle of `0` (what `leaderboard_found == false` yields, API.gml:9097 decode) IS numeric, passes the GML guard and goes straight to Steam (new-cpp gm_steam_userstats.cpp:740-765 has no handle check); the outcome (invalid call and therefore no callback, or an empty/failed result) is not verified. Either way: **check `leaderboard_found` before download/upload**; the reason is a silent stall, not a hard error.
7. **`force_update` bool != enum.** `SteamLeaderboardUploadScoreMethod` is `None=0, KeepBest=1, ForceUpdate=2` (API.gml:1442-1447). `is_numeric(true/false)` passes and the number is cast straight into the Steam enum (new-cpp gm_steam_userstats.cpp:822). Passing the old bool therefore maps **false -> `None` (0, an invalid value) and true -> `KeepBest`**: every non-forced upload is wrong, not only the forced ones. Always write `_force ? SteamLeaderboardUploadScoreMethod.ForceUpdate : SteamLeaderboardUploadScoreMethod.KeepBest`.
   (Note: the 3.0 docs describe the members wrongly, `KeepBest "The top-score is the lowest number"`, `ForceUpdate "The top-score is the highest number"`, docs3:1088-1089; that is copy-pasted from the sort-method enum. The numeric cast is what counts.)
8. **Leaderboard entries no longer carry the player name.** 2.x built a JSON with `name = SteamFriends()->GetFriendPersonaName(id)` (old-cpp 1013-1015). 3.0 gives `steam_id_user` only; resolve the name with `steam_friends_get_friend_persona_name(steam_id_user)` (API.gml:13158). `o_settings` finds the player's own cog rank by comparing names, so this matters.
9. **`lb_sort_*` / `lb_disp_*` constants no longer exist** (0 hits in yy and API.gml). Two call sites will not compile (`objects/o_onlineleaderboardCH/Create_0.gml:4` (orphan, never compiled), `scripts/scr_saveworkshopmedals/scr_saveworkshopmedals.gml:19`).
10. **`steam_userstats_get_achievement` can return `undefined`** (extension missing, name unknown, or stats unavailable; new-cpp gm_steam_userstats.cpp:112-128 returns `nullopt`). 2.x returned `0` (old-cpp 1184-1210). `achievement_earned()` is evaluated in `draw_achievement` every Draw frame (`scripts/draw_achievement/draw_achievement.gml:8,51`) as `!achievement_earned(stat)`. Normalise to a real bool.
11. **Direct-native functions have no `extension_exists` guard.** `steam_userstats_set_achievement`, `_clear_achievement`, `_store_stats`, `_reset_all_stats`, `_set_stat_*` are emitted as "Skipping function ... (no wrapper is required)" (API.gml:19485-19550, 19743), i.e. raw extension functions returning **Real (1/0)**, not Bool, and they do not exist on iOS/Android/Mac App Store builds (`tools/check_port.py:22-23` asserts `copyToTargets == '0'`). The `platform_steam() && steam_api_is_initialized()` guard in the tcc wrappers is mandatory.
12. **Behaviour change (deliberate): forced uploads now force on first use.** 2.x only honoured `force_update` when the board's handle was already cached; the first upload to a board in a session went through a queue that always used `KeepBest` (old-cpp 79-130, 265-275 vs 608-674). See entry 5.

---------------------------------------------------------------------------------------------------

## 1. Corrections to the task's premises

| Premise | Reality (evidence) |
|---|---|
| "Steam ids are probably a SteamId struct now" | **No.** Everything in this domain uses plain 64-bit unsigned ints, which GML sees as int64: `SteamUserStatsDownloadedLeaderboardEntry.steam_id_user` is `buffer_read(..., buffer_u64)` (API.gml:9042); `steam_user_get_steam_id()` returns `buffer_u64` (API.gml:14730-14742); leaderboard handles and entries handles are `buffer_u64` too (API.gml:9100-9106, 9158-9164). `SteamId` (API.gml:1688) is only returned by `steam_user_decode_steam_id`. |
| "stat functions" exist in the project | **No stat function is called anywhere.** Re-grepped over `objects/ scripts/ rooms/` (excluding `scripts/Steamworks_API`): no `steam_set_stat_*`, `steam_get_stat_*`, `steam_store_stats`, `steam_stats_ready`, `steam_request_global_*`, `steam_clear_achievement`, `steam_indicate_achievement_progress`, `steam_upload_score` / `_buffer`, `steam_get_leaderboard_*`. Only `steam_reset_all_stats_achievements` is stats-adjacent. |
| Async results use `async_load[? "id"]` etc. | True for 2.x. In 3.0 the result is one struct argument to the callback; there is no id (see entries). |
| `steam_stats_ready` / RequestCurrentStats | Not needed. 2.x `steam_stats_ready()` was hard-coded to 1 with the comment "since 1.61 the data is synced on init" (old-cpp 1938, 1946-1957); 3.0 has no such function and calls `RequestUserStats` only for other users (new-cpp gm_steam_userstats.cpp:679-693). **Confidence medium:** the only source for "synced on init" is the 2.x code comment; neither the 3.0 docs nor anything else read here states it. Test item 1 covers it. |

---------------------------------------------------------------------------------------------------

## 2. Project inventory (definitions and real callers)

### Wrapper definitions (`scripts/scr_steam_safe/scr_steam_safe.gml`)

| Wrapper | line | Fallback return when guard fails |
|---|---|---|
| `tcc_steam_create_leaderboard(_a0,_a1,_a2)` | 50 | `false` |
| `tcc_steam_download_friends_scores(_a0)` | 54 | `false` |
| `tcc_steam_download_scores(_a0,_a1,_a2)` | 58 | `false` |
| `tcc_steam_download_scores_around_user(_a0,_a1,_a2)` | 62 | `false` |
| `tcc_steam_get_number_of_current_players()` | 70 | `false` |
| `tcc_steam_reset_all_stats_achievements()` | 218 | `false` |
| `tcc_steam_update()` (pumps callbacks; also the old stats-store pump) | 310 | `false` |
| `tcc_steam_initialised()` (gate used everywhere) | 102 | `false` |

Achievement and upload calls have **no tcc wrapper**: they are raw in `scripts/scr_platform_services/scr_platform_services.gml` (allowed by `tools/check_port.py:78`):
`steam_get_achievement` line 181, `steam_set_achievement` line 188, `steam_upload_score_ext` line 205 (all behind `tcc_steam_initialised()`).

### Real callers

| Old function / wrapper | Caller (file:line) |
|---|---|
| `tcc_steam_get_number_of_current_players` | `objects/o_version/Create_0.gml:18`, `objects/o_version/Step_0.gml:9`, `objects/o_checkplayercount/Create_0.gml:19`, `objects/o_checkplayercount/Alarm_0.gml:8` (re-armed every 500 steps) |
| `tcc_steam_download_scores` | `scripts/reloadleaderboards/reloadleaderboards.gml:50` (1,100), `objects/o_settings/Create_0.gml:35` (1,10), `objects/o_onlineleaderboardCH/Other_69.gml:2` (orphan) |
| `tcc_steam_download_friends_scores` | `scripts/reloadleaderboards/reloadleaderboards.gml:52` |
| `tcc_steam_download_scores_around_user` | `scripts/reloadleaderboardsmini/reloadleaderboardsmini.gml:20` (workshop: "CL_"+name, -4,5), `:23` (single mini: -9,10), `:25` (two minis: -4,5) |
| `reloadleaderboards()` triggers | `objects/o_onlineleaderboards/Create_0.gml:37`, `Step_0.gml:4,9,15,19` (right, left, wrap-around min/max), `objects/o_reloadleaderboardsbutton/Mouse_4.gml:4`, `objects/o_friendleaderboardsettings/Mouse_4.gml:5` |
| `reloadleaderboardsmini()` triggers | `objects/o_onlineleaderboardsmini/Create_0.gml:89`, `Alarm_0.gml:14,23,32` (three room branches: r_gameoverscreen, r_dailylevelwin, r_endlessrunmenu), `objects/o_reloadleaderboardsbutton/Mouse_4.gml:8` (`with (o_onlineleaderboardsmini)`, i.e. once per mini instance) |
| `tcc_steam_create_leaderboard` | `scripts/scr_saveworkshopmedals/scr_saveworkshopmedals.gml:19` (immediately followed by `platform_submit_score` on line 20), `objects/o_onlineleaderboardCH/Create_0.gml:4` (orphan) |
| `tcc_steam_reset_all_stats_achievements` | `objects/o_steamachievementreset/KeyPress_65.gml:3` (hidden debug: 26 presses of "A" in `r_mainmenu`; object placed in `rooms/r_mainmenu/r_mainmenu.yy`) |
| `steam_upload_score_ext` via `platform_submit_score[_ext]` | **27 external call sites in 15 files** (+1 internal delegation `platform_submit_score` -> `platform_submit_score_ext` at `scr_platform_services.gml:198`; definitions at :197, :201): `objects/o_playerdead/Create_0.gml` x6 (26,29,35,37,42,45), `objects/o_settings/Step_0.gml` x2 (20,22), `objects/o_animatedtextfinalstats/Create_0.gml:54`, `objects/o_player/Step_0.gml` x3 (770,771,913), `objects/o_dailylevel/Create_0.gml:31`, `scripts/scr_workshopER/scr_workshopER.gml` x2 (297,299), `scripts/scr_saveworkshopmedals/scr_saveworkshopmedals.gml:20`, `scripts/scr_endlessruncheck/scr_endlessruncheck.gml` x3 (13,18,23), `scripts/scr_timing_gameplay/scr_timing_gameplay.gml:194`, rooms `r_lvl21`, `r_lvl41`, `r_lvl61`, `r_lvl81`, `r_theend` (1 each, `InstanceCreationCode_*.gml`) and `r_dailylevelwin` x2 (`InstanceCreationCode_inst_4FA6716F_1.gml:14,18`). **None of them read the return value or the upload result.** |
| `steam_get_achievement` / `steam_set_achievement` via `achievement_earned` / `achievement_award` | 304 call sites in 44 files (re-counted). All literal ids except `objects/o_animatedtextfinalstats/Create_0.gml:46-47`, `scripts/draw_achievement/draw_achievement.gml:8,51`, `scripts/scr_gameplay_qa/scr_gameplay_qa.gml:141`. No caller uses the return value of `achievement_award`. `achievement_award` early-outs when `global.cheats != 0` (`scr_platform_services.gml:187`). |

Some uploads are fired **twice in the same frame** (e.g. `objects/o_playerdead/Create_0.gml:26` then `:29`: "Endless Run" and "Seasonal Endless Run"). Steam documents "only one outstanding UploadLeaderboardScore at a time" and 10 uploads / 10 min (docs3:494); the 2.x source says uploads "tend to fail if a lot of posts are sent at once" (old-cpp 534-538). See the serialising queue in section 4.

**Dead call:** `scripts/scr_timing_gameplay/scr_timing_gameplay.gml:191` sets `global.cheats = 1` and line 194 then calls `platform_submit_score_ext("Current Daily Level Streak", 0, true)`, but `platform_submit_score_ext` returns `false` first thing when `global.cheats != 0` (`scr_platform_services.gml:202`). That forced reset therefore never reaches any backend, in 2.x or 3.0. Nothing to port.

---------------------------------------------------------------------------------------------------

## 3. Per-identifier entries

Legend: **A** = result arrives in a callback; **S** = synchronous.

### 3.1 `steam_create_leaderboard(lb_name, sort_order, display_type)`  -> A

| | 2.x | 3.0 |
|---|---|---|
| Call | `steam_create_leaderboard("CL_123", lb_sort_ascending, lb_disp_time_ms)` | `steam_userstats_find_or_create_leaderboard("CL_123", SteamLeaderboardSortMethod.Ascending, SteamLeaderboardDisplayType.TimeMilliSeconds, _callback)` (API.gml:19752) |
| Return | async id (real); `0` if not initialised or not logged on (old-cpp 484-519) | `0` (Real) when the extension is present (API.gml:19783, new-native 4459), `undefined` only if `extension_exists` is false; never a success flag |
| Result | Steam Async event `create_leaderboard` {id, lb_name, status}. **Sent only on repeat calls for a name the extension already knows**: status 1 = handle cached (old-cpp 435), status 0 = create already pending (445, 462). **The first call for a name sends no event at all** (the "not in the list" branch, 471-477). The completion event is commented out (old-cpp 393-398). Nothing in the project listens. | `_callback(SteamUserStatsLeaderboardFindResult)` fields `leaderboard_handle` (int64, 0 if not found), `leaderboard_found` (bool) (API.gml:3117, decode 9097; docs3:879-889) |
| Semantics | FindOrCreate; cached by name; any upload/download for that name queued behind it (old-cpp 290-312 `SendLBRequests`); IO failure retried silently (346-361) | FindOrCreate; **no cache, no queue**; no callback on IO failure |

Gotchas:
- Enum values are numerically identical (`lb_sort_none/ascending/descending = 0/1/2`, `lb_disp_none/numeric/time_sec/time_ms = 0/1/2/3` in the old yy vs `SteamLeaderboardSortMethod.None/Ascending/Descending`, `SteamLeaderboardDisplayType.None/Numeric/TimeSeconds/TimeMilliSeconds`, API.gml:1428-1441), but the old macro names are gone.
- 3.0 cannot tell "created" from "already existed"; `leaderboard_found` is true for both. Nothing depends on it (2.x status meant cached/pending, not created/existed, whatever the old docs say).
- **Ordering race at `scr_saveworkshopmedals.gml:19-20`:** it creates and uploads in the same frame. 2.x queued the upload behind the pending create. A naive port that does `find_or_create` and, in the same frame, `find_leaderboard` + upload races the create. Either serialise (section 4) or do the upload inside the create callback.
- Boards that were not pre-defined in the Steamworks partner site are only created by these two sites; every other board must already exist (plain upload/download used `FindLeaderboard`, **not** FindOrCreate: old-cpp 574-607). Keep it that way: do not turn plain uploads into `find_or_create`, that would auto-create wrongly-typed boards.
- `objects/o_onlineleaderboardCH` is an orphan (tracked in git but absent from the `.yyp` and `.resource_order`, in HEAD as well) so its call is never compiled. Port or delete freely.

### 3.2 `steam_download_scores(lb_name, start_idx, end_idx)`  -> A

New (two steps; the handle must be resolved first):
```
steam_userstats_find_leaderboard(_leaderboard_name, _callback)                                   // API.gml:19790
steam_userstats_download_leaderboard_entries(_leaderboard_handle, SteamLeaderboardDataRequest.Global, _range_start, _range_end, _callback)   // API.gml:19909
steam_userstats_downloaded_leaderboard_entry(_leaderboard_entries_handle, _entry_index)           // API.gml:19988
```
- 2.x return: async id; `0` not initialised; `-1` not logged on. Event `leaderboard_download` {id, status (0 ok / 1 IO failure), lb_name, num_entries, entries (JSON string)} or `leaderboard_not_found` {id, status=1, lb_name} (old-cpp 977-1083, 365).
- 3.0: download callback receives `SteamUserStatsScoresDownloadedResult {leaderboard_handle, entries_handle, entry_count}` (API.gml:3133, decode 9150; `entry_count` is u32). Read each row with `steam_userstats_downloaded_leaderboard_entry(result.entries_handle, i)` -> `SteamUserStatsDownloadedLeaderboardEntry {steam_id_user, global_rank, score, details[], ugc_handle}` (API.gml:3098, decode 9034) or `undefined`.
- Field mapping of the old JSON entry: `name` -> `steam_friends_get_friend_persona_name(e.steam_id_user)`; `score` -> `e.score` (int32); `rank` -> `e.global_rank` (1-based, same as before); `userID` (int64 via `@i64@..$i64$`, old-cpp 1022-1031) -> `e.steam_id_user` (int64); `data` (base64 of details) -> `e.details` (array of int32; unused by the project).
- Range semantics identical: Global is 1-based, inclusive (docs3:1045-1052; old call `DownloadLeaderboardEntries(h, Global, startidx, endidx)`). `(1,100)` and `(1,10)` stay as is.
- **Cap rows at 100**: 2.x truncated at `kMaxEntries = 100` (old-cpp 19, 990-994). The project's per-row arrays are sized 100/50; use `min(result.entry_count, 100)`.
- **Read the entries inside the callback**: `entries_handle` is documented as valid only for "the most recently received" download (docs3:475-481). Never stash it for later.
- Not-found board: `find_leaderboard` callback gives `leaderboard_found == false`, handle 0; **do not** call download with it (see section 0 item 6: it would not abort, it would stall or return nothing). 2.x delivered `leaderboard_not_found`, which the handlers did not handle (`entries` key absent -> `json_decode(undefined)`); behaviour is only better in 3.0 (rows just stay "LOADING").
- 2.x refused the call when `!SteamUser()->BLoggedOn()`; 3.0 does not. Keep the check in the wrapper with `steam_user_logged_on()` (direct native, yy line 156, returns Real).

### 3.3 `steam_download_scores_around_user(lb_name, range_start, range_end)`  -> A

Same as 3.2 with `SteamLeaderboardDataRequest.GlobalAroundUser` (value 1): `steam_userstats_download_leaderboard_entries(_leaderboard_handle, SteamLeaderboardDataRequest.GlobalAroundUser, _range_start, _range_end, _callback)`.
Ranges are relative to the player (-4,5 => 4 above, 5 below, self included; Steam shifts the window at the edges): same Steam call as before (old-cpp 850).
Workshop boards use the name `"CL_" + lbname` (`reloadleaderboardsmini.gml:20`); a board nobody has created yields `leaderboard_found == false`.

### 3.4 `steam_download_friends_scores(lb_name)`  -> A

`steam_userstats_download_leaderboard_entries(_leaderboard_handle, SteamLeaderboardDataRequest.Friends, 0, 0, _callback)` (old code passed `0, 0` and Steam ignores the range for Friends: docs3 enum text "The start and end parameters are ignored").
The Friends set can exceed 100 entries -> keep the `min(entry_count, 100)` cap.

### 3.5 `steam_upload_score_ext(lb_name, score, force_update)`  -> A (fire-and-forget in this project)

New (two steps):
```
steam_userstats_find_leaderboard(_leaderboard_name, _callback)                                   // API.gml:19790
steam_userstats_upload_leaderboard_score(_leaderboard_handle, _method, _score, _score_details, _callback)   // API.gml:20026
// _method  = _force ? SteamLeaderboardUploadScoreMethod.ForceUpdate : SteamLeaderboardUploadScoreMethod.KeepBest
// _score   = clamp(floor(_score), 0, 2147483647)     (int32)
// _score_details = []                                  (array required)
```
- Result struct: `SteamUserStatsScoreUploadedResult {success, leaderboard_handle, score, score_changed, global_rank_new, global_rank_previous}` (API.gml:3150, decode 9218). 2.x event keys map: `success`->`success`, `updated`->`score_changed`, `score`->`score`, `lb_name`->(own context or `steam_userstats_leaderboard_name(handle)`), `post_id`->(none).
- 2.x return: post id; `-1` when not logged on; `0` when not initialised (old-cpp 608-613, 700-720). 3.0 returns `0` (Real) when the extension is present. The project never used the return. The new wrapper returns `true` once the job is **enqueued** and `false` when its preconditions fail; dispatch failures are only visible through a missing callback (watchdog) and `steam_api_last_error()`.
- **Bool -> enum:** see section 0 item 7. false->`None`(0, invalid), true->`KeepBest`: both paths break.
- **Force semantics are NOT parity, they are a deliberate fix.** 2.x `SLBRequest` has no force field and `DoLBRequest` always used `KeepBest` (old-cpp 79-130, 265-275). `_forceupdate` was honoured only on the direct path, when the board's handle was already cached (old-cpp 656 vs 659). The first upload to a board in a session was queued and silently became `KeepBest`; once the queued find resolved, `OnFindLeaderboardResult` cached the handle (old-cpp 388-391) and every later forced upload in that session did force. With the queue in section 4 the first forced upload per board per session now forces too. Consequences:
  - `objects/o_dailylevel/Create_0.gml:31` (`diff >= 14`: `platform_submit_score_ext("Current Daily Level Streak", 0, true)`; `o_dailylevel` is placed in `rooms/r_gamemode` only) will now reset the Steam streak on the first visit instead of the second. The upload count per visit is the same as in 2.x, so the rate-limit cost is not new (it already repeated on every `r_gamemode` visit while `diff >= 14`). Optional project follow-up, not a port item: dedupe it.
  - `scripts/scr_timing_gameplay/scr_timing_gameplay.gml:194` is dead code (see section 2) and does not matter.
- Score type: `_score` is written as `buffer_s32` (API.gml:20054-20056). 2.x did `(int32)score` (truncation, old-cpp 649-659). `global.time * 1000` and `distance` (`o_settings/Step_0.gml:20`) are fractional, so use `floor()` explicitly and clamp (the Steam branch has no clamp today; the Apple branch rounds and clamps at `scr_platform_services.gml:209-211`).
- Callback is mandatory even though nobody reads the result: pass a struct-bound function, not an instance-bound one.
- `score_details` must be an array: `[]` (max 64 entries, new-cpp gm_steam_userstats.cpp:813-815).
- Rate limits are Steam's, unchanged: 10 uploads/10 min, one outstanding at a time (docs3:494). Serialise uploads (section 4); two same-frame uploads exist (section 2).
- IO failure / dispatch failure => no callback (2.x delivered `success=0` on upload IO failure, old-cpp 528-570): do not wait on it without a watchdog.
- Uploads used `FindLeaderboard` in 2.x (not FindOrCreate) and were silently dropped if the board did not exist (old-cpp 574-607, 357-370): keep that.
- `scr_platform_services.gml:205` is a raw call. `tools/check_port.py:78-79` only forbids a regex over `steam_(inventory_|ugc_|get_achievement|set_achievement|upload_score|initialised)`: **it does not match `steam_userstats_*`**, so the "raw calls only in scr_steam_safe / scr_platform_services" guard silently stops covering this domain. Add `userstats_` (and `api_`) to that regex.

### 3.6 `steam_set_achievement(ach_name)`  -> S

- New: `steam_userstats_set_achievement(_achievement_name)` (direct native, yy:387; arg string; returns Real 1/0) **then** `steam_userstats_store_stats()` (yy:390; returns Real 1/0).
- 2.x returned 1/0 and scheduled the store itself, **only when `SetAchievement` returned true** (old-cpp 1171-1181). In 3.0 you must do the store. Recommended: set a dirty flag in the wrapper when `set_achievement` returned 1, flush from `tcc_steam_update()`, keep the flag set while `store_stats` returns 0 (reproduces `m_bStoreStats = !bSuccess`, old-cpp 1973-1986). That is exact parity, including the fact that an award made while stats are not loaded (return 0) is lost; a pending-award retry would be an optional improvement, not required.
- `StoreStats` can be rate-limited ("order of minutes", docs3:142-153); with the dirty flag at most one call per frame is made, as in 2.x.
- Setting an already-unlocked achievement is legal (docs3:99-110) and still returns 1; this is how 2.x behaved too. Many call sites guard with `achievement_earned` first (`objects/o_checkpointflag/Collision_o_player.gml:13`), some do not (`o_animatedtextfinalstats/Create_0.gml:73,78`).
- Could fail with 0 if the stats are not loaded or the name is not defined in the partner site; if you log `steam_api_last_error()`, read it immediately after the call (every guarded call clears it first, `GMSteamworks.h:59-67`). Note the success path of `SetAchievement` leaves it empty; the extension only writes it for guard/dispatch failures, so an unknown name may give an empty string.
- `achievement_award` currently `return steam_set_achievement(_id)` (`scr_platform_services.gml:188`); nobody uses the value, but keep a real return.

### 3.7 `steam_get_achievement(ach_name)`  -> S

- New: `steam_userstats_get_achievement(_achievement_name)` (API.gml:19498, wrapper). Returns `Bool` **or `undefined`**.
- 2.x always returned 0/1 (old-cpp 1184-1210). 3.0 returns `undefined` when the extension is unavailable (`if (!__available__) return;`) or when `GetAchievement` fails (new-cpp gm_steam_userstats.cpp:112-128). Normalise: `var _r = steam_userstats_get_achievement(_id); return is_bool(_r) ? _r : false;`.
- Performance note: `draw_achievement` calls it up to twice per achievement per Draw; each call marshals through a buffer. ~150 achievements on screen is fine, but a per-frame cache is trivial if profiling shows a cost.

### 3.8 `steam_reset_all_stats_achievements()`  -> S

- New: `steam_userstats_reset_all_stats(true)` (direct native, yy:401; arg is a double, `true` is fine; returns Real 1/0).
- 3.0 auto-calls `StoreStats` (docs3:318-327), so no dirty flag is needed. 2.x did `ResetAllStats(true)` + deferred store (old-cpp 1834-1856).
- Debug-only feature, but reachable in shipped builds (26 "A" key presses in the main menu). Keep the `platform_steam()` guard; consider additionally gating on a debug build - not changed here.

### 3.9 `steam_get_number_of_current_players()`  -> A

- New: `steam_userstats_number_of_current_players(_callback)` (API.gml:20103); callback `SteamUserStatsNumberOfCurrentPlayersResult {success (bool), players (int32)}` (API.gml:3170, decode 9279).
- 2.x: returned **Real 1/0** (a bool written as `VALUE_REAL`, old-cpp 1885-1887), `0` when not initialised, and `false` if a request was already active (`IsActive()`, old-cpp 1131-1139); event `number_of_current_players` {success, players} (also `success=false, players=0` on IO failure, old-cpp 1111-1128).
- 3.0 returns `0` (Real) after dispatch, has no "already busy" rejection, and **never calls back on IO failure**. The wrapper must (a) return `true` once the request has been issued so `if (tcc_steam_get_number_of_current_players()) busy = true;` keeps working (a dispatch failure is invisible here), (b) keep its own in-flight flag with a timeout (reproduces the `IsActive` rejection and avoids a permanent `busy`), (c) write `global.playercount` itself in a struct-bound/unbound callback, because `o_version` is non-persistent.
- `objects/o_version/Step_0.gml:8-22` polls the wrapper each step while `busy` and treats the return as a count (`players = result`). It predates the async API and was inert in 2.x because `Other_69` cleared `busy` first and the busy call returned 0. **Delete that block; do not port it.** If it stayed after `Other_69.gml` is deleted: `busy` would stay true; the wrapper returns false while its own in-flight flag is set, so nothing happens until the callback arrives, then the next Step starts exactly **one** extra request, `result != 0` (true) sets `busy=false`, `success=true`, and `global.playercount = true` (1) until that extra request's callback overwrites it. That is one spurious request and a brief wrong value (the credits multiplier is clamped to 3), not one request per frame.
- Nothing reads `busy`, `success` or `players` outside those four files; the only consumer is `global.playercount` (`objects/o_version/Draw_0.gml:7-12`, `o_checkplayercount/Alarm_0.gml:17-18`).
- `o_version/Create_0.gml:12-13` still fires two `http_get` calls to api.steampowered.com whose handler (`Other_62.gml`) is an unclosed comment; not part of this migration.

### 3.10 Constants / enums

| Old | New | Value |
|---|---|---|
| `lb_sort_none` | `SteamLeaderboardSortMethod.None` | 0 |
| `lb_sort_ascending` | `SteamLeaderboardSortMethod.Ascending` | 1 |
| `lb_sort_descending` | `SteamLeaderboardSortMethod.Descending` | 2 |
| `lb_disp_none` | `SteamLeaderboardDisplayType.None` | 0 |
| `lb_disp_numeric` | `SteamLeaderboardDisplayType.Numeric` | 1 |
| `lb_disp_time_sec` | `SteamLeaderboardDisplayType.TimeSeconds` | 2 |
| `lb_disp_time_ms` | `SteamLeaderboardDisplayType.TimeMilliSeconds` | 3 |
| (new, no old equivalent) | `SteamLeaderboardDataRequest.Global/GlobalAroundUser/Friends` | 0/1/2 |
| (old bool `force_update`) | `SteamLeaderboardUploadScoreMethod.KeepBest/ForceUpdate` (`None` = 0 is an invalid value) | 1/2 |

Only the two creation sites use the old constants (`o_onlineleaderboardCH/Create_0.gml:4`, `scr_saveworkshopmedals.gml:19`).

### 3.11 Removed Steam Async event keys (this domain)

`event_type` values `create_leaderboard`, `leaderboard_download`, `leaderboard_not_found`, `leaderboard_upload`, `number_of_current_players` and their keys (`id`, `post_id`, `status`, `lb_name`, `num_entries`, `entries`, `success`, `updated`, `score`, `players`) have no 3.0 equivalent; the only `event_type` string still read in these files that belongs to **another** domain is `avatar_image_loaded` (see section 5).

---------------------------------------------------------------------------------------------------

## 4. Reference wrapper layer (recommended design; GML written by the original mapper, not compiled)

All of this belongs in `scripts/scr_steam_safe/scr_steam_safe.gml` so the call sites keep the `tcc_steam_*` indirection and the `platform_steam()` guard. Names `then`, `score`, `method` are avoided on purpose (GML keyword / built-in clashes). Changes versus the first map: comments only (return-value contract, force semantics). Optional hardening noted after the listing.

```gml
function tcc_steam_state() {
    static _s = {
        lb_handles: {}, lb_queue: [], lb_busy: false, lb_busy_at: 0, lb_gen: 0,
        stats_dirty: false, players_busy: false, players_busy_at: 0
    };
    return _s;
}

function tcc_steam_lb_available() {
    // 2.x refused leaderboard calls when !SteamUser()->BLoggedOn() (old-cpp 484-519, 766-790)
    return platform_steam() && steam_api_is_initialized() && steam_user_logged_on();
}

// One leaderboard request in flight at a time (Steam allows one outstanding upload; entries handles are "most recent only").
function tcc_steam_lb_enqueue(_start) {          // _start(_done): must call _done() once when its Steam callback has been handled
    array_push(tcc_steam_state().lb_queue, _start);
    tcc_steam_lb_pump();
}

function tcc_steam_lb_pump() {
    var _st = tcc_steam_state();
    if (_st.lb_busy) {
        if (current_time - _st.lb_busy_at < 20000) return;
        _st.lb_busy = false;                      // IO/dispatch failure => Steam never calls back: abandon the lost job
        _st.lb_gen += 1;                          // and ignore its late _done
    }
    if (array_length(_st.lb_queue) == 0) return;
    var _start = _st.lb_queue[0];
    array_delete(_st.lb_queue, 0, 1);
    _st.lb_busy = true;
    _st.lb_busy_at = current_time;
    _start(method({gen: _st.lb_gen}, function() {
        var _s = tcc_steam_state();
        if (gen != _s.lb_gen) return;
        _s.lb_busy = false;
        tcc_steam_lb_pump();
    }));
}

// Resolve a leaderboard handle by name (cached for the session). _sort undefined => FindLeaderboard (2.x default); else FindOrCreate.
// _next(handle) gets undefined when the board does not exist.
function tcc_steam_lb_resolve(_board, _sort, _disp, _next) {
    var _h = tcc_steam_state().lb_handles[$ _board];
    if (!is_undefined(_h)) { _next(_h); return; }
    var _cb = method({board: _board, next: _next}, function(_r) {
        if (_r.leaderboard_found) {
            tcc_steam_state().lb_handles[$ board] = _r.leaderboard_handle;
            next(_r.leaderboard_handle);
        } else next(undefined);
    });
    if (is_undefined(_sort)) steam_userstats_find_leaderboard(_board, _cb);
    else steam_userstats_find_or_create_leaderboard(_board, _sort, _disp, _cb);
}

function tcc_steam_create_leaderboard(_name, _sort, _disp) {            // was (_a0,_a1,_a2): same arguments, pass the new enums
    if (!tcc_steam_lb_available()) return false;
    tcc_steam_lb_enqueue(method({board: _name, sort: _sort, disp: _disp}, function(_done) {
        done = _done;
        tcc_steam_lb_resolve(board, sort, disp, method(self, function(_handle) { done(); }));
    }));
    return true;                                                         // "enqueued"; the Steam call's own return is always 0
}

// _request: SteamLeaderboardDataRequest.*. _callback(rows) with rows = array of SteamUserStatsDownloadedLeaderboardEntry, or undefined (board missing).
// NOTE: _callback must itself be struct-bound and check instance_exists (it is called later, possibly after the requesting instance is gone).
function tcc_steam_lb_download(_board, _request, _start, _end, _callback) {
    if (!tcc_steam_lb_available()) return false;
    tcc_steam_lb_enqueue(method({board: _board, request: _request, a: _start, b: _end, cb: _callback}, function(_done) {
        done = _done;
        tcc_steam_lb_resolve(board, undefined, undefined, method(self, function(_handle) {
            if (is_undefined(_handle)) { cb(undefined); done(); return; }
            steam_userstats_download_leaderboard_entries(_handle, request, a, b, method(self, function(_r) {
                var _rows = [];
                var _n = min(_r.entry_count, 100);                         // 2.x kMaxEntries
                for (var _i = 0; _i < _n; ++_i) {                          // read inside the callback: entries_handle is "most recent" only
                    var _e = steam_userstats_downloaded_leaderboard_entry(_r.entries_handle, _i);
                    if (!is_undefined(_e)) array_push(_rows, _e);
                }
                cb(_rows);
                done();
            }));
        }));
    }));
    return true;
}
function tcc_steam_download_scores(_board, _start, _end, _callback)       { return tcc_steam_lb_download(_board, SteamLeaderboardDataRequest.Global,          _start, _end, _callback); }
function tcc_steam_download_scores_around_user(_board, _from, _to, _callback) { return tcc_steam_lb_download(_board, SteamLeaderboardDataRequest.GlobalAroundUser, _from,  _to,  _callback); }
function tcc_steam_download_friends_scores(_board, _callback)            { return tcc_steam_lb_download(_board, SteamLeaderboardDataRequest.Friends,         0,      0,    _callback); }

function tcc_steam_upload_score(_board, _value, _force) {              // replaces the raw steam_upload_score_ext in scr_platform_services.gml:205
    if (!tcc_steam_lb_available()) return false;
    tcc_steam_lb_enqueue(method({board: _board, value: clamp(floor(_value), 0, 2147483647),
            how: (_force ? SteamLeaderboardUploadScoreMethod.ForceUpdate : SteamLeaderboardUploadScoreMethod.KeepBest)}, function(_done) {
        done = _done;
        tcc_steam_lb_resolve(board, undefined, undefined, method(self, function(_handle) {
            if (is_undefined(_handle)) { done(); return; }
            steam_userstats_upload_leaderboard_score(_handle, how, value, [], method(self, function(_r) {
                if (!_r.success) show_debug_message("Steam leaderboard upload failed: " + board);
                done();
            }));
        }));
    }));
    return true;
}

// ---- achievements ----
function tcc_steam_get_achievement(_name) {
    if (!(platform_steam() && steam_api_is_initialized())) return false;
    var _r = steam_userstats_get_achievement(_name);
    return is_bool(_r) ? _r : false;                                   // undefined when stats unavailable / name unknown
}
function tcc_steam_set_achievement(_name) {
    if (!(platform_steam() && steam_api_is_initialized())) return false;
    var _ok = steam_userstats_set_achievement(_name);                 // direct native, Real 1/0, in-memory only
    if (_ok) tcc_steam_state().stats_dirty = true;                    // flushed by tcc_steam_update (replaces 2.x m_bStoreStats, set on success only)
    return _ok;
}
function tcc_steam_reset_all_stats_achievements() {                   // line 218 today
    if (!(platform_steam() && steam_api_is_initialized())) return false;
    return steam_userstats_reset_all_stats(true);                     // auto-calls StoreStats
}

// ---- player count ----
function tcc_steam_get_number_of_current_players() {                  // keeps the old name and the old "true = request started" contract
    if (!(platform_steam() && steam_api_is_initialized())) return false;
    var _st = tcc_steam_state();
    if (_st.players_busy && current_time - _st.players_busy_at < 30000) return false;   // 2.x: IsActive() => false
    _st.players_busy = true;
    _st.players_busy_at = current_time;
    steam_userstats_number_of_current_players(method({}, function(_r) {    // unbound from the calling instance on purpose
        tcc_steam_state().players_busy = false;
        if (_r.success) global.playercount = _r.players;
    }));
    return true;                                                       // "issued"; the Steam call's own return is always 0
}

// ---- per-frame pump (init/update agent owns the run_callbacks part) ----
function tcc_steam_update() {
    if (!(platform_steam() && steam_api_is_initialized())) return false;
    steam_api_run_callbacks();
    var _st = tcc_steam_state();
    if (_st.stats_dirty && steam_userstats_store_stats()) _st.stats_dirty = false;   // retry next frame on failure, like 2.x
    tcc_steam_lb_pump();                                                              // watchdog for lost callbacks
    return true;
}
```

Notes for the person copying this:
- `achievement_earned` / `achievement_award` / `platform_submit_score_ext` in `scr_platform_services.gml` then call `tcc_steam_get_achievement(_id)`, `tcc_steam_set_achievement(_id)`, `tcc_steam_upload_score(_board, _score, _force)` (allowed either way by check_port; using the wrappers removes the raw 3.0 names from that file).
- `tcc_steam_lb_resolve` is shared by create/download/upload, so `scr_saveworkshopmedals.gml:19-20` becomes correct unchanged except for the two enum names: the create job runs first, caches the handle, then the upload job finds it in the cache. Do not cache negative results (2.x also dropped them so a later request could retry).
- A job whose `steam_userstats_*` call fails to dispatch stalls the queue until the 20 s watchdog. That is acceptable (rare). If you add diagnostics, call `steam_api_last_error()` right after the failing call (section 0 item 4).
- If an uploaded board is missing on the partner site, the upload is dropped silently, exactly like 2.x.
- Optional hardening (not parity): with rapid left/right presses the FIFO can accumulate stale 100-row download jobs from the same owner; a "supersede" key (drop queued, not-yet-started download jobs with the same owner) would shorten the backlog. The token check in the callbacks keeps correctness without it.

---------------------------------------------------------------------------------------------------

## 5. Handler-by-handler (Other_69 and related)

Common change: the leaderboard code stops using `score_get`, `async_load` and `json_decode`. Each requester creates a monotonically increasing token (`lb_req`) and a struct-bound callback.

### 5.1 `objects/o_onlineleaderboards/Other_69.gml` (+ `scripts/reloadleaderboards/reloadleaderboards.gml`, `Create_0.gml`)

Currently reads (async_load map): `id` (== `score_get`), `entries` (JSON string -> `json_decode` -> `ds_list` of maps with `name`, `score`, `rank`, `userID`/`steamid`), key `default` (empty/failed decode). Writes `steam_name[i]`, `steam_score[i]`, `steam_rank[i]`, `steam_userid[i]`, and prefetches avatars with `tcc_steam_get_user_avatar(real(entry_user_id), avatar_request_size)`.
Lines 51-68 handle `event_type == "avatar_image_loaded"` (map keys `success`, `user_id`, `image`) - **friends/avatar domain, not this one**.

Callback receives instead: `rows` = array of `SteamUserStatsDownloadedLeaderboardEntry` (`steam_id_user`, `global_rank`, `score`, `details`, `ugc_handle`), or `undefined`.

Patch outline (`reloadleaderboards.gml:49-53`):
```gml
lb_req = (variable_instance_exists(id, "lb_req") ? lb_req : 0) + 1;     // or lb_req = 0 in Create_0.gml before the reloadleaderboards() call on line 37
var _cb = method({owner: id, req: lb_req}, function(_rows) {
    if (!instance_exists(owner) || owner.lb_req != req || is_undefined(_rows)) return;   // stale / destroyed / board missing => stay on "LOADING"
    with (owner) {
        for (var i = 0; i < array_length(_rows); i++) {
            var e = _rows[i];
            steam_name[i]   = steam_friends_get_friend_persona_name(e.steam_id_user);    // was entry "name"
            steam_score[i]  = e.score;
            steam_rank[i]   = e.global_rank;
            steam_userid[i] = e.steam_id_user;                                            // int64; keep string(id) for avatar_sprites keys
            // avatar prefetch: unchanged logic, but pass e.steam_id_user directly - NOT real(e.steam_id_user)
        }
    }
});
if (global.friendleaderboardsettings == 0) tcc_steam_download_scores(lbname, 1, 100, _cb);
else tcc_steam_download_friends_scores(lbname, _cb);
```
Gotchas: (1) **`real(int64)` is lossy for a Steam64 id** (doubles are exact only below 2^53, Steam64 ids are ~7.6e16). This is a **pre-existing** hazard, not a 3.0 regression: in 2.x the `userID` also came from `"@i64@<hex>$i64$"` as an int64 (old-cpp 1022-1031) and was narrowed by the same `real()` at line 35 of this file and line 39 of the mini's. (What `real()` does to an int64 in the GameMaker runtime was not verified here.) The port should simply pass `e.steam_id_user` unchanged. (2) `steam_userid[i] = noone` sentinel and the `entry_user_id != noone && != 0` test still work with int64. (3) `Draw_0` treats `steam_score[i] = 0 and steam_rank[i] = 0` as an empty row; `global_rank` is >= 1 so real rows never match. (4) Several triggers can start overlapping requests: `Step_0.gml:4,9,15,19` (a key press plus a wrap-around in the same frame bumps the token twice), `o_reloadleaderboardsbutton/Mouse_4.gml:4`, `o_friendleaderboardsettings/Mouse_4.gml:5`; only the last request may win.
(5) After removal the object's event list must drop the Async Steam event only if the avatar half is moved elsewhere; **do not delete the file wholesale** - lines 51-68 are still needed until the friends agent replaces them with `steam_friends_set_callback_avatar_image_loaded` (a single global slot; two mini instances will need fan-out).

### 5.2 `objects/o_onlineleaderboardsmini/Other_69.gml` (+ `scripts/reloadleaderboardsmini/reloadleaderboardsmini.gml`)

Same reads/writes as 5.1. The early `global.hardmode = 1 -> instance_destroy()` in `Other_69.gml:2-4` (after an `!tcc_steam_initialised()` exit at line 1) is **redundant and can be dropped with the leaderboard half**: `Create_0.gml:1-4` already destroys the instance (non-Steam and hard mode) before `reloadleaderboardsmini()` runs, so no request is ever made in hard mode, and `Draw_0.gml:1-3` repeats the check every frame. Keep the `instance_exists(owner)` guard in the callback for room-change cases. Same patch as 5.1 with `tcc_steam_download_scores_around_user(name, from, to, _cb)` at `reloadleaderboardsmini.gml:20,23,25`.
Gotchas: `reloadleaderboardsmini()` is called from `Create_0.gml:89`, from `Alarm_0.gml:14,23,32` (5 ticks after Create) and from `o_reloadleaderboardsbutton/Mouse_4.gml:8` once per mini instance, so two or more requests per instance are normal -> token filtering is required; with the `instance_number(o_onlineleaderboardsmini) = 2` layout there can be four or more requests in flight at once, which the serialising queue turns into a FIFO (this also avoids the "entries handle is only valid for the most recent download" hazard; **test item**, not asserted either way). Workshop boards use `"CL_" + lbname`.

### 5.3 `objects/o_onlineleaderboardCH/Other_69.gml`

Orphan (not in `.yyp`/`.resource_order`, not referenced by any room or script; `Draw_0.gml` just prints "Will do this very soon :)"). It also re-issues `tcc_steam_download_scores(...)` on **every** Steam async event (line 2) and `ds_map_destroy`s sub-maps it does not own. Do not port; delete the folder or leave it (it is never compiled). `Create_0.gml:4` uses the removed constants.

### 5.4 `objects/o_settings/Other_69.gml` (+ `Create_0.gml:35`, `Alarm_0.gml`)

Reads `id`, `entries` -> `name`, `score`, `rank` into `steam_name/score/rank[0..10]` (no `tcc_steam_initialised()` guard). `Alarm_0` re-arms every 10 steps until `foundrank == 1`, matching `steam_name[i] = name` where `name = tcc_steam_get_persona_name()` (`Create_0.gml:27`) to set the cog sprite (gold/silver/bronze/normal) and `global.foundcog`.
New: `Create_0.gml:35` -> `tcc_steam_download_scores("Cog Distance", 1, 10, method({owner: id}, function(_rows){ if (!instance_exists(owner) || is_undefined(_rows)) return; with (owner) { for (var i = 0; i < array_length(_rows); i++) { steam_name[i] = steam_friends_get_friend_persona_name(_rows[i].steam_id_user); steam_score[i] = _rows[i].score; steam_rank[i] = _rows[i].global_rank; } } }))`; delete `Other_69.gml`.
Gotchas: (1) name matching is fragile; a cleaner equivalent is storing `steam_id_user` and comparing with `steam_user_get_steam_id()` (int64, API.gml:14730), but that changes the non-Steam behaviour below. (2) **Existing quirk:** on non-Steam builds `name` is `""` and `steam_name[0]` is `""`, so `Alarm_0` line 2 is true and every non-Steam run gets the gold cog (`global.foundcog = 4`). Preserve or fix deliberately. (3) With 3.0, if the callback never fires (IO failure) the alarm loop just keeps polling every 10 steps (cheap, same as before when the event was lost). (4) `distance` uploads at `Step_0.gml:20,22` are fractional -> `floor` in the wrapper; note line 22 (`x < -450`) is unreachable behind line 20's `x < 950` check, so `Cog Distance` is never force-updated (pre-existing).

### 5.5 `objects/o_checkplayercount/Other_69.gml` and `objects/o_version/Other_69.gml`

Both read `async_load[? "event_type"] == "number_of_current_players"`, `async_load[? "success"]`, `async_load[? "players"]` and set `busy=false`, `success=true`, `global.playercount = players`. In 2.x **every** instance received every Steam event, so each object overwrote `global.playercount` regardless of who asked; in 3.0 only the requester's callback runs.
New: callback struct `{success, players}` handled once inside the wrapper (section 4, writes `global.playercount`). `Create_0.gml:19` / `Alarm_0.gml:8` / `o_version/Create_0.gml:18` keep `if (tcc_steam_get_number_of_current_players()) busy = true;` (wrapper returns true = request issued). **Delete both Other_69.gml files** and the `o_version/Step_0.gml` polling block (delete the block *with* Other_69, otherwise `busy` stays true and one spurious request plus a transient `global.playercount = 1` result, see 3.9). `busy` can still stick (no callback on IO failure) - harmless because nothing reads it; `o_checkplayercount/Alarm_0.gml:2-4` resets it every 500 steps anyway.

### 5.6 `tcc_steam_update()` (init/update agent owns the file, this domain adds the stats flush)

`scripts/scr_steam_safe/scr_steam_safe.gml:310-313` -> section 4 version.

---------------------------------------------------------------------------------------------------

## 6. Functions the project does NOT use (for completeness; names and signatures verified in `yy` and `API.gml`)

| 2.x | 3.0 | Notes |
|---|---|---|
| `steam_upload_score(lb, score)` | same two-step as 3.5 with `KeepBest` | |
| `steam_upload_score_buffer[_ext]` | `steam_userstats_upload_leaderboard_score(h, method, score, _score_details, cb)` | details are an int32 array (max `k_cLeaderboardDetailsMax` 64), not a buffer; base64 `data` becomes `details[]` |
| `steam_get_leaderboard_entry_count(lb)` | `steam_userstats_leaderboard_entry_count(_leaderboard_handle)` (API.gml:19838) | by handle |
| `steam_get_leaderboard_display_type(lb)` | `steam_userstats_leaderboard_display_type(_leaderboard_handle)` (API.gml:19882); also `steam_userstats_leaderboard_sort_method` (19858) | |
| `steam_clear_achievement(n)` | `steam_userstats_clear_achievement(achievement_name)` (direct native, yy) + `steam_userstats_store_stats()` | |
| `steam_indicate_achievement_progress(n,c,m)` | `steam_userstats_indicate_achievement_progress(achievement_name, cur_progress, max_progress)` (direct native) | outcome via `steam_userstats_set_callback_user_stats_stored` / `_user_achievement_stored` |
| `steam_set_stat_int/float`, `steam_set_stat_avg_rate` | `steam_userstats_set_stat_int(stat_name, data)`, `steam_userstats_set_stat_float(stat_name, data)`, `steam_userstats_update_avg_rate_stat(stat_name, count_this_session, session_length)` (direct natives) + `store_stats` | `session_length` is in seconds |
| `steam_get_stat_int/float/avg_rate` | `steam_userstats_get_stat_int(_stat_name)` (API.gml:19439), `steam_userstats_get_stat_float(_stat_name)` (API.gml:19464; **also the replacement for `steam_get_stat_avg_rate`**) | 2.x `steam_get_stat_avg_rate` called `GetStat(name, &float)` (old-cpp 1394-1417), exactly what `get_stat_float` does (new-cpp gm_steam_userstats.cpp:62-77). Both getters return `undefined` on failure where 2.x returned 0.0. There is no separate avg-rate getter, and none is needed. |
| `steam_stats_ready()` | none (2.x always returned 1) | |
| `steam_request_global_stats(days)` etc. | `steam_userstats_request_global_stats(_history_days, _callback)` (API.gml:20200), `steam_userstats_request_global_achievement_percentages(_callback)` (20125), `steam_userstats_global_stat_int64(_stat_name)` (20227), `_global_stat_double(_stat_name)` (20252), `_global_stat_history_int64(_stat_name)` (20277), `_global_stat_history_double(_stat_name)` (20300) | these two request calls (and `request_user_stats`, `attach_leaderboard_ugc`) are the only ones whose callbacks report IO failure (new-cpp gm_steam_userstats.cpp:693, 862, 900, 918) |

---------------------------------------------------------------------------------------------------

## 7. Test checklist (what to verify once it runs against the real Steam client)

1. Award a new achievement: overlay toast appears within a frame or two and the unlock shows on the profile (proves the store flush). Award the same one twice: no error. Also award one very early after launch (proves "stats synced on init", medium confidence).
2. `achievement_earned` with Steam running vs offline vs `platform_steam() == false`: always returns a real bool; achievements room renders (no `undefined` in `!`).
3. Leaderboards room: hold left/right quickly; the displayed rows always match the title (token filtering). Leave the room mid-download: no error in the log (instance_exists guard). Press the reload button and the friends toggle (`o_friendleaderboardsettings`) while a download is pending: last request wins, no stale rows.
4. Friends toggle (`global.friendleaderboardsettings`) returns only friends; >100 friends does not overflow arrays.
5. Names show and avatars load for non-friends (`steam_friends_get_friend_persona_name` may return `""`/`"[unknown]"` until Steam has the persona; if so request `steam_friends_request_user_information(id, true)` in the friends domain).
6. `r_endlessrunmenu` / `r_gameoverscreen` / `r_dailylevelwin` with two mini boards: both fill correctly (concurrent-download test). Press the reload button there (it reloads every mini instance).
7. Two same-frame uploads (`o_playerdead`): both reach Steam. Forced upload: `o_dailylevel/Create_0.gml:31` (only in `r_gamemode`, when `diff >= 14`) now forces a reset to 0 on the first visit of a session; this is a behaviour change versus 2.x (see 3.5), confirm it is what you want. `scr_timing_gameplay.gml:194` cannot be tested (dead, `global.cheats` is already 1).
8. Workshop win: `CL_<id>` board gets created and the score lands on the first run (create+upload ordering).
9. Player count appears on the title screen after a few seconds and refreshes every 500 steps; no per-frame requests; `global.playercount` never flashes to 1.
10. Steam client offline/not logged in: no hard error, rows stay "LOADING", queue recovers after the 20 s watchdog.

---------------------------------------------------------------------------------------------------

## 8. Open questions / hand-offs / unresolved

- **init/update:** `steam_initialised()` -> `steam_api_is_initialized()` (direct native, yy line 22, Real) and `steam_update()` -> `steam_api_run_callbacks()` (yy line 26). Every guard in this map assumes that mapping. `tcc_steam_init` (`steam_init()`) is not needed in 3.0 ("the extension initialises itself", getting_started.md).
- **friends/avatars:** persona-name lookup for leaderboard rows, `tcc_steam_get_persona_name` (`steam_friends_get_persona_name()` is a direct native, yy line 75), avatar fetch for `steam_id_user`, and the `avatar_image_loaded` half of both leaderboard Other_69 files (3.0 has one global `steam_friends_set_callback_avatar_image_loaded` slot; fan-out needed for two mini instances; `SteamFriendsAvatarImageLoaded.steam_id_64` is the new key, API.gml:1799-1809, so `string(...)` keys must match the `string(steam_id_user)` keys used by `avatar_sprites`).
- **tools/check_port.py:79:** regex must be extended with `userstats_|api_` (and whatever other prefixes other domains add), otherwise raw 3.0 calls outside `scr_steam_safe` / `scr_platform_services` pass silently.
- **Unverified (cannot be settled from the sources):**
  1. What Steam does with an invalid value (`SteamLeaderboardUploadScoreMethod.None` = 0) or with a leaderboard handle of 0 passed to `UploadLeaderboardScore` / `DownloadLeaderboardEntries` (invalid API call and therefore no callback, or a failed result). Both are documented here as "avoid", not as a specific outcome.
  2. Behaviour of a GML method bound to a destroyed instance when invoked via `method_call`.
  3. Whether Steam invalidates an older `entries_handle` when a second `LeaderboardScoresDownloaded_t` arrives before the first is consumed by GML (the extension's dispatcher defers GML delivery by up to one frame). The queue in section 4 makes this moot.
  4. "Stats are synced on init since SDK 1.61" (medium): sourced only from 2.x code comments (old-cpp 1938, 1953); the 3.0 docs are silent. Whether `steam_userstats_get_achievement` can legitimately return `undefined` for a defined-but-not-yet-synced achievement shortly after launch is also open; the wrapper handles it either way.
  5. What GameMaker's `real()` does to an int64 (the lossy `real(entry_user_id)` hazard is analysed from the 2.x JSON path, not from a runtime run).
  6. Whether `__ext_core_function_register` handles registered for a call that then fails to dispatch (`k_uAPICallInvalid`) are ever released. Not checked; negligible unless dispatch failures are frequent.
- Deliberately not changed: `o_steamachievementreset` is reachable in release builds; the o_settings non-Steam gold-cog quirk; `o_version` `http_get` leftovers; the (optional) dedupe of the `o_dailylevel` streak reset.

---------------------------------------------------------------------------------------------------

## 9. Decisions on the verifier disputes

Verdicts: ACCEPTED (dispute is right, text corrected), NARROWED (right in part), REJECTED (dispute is wrong). Numbers follow the order the disputes were raised; the two duplicates are merged.

1. **Async functions "return undefined" (create / download* / upload / player count): ACCEPTED.** The GML wrappers end in `return __return_value__;` (API.gml:19783, 19811, 19942, 20065, 20119) and the natives end in `return 0;` (new-native 4459, 4473, 4549, 4607, 4635). `undefined` only comes from `if (!__available__) return;`. A failed dispatch also returns 0. Corrected in section 0 item 3, 3.1, 3.5, 3.9; the wrapper's `true` is documented as "enqueued/issued".
2. **"Never call with an unresolved/0 handle (show_error abort)": ACCEPTED.** The guard is `if (!is_numeric(_leaderboard_handle)) show_error(..., true)` (API.gml:19919 download, 20036 upload). 0 is numeric and passes; only undefined/non-numeric aborts. The advice "check `leaderboard_found` first" stands, the reason is a silent stall (outcome unverified). Corrected in section 0 item 6 and 3.2/3.5.
3. **Passing the bool as the method "silently breaks forcing": ACCEPTED (broader).** None=0/KeepBest=1/ForceUpdate=2 (API.gml:1442-1447); the number is cast into the Steam enum (new-cpp gm_steam_userstats.cpp:822). false->None (invalid value), true->KeepBest: both paths break. Steam's handling of `None` is undocumented here, so it is called "invalid value", no outcome is claimed. The docs wording of the members is indeed copy-pasted (docs3:1088-1089), noted. Corrected in section 0 item 7 and 3.5.
4. **`request_global_stats` signature: ACCEPTED.** `steam_userstats_request_global_stats(_history_days, _callback)` (API.gml:20200); its CallResult has `ReportIoFailure=true` (new-cpp gm_steam_userstats.cpp:918). Fixed in section 6 and entry 13. All other function signatures in the "unused" entry were checked against `yy` and `API.gml` too, so the entry's confidence is raised to high.
5. **`steam_update` composition / "steam_init_new.cpp does not exist" / "SDK 1.61 autoload": REJECTED for the file claim, NARROWED for 1.61.** The file exists in git HEAD: `git show HEAD:extensions/Steamworks/steamworks_cpp/GMLSteam/steam_init_new.cpp` lines 22-37 are `steam_update` = `SteamAPI_RunCallbacks(); Steam_UserStats_Process();` (copy saved to `port/old2x_cpp/steam_init_new.cpp`); the verifier looked only in the scratchpad extract. `Steam_UserStats_Process` is verified (old-cpp 1973-1986). The "synced on init since 1.61" statement comes from 2.x code comments (old-cpp 1938, 1953) and is marked medium confidence. The suggested "retry failed awards" is not needed for parity: 2.x set the store flag only when `SetAchievement` returned true (old-cpp 1171-1175), so an early award with stats not loaded was lost in 2.x as well; optional improvement only.
6. **"28 call sites in 15 files": ACCEPTED.** Re-counted: 27 external call sites in 15 files plus the internal delegation at `scr_platform_services.gml:198`. `r_dailylevelwin` was already listed in both the original md and the JSON; the table is now spelled out per file.
7. **"2.x often did not force at all" (SLBRequest has no force field): ACCEPTED on the facts, NARROWED on the consequences.** Verified: `SLBRequest` (old-cpp 79-130) has no force field; `DoLBRequest` always uses KeepBest (265-275); only the direct path (cached handle) forces (656 vs 659). But after the first queued find resolves the handle is cached for the session (old-cpp 388-391), so every later forced upload in that session did force. Net change: the first forced upload per board per session now forces too; severity downgraded from "risky" to a documented behaviour change. The claimed new rate-limit cost does not exist: the same upload was already issued in 2.x on every `r_gamemode` visit with `diff >= 14`. New finding while checking: `scr_timing_gameplay.gml:191` sets `global.cheats = 1` right before the forced reset at :194, and `platform_submit_score_ext` returns false at `scr_platform_services.gml:202` when `cheats != 0`, so that reset never uploads in either version. Test item 7 rewritten to target only `o_dailylevel/Create_0.gml:31` (placed in `r_gamemode` only).
8. **"Async functions return undefined, so the tcc wrapper contract 'true once dispatched' is misleading": ACCEPTED** (same fact as 1). The wrapper's `true` now means "preconditions passed and request enqueued/issued"; a dispatch failure is visible only through a missing callback (watchdog) and `steam_api_last_error()` (read immediately after the call, because `STEAM_GUARD` clears it on every guarded call: `GMSteamworks.h:59-67`). No `is_undefined()` checks on the result.
9. **create_leaderboard "event sent immediately, commented-out completion at 546-552": ACCEPTED.** Events are sent only when the name is already in the table (`status 1` cached at old-cpp 435; `status 0` pending at 445 and 462); the first call for a name (471-477) sends nothing. The commented-out completion event is at old-cpp 393-398 (inside `OnFindLeaderboardResult`), not 546-552 (that range is in `OnUploadScoreResult`). 2.x `status` therefore meant cached/pending, not created/existed. No behaviour change for the project (nothing listens). Corrected in 3.1.
10. **"Never pass an unresolved handle (show_error abort)" in the upload and download gotchas and md section 0 item 6: ACCEPTED** (duplicate of 2; the cited lines in the dispute, 19929/20048, are off, the real guards are 19919 and 20036).
11. **"2.x always delivered an event on IO failure" / "only three calls report IO failure": ACCEPTED.** Find/create IO failure was retried silently with no event (old-cpp 346-361); download, upload and player count did deliver failure events (977-990, 523-570, 1111-1128). 3.0 reports IO failure for four calls: `request_user_stats` (gm_steam_userstats.cpp:693), `attach_leaderboard_ugc` (:858-862), `request_global_achievement_percentages` (:900), `request_global_stats` (:918). Corrected in section 0 item 4.
12. **`real(entry_user_id)` "would request the wrong user" as a 3.0 regression: ACCEPTED.** It is pre-existing: in 2.x `userID` came from `@i64@<hex>$i64$` as an int64 (old-cpp 1022-1031) and the same `real()` already narrowed it at `o_onlineleaderboards/Other_69.gml:35` and `o_onlineleaderboardsmini/Other_69.gml:39`. The fix (pass `e.steam_id_user` unchanged) is unchanged. What the GameMaker runtime does inside `real(int64)` is listed as unverified.
13. **Player count "bool" return and "request per frame" claim: ACCEPTED.** 2.x returned Real 1/0 (old-cpp 1885-1887). With the proposed wrapper, `Step_0` would start exactly one extra request (the wrapper returns false while its in-flight flag is set; after the callback the next Step starts one request and sets `global.playercount = true` (1) until that request's callback overwrites it), not one per frame. Recommendation (delete the Step_0 block together with `Other_69.gml`) unchanged; reason corrected in 3.9 and 5.5.
14. **Hard-mode destroy in `o_onlineleaderboardsmini/Other_69.gml` "has to survive": ACCEPTED.** `Create_0.gml:1-4` already destroys in non-Steam and hard mode before any request, `Draw_0.gml:1-3` repeats it. The `Other_69` copy is redundant. `instance_exists(owner)` stays for room changes. Corrected in 5.2 and entry 11.
15. **Missing triggers for `reloadleaderboards()` / `reloadleaderboardsmini()`: ACCEPTED.** Verified `Step_0.gml:4,9,15,19`, `o_reloadleaderboardsbutton/Mouse_4.gml:4,8` (the latter via `with (o_onlineleaderboardsmini)`), `o_friendleaderboardsettings/Mouse_4.gml:5`, `Alarm_0.gml:14,23,32`, `Create_0.gml:37/89`. Added to section 2, 5.1, 5.2, entries 2-4 and test items 3 and 6. The token + FIFO design already covers them.
16. **"md section 2 table omits r_dailylevelwin": REJECTED as stated (the md's table row did list `r_dailylevelwin`), only the count was wrong** (see 6).
17. **"No avg-rate getter in 3.0": ACCEPTED.** 2.x `steam_get_stat_avg_rate` called `GetStat(name, &float)` (old-cpp 1394-1417), which is what `steam_userstats_get_stat_float` does (new-cpp gm_steam_userstats.cpp:62-77, API.gml:19464). The map now says "no separate getter, none needed", and notes `undefined`-on-failure versus 2.x's 0.0.

Extra checks run by the resolver (not raised by the verifiers): 304 achievement call sites in 44 files re-counted (matches); no use of any unused stat/upload function re-grepped (matches); `STEAM_GUARD` clears the last error at every guarded call (GMSteamworks.h:59-67); docs3 member descriptions of `SteamLeaderboardUploadScoreMethod` are wrong (docs3:1088-1089).
