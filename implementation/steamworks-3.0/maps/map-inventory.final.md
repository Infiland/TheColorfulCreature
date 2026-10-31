# Steamworks 2.1.6 -> 3.0.0 migration map: INVENTORY domain (FINAL, disputes resolved)

Project root: `/Users/infi/Documents/Github/TheColorfulCreature` (branch `feat/steamworks-3-0`). Read-only investigation; nothing under the project was changed. This file supersedes `map-inventory.md`. The JSON twin is `map-inventory.final.json` (15 entries, same fields as the structured entries).

Abbreviations used for evidence:

- `API.gml` = `scripts/Steamworks_API/Steamworks_API.gml` (3.0 GML wrappers, enums, structs). Never print its last line (24773).
- `YY` = `extensions/Steamworks/Steamworks.yy` (3.0 extension declaration)
- `NATIVE` = `extensions/Steamworks/source/src/gm_steam_inventory.cpp` (3.0 C++ shipped inside the extension, so native behaviour is read, not guessed)
- `GLUE` = `extensions/Steamworks/source/code_gen/native/SteamworksInternal_native.cpp`
- `ASYNC` = `extensions/Steamworks/source/src/steam_async_common.h`
- `DOCS3` = `<scratchpad>/gmext/src/docs/inventory.js`
- `DOCS2` = `.../scratchpad/port/old2x/extensions/Steamworks/docs/inventory.html` (text dump `.../scratchpad/port/old_inventory.txt`); `OLDYY` = `.../scratchpad/port/old2x/Steamworks.yy`
- `SAFE` = `scripts/scr_steam_safe/scr_steam_safe.gml`, `TRADE` = `scripts/scr_tradeup/scr_tradeup.gml`
- `CORE` = `.../scratchpad/port/map-core.md`, `ASH1` = `.../scratchpad/port/async-handlers-1.md`

---------------------------------------------------------------------------------------------------

## 0. TL;DR - what actually changes

1. **No Async Steam event any more.** `inventory_result_ready`, `inventory_request_prices`, `inventory_full_update` are gone. Results arrive as a **struct** passed to a **GML callback** (`SteamInventoryResultReady {result_handle, result}`), delivered after `steam_api_run_callbacks()` runs (the project already has a pump, see section 3).
2. **Three different routing rules:**
   - `steam_inventory_get_all_items()` takes **no callback**. Its result reaches GML **only** through the single global slot registered with `steam_inventory_set_callback_result_ready(cb)` (NATIVE:970-1000: per-call one-shot first, else global fallback).
   - `steam_inventory_exchange_items(..., cb)` and `steam_inventory_trigger_item_drop(id, cb)` take a per-call callback. That handle's result goes to its own callback and **never** to the global one.
   - `steam_inventory_request_prices(cb)` is a Steam CallResult; its callback gets `SteamInventoryRequestPricesResult {result, currency}` and is NOT guaranteed to fire.
3. **Struct field renames** (silently breaks `tradeup_inventory_snapshot`): result items are `{item_instance_id, item_def_id, quantity, flags}`, not `{item_id, item_def, quantity, flags}`.
4. **Exchange inputs must be constructor instances** (`new SteamInventoryItemDefQuantity()` / `new SteamInventoryItemInstanceQuantity()`); a plain struct literal is fatal (the `.__uid` read at API.gml:21159/21169 either errors by itself or reaches `show_error`).
5. **`steam_inventory_get_result_items` returns `undefined` for an EMPTY inventory** (not `[]`), which the current snapshot code reads as "Inventory unavailable".
6. **Function renames:** `result_get_status` -> `get_result_status`, `result_get_items` -> `get_result_items`, `result_get_item_property` -> `get_result_item_property`, `result_get_unix_timestamp` -> `get_result_timestamp`, `result_destroy` -> `destroy_result`.
7. **Every wrapper guard must change:** `steam_initialised()` does not exist in 3.0; use `steam_api_is_initialized()` (YY:22, native, no GML wrapper). The CORE map owns that mechanical rewrite.
8. **Without Steam, 3.0 inventory does NOT crash.** Every native entry point checks `steam_api_is_initialized()` before touching `SteamInventory()` (section 4).
9. **Global callback slot is single and must be owned by exactly one instance** (section 5.1): register after `owns_inventory = true`, clear only inside the `if (owns_inventory)` guard, and nobody else touches the slot.

---------------------------------------------------------------------------------------------------

## 1. Decisions on the 12 disputes (all verified at source)

