# Async-Steam handlers, batch 1: o_title, o_version, o_checkplayercount, o_onlineleaderboards, o_customlevelworkshopbuttonplay

Read-only analysis. Project root `/Users/infi/Documents/Github/TheColorfulCreature` (`P/` below). Paths are relative to it unless stated.
Other path prefixes used below:
- `API` = `P/scripts/Steamworks_API/Steamworks_API.gml` (3.0 GML wrappers)
- `EXT` = `P/scripts/ExtensionCore_api/ExtensionCore_api.gml` (callback registry and dispatcher)
- `SRC` = `<scratchpad>/gmext/src` (3.0 docs sources and the **native C++ source**)
- `OLD` = `_oldtxt/*.txt` (plain-text dump of the 2.x HTML docs; the 2.1.6 binaries are deleted from the tree, so 2.x runtime key names can only be checked against these docs)

All five `Other_69.gml` files are the **Asynchronous Steam event** (`eventType 7 / eventNum 69` in each `.yy`). None of them handles a non-Steam async event. `o_version` and `o_checkplayercount` also own an `Other_62` (HTTP) event, but both files are one unterminated `/*` block comment (zero `*/` in either file), so they are inert.

---

## 0. Summary

| Object | Persistent | Where it lives | async keys read | Request it answers | State it changes | 3.0 verdict |
|---|---|---|---|---|---|---|
| o_title | no | placed in r_mainmenu | event_type, success | `tcc_steam_inventory_request_prices()` (Create_0:5) | **none** (empty if-block) | Delete the handler. Wrappers need callbacks (the drop callback must free its result handle). |
| o_version | no | placed in r_mainmenu | event_type, success, players | `tcc_steam_get_number_of_current_players()` (Create_0:18, Step_0:9) | `busy`, `success`, `global.playercount` | Delete handler and the Step_0 busy block; share one request helper. |
| o_checkplayercount | **yes** | created by o_loading/Create_0:12 | event_type, success, players | same function (Create_0:19, Alarm_0:8) | `busy`, `success`, `global.playercount` | Same as o_version. Owner of the periodic refresh. |
| o_onlineleaderboards | no | placed in r_onlineleaderboard | id, entries (JSON), event_type, success, user_id, image | `reloadleaderboards()` -> `tcc_steam_download_scores` / `_friends_scores`; avatar requests inside the handler | `steam_name/score/rank/userid[]`, `avatar_sprites` map + sprites | Biggest rewrite: find-handle, download, per-entry reads, names, avatars; generation token; add Clean Up event. |
| o_customlevelworkshopbuttonplay | no | **placed in no room, never created by code** (see 6.0) | id, result, title, description, tags, published_file_id, steam_id_owner, votes_up, votes_down, banned, persona_name | `tcc_steam_ugc_request_item_details` and `tcc_steam_get_user_persona_name` (Create_0:21-22, Alarm_0:2-3, Other_10:1) | `mTitle, mDesc, mTags, mPubFileId, mOwner, mLikes, mDislikes, mBanned, loaded, ownername` | Unreachable today, but it still has to compile. Port mechanically or delete (decision for the lead). |

---

## 1. Cross-cutting facts that apply to every handler (verified unless marked UNVERIFIED)

