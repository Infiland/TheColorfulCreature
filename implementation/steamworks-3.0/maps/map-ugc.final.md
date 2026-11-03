# UGC / Workshop: Steamworks 2.1.6 -> 3.0.0 final migration map (resolver output)

Project root: `/Users/infi/Documents/Github/TheColorfulCreature` (branch `feat/steamworks-3-0`). Paths are relative to it unless absolute. READ-ONLY analysis: nothing in the project was edited. This file supersedes `map-ugc.md`; 32 entries, same field set as the JSON (`map-ugc.final.json`).

Legend: VERIFIED = read from the cited source. PROPOSED = new code, not compiled. UNVERIFIED = could not be confirmed from files in this repo (collected in "Unresolved").

Sources: 3.0 GML `scripts/Steamworks_API/Steamworks_API.gml` (never print line 24773); docs `<scratch>/gmext/src/docs/ugc.js`; 3.0 native `<scratch>/gmext/src/source/Steamworks_gml/extensions/steamworks/source/src/gm_steam_ugc.cpp`, `steam_async_common.h`, `.../code_gen/native/SteamworksInternal_native.cpp`; 2.1.6 native `<scratch>/port/old_steam_ugc.cpp`; dispatcher `scripts/ExtensionCore_api/ExtensionCore_api.gml:240-371`. `<scratch>` = `<scratchpad>`.

---

## 1. Rules that apply to every UGC call site (revised)

1. **Same-named functions compile and run silently wrong.** `create_item, get_item_install_info, get_item_update_progress, get_subscribed_items, set_item_*, start_item_update, submit_item_update, subscribe_item, unsubscribe_item` keep their names with new signatures (`identifiers.json` class "both"). Every raw `steam_ugc_*(` call must live in `scripts/scr_steam_safe/scr_steam_safe.gml` (`tools/check_port.py:78-79` fails the build otherwise).
2. **No request ids, no `async_load`.** The async natives return a constant `0` (`SteamworksInternal_native.cpp:2488-2503`; the GML wrapper returns it, or `undefined` without the extension, `Steamworks_API.gml:16253-16280`). `new_item`, `requestId`, `steam_details`, `browse_query_id`, `async_details[? id]` stop working; the `tcc_` wrappers return a bool "attempted".
3. **Callbacks get ONE struct argument** and fire only from the GML ticker after `steam_api_run_callbacks()` ran (`ExtensionCore_api.gml:350`; the pump is `tcc_steam_update()` at `objects/o_fullscreensystem/Step_0.gml:4`, remapped by the core domain). They run as `with (_dummy_context) method_call(_ref[0], _args)`: a named script function sees no instance variables.
4. **Callback routing design (Decision 6).** The native callback is keyed by `int64(ptr(callable))` and a repeated key keeps the FIRST callable (`ExtensionCore_api.gml:274-278`). Therefore: NO per-request `method()` objects are ever handed to a Steam function. Every Steam call gets one of five global named functions (`tcc_steam_ugc_on_create_item`, `_on_submit_item`, `_on_subscribed`, `_on_query_done`, `tcc_steam_ugc_noop`). Per-request context lives GML-side: a registry keyed by query handle (queries), a single-flight slot (create/submit, whose results carry no key), nothing at all (subscribe: the result carries `published_file_id` and the handler is context-free). User callbacks are then invoked by OUR code, so a `method({inst:id, seq:n}, function(...){...})` is safe there.
5. **Callbacks may outlive their instance.** `o_publishworkshopchallenge` is destroyed by Esc at any time (`Step_0.gml:2-5`); `o_publishinghappenshere` is destroyed by Enter/Esc once finished (`Step_0.gml:7`, `KeyPress_27.gml:3`) and unconditionally by `o_publishlevelLE/Create_0.gml:4` (possibly mid-request). The wrappers take an `_owner` instance id and drop the result if `!instance_exists(_owner)`; callbacks also re-check their state gate (`state=='creating'`/`'submitting'`).
6. **A callback may NEVER arrive, even when the wrapper returned true.** Causes: Steam uninitialised or IO failure (`ReportIoFailure=false`, `steam_async_common.h:11,31-40`; 2.x delivered `result = 0`) and an invalid `SteamAPICall_t` (`CallResult::set` never checks, `steam_async_common.h:21-24`, `gm_steam_ugc.cpp:1482,1494,1509,1522,1533`; standard SDK behaviour, UNVERIFIED here). Every state machine waiting on a callback needs its own deadline: publish (both objects: `o_publishworkshopchallenge` has none, `o_publishinghappenshere` has 120 s `Step_0.gml:3-4`), browser `browse_state=="loading"`. Not needing one: `o_workshopERloading` (30 s `max_wait`), net follow (`NET_FOLLOW_TIMEOUT_MS`, `scr_online_session.gml:550-554`), ER catalog scan (an unfinished scan only means the catalog pool is unused, `scr_workshopER.gml:107`), detail buttons (retry from Alarm).
7. **The query handle is YOURS to release** (`gm_steam_ugc.cpp:774-787`; 2.x did it itself, comment at `scr_workshopER.gml:338`). `tcc_steam_ugc_on_query_done` releases on every path.
8. **Bad arguments are fatal `show_error(..., true)`** in the 3.0 wrappers (non-numeric ids, `undefined` ids, non-string title/description/path/note, non-array/non-string tags, non-callable callback, non-numeric ids inside the details array). Wrappers validate/coerce first.
9. **One validity test for handles and ids.** Query and update handles are u64 read as int64 (nothing guarantees `< 2^63`): never test `> 0` / `<= 0`; use `tcc_steam_ugc_handle_valid(h)` (numeric, `!= 0`, `!= STEAM_UGC_QUERY_HANDLE_INVALID` which equals `STEAM_UGC_UPDATE_HANDLE_INVALID` = -1, `Steamworks_API.gml:113,115`). The tcc wrappers normalise undefined/0/-1 to `-1`. File ids stay `> 0`.
10. **The platform guard stays.** iOS/Android/MacAppStore have no Steam binary. Guard = `tcc_steam_ready()` = `platform_steam() && steam_api_is_initialized() != 0`, the same helper `map-lobby.final.md` section 6 proposes (define it once; core/lobby owns it, `map-inventory.final.md` and `map-social.final.md` inline the same expression). `steam_ugc_get_num_subscribed_items` and `steam_utils_get_app_id` are RAW natives (no `extension_exists` guard).

---

## 2. Proposed wrapper layer for `scripts/scr_steam_safe/scr_steam_safe.gml` (PROPOSED, not compiled)