| # | Dispute | Decision | Evidence / what changed in this map |
|---|---|---|---|
| 1 | Creation paths of `o_getallinventoryitems`: the room-placed duplicate would clear the owner's global callback (severity risky) | **ACCEPT.** The old md mentioned the placement in 1.2 but never tied it to the register/clear rule, and the JSON gotcha omitted it. Now explicit: register between Create_0 line 9 and 10 (owner only); clear only inside `if (owns_inventory)` in CleanUp_0; no other caller may touch the slot. | `rooms/r_skinmenu/r_skinmenu.yy:161` (`inst_51393B35`, layer "Items", x=140,y=0); `Create_0.gml:4-8` (duplicate calls `tradeup_request_inventory()` then `instance_destroy()`); `Create_0.gml:1-2` (`owns_inventory = false` is set first, so the Steam-less early `instance_destroy()` is also safe once the clear is guarded); `CleanUp_0.gml:1`; NATIVE:943 `g_cb_result_ready`, :1028-1038 set/clear store/null one pointer under one mutex. A duplicate's `CleanUp` runs on its `instance_destroy()`, so an UNguarded clear would remove the owner's callback and the inventory would never load again. Other creators: `o_loading/Create_0.gml:17`, `o_tradeup_menu/Create_0.gml:3-4`. Re-registering from a duplicate would be harmless (refcounted, ExtensionCore_api.gml:271-290) but is pointless, so owner-only. |
| 2 | Third inventory handler omitted from JSON call_sites: `o_tradeup_menu/Other_69.gml` + `o_tradeup_menu.yy:8` | **ACCEPT.** Added. Decision: DELETE the file and its yy event entry, same as the other two, so no stray Async-Steam events remain. | `o_tradeup_menu/Other_69.gml:1-2` is two comment lines; `o_tradeup_menu.yy:8` = `{eventNum:69,eventType:7}`. The old md had it (1.3, 7.7) but the JSON did not. CORE:152 also lists o_tradeup_menu as "no core dependency". |
| 3 | `steam_api_run_callbacks()` "never called" hides the existing 2.x pump | **ACCEPT (reword).** The pump exists: `tcc_steam_update()` (SAFE:310-312, wraps `steam_update()`), called by `objects/o_fullscreensystem/Step_0.gml:4` behind `platform_steam()`, after `if (!timing_instance_step()) exit;` on line 1. The CORE map already remaps it (CORE:166-167: `steam_api_run_callbacks()` with the `steam_api_is_initialized()` guard, "Must run every frame" CORE:79). Do NOT add a second pump. | `o_fullscreensystem.yy:23` persistent; created by `o_loading/Create_0.gml:13`; **destroyed** by `o_endingreq/Create_0.gml:3` (`instance_destroy(o_fullscreensystem)`), after which nothing pumps (CORE:218). Concrete lock path: a trade pending when the ending starts never unlocks (`trade_handle` has no timeout, TRADE:136-138). grep for `steam_api_run_callbacks` outside API.gml: no hits (it is only called through the remapped wrapper). |
| 4 + 8 | "Native treats handle 0 as invalid" is overbroad | **ACCEPT (reword).** `inv_rr_is_valid_handle` (NATIVE:49-52, rejects -1 and 0) gates only `inv_rr_register_once` (:54-58), the one-shot lookup in `OnResultReady` (:977) and `steam_inventory_destroy_result` (:214). `steam_inventory_get_all_items` (:295-306) returns the raw SDK handle with no 0 check. | The wrapper's `>= 1` normalisation and `tradeup_handle_valid` lower bound 1 stay, but as a defensive project choice (real Steam handles are positive; 0 would be a handle that can never be destroyed or one-shot routed). |
| 5 | `steam_inventory_result_invalid` (-1) does have a 3.0 equivalent | **ACCEPT.** `#macro STEAM_INVENTORY_RESULT_INVALID -1` (API.gml:147) and `STEAM_INVENTORY_ITEM_INSTANCE_ID_INVALID -1` (API.gml:149); old constant `OLDYY:94`. Project never uses it. Only `steam_inventory_result_status_invalid` (a status, not a handle) has no enum member. | Folded into the constants entry; usable as the wrappers' failure sentinel. |
| 6 | "wrapper checks `.__uid` ... -> fatal" is wrong about the branch | **ACCEPT (reword, without asserting GML's exact fault).** The reads are at API.gml:21159 and 21169; a plain `{item_def,quantity}` literal has no `__uid` member (it exists only as a `static` in the constructors, API.gml:3416-3446). Either the read itself raises a runtime error or it reaches `show_error(..., true)`; fatal either way. Constructor instances are mandatory. | Dispute cited lines 21158/21167; actual lines are 21159/21169. |
| 7 | `steam_inventory_destroy_result` "returns nothing" | **ACCEPT.** C++ is `void` (NATIVE:210) but the GML-visible function is native-direct with `@returns {Real}` (YY:471, returnType 2) and the glue returns a meaningless `0` (GLUE:5249-5253). 0 is falsy and equals the old failure value `false`, so never forward the raw value; the tcc_ wrapper returns an explicit `true`/`false`. | |
| 9 | `current_price` as the numeric replacement for old `get_item_price` has no source | **ACCEPT.** No 2.x inventory source exists in the scratchpad (`oldsrc`, `old2x_cpp`, `old2x_head`: no match). DOCS2 and OLDYY:438 say only `@returns {Int64}`. 3.0 returns `{current_price, base_price}` (NATIVE:883-901). Marked as an ASSUMPTION; wrapper returns `current_price` (the price actually charged). No live caller, so low risk. Listed under unresolved. | |
| 10 | (dup of 2) | merged with 2 | |
| 11 | Stale doc comment `TRADE:165` names the old API | **ACCEPT.** Documentation-only call site; new text below in 5.2. `tools/check_port.py:79` does not flag it (regex needs `steam_inventory_...(`), but do not write a call-like `name(` in the new comment. | |
| 12 | request_prices callback silent cases incomplete | **ACCEPT and widen.** Three silent paths: (a) Steam down (`STEAM_GUARD()` / null iface, NATIVE:1085-1090), (b) dispatch failure `k_uAPICallInvalid` (NATIVE:1094-1097, sets last error, returns), (c) IO failure: `ReportIoFailure` defaults to `false` (ASYNC:11) and `on_result` drops the callback (`delete this`, ASYNC:33-44; NATIVE:1099 uses the default). Never gate state on it. Same conclusion as ASH1 section 1.5. | Deleting `o_title/Other_69.gml` stays safe because its body is a no-op. |

### Gaps found while resolving (not in the disputes)

- **G1. The proposed matcher also accepts a `SteamInventoryFullUpdate`-shaped struct.** `tradeup_result_matches` checking only `result_handle` would accept `{result_handle:5}`. Require BOTH `result_handle` and `result`. The old selfcheck "unrelated inventory event cannot complete a trade" (TRADE:49-50) then translates to `!tradeup_result_matches({result_handle:5},5)`.
- **G2. Conflict with ASH1.md section 2.3.** That file's `tcc_steam_inventory_trigger_item_drop` / `request_prices` wrappers return `true`/`false` and pass bare script functions; this map's wrappers return the handle (-1 on failure) and (originally) used `method(undefined, fn)`. **This map is authoritative for the inventory wrappers.** Callers ignore the return values of both, so either return convention works at `o_title/Create_0.gml:4-5`; this map keeps the handle/-1 convention because it matches the old `get_all_items` wrapper and lets the trade code validate handles. **Callback form is now ONE convention project-wide: bare unbound script functions** (`tradeup_inventory_event`, `tcc_steam_inventory_release_result`, `tcc_steam_inventory_ignore_result`), matching ASH1 section 1.12 (same callable re-registered hits the refcount branch, ExtensionCore_api.gml:271-290; no per-call `method()` allocation). `method(undefined, fn)` is the equivalent fallback. Neither form is runtime-verified (unresolved U2).
- **G3. Steam-down fallback of `tcc_steam_inventory_result_get_items`.** The old md returned `[]`, which would publish an "ok" empty inventory and zero `global.itemdef`. It now returns `undefined` when Steam is unavailable or the status is not Ok, so a failure stays a failure (consistent with the Ok-status rule). The only call site (TRADE:111) is reached only after a successful Steam callback, so this never changes normal behaviour.

---------------------------------------------------------------------------------------------------

## 2. Where the old identifiers are used (exhaustive grep of scripts/, objects/, rooms/ `.gml`, excluding `scripts/Steamworks_API`)

Also grepped: `steam_inventory_result_status_*`, `inventory_full_update`, `steam_inventory_item_*`, `inventory_result_ready`, `inventory_request_prices`, `run_callbacks`. Result: the status constants are never used; `inventory_full_update` appears only in the selfcheck fixture (`TRADE:328`); the project never calls `steam_api_run_callbacks` directly (it is reached only through `tcc_steam_update()`, section 3).

### 2.1 Wrapper definitions (all in `SAFE`, all guard `platform_steam() && steam_initialised()`)

| tcc_ wrapper | SAFE lines | wraps | Steam-less fallback today |
|---|---|---|---|
| `tcc_steam_inventory_exchange_items(_a0,_a1)` | 106-109 | `steam_inventory_exchange_items` | `false` |
| `tcc_steam_inventory_get_all_items()` | 110-113 | `steam_inventory_get_all_items` | `-1` |
| `tcc_steam_inventory_get_item_price(_a0)` | 114-117 | `steam_inventory_get_item_price` | `undefined` |
| `tcc_steam_inventory_request_prices()` | 118-121 | `steam_inventory_request_prices` | `false` |
| `tcc_steam_inventory_result_destroy(_a0)` | 122-125 | `steam_inventory_result_destroy` | `false` |
| `tcc_steam_inventory_result_get_item_property(_a0,_a1,_a2)` | 126-129 | `steam_inventory_result_get_item_property` | `""` |
| `tcc_steam_inventory_result_get_items(_a0)` | 130-133 | `steam_inventory_result_get_items` | `[]` |
| `tcc_steam_inventory_result_get_status(_a0)` | 134-137 | `steam_inventory_result_get_status` | `false` |
| `tcc_steam_inventory_result_get_unix_timestamp(_a0)` | 138-141 | `steam_inventory_result_get_unix_timestamp` | `false` |
| `tcc_steam_inventory_trigger_item_drop(_a0)` | 142-145 | `steam_inventory_trigger_item_drop` | `false` |

### 2.2 Real callers

| wrapper | caller (file:line) | what it does |
|---|---|---|
| `get_all_items` | `TRADE:83` in `tradeup_request_inventory()` | stores handle in `global.tradeup_state.inventory_handle`; `-1`/invalid => "Inventory unavailable" |
| `result_get_items` | `TRADE:111` in `tradeup_inventory_event()` | feeds `tradeup_inventory_snapshot()` |
| `result_destroy` | `TRADE:100, 112, 132, 144, 145` | after trade result; after inventory result; on 30 s inventory timeout; in `tradeup_inventory_cleanup()` x2 |
| `exchange_items` | `TRADE:170` in `scr_execute_trade_up()` | `tcc_steam_inventory_exchange_items(_plan.create,_plan.destroy)`; result stored in `trade_handle`; doc comment at `TRADE:165` |
| `trigger_item_drop` | `objects/o_title/Create_0.gml:4` | `tcc_steam_inventory_trigger_item_drop(99)` fire-and-forget, handle never destroyed (leaks in 2.x) |
| `request_prices` | `objects/o_title/Create_0.gml:5` | `tcc_steam_inventory_request_prices(); //Test` (dead work: only consumer is a no-op) |
| `get_item_price` | `objects/o_title/Other_69.gml:12` | **commented out** |
| `get_item_property`, `get_status`, `get_unix_timestamp` | none | wrapper only |

### 2.3 Who creates / owns the controller `o_getallinventoryitems` (persistent, `o_getallinventoryitems.yy:18`)

| creator | where | what happens |
|---|---|---|
| `o_loading` | `objects/o_loading/Create_0.gml:17` (`instance_create`) | normally the FIRST instance => becomes the owner (`owns_inventory = true`) |
| room placement | `rooms/r_skinmenu/r_skinmenu.yy:161` (`inst_51393B35`, layer "Items", x=140, y=0) | every visit to r_skinmenu creates a **non-owner duplicate** while the persistent owner exists: `Create_0.gml:4-8` calls `tradeup_request_inventory()` then `instance_destroy()` (its CleanUp runs with `owns_inventory == false`) |
| `o_tradeup_menu` | `objects/o_tradeup_menu/Create_0.gml:3-4` | `instance_create` if none exists, else `tradeup_request_inventory()`; `Step_0.gml:21` (key R) also calls `tradeup_request_inventory()` |

`Create_0.gml` today (10 lines): 1 `owns_inventory = false`; 2 Steam guard (destroys + exits); 3 `tradeup_defaults()`; 4-8 duplicate branch; 9 `owns_inventory = true`; 10 `tradeup_request_inventory()`. `CleanUp_0.gml:1` = `if (owns_inventory) tradeup_inventory_cleanup();`. `Step_0.gml:2` = `if (owns_inventory) tradeup_inventory_tick();` (after `timing_instance_step()` gate, line 1).

### 2.4 Async-Steam (Other_69, eventNum 69 / eventType 7) handlers touching inventory

| handler | line | reads today | in 3.0 |
|---|---|---|---|
| `objects/o_getallinventoryitems/Other_69.gml` | 1 | `if (owns_inventory && tcc_steam_initialised()) tradeup_inventory_event(async_load)` -> ds_map keys `event_type=="inventory_result_ready"`, `handle`, `success` (TRADE:72-75, 99, 110) | event never fires. Replace with global callback + per-call callback. Entry: `o_getallinventoryitems.yy:8` |
| `objects/o_title/Other_69.gml` | 1-15 | `async_load[? "event_type"] == "inventory_request_prices"`, `async_load[? "success"]`, (commented) `async_load[? "currency"]`; **body is a no-op** | Delete. Entry: `o_title.yy:7` |
| `objects/o_tradeup_menu/Other_69.gml` | 1-2 | comments only | Delete. Entry: `o_tradeup_menu.yy:8` |

If an `Other_69.gml` is deleted, its `eventList` entry must be removed too, otherwise the IDE recreates an empty event (an empty leftover is harmless but inconsistent). `o_title/Other_69.gml` line 1 and the comment on line 2 ("lobby joins handled by o_networkmanager") hold no other domain's logic (CORE:143, ASH1 section 2.3 also say delete).

---------------------------------------------------------------------------------------------------

## 3. Prerequisites that live OUTSIDE this domain (owned by the core domain)

1. **The callback pump already exists and only needs remapping.** `tcc_steam_update()` (SAFE:310-312, `steam_update()` today) is called every simulation tick by `objects/o_fullscreensystem/Step_0.gml:4` (`if (platform_steam()) tcc_steam_update();`, after `if (!timing_instance_step()) exit;` on line 1). CORE:166-167 remaps it to `steam_api_run_callbacks()` guarded by `steam_api_is_initialized()`. Without that remap NO inventory callback fires: inventory never loads (30 s timeout message) and `trade_handle` has **no timeout/unlock** (TRADE:136-138 only changes the message). Do not add a second pump. Known weakness: the pump disappears when `o_endingreq/Create_0.gml:3` destroys `o_fullscreensystem` (CORE:218), and is skipped on frames where `timing_instance_step()` returns false. Native `steam_api_run_callbacks()` is `STEAM_GUARD()` + `SteamAPI_RunCallbacks()` (`gm_steam_api.cpp:300-304`), safe when Steam is down.
2. **Guard rename:** `steam_initialised()` -> `steam_api_is_initialized()` (YY:22; native returns bool, declared `@returns {Real}`; truthy test is fine). CORE:74 does the mechanical replace in SAFE. The extension auto-initialises before the first frame, so `tcc_steam_init()` is not needed for inventory.
3. **Callback dispatch mechanics** (`scripts/ExtensionCore_api/ExtensionCore_api.gml:271-290, 340-420`): the native side queues invocations; a `time_source_global` ticker (1 frame) drains them; each callback runs as `with (_dummy_context) method_call(_ref[0], _args)`. The callable is stored in a global ds_map keyed by `int64(ptr(_callable))` and refcounted, released when the native `GMFunction` is dropped. A callback written as a function literal in an instance event is bound to that instance; use unbound script functions (this map's convention) and keep callbacks defensive (`is_struct`, `undefined` checks); an uncaught error inside a callback is raised from the time source (ASH1 section 1.4).

---------------------------------------------------------------------------------------------------

## 4. Behaviour WITHOUT Steam (the startup crash from `docs/release/STATUS.md:27`)

STATUS.md:27 records `EXC_BAD_ACCESS` in 2.x `steam_inventory_get_all_items` when Steam was not running (reached via `o_getallinventoryitems` Create <- `o_loading` Create).

3.0 native code (verified in `NATIVE`):

- `steam_inventory_iface()` (NATIVE:22-34) returns `nullptr` and sets last-error unless `steam_api_is_initialized()`; it also null-checks `SteamInventory()`.
- Every inventory call starts with `STEAM_GUARD_RET(...)` (`GMSteamworks.h:20-24, 59-67`) and then `steam_inventory_iface()`:
  - `get_all_items` (NATIVE:295-306) -> `-1` (`k_SteamInventoryResultInvalid == -1`)
  - `exchange_items` (231-267), `trigger_item_drop` (749-763), ... -> `-1`, **no callback is registered**
  - `request_prices` (1085-1101) -> returns void, **callback never fires** (see decision 12 for the other silent paths)
  - `get_result_items` -> `undefined`; `get_result_status` -> `SteamApiResult.Fail`; `get_result_timestamp` -> `0`; `get_result_item_property` -> `undefined`; `get_item_price` -> `undefined`
  - `destroy_result` (210-229) -> no-op for handles `-1`/`0`; when Steam is down it only tombstones the pending one-shot and returns (never touches `SteamInventory()`)
  - `set/clear_callback_*` have no guard (just store/clear a pointer); `steam_api_shutdown` clears them all (`gm_steam_api.cpp:113-155`).
- Wrapped functions (`exchange_items`, `trigger_item_drop`, `request_prices`, `get_result_items`, ...) additionally start with `if (!__Steamworks_is_available()) return;` where that is `extension_exists("Steamworks")` (API.gml:24764-24768) -> `undefined` when the extension is not part of the build.
- **Native-direct functions with NO GML wrapper and NO `extension_exists` check:** `steam_inventory_get_all_items` (YY:474, API.gml:21217), `steam_inventory_destroy_result` (YY:471, API.gml:21135), `steam_inventory_get_result_timestamp` (YY:477, API.gml:21268), `steam_inventory_clear_callback_result_ready` (YY:504, API.gml:21968). `YY:14` sets `ConfigValues {Apple:{copyToTargets:"0"}, Mobile:{copyToTargets:"0"}}`, i.e. iOS/Android/MacAppStore ship no extension binary, so these calls may only run behind `platform_steam()` (`scripts/scr_platform/scr_platform.gml:17`).

Conclusion: with the 3.0 extension, calling inventory functions on a desktop Steam build when Steam is not running is safe (invalid handle `-1` / `undefined` / no callback). The `steam_api_is_initialized()` guard stays mandatory anyway to avoid pointless native calls and to keep the `-1`/failure fallbacks. Binaries were not inspected (unresolved U5).

---------------------------------------------------------------------------------------------------

## 5. Per-function migration

| old (2.x) | new (3.0) exact call | result delivery | evidence |
|---|---|---|---|
| `steam_inventory_get_all_items()` | `steam_inventory_get_all_items()` (SAME name, native-direct) **+** global `steam_inventory_set_callback_result_ready(_callback)` | callback (global, single slot) | YY:474; NATIVE:295-306, 943, 970-1000, 1028-1038; API.gml:21949; DOCS3:170-182, 642-658 |
| `steam_inventory_exchange_items(create_arr, destroy_arr)` | `steam_inventory_exchange_items(_generate_items, _destroy_items, _callback)` | callback (per call) | API.gml:21144; NATIVE:231-267; DOCS3:119-150 |
| `steam_inventory_trigger_item_drop(item_def)` | `steam_inventory_trigger_item_drop(_item_def_id, _callback)` | callback (per call) | API.gml:21824; NATIVE:749-763; DOCS3:546-577 |
| `steam_inventory_request_prices()` | `steam_inventory_request_prices(_callback)` | callback (not guaranteed) | API.gml:21516; NATIVE:1085-1101; ASYNC:11, 31-57; DOCS3:373-390 |
| `steam_inventory_get_item_price(item)` | `steam_inventory_get_item_price(_item_def_id)` | sync (struct or undefined) | API.gml:21925; NATIVE:883-901; DOCS3:631-640 |
| `steam_inventory_result_get_status(h)` | `steam_inventory_get_result_status(_result_handle)` | sync (`SteamApiResult`) | API.gml:21254; NATIVE:342-351; DOCS3:195-206 |
| `steam_inventory_result_get_items(h)` | `steam_inventory_get_result_items(_result_handle)` | sync (array or undefined) | API.gml:21224; NATIVE:308-340; DOCS3:184-193 |
| `steam_inventory_result_get_item_property(h,i,name)` | `steam_inventory_get_result_item_property(_result_handle, _item_index, _property_name)` | sync (string or undefined) | API.gml:21443; NATIVE:546-589; DOCS3:333-345 |
| `steam_inventory_result_get_unix_timestamp(h)` | `steam_inventory_get_result_timestamp(_result_handle)` | sync (u32 real, 0 on failure) | YY:477; NATIVE:353-362; DOCS3:208-219 |
| `steam_inventory_result_destroy(h)` | `steam_inventory_destroy_result(_result_handle)` | sync, returns meaningless Real 0 | YY:471; GLUE:5249-5253; NATIVE:210-229; DOCS3:109-117 |
| Async event `inventory_result_ready` | callback arg `Struct.SteamInventoryResultReady {result_handle, result}` | event removed | API.gml:3515-3529; DOCS3:799-808 |
| Async event `inventory_request_prices` | callback arg `Struct.SteamInventoryRequestPricesResult {result, currency}` | event removed | API.gml:3580-3593; DOCS3:844-855 |
| Async event `inventory_full_update` | optional `steam_inventory_set_callback_full_update(_callback)` -> `SteamInventoryFullUpdate {result_handle}` | event removed (unused) | API.gml:21974, 3531-3544 |
| `steam_inventory_result_status_*`, `steam_inventory_result_invalid` | `SteamApiResult.*` enum; `STEAM_INVENTORY_RESULT_INVALID` | enum / macro | API.gml:314-.., 147 |
| ResultItem / InventoryItemCreationData / InventoryItemConsumptionData | `SteamInventoryItemDetails` / `SteamInventoryItemDefQuantity` / `SteamInventoryItemInstanceQuantity` | struct shapes | API.gml:3416-3481 |

### 5.0 Struct / enum shape changes (exact field names)

| 2.x | 3.0 (constructor, API.gml) | notes |
|---|---|---|
| ResultItem `{item_id (Real), item_def (Real), quantity (Int64), flags (Int64)}` | `SteamInventoryItemDetails {item_instance_id, item_def_id, quantity, flags}` (API.gml:3465-3481; decode 10231-10260: u64, u32, u32, u64) | `item_id`->`item_instance_id`, `item_def`->`item_def_id` |
| InventoryItemCreationData `{item_def, quantity}` | `SteamInventoryItemDefQuantity {itemdef_id, quantity}` (3416-3430, `__uid = 837655736`) | **`itemdef_id`** (no underscore before `def`), differs from `item_def_id` above |
| InventoryItemConsumptionData `{item_id, quantity}` | `SteamInventoryItemInstanceQuantity {item_instance_id, quantity}` (3432-3446, `__uid = 37410476`) | encode writes `item_instance_id` as `buffer_u64` (API.gml:10094-10115) |
| flag bits (hard-coded 768 in TRADE:41) | `enum SteamInventoryItemFlags {NoTrade = 1, Removed = 256, Consumed = 512}` (API.gml:1475-1480) | `(flags & 768)` is still exactly Removed\|Consumed |
| `async_load[? "success"]` (bool) | `_result.result == SteamApiResult.Ok` | `SteamApiResult.Ok = 1` (API.gml:317), `Fail = 2` is truthy: never test `_result.result` for truthiness |
| `async_load[? "handle"]` | `_result.result_handle` | |
| `async_load[? "result"]` | `_result.result` | same name, now `SteamApiResult` |
| `steam_inventory_result_status_ok/fail/invalid_param/service_unavailable/pending/limit_exceeded/expired` = 1/2/8/20/22/25/27 (OLDYY) | `SteamApiResult.Ok/Fail/InvalidParam/ServiceUnavailable/Pending/LimitExceeded/Expired` = 1/2/8/20/22/25/27 | numerically identical; status `invalid = -1` has no enum member. The handle sentinel `steam_inventory_result_invalid` (-1, OLDYY:94) maps to `STEAM_INVENTORY_RESULT_INVALID` (API.gml:147). Project uses none of these. |

### 5.1 `steam_inventory_get_all_items`

- **Old (DOCS2):** `steam_inventory_get_all_items()` -> Real handle. Async event `inventory_result_ready` {`event_type`, `success`, `result`, `handle`}; optional `inventory_full_update`. Must `steam_inventory_result_destroy(handle)`.
- **New:** `steam_inventory_get_all_items()` - YY:474, 0 args, returns Real (int32 handle). API.gml:21217 has only "Skipping function ... (no wrapper is required)", so there is no `extension_exists` check. Returns `-1` if Steam is not initialised / `SteamInventory()` is NULL / `GetAllItems` refuses (NATIVE:295-306). It returns the raw SDK handle with no further validation.
- **No callback parameter.** Completion is signalled through:
  - `steam_inventory_set_callback_result_ready(_callback)` (API.gml:21949; DOCS3:642-658): global, **single slot** (`g_cb_result_ready`, NATIVE:943; the setter overwrites, :1028-1032), fires for every result handle that has no per-call one-shot. Callback arg: `SteamInventoryResultReady {result_handle, result}`.
  - or polling `steam_inventory_get_result_status(handle)` until it is not `SteamApiResult.Pending` (22).
  - `steam_inventory_clear_callback_result_ready()` (native, YY:504) nulls the slot.
  - (Optional) `steam_inventory_set_callback_full_update(_callback)` replaces `inventory_full_update`; project does not use it.
- **Slot ownership rule (decision 1):**
  1. Register ONCE, in `objects/o_getallinventoryitems/Create_0.gml` between line 9 (`owns_inventory = true;`) and line 10 (`tradeup_request_inventory();`), via the new wrapper `tcc_steam_inventory_set_callback_result_ready(tradeup_inventory_event)`. The Steam-less early exit (line 2) and the duplicate branch (lines 4-8) never register.
  2. Clear ONLY inside the existing `if (owns_inventory)` guard of `CleanUp_0.gml` (a guarded line next to `tradeup_inventory_cleanup()`, so callback lifecycle stays out of `scr_tradeup`), via `tcc_steam_inventory_clear_callback_result_ready()`. An unguarded clear, or a clear from `tradeup_inventory_cleanup()` if anything else ever calls it, would let the r_skinmenu duplicate (r_skinmenu.yy:161) wipe the owner's callback.
  3. Nobody else in the project may call `steam_inventory_set_callback_result_ready` / `..._clear_...` (single slot; today no code does).
- **Gotchas:**
  - Without a registered global callback the result is silently dropped: inventory never loads (30 s timeout).
  - A destroyed handle whose result arrives late still reaches the global callback (NATIVE:970-1000: `inv_rr_take_once` finds nothing for get_all_items handles, so it falls through). The handler must ignore unknown handles - `tradeup_result_matches` already does by comparing with `global.tradeup_state.inventory_handle`; the 30 s timeout path (`TRADE:131-135`) sets it to `-1`, so the stale callback is ignored.
  - Steam may rate-limit/cache `GetAllItems` (DOCS3:170-182 note); the callback still fires per handle.
  - Handle `0`: `destroy_result(0)` and the per-call one-shot layer ignore it (NATIVE:49-52), but `get_all_items` itself would return it raw. `tradeup_handle_valid(0)` is true today (`TRADE:20-22`, range 0..2147483647); lower the bound to 1 and normalise `<1` to `-1` in the wrapper as a defensive project choice (decision 4+8).
  - Steam-less: returns `-1`, no crash (section 4). `platform_steam()` is the ONLY protection on builds where the extension is absent.
  - Callback must be an unbound script function (section 3.3), not a literal bound to a destroyable instance.
  - The pump is `tcc_steam_update()` at `o_fullscreensystem/Step_0.gml:4` (section 3.1); it must be remapped by the core domain or nothing fires.

### 5.2 `steam_inventory_exchange_items`

- **Old:** `steam_inventory_exchange_items(create_arr, destroy_arr)`, create = `[{item_def, quantity}]` (size 1, quantity 1), destroy = `[{item_id, quantity}]` -> Real handle; event `inventory_result_ready`.
- **New:** `steam_inventory_exchange_items(_generate_items, _destroy_items, _callback)` (API.gml:21144-21182).
  - `_generate_items`: `Array[Struct.SteamInventoryItemDefQuantity]`; each element is checked via `.__uid != 837655736` (API.gml:21159). Fields `itemdef_id` (u32), `quantity` (u32).
  - `_destroy_items`: `Array[Struct.SteamInventoryItemInstanceQuantity]`, `.__uid != 37410476` (API.gml:21169). Fields `item_instance_id` (u64; an `int64` is accepted by `is_numeric` and written with `buffer_u64`), `quantity` (u32).
  - A plain struct has no `__uid` member (it is a `static` of the constructors), so the read itself faults or reaches `show_error(..., true)`: fatal either way.
  - `_callback`: `is_callable` required, otherwise fatal `show_error`.
  - Returns Real handle; `-1` when Steam down, either array empty (`genN == 0 || dstN == 0`, NATIVE:257), or the SDK call fails; `undefined` when the extension is absent.
  - Callback arg: `SteamInventoryResultReady`; one-shot (registered after the SDK call, NATIVE:259-266), called once when the result leaves Pending; success == `result == SteamApiResult.Ok`. Never goes to the global slot.
- **Gotchas:**
  - `tradeup_plan` (TRADE:63, 69) builds plain literals `{item_def, quantity}` / `{item_id, quantity}`. Convert **inside `tcc_steam_inventory_exchange_items`** so `tradeup_plan` and its selfcheck assertions (TRADE:298-305, 319-321) keep their shape.
  - Spelling trap: exchange input uses `itemdef_id`, result items use `item_def_id`.
  - `item_instance_id` must stay int64 (`int64(_entry.item_id)` already used at TRADE:45, 63); never round through a double (ids > 2^53; selfcheck uses 9007199254741003).
  - Wrapper fallback `false` (SAFE:108) is a bad "handle": make it `-1`; normalise `<1` to `-1`.
  - The result handle must still be destroyed (done in the callback via `tradeup_inventory_event`, TRADE:100).
  - `tradeup_inventory_cleanup()` destroying `trade_handle` tombstones the pending one-shot (NATIVE:215-222), so the exchange callback is suppressed (not rerouted): only at shutdown, never mid-trade.
  - Pass the unbound script function: `tcc_steam_inventory_exchange_items(_plan.create, _plan.destroy, tradeup_inventory_event)`; the handler matches by handle, so the same function serves the exchange and global callbacks.
  - Stale doc comment `TRADE:165` (`/// Returns the async handle from steam_inventory_exchange_items`): replace with `/// Returns the exchange result handle (-1 on failure); completion arrives through the per-call callback with a SteamInventoryResultReady struct.` (no call-like `name(` text; check_port.py:79 regex).

### 5.3 `steam_inventory_trigger_item_drop`

- **Old:** `steam_inventory_trigger_item_drop(item_def)`; documented Bool, behaves as a handle; event `inventory_result_ready`. `o_title/Create_0.gml:4` fires `(99)` and ignores everything, leaking the handle.
- **New:** `steam_inventory_trigger_item_drop(_item_def_id, _callback)` (API.gml:21824-21846), `_callback` mandatory (fatal if not callable). Returns Real handle (`-1` on failure/Steam down, no callback registered). Callback arg `SteamInventoryResultReady`; one-shot.
- **Gotchas:** an omitted callback is fatal, so the wrapper supplies one: default `tcc_steam_inventory_release_result`, a script function that destroys `_result.result_handle` (3.0 requires destroying every result, DOCS3:546-577). It must run unconditionally (no `instance_exists` gate, no success gate), exactly as ASH1 section 2.3 requires. `o_title` is non-persistent (`o_title.yy:17`), so the callback must be unbound. Steam rate-limits drops (minute granularity). Wrapper signature `tcc_steam_inventory_trigger_item_drop(_item_def, _callback = undefined)` keeps `o_title/Create_0.gml:4` unchanged. Steam-less: returns `-1`, callback never fires.

### 5.4 `steam_inventory_request_prices`

- **Old:** `steam_inventory_request_prices()` -> Bool; event `inventory_request_prices` {`event_type`, `success`, `result`, `currency`}.
- **New:** `steam_inventory_request_prices(_callback)` (API.gml:21516-21533), returns nothing useful. Callback arg `Struct.SteamInventoryRequestPricesResult {result: SteamApiResult, currency: String}` (API.gml:3580-3593, decode 10593-10615).
- **Gotchas:** callback mandatory. **The callback is not guaranteed to fire**: Steam down (STEAM_GUARD), `k_uAPICallInvalid` (NATIVE:1094-1097), or IO failure (`ReportIoFailure = false`, ASYNC:11, 33-44). Never gate state on it. The only consumer is a no-op, so the wrapper defaults the callback to `tcc_steam_inventory_ignore_result` and `o_title/Other_69.gml` + `o_title.yy:7` are deleted. The request itself is dead work (ASH1 section 2.3 offers removing it from `o_title/Create_0.gml:5`); this map keeps it so behaviour is unchanged (optional cleanup).

### 5.5 `steam_inventory_get_item_price`

- **Old:** `steam_inventory_get_item_price(item)` -> `@returns {Int64}` (DOCS2, OLDYY:438); semantics (current vs base) are not documented and the 2.x source is not available. Only use: commented-out `o_title/Other_69.gml:12`.
- **New:** `steam_inventory_get_item_price(_item_def_id)` (API.gml:21925-21942) -> `Struct.SteamInventoryItemPrice {current_price, base_price}` (u64 -> int64, API.gml:3499-3513) or `undefined` (Steam down, price unknown, or `request_prices` not completed). Only valid after a successful `request_prices` callback (DOCS3:631-640).
- **ASSUMPTION:** the wrapper returns `current_price` as the numeric "price". That is a guess about 2.x behaviour (no source); no live caller, so low risk. Alternative: return the struct as-is and change the contract.

### 5.6 `steam_inventory_result_get_status`

- **New:** `steam_inventory_get_result_status(_result_handle)` (API.gml:21254-21266) -> `Enum.SteamApiResult` (read as `buffer_u64`). Steam down -> `SteamApiResult.Fail` (NATIVE:342-351). Numerically same as old macros except `-1`. No project callers; wrapper fallback `false` (SAFE:136) becomes `SteamApiResult.Fail`.

### 5.7 `steam_inventory_result_get_items`

- **Old:** `Array<ResultItem>` `{item_id, item_def, quantity, flags}`.
- **New:** `steam_inventory_get_result_items(_result_handle)` (API.gml:21224-21250) -> `Array[Struct.SteamInventoryItemDetails]` **or `undefined`**: native returns nullopt when `count == 0`, `GetResultItems` fails, handle invalid or Steam down (NATIVE:308-340); wrapper also returns `undefined` when the extension is absent.
- **Gotchas (silent breakers):**
  1. Empty inventory => `undefined`. `tradeup_inventory_snapshot` (TRADE:27) returns `ok:false` for non-arrays => every player with zero items would see "Inventory unavailable". Map `undefined` to `[]` **only when `steam_inventory_get_result_status(h) == SteamApiResult.Ok`**.
  2. Field renames break `variable_struct_exists(_entry,"item_id")` / `"item_def"` (TRADE:31-32). Convert to the old project shape `{item_id, item_def, quantity, flags}` inside the wrapper so `tradeup_inventory_snapshot`, `tradeup_plan` and the selfcheck fixtures (TRADE:289-293) stay valid.
  3. Steam unavailable / extension absent => the wrapper returns `undefined` (not `[]`, gap G3) so a failure never publishes an empty "ok" inventory.
  4. Types: `item_instance_id` = `buffer_read(buffer_u64)` (int64 in GML; ids >= 2^63 would wrap negative and fail `tradeup_item_id_valid`; verify at runtime, U1), `item_def_id`/`quantity` = u32 reals, `flags` = u64. `tradeup_integer` accepts real or int64.
  5. `flags & 768` semantics unchanged (Removed=256, Consumed=512).

### 5.8 `steam_inventory_result_get_item_property`

- **New:** `steam_inventory_get_result_item_property(_result_handle, _item_index, _property_name)` (API.gml:21443-21480) -> String or `undefined` (property missing/empty name/handle invalid/Steam down; NATIVE:546-589). Old returned a String; keep the wrapper's `""` default. `_item_index` is u32, 0-based. No callers.

### 5.9 `steam_inventory_result_get_unix_timestamp`

- **New:** `steam_inventory_get_result_timestamp(_result_handle)` - native-direct (YY:477; API.gml:21268). Returns u32 Real, `0` on failure (NATIVE:353-362). No callers; wrapper fallback `false` -> `0`. Keep the `platform_steam()` guard.

### 5.10 `steam_inventory_result_destroy`

- **New:** `steam_inventory_destroy_result(_result_handle)` - native-direct (YY:471; API.gml:21135). C++ is `void` (NATIVE:210) but the GML-visible function is `@returns {Real}` and the glue returns a meaningless `0` (GLUE:5249-5253): falsy, equal to the old failure value. Never forward the raw value; the wrapper returns an explicit `true` when a destroy was issued, `false` when guarded or the handle is `<1`.
- **Gotchas:** no-op for `-1`/`0`; tombstones a pending per-call one-shot so its callback is suppressed and NOT rerouted to the global callback (NATIVE:215-222); for get_all_items handles (no one-shot) a late result still reaches the global callback and the handler must ignore it. Calling destroy inside the handle's own callback is fine (entry already erased by `inv_rr_take_once`). Also needed for `trigger_item_drop` results, which 2.x leaked.

---------------------------------------------------------------------------------------------------

## 6. Recommended wrapper replacements (`SAFE:106-145`, plus two new set/clear wrappers)

Raw `steam_inventory_*(` calls must stay in `SAFE` (check_port.py:79 regex is exempt only for `scr_steam_safe` and `scr_platform_services`; `new SteamInventoryItemDefQuantity()` does not match it, but keep it in `SAFE` anyway). Callbacks are bare unbound script functions (gap G2). `tradeup_inventory_event` lives in `scr_tradeup`; scripts are global, so `SAFE` need not reference it.

```gml
function tcc_steam_inventory_get_all_items() {
    if (platform_steam() && steam_api_is_initialized()) {
        var _handle = steam_inventory_get_all_items();
        return (is_numeric(_handle) && _handle >= 1) ? _handle : -1;
    }
    return -1;
}
/// NEW. Single global slot: only the owning o_getallinventoryitems may call these two.
function tcc_steam_inventory_set_callback_result_ready(_callback) {
    if (platform_steam() && steam_api_is_initialized()) steam_inventory_set_callback_result_ready(_callback);
}
function tcc_steam_inventory_clear_callback_result_ready() {
    if (platform_steam() && steam_api_is_initialized()) steam_inventory_clear_callback_result_ready();
}
/// _create = [{item_def, quantity}], _destroy = [{item_id, quantity}] (the shape tradeup_plan builds); _callback receives SteamInventoryResultReady.
function tcc_steam_inventory_exchange_items(_create, _destroy, _callback) {
    if (!(platform_steam() && steam_api_is_initialized())) return -1;
    var _gen = [], _del = [];
    for (var _i = 0; _i < array_length(_create); ++_i) {
        var _g = new SteamInventoryItemDefQuantity();
        _g.itemdef_id = _create[_i].item_def;
        _g.quantity = _create[_i].quantity;
        array_push(_gen, _g);
    }
    for (var _j = 0; _j < array_length(_destroy); ++_j) {
        var _d = new SteamInventoryItemInstanceQuantity();
        _d.item_instance_id = _destroy[_j].item_id;     // keep int64
        _d.quantity = _destroy[_j].quantity;
        array_push(_del, _d);
    }
    var _handle = steam_inventory_exchange_items(_gen, _del, _callback);
    return (is_numeric(_handle) && _handle >= 1) ? _handle : -1;
}
function tcc_steam_inventory_result_destroy(_handle) {
    if (!(platform_steam() && steam_api_is_initialized())) return false;
    if (!is_numeric(_handle) || _handle < 1) return false;
    steam_inventory_destroy_result(_handle);      // raw return is a meaningless 0; do not forward it
    return true;
}
/// Returns the OLD project shape [{item_id, item_def, quantity, flags}] so scr_tradeup.gml and its selfcheck stay unchanged.
/// undefined => failure (snapshot not ok): Steam unavailable, or status not Ok. Ok + no items => [] (genuinely empty inventory).
function tcc_steam_inventory_result_get_items(_handle) {
    if (!(platform_steam() && steam_api_is_initialized())) return undefined;
    var _src = steam_inventory_get_result_items(_handle);
    if (!is_array(_src)) return (steam_inventory_get_result_status(_handle) == SteamApiResult.Ok) ? [] : undefined;
    var _out = array_create(array_length(_src));
    for (var _i = 0; _i < array_length(_src); ++_i) {
        var _s = _src[_i];
        _out[_i] = {item_id:_s.item_instance_id, item_def:_s.item_def_id, quantity:_s.quantity, flags:_s.flags};
    }
    return _out;
}
function tcc_steam_inventory_result_get_status(_handle) {
    if (platform_steam() && steam_api_is_initialized()) return steam_inventory_get_result_status(_handle);
    return SteamApiResult.Fail;
}
function tcc_steam_inventory_result_get_unix_timestamp(_handle) {
    if (platform_steam() && steam_api_is_initialized()) return steam_inventory_get_result_timestamp(_handle);
    return 0;
}
function tcc_steam_inventory_result_get_item_property(_handle, _index, _name) {
    if (platform_steam() && steam_api_is_initialized()) {
        var _v = steam_inventory_get_result_item_property(_handle, _index, _name);
        return is_undefined(_v) ? "" : _v;
    }
    return "";
}
/// ASSUMPTION (no 2.x source): "price" == current_price. No live caller.
function tcc_steam_inventory_get_item_price(_item_def) {
    if (platform_steam() && steam_api_is_initialized()) {
        var _p = steam_inventory_get_item_price(_item_def);
        return is_struct(_p) ? _p.current_price : undefined;
    }
    return undefined;
}
/// Default callbacks (bare script functions). The release callback must run unconditionally.
function tcc_steam_inventory_release_result(_result) {
    if (is_struct(_result) && variable_struct_exists(_result, "result_handle")) tcc_steam_inventory_result_destroy(_result.result_handle);
}
function tcc_steam_inventory_ignore_result(_result) {}
function tcc_steam_inventory_trigger_item_drop(_item_def, _callback = undefined) {
    if (!(platform_steam() && steam_api_is_initialized())) return -1;
    if (!is_callable(_callback)) _callback = tcc_steam_inventory_release_result;
    var _handle = steam_inventory_trigger_item_drop(_item_def, _callback);
    return (is_numeric(_handle) && _handle >= 1) ? _handle : -1;
}
function tcc_steam_inventory_request_prices(_callback = undefined) {
    if (!(platform_steam() && steam_api_is_initialized())) return false;
    if (!is_callable(_callback)) _callback = tcc_steam_inventory_ignore_result;
    steam_inventory_request_prices(_callback);     // callback may never fire (Steam down / dispatch / IO failure)
    return true;
}
```

With these defaults `objects/o_title/Create_0.gml:4-5` (`tcc_steam_inventory_trigger_item_drop(99)` and `tcc_steam_inventory_request_prices()`) compile and behave unchanged with no edit.

## 7. Required edits to `scr_tradeup.gml` and the controller objects

1. `tradeup_handle_valid` (TRADE:20-22): lower bound `0` -> `1` (`tradeup_integer(_handle, 1, 2147483647)`), defensive (decision 4+8). Optionally add `!tradeup_handle_valid(0)` to the selfcheck assertion at TRADE:331.
2. `tradeup_result_matches(_event,_handle)` (TRADE:72-76): replace the ds_map logic (`ds_exists` on a struct is invalid, so the inventory would never load and trades never complete). New logic requires BOTH members so a `SteamInventoryFullUpdate`-shaped struct cannot match (gap G1):
   ```gml
   function tradeup_result_matches(_result,_handle) {
       return tradeup_handle_valid(_handle) && is_struct(_result)
           && variable_struct_exists(_result,"result_handle") && variable_struct_exists(_result,"result")
           && _result.result_handle == _handle;
   }
   function tradeup_result_ok(_result) {
       return is_struct(_result) && variable_struct_exists(_result,"result") && _result.result == SteamApiResult.Ok;
   }
   ```
3. `tradeup_inventory_event(_event)` (TRADE:95-126): rename param to `_result`; replace both `ds_map_exists(_event,"success") && _event[? "success"]` (TRADE:99, 110) with `tradeup_result_ok(_result)`. Never `if (_result.result)` (Fail=2 is truthy). Rest of the logic stays.
4. `scr_execute_trade_up` (TRADE:170): `var _handle = tcc_steam_inventory_exchange_items(_plan.create,_plan.destroy,tradeup_inventory_event);`. Also update the doc comment at TRADE:165 (section 5.2).
5. `objects/o_getallinventoryitems/Create_0.gml`: insert after line 9 (`owns_inventory = true;`), before line 10 (`tradeup_request_inventory();`): `tcc_steam_inventory_set_callback_result_ready(tradeup_inventory_event);`.
6. `objects/o_getallinventoryitems/CleanUp_0.gml`: keep it guarded, e.g. `if (owns_inventory) { tradeup_inventory_cleanup(); tcc_steam_inventory_clear_callback_result_ready(); }`. Never clear outside the `owns_inventory` guard.
7. Delete `objects/o_getallinventoryitems/Other_69.gml` + `o_getallinventoryitems.yy:8`; `objects/o_title/Other_69.gml` + `o_title.yy:7`; `objects/o_tradeup_menu/Other_69.gml` + `o_tradeup_menu.yy:8`.
8. `scr_tradeup_selfcheck` (TRADE:324-330) replace the ds_map fixture:
   ```gml
   var _event = {result_handle:5, result:SteamApiResult.Ok};
   scr_port_assert(tradeup_result_matches(_event,5) && !tradeup_result_matches(_event,6)
       && !tradeup_result_matches(_event,-1),"only matching live inventory result is accepted");
   scr_port_assert(!tradeup_result_matches({result_handle:5},5) && !tradeup_result_matches({},5)
       && !tradeup_result_matches(undefined,5),"unrelated inventory callback payload cannot complete a trade");
   scr_port_assert(tradeup_result_ok(_event) && !tradeup_result_ok({result_handle:5,result:SteamApiResult.Fail}),
       "only Ok is success; Fail is truthy but not success");
   ```
   Remove `ds_map_destroy`. The other fixtures (TRADE:289-321) stay unchanged because the wrapper keeps the project's item shape.

---------------------------------------------------------------------------------------------------

## 8. Pitfall checklist for the migration agent

- [ ] Do NOT pass plain struct literals to `steam_inventory_exchange_items`; use constructors (`itemdef_id`, `item_instance_id`).
- [ ] Do NOT omit the callback on `exchange_items`, `trigger_item_drop`, `request_prices` (fatal `show_error`).
- [ ] Do NOT expect a callback from `steam_inventory_get_all_items()`; register `steam_inventory_set_callback_result_ready` first, from the OWNER only (after `owns_inventory = true`), and clear it only inside `if (owns_inventory)`.
- [ ] Do NOT let the r_skinmenu duplicate (`r_skinmenu.yy:161`) register or clear the global slot.
- [ ] Do NOT rely on `undefined` meaning failure for `steam_inventory_get_result_items` (it is also an empty inventory); do not return `[]` when Steam is unavailable.
- [ ] Do NOT treat `_result.result` as a boolean; the matcher must require `result_handle` AND `result`.
- [ ] Do NOT call `steam_initialised()` anywhere.
- [ ] Do NOT add a second pump; remap `tcc_steam_update()` (o_fullscreensystem/Step_0.gml:4).
- [ ] Keep `platform_steam()` as the first guard (`get_all_items`, `destroy_result`, `get_result_timestamp`, `clear_callback_result_ready` have no `extension_exists` check).
- [ ] Never gate state on the `request_prices` callback (may never fire).
- [ ] Do not forward `steam_inventory_destroy_result`'s raw return value.
- [ ] Callbacks: bare unbound script functions only, none bound to non-persistent instances (o_title).

---------------------------------------------------------------------------------------------------

## 9. Unresolved (not verifiable read-only)

- **U1.** `buffer_read(buffer_u64)` returns an `int64` in GameMaker and ids >= 2^63 wrap negative (then `tradeup_item_id_valid` rejects the whole snapshot). Selfcheck fixtures cannot catch this; verify with a real inventory on a Steam build.
- **U2.** `int64(ptr(_callable))` registry key: neither a bare script function nor `method(undefined, fn)` has been shown to get a unique, stable key for each distinct callable (ASH1 section 1.4 gate). Run the smoke test (register two different script functions back to back, plus the same one twice) before relying on it.
- **U3.** Whether `scripts/Steamworks_API` (which references `__steam_*` extension functions) compiles on Apple/Mobile configs where the extension has `copyToTargets:"0"` (YY:14). Same situation as 2.x for the old function names, but the native-direct functions (`get_all_items`, `destroy_result`, ...) have no `extension_exists` guard. Core domain.
- **U4.** What 2.x `steam_inventory_get_item_price` actually returned (current or base price): no 2.x inventory source in the scratchpad.
- **U5.** `docs/release/STATUS.md:27` crash claim: the 3.0 source proves no null dereference when Steam is down, but the shipped binaries (`Steamworks.dll`, `libSteamworks.dylib`, `libSteamworks.so`) were not inspected; confirm on a Mac without Steam running.
- **U6.** Pump survival: `o_fullscreensystem` is destroyed by `o_endingreq/Create_0.gml:3`, and the pump is skipped when `timing_instance_step()` returns false; the exact phase of callback delivery relative to Step events is unverified (ASH1 section 1.4). Core domain.
- **U7.** Item definition id range: project uses `item_def` 100..~350 (`scr_get_item_def_for_tier`, `TRADE:150-152`; `item_def >= 5000` skipped); no change, but the exchange `itemdef_id` is u32.
