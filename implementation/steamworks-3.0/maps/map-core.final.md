# Steamworks 2.1.6 -> 3.0.0 migration map (FINAL, resolver pass): core / init / app / user / overlay-state

Project: /Users/infi/Documents/Github/TheColorfulCreature, branch feat/steamworks-3-0. Read-only analysis. This file supersedes map-core.md; the machine-readable twin is map-core.final.json (24 entries, same fields as the original structured entries).

Abbreviations: `API.gml` = scripts/Steamworks_API/Steamworks_API.gml (3.0 GML layer). `SAFE` = scripts/scr_steam_safe/scr_steam_safe.gml (project wrappers). `SRC30` = extensions/Steamworks/source/src (3.0 C++ source shipped in the project). `NATIVE` = extensions/Steamworks/source/code_gen/native/SteamworksInternal_native.cpp. `OLDSRC` = /Users/infi/Documents/Github/GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam (old C++ source, tagged 2.2.0 on disk; the project had 2.1.6, tiny behavioural drift for these trivial functions is possible but unlikely).

## 0. Decisions on the verifier disputes

17 disputes were raised; each was re-checked against the source (not just accepted). Result: 11 accepted (one of them, #9, rewritten), 3 accepted in modified form (#7 guard, #10 mitigation, #12 callback rule), 3 folded into a sibling dispute (#4 into #7, #15 into #5, #17 into #3). Field `result_delivery` uses the other domains' vocabulary (`sync`, `callback`, `event-removed`, `constant-or-enum`); the only two compound tokens are `sync+callback` (screenshot) and `callback+sync` (steam_id_owner).

| # | Entry | Sev. | Verdict | Evidence and what changed |
|---|---|---|---|---|
| 1 | steam_id_owner: "delivered via callback struct" | risky | ACCEPTED | `SteamUgcQueryResult` (API.gml:2532, `owner_steam_id` at :2554) is the RETURN value of the sync getter `steam_ugc_get_query_ugc_result(_query_handle,_index)` (API.gml:16630-16637). The callback of `steam_ugc_send_query_ugc_request(_query_handle,_callback)` (API.gml:17390) receives `SteamUgcQueryCompleted { query_handle, result, num_results_returned, total_matching_results, cached_data }` (API.gml:2637-2650): no owner. A field literally named `steam_id_owner` exists only in `SteamRemoteStorageUgcDetails` (API.gml:3628-3640) and `SteamRemoteStorageDownloadUgcResult` (API.gml:3679-3692): wrong target. Entry rewritten to `callback+sync` with the full create/send/get/release sequence; also records that o_playmostrecentlevelCL is dead per map-ugc.md. |
| 2 | steam_init: hazard of calling steam_api_init overstated | nit | ACCEPTED | `steam_api_init` clears the last error, then returns true immediately when already initialised (gm_steam_api.cpp:227-232). The RestartAppIfNecessary/`std::exit(0)` branch (gm_steam_api.cpp:252-262) is reached only when not yet initialised and Debug != Enabled, the pre-graphics hook (gm_steam_api.cpp:206-219) runs the same logic at startup, and 2.x had the same exit (OLDSRC steam_init_new.cpp:104-108). Advice "do not use it as the body of tcc_steam_init" kept, reason reworded. |
| 3, 17 | steam_is_overlay_enabled: overlay struct listed with only the `active` field | nit | ACCEPTED (duplicate pair) | `SteamFriendsGameOverlayActivated` has `active, user_initiated, app_id` (API.gml:1902-1913); setter `steam_friends_set_callback_game_overlay_activated` at API.gml:13782. Fixed. |
| 4, 7 | steam_user_set_played_with: id source + show_error risk | nit + risky | ACCEPTED (merged), guard MODIFIED | The only caller `net_register_player` (scr_online_multiplayer.gml:777-805) gets `_sender` from the packet receive loop (callers :715/:722/:740, `_sender` at :694), not from a lobby lookup. The 3.0 wrapper (API.gml:13735-13749) calls `show_error(..., true)` on a non-number, which aborts the game; the 2.x native coerced with YYGetInt64 and never aborted; the native is void (SRC30/gm_steam_friends.cpp:763-771). Wrapper gets an `is_numeric(_a0) && _a0 != 0` guard. Modification: the guard does NOT test `is_int64`, because the int64-ness of a `buffer_read(buffer_u64)` value is not runtime-proven (a false negative would silently disable the call). Instead the networking domain is obligated to return an int64 (a double passes is_numeric but is wrong above 2^53), enforced by the is_int64 smoke test. |
| 5, 15 | steam_name/rank/score (and userid): call_sites incomplete | nit | ACCEPTED (merged) | Full grep over scripts/objects/rooms; entries now list every Create/Draw/Other_69/Alarm line. Producers that go dead with the Async-Steam event: o_settings/Other_69.gml:19-21, o_onlineleaderboards/Other_69.gml:20-22, o_onlineleaderboardCH/Other_69.gml:21-23, o_onlineleaderboardsmini/Other_69.gml:24-26 (steam_userid: o_onlineleaderboards/Other_69.gml:30, o_onlineleaderboardsmini/Other_69.gml:34). `o_settings` was wrongly listed as "no core dependency" in section 5 of the original; it is a leaderboard producer. The leaderboards map already covers it (map-stats.md:420). |
| 6 | steam_initialised: doc path without directory | nit | ACCEPTED | `steam_api_is_initialized` is at NATIVE:36-40 and `steam_api_run_callbacks` at NATIVE:60; `src/native/` contains only Steamworks_native.cpp/.h. Full path used everywhere. |
| 8 | steam_init: IDE / non-Steam launch behaviour changed | risky | ACCEPTED | Old `debug = Enabled ? true : isRunningFromIDE()` (OLDSRC steam_init_new.cpp:64); new `debug = (option == "Enabled")` only (gm_steam_api.cpp:105-110). options/extensions/Steamworks.json HAS an entry for the Debug GUID 96a61e5d-c4ac-4104-b5ac-c8ef936e2609 and its value is null (file unchanged from HEAD), so the option is Auto (the original map said there was no entry: corrected). With Auto, the else-branch deletes steam_appid.txt and a non-Steam launch exits (gm_steam_api.cpp:252-262). Recorded in the steam_init gotchas; per-configuration choice left as a user decision (section 7). |
| 9 | open question 8: Check/QA mac packages carry the dylib and would exit(0) | nit | ACCEPTED, rewritten | The yyp config tree puts `Check` and `QA` under `Apple` (children of Default > Apple); Steamworks.yy `ConfigValues` has `Apple.copyToTargets = "0"`; scr_platform.gml:12 already relies on Apple inheritance (`#macro Apple:TCC_STEAM false`); tools/build.py:448-451 raises if a non-Steam package contains a *steam*.dylib. The exit(0) claim is dropped. Residual: inheritance of extension ConfigValues to child configs is inferred, not proven: inspect a built Check package (section 7). |
| 10 | open question 1 mitigation via `global.appid` | risky | ACCEPTED (modified) | objects/o_title/Create_0.gml:28 runs `global.appid = tcc_steam_get_app_id();` on every o_title Create, and after a shutdown that wrapper returns the guard fallback false (SAFE:66-69), so the stored id is overwritten before any later code could use it; it is also the LAUNCHING app id (the demo is 1749610), not the extension option (1651680). Mitigation text replaced (section 7, item 1). Modification: the whole item stays UNRESOLVED because whether the runner calls the extension `final` function on `game_restart()` cannot be settled from the sources; it needs the runtime test. |
| 11 | steam_initialised: "false for the whole run" and last_error | nit | ACCEPTED | api.js:30 documents steam_api_init as the retry path, so the correct wording is "false until a successful retry" (the project never retries). `steam_guard_failed()` calls `steam_clear_last_error()` before every guarded native and sets "Steam API not initialized" when not initialised (SRC30/GMSteamworks.h:59-66), so the real init-failure text is reliable only at the earliest boot point, before any other guarded Steam native. `steam_api_is_initialized()` does not clear it. Not claimed: that o_version/Create_0.gml:8 is the first guarded call (unverified). |
| 12 | steam_update: "use non-instance-bound functions" | nit | MODIFIED | Verified ExtensionCore_api.gml:350: `with (_dummy_context) method_call(_ref[0], _args)` where `_dummy_context` is a shared static struct (:300). An UNBOUND callback (bare script-function reference) runs with self = that shared struct, so instance-variable writes leak onto it; a callback bound with method(target, fn) (or a function literal created inside an instance) keeps its own bound self, so the rule is "bound target must be alive when the tick fires". New rule: bind to a plain struct (per-call context struct or a global struct the project owns, as map-ugc.md does with `method({inst:id,...}, fn)`), never to an instance; check `instance_exists()` on captured instance ids. The earlier advice to bind through an undefined target is dropped. |
| 13 | steam_send_screenshot: delivery is only `sync` | nit | ACCEPTED | screenshots.js:10 says the result is delivered through the callback; only the handle (0 on failure) is synchronous (gm_steam_screenshots.cpp:116-140); `SteamScreenshotsScreenshotReady { screenshot_handle, result }` at API.gml:2101-2110. `result_delivery` is `sync+callback`. |
| 14 | steam_userid: `real()` truncates the id | risky | ACCEPTED as a handoff | `tcc_steam_get_user_avatar(real(entry_user_id), ...)` at o_onlineleaderboards/Other_69.gml:35 and o_onlineleaderboardsmini/Other_69.gml:39. Steam64 ids (~7.6e16) exceed 2^53 (~9.0e15), so real() rounds them. Pre-existing: the old JSON carried the id as `"@i64@hex$i64$"` (OLDSRC steam_userstats.cpp:1024-1026). Already tracked by the leaderboards and social maps (map-stats.md:408, map-social.md:20,144,337); not a core-domain edit. Added to the steam_userid entry. |
| 16 | steam_id_owner: wrong line for the owner compare | nit | ACCEPTED | objects/o_workshopchallengecreator/Step_0.gml: `my_steam_id` at :29, `show = (btn.owner_id == my_steam_id)` at :37 (line 35 is `if filter_mode = 1 {`). Fixed here and in section 3.4. |


## 1. Summary table (old -> new)

| Old (2.x) | Project wrapper (SAFE line) | New (3.0) exact call | Delivery | Confidence |
|---|---|---|---|---|
| `steam_init()` | `tcc_steam_init` (98) | none needed (auto init pre-graphics). Use `steam_api_is_initialized()` | sync | high |
| `steam_initialised()` | `tcc_steam_initialised` (102) + 77 guard uses | `steam_api_is_initialized()` | sync | high |
| `steam_update()` | `tcc_steam_update` (310) | `steam_api_run_callbacks()` | sync (pump) | high |
| `steam_is_user_logged_on()` | `tcc_steam_is_user_logged_on` (146) | `steam_user_logged_on()` | sync | high |
| `steam_get_app_id()` | `tcc_steam_get_app_id` (66) | `steam_utils_get_app_id()` | sync | high |
| `steam_get_user_steam_id()` | `tcc_steam_get_user_steam_id` (86) | `steam_user_get_steam_id()` | sync (int64) | high |
| `steam_send_screenshot(file,w,h)` | `tcc_steam_send_screenshot` (222), 0 callers | `steam_screenshots_add_screenshot_to_library(abs_file, "", w, h)` | sync handle + ScreenshotReady callback | medium |
| `steam_is_overlay_enabled()` | `tcc_steam_is_overlay_enabled` (22) | `steam_utils_is_overlay_enabled()` | sync | high |
| `steam_user_owns_dlc(id)` | `tcc_steam_user_owns_dlc` (318) | `steam_apps_is_subscribed_app(app_id)` | sync | high |
| `steam_user_installed_dlc(id)` | `tcc_steam_user_installed_dlc` (314), only commented-out use | `steam_apps_is_dlc_installed(app_id)` | sync | high |
| `steam_user_set_played_with(id)` (friends domain, wrapper in SAFE) | `tcc_steam_user_set_played_with` (38) | `steam_friends_set_played_with(steam_id)` (guarded) | sync | high |
| `steam_is_available` | not an API: `global.steam_is_available` | keep | n/a | high |
| `steam_api` | not an API: `global.steam_api` | keep | n/a | high |
| `steam_id`, `steam_name`, `steam_rank`, `steam_score`, `steam_userid`, `steam_list`, `steam_details` | not API: project struct members / instance vars | keep (value types change in other domains) | n/a | high |
| `steam_id_owner` | async_load map key (old UGC events) | `steam_ugc_get_query_ugc_result(handle,i).owner_steam_id` inside the `SteamUgcQueryCompleted` callback (UGC domain) | callback+sync | high |
| `steam_display`, `steam_player_group`, `steam_player_group_size` | Steam-defined rich-presence KEY strings | unchanged strings, set via `steam_friends_set_rich_presence(key, value)` (friends domain) | n/a | high |


## 2. Cross-cutting facts that change behaviour (verified in source)

### 2.1 Initialisation lifecycle
* 2.1.6 yy: `Steamworks.ext` had `init = "steam_init"`, `final = ""` (old2x Steamworks.yy lines 271, 561). The real init was `OldPreGraphicsInitialisation()` (OLDSRC/steam_init_new.cpp:53-124). The exported `steam_init()` never initialised anything: it returned 1 if the flag `steam_is_initialised` was already set (steam_init_new.cpp:40-53). So `tcc_steam_init()` was always just "is Steam up".
* 3.0 yy: `init = ""`, `final = "steam_api_shutdown"` (extensions/Steamworks/Steamworks.yy lines 20, 642). Init is a native pre-graphics hook that runs exactly once per process (`GM_REGISTER_INIT_HOOK`; `gm::RunInitHookOnce` is a `std::call_once`; SRC30/gm_steam_api.cpp:206-219, extensions/Steamworks/source/code_gen/core/GMExtUtils.cpp:81-87). It reads the `appID` extension option (options/extensions/Steamworks.json: `2d512363-...` = `1651680`).
* `steam_api_init(app_id)` still exists but is `hidden: true` (Steamworks.yy args [2], ret 2). It clears the last error, returns true immediately if already initialised (gm_steam_api.cpp:227-232), and only otherwise runs the Debug logic: with Debug == Enabled it writes steam_appid.txt; otherwise it deletes steam_appid.txt, calls `SteamAPI_RestartAppIfNecessary` and `std::exit(0)`s if the process was not launched through Steam (gm_steam_api.cpp:252-262). That exit already ran in 2.x (OLDSRC steam_init_new.cpp:104-108) and runs in the startup hook. Do not use it as the body of `tcc_steam_init`; it matters only as a retry after a failed automatic init (api.js:30).
* On shutdown (`steam_api_shutdown`, run at game end through `final`) every registered callback is cleared (gm_steam_api.cpp:113-204, 307-318) and the init flag is dropped. The init hook never runs again in the same process: see section 7 item 1 (`game_restart`).
* Debug behaviour changed: OLD `debug = (option=="Enabled") ? true : isRunningFromIDE()` (steam_init_new.cpp:64), so IDE runs implicitly wrote `steam_appid.txt`. NEW `debug = (option == "Enabled")` only (gm_steam_api.cpp:105-110). Docs (extension_options.md, getting_started.md:23) say IDE runs need Debug=Enabled; with Auto a non-Steam launch is relaunched through Steam and the IDE-started process exits. options/extensions/Steamworks.json contains the Debug GUID `96a61e5d-c4ac-4104-b5ac-c8ef936e2609` with value null (unchanged from HEAD), i.e. Auto. The per-configuration choice is a user decision (section 7 item 2).

### 2.2 Pumping and callback delivery (replaces steam_update + the Async-Steam event)
* Old `steam_update()` = `SteamAPI_RunCallbacks(); Steam_UserStats_Process();` returning 1 when initialised else 0 (OLDSRC/steam_init_new.cpp:22-37). Results arrived through the Async-Steam event (`async_load[? "event_type"]`).
* New `steam_api_run_callbacks()` (native, 0 args, ret double 0; SRC30/gm_steam_api.cpp:300-304; NATIVE:60) only calls `SteamAPI_RunCallbacks()`. The 3.0 source never raises a GameMaker Async event (only unused function-pointer slots in code_gen/core/GMExtUtils.h:119-120). So EVERY `Other_69.gml` Steam handler becomes dead code.
* How GML callbacks fire (scripts/ExtensionCore_api/ExtensionCore_api.gml:240-371): native callbacks go onto a native `DispatchQueue`; a `time_source_global` ticker (1-frame period, started when any callback is registered) calls the dispatch routine, which unmarshals the args and runs `with (_dummy_context) method_call(_ref[0], _args)` (line 350; `_dummy_context` is a shared static struct, line 300). So callbacks run on the next time-source tick after `steam_api_run_callbacks()` queued them, not inside that call as the docs claim.
* Self rule (corrected, dispute 12): an UNBOUND callback (bare script-function reference) runs with self = the shared dummy struct, so instance-variable writes silently land there; a callback bound with `method(target, fn)`, or a function literal created inside an instance, keeps its own bound self, and a bound instance destroyed before the tick makes the callback run against a dead self. Bind callbacks to a plain struct (per-call context struct or a global struct the project owns), never to an instance, and test `instance_exists()` for captured instance ids. o_fullscreensystem is a poor owner: it is destroyed by objects/o_endingreq/Create_0.gml:3.
* `steam_*_set_callback_*` stores one slot per event (SRC30/gm_steam_friends.cpp:1090-1095): registering again replaces the previous callback; registration works before init. `steam_api_shutdown` wipes all slots.
* Pump site: objects/o_fullscreensystem/Step_0.gml:4 `if (platform_steam()) tcc_steam_update();` runs AFTER `if (!timing_instance_step()) exit;` (line 1), so it only pumps on simulation ticks (TCC_SIM_HZ = 60, scr_timing.gml:4; docs need >= 10 Hz). o_fullscreensystem is persistent but destroyed by objects/o_endingreq/Create_0.gml:3 and recreated by objects/o_loading/Create_0.gml:13, so the pump stops while it is absent (pre-existing).

### 2.3 Availability guards and values returned when Steam is not usable
* `API.gml` wrapper functions start with `__Steamworks_is_available()` = `extension_exists("Steamworks")` (API.gml:24764-24768) and `return;` (undefined) if false. Functions marked "Skipping function ... (no wrapper is required)" are the raw extension natives (e.g. `steam_api_is_initialized`, `steam_user_logged_on`, `steam_utils_get_app_id`, `steam_utils_is_overlay_enabled`, `steam_apps_is_subscribed_app`, `steam_apps_is_dlc_installed`, `steam_screenshots_add_screenshot_to_library`) and do not have that guard.
* Extension 3.0 is not copied for `Apple` and `Mobile` configs (`ConfigValues {Apple:{copyToTargets:"0"}, Mobile:{copyToTargets:"0"}}`, Steamworks.yy:14; asserted by tools/check_port.py:21-24). Therefore the `platform_steam() &&` guard in every `tcc_steam_*` wrapper MUST stay (`platform_steam()` = scr_platform.gml:17). The guard is never needed for `Steamworks_API.gml` itself, only for calling the natives.
* Native fallbacks when the extension is present but Steam is not initialised (STEAM_GUARD_RET): `steam_user_logged_on` -> false, `steam_utils_get_app_id` -> 0, `steam_user_get_steam_id` -> 0, `steam_utils_is_overlay_enabled` -> false, `steam_apps_is_subscribed_app`/`steam_apps_is_dlc_installed` -> false, `steam_screenshots_add_screenshot_to_library` -> 0. Keep the wrapper-level guards so behaviour stays identical.
* Every STEAM_GUARD native clears the last error first (SRC30/GMSteamworks.h:59-66): see the steam_init gotchas for what that means for `steam_api_last_error()`.

### 2.4 ID types (answer to "SteamId struct or int64?")
* A Steam id is still a plain 64-bit integer. `steam_user_get_steam_id()` is declared `@returns {Real}` and returns `buffer_read(ret, buffer_u64)` (API.gml:14727-14742), i.e. an int64 value (old: `VALUE_INT64`, OLDSRC/steam_user.cpp:34-45). Every `_steam_id` parameter is `UInt64`, validated with `is_numeric` and written as `buffer_u64` (e.g. API.gml:13735-13749).
* `SteamId` (API.gml:1688) is only the return struct of `steam_user_decode_steam_id(_steam_id)` (API.gml:14748). Its `id64` is the same integer. No existing project call needs a struct.
* App ids/DLC ids are plain doubles (`steam_utils_get_app_id` returns `uint32` as double).
* Not verified at runtime: that GML hands back `buffer_u64` as an `int64`. The project compares ids with `==` against other int64 values (scr_online_multiplayer.gml:508,520,580,1095,1116; objects/o_workshopchallengecreator/Step_0.gml:37) and stringifies them (`string(...)` in badge_system.gml:199 and scr_online_session.gml:93), which only stays exact if they remain int64, not double. Hardening in the wrapper: `int64(steam_user_get_steam_id())`; add an `is_int64` smoke check.

### 2.5 Booleans are 1.0/0.0 doubles
Natives return `static_cast<double>(bool)` (NATIVE:36-40). Old `steam_initialised()` and `steam_user_owns_dlc()` returned real GML booleans (VALUE_BOOL); old logged-on/overlay/app-id returned doubles. All project call sites use them in `if`/`!`/`&&`/`= false`/`== 1749610` positions where 1/0 behaves identically. If anything ever tests `is_bool()` or `=== true`, wrap the wrapper result in `bool(...)`.

### 2.6 Build prerequisites that affect this domain (not editable by this phase)
* SDK mismatch BLOCKER: options/extensions/Steamworks.json sets the Steam SDK path to `../../sdk` (= /Users/infi/Documents/sdk). `shasum -a 256 .../sdk/redistributable_bin/osx/libsteam_api.dylib` = `b2260d2b...a82c0` (re-verified in this pass): the OLD 1.61 hash. 3.0 expects `sdkHashMac`/`sdkHashWin` for SDK 1.65 (extensions/Steamworks/post_build_step.sh:216-217 reads them and asserts), so the first 3.0 build fails until an SDK 1.65 is placed there.
* App id: appID option = `1651680` (full game). The demo is `1749610` and is detected at runtime by `SteamUtils()->GetAppID()` (36+ call sites). That value follows how Steam launched the process, not the option, exactly like 2.x.


## 3. Per-identifier entries

### 3.1 steam_init
* New: steam_api_is_initialized()   // no init call is needed: the 3.0 extension initialises itself in a native pre-graphics hook (once per process) using the 'Application ID' extension option. Optional diagnostics: steam_api_last_error() -> String (read it at the earliest boot point, see gotchas). Do NOT use steam_api_init(own_app_id) as the body of tcc_steam_init: it is hidden (Steamworks.yy args [2] ret 2), it is a no-op returning true once the automatic init succeeded, and when it still has to initialise with Debug != Enabled it calls SteamAPI_RestartAppIfNecessary and, if the process was not launched through Steam, relaunches through Steam and std::exit(0)s.
* Delivery: `sync`; confidence: high
* Call sites: scripts/scr_steam_safe/scr_steam_safe.gml:98 (definition tcc_steam_init); objects/o_profilepicture/Create_0.gml:7 (only caller: `if !tcc_steam_init() { instance_destroy() }`)
* Callback struct / fields: none
* Signature changes: Old steam_init() took no args and only reported the init flag (0/1). 3.0 steam_api_init(own_app_id) is hidden and is the real initialiser; not needed because the extension calls it before the first frame. Wrapper body becomes: `if (platform_steam()) return steam_api_is_initialized(); return false;`
* Gotchas: (1) tcc_steam_init behaviour is unchanged (old steam_init never initialised anything, the real init was OldPreGraphicsInitialisation); but the INITIALISATION behaviour changed for IDE and non-Steam launches: old `debug = Enabled ? true : isRunningFromIDE()` (steam_init_new.cpp:64) so IDE runs wrote steam_appid.txt and worked; new `debug = (option == "Enabled")` only (gm_steam_api.cpp:105-110). options/extensions/Steamworks.json HAS an entry for the Debug GUID 96a61e5d-c4ac-4104-b5ac-c8ef936e2609 and its value is null (unchanged from HEAD), so the option is Auto: any run that was not launched through Steam (an IDE run, a tester build, a Steam-config build started outside Steam) deletes steam_appid.txt, hits SteamAPI_RestartAppIfNecessary and std::exit(0)s before the first frame. IDE/dev runs need Debug=Enabled; shipping Steam builds must stay Auto (the build step warns while Enabled). How to scope it per configuration is a user decision (see unresolved). (2) Init hook is std::call_once and never re-runs in the same process; see the game_restart open question. (3) The exit(0) path is not new (2.x had it, steam_init_new.cpp:104-108) and the hook already runs it at startup, so a late steam_api_init call after a successful init is harmless; it is still not the right body for tcc_steam_init because it can only matter as a retry after a failed init. (4) steam_api_last_error(): steam_api_init clears it first; every STEAM_GUARD native clears it before each guarded call (src/GMSteamworks.h:59-66) and sets 'Steam API not initialized' when not initialised, so the real init-failure text is only reliable if read at the earliest boot point, before any other guarded Steam native call. steam_api_is_initialized() itself does not clear it. (5) Old yy had init='steam_init', final=''; 3.0 yy has init='' and final='steam_api_shutdown' (extensions/Steamworks/Steamworks.yy lines 20/642 vs old2x Steamworks.yy lines 271/561).
* ID types: n/a
* Doc refs: scratchpad gmext/src/docs/api.js (steam_api_init, steam_api_is_initialized, steam_api_last_error; api.js:30 says steam_api_init is only useful to retry after the automatic init failed); getting_started.md 'Initialising' (line 23: while developing from the IDE set Debug to Enabled); extension_options.md (Debug row); scripts/Steamworks_API/Steamworks_API.gml:12453-12459 (skip comments); extensions/Steamworks/source/src/gm_steam_api.cpp:105-110 (debug = option == "Enabled" only), :206-219 (pre-graphics hook), :227-283 (steam_api_init: clears last error at :229, returns true if already initialised at :231-232, deletes steam_appid.txt at :253, RestartAppIfNecessary + exit(0) at :256-260 when Debug != Enabled); GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam/steam_init_new.cpp:40-53 (old steam_init), :64 (old debug = option=="Enabled" ? true : isRunningFromIDE()), :104-108 (old RestartAppIfNecessary + exit(0))

### 3.2 steam_initialised
* New: steam_api_is_initialized()
* Delivery: `sync`; confidence: high
* Call sites (33 entries): scripts/scr_steam_safe/scr_steam_safe.gml:102 (definition tcc_steam_initialised; body at line 103); scripts/scr_steam_safe/scr_steam_safe.gml: 77 guard lines `platform_steam() && steam_initialised()` (mechanical whole-word replace of steam_initialised() with steam_api_is_initialized(); whole-word matching does not touch the wrapper name tcc_steam_initialised); users of tcc_steam_initialised (29 lines):; scripts/scr_tradeup/scr_tradeup.gml:81; ... (full list in map-core.final.json and Appendix A)
* Callback struct / fields: none
* Signature changes: Renamed (British 'initialised' -> American 'initialized'), no args, still returns a boolean-ish value.
* Gotchas: Native returns double 1.0/0.0 (old returned a real GML bool). All project uses are in if/!/&& positions so no change is needed; wrap in bool() only if something tests is_bool/===true. Keep `platform_steam() &&` in front of every native call (extension is not copied for Apple/Mobile configs; Steamworks.yy ConfigValues, asserted by tools/check_port.py:21-24). The value is a snapshot of the init flag: false until a successful retry (the project never retries; steam_api_init is hidden), so with the Steam client not running it is false for the whole run. To log the failure reason use steam_api_last_error() at the earliest boot point, because the guarded natives clear it (see steam_init gotcha 4); every wrapper stays gated on steam_api_is_initialized(), which does not clear it.
* ID types: n/a
* Doc refs: gmext/src/docs/api.js steam_api_is_initialized; scripts/Steamworks_API/Steamworks_API.gml:12456 (skip comment: raw native); Steamworks.yy: steam_api_is_initialized args [] ret 2; extensions/Steamworks/source/code_gen/native/SteamworksInternal_native.cpp:36-40 (returns static_cast<double>(bool)); GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam/steam_init_new.cpp:126-130

### 3.3 steam_update
* New: steam_api_run_callbacks()
* Delivery: `sync`; confidence: high
* Call sites: scripts/scr_steam_safe/scr_steam_safe.gml:310 (definition tcc_steam_update); objects/o_fullscreensystem/Step_0.gml:4 (only caller: `if (platform_steam()) tcc_steam_update();`, placed after `if (!timing_instance_step()) exit;` on line 1)
* Callback struct / fields: none (it pumps the queue; individual callbacks receive their own result structs)
* Signature changes: No args. Return value unused by callers. Suggested wrapper: `if (platform_steam() && steam_api_is_initialized()) { steam_api_run_callbacks(); return true; } return false;`
* Gotchas: Must be called every frame or NO callback (set_callback_* or trailing-callback arguments) is ever delivered. The old Async-Steam event no longer exists (3.0 source never calls CreateAsyncEvent), so every Other_69 Steam handler is dead after the migration. Callbacks are queued natively during steam_api_run_callbacks() and invoked by a time_source_global ticker (ExtensionCore_api.gml:240-371) as `with (_dummy_context) method_call(_ref[0], _args)` (line 350), i.e. on the next time-source tick, not inside the pump call as the docs say. Consequences for self: an UNBOUND callback (a bare script-function reference) runs with self = the shared static _dummy_context struct, so instance-variable writes silently land on that shared struct; a callback bound with method(target, fn) or a function literal created inside an instance keeps ITS bound self, and if that instance was destroyed before the tick the callback runs against a dead self. Rule: register callbacks bound to a plain struct (a per-call context struct or a global struct the project owns, as map-ugc.md does with method({inst:id,...}, fn)), never to an instance, and test instance_exists() on any captured instance id. o_fullscreensystem (the pump owner) is destroyed by objects/o_endingreq/Create_0.gml:3 and recreated by objects/o_loading/Create_0.gml:13, so pumping pauses while it is absent (pre-existing). Safe to call when Steam is not initialised (native STEAM_GUARD returns).
* ID types: n/a
* Doc refs: gmext/src/docs/api.js steam_api_run_callbacks; getting_started.md 'Running the callbacks'; scripts/Steamworks_API/Steamworks_API.gml:12468 (skip comment); extensions/Steamworks/source/src/gm_steam_api.cpp:300-304; extensions/Steamworks/source/code_gen/native/SteamworksInternal_native.cpp:60 (native export); GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam/steam_init_new.cpp:22-37 (RunCallbacks + Steam_UserStats_Process, returned 1/0); scripts/ExtensionCore_api/ExtensionCore_api.gml:240-371 (GML dispatcher)

### 3.4 steam_is_user_logged_on
* New: steam_user_logged_on()
* Delivery: `sync`; confidence: high
* Call sites: scripts/scr_steam_safe/scr_steam_safe.gml:146 (definition tcc_steam_is_user_logged_on); scripts/scr_timing_ui/scr_timing_ui.gml:32; objects/o_publishworkshopchallenge/Create_0.gml:21; objects/o_publishinghappenshere/Create_0.gml:35
* Callback struct / fields: none (synchronous; reconnect notifications would be steam_user_set_callback_steam_servers_connected, API.gml:15113, unused by the project)
* Signature changes: Renamed only; 0 args; returns double 1/0 (Bool).
* Gotchas: Same ISteamUser::BLoggedOn as before. Comparison `= false` in objects/o_publishworkshopchallenge/Create_0.gml:21 still works with 0.
* ID types: n/a
* Doc refs: gmext/src/docs/user.js steam_user_logged_on; scripts/Steamworks_API/Steamworks_API.gml:14572 (skip comment); extensions/Steamworks/source/src/gm_steam_user.cpp:150-157 (BLoggedOn, false when not initialised); GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam/steam_user.cpp:20-31

### 3.5 steam_get_app_id
* New: steam_utils_get_app_id()
* Delivery: `sync`; confidence: high
* Call sites (43 entries): scripts/scr_steam_safe/scr_steam_safe.gml:66 (definition tcc_steam_get_app_id, fallback `false`); users (41 lines, 40 files; 36+ are the demo gate `== / = / != 1749610`):; scripts/scr_online_session/scr_online_session.gml:568; objects/o_LESceneryChange/Mouse_4.gml:1; ... (full list in map-core.final.json and Appendix A)
* Callback struct / fields: none
* Signature changes: Renamed (steam_utils_ interface prefix); 0 args; real (double) result, same as before.
* Gotchas: Demo detection depends on this: `tcc_steam_get_app_id() = 1749610` => demo. When Steam is not up the wrapper falls back to false(0), so `!= 1749610` is TRUE and `= 1749610` is FALSE; keep that exact fallback. The value is whatever app launched the process (steam_appid.txt in Debug=Enabled, else the launching Steam app), NOT the 'Application ID' extension option (options/extensions/Steamworks.json = 1651680), same as 2.x. global.appid (objects/o_title/Create_0.gml:28) is overwritten on every o_title Create with this wrapper's result (false when Steam is down), feeds UGC calls (o_publishinghappenshere/Create_0.gml:20,45; o_publishworkshopchallenge/Create_0.gml:176, Other_69.gml:20) and must stay numeric (not string).
* ID types: Plain double holding a uint32 app id; no struct, no int64.
* Doc refs: gmext/src/docs/utils.js steam_utils_get_app_id; scripts/Steamworks_API/Steamworks_API.gml:15531 (skip comment: raw native); Steamworks.yy: args [] ret 2; extensions/Steamworks/source/src/gm_steam_utils.cpp:154-162 (uint32 GetAppID as double, 0 when not initialised); GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam/steam_user.cpp:62-75

### 3.6 steam_get_user_steam_id
* New: steam_user_get_steam_id()
* Delivery: `sync`; confidence: high
* Call sites: scripts/scr_steam_safe/scr_steam_safe.gml:86 (definition tcc_steam_get_user_steam_id, fallback int64(0)); scripts/scr_online_multiplayer/scr_online_multiplayer.gml:433; scripts/scr_online_multiplayer/scr_online_multiplayer.gml:450; scripts/scr_online_multiplayer/scr_online_multiplayer.gml:531; scripts/scr_online_multiplayer/scr_online_multiplayer.gml:1075; objects/o_version/Draw_0.gml:21; scripts/badge_system/badge_system.gml:199; objects/o_workshopchallengecreator/Step_0.gml:29; objects/o_profilepicture/Create_0.gml:36; (notes: o_version/Draw_0.gml:21 unused local; badge_system.gml:199 string(...) key into seasonal_rankings.json; o_workshopchallengecreator/Step_0.gml:29 compared with btn.owner_id at :37; o_profilepicture/Create_0.gml:36 avatar domain)
* Callback struct / fields: none. SteamId struct (scripts/Steamworks_API/Steamworks_API.gml:1688: id64, account_id, account_instance, universe, account_type, is_valid, is_lobby, is_individual, ...) is only returned by steam_user_decode_steam_id(_steam_id) (scripts/Steamworks_API/Steamworks_API.gml:14748), not by this function.
* Signature changes: Renamed; 0 args. Same 64-bit value as before. Wrapper hardening: `var _id = steam_user_get_steam_id(); return is_undefined(_id) ? int64(0) : int64(_id);` (the GML wrapper returns undefined if extension_exists('Steamworks') is false).
* Gotchas: Answer to 'struct or int64': still a plain 64-bit integer, NOT a SteamId struct. Every other 3.0 steam_id parameter is also a UInt64 number validated with is_numeric and written with buffer_u64. The project compares this with ids from lobbies/UGC (== on int64) and string()s it: all other domains must also hand back int64 (not doubles, which lose precision above 2^53 = 9.0e15; Steam64 ids are ~7.6e16). The int64-ness of buffer_read(buffer_u64) is inferred, not runtime-proven: add an is_int64(steam_user_get_steam_id()) smoke check.
* ID types: Steam ids stay int64 (buffer_u64). Struct SteamId exists only for steam_user_decode_steam_id. Fallbacks: 0 (not initialised) / undefined (extension missing) -> wrapper keeps int64(0).
* Doc refs: gmext/src/docs/user.js steam_user_get_steam_id (@returns {Real}); scripts/Steamworks_API/Steamworks_API.gml:14730-14742 (GML wrapper: buffer_read(ret, buffer_u64)); extensions/Steamworks/source/src/gm_steam_user.cpp:530-538 (0 when not initialised); GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam/steam_user.cpp:34-45 (VALUE_INT64)

### 3.7 steam_send_screenshot
* New: steam_screenshots_add_screenshot_to_library(_absolute_filename, "", _width, _height)   // returns the handle synchronously; the outcome of the import arrives through the callback registered once with steam_screenshots_set_callback_screenshot_ready(function(_result) { /* _result.screenshot_handle, _result.result */ })
* Delivery: `sync+callback`; confidence: medium
* Call sites: scripts/scr_steam_safe/scr_steam_safe.gml:222 (definition tcc_steam_send_screenshot(_a0,_a1,_a2)); NO callers anywhere in scripts/objects/rooms (dead wrapper)
* Callback struct / fields: SteamScreenshotsScreenshotReady { screenshot_handle, result } (scripts/Steamworks_API/Steamworks_API.gml:2101-2110) via steam_screenshots_set_callback_screenshot_ready(_callback) (scripts/Steamworks_API/Steamworks_API.gml:14426). Per gmext/src/docs/screenshots.js:10 the RESULT is delivered through that callback; only the handle (0 on failure) is synchronous (gm_steam_screenshots.cpp:116-140). Register the callback only if a caller ever appears.
* Signature changes: Arg count 3 -> 4: new 2nd arg thumbnail_filename (pass "" for auto thumbnail). filename must now be an ABSOLUTE path to a JPG/PNG/TGA; width and height must be > 0 or the call returns 0.
* Gotchas: Old function resolved the relative name against the SAVE area, then the BUNDLE, returned -1 when not found, 0 when Steam not initialised, handle > 0 on success. New returns the handle or STEAM_SCREENSHOTS_INVALID_SCREENSHOT_HANDLE (0) and never -1. A caller that used screen_save(file) must pass e.g. game_save_id + file. Because nothing calls it, it can stay a documented stub. Old steam_is_screenshot_requested (not used) maps to steam_screenshots_hook_screenshots(true) + steam_screenshots_set_callback_screenshot_requested (API.gml:14448).
* ID types: Screenshot handle is a plain real (uint32).
* Doc refs: gmext/src/docs/screenshots.js steam_screenshots_add_screenshot_to_library; Steamworks.yy: args [1,1,2,2] ret 2; scripts/Steamworks_API/Steamworks_API.gml:14269 (skip comment), STEAM_SCREENSHOTS_INVALID_SCREENSHOT_HANDLE = 0 at line 89; extensions/Steamworks/source/src/gm_steam_screenshots.cpp:116-140; GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam/steam_screenshots.cpp:71-109; old docs ugc.html

### 3.8 steam_is_overlay_enabled
* New: steam_utils_is_overlay_enabled()
* Delivery: `sync`; confidence: high
* Call sites: scripts/scr_steam_safe/scr_steam_safe.gml:22 (definition tcc_steam_is_overlay_enabled); scripts/scr_online_friends/scr_online_friends.gml:141 (enabled flag of the 'Steam Friends' button)
* Callback struct / fields: none (overlay open/close events are steam_friends_set_callback_game_overlay_activated(_callback) (scripts/Steamworks_API/Steamworks_API.gml:13782) -> SteamFriendsGameOverlayActivated { active, user_initiated, app_id } (scripts/Steamworks_API/Steamworks_API.gml:1902-1913), not used by the project)
* Signature changes: Renamed, 0 args, double 1/0.
* Gotchas: Docs: returns false for a few seconds while the overlay process loads, same as before. In an IDE run without Debug=Enabled the overlay never loads (the process exits first).
* ID types: n/a
* Doc refs: gmext/src/docs/utils.js steam_utils_is_overlay_enabled; scripts/Steamworks_API/Steamworks_API.gml:15650 (skip comment); extensions/Steamworks/source/src/gm_steam_utils.cpp:323-331 (false when not initialised); GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam/steam_friends.cpp:174

### 3.9 steam_user_owns_dlc
* New: steam_apps_is_subscribed_app(_app_id)
* Delivery: `sync`; confidence: high
* Call sites: scripts/scr_steam_safe/scr_steam_safe.gml:318 (definition tcc_steam_user_owns_dlc); scripts/scr_commentary/scr_commentary.gml:7; scripts/badge_system/badge_system.gml:172; scripts/badge_system/badge_system.gml:173; scripts/badge_system/badge_system.gml:174; scripts/badge_system/badge_system.gml:175; scripts/badge_system/badge_system.gml:176; scripts/badge_system/badge_system.gml:178; scripts/badge_system/badge_system.gml:179; scripts/badge_system/badge_system.gml:180; objects/o_devcommentarysettings/Mouse_4.gml:3; objects/o_settingbutton/Mouse_4.gml:19; objects/o_settingbutton/Step_0.gml:41; objects/o_commentarynodegame/Create_0.gml:3 (commented out)
* Callback struct / fields: none (licence changes arrive via steam_user_set_callback_licenses_updated (API.gml:15213) / steam_apps_set_callback_dlc_installed (API.gml:14247) if ever needed)
* Signature changes: Renamed; still one numeric app/DLC id argument (uint32 as double).
* Gotchas: Identical underlying Steam call, so base-game id 1651680 and the OST/donation ids keep working (ids by call site: scr_commentary 1995510; badge_system 1651680, 1749590, 1749600, 1995510, 2407300, 2411810, 2411811, 2411812; o_devcommentarysettings/Mouse_4:3; o_settingbutton Mouse_4:19 / Step_0:41 via dlc_gate). The 2.x docs claim '-1 if not logged in' is NOT what the code did (it returned bool/0). Result is now double 1/0 instead of a GML bool: fine for `if`, `!`, `&&` (scr_commentary.gml:7 commentary_access_policy). This is 'owns', not 'installed'. Do not use steam_user_user_has_license_for_app (server-side auth-ticket API).
* ID types: DLC/app ids are plain doubles (uint32).
* Doc refs: gmext/src/docs/apps.js steam_apps_is_subscribed_app; scripts/Steamworks_API/Steamworks_API.gml:13941 (skip comment); Steamworks.yy args [2] ret 2; extensions/Steamworks/source/src/gm_steam_apps.cpp:103-111 (SteamApps()->BIsSubscribedApp); GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam/steam_apps.cpp:8-21 (BIsSubscribedApp, VALUE_BOOL, 0 if not initialised)

### 3.10 steam_user_installed_dlc
* New: steam_apps_is_dlc_installed(_app_id)
* Delivery: `sync`; confidence: high
* Call sites: scripts/scr_steam_safe/scr_steam_safe.gml:314 (definition tcc_steam_user_installed_dlc); objects/o_commentarynodegame/Create_0.gml:4 (only mention, commented out)
* Callback struct / fields: none
* Signature changes: Renamed; one numeric id argument.
* Gotchas: Same BIsDlcInstalled call: true only if the user owns the DLC AND it is installed. No live callers, so a rename of the wrapper body is enough.
* ID types: uint32 as double.
* Doc refs: gmext/src/docs/apps.js steam_apps_is_dlc_installed; scripts/Steamworks_API/Steamworks_API.gml:13932 (skip comment); extensions/Steamworks/source/src/gm_steam_apps.cpp:73-81 (BIsDlcInstalled); GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam/steam_apps.cpp:23-36

### 3.11 steam_user_set_played_with
* New: steam_friends_set_played_with(_steam_id)   // belongs to the friends domain; listed here because the wrapper is in scr_steam_safe. Guard the wrapper: `if (platform_steam() && steam_api_is_initialized() && is_numeric(_a0) && _a0 != 0) { steam_friends_set_played_with(_a0); return true; } return false;`
* Delivery: `sync`; confidence: high
* Call sites: scripts/scr_steam_safe/scr_steam_safe.gml:38 (definition tcc_steam_user_set_played_with); scripts/scr_online_multiplayer/scr_online_multiplayer.gml:805 (inside net_register_player; return value ignored)
* Callback struct / fields: none
* Signature changes: Moved from steam_user_* to steam_friends_*; same single 64-bit id arg. No useful return value (native is void; the GML wrapper returns undefined, and also undefined when the extension is absent): the project wrapper should call it and return true.
* Gotchas: The id is NOT a lobby-member lookup: the only caller net_register_player(_steam_id, ...) (scr_online_multiplayer.gml:777-805) receives `_sender` from the packet receive loop (callers at :715, :722, :740, `_sender = tcc_steam_net_packet_get_sender_id()` at :694). The networking rewrite replaces that path (e.g. SteamNetworkingMessage.steam_id_remote, scripts/Steamworks_API/Steamworks_API.gml:3980, a UInt64) and MUST still hand a numeric int64 here: the 3.0 wrapper calls show_error(..., true) on a non-number (struct, string, undefined), so every remote-player join would become a fatal error, and a double (is_numeric passes it) silently targets the wrong account above 2^53. The wrapper guard above prevents the crash; int64-ness is the net domain's obligation (checked by the is_int64 smoke test). Docs: the current user must be in game with the other player.
* ID types: UInt64 steam id as int64.
* Doc refs: gmext/src/docs/friends.js steam_friends_set_played_with (friends.js:872); scripts/Steamworks_API/Steamworks_API.gml:13735-13749 (GML wrapper: `if (!is_numeric(...)) show_error(..., true)` aborts the game on a non-number); extensions/Steamworks/source/src/gm_steam_friends.cpp:763-771 (void native, ISteamFriends::SetPlayedWith); GMEXT-Steamworks/source/Steamworks_gml/extensions/steamworks/steamworks_cpp/GMLSteam/steam_user.cpp:78-96 (old native coerced with YYGetInt64 and never aborted)

### 3.12 steam_id_owner
* New: none as a call: it is a string KEY of the old UGC async_load / query-result ds_map (`async_load[? "steam_id_owner"]`). In 3.0 the owner is read from the struct SteamUgcQueryResult (field `owner_steam_id`) returned by the SYNC getter steam_ugc_get_query_ugc_result(_query_handle, _index) once the query callback has fired: steam_ugc_create_query_ugc_details_request([ids]) (or a create_query_all/user request) -> steam_ugc_send_query_ugc_request(handle, callback) -> in the callback loop i < _result.num_results_returned: steam_ugc_get_query_ugc_result(_result.query_handle, i).owner_steam_id -> steam_ugc_release_query_ugc_request(handle). The UGC-domain agent owns the rewrite.
* Delivery: `callback+sync`; confidence: high
* Call sites: objects/o_customlevelworkshopbuttonplay/Other_69.gml:13; objects/o_playmostrecentlevelCL/Mouse_4.gml:11 (dead object per map-ugc.md:190,355; also reads async_load inside a Mouse event, pre-existing, delete rather than port); objects/o_workshoplevelselectbutton/Other_69.gml:7; objects/o_customlevelsbrowser/Other_69.gml:29; objects/o_customlevelsbrowser/Other_69.gml:100
* Callback struct / fields: The query callback receives SteamUgcQueryCompleted { query_handle, result, num_results_returned, total_matching_results, cached_data } (scripts/Steamworks_API/Steamworks_API.gml:2637-2650), which carries NO owner. The owner is SteamUgcQueryResult.owner_steam_id (struct constructor scripts/Steamworks_API/Steamworks_API.gml:2532, field at :2554), the RETURN value of steam_ugc_get_query_ugc_result (scripts/Steamworks_API/Steamworks_API.gml:16630-16637, @returns {Struct.SteamUgcQueryResult}). A field literally named steam_id_owner exists in 3.0 only inside SteamRemoteStorageUgcDetails (scripts/Steamworks_API/Steamworks_API.gml:3628-3640) and SteamRemoteStorageDownloadUgcResult (:3679-3692), the remote-storage domain: it is the WRONG target for Workshop queries.
* Signature changes: Key renamed to owner_steam_id and read from the SteamUgcQueryResult struct returned by steam_ugc_get_query_ugc_result inside the SteamUgcQueryCompleted callback; not a ds_map key and not a callback field.
* Gotchas: Compared with tcc_steam_get_user_steam_id() in objects/o_workshopchallengecreator/Step_0.gml:37 (`show = (btn.owner_id == my_steam_id)`; my_steam_id is read at :29): both sides must be int64.
* ID types: int64 owner id (UInt64 via buffer_read(buffer_u64)).
* Doc refs: scripts/Steamworks_API/Steamworks_API.gml:16331 (steam_ugc_create_query_ugc_details_request), :16635 (steam_ugc_get_query_ugc_result), :17390 (steam_ugc_send_query_ugc_request), :17416 (steam_ugc_release_query_ugc_request); gmext/src/docs/ugc.js:1589 (owner_steam_id member), remote_storage.js:506,543 (steam_id_owner members); cross-check map-ugc.md:162,346-350

## 4. Project-local / non-API identifiers (decisions)

| Identifier | What it is | Action |
|---|---|---|
| `steam_is_available` | none: project-local. `global.steam_is_available = tcc_steam_initialised();` stays; the wrapper now returns steam_api_is_initialized(). | It is a snapshot taken once in o_version Create; 3.0 initialises before the first frame so the snapshot is valid. After a possible Steam shutdown (game_restart question) it would not refresh. |
| `steam_api` | none: project-local global flag `global.steam_api`; keep the logic `if (tcc_steam_initialised()) global.steam_api = true;` (objects/o_title/Create_0.gml:24-27). Do not confuse with the 3.0 function prefix steam_api_* (steam_api_is_initialized, steam_api_run_callbacks, ...). | Name collision risk only for tools/check_port.py's proposed regex: match the prefix steam_api_ (trailing underscore) followed by word characters and an opening parenthesis, so `global.steam_api` (no paren) is not matched. |
| `steam_id` | none: project-local struct member `steam_id` of the net player records (scr_online_multiplayer.gml:789) and function parameter/doc names (net_register_player/net_remove_player). Not an API identifier. | Holds an int64 Steam id; must stay int64 (3.0 ids remain u64 numbers). |
| `steam_display` | none: Steam-reserved rich-presence KEY string literal (54 uses: scripts/scr_rich_presence/scr_rich_presence.gml:18-160 and scripts/scr_online_friends/scr_online_friends.gml:34 as key for tcc_steam_get_friend_rich_presence). Unchanged; getter/setter become steam_friends_get_friend_rich_presence(steam_id, key) (API.gml:13252) / steam_friends_set_rich_presence(key, value) in the friends domain. | Values like '#MainMenu' are localisation tokens from rich_presence_localization.vdf; unchanged. |
| `steam_player_group` | none: Steam-reserved rich-presence KEY string literal (scr_online_multiplayer.gml:1167,1170). Unchanged. The setter changes in the friends domain: steam_friends_set_rich_presence(key, value) -> Bool (Steamworks.yy args [1,1]); value "" removes the key. | Do not rename the string. The 20-key / key-length limits are STEAM_FRIENDS_MAX_RICH_PRESENCE_KEYS / _KEY_LENGTH. |
| `steam_player_group_size` | none: Steam-reserved rich-presence KEY string literal (scr_online_multiplayer.gml:1168,1171). Unchanged; set with steam_friends_set_rich_presence(key, value) (friends domain). | Value must be a string (string(net_member_count())). |
| `steam_name` | none: project-local instance array of leaderboard entry names (o_settings/Create_0.gml:31, reloadleaderboards*, o_onlineleaderboards*). Not API. | Keep array names; only the producers (async handlers) change. objects/o_settings/Other_69.gml is a Steam async producer too (it is NOT a handler without Steam dependency): add it to the leaderboards port list. |
| `steam_rank` | none: project-local instance array of leaderboard ranks. Not API. | none for this domain; o_settings/Other_69.gml:21 must be ported with the leaderboards domain. |
| `steam_score` | none: project-local instance array of leaderboard scores. Not API. | none for this domain; o_settings/Other_69.gml:20 must be ported with the leaderboards domain. |
| `steam_userid` | none: project-local instance array holding leaderboard entry user ids (o_onlineleaderboards/Create_0.gml:8, Other_69.gml:30, o_onlineleaderboardsmini/Create_0.gml:10, reloadleaderboards*.gml). Not API. | Used as ds_map key via string(steam_userid[i]) in Draw_0 (avatar_sprites map): the stored id must stay int64 so string() keeps all digits. The two producers convert the id with real() before the avatar request (o_onlineleaderboards/Other_69.gml:35, o_onlineleaderboardsmini/Other_69.gml:39): a Steam64 id (~7.6e16) is above 2^53 (~9.0e15), so real() rounds it and the avatar lookup targets the wrong account. Pre-existing (the old JSON delivered the id as int64), but 3.0 avatar functions take a UInt64 via buffer_u64 and accept an int64 directly: drop real() when the leaderboards/avatar handlers are ported (already covered by map-stats.md:408 and map-social.md:20,144; not a core-domain change). |
| `steam_list` | none: project-local instance ds_list filled by tcc_steam_ugc_get_subscribed_items (objects/o_showsubscribedlevels/Draw_73.gml:10, objects/o_workshopchallengecreator/Create_0.gml:23, o_customlevelsbrowser/Create_0.gml, o_workshopchallengesplay/Mouse_4.gml, scr_workshopER.gml). Not API. | Contents (published file ids) must be int64 after the UGC rewrite: steam_ugc_get_subscribed_items(_max_entries, _include_locally_disabled) returns an ARRAY of UInt64 read with buffer_u64 (scripts/Steamworks_API/Steamworks_API.gml:16611-16628), not a filled ds_list, so the `steam_list` ds_list either becomes an array or is filled from it (UGC domain decides). |
| `steam_details` | none: project-local instance variable storing the async request id returned by tcc_steam_ugc_request_item_details (o_customlevelworkshopbuttonplay/Create_0.gml:21, Alarm_0.gml:2, Other_10.gml:1; o_workshoplevelselectbutton/Create_0.gml:21, Alarm_0.gml:7). Not API. The request-id matching in the Other_69 handlers (`map_id == steam_details`) disappears when the UGC domain moves to per-call callbacks. | Handled by the UGC agent. |

Full call-site lists for these are in map-core.final.json. Out of scope here, left to the avatar/friends agent: the old constants `steam_user_avatar_size_medium/small` (seen in objects/o_profilepicture/Create_0.gml:36, scripts/scr_online_friends, objects/o_onlineleaderboards*/Create_0.gml).

Detail for the producers that go dead with the Async-Steam event (leaderboards arrays steam_name / steam_rank / steam_score / steam_userid):

| Handler | Lines | Port owner |
|---|---|---|
| objects/o_settings/Other_69.gml | 19-21 (name, score, rank) | leaderboards (map-stats.md:420) |
| objects/o_onlineleaderboards/Other_69.gml | 20-22, 30 (userid), 35 (real() avatar call) | leaderboards + avatar (map-stats.md:384,408; map-social.md:20) |
| objects/o_onlineleaderboardCH/Other_69.gml | 21-23 | leaderboards |
| objects/o_onlineleaderboardsmini/Other_69.gml | 24-26, 34 (userid), 39 (real() avatar call) | leaderboards + avatar |

## 5. Async-Steam event handlers touched by this domain

The 3.0 extension never raises the Async-Steam event, so all Other_69 Steam handlers stop firing. None reads a payload that belongs to this domain (no `app_resuming_from_suspend`, `steam_shutdown`, `user_persona_name`, `remote_storage_local_file_change` reads exist; verified with rg for `event_type`). What they use from this domain is the guard `tcc_steam_initialised()`, which stays valid:

| Handler | Core-domain line | Reads now | Receives instead |
|---|---|---|---|
| objects/o_title/Other_69.gml | line 1 `if (!tcc_steam_initialised()) exit;` | event_type "inventory_request_prices" (inventory domain) | n/a for core |
| objects/o_fullscreensystem/Other_69.gml | line 3 guard in compound `if` | event_type "lobby_created"/"lobby_joined" (matchmaking) | n/a for core |
| objects/o_onlineleaderboards/Other_69.gml | line 1 guard | leaderboard/avatar events | n/a for core |
| objects/o_onlineleaderboardCH/Other_69.gml | line 1 guard | leaderboard events | n/a for core |
| objects/o_onlineleaderboardsmini/Other_69.gml | line 1 guard | leaderboard/avatar events | n/a for core |
| objects/o_customlevelsbrowser/Other_69.gml | line 1 guard | ugc_query | n/a for core |
| objects/o_publishworkshopchallenge/Other_69.gml | line 1 guard | ugc events | n/a for core |
| objects/o_getallinventoryitems/Other_69.gml | line 1 `owns_inventory && tcc_steam_initialised()` | inventory events | n/a for core |

Handlers with no core dependency: o_checkplayercount, o_customlevelworkshopbuttonplay, o_networkmanager, o_profilepicture (its Other_69 only draws a sprite, guarded by `platform_steam()`), o_publishinghappenshere, o_tradeup_menu, o_version, o_workshopERloading, o_workshoplevelselectbutton. Moved out of this list in the resolver pass: objects/o_settings/Other_69.gml (it is a leaderboard producer, see section 4).

## 6. Proposed wrapper bodies for this domain (copy verbatim, keep every `platform_steam()` guard)

```gml
function tcc_steam_init() {
    // 3.0 initialises itself before the first frame; steam_api_init is hidden and only a retry path.
    if (platform_steam()) return steam_api_is_initialized();
    return false;
}
function tcc_steam_initialised() {
    if (platform_steam()) return steam_api_is_initialized();
    return false;
}
function tcc_steam_update() {
    if (platform_steam() && steam_api_is_initialized()) { steam_api_run_callbacks(); return true; }
    return false;
}
function tcc_steam_is_user_logged_on() {
    if (platform_steam() && steam_api_is_initialized()) return steam_user_logged_on();
    return false;
}
function tcc_steam_get_app_id() {
    if (platform_steam() && steam_api_is_initialized()) return steam_utils_get_app_id();
    return false;   // keep: `!= 1749610` must stay TRUE and `= 1749610` FALSE when Steam is down
}
function tcc_steam_get_user_steam_id() {
    if (platform_steam() && steam_api_is_initialized()) {
        var _id = steam_user_get_steam_id();
        return is_undefined(_id) ? int64(0) : int64(_id);
    }
    return int64(0);
}
function tcc_steam_is_overlay_enabled() {
    if (platform_steam() && steam_api_is_initialized()) return steam_utils_is_overlay_enabled();
    return false;
}
function tcc_steam_user_owns_dlc(_a0) {
    if (platform_steam() && steam_api_is_initialized()) return steam_apps_is_subscribed_app(_a0);
    return false;
}
function tcc_steam_user_installed_dlc(_a0) {
    if (platform_steam() && steam_api_is_initialized()) return steam_apps_is_dlc_installed(_a0);
    return false;
}
function tcc_steam_user_set_played_with(_a0) {
    // The 3.0 wrapper show_error(..., true)s on a non-number. The id must be an int64 packet sender.
    if (platform_steam() && steam_api_is_initialized() && is_numeric(_a0) && _a0 != 0) { steam_friends_set_played_with(_a0); return true; }
    return false;
}
function tcc_steam_send_screenshot(_a0, _a1, _a2) {
    // _a0 must now be an ABSOLUTE path (old API searched the save area and bundle).
    // The import result arrives via steam_screenshots_set_callback_screenshot_ready; register it if a caller ever appears.
    if (platform_steam() && steam_api_is_initialized()) return steam_screenshots_add_screenshot_to_library(_a0, "", _a1, _a2);
    return false;
}
```

tools/check_port.py:79 currently forbids, outside SAFE and scr_platform_services, `\bsteam_(?:inventory_|ugc_|get_achievement|set_achievement|upload_score|initialised)\w*\s*\(`. After the rename the old alternatives no longer exist; extend it so unguarded raw 3.0 calls are still caught, e.g. `\bsteam_(?:api|apps|friends|input|inventory|matchmaking|music|networking|parties|remote_storage|screenshots|timeline|ugc|user|userstats|utils)_\w*\s*\(`. Project-local names `steam_userid`, `steam_image_create_sprite` and `global.steam_api` (no paren) do not match this pattern. The wrapper directory `Steamworks_API` is already skipped (`endswith('_API')`). Suggested extra assertion (see section 7 item 2): the Steam configuration's resolved Debug option for GUID 96a61e5d-c4ac-4104-b5ac-c8ef936e2609 is never `Enabled`.

## 7. Open questions / unresolved

1. `game_restart()` vs `final = steam_api_shutdown` (HIGH RISK, needs a runtime test; NOT settled by the sources). 2.1.6 had no `final`, so Steam stayed up across `game_restart()`. 3.0 shuts Steam down in `final`, and the init hook is `call_once`. The project depends on Steam surviving a restart: scr_online_multiplayer.gml:322-325 (`net_game_restart` "Globals, maps, buffers and the Steam lobby survive game_restart"), used from objects/o_endingreq/Alarm_0.gml:2, objects/o_endingslides/Alarm_0.gml:28, scr_timing_ui.gml:311; objects/o_restartgameLE/Mouse_4.gml:3 calls game_restart() directly. Whether the runner calls the extension `final` function on `game_restart()` is unknown. Test: log `steam_api_is_initialized()` right after a restart. If it turns false, all callbacks are cleared and the online session is lost. Mitigations (a choice for the user): (a) blank `final` in the project's extensions/Steamworks/Steamworks.yy: simplest, matches 2.x (Steam is not shut down at exit, the process teardown cleans up); costs: re-importing or updating the extension overwrites it, so it is a local patch to re-apply. (b) re-initialise early in a boot script with `steam_api_init(<constant app id captured before o_title>)` and re-register every `steam_*_set_callback_*`; costs: duplicates the extension's appID option, and `global.appid` CANNOT be that constant because o_title/Create_0.gml:28 overwrites it with the wrapper result (false when Steam is down) and it holds the launching app (demo 1749610), not the option (1651680).
2. Debug extension option per configuration (USER DECISION, not a map decision). Today it is Auto for every configuration, so an IDE run or a Steam-config build started outside Steam exits. Evidence that per-config option keys work in this project: options/extensions/GMAdMob.json overrides GUIDs 538faebe-... and f6d2fbcb-... under both `iOS` and `iOSCheck`; inheritance of such an override to child configs is NOT proven (GMAdMob sets both explicitly). Recommended direction if an override is added: the shipping Steam configuration stays `Auto` and developers opt in to `Enabled`; never ship Enabled (the build step warns while Enabled). Suggested guard: a tools/check_port.py assertion that the Steam config never resolves to Enabled.
3. SDK 1.65 must replace the 1.61 SDK at /Users/infi/Documents/sdk or every 3.0 build fails the hash assertion (section 2.6).
4. Demo build: options JSON hard-codes appID `1651680`. It is not found in the repo how the demo (1749610) build is produced; runtime demo detection works only if Steam launches it as app 1749610 (unchanged from 2.x, where RestartAppIfNecessary also used the option).
5. int64 handling of `buffer_u64` reads (2.4) is inferred from GameMaker behaviour, not proven by a run. Add an `is_int64(steam_user_get_steam_id())` assert in a smoke test; the same obligation applies to every id the other domains hand back (sender ids for set_played_with, lobby members, owner ids, leaderboard user ids).
6. Check/QA packages: expected NOT to carry the Steam libraries (children of Apple, copyToTargets 0 inherited, build.py:448-451 enforces it). Inherited ConfigValues is inferred: confirm by listing a built Check package for libSteamworks.dylib / libsteam_api.dylib (non-blocking).
7. Callback timing differs from the docs (2.2): callbacks come from a global time-source tick after `steam_api_run_callbacks()`, not inside it. Confirm at runtime when the first callback-based flow is ported.
8. If `o_fullscreensystem` is absent (during/after o_endingreq), nothing calls `steam_api_run_callbacks()` (existing behaviour; consider moving the pump to a never-destroyed persistent object).

## Appendix A. Real callers of in-scope wrappers

The full caller lists (file:line, 29 lines for tcc_steam_initialised, 41 for tcc_steam_get_app_id, 13 for tcc_steam_user_owns_dlc, 8 for tcc_steam_get_user_steam_id, and the smaller ones) are in the `call_sites` arrays of map-core.final.json; the raw grep lines with source text are in core_callers.json. tcc_steam_send_screenshot has no callers outside SAFE.