```gml
// ---------- shared helpers --------------------------------------------------------------------
// function tcc_steam_ready() { return platform_steam() && steam_api_is_initialized() != 0; }   // see map-lobby.final.md
#macro TCC_UGC_SLOT_MS 180000        // single-flight slot expiry: longer than every caller deadline (120 s)

function tcc_steam_ugc_noop(_r) {}   // unsubscribe only

/// ONE validity test for query AND update handles. Never use > 0 / <= 0.
function tcc_steam_ugc_handle_valid(_h) {
    return is_numeric(_h) && _h != 0 && _h != STEAM_UGC_QUERY_HANDLE_INVALID && _h != STEAM_UGC_UPDATE_HANDLE_INVALID;
}
/// Resolve the consumer app id at call time: global.appid can be false (o_title/Create_0.gml:28).
function tcc_steam_ugc_app_id(_a) {
    var _id = (is_numeric(_a) && _a > 0) ? _a : steam_utils_get_app_id();      // raw native, argCount 0
    return (is_numeric(_id) && _id > 0) ? _id : 0;
}
/// Single hook for path handling. Currently NO rewriting (Decisions 2/14, unresolved U1).
function tcc_steam_ugc_path(_p) { return string(_p); }

// ---------- sync shims (same signatures as 2.x; the 26 live callers stay unchanged) -----------
function tcc_steam_ugc_num_subscribed_items() {
    if (tcc_steam_ready()) return steam_ugc_get_num_subscribed_items(false);
    return false;
}
function tcc_steam_ugc_get_subscribed_items(_list) {
    if (!tcc_steam_ready()) return false;
    ds_list_clear(_list);
    var _n = steam_ugc_get_num_subscribed_items(false);
    var _ids = (_n > 0) ? steam_ugc_get_subscribed_items(_n, false) : [];
    if (!is_array(_ids)) return false;
    for (var _i = 0; _i < array_length(_ids); ++_i) ds_list_add(_list, _ids[_i]);
    return ds_list_size(_list);
}
function tcc_steam_ugc_get_item_install_info(_file_id, _map) {
    if (!tcc_steam_ready() || !is_numeric(_file_id)) return false;
    ds_map_clear(_map);
    var _info = steam_ugc_get_item_install_info(_file_id);       // undefined when not installed
    if (is_undefined(_info)) return false;
    _map[? "size_on_disk"] = _info.size_on_disk;
    _map[? "legacy_item"]  = ((steam_ugc_get_item_state(_file_id) & SteamUgcItemState.LegacyItem) != 0) ? 1 : 0;
    _map[? "folder"]       = _info.folder;
    return true;
}
function tcc_steam_ugc_get_item_update_info(_file_id, _map) {
    if (!tcc_steam_ready() || !is_numeric(_file_id)) return false;
    ds_map_clear(_map);
    var _state = steam_ugc_get_item_state(_file_id);
    if (!is_numeric(_state)) return false;
    var _dl = steam_ugc_get_item_download_info(_file_id);        // undefined unless Steam has download info
    _map[? "needs_update"]        = ((_state & SteamUgcItemState.NeedsUpdate) != 0) ? 1 : 0;
    _map[? "is_downloading"]      = ((_state & SteamUgcItemState.Downloading) != 0) ? 1 : 0;
    _map[? "bytes_downloaded"]    = is_undefined(_dl) ? 0 : _dl.bytes_downloaded;
    _map[? "bytes_total"]         = is_undefined(_dl) ? 0 : _dl.bytes_total;
    _map[? "is_legacy"]           = ((_state & SteamUgcItemState.LegacyItem) != 0) ? 1 : 0;
    _map[? "is_download_pending"] = ((_state & SteamUgcItemState.DownloadPending) != 0) ? 1 : 0;
    _map[? "is_installed"]        = ((_state & SteamUgcItemState.Installed) != 0) ? 1 : 0;
    return true;
}

// ---------- publish side: single-flight slots (results of create/submit carry no key) ----------
function tcc_steam_ugc_slot_take(_kind, _owner, _cb) {
    if (!variable_global_exists("tcc_ugc_slots")) global.tcc_ugc_slots = {};
    var _s = variable_struct_get(global.tcc_ugc_slots, _kind);
    if (is_struct(_s) && _s.busy && current_time < _s.expires) return undefined;     // previous request still pending
    _s = { busy: true, owner: _owner, cb: _cb, expires: current_time + TCC_UGC_SLOT_MS };
    variable_struct_set(global.tcc_ugc_slots, _kind, _s);
    return _s;
}
function tcc_steam_ugc_slot_deliver(_kind, _r) {
    if (!variable_global_exists("tcc_ugc_slots")) return;
    var _s = variable_struct_get(global.tcc_ugc_slots, _kind);
    if (!is_struct(_s) || !_s.busy) return;                                           // late/duplicate result: ignored
    _s.busy = false;
    if (_s.owner != noone && !instance_exists(_s.owner)) return;                      // handler object is gone
    _s.cb(_r);
}
function tcc_steam_ugc_on_create_item(_r) { tcc_steam_ugc_slot_deliver("create", _r); }   // global, context-free
function tcc_steam_ugc_on_submit_item(_r) { tcc_steam_ugc_slot_deliver("submit", _r); }

/// Returns true = ATTEMPTED (a result is still not guaranteed: callers keep their own deadline). _callback(_r).
function tcc_steam_ugc_create_item(_app_id, _file_type, _callback, _owner = noone) {
    if (!tcc_steam_ready() || !is_callable(_callback)) return false;
    var _app = tcc_steam_ugc_app_id(_app_id);
    if (_app <= 0) return false;
    if (is_undefined(tcc_steam_ugc_slot_take("create", _owner, _callback))) return false;
    steam_ugc_create_item(_app, _file_type, tcc_steam_ugc_on_create_item);
    return true;
}
function tcc_steam_ugc_start_item_update(_app_id, _file_id) {
    if (!tcc_steam_ready() || !is_numeric(_file_id) || _file_id <= 0) return -1;
    var _app = tcc_steam_ugc_app_id(_app_id);
    if (_app <= 0) return -1;
    var _h = steam_ugc_start_item_update(_app, _file_id);
    return tcc_steam_ugc_handle_valid(_h) ? _h : -1;
}
function tcc_steam_ugc_set_item_title(_h, _t) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h)) return false;
    return steam_ugc_set_item_title(_h, string(_t));
}
function tcc_steam_ugc_set_item_description(_h, _d) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h)) return false;
    return steam_ugc_set_item_description(_h, string(_d));
}
function tcc_steam_ugc_set_item_visibility(_h, _v) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h)) return false;
    return steam_ugc_set_item_visibility(_h, _v);          // SteamRemoteStoragePublishedFileVisibility.Public
}
function tcc_steam_ugc_set_item_tags(_h, _tags) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h) || !is_array(_tags)) return false;
    var _strings = [];
    for (var _i = 0; _i < array_length(_tags); ++_i) array_push(_strings, string(_tags[_i]));
    return steam_ugc_set_item_tags(_h, _strings);
}
function tcc_steam_ugc_set_item_preview(_h, _p) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h)) return false;
    var _path = tcc_steam_ugc_path(_p);
    if (!file_exists(_path)) return false;                  // 2.x returned false for a missing file
    return steam_ugc_set_item_preview(_h, _path);           // no size check (2.x had none)
}
function tcc_steam_ugc_set_item_content(_h, _c) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h)) return false;
    var _path = tcc_steam_ugc_path(_c);
    if (!directory_exists(_path)) return false;             // 2.x returned false for a missing folder
    return steam_ugc_set_item_content(_h, _path);
}
function tcc_steam_ugc_submit_item_update(_h, _note, _callback, _owner = noone) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h) || !is_callable(_callback)) return false;
    if (is_undefined(tcc_steam_ugc_slot_take("submit", _owner, _callback))) return false;
    steam_ugc_submit_item_update(_h, string(_note), tcc_steam_ugc_on_submit_item);
    return true;
}

// ---------- subscribe / unsubscribe ----------------------------------------------------------
/// Shared by EVERY subscribe site: keeps both jobs of the old broadcast event. Context-free.
function tcc_steam_ugc_on_subscribed(_r) {
    if (!is_struct(_r)) return;
    var _file = _r.published_file_id;
    var _failed = (_r.result != SteamApiResult.Ok);
    // (a) was objects/o_workshopERloading/Other_69.gml:5-11; never depended on net_ready
    if (_failed && instance_exists(o_workshopERloading)) {
        with (o_workshopERloading) {
            if (state == "waiting" && target_file_id == _file) {
                state = "idle";
                global.workshopER_loading = false;
                workshopER_skip_level();
            }
        }
    }
    // (b) was net_handle_async_steam case "ugc_subscribe_item" (gated by net_ready at scr_online_multiplayer.gml:1018)
    if (variable_global_exists("net_ready") && global.net_ready
        && variable_global_exists("net_ugc_failed") && ds_exists(global.net_ugc_failed, ds_type_map)
        && variable_global_exists("net_ugc_subscribed") && is_array(global.net_ugc_subscribed)) {
        if (_failed) {
            for (var _i = 0; _i < array_length(global.net_ugc_subscribed); ++_i) {
                if (global.net_ugc_subscribed[_i].file == _file) global.net_ugc_failed[? string(_file)] = current_time;
            }
        } else {
            ds_map_delete(global.net_ugc_failed, string(_file));
        }
    }
}
function tcc_steam_ugc_subscribe_item(_file_id) {           // signature unchanged: all 5 callers keep working
    if (!tcc_steam_ready() || !is_numeric(_file_id) || _file_id <= 0) return false;
    steam_ugc_subscribe_item(_file_id, tcc_steam_ugc_on_subscribed);
    return true;
}
function tcc_steam_ugc_unsubscribe_item(_file_id) {
    if (!tcc_steam_ready() || !is_numeric(_file_id) || _file_id <= 0) return false;
    steam_ugc_unsubscribe_item(_file_id, tcc_steam_ugc_noop);
    return true;
}

// ---------- queries: registry keyed by query handle ---------------------------------------------
function tcc_steam_ugc_query_table() {
    if (!variable_global_exists("tcc_ugc_queries")) global.tcc_ugc_queries = {};
    return global.tcc_ugc_queries;
}
/// The ONLY native callback for queries. Always releases the handle.
function tcc_steam_ugc_on_query_done(_completed) {
    var _t = tcc_steam_ugc_query_table();
    var _key = string(_completed.query_handle);
    var _entry = variable_struct_get(_t, _key);
    var _items = [];
    var _ok = (_completed.result == SteamApiResult.Ok);
    if (_ok) {
        for (var _i = 0; _i < _completed.num_results_returned; ++_i) {
            var _item = steam_ugc_get_query_ugc_result(_completed.query_handle, _i);
            if (!is_undefined(_item) && _item.result == SteamApiResult.Ok) array_push(_items, _item);
        }
    }
    steam_ugc_release_query_ugc_request(_completed.query_handle);
    if (!is_struct(_entry)) return;                                   // unknown/stale: nothing to deliver
    variable_struct_remove(_t, _key);
    if (_entry.owner != noone && !instance_exists(_entry.owner)) return;
    _entry.cb(_ok, _items, _completed);                               // _items: array of SteamUgcQueryResult
}
/// Returns true = attempted. The handle is released here if nothing was sent. _callback(_ok, _items, _completed).
function tcc_steam_ugc_send_query(_qh, _callback, _owner = noone) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_qh)) return false;
    if (!is_callable(_callback)) { steam_ugc_release_query_ugc_request(_qh); return false; }
    variable_struct_set(tcc_steam_ugc_query_table(), string(_qh), { cb: _callback, owner: _owner, t: current_time });
    steam_ugc_send_query_ugc_request(_qh, tcc_steam_ugc_on_query_done);
    return true;
}
/// Optional (call from tcc_steam_update every few seconds): drop entries whose callback never came.
function tcc_steam_ugc_query_sweep(_max_age_ms = 120000) {
    var _t = tcc_steam_ugc_query_table();
    var _keys = variable_struct_get_names(_t);
    for (var _i = 0; _i < array_length(_keys); ++_i) {
        var _e = variable_struct_get(_t, _keys[_i]);
        if (current_time - _e.t > _max_age_ms) {
            steam_ugc_release_query_ugc_request(int64(_keys[_i]));
            variable_struct_remove(_t, _keys[_i]);
        }
    }
}
function tcc_steam_ugc_create_query_all(_query_type, _match_type, _page) {
    if (!tcc_steam_ready()) return -1;
    var _app = tcc_steam_ugc_app_id(0);
    if (_app <= 0) return -1;
    var _h = steam_ugc_create_query_all_ugc_request(_query_type, _match_type, 0, _app, _page);
    return tcc_steam_ugc_handle_valid(_h) ? _h : -1;
}
function tcc_steam_ugc_query_set_search_text(_qh, _text) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_qh)) return false;
    return steam_ugc_set_search_text(_qh, string(_text));
}
/// _file_ids: one id or an array. One query per 50 ids; _callback(_ok, _items, _completed) fires once PER CHUNK;
/// callers match by _item.published_file_id. Ids that are not numeric or <= 0 are dropped (3.0 raises a fatal error).
function tcc_steam_ugc_request_item_details(_file_ids, _max_age_seconds, _callback, _owner = noone) {
    if (!tcc_steam_ready()) return false;
    var _src = is_array(_file_ids) ? _file_ids : [_file_ids];
    var _ids = [];
    for (var _i = 0; _i < array_length(_src); ++_i) if (is_numeric(_src[_i]) && _src[_i] > 0) array_push(_ids, _src[_i]);
    var _sent = 0;
    for (var _from = 0; _from < array_length(_ids); _from += STEAM_UGC_NUM_RESULTS_PER_PAGE) {
        var _chunk = array_create(min(STEAM_UGC_NUM_RESULTS_PER_PAGE, array_length(_ids) - _from));
        array_copy(_chunk, 0, _ids, _from, array_length(_chunk));
        var _qh = steam_ugc_create_query_ugc_details_request(_chunk);
        if (!tcc_steam_ugc_handle_valid(_qh)) continue;
        steam_ugc_set_allow_cached_response(_qh, _max_age_seconds);       // return value ignored (ugc.js:887)
        if (tcc_steam_ugc_send_query(_qh, _callback, _owner)) _sent++;
    }
    return _sent > 0;
}
```

Notes
- `tcc_steam_ugc_get_item_update_progress` has no callers: delete it (or return `steam_ugc_get_item_update_progress(_h)`).
- Passing an inline `function(){...}` or `method(ctx, fn)` as `_callback` to the wrappers is fine because OUR code calls it; the Steam-facing callables are only the five named globals.
- Not recommended: calling the callback synchronously with a failure struct when Steam is unavailable (re-entrancy inside Create events); a `false` return plus a deadline is simpler.

---

## 3. Handlers and call-site rewrite checklist

Every UGC branch below disappears from `Other_69` (UGC raises no Steam Async Event). Removing an `Other_69.gml` also means removing the event from the object's `.yy` (migration agent). Persona-name branches stay in the friends domain.