1. **Zero-argument async calls are fatal in 3.0.** Every async wrapper runs `if (!is_callable(_callback)) show_error(..., true)` (e.g. `API:20103-20123` `steam_userstats_number_of_current_players`, `API:21516-21534` `steam_inventory_request_prices`, `API:21824-21850` `steam_inventory_trigger_item_drop`, `API:19909-19948` `steam_userstats_download_leaderboard_entries`). Every existing `tcc_steam_*` wrapper that fronts an async call (scr_steam_safe.gml:54-64 leaderboards, :70 player count, :118 prices, :142 drop, :262 ugc details, :82 persona name) must gain a callback argument. Passing nothing aborts the game.
2. **The old zero-or-bool "was it sent" return value is gone.** 3.0 async functions have no documented return value (`steam_userstats_number_of_current_players` has no `@returns`; the leaderboard functions likewise). Code of the form `if (tcc_steam_...()) busy = true;` must set its flag from the wrapper's own "issued" boolean instead.
3. **Prerequisites for any callback to fire.** (a) `steam_initialised()` and `steam_update()` exist only in 2.x; `tcc_steam_initialised()` (scr_steam_safe.gml:102-105) must call `steam_api_is_initialized()` (extension function, `API:12456`; doc `SRC/docs/api.js:15-22`) and `tcc_steam_update()` (:310) must call `steam_api_run_callbacks()` (`SRC/docs/api.js:69-82`). The pump lives at `objects/o_fullscreensystem/Step_0.gml:4` (`if (platform_steam()) tcc_steam_update();`), which runs after `timing_instance_step()` returns true, so it pumps only on simulation ticks. o_fullscreensystem is persistent and is created by o_loading/Create_0:13, so the pump survives room changes. (b) Anything requested before o_fullscreensystem exists (logo and loading rooms) is only delivered after it does.
4. **How a callback is actually invoked** (EXT:240-371). Each registered callable is stored in a global ds_map (`__ext_core_function_map`, keyed by `int64(ptr(_callable))`, EXT:274) with a ref count. A **global time source** ticks every frame (EXT:245) and drains the native queue; each call runs as `with (_dummy_context) method_call(_ref[0], _args)` (EXT:300, 350). Consequences:
   - There is **no `instance_exists` check anywhere**; a callback is delivered even if the object that issued the request is long gone or the room changed. The map keeps the callable alive until the native side releases it.
   - A callback that is a plain **unbound** script function runs with `self` = one shared empty dummy struct. Writing `busy = false` inside it writes into that dummy struct, not into any instance. Unbound callbacks may only touch `global.*` or call other functions.
   - A function literal written inside an object event is bound to that instance. If that instance is destroyed before the callback fires, reading or writing its variables is unsafe. What GameMaker does when calling a method bound to a destroyed instance is not documented in this repo: **UNVERIFIED**, treat as unsafe.
   - GML function literals do **not capture locals**. Per-request context must travel in a struct bound with `method(ctx, function(...) {...})`, so `self` inside the callback is `ctx`.
   - Delivery happens in a time-source tick, not inside the object's own event, and on every engine frame including render-only frames of the project's decoupled timing layer (`scr_timing.gml:46`, `timing_is_tick()`). Callbacks must therefore be pure state writes; do not assume `timing_is_tick()`. The exact phase of the tick relative to Step events is **UNVERIFIED**.
   - An uncaught runtime error inside a callback is raised from the time source and will take the game down. Every callback must be defensive (`is_struct`, `undefined` checks).
   - **UNVERIFIED**: the registry key is `int64(ptr(_callable))`. If two different bound methods created from the same function literal share a `ptr`, the second registration hits the "already registered" branch (EXT:275-279) and the **first** callable (with the first instance's bound self) is the one that fires. **This is a hard gate for the closure designs in 5.6 and 6.4**: run a smoke test (the same function literal, bound to two different contexts, registered back to back in one frame; each callback must run on its own context) before anyone adopts them. See the fallback in 1.12. Weak evidence only: YoYo's own demo objects under `SRC/source/Steamworks_gml/objects` use no `method(` rebinding (grep: none), so the intended pattern is not demonstrated there.
5. **Requests can silently never call back (verified in the native source).**
   - `SRC/source/Steamworks_gml/extensions/steamworks/source/src/steam_async_common.h`: on an IO failure the callback is dropped (`delete this`) unless the template flag `ReportIoFailure` is true. Leaderboard find/download (`gm_steam_userstats.cpp:717,736,763,796`), `number_of_current_players` (`:882`), UGC query (`gm_steam_ugc.cpp:1482`) and `inventory_request_prices` (`gm_steam_inventory.cpp:1099`) all use the default `false`.
   - If the call fails to dispatch (`k_uAPICallInvalid`), the native function sets `steam_api_last_error()` and returns without any callback (`gm_steam_userstats.cpp:712,731,758,791,877`).
   - So **every 3.0 request needs a "never answered" state** (timeout or in-flight flag with expiry). The 2.x code never had one either: a lost answer left the screen in its loading or `busy` state forever.
6. **Single-slot global callbacks (verified).** `steam_friends_set_callback_persona_state_change` stores one `g_cb_persona_state_change` and a second call **replaces** the first (`gm_steam_friends.cpp:949-991`). The avatar-loaded slot is the same (verified: `g_cb_avatar_image_loaded` is overwritten by the setter, `gm_steam_friends.cpp:40,74-79`); assume the same for every other `steam_*_set_callback_*`. They are also used elsewhere today (avatar events in `scripts/scr_online_multiplayer/scr_online_multiplayer.gml:1135`, `scr_online_friends.gml:74`, `o_onlineleaderboardsmini`, `o_customlevelsbrowser`). Recommendation: one persistent owner registers each slot once and fans out to subscribers. No per-object `set_callback` calls.
7. **Broadcast becomes point-to-point.** In 2.x every instance's Async Steam event sees every result, so handlers routinely consume results requested by someone else (see 3 and 4: o_version and o_checkplayercount feed each other). In 3.0 only the requester's callback runs. Anything that silently relied on someone else's request must issue its own or read a shared global.
8. **Steam ids are plain numbers, not a SteamId struct (verified).** `steam_user_get_steam_id` returns a UInt64 read as Real (`API:14730-14742`); `steam_id_user`, `owner_steam_id`, `steam_id_64`, `steam_id_friend`, `steam_id_user` parameters are all `{Real}`/UInt64 (`API:13158,13457,13688`, `SRC/docs/userstats.js:865-876`, `friends.js:1126-1137`). The `SteamId` struct only comes back from `steam_user_decode_steam_id` (`API:14746`). No object here needs the struct.
9. **Constants removed in 3.0:** `ugc_result_success` and `steam_user_avatar_size_small/medium/large` have zero hits in `API` and are not in `extensions/Steamworks/Steamworks.yy`. `ugc_result_success` = 1 in 2.x (old Steamworks.yy:34) = `SteamApiResult.Ok` (`API:314-318`). Avatar size is now chosen by function name (`steam_friends_get_small/medium/large_friend_avatar`).
10. **tools/check_port.py:78-79** only forbids raw calls matching `steam_(inventory_|ugc_|get_achievement|set_achievement|upload_score|initialised)`. The new prefixes `steam_userstats_`, `steam_friends_`, `steam_utils_`, `steam_api_` are not covered, so raw 3.0 calls in objects would pass the guard. Extend the regex when porting, and keep all raw calls inside scr_steam_safe.
11. **Platform guard.** iOS, Android and Mac App Store builds ship no Steam binary (`API:24764` `__Steamworks_is_available()` is `extension_exists("Steamworks")`). Keep `platform_steam() && steam_api_is_initialized()` in every wrapper, and make wrappers return `false` when no request was issued so callers can leave their loading state.
12. **Fallback if the per-method key is not unique (design that does not depend on it).** Use one **unbound script function** per request type as the callback and register it repeatedly: re-registering the same callable is exactly what the ref-count branch (EXT:275-279) is for, so it is correct by construction. Keep at most one request in flight per request type and hold its context (owner id, generation) in a global slot owned by scr_steam_safe (for example `global.tcc_lb_ctx`, `global.tcc_ugc_ctx`). The unbound callback reads that slot, checks `instance_exists(owner)` and the generation, then acts. A second request of the same type issued while one is in flight either replaces the slot (latest wins, the earlier answer is then applied to the newer context and must be recognised as stale by a token echoed in the result, e.g. the leaderboard handle or file id) or is queued. Player count (3.3) and the o_title callbacks already use this shape.

---

## 2. o_title

### 2.1 What the handler does today (objects/o_title/Other_69.gml, 15 lines)
- L1: `if (!tcc_steam_initialised()) exit;`
- L5: `if (async_load[? "event_type"] != "inventory_request_prices") exit;`
- L8-15: `if (async_load[? "success"]) { ... }` whose body is entirely comments (L10-13 mention an unused currency print and `tcc_steam_inventory_get_item_price(100)`).
- Keys read: `event_type`, `success`. (`currency`, `result` exist in 2.x per `OLD/inventory.txt:213-262` and are not read.)
- **State changed: none, on every path.** No instance variable, global, ds structure or sprite is created.
- Error/empty behaviour: not initialised -> exit; other event types -> exit; `success` false -> nothing; `success` true -> nothing.
- Header comment L2 says lobby joins ("lobby_join_requested") are handled by o_networkmanager in every room (a different handler, other chunk).

### 2.2 Initiators
- `objects/o_title/Create_0.gml:5` `tcc_steam_inventory_request_prices(); //Test` -> scr_steam_safe.gml:118-121 -> `steam_inventory_request_prices()`. Its only consumer is this empty branch; `tcc_steam_inventory_get_item_price` has no live caller (grep: only a comment in this handler), so the request is **dead work**.
- `Create_0.gml:4` `tcc_steam_inventory_trigger_item_drop(99)` (scr_steam_safe.gml:142-145). Its result (`inventory_result_ready` in 2.x) is not handled by o_title at all; the returned handle is discarded and never passed to `steam_inventory_result_destroy`, so it **leaks** a Steam inventory result handle every visit.
- Create_0 runs **every time r_mainmenu is entered** (o_title.yy `persistent:false`, placed once in rooms/r_mainmenu/r_mainmenu.yy), so both requests repeat on every return to the menu.

### 2.3 Restructure for 3.0
- API: `steam_inventory_request_prices(_callback)` -> `SteamInventoryRequestPricesResult { result (SteamApiResult), currency }` (`API:21516`, `SRC/docs/inventory.js:373-390,844-851`). `steam_inventory_trigger_item_drop(_item_def_id, _callback)` -> callback gets `SteamInventoryResultReady { result_handle, result }` (`API:3515-3528`, `inventory.js:546-574`); docs require `steam_inventory_destroy_result(result_handle)` (`inventory.js:560`; extension function present in `extensions/Steamworks/Steamworks.yy`).
- **Delete `Other_69.gml`** and remove the `"eventNum":69,"eventType":7` entry from `objects/o_title/o_title.yy` (an empty event would otherwise stay).
- Wrapper changes (scr_steam_safe):
  ```gml
  function tcc_steam_inventory_request_prices() {          // keep only if the price info is ever wanted
      if (platform_steam() && steam_api_is_initialized()) { steam_inventory_request_prices(tcc_steam_ignore_result); return true; }
      return false;
  }
  function tcc_steam_inventory_trigger_item_drop(_def) {
      if (platform_steam() && steam_api_is_initialized()) { steam_inventory_trigger_item_drop(_def, tcc_steam_release_inventory_result); return true; }
      return false;
  }
  function tcc_steam_ignore_result(_r) {}                  // unbound, touches nothing
  function tcc_steam_release_inventory_result(_r) {        // unbound: globals/handles only
      if (is_struct(_r) && is_numeric(_r.result_handle)) steam_inventory_destroy_result(_r.result_handle);
  }
  ```
  The release callback must run **unconditionally** (no instance_exists gate, no success gate): it is what frees the handle, and it must fire even after o_title has been destroyed.
- Native evidence for the drop callback (`SRC/source/Steamworks_gml/extensions/steamworks/source/src/gm_steam_inventory.cpp:54-60,749-763`): the callback is stored one-shot **keyed by the returned result handle**, and only if the handle is valid (`inv_rr_register_once` returns early otherwise). If Steam refuses the drop (invalid handle), **no callback ever fires and there is nothing to destroy**. When it fires it is delivered to this one-shot, not to a global result-ready fallback. `steam_inventory_destroy_result` before delivery tombstones the entry (`:74-83`), so do not destroy the handle from anywhere except the callback.
- Decision for the lead: the price request has no consumer. Either drop `tcc_steam_inventory_request_prices()` from Create_0:5 (no behaviour change) or keep it with `tcc_steam_ignore_result`.
- Lifetime hazards: room change before the callback fires is harmless because both callbacks are unbound and instance-independent. Re-issue before the previous callback arrives is harmless (each handle is released independently). No stale-result problem because nothing is stored.

---

## 3. o_version

### 3.1 What the handler does today (objects/o_version/Other_69.gml, 6 lines, no trailing newline)
```
if (async_load[? "event_type"] == "number_of_current_players") {
    busy = false;                      // L2
    if (async_load[? "success"]) {     // L3
        success = true;                // L4
        global.playercount = async_load[? "players"];   // L5
    }
}
```
- Keys: `event_type`, `success`, `players`. No `tcc_steam_initialised()` guard and no id check: **any** `number_of_current_players` event updates this instance, including the one o_checkplayercount requested (broadcast).
- State changed: instance `busy` (always cleared), `success` (set true only on success, **never reset to false** here), `global.playercount` (only on success). `players` is never written by the handler. `success`/`busy`/`players` are not read outside o_version (grep for `o_version.`/`.players`: no hits); only `global.playercount` is consumed elsewhere (o_version/Draw_0:7-13, o_checkplayercount/Alarm_0:17-18).
- Error/empty: `success` false -> `busy` cleared, `success` unchanged, `global.playercount` keeps its old value (stale count stays on screen). No error message. No ds structure created.

### 3.2 Initiators and the sibling Step logic
- `Create_0.gml:8` sets `global.steam_is_available = tcc_steam_initialised();` (the **only** place that variable is set; grep).
- `Create_0.gml:18` `if (tcc_steam_get_number_of_current_players()) busy = true;` (wrapper scr_steam_safe.gml:70-73 -> `steam_get_number_of_current_players()`, a Boolean "request submitted" per `OLD/achievements.txt:595-640`).
- **Bug in `Step_0.gml:8-22`:** while `busy` is true it calls `tcc_steam_get_number_of_current_players()` again **every step** and treats the Boolean as a count: `result != 0` is true for `true`, so `busy=false; success=true; players = true; global.playercount = true;` runs on the first step. That submits a second request and temporarily sets `global.playercount` to `true` (1) on every title-screen entry before the real answer(s) arrive (Draw_0:7-13 would show "1"). Under 3.0 this exact call (no callback) is fatal. **Delete the whole `if (busy)` block** (L7-22).
- `Create_0.gml:12-13` also fires two `http_get` requests (`get`, `getdemo`) to `api.steampowered.com`; their handler (`Other_62.gml`) is entirely commented out, so the responses are ignored. `global.playercountdemo` is only ever set to 0 (o_checkplayercount/Create_0:7). Candidates for deletion, but outside the Steamworks port.
- Create runs on every r_mainmenu entry (o_version.yy `persistent:false`), so the request repeats per visit.
- Draw_0:21-22 makes synchronous Steam calls every frame (`tcc_steam_get_user_steam_id()`, `tcc_steam_get_persona_name()`); these map to `steam_user_get_steam_id` and `steam_friends_get_persona_name`, no callback needed.

### 3.3 Restructure for 3.0
- API: `steam_userstats_number_of_current_players(_callback)` -> `SteamUserStatsNumberOfCurrentPlayersResult { success, players }` (`API:20103`, `SRC/docs/userstats.js:537-551,917-924`). Same key names as the old map (`success`, `players`).
- Shared helper in scr_steam_safe (one request path for both objects):
  ```gml
  function tcc_steam_request_player_count() {
      if (!(platform_steam() && steam_api_is_initialized())) return false;
      steam_userstats_number_of_current_players(tcc_steam_on_player_count);
      return true;
  }
  function tcc_steam_on_player_count(_r) {                 // unbound: globals only
      if (is_struct(_r) && _r.success) global.playercount = _r.players;
  }
  ```
- o_version edits: Create_0:8-20 -> keep `global.steam_is_available`, call `tcc_steam_request_player_count()`; drop `busy/success/players`; **delete Other_69.gml** and its `.yy` event entry; **delete the Step_0 busy block**. Keep the `badge_data_changed`/`event_user(0)` remainder of Step_0.
- Behaviour change to document: in 2.x one answer updated both objects. In 3.0 o_version's answer only updates `global.playercount`; since it is a global both objects read, that is equivalent. o_version no longer needs its own flags.
- Lifetime hazards:
  - Callback after the instance is destroyed (player leaves the menu within the request latency): safe, because the callback is unbound and writes only a global.
  - Re-issue before arrival: o_version requests once per entry and o_checkplayercount every 500 steps, so several requests can be in flight. Answers are interchangeable snapshots; an older answer arriving after a newer one briefly regresses the count. If that matters, stamp requests with a counter and ignore older ones.
  - Never answered (Steam offline): `global.playercount` stays at its last value (same as today).
  - Do not put `busy = false` in the callback expecting it to reach the instance (see 1.4).

---

## 4. o_checkplayercount

### 4.1 What the handler does today (objects/o_checkplayercount/Other_69.gml)
Byte-for-byte the same 6 lines as o_version/Other_69.gml (L1-6, same keys, same state: `busy` cleared, `success` set on success, `global.playercount` set on success; `players` untouched). Same broadcast consequence: it consumes o_version's answers too.

### 4.2 Initiators and surrounding logic
- Object is `persistent:true` (o_checkplayercount.yy:18) and is created by code at `objects/o_loading/Create_0.gml:12` (o_loading is placed in r_loading). It is **placed in no room**. If o_loading is ever created twice there would be two instances; guard with `instance_exists`.
- `Create_0.gml:1-3`: on web builds `instance_destroy()` (the rest of Create still runs). `:6-8` initialises `global.playercount=0`, `global.playercountdemo=0`, `global.creditsmultiplier=1`. `:18-22` requests only if `variable_global_exists("steam_is_available") && global.steam_is_available`.
- **That Create-time request effectively never fires.** `global.steam_is_available` is set only by o_version/Create_0:8, and o_version exists only in r_mainmenu (rooms/r_mainmenu/r_mainmenu.yy), which comes after r_loading. The first real o_checkplayercount request is its Alarm_0 at +500 steps, if the variable exists by then. This is why o_version's own request matters for the first value on the title screen.
- `Alarm_0.gml` (every 500 steps, re-armed at L25, gated by `timing_is_tick()` at L1): resets `busy/success/players` (L3-5), issues the request (L8, same gate), then computes `global.creditsmultiplier` (L16-24) from the **previous** `global.playercount`: `1 + playercount*0.05 + playercountdemo*0.01`, capped at 3, only when `playercount > 1`; offline -> reset to 1. When connected and `playercount <= 1` the multiplier is left unchanged (pre-existing quirk).
- Consumers of the result: `global.creditsmultiplier` -> o_playerdead/Create_0:58-59, o_animatedtextfinalstats/Create_0:95, o_wheelpaycooldown/Create_0:12, o_player/Step_0:898-909; `global.playercount` -> o_version/Draw_0:7-13.

### 4.3 Restructure for 3.0
- Replace the two request sites with `tcc_steam_request_player_count()` (3.3). Replace the `variable_global_exists("steam_is_available") && global.steam_is_available` gate with `tcc_steam_initialised()` so it no longer depends on o_version having been created first (this also makes the Create-time request real; accept or keep the old behaviour deliberately).
- Delete `busy/success/players` and **delete Other_69.gml** plus its `.yy` entry. Optionally recompute the multiplier in the callback by moving the L16-24 maths into a global function called from both the Alarm and `tcc_steam_on_player_count`, so a fresh count applies immediately instead of one alarm later (behaviour change, optional).
- Lifetime: persistent object, so "destroyed before callback" only applies to the web `instance_destroy` path (no Steam there). Re-issue: requests are 500 steps apart; overlapping only under high latency, and answers are idempotent. Never answered: multiplier keeps computing from the stale count.

---

## 5. o_onlineleaderboards

### 5.1 Events and structure
Events (o_onlineleaderboards.yy): Create_0, Other_69, Draw_0, Step_0, Alarm_0. **No Destroy and no Clean Up event.** Not persistent. Placed once in rooms/r_onlineleaderboard/r_onlineleaderboard.yy; the room is entered only from `scr_platform_services.gml:299` inside `else if (platform_steam())`, so a Steam-less instance cannot normally exist. Alarm_0 is an empty event and `alarm[0]` is never set (free to reuse).

### 5.2 Handler walkthrough (objects/o_onlineleaderboards/Other_69.gml, 68 lines)
- L1 `if (!tcc_steam_initialised()) exit;`
- **Block A, leaderboard result (L2-49).** `async_id = async_load[? "id"]`; runs if `async_id == score_get`. No `event_type` check and no check of `status`.
  - L5-6 `entries = async_load[? "entries"]` (JSON string), `map = json_decode(entries)` (**creates a ds_map**, nested ds_list and per-entry ds_maps are freed with it).
  - L7-11 `if ds_map_exists(map,"default")` -> `ds_map_destroy(map); exit;` (treats a bare-array JSON as "no data"; also skips Block B, which is irrelevant for that event).
  - L14-46 for each entry i (0..len-1, no cap): `steam_name[i]=entry.name`, `steam_score[i]=entry.score`, `steam_rank[i]=entry.rank`; user id from `userID` else `steamid` else `noone` into `steam_userid[i]` (L24-30). If the id is not `noone/0`: key `string(id)`; if not in `avatar_sprites`: `img = tcc_steam_get_user_avatar(real(id), avatar_request_size)`; `img>0` -> `sprite = steam_image_create_sprite(img)` stored; `img==0` -> store `-2` (no avatar); otherwise (`-1` pending, or failure) store `-1`.
  - L48 `ds_map_destroy(map)`.
- **Block B, avatar arrival (L51-68).** `if (event_type != "avatar_image_loaded") exit;` then if `success == 1` and `image > 0`: key `string(user_id)`; if the key exists, delete the old sprite if `sprite_exists`; create a new sprite from `image`; store it. `success != 1` -> `show_debug_message("Failed to get user avatar")`. `success==1` with `image<=0` -> silently ignored.
  - **It accepts any user's avatar**: every `avatar_image_loaded` event is broadcast to every instance (also those requested by the lobby code or the mini leaderboards), so users who are not on the board get a sprite added to `avatar_sprites`.
- Keys read: `id`, `entries`, then inside entries `name`, `score`, `rank`, `userID`/`steamid`; `event_type`, `success`, `user_id`, `image`. (2.x documents `entries` as JSON with `rank, score, name, userID, data?`: `OLD/leaderboards.txt` LeaderboardEntry section; `userID` is Int64.)
- Precision note, UNVERIFIED: JSON numbers decode as doubles, and Steam ids (~7.6e16) exceed 2^53, so `real(userID)` can be a rounded id in 2.x. 3.0 returns the exact UInt64, so this cannot recur.

### 5.3 State changed and owned resources
- Instance arrays `steam_name`, `steam_score`, `steam_rank`, `steam_userid` (zeroed to ""/0/0/`noone` for 0..99 by `reloadleaderboards()`, scripts/reloadleaderboards/reloadleaderboards.gml:31-37; a friends list longer than 100 grows the arrays but Draw only reads 0..99, Draw_0:7).
- `avatar_sprites` ds_map created at Create_0:9; sprites created by the instance method `steam_image_create_sprite` (Create_0:11-35, which allocates and frees its own buffer and surface; `-1` on failure). `reloadleaderboards()` deletes every sprite and `ds_map_clear`s the map (L39-47). **Nothing destroys the map or the sprites when the room is left** (no Destroy/Clean Up event): one ds_map and up to ~100 sprites leak per visit.
- `json_decode` map: destroyed on both normal paths. A runtime error, or `json_decode` returning -1, would skip the destroy.

### 5.4 Initiators
- `scripts/reloadleaderboards/reloadleaderboards.gml:49-53`: `score_get = global.friendleaderboardsettings==0 ? tcc_steam_download_scores(lbname, 1, 100) : tcc_steam_download_friends_scores(lbname)`; then the handler matches `async_load[?"id"] == score_get`. `lbname` comes from the switch on `global.leaderboardselect` (L2-30).
- Callers of `reloadleaderboards()`: Create_0:37; Step_0:4 (right key), :9 (left key), :15 and :19 (wrap-around); `objects/o_reloadleaderboardsbutton/Mouse_4.gml:4`; `objects/o_friendleaderboardsettings/Mouse_4.gml:5` (after toggling the friends filter).
- Avatar requests: inside the handler, L35. Wrapper: scr_steam_safe.gml:78-81 (`steam_get_user_avatar`, returns -1 when not Steam).
- Same-frame double issue exists today: pressing right at `maxselect` calls `reloadleaderboards()` at Step_0:4 with an out-of-range `global.leaderboardselect` (the switch has no case, so `lbname` is stale), then again at :19 after the wrap. The first request's answer is discarded in 2.x because `score_get` was overwritten (id mismatch).

### 5.5 Error and empty behaviour today
- Every failure looks the same: Draw_0:9-10 shows `loc("LOADING")` whenever `steam_score[0]==0 && steam_rank[0]==0`. This single state covers: board still loading; empty board (len 0, loop does nothing); "default" JSON; failed download; request never issued (`score_get` is 0 or -1 per `OLD/leaderboards.txt:422-428`, or `false` from the wrapper); and any state where the handler exits early.
- Leaderboard not found: 2.x sends `event_type "leaderboard_not_found"` with the same `id` but **no `entries`** (`OLD/leaderboards.txt:467-480`). The handler does not check `event_type`/`status`, so `json_decode(undefined)` is the next call. Whether that raises a runtime error in GameMaker is **UNVERIFIED**; it is a latent crash path.
- `json_decode` returning -1 (invalid JSON) -> `ds_map_exists(-1, ...)`: unguarded, outcome **UNVERIFIED**.
- No timeout: a lost answer leaves "LOADING" forever.

### 5.6 Restructure for 3.0
3.0 turns one request into a chain (`SRC/docs/userstats.js:331-489`):
1. `steam_userstats_find_leaderboard(name, cb)` -> `SteamUserStatsLeaderboardFindResult { leaderboard_handle, leaderboard_found }` (`API:19790`). The handle is valid for the game session: **cache it per name**.
2. `steam_userstats_download_leaderboard_entries(handle, SteamLeaderboardDataRequest.Global|GlobalAroundUser|Friends, start, end, cb)` (`API:19909`, enum `API:1421`; `Friends` ignores start/end) -> `SteamUserStatsScoresDownloadedResult { leaderboard_handle, entries_handle, entry_count }`. There is no success flag; failure never calls back (1.5).
3. In that callback only, loop `steam_userstats_downloaded_leaderboard_entry(entries_handle, i)` (`API:19988`) -> `SteamUserStatsDownloadedLeaderboardEntry { steam_id_user, global_rank, score, details[], ugc_handle }` or `undefined`. The docs bind the entries handle to "the most recently received call result", so read every entry synchronously inside the callback and never keep the handle.
4. **Names are not in the entry.** Use `steam_friends_get_friend_persona_name(steam_id_user)` (`API:13158`); it returns `""` or `"[unknown]"` for users Steam has not cached yet (`SRC/docs/friends.js:451-465`). For those, call `steam_friends_request_user_information(id, true)` (`API:13688`; returns `false` if everything is already available) and re-read later.
5. **Avatars:** `steam_friends_get_small_friend_avatar(id)` (`API:13457`; native returns `-1` also when Steam is unavailable, `gm_steam_friends.cpp:660-669`) returns an image handle. The extension docs do not define the sentinel values. 2.x defined `0 = none`, `-1 = pending` (`OLD/social.txt:157-170`); the SDK uses the same: **UNVERIFIED for 3.0, test it**. The 3.0 avatar-loaded callback is documented only for **large** avatars (`friends.js:134-146`, `:607-611`), so the current "small avatar pending -> wait for `avatar_image_loaded`" flow has no 3.0 equivalent: a pending `-1` would turn into a permanent "no avatar". Options: (a) poll the getter from `Alarm_0` (currently unused; every 30 steps, bounded retries, also call `steam_friends_request_user_information(id, false)` once), or (b) the single persona-state-change fan-out (flag `SteamFriendsPersonaChange.Avatar` = 64, `Name` = 1, `API:518-526`) or the large avatar plus the avatar-loaded fan-out. Option (a) needs no global slot and is the least invasive here.
6. Image helpers changed shape (Create_0:11-35 breaks on both): `steam_utils_get_image_size(h)` returns a struct `{ width, height }` (or `undefined`), not an array (`API:15611`, struct at `API:2426-2427`); `steam_utils_get_image_rgba(h, buffer)` takes **2** arguments, not 3 (`API:15587`). `tcc_steam_image_get_size/_rgba` (scr_steam_safe.gml:90-97) must be adapted (e.g. wrapper returns `[w,h]` to keep `steam_image_create_sprite` unchanged).

**Design dependency:** the sketch below binds a different context to each request through `method(ctx, function ...)`. It is only correct if the callback registry keeps those methods distinct (1.4, UNVERIFIED). Under left/right spam a collision would run the oldest context for every answer: all answers carry a stale `gen` and are dropped (the board never loads), and `find_leaderboard` answers could cache a handle under the wrong board name. Smoke test first; if it fails use the fallback in 1.12 (one unbound callback per request type, context in a global slot, one chain in flight, latest request wins, and the cached handle keyed by the name echoed through the chain's own state rather than by closure).

Suggested shape (shared by all four leaderboard objects: o_onlineleaderboards, o_onlineleaderboardsmini, o_onlineleaderboardCH, o_settings, which use the same `score_get` pattern): one wrapper that hides steps 1-3 and returns normalised rows.
```gml
// scr_steam_safe
function tcc_steam_leaderboard_fetch(_name, _request, _start, _end, _done) {   // _done(_ok, _rows[])
    if (!(platform_steam() && steam_api_is_initialized())) return false;
    var _ctx = { name:_name, request:_request, start:_start, stop:_end, done:_done };
    if (!variable_global_exists("tcc_lb_handles")) global.tcc_lb_handles = {};   // reading an unset global throws
    if (struct_exists(global.tcc_lb_handles, _name)) { tcc_lb_download(_ctx, global.tcc_lb_handles[$ _name]); return true; }
    steam_userstats_find_leaderboard(_name, method(_ctx, function(_r) {
        if (!_r.leaderboard_found) { done(false, []); return; }
        global.tcc_lb_handles[$ name] = _r.leaderboard_handle;
        tcc_lb_download(self, _r.leaderboard_handle);
    }));
    return true;
}
function tcc_lb_download(_ctx, _handle) {
    steam_userstats_download_leaderboard_entries(_handle, _ctx.request, _ctx.start, _ctx.stop, method(_ctx, function(_r) {
        var _rows = [];
        for (var _i = 0; _i < _r.entry_count; ++_i) {
            var _e = steam_userstats_downloaded_leaderboard_entry(_r.entries_handle, _i);
            if (_e == undefined) continue;
            array_push(_rows, { rank:_e.global_rank, score:_e.score, user_id:_e.steam_id_user,
                                name:steam_friends_get_friend_persona_name(_e.steam_id_user) });
        }
        done(true, _rows);
    }));
}
```
And in `reloadleaderboards()` (replace L49-53), after the existing array and avatar reset:
```gml
request_gen++;                                         // invalidates every earlier chain
lb_state = "loading";                                  // new: "loading" / "ready" / "empty" / "unavailable"
var _mode = (global.friendleaderboardsettings == 0) ? SteamLeaderboardDataRequest.Global : SteamLeaderboardDataRequest.Friends;
var _sent = tcc_steam_leaderboard_fetch(lbname, _mode, 1, 100,
    method({ owner:id, gen:request_gen }, function(_ok, _rows) {
        if (!instance_exists(owner)) return;           // room left while in flight
        if (owner.request_gen != gen) return;          // superseded (left/right spam, friends toggle, double reload)
        with (owner) leaderboard_apply(_ok, _rows);    // new instance method defined in Create_0
    }));
if (!_sent) lb_state = "unavailable";
```
`leaderboard_apply` fills `steam_name/score/rank/userid[]` from the rows (`user_id` is now an exact number, no `real()` conversion), requests small avatars with the same `>0 / 0 / else` bookkeeping (`-2` none, `-1` pending), and sets `alarm[0] = 30` while any avatar or name is pending. Rewrite `Alarm_0` as the bounded retry loop. **Delete Other_69.gml** (both blocks) and remove its `.yy` entry. Draw_0's "LOADING" test can stay as is; to distinguish empty/unavailable, add a `lb_state` check there (optional UI change).

Add a **Clean Up event** (`eventType 12`): delete every sprite stored in `avatar_sprites`, `ds_map_destroy(avatar_sprites)`, bump `request_gen`.

### 5.7 Lifetime hazards for the new flow
- **Callback after the instance is destroyed or the room changed:** the `instance_exists(owner)` check comes before any use of the instance. Never put the `avatar_sprites` ds_map index (or any ds index) into `ctx`: once the Clean Up event destroys the map, GameMaker can reuse that index for a different map, and a late write through a cached index would corrupt an unrelated structure. Always reach it as `owner.avatar_sprites` after the `instance_exists` guard, or hold avatars in a struct instead of a ds_map.
- **Request re-issued before the previous chain finished:** `request_gen` check in the final callback. The intermediate `find_leaderboard` callback of an old chain still caches the handle (useful), and may issue a download nobody wants; harmless, but you can skip it by having the helper take an `_alive()` predicate. Also coalesce the same-frame double reload (5.4) by deferring the reload to the end of Step_0 (`reload_pending` flag).
- **Stale results:** the 2.x id match gave stale-drop for free; in 3.0 the generation token is the replacement. The friends toggle and left/right keys all go through `reloadleaderboards()`, so one increment there covers all callers.
- **Never answered:** keep `lb_state` at "loading" with a timestamp; after ~10 s show "unavailable" (and use `steam_api_last_error()` when `tcc_steam_leaderboard_fetch` returned false).
- **Avatar/name arrival after the user left the visible set:** accept a late avatar only if the user id is in the current `steam_userid` array (fixes today's "any user's avatar" leak).
- Leaderboard handle cache is process-lifetime state; it needs no invalidation (valid for the game session per the docs).

---

## 6. o_customlevelworkshopbuttonplay

### 6.0 Reachability (changes the port priority)
`grep` for the object name across all `.gml`, `.yy`, `.yyp` and other text files finds only: its own folder, `The Colorful Creature.yyp` (registration), `objects/o_reloadlevelsworkshop/Mouse_4.gml` (`with` over it) and `objects/o_customviewworkshop/Mouse_4.gml:1` (`instance_exists`). It is **placed in no room** (no `objectId` reference in `rooms/*/*.yy`), nothing calls `instance_create` for it, and `asset_get_index` is not used with its name. Further dead-code evidence: `mPath` is only ever set to `""` (Create_0:15) and then handed to `global.workshopfolder` in Mouse_4:7, so clicking it could never load a level; its `level` is hard-coded to 2592571669 (Create_0:5); Alarm_0:39-66 is a commented-out older version. It looks like the retired "Level of the Week" button. It still **must compile** (YYC), and it references removed names (`ugc_result_success`, two removed wrapper signatures), so either port it mechanically or delete the object from the project (resource, `.yyp`, `.resource_order`, two small caller edits). Deleting needs the owner's decision. `o_reloadlevelsworkshop/Mouse_4.gml:1` is also missing `if` (`instance_exists(o_customlevelworkshopbuttonplay) { ... }`), so its `with` always runs; harmless.

### 6.1 Handler walkthrough (objects/o_customlevelworkshopbuttonplay/Other_69.gml, 28 lines)
- L1-2 `map_id = async_load[? "id"]`, `result = async_load[? "result"]`.
- L6-18 `if (map_id == steam_details) && (result == ugc_result_success)`: sets `mTitle<-title`, `mDesc<-description`, `mTags<-tags`, `mPubFileId<-published_file_id`, `mOwner<-steam_id_owner`, `mLikes<-votes_up`, `mDislikes<-votes_down`, `mBanned<-banned`, `loaded=1` (`mScore` read is commented out).
- L21-24 `if (async_load[?"id"] == requestname) ownername = async_load[? "persona_name"];` (no `result`/`success` check; persona events are `event_type "user_persona_name"` with `id, steamid, persona_name`, `OLD/general.txt:127-160`).
- No `event_type` check anywhere; matching is purely by async id. No ds structures or sprites are created. L26-28 is a commented-out older version. The file is not guarded by `tcc_steam_initialised()` (not needed, since the ids would never match).
- Key-name caveat: the 2.x docs for `ugc_item_details` list `up_votes`/`down_votes` (`OLD/ugc.txt:776-870`, item-details table) but the code (and `objects/o_customlevelsbrowser/Other_69.gml:30-31,101-102`) reads `votes_up`/`votes_down`. The 2.1.6 binary is gone, so this cannot be settled here (**UNVERIFIED** which was right in 2.x). The 3.0 struct uses `votes_up`/`votes_down` (`SRC/docs/ugc.js:1570-1599`).

### 6.2 State, error and empty behaviour
- Initial values (Create_0:6-22): `mTitle="Loading"`, `ownername="Unknown"`, `mOwner=0`, `mPubFileId=0`, `mBanned=false`, `loaded=0`.
- Success path sets everything above and `loaded=1`. Alarm_0:5-33 then derives `mFeatured` (`string_count("Level of the Week", string(mTags)) == 1`) and `difficulty` (1-6 via `string_count` of Easy/Medium/Difficult/Insane/Unfair/Impossible) once `loaded=1`.
- Failure/empty: `result != ugc_result_success` (or no `result` key) -> nothing changes: the title stays "Loading", `loaded` stays 0 (or keeps the previous successful values), the persona line stays "Unknown". `Mouse_4` requires `mPubFileId != 0` and `mBanned = false`. A persona answer with an empty name makes `ownername` blank. No message anywhere.

### 6.3 Initiators and cadence
- Create_0:21 `steam_details = tcc_steam_ugc_request_item_details(level, 30)` (scr_steam_safe.gml:262-265; returns `false` off-Steam) and :22 `requestname = tcc_steam_get_user_persona_name(mOwner)` with `mOwner = 0` at that point (Steam is asked for the name of user 0).
- `Alarm_0.gml:2-3` repeats **both requests every 30 steps forever** (re-armed at L36, first alarm at 20 steps from Create_0:37). `Other_10.gml:1` (user event 0, triggered from `objects/o_reloadlevelsworkshop/Mouse_4.gml`) issues the details request again.
- Because each issue overwrites `steam_details`/`requestname`, any answer slower than 30 steps is dropped as stale in 2.x (cached answers, `max_age 30`, normally arrive in time).

### 6.4 Restructure for 3.0
- There is no `ugc_request_item_details` and no "persona name by id" async function. Replacements:
  - Details: `steam_ugc_create_query_ugc_details_request([file_id])` -> query handle (`API:16331`); `steam_ugc_set_allow_cached_response(handle, 30)` (`API:17487`, must precede the send); `steam_ugc_send_query_ugc_request(handle, cb)` (`API:17390`) -> `SteamUgcQueryCompleted { query_handle, result, num_results_returned, total_matching_results, cached_data }`; in the callback `steam_ugc_get_query_ugc_result(handle, 0)` (`API:16635`) -> `SteamUgcQueryResult`; then **`steam_ugc_release_query_ugc_request(handle)` inside the callback, on every path that reaches it** (`API:17416`; docs: the handle must be released, `ugc.js:240`). Handles leak otherwise, and at today's cadence that would be two per second per instance. The release is **not** guaranteed on the paths where no callback ever arrives: an IO failure drops the callback (1.5), and `steam_ugc_send_query_ugc_request` does not check for `k_uAPICallInvalid` before `CCallResult::Set` (`gm_steam_ugc.cpp:1474-1484`). Each such miss leaks one query handle.
  - Field map (`SteamUgcQueryResult`, `ugc.js:1570-1599`): `title`, `description`, `published_file_id`, `banned`, `votes_up`, `votes_down` unchanged; `steam_id_owner` -> **`owner_steam_id`**; `tags` is now a **comma-separated String** (was an array in 2.x); `string(mTags)`/`string_count` in Alarm_0:6,19-24 keep working unchanged; `result` (enum `SteamApiResult`, success is `SteamApiResult.Ok` = 1, the same number as `ugc_result_success`).
  - Owner name: `steam_friends_get_friend_persona_name(owner)` (wrapper `tcc_steam_get_user_persona_name_sync`, scr_steam_safe.gml:18-21, to be pointed at it); if it returns `""` or `"[unknown]"`, call `steam_friends_request_user_information(owner, true)` (new wrapper needed) and let the existing Alarm_0 poll re-read it. No global persona callback is needed for this object. Never ask for user 0.
- Helper (scr_steam_safe):
  ```gml
  function tcc_steam_ugc_item_details(_file_id, _max_age, _done) {            // _done(_item or undefined)
      if (!(platform_steam() && steam_api_is_initialized())) return false;
      var _q = steam_ugc_create_query_ugc_details_request([_file_id]);
      steam_ugc_set_allow_cached_response(_q, _max_age);
      steam_ugc_send_query_ugc_request(_q, method({ q:_q, done:_done }, function(_r) {
          var _item = undefined;
          if (_r.result == SteamApiResult.Ok && _r.num_results_returned > 0) _item = steam_ugc_get_query_ugc_result(q, 0);
          steam_ugc_release_query_ugc_request(q);          // always, even if the owner is gone
          done(_item);
      }));
      return true;
  }
  ```
  `done` is where the instance guard lives, so the release happens even when the object is already destroyed. If the helper is changed to the 1.12 fallback, keep the release in the unbound callback and read `q` from the global slot.
- Object edits: Create_0:21-22 -> `details_busy = false; details_sent = 0;` plus a `request_details` instance method that sends one query only if none is in flight (and **no timeout re-issue**: offline, every timeout would leak another query handle; for this unreachable object, retry only on user event 0) and whose `done` is `method({ owner:id }, function(_item) { if (!instance_exists(owner)) return; with (owner) { details_busy = false; if (_item == undefined || _item.result != SteamApiResult.Ok) exit; mTitle=_item.title; mDesc=_item.description; mTags=_item.tags; mPubFileId=_item.published_file_id; mOwner=_item.owner_steam_id; mLikes=_item.votes_up; mDislikes=_item.votes_down; mBanned=_item.banned; loaded=1; } })`. Alarm_0:2-3 and Other_10:1 call `request_details()`; Alarm_0 keeps the `loaded`-gated tag/difficulty logic and gains the persona-name poll. **Delete Other_69.gml** and its `.yy` entry. Consider stopping the 30-step re-poll after `loaded=1` (refresh only via user event 0).
- Lifetime hazards: object destroyed (room change) before the callback -> guarded by `instance_exists(owner)`, and the query handle is still released; re-issued before the previous answer -> the in-flight flag (with expiry for the never-answered case) prevents pile-up, and if a late answer from an older request arrives it carries the same item data, so applying it is harmless (no generation token needed); stale `steam_details`/`requestname` ids no longer exist.

---

## 7. Wrapper and file edit list implied by these five handlers

scr_steam_safe.gml (all raw 3.0 calls stay here):
- `tcc_steam_initialised` -> `steam_api_is_initialized()`; `tcc_steam_update` -> `steam_api_run_callbacks()`.
- New or changed: `tcc_steam_request_player_count` (+ `tcc_steam_on_player_count`), `tcc_steam_leaderboard_fetch` (+ `tcc_lb_download`, handle cache), `tcc_steam_ugc_item_details`, `tcc_steam_inventory_request_prices` and `_trigger_item_drop` (with callbacks), `tcc_steam_release_inventory_result`, a small-avatar getter, adapted `tcc_steam_image_get_size/_rgba`, `tcc_steam_request_user_information`; repoint `tcc_steam_get_user_persona_name_sync`.
- Remove: `tcc_steam_get_number_of_current_players`, `tcc_steam_download_scores`, `_download_friends_scores`, `_download_scores_around_user`, `tcc_steam_ugc_request_item_details`, `tcc_steam_get_user_persona_name` (async), once all callers (including other chunks) are migrated.

Files to delete with their `.yy` event entries (`eventNum 69, eventType 7`): `objects/{o_title,o_version,o_checkplayercount,o_onlineleaderboards,o_customlevelworkshopbuttonplay}/Other_69.gml`.
Files to edit: `o_title/Create_0.gml`, `o_version/{Create_0,Step_0}.gml`, `o_checkplayercount/{Create_0,Alarm_0}.gml`, `o_onlineleaderboards/{Create_0,Alarm_0}.gml` + new Clean Up event, `scripts/reloadleaderboards/reloadleaderboards.gml`, `o_customlevelworkshopbuttonplay/{Create_0,Alarm_0,Other_10}.gml` (or delete the object).
Config: extend `tools/check_port.py:79` regex to `steam_userstats_|steam_friends_|steam_utils_|steam_api_`.

## 8. Open items and UNVERIFIED claims (do not state as fact)
1. **Whether `int64(ptr(callable))` is unique per bound method (1.4). Hard gate for the closure designs in 5.6 and 6.4; smoke test before adopting, otherwise use the 1.12 fallback.**
2. GameMaker behaviour when a method bound to a destroyed instance is invoked (1.4).
3. `json_decode(undefined)` and `ds_map_exists(-1, ...)` runtime outcomes in the current handler (5.5).
4. Whether the 2.x ugc map really used `votes_up` (code) or `up_votes` (docs) (6.1).
5. 3.0 small-avatar sentinels (`0` none, `-1` pending) and whether Steam still delivers any signal for pending small avatars; only the large-avatar callback is documented (5.6.5).
6. Whether persona names and avatars are already cached when the leaderboard callback fires (5.6.4). The doc says users on requested leaderboards are "known", not that their data is ready.
7. Phase of the ExtensionCore time-source tick relative to Step events (1.4).
8. Return value of `steam_userstats_number_of_current_players`: undocumented, assumed void (1.2).
9. `steam_ugc_create_query_ugc_details_request` doc text carries a copied note about `consumer_app_id`/`creator_app_id` that does not match its one-parameter signature; check in a real run that a details query by file id returns the item.