| Handler / site | Today | Replacement |
|---|---|---|
| `objects/o_customlevelsbrowser/Create_0.gml:52-59` `send_browse_query` + `Other_69.gml:9-91` (`ugc_query`) | `browse_query_id`, `results_list[i][? ...]` | `browse_seq += 1; browse_deadline = current_time + 20000; var qh = tcc_steam_ugc_create_query_all(SteamUgcQuery.RankedByVote, SteamUgcMatchingUgcType.Items, browse_page); if (!tcc_steam_ugc_handle_valid(qh)) { browse_state = "error"; return }`, search text, then `tcc_steam_ugc_send_query(qh, method({inst:id, seq:browse_seq}, function(_ok,_items,_completed){ if (!instance_exists(inst) \|\| inst.browse_seq != seq) return; with (inst) {...} }), id)`. Items: `.published_file_id/.title/.owner_steam_id/.votes_up/.votes_down/.banned/.handle_preview_file/.tags`; total = `_completed.total_matching_results`. `!_ok` => `browse_state = "error"`. `Step_0.gml`: if `browse_state == "loading" && current_time > browse_deadline` => `"error"`. Delete the `is_array(_tags)` branch. Lines 70-76 stay (shim + friends-domain persona request). |
| `o_customlevelsbrowser/Create_0.gml:114,122` + `Other_69.gml:93-135` (`ugc_item_details`) | one request per level, `async_details[? req_id]` | After the `levels` loop: ONE `tcc_steam_ugc_request_item_details(ids, 30, method({inst:id}, ...), id)`; in the callback match `_item.published_file_id` to `levels[]`; `_lvl.owner_id = _item.owner_steam_id`. `async_details` (Create_0.gml:38, CleanUp_0.gml:17) disappears. |
| `o_customlevelworkshopbuttonplay` `Create_0.gml:21`, `Alarm_0.gml:2`, `Other_10.gml:1`, `Other_69.gml:1-18` | `steam_details`, `map_id == steam_details` | `tcc_steam_ugc_request_item_details(level, 30, <callback>, id)`; callback sets `mTitle,mDesc,mTags,mPubFileId,mOwner=_item.owner_steam_id,mLikes,mDislikes,mBanned,loaded=1`. Stop re-requesting once `loaded == 1`. Lines 21-23 (persona) are friends domain. |
| `o_workshoplevelselectbutton/Alarm_0.gml:7` + `Other_69.gml` | same | callback sets `mTitle,mTags,owner_id=_item.owner_steam_id,loaded=1` + the difficulty `string_count` block; `Other_69.gml` can be deleted. |
| `o_workshopERloading/Other_69.gml` | subscribe skip + `workshopER_handle_async_catalog` | skip = shared `tcc_steam_ugc_on_subscribed` (section 2); catalog = callback of `workshopER_query_catalog`. Delete the file. |
| `scripts/scr_workshopER/scr_workshopER.gml:77-95` `workshopER_query_catalog` | `qh == 0 \|\| qh == -1`; `query_id <= 0` | `qh = tcc_steam_ugc_create_query_all(SteamUgcQuery.RankedByPublicationDate, SteamUgcMatchingUgcType.Items, page)`; `if (!tcc_steam_ugc_handle_valid(qh))` => scan done; `global.workshopER_query_id = qh`; `if (!tcc_steam_ugc_send_query(qh, workshopER_on_catalog))` => `query_id = -1`, scan done. |
| `scr_workshopER.gml:340-417` `workshopER_catalog_callback` / `workshopER_handle_async_catalog` | ds_map event | take `(_ok, _items, _completed)`; match `_completed.query_handle == global.workshopER_query_id` (explicit invalid tests, no `<= 0`); ids from `_item.published_file_id`; `STEAM_UGC_NUM_RESULTS_PER_PAGE` for the literals 50 (:351,:408). `:419-499` selfcheck: synthetic `SteamUgcQueryCompleted` + `SteamUgcQueryResult` structs fed to a pure parser. |
| `scr_level_document.gml:761-778` `level_publish_callback` (+ fixtures :923-936) | ds_map with `id`/`event_type` | `level_publish_callback(_struct, _state)` using `.result`, `.published_file_id` (create only), `.legal_agreement_required`; fixtures use `new SteamUgcCreateItemResult()` / `new SteamUgcSubmitItemUpdateResult()`. |
| `objects/o_publishinghappenshere/Create_0.gml:13-47` + `Other_69.gml` | state machine on `new_item`/`requestId` | `create` => `tcc_steam_ugc_create_item(global.appid, SteamRemoteStorageWorkshopFileType.Community, on_create_result, id)`; `on_create_result` / `on_submit_result` are instance methods holding today's `Other_69` bodies behind the `state=='creating'/'submitting'` gates; handle test `!tcc_steam_ugc_handle_valid(_handle)` at :21; delete `Other_69.gml`. |
| `objects/o_publishworkshopchallenge/Create_0.gml:176` + `Other_69.gml:1-55` | `create_request`, `submit_request` | same pattern; `if (!tcc_steam_ugc_create_item(...)) { result = 4; timer = 600 }` (and the same for submit), handle validity check, setter result checks, and a 120 s deadline for `result` 0.1 / 0.5. |
| `net_handle_async_steam` case `"ugc_subscribe_item"` (`scr_online_multiplayer.gml:1139-1148`) | broadcast event | remove the case (logic now in `tcc_steam_ugc_on_subscribed`). |
| `objects/o_playmostrecentlevelCL/Mouse_4.gml` | dead (never placed) | delete the UGC lines. |
| `scr_online_session.gml:877-919,983-1006` (`net_ugc_folder`, `net_ugc_request`, `net_er_goto_workshop`) | shims + 1-arg subscribe | unchanged (shims and unchanged `tcc_steam_ugc_subscribe_item(_file)`). |

Constants to replace: `scr_workshopER.gml:83,347,360,445,451,481`; `scr_level_document.gml:775,925`; `scr_online_multiplayer.gml:1142`; `o_customlevelworkshopbuttonplay/Other_69.gml:6`; `o_playmostrecentlevelCL/Mouse_4.gml:5`; `o_workshoplevelselectbutton/Other_69.gml:4`; `o_publishinghappenshere/Create_0.gml:24,45`; `o_customlevelsbrowser/Other_69.gml:10,95` and `Create_0.gml:54`; `o_workshopERloading/Other_69.gml:6`; `o_publishworkshopchallenge/Other_69.gml:13,23,45` and `Create_0.gml:176`.

---

## 4. Quick lookup (old -> new)

| Old | New (short) | Delivery | Conf |
|---|---|---|---|
| `steam_ugc_create_item` | tcc_steam_ugc_create_item(app, type, cb, owner) -> steam_ugc_create_item(app, type, tcc_steam_ugc_on_create_item) | callback | high |
| `steam_ugc_start_item_update` | tcc_steam_ugc_start_item_update(app, id) -> steam_ugc_start_item_update(app, id); returns handle or -1 | sync | high |
| `steam_ugc_set_item_title` | same name, string() coerced, handle checked | sync | high |
| `steam_ugc_set_item_description` | same name, string() coerced | sync | high |
| `steam_ugc_set_item_visibility` | SteamRemoteStoragePublishedFileVisibility.Public | sync | high |
| `steam_ugc_set_item_tags` | same name; array of strings (string() coerced copy) | sync | high |
| `steam_ugc_set_item_preview` | same name; wrapper requires file_exists(path); no path rewriting | sync | medium |
| `steam_ugc_set_item_content` | same name; wrapper requires directory_exists(path); no path rewriting | sync | medium |
| `steam_ugc_submit_item_update` | tcc_steam_ugc_submit_item_update(h, note, cb, owner) -> steam_ugc_submit_item_update(h, note, tcc_steam_ugc_on_submit_item) | callback | high |
| `steam_ugc_get_item_update_progress` | returns SteamUgcItemUpdateProgress struct; no callers | sync | high |
| `steam_ugc_subscribe_item` | tcc_steam_ugc_subscribe_item(id) UNCHANGED signature; always chains tcc_steam_ugc_on_subscribed | callback | high |
| `steam_ugc_unsubscribe_item` | tcc_steam_ugc_unsubscribe_item(id) UNCHANGED signature; passes tcc_steam_ugc_noop | callback | high |
| `steam_ugc_num_subscribed_items` | steam_ugc_get_num_subscribed_items(false) (raw native, 1 arg) | sync | high |
| `steam_ugc_get_subscribed_items` | keep tcc_steam_ugc_get_subscribed_items(list) as a ds_list shim over the array | sync | high |
| `steam_ugc_get_item_install_info` | keep tcc_steam_ugc_get_item_install_info(id, map) as a ds_map shim over the struct | sync | high |
| `steam_ugc_get_item_update_info` | OLD-ONLY: keep tcc_steam_ugc_get_item_update_info(id, map) as a shim over get_item_state + get_item_download_info | sync | medium |
| `steam_ugc_request_item_details` | tcc_steam_ugc_request_item_details(ids, age, cb, owner): chunked details query, cb(_ok,_items,_completed) per chunk | callback | medium |
| `steam_ugc_create_query_all` | tcc_steam_ugc_create_query_all(type, match, page) -> create_query_all_ugc_request(type, match, 0, app id, page) | sync | high |
| `steam_ugc_query_set_search_text` | steam_ugc_set_search_text(qh, string(text)) | sync | high |
| `steam_ugc_send_query` | tcc_steam_ugc_send_query(qh, cb, owner): ONE global native callback + registry keyed by query handle | callback | high |
| `ugc_result_success` | SteamApiResult.Ok | constant-or-enum | high |
| `ugc_filetype_community` | SteamRemoteStorageWorkshopFileType.Community | constant-or-enum | high |
| `ugc_visibility_public` | SteamRemoteStoragePublishedFileVisibility.Public | constant-or-enum | high |
| `ugc_match_Items` | SteamUgcMatchingUgcType.Items | constant-or-enum | high |
| `ugc_query_RankedByVote` | SteamUgcQuery.RankedByVote | constant-or-enum | high |
| `ugc_query_RankedByPublicationDate` | SteamUgcQuery.RankedByPublicationDate | constant-or-enum | high |
| `event_type "ugc_create_item" (async_load)` | callback of tcc_steam_ugc_create_item | event-removed | high |
| `event_type "ugc_update_item" (async_load)` | callback of tcc_steam_ugc_submit_item_update | event-removed | high |
| `event_type "ugc_subscribe_item" (async_load)` | shared global tcc_steam_ugc_on_subscribed | event-removed | high |
| `event_type "ugc_query" (async_load)` | callback of tcc_steam_ugc_send_query | event-removed | high |
| `event_type "ugc_item_details" (async_load)` | callback of tcc_steam_ugc_request_item_details | event-removed | medium |
| `ugc_item_subscribed / ugc_item_unsubscribed / ugc_item_installed (unsolicited 2.x events)` | not used by the project | event-removed | high |

All old `ugc_*` constants are ABSENT from the 3.0 extension (0 matches in `extensions/Steamworks/Steamworks.yy`); using them is an unresolved variable at runtime.

---

## 5. Entries (all 32, same content as the JSON)
### 5.1 `steam_ugc_create_item`
- **New:** tcc_steam_ugc_create_item(_app_id, _file_type, _callback, _owner = noone) -> steam_ugc_create_item(_app, _file_type, tcc_steam_ugc_on_create_item). Raw 3.0 signature: steam_ugc_create_item(_consumer_app_id, _workshop_file_type, _callback). Call site: tcc_steam_ugc_create_item(global.appid, SteamRemoteStorageWorkshopFileType.Community, on_create_result, id); _callback(_r) receives SteamUgcCreateItemResult.
- **Delivery / confidence:** callback / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:230 (wrapper def, fallback false); objects/o_publishinghappenshere/Create_0.gml:45; objects/o_publishworkshopchallenge/Create_0.gml:176
- **Result struct / fields:** SteamUgcCreateItemResult {result: SteamApiResult, published_file_id: int64, legal_agreement_required: bool} (Steamworks_API.gml:2656). Old event ugc_create_item: id, event_type, result, legal_agreement_required (0/1), published_file_id.
- **Signature changes:** _callback is mandatory in 3.0 (is_callable else fatal show_error). The native returns constant 0 and the GML wrapper returns that 0 (undefined if the extension is missing): Steamworks_API.gml:16253-16280, SteamworksInternal_native.cpp:2488-2503. It is never an id, so delete 'new_item < 0' (o_publishinghappenshere/Create_0.gml:46). The tcc_ wrapper returns bool 'attempted' (false => the callback will NOT fire). The result struct has no key to correlate on, so the wrapper is SINGLE-FLIGHT: it uses a global named callback plus one 'create' slot {busy, owner, cb, expires} and returns false while a previous create is still pending (slot expires after 180 s, longer than every caller deadline of 120 s). The consumer app id is resolved at call time (tcc_steam_ugc_app_id): global.appid can be false (o_title/Create_0.gml:28 + scr_steam_safe.gml:66-69 fallback false; is_numeric(false) is expected to be true) and 3.0 steam_utils_get_app_id() returns 0 when uninitialised; require > 0. Pass SteamRemoteStorageWorkshopFileType.Community (=0) instead of ugc_filetype_community. BEHAVIOUR CHANGE vs 2.x (accepted, Decision 20): after a timeout a retried publish is refused (wrapper returns false) for up to 60 s until the 180 s slot expires; EVERY caller must test the return: if (!tcc_steam_ugc_create_item(...)) { result = 4; <finish> } (o_publishinghappenshere replaces 'new_item < 0' at Create_0.gml:46; o_publishworkshopchallenge/Create_0.gml:176 has no such check today).
- **Gotchas:** The callback can NEVER fire even when the wrapper returned true: Steam uninitialised or IO failure (ReportIoFailure=false, steam_async_common.h:11,31-40; 2.x delivered result=0) and CallResult::set() never checks for k_uAPICallInvalid (steam_async_common.h:21-24; gm_steam_ugc.cpp:1482,1494,1509,1522,1533), so an invalid API call registers nothing (standard SDK behaviour, UNVERIFIED in this repo). Every waiter needs its own deadline: o_publishinghappenshere has one (wait_seconds > 120, Step_0.gml:3-4; wait_seconds is reset at Create_0.gml:30 for the submit phase); o_publishworkshopchallenge has none (result stays 0.1, its timer only counts down when > 0, Step_0.gml:7-12): add 120 s. Lifetime: o_publishinghappenshere is NOT destroyed by its timeout (it only becomes 'finished', Step_0.gml:4; destroyed on Enter/Esc once finished, Step_0.gml:7 and KeyPress_27.gml:1-3) but IS destroyed unconditionally by objects/o_publishlevelLE/Create_0.gml:4, possibly mid-request; o_publishworkshopchallenge is destroyed by Esc at any time (Step_0.gml:2-5). The wrapper drops a result whose owner no longer exists; keep the state=='creating' gate inside the callback. A late create result after the 120 s timeout is dropped, leaving an orphan Workshop item exactly as in 2.x. legal_agreement_required is a real bool (== true and == 1 both still work). Bad arg types are fatal show_error.
- **Id types:** consumer app id Real (> 0). published_file_id in the callback is int64 (buffer_u64), same as before.
- **Refs:** Steamworks_API.gml:16253; ugc.js:190; gm_steam_ugc.cpp:1486-1498; steam_async_common.h:11-60; ExtensionCore_api.gml:240-371

### 5.2 `steam_ugc_start_item_update`
- **New:** tcc_steam_ugc_start_item_update(_app_id, _file_id) -> steam_ugc_start_item_update(_app, _published_file_id). Returns the update handle, or -1 when invalid.
- **Delivery / confidence:** sync / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:294 (wrapper def, fallback -1); objects/o_publishinghappenshere/Create_0.gml:20; objects/o_publishworkshopchallenge/Other_69.gml:20
- **Signature changes:** Arguments unchanged. The wrapper resolves the app id at call time (tcc_steam_ugc_app_id, must be > 0, same reason as create_item), requires a numeric file id > 0, and normalises the result: undefined, 0 (guard failure, gm_steam_ugc.cpp:1203) and -1 (STEAM_UGC_UPDATE_HANDLE_INVALID, Steamworks_API.gml:115) all become -1. Validity is tested with ONE helper tcc_steam_ugc_handle_valid(h) (is_numeric, != 0, != -1) for update AND query handles; replace '_handle <= 0' at o_publishinghappenshere/Create_0.gml:21 with '!tcc_steam_ugc_handle_valid(_handle)'.
- **Gotchas:** o_publishworkshopchallenge/Other_69.gml:20 has no validity check on the handle: add one and abort with result 4. file id must be numeric or the 3.0 wrapper raises a fatal show_error.
- **Id types:** update handle Real/int64 (u64); file id int64.
- **Refs:** Steamworks_API.gml:18193; gm_steam_ugc.cpp:1203; ugc.js:1282

### 5.3 `steam_ugc_set_item_title`
- **New:** tcc_steam_ugc_set_item_title(_h, _t) -> steam_ugc_set_item_title(_h, string(_t))
- **Delivery / confidence:** sync / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:286; objects/o_publishinghappenshere/Create_0.gml:22; objects/o_publishworkshopchallenge/Other_69.gml:21
- **Signature changes:** Same args; returns Bool (old: real 1/0; the '&& _ok' chains still work).
- **Gotchas:** _title must be a string or the 3.0 wrapper raises a fatal show_error: wrap with string(). ugc.js:1002 documents a 128 byte maximum; what Steam does beyond it (return false vs truncate) is UNVERIFIED. 2.x had the same limit.
- **Refs:** Steamworks_API.gml:17674; ugc.js:990-1002

### 5.4 `steam_ugc_set_item_description`
- **New:** tcc_steam_ugc_set_item_description(_h, _d) -> steam_ugc_set_item_description(_h, string(_d))
- **Delivery / confidence:** sync / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:274; objects/o_publishinghappenshere/Create_0.gml:23; objects/o_publishworkshopchallenge/Other_69.gml:22
- **Signature changes:** Same args; Bool result.
- **Gotchas:** _description must be a string (publish_document.metadata.text, challenge_desc): wrap with string(). ugc.js:938 documents 8000 bytes maximum; the failure mode beyond it is UNVERIFIED.
- **Refs:** Steamworks_API.gml:17564; ugc.js:926-938

### 5.5 `steam_ugc_set_item_visibility`
- **New:** steam_ugc_set_item_visibility(_update_handle, _visibility) with _visibility = SteamRemoteStoragePublishedFileVisibility.Public
- **Delivery / confidence:** sync / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:290; objects/o_publishinghappenshere/Create_0.gml:24; objects/o_publishworkshopchallenge/Other_69.gml:23
- **Signature changes:** Same args; _visibility is now Enum.SteamRemoteStoragePublishedFileVisibility. Replace ugc_visibility_public.
- **Gotchas:** Numeric values identical (Public 0, FriendsOnly 1, Private 2; new Unlisted 3, Steamworks_API.gml:766). Old constants do not exist in 3.0.
- **Refs:** Steamworks_API.gml:17780; ugc.js:1038

### 5.6 `steam_ugc_set_item_tags`
- **New:** tcc_steam_ugc_set_item_tags(_h, _tags) -> steam_ugc_set_item_tags(_h, <string-coerced copy of _tags>)
- **Delivery / confidence:** sync / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:282; objects/o_publishinghappenshere/Create_0.gml:25 (level_publish_tags, scr_level_document.gml:780); objects/o_publishworkshopchallenge/Other_69.gml:26 (tags[0]='Challenges')
- **Signature changes:** Same args. _tags_csv is an ARRAY of strings despite the name (the old implementation also took an array).
- **Gotchas:** A non-array or non-string element is a fatal show_error: build a string-coerced copy in the wrapper (return false if not an array). Tags max 255 characters each, no commas (ugc.js:981).
- **Refs:** Steamworks_API.gml:17642; ugc.js:976-988

### 5.7 `steam_ugc_set_item_preview`
- **New:** tcc_steam_ugc_set_item_preview(_h, _p): path = tcc_steam_ugc_path(_p); if (!file_exists(path)) return false; return steam_ugc_set_item_preview(_h, path)
- **Delivery / confidence:** sync / medium
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:278; objects/o_publishinghappenshere/Create_0.gml:26 (image = content_directory + 'thumb.jpg'); objects/o_publishworkshopchallenge/Other_69.gml:28 (preview_path = content_dir + 'preview.png')
- **Signature changes:** Same args; Bool.
- **Gotchas:** PATH SEMANTICS CHANGED. 2.x resolved the string against the save area then the bundle (SaveFileExists/BundleFileExists, old steam_ugc.cpp:1066-1100) and returned false when absent. 3.0 forwards the raw string to Steam (gm_steam_ugc.cpp:933-942; ugc.js:960-974 asks for an ABSOLUTE path). Decision: the wrapper restores the 2.x false-on-missing with file_exists() and does NOT rewrite separators (see Decisions 2/14). level paths are already '/'-normalised by level_directory() (scr_level_document.gml:33-38, which can leave '//'); the challenge path comes from raw directory_set() (game_save_id + dir, directory_set.gml:7-9) and can mix '\' and '/'. Whether Steam accepts both on Windows is a MUST-TEST before merge (unresolved U1). Fallback if it fails: normalise inside tcc_steam_ugc_path() (single hook, currently returns string(p)). The QA-build branch of directory_set (global.tcc_qa.save_root + dir) cannot reach this wrapper: platform_steam() is false when TCC_GAMEPLAY_QA (scr_platform.gml:17) and qa_active() needs TCC_GAMEPLAY_QA (scr_gameplay_qa.gml:3-4). The 1 MB limit text is in ugc.js:87 and :1464 (add_item_preview_file / update_item_preview_file); the set_item_preview doc (ugc.js:960-974) does not state it; 2.x had no size check and none is added.
- **Refs:** Steamworks_API.gml:17616; ugc.js:87,960,1464; gm_steam_ugc.cpp:933-942; old steam_ugc.cpp:1066-1100

### 5.8 `steam_ugc_set_item_content`
- **New:** tcc_steam_ugc_set_item_content(_h, _c): path = tcc_steam_ugc_path(_c); if (!directory_exists(path)) return false; return steam_ugc_set_item_content(_h, path)
- **Delivery / confidence:** sync / medium
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:270; objects/o_publishinghappenshere/Create_0.gml:27 (content_directory); objects/o_publishworkshopchallenge/Other_69.gml:30 (content_dir)
- **Signature changes:** Same args; Bool.
- **Gotchas:** Same PATH SEMANTICS CHANGE as set_item_preview. 2.x did SaveFileName/BundleFileName + DirExists and returned 0 when not found (old steam_ugc.cpp:1017-1060); 3.0 forwards the string unchanged (gm_steam_ugc.cpp:899-909). The o_publishinghappenshere '_ok' chain (Create_0.gml:22-28) and the UNCHECKED call at o_publishworkshopchallenge/Other_69.gml:30 relied on that false; the wrapper restores it with directory_exists() (already used with trailing-slash paths in this project, e.g. o_publishworkshopchallenge/Create_0.gml:56, scr_level_document.gml:606). Do not rely on Steam to reject a missing folder at set time (unknown). Folder must contain the files directly (no zip, ugc.js:917). Recommended: make o_publishworkshopchallenge check the title/content setter results and abort with result 4 (2.x ignored them). No separator rewriting and no '//' collapsing (UNC paths; directory_set writes 'MODS//' on purpose): see Decisions and unresolved U1.
- **Refs:** Steamworks_API.gml:17538; ugc.js:910-924; gm_steam_ugc.cpp:899-909; old steam_ugc.cpp:1017-1060

### 5.9 `steam_ugc_submit_item_update`
- **New:** tcc_steam_ugc_submit_item_update(_h, _note, _callback, _owner = noone) -> steam_ugc_submit_item_update(_h, string(_note), tcc_steam_ugc_on_submit_item). Raw: steam_ugc_submit_item_update(_update_handle, _change_note, _callback). _callback(_r) receives SteamUgcSubmitItemUpdateResult.
- **Delivery / confidence:** callback / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:298; objects/o_publishinghappenshere/Create_0.gml:31 (requestId; the '< 0' check at :32 must go); objects/o_publishworkshopchallenge/Other_69.gml:32 (submit_request)
- **Result struct / fields:** SteamUgcSubmitItemUpdateResult {result: SteamApiResult, legal_agreement_required: bool} (Steamworks_API.gml:2673). NO published_file_id. Old event ugc_update_item: id, event_type, result, legal_agreement_required.
- **Signature changes:** _callback mandatory; no request id returned (native returns 0). Wrapper returns bool 'attempted', requires tcc_steam_ugc_handle_valid(_h), and is single-flight with a 'submit' slot (same design and 180 s expiry as create_item) because the result carries neither update handle nor file id. level_publish_callback(_event,_state,_create_request,_update_request) (scr_level_document.gml:761-778) becomes level_publish_callback(_struct,_state). _change_note must be a string (empty allowed; native passes NULL, gm_steam_ugc.cpp:1498-1510). Same slot behaviour change as create_item (Decision 20): a false return must be treated as failure (result 4) by o_publishinghappenshere/Create_0.gml:31-32 and o_publishworkshopchallenge/Other_69.gml:32.
- **Gotchas:** Never fires on Steam-unavailable/IO failure or an invalid API call (see create_item): o_publishworkshopchallenge has no deadline (add 120 s); o_publishinghappenshere resets wait_seconds at Create_0.gml:30 so its 120 s deadline covers the submit phase. Keep the state=='submitting' gate so a duplicate or late callback is ignored; because the result has no key, a late result after the slot expired is dropped (slot.busy false).
- **Id types:** Update handle Real/int64.
- **Refs:** Steamworks_API.gml:18310; ugc.js:1360; gm_steam_ugc.cpp:1500-1514

### 5.10 `steam_ugc_get_item_update_progress`
- **New:** steam_ugc_get_item_update_progress(_update_handle) -> SteamUgcItemUpdateProgress
- **Delivery / confidence:** sync / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:246 (wrapper def). NO CALLERS in the project.
- **Result struct / fields:** Returns SteamUgcItemUpdateProgress {status: SteamUgcItemUpdateStatus, bytes_processed, bytes_total} (Steamworks_API.gml:2515). Old ds_map keys status_code (same numeric values), status_string (no equivalent), bytes_processed, bytes_total.
- **Signature changes:** Drops the info_map argument; returns a struct, not bool. Delete the unused wrapper (or return the struct).
- **Refs:** Steamworks_API.gml:16583; enum SteamUgcItemUpdateStatus :795; ugc.js:370

### 5.11 `steam_ugc_subscribe_item`
- **New:** tcc_steam_ugc_subscribe_item(_file_id) -> steam_ugc_subscribe_item(_file_id, tcc_steam_ugc_on_subscribed). Raw 3.0: steam_ugc_subscribe_item(_published_file_id, _callback). The wrapper takes NO callback argument: the shared global handler is always used.
- **Delivery / confidence:** callback / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:302; scripts/scr_online_session/scr_online_session.gml:906; scripts/scr_online_session/scr_online_session.gml:915; scripts/scr_online_session/scr_online_session.gml:999; scripts/scr_workshopER/scr_workshopER.gml:199; objects/o_customlevelsbrowser/Step_0.gml:181
- **Result struct / fields:** SteamUgcSubscribeItemResult {result: SteamApiResult, published_file_id: int64} (Steamworks_API.gml:2689). Old event ugc_subscribe_item: id, event_type, result, published_file_id.
- **Signature changes:** _callback is mandatory in 3.0 (the 1-arg call style now hits show_error). The old event was a BROADCAST seen by every consumer for every subscribe: (a) o_workshopERloading/Other_69.gml:5-11 (skip a private/removed item instead of waiting 30 s) and (b) net_handle_async_steam case 'ugc_subscribe_item' (scr_online_multiplayer.gml:1139-1148, net_ugc_failed bookkeeping). To keep both without touching the 5 call sites, the wrapper keeps its 1-arg signature and ALWAYS passes the shared global function tcc_steam_ugc_on_subscribed (no noop default, which would silently drop both behaviours). The handler splits its guards: the ER skip runs whenever o_workshopERloading exists and state=='waiting' (it never depended on net_ready); the net bookkeeping runs only when variable_global_exists('net_ready') && global.net_ready (as the old branch, scr_online_multiplayer.gml:1018) and ds_exists(global.net_ugc_failed, ds_type_map) (destroyed by net_session_cleanup, scr_online_session.gml:57-58) and global.net_ugc_subscribed is an array. Remove the case from net_handle_async_steam and delete o_workshopERloading/Other_69.gml.
- **Gotchas:** The result may never arrive (Steam unavailable/IO failure, invalid API call; a true return only means 'attempted'). o_workshopERloading already has a 30 s max_wait (Create_0.gml:6, Step_0.gml:17-22). The net follow path is bounded by NET_FOLLOW_TIMEOUT_MS (scr_online_session.gml:550-554), so net_ugc_request needs no new deadline, but net_ugc_failed will simply not be filled in that case (2.x filled it with result=0). The handler is a named global function: it runs with self = a dummy struct (ExtensionCore_api.gml:350), so it may only use globals, instance_exists and with().
- **Id types:** published_file_id int64; must be numeric (undefined/string => fatal show_error): the wrapper checks is_numeric and > 0.
- **Refs:** Steamworks_API.gml:18342; ugc.js:1382; scr_online_multiplayer.gml:1018,1139-1148; o_workshopERloading/Other_69.gml:5-11

### 5.12 `steam_ugc_unsubscribe_item`
- **New:** tcc_steam_ugc_unsubscribe_item(_file_id) -> steam_ugc_unsubscribe_item(_file_id, tcc_steam_ugc_noop). Raw: steam_ugc_unsubscribe_item(_published_file_id, _callback).
- **Delivery / confidence:** callback / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:306; scripts/scr_online_session/scr_online_session.gml:927; scripts/scr_workshopER/scr_workshopER.gml:319
- **Result struct / fields:** SteamUgcUnsubscribeItemResult {result: SteamApiResult, published_file_id: int64} (Steamworks_API.gml:2705). Old event ugc_unsubscribe_item (the project ignored it).
- **Signature changes:** _callback is mandatory even for fire-and-forget: the wrapper passes the named no-op function tcc_steam_ugc_noop(_r){}. The noop is used ONLY here, never for subscribe.
- **Gotchas:** Removal happens after the game quits (unchanged, ugc.js:1413). Callers loop and ignore the result.
- **Id types:** int64 file id.
- **Refs:** Steamworks_API.gml:18372; ugc.js:1413

### 5.13 `steam_ugc_num_subscribed_items`
- **New:** steam_ugc_get_num_subscribed_items(_include_locally_disabled); call steam_ugc_get_num_subscribed_items(false) to reproduce 2.x
- **Delivery / confidence:** sync / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:254; objects/o_customlevelsplay/Create_0.gml:6; scripts/scr_timing_ui/scr_timing_ui.gml:349
- **Signature changes:** Renamed; takes ONE bool argument. Fewer arguments than declared is an error (Steamworks.yy argCount 1, args [2]).
- **Gotchas:** RAW native (no GML wrapper: 'Skipping function ... no wrapper is required', Steamworks_API.gml:16603), so it is not protected by extension_exists('Steamworks'): only call behind tcc_steam_ready(). Returns 0 if Steam is uninitialised (gm_steam_ugc.cpp:333).
- **Refs:** Steamworks.yy (steam_ugc_get_num_subscribed_items argCount 1); gm_steam_ugc.cpp:333; ugc.js:381

### 5.14 `steam_ugc_get_subscribed_items`
- **New:** steam_ugc_get_subscribed_items(_max_entries, _include_locally_disabled) -> Array[Real]; use steam_ugc_get_subscribed_items(steam_ugc_get_num_subscribed_items(false), false). Recommended: keep tcc_steam_ugc_get_subscribed_items(_list) as a shim (ds_list_clear + ds_list_add) so the 6 live callers do not change.
- **Delivery / confidence:** sync / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:250; scripts/scr_online_session/scr_online_session.gml:912; scripts/scr_online_session/scr_online_session.gml:995; scripts/scr_workshopER/scr_workshopER.gml:13; objects/o_customlevelsbrowser/Create_0.gml:64; objects/o_workshopchallengecreator/Create_0.gml:24; objects/o_workshopchallengesplay/Mouse_4.gml:11; objects/o_showsubscribedlevels/Draw_73.gml:11 (inside an unterminated /* comment: dead)
- **Signature changes:** Old: (ds_list) filled in place, returned the count. New: returns Array[Real] of int64 ids. The shim returns ds_list_size(list) (false when Steam is unavailable).
- **Gotchas:** Old-style call steam_ugc_get_subscribed_items(list) COMPILES (two declared parameters, no defaults: Steamworks_API.gml:16611) and passes the list index as max_entries and undefined as _include_locally_disabled into the raw native; what GameMaker does with undefined for a double extension argument is UNVERIFIED (may error or return a wrong-length array). Always pass both arguments. ugc.js:384,392 say include_locally_disabled 'Defaults to false' but neither the GML declaration nor Steamworks.yy provides a default. max_entries==0 returns [] and > 65536 returns [] (gm_steam_ugc.cpp:342-366): size it with get_num_subscribed_items. Returns undefined if the extension is missing: guard with is_array.
- **Id types:** Array of int64 (buffer_u64); ds_list_add preserves int64.
- **Refs:** Steamworks_API.gml:16611; ugc.js:392; gm_steam_ugc.cpp:342-366

### 5.15 `steam_ugc_get_item_install_info`
- **New:** steam_ugc_get_item_install_info(_published_file_id) -> SteamUgcItemInstallInfo or undefined. Recommended: keep tcc_steam_ugc_get_item_install_info(_file_id, _map) as a shim (ds_map_clear, then fill size_on_disk / legacy_item / folder) so the 11 callers do not change.
- **Delivery / confidence:** sync / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:238; scripts/scr_online_session/scr_online_session.gml:884; scripts/scr_workshopchallenge/scr_workshopchallenge.gml:113; scripts/scr_workshopchallenge/scr_workshopchallenge.gml:157; scripts/scr_workshopER/scr_workshopER.gml:19; scripts/scr_workshopER/scr_workshopER.gml:182; scripts/scr_workshopER/scr_workshopER.gml:225; objects/o_customlevelsbrowser/Create_0.gml:70; objects/o_workshopERloading/Step_0.gml:37; objects/o_workshopchallengecreator/Create_0.gml:37; objects/o_workshopchallengesplay/Mouse_4.gml:17; objects/o_publishworkshopchallenge/Create_0.gml:91
- **Result struct / fields:** Returns SteamUgcItemInstallInfo {size_on_disk: Real, folder: String, timestamp: Real} (Steamworks_API.gml:2498) or UNDEFINED when not installed. Old ds_map keys: size_on_disk, legacy_item (0/1; derive from steam_ugc_get_item_state(id) & SteamUgcItemState.LegacyItem), folder.
- **Signature changes:** Drops the info_map argument and the bool return. Same name as 2.x: an old-style call steam_ugc_get_item_install_info(id, map) compiles, ignores the map and every level then looks uninstalled, so all raw calls live in the shim.
- **Gotchas:** undefined for not-installed items: callers must never read .folder without an is_undefined check; the existing pattern string(map[? 'folder']) => 'undefined' => level_exists('undefined/') false keeps working through the shim (the shim leaves the map empty). Still sets Steam's 'used' flag. 3.0 no longer whitelists workshop folders in GameMaker's sandbox (GMExtUtils.h:181-183 unused) but the project disables the sandbox on Windows/Linux/default mac (options_windows.yy:12, options_linux.yy:6, options_mac.yy:32); options_mac.yy:7 is the MacAppStore config, which has no Steam.
- **Id types:** file id int64.
- **Refs:** Steamworks_API.gml:16528; ugc.js:346; gm_steam_ugc.cpp:277-303

### 5.16 `steam_ugc_get_item_update_info`
- **New:** steam_ugc_get_item_state(_published_file_id) ; steam_ugc_get_item_download_info(_published_file_id). Recommended: keep tcc_steam_ugc_get_item_update_info(_file_id, _map) as a shim that fills the old keys so callers are unchanged.
- **Delivery / confidence:** sync / medium
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:242; scripts/scr_online_session/scr_online_session.gml:879; objects/o_customlevelsbrowser/Create_0.gml:114; objects/o_customlevelsbrowser/Other_69.gml:70; objects/o_customlevelsbrowser/Step_0.gml:142; objects/o_customlevelsbrowser/Step_0.gml:208; objects/o_customlevelsbrowser/Step_0.gml:225; objects/o_workshopERloading/Step_0.gml:30
- **Result struct / fields:** steam_ugc_get_item_state returns SteamUgcItemState bit flags (None 0, Subscribed 1, LegacyItem 2, Installed 4, NeedsUpdate 8, Downloading 16, DownloadPending 32, DisabledLocally 64; Steamworks_API.gml:783). steam_ugc_get_item_download_info returns SteamUgcItemDownloadInfo {bytes_downloaded, bytes_total} (Steamworks_API.gml:2482) or undefined. Old map keys needs_update, is_downloading, bytes_downloaded, bytes_total, is_legacy, is_download_pending, is_installed (the HTML docs list only four).
- **Signature changes:** OLD-ONLY: no 3.0 function of this name. is_installed = ((_state & SteamUgcItemState.Installed) != 0), same for the other flags. Keep the parentheses; the relative precedence of & and == in GML is not documented in this repo (UNVERIFIED), the shim is correct either way.
- **Gotchas:** 2.x populated the map ONLY when GetItemDownloadInfo returned true (old steam_ugc.cpp:1312-1363) and left it empty otherwise; every caller treats empty (is_installed undefined) as 'not installed'. get_item_state returns 0 for unknown items => same outcome; if Steam returned false for an idle installed item (UNVERIFIED which case occurs, U4) the new behaviour is more accurate. Returns undefined if the extension is missing: guard is_numeric before the bit operations.
- **Id types:** file id int64.
- **Refs:** Steamworks_API.gml:16559, 16497; ugc.js:359, 335

### 5.17 `steam_ugc_request_item_details`
- **New:** tcc_steam_ugc_request_item_details(_file_ids, _max_age_seconds, _callback, _owner = noone) builds: steam_ugc_create_query_ugc_details_request(_chunk) ; steam_ugc_set_allow_cached_response(_qh, _max_age_seconds) ; tcc_steam_ugc_send_query(_qh, _callback, _owner) (-> steam_ugc_send_query_ugc_request, steam_ugc_get_query_ugc_result, steam_ugc_release_query_ugc_request)
- **Delivery / confidence:** callback / medium
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:262; objects/o_customlevelsbrowser/Create_0.gml:122 (id stored in async_details[? req_id]); objects/o_customlevelworkshopbuttonplay/Create_0.gml:21; objects/o_customlevelworkshopbuttonplay/Alarm_0.gml:2 (re-requested every 30 frames forever); objects/o_customlevelworkshopbuttonplay/Other_10.gml:1; objects/o_workshoplevelselectbutton/Alarm_0.gml:7; objects/o_playmostrecentlevelCL/Mouse_4.gml:1 (DEAD: object never placed/created; also reads async_load in a Mouse event)
- **Result struct / fields:** Callback gets SteamUgcQueryCompleted {query_handle, result, num_results_returned, total_matching_results, cached_data} (Steamworks_API.gml:2637); the wrapper reads items with steam_ugc_get_query_ugc_result(query_handle, i) -> SteamUgcQueryResult {published_file_id, title, description, time_created, time_updated, visibility, banned(bool), accepted_for_use(bool), tags_truncated(bool), tags(comma-separated STRING), result, file_type, creator_app_id, consumer_app_id, owner_steam_id, time_added_to_user_list, handle_file, handle_preview_file, file_name, file_size, preview_file_size, url, votes_up, votes_down, score, num_children, total_files_size} (:2532, decoder :7108) and passes only items with result == SteamApiResult.Ok. Old event ugc_item_details keys: id, result, cached_data, published_file_id, file_type, creator_app_id, consumer_app_id, title, description, steam_id_owner, time_*, visibility, banned, accepted_for_use, tags_truncated, tags(array), handle_file, handle_preview_file, filename, file_size, preview_file_size, url, votes_up, votes_down, score, num_children, account_id_owner.
- **Signature changes:** No single replacement (2.x used the deprecated RequestUGCDetails). The wrapper accepts one id or an array, DROPS every id that is not is_numeric and > 0 (3.0 raises a fatal show_error on a non-number, Steamworks_API.gml:16344), returns false if none remain, and sends ONE query per STEAM_UGC_NUM_RESULTS_PER_PAGE (50) ids; the callback _callback(_ok, _items, _completed) fires once PER CHUNK and callers MATCH BY _item.published_file_id, never by index. (ugc.js:236 documents a 1,000 id limit, but nothing shows all results arrive in one callback; ugc.js:215,255 say 50 results per page.) No per-id fallback: a missing id is a deleted or private item, which 2.x also left at 'Loading...'. Field renames: steam_id_owner->owner_steam_id, filename->file_name, tags array->comma string, banned 0/1->bool, account_id_owner removed (derive owner_steam_id & $FFFFFFFF, or steam_user_decode_steam_id(owner_steam_id).account_id, Steamworks_API.gml:14748). Replace async_details[? req_id] by capturing the level struct or matching on published_file_id.
- **Gotchas:** The callback never fires when Steam is unavailable/IO failure or the API call was invalid, so nothing may wait on it: the buttons retry from Alarm_0, the browser keeps 'Loading...' like 2.x. Alarm_0 re-requests every 30 frames FOREVER: stop once loaded == 1 (each call now costs a query handle + a registry entry). The wrapper releases every handle itself (tcc_steam_ugc_on_query_done), also for stale or owner-less responses. steam_ugc_set_allow_cached_response is documented for user/all-UGC handles only (ugc.js:887): its return value is ignored (harmless). Persona-name requests inside these handlers belong to the friends domain. Description truncation is moot: mDesc is only ever assigned (o_customlevelworkshopbuttonplay/Other_69.gml:9, Create_0.gml:7, dead o_playmostrecentlevelCL/Mouse_4.gml:8) and never read (grep of mDesc); call steam_ugc_set_return_long_description only if a description UI is added.
- **Id types:** published_file_id and owner_steam_id are int64 (buffer_u64), NOT SteamId structs (Steamworks_API.gml:7160-7161); owner_steam_id can be passed straight to steam_friends_* functions that take a Real.
- **Refs:** Steamworks_API.gml:16331, 17487, 17390, 16635, 17416; ugc.js:215,233-236,255,880-887,791,406,814; old steam_ugc.cpp:1366-1385, 516-560

### 5.18 `steam_ugc_create_query_all`
- **New:** steam_ugc_create_query_all_ugc_request(_query_type, _matching_ugc_type, _creator_app_id, _consumer_app_id, _page); wrapper call: steam_ugc_create_query_all_ugc_request(_query_type, _match_type, 0, tcc_steam_ugc_app_id(0), _page)
- **Delivery / confidence:** sync / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:234 (fallback -1); scripts/scr_workshopER/scr_workshopER.gml:83; objects/o_customlevelsbrowser/Create_0.gml:54
- **Signature changes:** New arg order and two new app-id args. 2.x fixed creator=0 and consumer=SteamUtils()->GetAppID() (old steam_ugc.cpp:1472-1490). The wrapper keeps the 3-arg signature and calls steam_utils_get_app_id() at call time (raw native, argCount 0, Steamworks_API.gml:15531). Page is the 5th raw arg, still 1-based. Returns the handle, or -1 for undefined/0/-1 (single normalised invalid value).
- **Gotchas:** Raw returns 0 if the guard fails and -1 (STEAM_UGC_QUERY_HANDLE_INVALID, Steamworks_API.gml:113) if Steam rejects it. Test validity ONLY with tcc_steam_ugc_handle_valid(qh) (never '> 0' / '<= 0': handles are u64 read as int64, nothing guarantees they stay below 2^63). scr_workshopER.gml:84 already checks '== 0 || == -1' (correct); o_customlevelsbrowser/Create_0.gml:54 has NO check: add one. The handle must be released after sending (tcc_steam_ugc_send_query does it) or when sending is abandoned. Enum numeric values unchanged.
- **Id types:** query handle Real/int64 (u64).
- **Refs:** Steamworks_API.gml:16289; gm_steam_ugc.cpp:178; ugc.js:210

### 5.19 `steam_ugc_query_set_search_text`
- **New:** steam_ugc_set_search_text(_query_handle, _search_text)
- **Delivery / confidence:** sync / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:258; objects/o_customlevelsbrowser/Create_0.gml:56
- **Signature changes:** Renamed (drops 'query_'), same args; Bool.
- **Gotchas:** Only valid on create_query_all_ugc_request handles and before the send. _search_text must be a string (wrap with string(); skip when the handle is invalid).
- **Refs:** Steamworks_API.gml:18082; ugc.js:1216

### 5.20 `steam_ugc_send_query`
- **New:** tcc_steam_ugc_send_query(_query_handle, _callback, _owner = noone) -> steam_ugc_send_query_ugc_request(_query_handle, tcc_steam_ugc_on_query_done); the global handler reads steam_ugc_get_query_ugc_result(_r.query_handle, i), calls steam_ugc_release_query_ugc_request(_r.query_handle) and then _callback(_ok, _items, _completed).
- **Delivery / confidence:** callback / high
- **Call sites:** scripts/scr_steam_safe/scr_steam_safe.gml:266; scripts/scr_workshopER/scr_workshopER.gml:88 (global.workshopER_query_id); objects/o_customlevelsbrowser/Create_0.gml:58 (browse_query_id)
- **Result struct / fields:** SteamUgcQueryCompleted {query_handle, result: SteamApiResult, num_results_returned, total_matching_results, cached_data} (Steamworks_API.gml:2637). Items: steam_ugc_get_query_ugc_result(handle, i) (SteamUgcQueryResult or undefined; fields in the request_item_details entry). Old ugc_query event: id, event_type, result, num_results, total_matching, ugc_query_handle, cached_data, results_list (ds_list of ds_maps). Key map: num_results->num_results_returned, total_matching->total_matching_results, ugc_query_handle->query_handle, steam_id_owner->owner_steam_id, filename->file_name.
- **Signature changes:** Second arg _callback mandatory; the native returns 0 (undefined if the extension is missing): do not use it as an id. The wrapper returns bool 'attempted'. Callback routing: the result struct carries query_handle, so the native callback is ONE global named function and the per-request callable lives in global.tcc_ugc_queries[string(handle)] = {cb, owner, t}; this removes any dependence on ptr() identity of method() objects (ExtensionCore_api.gml:274-278 keys the native callback by int64(ptr(callable)) and keeps the FIRST callable when a key repeats). User callback shape: _callback(_ok, _items, _completed); pass a method({inst:id, seq:n}, function(_ok,_items,_completed){...}) when per-request context is needed and test instance_exists(inst) and the sequence number first. Staleness: o_customlevelsbrowser keeps browse_seq (a new search can start while one is in flight, Step_0.gml:28-38) instead of matching async ids; scr_workshopER keeps global.workshopER_query_id = the query HANDLE and compares _completed.query_handle == it. 'No active request' stays -1: never use '<= 0' / '> 0' on handles (scr_workshopER.gml:89 and workshopER_catalog_callback '_request <= 0' must become explicit invalid tests); the shipped create_query_all check '== 0 || == -1' (scr_workshopER.gml:84) is already right. Replace the literal 50 at scr_workshopER.gml:351,408 by STEAM_UGC_NUM_RESULTS_PER_PAGE.
- **Gotchas:** 2.x released the query handle itself (comment at scr_workshopER.gml:338 depends on it); 3.0 does NOT (only steam_ugc_release_query_ugc_request, gm_steam_ugc.cpp:774-787): the global handler releases on EVERY path, including stale/ignored/owner-less responses, after reading the items. The callback can fail to arrive (Steam unavailable/IO failure/invalid API call): the browser needs a deadline on 'loading' (set browse_deadline, e.g. 20 s, check it in Step_0); a failed ER catalog scan just leaves workshopER_catalog_scan_done false, which only means the catalog pool is not used (scr_workshopER.gml:107), no hang. Optional tcc_steam_ugc_query_sweep() drops registry entries older than 120 s and releases their handles. banned/accepted_for_use/tags_truncated are bools; tags is a comma string: delete the is_array branch of the tag parsers. Only the browser's array branches matched tags exactly; the other consumers already ran string_count on a stringified array (o_customlevelworkshopbuttonplay/Alarm_0.gml:19-24, o_workshoplevelselectbutton/Other_69.gml:10-15) and no tag in level_publish_tags (scr_level_document.gml:780-798) or 'Challenges' contains another tag as a substring, so substring matching is equivalent; optionally split on ',' for exact matching. The selfchecks that fabricate ds_map ugc_query events (scr_workshopER.gml:419-499) must become synthetic SteamUgcQueryCompleted / SteamUgcQueryResult structs fed to a pure parser.
- **Id types:** query handle and item ids int64; compare handles with ==.
- **Refs:** Steamworks_API.gml:17390, 16635, 17416; ugc.js:791, 406, 814; gm_steam_ugc.cpp:774-787,1474-1486; old steam_ugc.cpp:689-735; ExtensionCore_api.gml:240-371

### 5.21 `ugc_result_success`
- **New:** SteamApiResult.Ok
- **Delivery / confidence:** constant-or-enum / high
- **Call sites:** scripts/scr_workshopER/scr_workshopER.gml:347,360,445,451,481; scripts/scr_level_document/scr_level_document.gml:775,925; scripts/scr_online_multiplayer/scr_online_multiplayer.gml:1142; objects/o_customlevelworkshopbuttonplay/Other_69.gml:6; objects/o_playmostrecentlevelCL/Mouse_4.gml:5; objects/o_workshoplevelselectbutton/Other_69.gml:4; objects/o_customlevelsbrowser/Other_69.gml:10,95; objects/o_workshopERloading/Other_69.gml:6; objects/o_publishworkshopchallenge/Other_69.gml:13,45
- **Signature changes:** Value 1 in both (old Steamworks.yy ugc_result_success 1; Steamworks_API.gml:314-317 SteamApiResult.Ok = 1). The constant no longer exists in 3.0 (0 matches in extensions/Steamworks/Steamworks.yy).
- **Gotchas:** Fields named result are now SteamApiResult enums in callback structs, not ds_map doubles. '_event[? "result"] == ugc_result_success' becomes '_r.result == SteamApiResult.Ok'.
- **Refs:** Steamworks_API.gml:314; api.js:283

### 5.22 `ugc_filetype_community`
- **New:** SteamRemoteStorageWorkshopFileType.Community
- **Delivery / confidence:** constant-or-enum / high
- **Call sites:** objects/o_publishinghappenshere/Create_0.gml:45; objects/o_publishworkshopchallenge/Create_0.gml:176
- **Signature changes:** Value 0 in both (ugc_filetype_microtrans 1 = Microtransaction 1). Enum at Steamworks_API.gml:1502. The old constant is absent from 3.0.
- **Refs:** Steamworks_API.gml:1502

### 5.23 `ugc_visibility_public`
- **New:** SteamRemoteStoragePublishedFileVisibility.Public
- **Delivery / confidence:** constant-or-enum / high
- **Call sites:** objects/o_publishinghappenshere/Create_0.gml:24; objects/o_publishworkshopchallenge/Other_69.gml:23
- **Signature changes:** Value 0 in both. Enum at Steamworks_API.gml:766 (Public 0, FriendsOnly 1, Private 2, Unlisted 3). The old constant is absent from 3.0.
- **Refs:** Steamworks_API.gml:766

### 5.24 `ugc_match_Items`
- **New:** SteamUgcMatchingUgcType.Items
- **Delivery / confidence:** constant-or-enum / high
- **Call sites:** scripts/scr_workshopER/scr_workshopER.gml:83; objects/o_customlevelsbrowser/Create_0.gml:54
- **Signature changes:** Value 0 in both. Enum at Steamworks_API.gml:689 (Items 0, Items_Mtx 1, ..., All -1). The old constant is absent from 3.0.
- **Refs:** Steamworks_API.gml:689

### 5.25 `ugc_query_RankedByVote`
- **New:** SteamUgcQuery.RankedByVote
- **Delivery / confidence:** constant-or-enum / high
- **Call sites:** objects/o_customlevelsbrowser/Create_0.gml:54
- **Signature changes:** Value 0 in both. Enum at Steamworks_API.gml:707. The old constant is absent from 3.0.
- **Refs:** Steamworks_API.gml:707

### 5.26 `ugc_query_RankedByPublicationDate`
- **New:** SteamUgcQuery.RankedByPublicationDate
- **Delivery / confidence:** constant-or-enum / high
- **Call sites:** scripts/scr_workshopER/scr_workshopER.gml:83
- **Signature changes:** Value 1 in both. Enum at Steamworks_API.gml:707. The old constant is absent from 3.0.
- **Refs:** Steamworks_API.gml:707

### 5.27 `event_type "ugc_create_item" (async_load)`
- **New:** callback passed through tcc_steam_ugc_create_item(_app_id, _file_type, _callback, _owner) (raw: last argument of steam_ugc_create_item)
- **Delivery / confidence:** event-removed / high
- **Call sites:** scripts/scr_level_document/scr_level_document.gml:761-778 (level_publish_callback), 924 (selfcheck fixture); objects/o_publishworkshopchallenge/Other_69.gml:5; objects/o_publishinghappenshere/Other_69.gml:1 (via level_publish_callback)
- **Result struct / fields:** SteamUgcCreateItemResult {result, published_file_id, legal_agreement_required}
- **Gotchas:** No Steam Async Event, no async_load[? "id"], no event_type any more. Selfchecks that build ds_map events must build new SteamUgcCreateItemResult() structs instead.

### 5.28 `event_type "ugc_update_item" (async_load)`
- **New:** callback passed through tcc_steam_ugc_submit_item_update(_h, _note, _callback, _owner) (raw: last argument of steam_ugc_submit_item_update)
- **Delivery / confidence:** event-removed / high
- **Call sites:** scripts/scr_level_document/scr_level_document.gml:770, 929 (selfcheck fixture); objects/o_publishworkshopchallenge/Other_69.gml:37; objects/o_publishinghappenshere/Other_69.gml:1
- **Result struct / fields:** SteamUgcSubmitItemUpdateResult {result, legal_agreement_required}
- **Gotchas:** Event name 'ugc_update_item' becomes the submit callback; the result struct has no published_file_id.

### 5.29 `event_type "ugc_subscribe_item" (async_load)`
- **New:** tcc_steam_ugc_on_subscribed(_r): shared global callback chained by tcc_steam_ugc_subscribe_item (raw: last argument of steam_ugc_subscribe_item)
- **Delivery / confidence:** event-removed / high
- **Call sites:** objects/o_workshopERloading/Other_69.gml:5-11; scripts/scr_online_multiplayer/scr_online_multiplayer.gml:1139-1148 (net_handle_async_steam, routed from objects/o_networkmanager/Other_69.gml:3)
- **Result struct / fields:** SteamUgcSubscribeItemResult {result, published_file_id}
- **Gotchas:** Was broadcast to every consumer; the single shared handler preserves that (see steam_ugc_subscribe_item). Remove the case from net_handle_async_steam; delete o_workshopERloading/Other_69.gml.

### 5.30 `event_type "ugc_query" (async_load)`
- **New:** callback passed through tcc_steam_ugc_send_query(_qh, _callback, _owner) (raw: last argument of steam_ugc_send_query_ugc_request)
- **Delivery / confidence:** event-removed / high
- **Call sites:** objects/o_customlevelsbrowser/Other_69.gml:9-91; scripts/scr_workshopER/scr_workshopER.gml:345,450,461,480 (catalog callback + selfcheck); objects/o_workshopERloading/Other_69.gml:12
- **Result struct / fields:** SteamUgcQueryCompleted + items from steam_ugc_get_query_ugc_result; the handle is released by the global handler.
- **Gotchas:** results_list ds_list/ds_map no longer exists (the ds_map was owned by async_load and valid only inside the event). Items arrive as an array of SteamUgcQueryResult.

### 5.31 `event_type "ugc_item_details" (async_load)`
- **New:** details query via tcc_steam_ugc_request_item_details (steam_ugc_create_query_ugc_details_request + send + get_query_ugc_result + release)
- **Delivery / confidence:** event-removed / medium
- **Call sites:** objects/o_customlevelsbrowser/Other_69.gml:94-135 (async_details lookup, no event_type check; async_details created Create_0.gml:38, destroyed CleanUp_0.gml:17); objects/o_customlevelworkshopbuttonplay/Other_69.gml:1-18 (matched on id==steam_details only); objects/o_workshoplevelselectbutton/Other_69.gml:1-24; objects/o_playmostrecentlevelCL/Mouse_4.gml:3-15 (dead)
- **Result struct / fields:** SteamUgcQueryCompleted + SteamUgcQueryResult
- **Gotchas:** These handlers matched ONLY on async_load[? "id"] == request id, not on event_type; with ids gone the logic moves into the details callback. Persona-name branches in the same files are friends-domain.

### 5.32 `ugc_item_subscribed / ugc_item_unsubscribed / ugc_item_installed (unsolicited 2.x events)`
- **New:** steam_ugc_set_callback_user_subscribed_items_list_changed(_callback) ; steam_ugc_set_callback_item_installed(_callback) ; steam_remote_storage_set_callback_published_file_subscribed / _unsubscribed (other domain)
- **Delivery / confidence:** event-removed / high
- **Call sites:** NONE: grep for "ugc_ strings finds only ugc_create_item, ugc_update_item, ugc_subscribe_item, ugc_query (+ ugc_download_item in a selfcheck fixture)
- **Result struct / fields:** SteamUgcItemInstalled {app_id, published_file_id} (Steamworks_API.gml:2606); SteamUgcUserSubscribedItemsListChanged {app_id} (:2622)
- **Gotchas:** Unused by the project, nothing to port. Optional replacement for polling in o_workshopERloading and the browser download_state poll. item_installed fires for all apps: filter app_id yourself.

---

## 6. Decisions on the verifier disputes

Verdict key: ACCEPT = dispute right, map corrected; PARTIAL = part right; the evidence column names the source I read myself.

| # | Entry | Verdict | Evidence and outcome |
|---|---|---|---|
| 1 | subscribe_item: noop default drops both broadcast jobs | ACCEPT (risky) | `scr_online_multiplayer.gml:1139-1148`, `o_workshopERloading/Other_69.gml:5-11`, `Steamworks_API.gml:18342`. The wrapper has no callback parameter and ALWAYS chains the shared `tcc_steam_ugc_on_subscribed`; the noop is used only by unsubscribe. Guards are split: ER skip never needed `net_ready` (the old net branch bailed at `scr_online_multiplayer.gml:1018`); net bookkeeping needs `net_ready`, `ds_exists(net_ugc_failed)` and the subscribed array. The proposed fix's typo `tcc_steam_ugc_tcc_steam_ugc_noop` is just `tcc_steam_ugc_noop`. |
| 2 | set_item_content: no check, no normalisation | ACCEPT existence check; REJECT separator rewriting | Old `steam_ugc.cpp:1017-1060` returned 0 when `DirExists` failed; new `gm_steam_ugc.cpp:899-909` forwards verbatim. Wrapper: `directory_exists()` gate. No separator rewriting and no `//` collapsing (UNC paths; `directory_set.gml:8` writes `MODS//` on purpose). Conflicts with #14 and resolves with it: see #14 and U1. |
| 3 | set_item_preview: file_exists + "1MB has no source" | PARTIAL | `file_exists()` gate ACCEPTED (2.x `steam_ugc.cpp:1066-1100`; challenge flow pre-checks at `o_publishworkshopchallenge/Other_69.gml:27` but ignores the result). The claim that 1MB is absent from `ugc.js` is WRONG as a statement: `ugc.js:87` (`steam_ugc_add_item_preview_file`) and `:1464` (`steam_ugc_update_item_preview_file`, both read) say "must be under 1MB"; `ugc.js:960-974` (`set_item_preview`) does not. Entry now says exactly that; no size check (2.x had none). |
| 4 | request_item_details: unvalidated ids | ACCEPT (risky) | `Steamworks_API.gml:16344` fatal `show_error` on a non-number element. Wrapper filters to numeric `> 0`, returns false if none remain. |
| 5 | create_item: never-fires list incomplete | ACCEPT (nit) | `steam_async_common.h:21-24` and `gm_steam_ugc.cpp:1482,1494,1509,1522,1533`: `set(call)` is unconditional. Rule 6 rewritten; wrapper return documented as "attempted"; deadlines for publish and browser. Net follow (`scr_online_session.gml:550-554`), `o_workshopERloading` and the ER catalog scan were checked and need no new deadline. The "pending refcount stays up / object leaks" consequence is plausible but SDK-side (UNVERIFIED). |
| 6 | send_query: callback identity / "returns nothing useful" | ACCEPT (nit), resolved by design | `ExtensionCore_api.gml:274-278` keys by `int64(ptr(callable))` and keeps the first callable; `SteamworksInternal_native.cpp:2488-2503` returns 0 and the GML wrapper returns it (`Steamworks_API.gml:16275-16279`). Replaced the per-call `method({cb})` by one global native callback plus a registry keyed by `query_handle`, a single-flight slot for create/submit, and a context-free subscribe handler (rule 4). Return value reworded: constant 0 / undefined, never an id. Handle checks no longer use `> 0`. |
| 7 | get_subscribed_items: "silently passes" | ACCEPT (nit) | No parameter defaults at `Steamworks_API.gml:16611`; `ugc.js:384,392` claim a default that code and `Steamworks.yy` lack. Reworded to "compiles; behaviour with undefined for a double extension argument UNVERIFIED". |
| 8 | submit_item_update: "destroyed after its 120 s timeout" | ACCEPT (nit) | `Step_0.gml:3-7`, `KeyPress_27.gml:1-3`, `o_publishlevelLE/Create_0.gml:4`. Rule 5 reworded; also noted `wait_seconds` resets at `Create_0.gml:30`, so the 120 s deadline covers the submit phase too. |
| 9 | ugc_item_details cited `Create_0.gml:36` | ACCEPT (nit) | `async_details` is created at `Create_0.gml:38` (read myself). Corrected. |
| 10 | send_query: `_query_handle > 0` / `<= 0` sentinel | ACCEPT (risky) | Handles are u64 read as int64 (`Steamworks_API.gml:113`, `buffer_read(buffer_u64)`). One helper `tcc_steam_ugc_handle_valid` for query AND update handles (no asymmetry; the shipped `<= 0` at `o_publishinghappenshere/Create_0.gml:21` is replaced by the helper). `scr_workshopER.gml:84` (`== 0 \|\| == -1`) was already right; `:89` and `workshopER_catalog_callback` (`_request <= 0`) must change. |
| 11 | request_item_details: one batch of up to 1000 ids | ACCEPT (risky) | `ugc.js:236` documents 1,000 ids, `ugc.js:215,255` and `STEAM_UGC_NUM_RESULTS_PER_PAGE = 50` (`Steamworks_API.gml:109`) limit a page; nothing shows 1,000 results in one callback. Wrapper chunks to 50, callback per chunk, match by `published_file_id`. No per-id fallback (a missing id is a deleted/private item, left at "Loading..." as in 2.x). `set_allow_cached_response` return ignored (`ugc.js:887`). |
| 12 | create_item: app id only `is_numeric` | ACCEPT (nit) | `global.appid = tcc_steam_get_app_id()` (`o_title/Create_0.gml:28`), fallback `false` (`scr_steam_safe.gml:66-69`). `tcc_steam_ugc_app_id()` resolves `steam_utils_get_app_id()` at call time and requires `> 0`; used by create_item, start_item_update and create_query_all. `is_numeric(false)` being true is assumed (U10). |
| 13 | create_item: rule 5 wording | ACCEPT (nit) | Duplicate of #8. |
| 14 | set_item_preview: slash normalisation / QA branch | PARTIAL | QA claim ACCEPTED: `platform_steam()` is false when `TCC_GAMEPLAY_QA` (`scr_platform.gml:17`) while `qa_active()` needs it (`scr_gameplay_qa.gml:3-4`), so the QA branch of `directory_set` (`:2`) never reaches a Steam wrapper; risk (b) dropped. Separator advice: neither `\` nor `/` can be confirmed from the repo, and `level_directory()` already forces `/` (`scr_level_document.gml:35`) while the challenge path is raw `directory_set`. Decision: NO rewriting (single hook `tcc_steam_ugc_path()` for a later fix) and a must-test on Windows for BOTH flows (U1). |
| 15 | update_info: "== binds tighter than &" | ACCEPT (nit) | No source in the repo, and GML may differ from C. Claim removed; parentheses kept (the shim parenthesises every test). |
| 16 | description truncation parity | ACCEPT (nit) | `mDesc` is only assigned (`o_customlevelworkshopbuttonplay/Other_69.gml:9`, `Create_0.gml:7`, dead `o_playmostrecentlevelCL/Mouse_4.gml:8`), never read. Open question closed as moot. |
| 17 | set_item_title: "returns false beyond 128" | ACCEPT (nit) | Limits are documented (`ugc.js:1002`, `:938`); failure mode marked UNVERIFIED, no truncation added. |
| 18 | send_query: dropping `is_array(_tags)` | ACCEPT (nit) | Only the browser's array branches matched exactly; `o_customlevelworkshopbuttonplay/Alarm_0.gml:19-24` and `o_workshoplevelselectbutton/Other_69.gml:10-15` already ran `string_count` on a stringified array, and no tag of `level_publish_tags` (`scr_level_document.gml:780-798`) or `"Challenges"` contains another as a substring. Documented; optional split on ','. |
| 19 | subscribe_item: "true means the callback will fire" | ACCEPT (nit) | Merged with #5: the wrapper contract is "attempted", deadlines are the caller's job. |

| 20 | (resolver) single-flight slot for create/submit | DECISION | The results carry no key, so attribution is only correct if at most one request per kind is pending. Price: after a timeout a retried publish is refused for up to 60 s (slot 180 s vs caller deadline 120 s) and the caller reports result 4. Callers must test the wrapper return (handler table). Alternative (per-request `method()` objects) was rejected because it depends on the unresolved `ptr()` identity question (U2). |

Cross-domain hand-offs and divergences:
- `net_handle_async_steam` / `o_networkmanager/Other_69.gml` (`map-lobby.final.md` section 6 and item 14, `async-handlers-2.md` section 3): this map removes ONLY the `ugc_subscribe_item` case. The `avatar_image_loaded` case (friends domain) and the lobby cases (lobby domain) stay until their own migrations land; the file and its `.yy` event entry may be deleted only by the last of the three domains.
- `async-handlers-2.md` section 4.6 agrees on ONE shared subscribe listener and on `instance_exists(o_workshopERloading)` before touching the loader. Divergences: (a) it suggests a `tcc_steam_ugc_subscribe(file_id, cb)` listener list; this map keeps the 1-arg `tcc_steam_ugc_subscribe_item(file)` so the five call sites do not change. (b) its browser item 7 wants to flip a tile back from "pending" when a subscribe fails (new behaviour): add an optional branch (c) to `tcc_steam_ugc_on_subscribed` (`if (_failed && instance_exists(o_customlevelsbrowser)) with (o_customlevelsbrowser) { ...find the tile by file id... }`); not required for parity, the 60-frame poll already reconciles states. (c) it stales ER catalog replies with a serial and calls `create_query_all_ugc_request(..., global.appid, global.appid, page)`; this map compares the query HANDLE (unique per request) and reproduces 2.x exactly (creator 0, consumer = app id); a serial bump in `workshopER_cleanup` / `workshopER_start` remains compatible (set `global.workshopER_query_id = -1`). (d) its 20 s catalog deadline is optional here: an unfinished scan only leaves the catalog pool unused (`scr_workshopER.gml:107`).
- Guard helper: `tcc_steam_ready()` as proposed in `map-lobby.final.md` section 6. Pump and rename: core domain.

Additional findings by the resolver (not in the disputes): (a) the old net follow path, ER loading screen and ER catalog scan are already bounded or degrade gracefully (rule 6); (b) callbacks run with `self` = a dummy struct, so the named globals avoid instance variables; (c) `o_workshopERloading` is persistent, so the subscribe handler checks `instance_exists` before `with`; (d) the challenge flow ignores setter results (title/content), recommended to check them; (e) pooled details callbacks arrive per 50-id chunk, so browser code must tolerate partial arrival.

---

## 7. Unresolved

- **U1 (BLOCKING before merge: must-test on a real Windows build).** Whether Steam accepts the raw paths on Windows in BOTH flows: level publish (`level_directory()` => `/` with a possible `//`, `scr_level_document.gml:33-38,540-548`) and the challenge publish (raw `directory_set`, mixed `\` and `/`, `o_publishworkshopchallenge/Create_0.gml:55`). 2.x passed these through GameMaker's `SaveFileName` first. Fallback: normalise inside `tcc_steam_ugc_path()`. Also unknown: trailing slash on the content folder.
- **U2 (BLOCKING smoke test, shared with `map-inventory.final.md` U2).** `int64(ptr(callable))` must give distinct keys for different named functions and a stable key when the SAME named function is registered repeatedly (the registry refcount path, `ExtensionCore_api.gml:274-278`). This design registers five named globals and one of them (`on_query_done`) many times concurrently. Fallback if different named functions collide: a single native callback that dispatches on `instanceof(_r)` (`SteamUgcQueryCompleted`, `SteamUgcCreateItemResult`, `SteamUgcSubmitItemUpdateResult`, `SteamUgcSubscribeItemResult`, `SteamUgcUnsubscribeItemResult`).
- **U3.** Whether Steam returns an invalid `SteamAPICall_t` for bad handles/arguments (standard SDK behaviour, not visible in the repo); mitigated by deadlines and the slot/registry expiry. Also: `tcc_steam_ugc_query_sweep` releases a handle and a late `on_query_done` would release it again; Steam most likely returns false on a double release (harmless, UNVERIFIED).
- **U4.** GetItemDownloadInfo for installed idle items (2.x map emptiness) vs `GetItemState`: the shim is never worse, which case occurred in 2.x is UNVERIFIED.
- **U5.** Whether SetItemContent/SetItemPreview fail at set time or at submit for bad content (the wrappers now cover missing paths; other failures surface in the submit result).
- **U6.** Title (128 bytes) / description (8000 bytes) failure mode beyond the limit; primary preview size limit (1 MB documented only for the sibling preview functions); no checks added.
- **U7.** Whether `undefined` passed as a double extension argument errors or coerces (old-style `steam_ugc_get_subscribed_items(list)` call).
- **U8.** u64 ids/handles >= 2^63 wrap negative (shared with inventory U1): handles tolerate this, file ids use `> 0` (real Workshop ids are far below 2^63).
- **U9.** Relative precedence of `&` and `==` in GML (code parenthesised, so moot).
- **U10.** `is_numeric(false)` being true in GML (code is robust either way: it also requires `> 0`).
- **U11.** `steam_api_run_callbacks()` pump placement and the `steam_initialised()` rename are owned by the core domain; every callback here depends on them.

---

## 8. Evidence index

- Wrapper block: `scripts/scr_steam_safe/scr_steam_safe.gml:230-309`; `tools/check_port.py:78-79`.
- 3.0 GML: functions `:16253` create_item, `:16289` create_query_all, `:16331` details request, `:16497` download_info, `:16528` install_info, `:16559` item_state, `:16583` update_progress, `:16611` get_subscribed_items, `:16635` get_query_ugc_result, `:17390` send_query, `:17416` release, `:17487` allow_cached, `:17538-17780` set_item_*, `:17957` return_long_description, `:18082` search_text, `:18193` start_item_update, `:18310` submit, `:18342` subscribe, `:18372` unsubscribe; structs `:2482-2705`; enums `:689,707,766,783,795,1502,314`; decoders `:7108`; macros `:109-115`; availability `:24764`.
- 3.0 native: `gm_steam_ugc.cpp` (`:178,200,277-303,333,342-366,774-787,899-942,1203,1474-1534`); `steam_async_common.h:11-60`; `SteamworksInternal_native.cpp:2488-2503`; `GMSteamworks.h:14-24`.
- Dispatcher: `ExtensionCore_api.gml:240-371`. 2.1.6 native `old_steam_ugc.cpp` (`:593-630,689-735,1017-1104,1312-1363,1366-1385,1472-1490`).
- Project: `o_publishinghappenshere/{Create_0,Step_0,KeyPress_27,Other_69}.gml`, `o_publishlevelLE/Create_0.gml:4`, `o_publishworkshopchallenge/{Create_0,Step_0,Other_69}.gml`, `o_customlevelsbrowser/{Create_0,Step_0,Other_69,CleanUp_0}.gml`, `o_workshopERloading/{Create_0,Step_0,Other_69}.gml`, `scr_workshopER.gml:77-95,340-499`, `scr_online_session.gml:40-72,877-1006`, `scr_online_multiplayer.gml:1017-1148`, `scr_platform.gml:17`, `scr_gameplay_qa.gml:3-4`, `directory_set.gml`.
- Old constants: `<scratch>/port/old2x/Steamworks.yy`.
