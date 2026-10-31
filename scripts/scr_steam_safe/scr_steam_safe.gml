// Steamworks 3.0 wrapper layer. This is the only script that calls the Steam extension; every raw call sits behind
// tcc_steam_ready() (or platform_steam() for the persistent callback slots), so iOS / Android / Mac App Store builds,
// which ship no Steam binary, never reach one.
// Layout: macros, state and id helpers, callback registry, relay, pump, wrappers by domain, self-check.
// Steam only ever receives tcc_steam_relay. Callers' callbacks are invoked by __tcc_steam_deliver, never by Steam.

#macro TCC_STEAM_SLOT_TTL_MS        180000   // single-flight / keyed entry lifetime (longer than every caller deadline, 120 s)
#macro TCC_STEAM_PUBLISH_SLOT_TTL_MS 125000  // ugc_create / ugc_submit: just past the publish screens' 120 s deadline, so a retry is not refused for a minute
#macro TCC_STEAM_RETURN_BUFFER_BYTES 262144  // the extension writes results into one shared return buffer (8192 bytes by default) and aborts the game on overflow
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
#macro TCC_NET_CHANNEL     0
#macro TCC_NET_RX_DROPPED  (-1)        // receive: a message was consumed and discarded by the native; keep looping

/// All registry state. Lives in a global so it survives game_restart like every other project global; re-created lazily.
function __tcc_steam_state() {
    if (!variable_global_exists("tcc_steam") || !is_struct(global.tcc_steam)) {
        global.tcc_steam = {
            was_ready: false, diag_done: false, tick: 0, sweep_at: 0,
            listeners: {},            // kind -> {cb, owner}              persistent, last writer wins, NOT consumed
            slots: {},                // kind -> {cb, owner, expires}     single flight, consumed on delivery
            keyed: {},                // kind -> { key -> {cb, owner, expires} }   consumed on delivery
            native_registered: {},    // kind -> true: the relay is installed in that native slot
            lb: { handles: {}, queue: [], cur: undefined },
            stats_dirty: false, stats_next_tick: 0,
            persona_req: {}, avatar_req: {},
            relay_errors: 0, unrouted: 0, ids_int64: undefined,
            net_last_send: 0          // EResult of the last tcc_steam_net_packet_send call (SteamApiResult.None = not attempted)
        };
    }
    return global.tcc_steam;
}

// ---- ids and small helpers -------------------------------------------------------------------------------------
function __tcc_steam_id(_v)       { return (is_numeric(_v) && !is_nan(_v) && !is_infinity(_v)) ? int64(_v) : int64(0); }   // int64(undefined) would throw
function tcc_steam_id_valid(_v)   { return is_numeric(_v) && _v > 0; }
function __tcc_steam_bool(_v)     { if (is_bool(_v)) return _v; return is_numeric(_v) ? (_v != 0) : false; }
function __tcc_steam_key(_v)      { return is_numeric(_v) ? string(int64(_v)) : string(_v); }                          // registry key of a handle / id
function __tcc_steam_buffer_ok(_b) { if (is_undefined(_b) || is_string(_b) || is_struct(_b) || is_array(_b)) return false; return buffer_exists(_b); }

/// Parses a registry key back into an int64; 0 when it is not a number.
function __tcc_steam_key_id(_key) {
    var _id = int64(0);
    try { _id = int64(_key); } catch (_e) { _id = int64(0); }
    return _id;
}

// ---- guard -----------------------------------------------------------------------------------------------------
function tcc_steam_ready()        { return platform_steam() && steam_api_is_initialized() != 0; }
function tcc_steam_initialised()  { return bool(tcc_steam_ready()); }
function tcc_steam_init()         { return bool(tcc_steam_ready()); }   // 3.0 initialises itself before the first frame; nothing to call

// ---- registry and delivery ---------------------------------------------------------------------------------------
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

// persistent listeners (lobby_created, lobby_entered, lobby_chat_update, lobby_join_requested, net_session_request, net_session_failed, inv_result_ready)
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

/// true when no more than one request per _interval_ms was made for _key (and records this one)
function __tcc_steam_throttle(_table, _key, _interval_ms) {
    var _last = _table[$ _key];
    if (!is_undefined(_last) && current_time - _last < _interval_ms) return false;
    _table[$ _key] = current_time;
    return true;
}

// ---- relay: the only callable that ever reaches a Steam extension function ---------------------------------------
// The dispatcher calls it with self = a shared empty struct, so it touches only globals. It never throws (an exception would
// abort the dispatcher loop and leave its packet buffer half read). Routing is by constructor name.
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
            case "SteamNetworkingMessagesSessionFailed":  __tcc_steam_deliver(_s.listeners[$ "net_session_failed"],   [_r]); break;
            // ---- inventory: this call's entry (by result_handle) first, else the owner's listener ----
            case "SteamInventoryResultReady": {
                var _entry = __tcc_steam_keyed_take("inv", __tcc_steam_key(_r.result_handle));
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
            // ---- leaderboards (serial queue) and player count ----
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

// ---- pump, registration, ready edge, sweep -----------------------------------------------------------------------
/// Persistent native slots. Guard is platform_steam() ONLY: the natives just store the pointer, and iOS/Android/MAS have no binary.
function __tcc_steam_native_register(_kind) {
    if (!platform_steam()) return false;
    switch (_kind) {
        case "lobby_chat_update":    steam_matchmaking_set_callback_lobby_chat_update(tcc_steam_relay); break;
        case "lobby_join_requested": steam_friends_set_callback_game_lobby_join_requested(tcc_steam_relay); break;
        case "net_session_request":  steam_networking_messages_set_callback_session_request(tcc_steam_relay); break;
        case "net_session_failed":   steam_networking_messages_set_callback_session_failed(tcc_steam_relay); break;
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
        case "net_session_request":  steam_networking_messages_clear_callback_session_request(); break;
        case "net_session_failed":   steam_networking_messages_clear_callback_session_failed(); break;
        case "inv_result_ready":     steam_inventory_clear_callback_result_ready(); break;
        default: return false;       // lobby_join_requested is never cleared by the project; shutdown clears it
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

/// Grows the extension's shared return buffer once. The native writes whole result structs and arrays (an inventory snapshot, a Workshop
/// query result, the subscribed item list) into it and aborts the game when one does not fit in the default 8192 bytes.
function __tcc_steam_grow_return_buffer() {
    if (buffer_get_size(__ext_core_get_ret_buffer()) < TCC_STEAM_RETURN_BUFFER_BYTES) __ext_core_get_ret_buffer(TCC_STEAM_RETURN_BUFFER_BYTES);
}

/// The only pump: called every simulation tick from o_fullscreensystem. Nobody else calls steam_api_run_callbacks().
function tcc_steam_update() {
    if (!platform_steam()) return false;
    var _s = __tcc_steam_state();
    _s.tick += 1;
    var _ready = tcc_steam_ready();
    if (_ready != _s.was_ready) {                       // Steam came up, or went away (shutdown / restart)
        _s.was_ready = _ready;
        if (_ready) { _s.diag_done = false; __tcc_steam_grow_return_buffer(); tcc_steam_register_callbacks(true); }
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
            if (_kinds[_k] == "ugc_query") {                                    // the callback never came: free the handle
                var _qh = __tcc_steam_key_id(_keys[_j]);
                if (_qh != 0 && tcc_steam_ready()) steam_ugc_release_query_ugc_request(_qh);
            }
            variable_struct_remove(_table, _keys[_j]);
        }
    }
    if (variable_struct_names_count(_s.persona_req) > 512) _s.persona_req = {};   // cap growth
    if (variable_struct_names_count(_s.avatar_req) > 512)  _s.avatar_req = {};
}

// ---- core, identity, apps ----------------------------------------------------------------------------------------
function tcc_steam_get_app_id() {
    if (!tcc_steam_ready()) return false;                           // false on purpose: `!= 1749610` stays true when Steam is down
    var _app = steam_utils_get_app_id();
    return is_numeric(_app) ? _app : false;
}
function tcc_steam_get_user_steam_id() {
    if (!tcc_steam_ready()) return int64(0);
    return __tcc_steam_id(steam_user_get_steam_id());
}
function tcc_steam_is_user_logged_on() {
    if (!tcc_steam_ready()) return false;
    return __tcc_steam_bool(steam_user_logged_on());
}
function tcc_steam_get_persona_name() {
    if (!tcc_steam_ready()) return "";
    var _name = steam_friends_get_persona_name();
    return is_string(_name) ? _name : "";
}
function tcc_steam_is_overlay_enabled() {
    if (!tcc_steam_ready()) return false;
    return __tcc_steam_bool(steam_utils_is_overlay_enabled());
}
function tcc_steam_user_owns_dlc(_app_id) {
    if (!tcc_steam_ready() || !is_numeric(_app_id)) return false;
    return __tcc_steam_bool(steam_apps_is_subscribed_app(_app_id));
}
function tcc_steam_user_installed_dlc(_app_id) {
    if (!tcc_steam_ready() || !is_numeric(_app_id)) return false;
    return __tcc_steam_bool(steam_apps_is_dlc_installed(_app_id));
}
/// _abs_file must be an absolute JPG / PNG / TGA path. Returns the screenshot handle (> 0) or false. The import result is not observed.
function tcc_steam_send_screenshot(_abs_file, _w, _h) {
    if (!tcc_steam_ready() || !is_string(_abs_file) || _abs_file == "" || !file_exists(_abs_file)) return false;
    if (!is_numeric(_w) || !is_numeric(_h) || _w <= 0 || _h <= 0) return false;
    var _handle = steam_screenshots_add_screenshot_to_library(_abs_file, "", _w, _h);
    return (is_numeric(_handle) && _handle > 0) ? _handle : false;
}

// ---- social: overlay, rich presence, friends ----------------------------------------------------------------------
function tcc_steam_activate_overlay(_dialog) {
    if (!tcc_steam_ready()) return false;
    steam_friends_activate_game_overlay(string(_dialog));
    return true;
}
function tcc_steam_activate_overlay_user(_dialog, _steam_id) {
    if (!tcc_steam_ready() || !tcc_steam_id_valid(_steam_id)) return false;
    steam_friends_activate_game_overlay_to_user(string(_dialog), _steam_id);
    return true;
}
function tcc_steam_activate_overlay_browser(_url) {
    if (!tcc_steam_ready()) return false;
    steam_friends_activate_game_overlay_to_web_page(string(_url), SteamFriendsOverlayToWebpageMode.Default);
    return true;
}
function tcc_steam_activate_overlay_store(_app_id) {
    if (!tcc_steam_ready() || !is_numeric(_app_id)) return false;
    steam_friends_activate_game_overlay_to_store(_app_id, SteamFriendsOverlayToStoreFlag.None);
    return true;
}
/// "" as value deletes the key. Keys steam_display, steam_player_group and steam_player_group_size are Steam-reserved strings.
function tcc_steam_set_rich_presence(_key, _value) {
    if (!tcc_steam_ready()) return false;
    return __tcc_steam_bool(steam_friends_set_rich_presence(string(_key), string(_value)));
}
function tcc_steam_get_friend_rich_presence(_steam_id, _key) {
    if (!tcc_steam_ready() || !tcc_steam_id_valid(_steam_id)) return "";
    var _value = steam_friends_get_friend_rich_presence(_steam_id, string(_key));
    return is_string(_value) ? _value : "";
}
/// Legacy row shape [{friendId, gameId, lobbyId, name}], only friends that are in a game. Local data only (no network request).
function tcc_steam_get_friends_game_info() {
    var _result = [];
    if (!tcc_steam_ready()) return _result;
    var _flags = SteamFriendsFriendFlag.Immediate;
    var _count = steam_friends_get_friend_count(_flags);
    if (!is_numeric(_count)) return _result;
    for (var _i = 0; _i < _count; ++_i) {
        var _friend = steam_friends_get_friend_by_index(_i, _flags);
        if (!tcc_steam_id_valid(_friend)) continue;
        var _game = steam_friends_get_friend_game_played(_friend);
        if (!is_struct(_game)) continue;
        var _name = steam_friends_get_friend_persona_name(_friend);
        array_push(_result, {
            friendId: __tcc_steam_id(_friend),
            gameId:   __tcc_steam_id(_game.game_id) & 0xFFFFFF,
            lobbyId:  __tcc_steam_id(_game.lobby_steam_id_64),
            name:     is_string(_name) ? _name : ""
        });
    }
    return _result;
}
function tcc_steam_user_set_played_with(_steam_id) {
    if (!tcc_steam_ready() || !tcc_steam_id_valid(_steam_id)) return false;       // 3.0 aborts the game on a non-number
    steam_friends_set_played_with(_steam_id);
    return true;
}

/// "" while the name is unknown. Issues a throttled request so Steam fetches it; the next poll sees it. Never call from a Draw event.
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

// ---- avatars and images ---------------------------------------------------------------------------------------------
/// > 0 ready image handle, TCC_AVATAR_PENDING (-1) not available yet (the caller retries, bounded), TCC_AVATAR_NONE (0) Steam not ready / invalid id.
function tcc_steam_get_user_avatar(_steam_id, _size) {
    if (!tcc_steam_ready()) return TCC_AVATAR_NONE;
    var _id = __tcc_steam_id(_steam_id);
    if (_id <= 0) return TCC_AVATAR_NONE;
    var _h;
    switch (_size) {                                               // default = SMALL, as 2.x did
        case TCC_STEAM_AVATAR_LARGE:  _h = steam_friends_get_large_friend_avatar(_id);  break;
        case TCC_STEAM_AVATAR_MEDIUM: _h = steam_friends_get_medium_friend_avatar(_id); break;
        default:                      _h = steam_friends_get_small_friend_avatar(_id);  break;
    }
    if (is_numeric(_h) && _h > 0) return _h;
    if (_id != steam_user_get_steam_id() && __tcc_steam_throttle(__tcc_steam_state().avatar_req, string(_id), TCC_STEAM_PERSONA_RETRY_MS))
        steam_friends_request_user_information(_id, false);        // false = also fetch the avatar
    return TCC_AVATAR_PENDING;                                     // raw 0 or -1: not available yet
}
/// [w, h] or undefined.
function tcc_steam_image_get_size(_image) {
    if (!tcc_steam_ready() || !is_numeric(_image) || _image <= 0) return undefined;
    var _s = steam_utils_get_image_size(_image);
    if (is_struct(_s) && is_numeric(_s.width) && is_numeric(_s.height)) return [_s.width, _s.height];
    return undefined;
}
/// _size is ignored: the buffer must be exactly w*h*4 bytes (size it from tcc_steam_image_get_size).
function tcc_steam_image_get_rgba(_image, _buffer, _size = 0) {
    if (!tcc_steam_ready() || !is_numeric(_image) || _image <= 0 || !__tcc_steam_buffer_ok(_buffer)) return false;
    return __tcc_steam_bool(steam_utils_get_image_rgba(_image, _buffer));
}
/// Sprite id, or -1. The CALLER owns the sprite (sprite_delete).
function tcc_steam_image_to_sprite(_image) {
    var _dims = tcc_steam_image_get_size(_image);
    if (!is_array(_dims) || _dims[0] <= 0 || _dims[1] <= 0 || _dims[0] > 512 || _dims[1] > 512) return -1;
    var _bytes = _dims[0] * _dims[1] * 4;
    var _buffer = buffer_create(_bytes, buffer_fixed, 1);
    var _sprite = -1;
    if (tcc_steam_image_get_rgba(_image, _buffer)) {
        var _surface = surface_create(_dims[0], _dims[1]);
        if (surface_exists(_surface)) {
            buffer_set_surface(_buffer, _surface, 0);
            _sprite = sprite_create_from_surface(_surface, 0, 0, _dims[0], _dims[1], false, false, 0, 0);
            surface_free(_surface);
        }
    }
    buffer_delete(_buffer);
    return _sprite;
}

// ---- lobbies (matchmaking) ---------------------------------------------------------------------------------------
/// undefined -> the lobby the game is in; anything that is not a positive number -> 0 (no lobby)
function __tcc_steam_lobby_resolve(_lobby_id) {
    if (is_undefined(_lobby_id)) _lobby_id = variable_global_exists("net_lobby_id") ? global.net_lobby_id : -1;
    if (!tcc_steam_id_valid(_lobby_id)) return int64(0);
    return __tcc_steam_id(_lobby_id);
}

/// Callback _callback(_r), _r = SteamMatchmakingLobbyCreated {result, lobby_id}. Persistent listener "lobby_created" (last writer wins, not
/// consumed: a late reply after the caller gave up still arrives). Returns true when the request was issued; a reply is still not guaranteed.
function tcc_steam_lobby_create(_type, _max_members, _callback, _owner = noone) {
    if (!tcc_steam_ready() || !is_callable(_callback) || !is_numeric(_type) || !is_numeric(_max_members)) return false;
    __tcc_steam_listener_set("lobby_created", _callback, _owner);
    steam_matchmaking_create_lobby(_type, _max_members, tcc_steam_relay);
    return steam_api_last_error() == "";          // native is void; read the last error immediately, nothing may run in between
}
/// Callback _callback(_r), _r = SteamMatchmakingLobbyEnter {lobby_id, chat_permissions, locked, response}. Persistent listener "lobby_entered".
function tcc_steam_lobby_join_id(_lobby_id, _callback, _owner = noone) {
    if (!tcc_steam_ready() || !is_callable(_callback) || !tcc_steam_id_valid(_lobby_id)) return false;   // a join has no "current lobby" default
    __tcc_steam_listener_set("lobby_entered", _callback, _owner);
    steam_matchmaking_join_lobby(_lobby_id, tcc_steam_relay);
    return steam_api_last_error() == "";
}
function tcc_steam_lobby_leave(_lobby_id = undefined) {
    if (!tcc_steam_ready()) return false;
    var _lobby = __tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby == 0) return false;
    steam_matchmaking_leave_lobby(_lobby);
    return true;
}
function tcc_steam_lobby_set_data(_key, _value, _lobby_id = undefined) {
    if (!tcc_steam_ready()) return false;
    var _lobby = __tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby == 0) return false;
    return __tcc_steam_bool(steam_matchmaking_set_lobby_data(_lobby, string(_key), string(_value)));
}
function tcc_steam_lobby_get_data(_key, _lobby_id = undefined) {
    if (!tcc_steam_ready()) return "";
    var _lobby = __tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby == 0) return "";
    var _value = steam_matchmaking_get_lobby_data(_lobby, string(_key));
    return is_string(_value) ? _value : "";
}
function tcc_steam_lobby_set_joinable(_joinable, _lobby_id = undefined) {
    if (!tcc_steam_ready()) return false;
    var _lobby = __tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby == 0) return false;
    return __tcc_steam_bool(steam_matchmaking_set_lobby_joinable(_lobby, __tcc_steam_bool(_joinable)));   // is_bool is enforced by 3.0
}
function tcc_steam_lobby_set_owner_id(_user_id, _lobby_id = undefined) {
    if (!tcc_steam_ready() || !tcc_steam_id_valid(_user_id)) return false;
    var _lobby = __tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby == 0) return false;
    return __tcc_steam_bool(steam_matchmaking_set_lobby_owner(_lobby, _user_id));
}
function tcc_steam_lobby_get_owner_id(_lobby_id = undefined) {
    var _mock = tcc_steam_net_mock();
    if (is_struct(_mock)) return __tcc_steam_id(_mock.lobby_owner_id());
    if (!tcc_steam_ready()) return int64(0);
    var _lobby = __tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby == 0) return int64(0);
    return __tcc_steam_id(steam_matchmaking_get_lobby_owner(_lobby));
}
function tcc_steam_lobby_is_owner(_lobby_id = undefined) {
    var _owner = tcc_steam_lobby_get_owner_id(_lobby_id);
    return _owner != 0 && _owner == tcc_steam_get_user_steam_id();
}
function tcc_steam_lobby_get_member_count(_lobby_id = undefined) {
    var _mock = tcc_steam_net_mock();
    if (is_struct(_mock)) return _mock.lobby_member_count();
    if (!tcc_steam_ready()) return 0;
    var _lobby = __tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby == 0) return 0;
    var _count = steam_matchmaking_get_num_lobby_members(_lobby);
    return is_numeric(_count) ? _count : 0;
}
function tcc_steam_lobby_get_member_id(_index, _lobby_id = undefined) {
    var _mock = tcc_steam_net_mock();
    if (is_struct(_mock)) return __tcc_steam_id(_mock.lobby_member_id(_index));
    if (!tcc_steam_ready() || !is_numeric(_index) || _index < 0) return int64(0);
    var _lobby = __tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby == 0) return int64(0);
    return __tcc_steam_id(steam_matchmaking_get_lobby_member_by_index(_lobby, _index));
}
function tcc_steam_lobby_activate_invite_overlay(_lobby_id = undefined) {
    if (!tcc_steam_ready()) return false;
    var _lobby = __tcc_steam_lobby_resolve(_lobby_id);
    if (_lobby == 0) return false;
    steam_friends_activate_game_overlay_invite_dialog(_lobby);
    return true;
}
/// Registered once per boot from o_networkmanager (re-calling replaces the listeners and re-registers). Platform guard only.
/// _chat_update(_r): SteamMatchmakingLobbyChatUpdate {lobby_id, user_changed_id, making_change_id, chat_member_state_change}.
/// _join_requested(_r): SteamFriendsGameLobbyJoinRequested {steam_id_friend, steam_id_lobby}. Both must be named global script functions
/// that touch only globals: they run for the whole session with a shared empty self.
function tcc_steam_set_lobby_callbacks(_chat_update, _join_requested) {
    if (!platform_steam()) return false;
    __tcc_steam_listener_set("lobby_chat_update", _chat_update, noone);
    __tcc_steam_listener_set("lobby_join_requested", _join_requested, noone);
    __tcc_steam_native_register("lobby_chat_update");
    __tcc_steam_native_register("lobby_join_requested");
    return true;
}

// ---- networking (Networking Messages, channel TCC_NET_CHANNEL) ---------------------------------------------------
/// Test seam, Check configuration only: returns the mock struct in global.tcc_net_mock, or undefined. TCC_SELF_CHECK is the literal
/// false outside Check, so the seam is never consulted in a shipped build.
function tcc_steam_net_mock() {
    if (!TCC_SELF_CHECK) return undefined;
    if (!variable_global_exists("tcc_net_mock")) return undefined;
    return is_struct(global.tcc_net_mock) ? global.tcc_net_mock : undefined;
}

/// Pure. Turns the result of ONE count=1 receive into the wrapper's return value:
/// [message] -> the struct; [] + "output buffer exhausted" -> TCC_NET_RX_DROPPED (the native consumed and released a message
/// that did not fit); anything else empty (queue empty, Steam not ready, extension missing) -> undefined.
function tcc_steam_net_classify(_messages, _last_error) {
    if (!is_array(_messages)) return undefined;
    if (array_length(_messages) > 0) return _messages[0];
    return (string_pos("output buffer exhausted", string(_last_error)) > 0) ? TCC_NET_RX_DROPPED : undefined;
}

/// EResult of the most recent tcc_steam_net_packet_send call. Read it immediately after the send; nothing else writes it.
function tcc_steam_net_last_send_result() {
    return __tcc_steam_state().net_last_send;
}

/// true ONLY when the SDK returned SteamApiResult.Ok (queued, not delivered). _size is mandatory: an omitted count would send the whole
/// allocated buffer. Flags default to reliable (the 2.x default). A refused argument never reaches the native (3.0 aborts the game on it).
function tcc_steam_net_packet_send(_steam_id, _buffer, _size, _flags = undefined) {
    var _st = __tcc_steam_state();
    _st.net_last_send = SteamApiResult.None;
    var _mock = tcc_steam_net_mock();
    if (!is_struct(_mock) && !tcc_steam_ready()) return false;
    if (!tcc_steam_id_valid(_steam_id) || !__tcc_steam_buffer_ok(_buffer) || !is_numeric(_size)) {
        _st.net_last_send = SteamApiResult.InvalidParam;
        return false;
    }
    var _count = min(floor(_size), buffer_get_size(_buffer));      // 2.x clamped to the buffer as well
    if (_count < 1) { _st.net_last_send = SteamApiResult.InvalidParam; return false; }   // 0 bytes is InvalidParam natively
    var _use = is_undefined(_flags) ? TCC_NET_SEND_RELIABLE : _flags;
    var _result = is_struct(_mock)
        ? _mock.send(_steam_id, _buffer, _use, TCC_NET_CHANNEL, 0, _count)
        : steam_networking_messages_send_message_to_user(_steam_id, _buffer, _use, TCC_NET_CHANNEL, 0, _count);
    if (!is_numeric(_result)) _result = SteamApiResult.Fail;       // undefined = extension missing
    _st.net_last_send = _result;
    return _result == SteamApiResult.Ok;
}

/// Pulls at most ONE message on the game channel into _buffer (payload at offset 0; a fixed 524288-byte buffer).
/// Returns the SteamNetworkingMessage struct, undefined (nothing to read / Steam not ready), or TCC_NET_RX_DROPPED.
function tcc_steam_net_packet_receive(_buffer) {
    var _mock = tcc_steam_net_mock();
    if (!is_struct(_mock) && !tcc_steam_ready()) return undefined;
    if (!__tcc_steam_buffer_ok(_buffer)) return undefined;
    var _messages;
    var _error = "";
    if (is_struct(_mock)) {
        _messages = _mock.receive(TCC_NET_CHANNEL, _buffer, 1);
        _error = _mock.last_error();
    } else {
        _messages = steam_networking_messages_receive_messages_on_channel(TCC_NET_CHANNEL, _buffer, 1);
        // Nothing guarded may run between the receive and this read: every guarded native clears the last error on entry.
        if (is_array(_messages) && array_length(_messages) == 0) _error = string(steam_api_last_error());
    }
    return tcc_steam_net_classify(_messages, _error);
}

function tcc_steam_net_accept_session(_steam_id) {
    var _mock = tcc_steam_net_mock();
    if (!is_struct(_mock) && !tcc_steam_ready()) return false;
    if (!tcc_steam_id_valid(_steam_id)) return false;
    var _accepted = is_struct(_mock) ? _mock.accept(_steam_id) : steam_networking_messages_accept_session_with_user(_steam_id);
    return __tcc_steam_bool(_accepted);
}

function tcc_steam_net_close_p2p_session(_steam_id) {
    var _mock = tcc_steam_net_mock();
    if (!is_struct(_mock) && !tcc_steam_ready()) return false;
    if (!tcc_steam_id_valid(_steam_id)) return false;
    var _closed = is_struct(_mock) ? _mock.close(_steam_id) : steam_networking_messages_close_session_with_user(_steam_id);
    return __tcc_steam_bool(_closed);
}

/// Persistent listener "net_session_request". _callback(_r), _r = SteamNetworkingMessagesSessionRequest {steam_id_remote}. It runs from the
/// extension's time-source tick with a shared empty self: a named global script function that touches only globals and only queues the id.
function tcc_steam_net_set_session_request_callback(_callback) {
    if (!is_callable(_callback)) return false;
    var _mock = tcc_steam_net_mock();
    if (is_struct(_mock)) return _mock.set_session_request_callback(_callback);
    if (!platform_steam()) return false;
    __tcc_steam_listener_set("net_session_request", _callback, noone);
    return __tcc_steam_native_register("net_session_request");
}

/// Persistent listener "net_session_failed". _callback(_r), _r = SteamNetworkingMessagesSessionFailed {steam_id_remote, end_reason, debug_msg}.
/// Diagnostics only: membership never depends on it.
function tcc_steam_net_set_session_failed_callback(_callback) {
    if (!is_callable(_callback)) return false;
    var _mock = tcc_steam_net_mock();
    if (is_struct(_mock)) return _mock.set_session_failed_callback(_callback);
    if (!platform_steam()) return false;
    __tcc_steam_listener_set("net_session_failed", _callback, noone);
    return __tcc_steam_native_register("net_session_failed");
}

/// Removes both session listeners and clears both native slots. Not called by the project (see the restart analysis); kept for completeness.
function tcc_steam_net_clear_session_callbacks() {
    __tcc_steam_listener_clear("net_session_request");
    __tcc_steam_listener_clear("net_session_failed");
    var _request = __tcc_steam_native_unregister("net_session_request");
    var _failed = __tcc_steam_native_unregister("net_session_failed");
    return _request || _failed;
}

// ---- leaderboards, achievements, player count ---------------------------------------------------------------------
// Leaderboard requests run one at a time through a queue: Steam's answers carry no request id, and two same-frame uploads exist.
// Jobs are only queued by the wrappers; the first Steam call of a job is made by the next tcc_steam_update(), so no callback (not even
// a watchdog failure of an older job) ever runs inside the requesting instance's event.
function __tcc_steam_lb_available() { return tcc_steam_ready() && steam_user_logged_on() != 0; }   // 2.x refused leaderboard calls when not logged on

function __tcc_steam_lb_enqueue(_job) {
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
    if (array_length(_lb.queue) == 0 || !tcc_steam_ready()) return;      // the first Steam call of a job is made here, never without Steam
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
/// A newer download from the same instance replaces its queued ones (2.x let stale answers be dropped by the caller's token; here the
/// serial queue would run every one of them, so quickly paging through boards would wait for all of them). The dropped jobs get no callback.
function __tcc_steam_lb_drop_queued_downloads(_owner) {
    if (_owner == noone) return;
    var _queue = __tcc_steam_state().lb.queue;
    for (var _i = array_length(_queue) - 1; _i >= 0; --_i)
        if (_queue[_i].kind == "download" && _queue[_i].owner == _owner) array_delete(_queue, _i, 1);
}
function __tcc_steam_lb_download(_board, _request, _a, _b, _callback, _owner) {
    if (!is_callable(_callback) || !__tcc_steam_lb_available()) return false;
    __tcc_steam_lb_drop_queued_downloads(_owner);
    __tcc_steam_lb_enqueue({ kind: "download", board: string(_board), request: _request, range_a: _a, range_b: _b, cb: _callback, owner: _owner, step: "", handle: 0, deadline: 0 });
    return true;
}
/// _callback(_rows): array (length <= 100, may be empty) of {steam_id: int64, name, score, rank (1-based)}, or undefined on any failure.
function tcc_steam_download_scores(_board, _start, _end, _callback, _owner = noone)             { return __tcc_steam_lb_download(_board, SteamLeaderboardDataRequest.Global,          _start, _end, _callback, _owner); }
function tcc_steam_download_scores_around_user(_board, _from, _to, _callback, _owner = noone)   { return __tcc_steam_lb_download(_board, SteamLeaderboardDataRequest.GlobalAroundUser, _from,  _to,  _callback, _owner); }
function tcc_steam_download_friends_scores(_board, _callback, _owner = noone)                   { return __tcc_steam_lb_download(_board, SteamLeaderboardDataRequest.Friends,         0,      0,    _callback, _owner); }
function tcc_steam_upload_score(_board, _score, _force = false) {
    if (!__tcc_steam_lb_available() || !is_numeric(_score) || is_nan(_score)) return false;
    __tcc_steam_lb_enqueue({ kind: "upload", board: string(_board), value: clamp(floor(_score), 0, 2147483647),
        how: (_force ? SteamLeaderboardUploadScoreMethod.ForceUpdate : SteamLeaderboardUploadScoreMethod.KeepBest), step: "", handle: 0, deadline: 0 });
    return true;
}

// ---- achievements and stats -----------------------------------------------------------------------------------------
function tcc_steam_get_achievement(_name) {
    if (!tcc_steam_ready()) return false;
    var _r = steam_userstats_get_achievement(string(_name));       // Bool, or undefined (stats unavailable / unknown name)
    return is_bool(_r) ? _r : false;
}
function tcc_steam_set_achievement(_name) {
    if (!tcc_steam_ready()) return false;
    var _ok = __tcc_steam_bool(steam_userstats_set_achievement(string(_name)));   // direct native, in-memory only
    if (_ok) { var _st = __tcc_steam_state(); _st.stats_dirty = true; }            // flushed by tcc_steam_update
    return _ok;
}
function tcc_steam_reset_all_stats_achievements() {
    if (!tcc_steam_ready()) return false;
    return __tcc_steam_bool(steam_userstats_reset_all_stats(true));                // 3.0 stores automatically
}
/// Returns true when the request was issued; the relay writes global.playercount when the answer arrives.
function tcc_steam_get_number_of_current_players() {
    if (!tcc_steam_ready()) return false;
    if (!__tcc_steam_slot_take("players", undefined, noone, TCC_STEAM_PLAYERS_TTL_MS)) return false;   // 2.x IsActive() rejection
    steam_userstats_number_of_current_players(tcc_steam_relay);
    return true;
}

// ---- inventory ------------------------------------------------------------------------------------------------------
// Result handles are small positive ints; -1 = none. The result-ready slot is single and global, so only one owner (the trade-up
// controller) sets and clears the listener; per-call results (exchange, drop) are routed by result_handle to their own entry first.
function tcc_steam_inventory_get_all_items() {
    if (!tcc_steam_ready()) return -1;
    var _handle = steam_inventory_get_all_items();
    return (is_numeric(_handle) && _handle >= 1) ? _handle : -1;
}
/// _callback(_r), _r = SteamInventoryResultReady {result_handle, result}. Success is `_r.result == SteamApiResult.Ok` (Fail = 2 is truthy).
function tcc_steam_inventory_set_callback_result_ready(_callback) {
    if (!platform_steam() || !is_callable(_callback)) return false;
    __tcc_steam_listener_set("inv_result_ready", _callback, noone);
    return __tcc_steam_native_register("inv_result_ready");
}
function tcc_steam_inventory_clear_callback_result_ready() {
    __tcc_steam_listener_clear("inv_result_ready");
    return __tcc_steam_native_unregister("inv_result_ready");
}
/// _create = [{item_def, quantity}], _destroy = [{item_id, quantity}]. Returns the result handle (>= 1) or -1. The result handle must
/// then be destroyed with tcc_steam_inventory_result_destroy. _callback(_r) gets SteamInventoryResultReady for THIS call only.
function tcc_steam_inventory_exchange_items(_create, _destroy, _callback, _owner = noone) {
    if (!tcc_steam_ready() || !is_array(_create) || !is_array(_destroy) || !is_callable(_callback)) return -1;
    var _gen = [], _del = [];
    for (var _i = 0; _i < array_length(_create); ++_i) {
        var _g = new SteamInventoryItemDefQuantity();            // plain struct literals abort the game
        _g.itemdef_id = _create[_i].item_def;
        _g.quantity = _create[_i].quantity;
        array_push(_gen, _g);
    }
    for (var _j = 0; _j < array_length(_destroy); ++_j) {
        var _d = new SteamInventoryItemInstanceQuantity();
        _d.item_instance_id = _destroy[_j].item_id;              // keep int64
        _d.quantity = _destroy[_j].quantity;
        array_push(_del, _d);
    }
    var _handle = steam_inventory_exchange_items(_gen, _del, tcc_steam_relay);
    if (!is_numeric(_handle) || _handle < 1) return -1;
    __tcc_steam_keyed_put("inv", __tcc_steam_key(_handle), _callback, _owner);
    return _handle;
}
function tcc_steam_inventory_result_destroy(_handle) {
    if (!tcc_steam_ready() || !is_numeric(_handle) || _handle < 1) return false;
    steam_inventory_destroy_result(_handle);      // the raw return is a meaningless 0 and is never forwarded
    return true;
}
/// Default callbacks (plain script functions). The release callback destroys the result handle unconditionally.
function tcc_steam_inventory_release_result(_r) {
    if (is_struct(_r) && variable_struct_exists(_r, "result_handle")) tcc_steam_inventory_result_destroy(_r.result_handle);
}
function tcc_steam_inventory_ignore_result(_r) {}
/// Returns the result handle (>= 1) or -1. _callback defaults to tcc_steam_inventory_release_result. May never call back.
function tcc_steam_inventory_trigger_item_drop(_item_def, _callback = undefined, _owner = noone) {
    if (!tcc_steam_ready() || !is_numeric(_item_def)) return -1;
    if (!is_callable(_callback)) _callback = tcc_steam_inventory_release_result;
    var _handle = steam_inventory_trigger_item_drop(_item_def, tcc_steam_relay);
    if (!is_numeric(_handle) || _handle < 1) return -1;
    __tcc_steam_keyed_put("inv", __tcc_steam_key(_handle), _callback, _owner);
    return _handle;
}
/// Returns true when issued. May never call back; never gate state on it. _r = SteamInventoryRequestPricesResult {result, currency}.
function tcc_steam_inventory_request_prices(_callback = undefined, _owner = noone) {
    if (!tcc_steam_ready()) return false;
    if (!is_callable(_callback)) _callback = tcc_steam_inventory_ignore_result;
    if (!__tcc_steam_slot_take("inv_prices", _callback, _owner)) return false;
    steam_inventory_request_prices(tcc_steam_relay);
    return true;
}
/// ASSUMPTION (no 2.x source): "price" is current_price. No live caller.
function tcc_steam_inventory_get_item_price(_item_def) {
    if (!tcc_steam_ready() || !is_numeric(_item_def)) return undefined;
    var _p = steam_inventory_get_item_price(_item_def);
    return is_struct(_p) ? _p.current_price : undefined;
}
function tcc_steam_inventory_result_get_status(_handle) {
    if (!tcc_steam_ready() || !is_numeric(_handle) || _handle < 1) return SteamApiResult.Fail;
    var _status = steam_inventory_get_result_status(_handle);
    return is_numeric(_status) ? _status : SteamApiResult.Fail;
}
/// Old project shape [{item_id, item_def, quantity, flags}]. undefined = failure (not ready, or the snapshot is not Ok);
/// [] = a genuinely empty inventory.
function tcc_steam_inventory_result_get_items(_handle) {
    if (!tcc_steam_ready() || !is_numeric(_handle) || _handle < 1) return undefined;
    var _src = steam_inventory_get_result_items(_handle);
    if (!is_array(_src)) return (steam_inventory_get_result_status(_handle) == SteamApiResult.Ok) ? [] : undefined;
    var _out = array_create(array_length(_src));
    for (var _i = 0; _i < array_length(_src); ++_i) {
        var _s = _src[_i];
        _out[_i] = { item_id: _s.item_instance_id, item_def: _s.item_def_id, quantity: _s.quantity, flags: _s.flags };
    }
    return _out;
}
function tcc_steam_inventory_result_get_item_property(_handle, _index, _name) {
    if (!tcc_steam_ready() || !is_numeric(_handle) || _handle < 1 || !is_numeric(_index) || _index < 0) return "";
    var _v = steam_inventory_get_result_item_property(_handle, _index, string(_name));
    return is_string(_v) ? _v : "";
}
function tcc_steam_inventory_result_get_unix_timestamp(_handle) {
    if (!tcc_steam_ready() || !is_numeric(_handle) || _handle < 1) return 0;
    var _t = steam_inventory_get_result_timestamp(_handle);
    return is_numeric(_t) ? _t : 0;
}

// ---- UGC / Workshop ---------------------------------------------------------------------------------------------------
// Query and update handles are u64 read as int64: never test them with > 0, use tcc_steam_ugc_handle_valid. File ids stay > 0.
/// ONE validity test for query AND update handles.
function tcc_steam_ugc_handle_valid(_h) {
    return is_numeric(_h) && _h != 0 && _h != STEAM_UGC_QUERY_HANDLE_INVALID && _h != STEAM_UGC_UPDATE_HANDLE_INVALID;
}
/// Resolves the consumer app id at call time: global.appid can be false (o_title/Create_0.gml).
function __tcc_steam_ugc_app_id(_a) {
    var _id = (is_numeric(_a) && _a > 0) ? _a : steam_utils_get_app_id();
    return (is_numeric(_id) && _id > 0) ? _id : 0;
}
/// Single hook for path handling. Paths are passed through unmodified (the Windows path form is unverified; normalise here if needed).
function __tcc_steam_ugc_path(_p) { return string(_p); }

// ---- sync shims (same signatures as 2.x) ------------------------------------------------------------------------------
function tcc_steam_ugc_num_subscribed_items() {
    if (!tcc_steam_ready()) return false;
    var _n = steam_ugc_get_num_subscribed_items(false);
    return is_numeric(_n) ? _n : false;
}
/// Fills the ds_list with int64 file ids. Returns the list size, or false.
function tcc_steam_ugc_get_subscribed_items(_list) {
    if (!tcc_steam_ready() || !is_numeric(_list) || !ds_exists(_list, ds_type_list)) return false;
    ds_list_clear(_list);
    var _n = steam_ugc_get_num_subscribed_items(false);
    if (!is_numeric(_n)) return false;
    var _ids = (_n > 0) ? steam_ugc_get_subscribed_items(_n, false) : [];
    if (!is_array(_ids)) return false;
    for (var _i = 0; _i < array_length(_ids); ++_i) ds_list_add(_list, __tcc_steam_id(_ids[_i]));
    return ds_list_size(_list);
}
/// ds_map keys: size_on_disk, legacy_item, folder.
function tcc_steam_ugc_get_item_install_info(_file_id, _map) {
    if (!tcc_steam_ready() || !tcc_steam_id_valid(_file_id) || !is_numeric(_map) || !ds_exists(_map, ds_type_map)) return false;
    ds_map_clear(_map);
    var _info = steam_ugc_get_item_install_info(_file_id);       // undefined when not installed
    if (!is_struct(_info)) return false;
    var _state = steam_ugc_get_item_state(_file_id);
    _map[? "size_on_disk"] = _info.size_on_disk;
    _map[? "legacy_item"]  = (is_numeric(_state) && (_state & SteamUgcItemState.LegacyItem) != 0) ? 1 : 0;
    _map[? "folder"]       = _info.folder;
    return true;
}
/// ds_map keys: needs_update, is_downloading, bytes_downloaded, bytes_total, is_legacy, is_download_pending, is_installed.
function tcc_steam_ugc_get_item_update_info(_file_id, _map) {
    if (!tcc_steam_ready() || !tcc_steam_id_valid(_file_id) || !is_numeric(_map) || !ds_exists(_map, ds_type_map)) return false;
    ds_map_clear(_map);
    var _state = steam_ugc_get_item_state(_file_id);
    if (!is_numeric(_state)) return false;
    var _dl = steam_ugc_get_item_download_info(_file_id);        // undefined unless Steam has download info
    var _have = is_struct(_dl);
    _map[? "needs_update"]        = ((_state & SteamUgcItemState.NeedsUpdate) != 0) ? 1 : 0;
    _map[? "is_downloading"]      = ((_state & SteamUgcItemState.Downloading) != 0) ? 1 : 0;
    _map[? "bytes_downloaded"]    = _have ? _dl.bytes_downloaded : 0;
    _map[? "bytes_total"]         = _have ? _dl.bytes_total : 0;
    _map[? "is_legacy"]           = ((_state & SteamUgcItemState.LegacyItem) != 0) ? 1 : 0;
    _map[? "is_download_pending"] = ((_state & SteamUgcItemState.DownloadPending) != 0) ? 1 : 0;
    _map[? "is_installed"]        = ((_state & SteamUgcItemState.Installed) != 0) ? 1 : 0;
    return true;
}

// ---- publish side: single-flight slots (the results of create and submit carry no key) -------------------------------
/// Returns true = attempted (a result is still not guaranteed: callers keep their own deadline).
/// _callback(_r), _r = SteamUgcCreateItemResult {result, published_file_id, legal_agreement_required}.
function tcc_steam_ugc_create_item(_app_id, _file_type, _callback, _owner = noone) {
    if (!tcc_steam_ready() || !is_callable(_callback) || !is_numeric(_file_type)) return false;
    var _app = __tcc_steam_ugc_app_id(_app_id);
    if (_app <= 0) return false;
    if (!__tcc_steam_slot_take("ugc_create", _callback, _owner, TCC_STEAM_PUBLISH_SLOT_TTL_MS)) return false;     // taken last: an early return after it would block the slot
    steam_ugc_create_item(_app, _file_type, tcc_steam_relay);
    return true;
}
function tcc_steam_ugc_start_item_update(_app_id, _file_id) {
    if (!tcc_steam_ready() || !tcc_steam_id_valid(_file_id)) return -1;
    var _app = __tcc_steam_ugc_app_id(_app_id);
    if (_app <= 0) return -1;
    var _h = steam_ugc_start_item_update(_app, _file_id);
    return tcc_steam_ugc_handle_valid(_h) ? _h : -1;
}
function tcc_steam_ugc_set_item_title(_h, _text) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h)) return false;
    return __tcc_steam_bool(steam_ugc_set_item_title(_h, string(_text)));
}
function tcc_steam_ugc_set_item_description(_h, _text) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h)) return false;
    return __tcc_steam_bool(steam_ugc_set_item_description(_h, string(_text)));
}
/// _visibility = SteamRemoteStoragePublishedFileVisibility.*
function tcc_steam_ugc_set_item_visibility(_h, _visibility) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h) || !is_numeric(_visibility)) return false;
    return __tcc_steam_bool(steam_ugc_set_item_visibility(_h, _visibility));
}
/// _tags = array of strings.
function tcc_steam_ugc_set_item_tags(_h, _tags) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h) || !is_array(_tags)) return false;
    var _strings = [];
    for (var _i = 0; _i < array_length(_tags); ++_i) array_push(_strings, string(_tags[_i]));
    return __tcc_steam_bool(steam_ugc_set_item_tags(_h, _strings));
}
function tcc_steam_ugc_set_item_preview(_h, _path) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h)) return false;
    var _file = __tcc_steam_ugc_path(_path);
    if (!file_exists(_file)) return false;                        // 2.x returned false for a missing file
    return __tcc_steam_bool(steam_ugc_set_item_preview(_h, _file));
}
function tcc_steam_ugc_set_item_content(_h, _path) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h)) return false;
    var _folder = __tcc_steam_ugc_path(_path);
    if (!directory_exists(_folder)) return false;                 // 2.x returned false for a missing folder
    return __tcc_steam_bool(steam_ugc_set_item_content(_h, _folder));
}
/// Returns true = attempted. _callback(_r), _r = SteamUgcSubmitItemUpdateResult {result, legal_agreement_required}.
function tcc_steam_ugc_submit_item_update(_h, _note, _callback, _owner = noone) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_h) || !is_callable(_callback)) return false;
    if (!__tcc_steam_slot_take("ugc_submit", _callback, _owner, TCC_STEAM_PUBLISH_SLOT_TTL_MS)) return false;
    steam_ugc_submit_item_update(_h, string(_note), tcc_steam_relay);
    return true;
}

// ---- subscribe / unsubscribe ---------------------------------------------------------------------------------------------
/// Shared by EVERY subscribe site: keeps both jobs of the old broadcast event. Context-free (it runs from the relay).
function __tcc_steam_ugc_on_subscribed(_r) {
    if (!is_struct(_r)) return;
    var _file = _r.published_file_id;
    var _failed = (_r.result != SteamApiResult.Ok);
    // a private or removed item can never download: stop the Workshop ER loading screen waiting for it
    if (_failed && instance_exists(o_workshopERloading)) {
        with (o_workshopERloading) {
            if (state == "waiting" && target_file_id == _file) {
                state = "idle";
                global.workshopER_loading = false;
                workshopER_skip_level();
            }
        }
    }
    // a private or removed item fails that online follow at once (only while the net layer is up)
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
function tcc_steam_ugc_subscribe_item(_file_id) {
    if (!tcc_steam_ready() || !tcc_steam_id_valid(_file_id)) return false;
    steam_ugc_subscribe_item(_file_id, tcc_steam_relay);
    return true;
}
function tcc_steam_ugc_unsubscribe_item(_file_id) {
    if (!tcc_steam_ready() || !tcc_steam_id_valid(_file_id)) return false;
    steam_ugc_unsubscribe_item(_file_id, tcc_steam_relay);
    return true;
}

// ---- queries: registry keyed by query handle -------------------------------------------------------------------------------
/// Routed from the relay. Reads the items, always releases the query handle, then delivers (_ok, _items, _completed) to the caller.
function __tcc_steam_ugc_on_query_done(_completed) {
    if (!is_struct(_completed)) return;
    var _handle = _completed.query_handle;
    var _entry = __tcc_steam_keyed_take("ugc_query", __tcc_steam_key(_handle));
    var _items = [];
    var _ok = (_completed.result == SteamApiResult.Ok);
    var _live = tcc_steam_ready() && tcc_steam_ugc_handle_valid(_handle);
    if (!_live) _ok = false;                                         // the items cannot be read: report failure
    if (_ok) {
        for (var _i = 0; _i < _completed.num_results_returned; ++_i) {
            var _item = steam_ugc_get_query_ugc_result(_handle, _i);
            if (is_struct(_item) && _item.result == SteamApiResult.Ok) array_push(_items, _item);
        }
    }
    if (_live) steam_ugc_release_query_ugc_request(_handle);
    __tcc_steam_deliver(_entry, [_ok, _items, _completed]);         // unknown / stale handle: nothing to deliver
}
/// Returns true = attempted. The handle is released here if nothing was sent; afterwards the wrapper releases it on every path.
/// _callback(_ok, _items, _completed): _items = array of SteamUgcQueryResult (only entries whose result is Ok).
function tcc_steam_ugc_send_query(_qh, _callback, _owner = noone) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_qh)) return false;
    if (!is_callable(_callback)) { steam_ugc_release_query_ugc_request(_qh); return false; }
    __tcc_steam_keyed_put("ugc_query", __tcc_steam_key(_qh), _callback, _owner);
    steam_ugc_send_query_ugc_request(_qh, tcc_steam_relay);
    return true;
}
function tcc_steam_ugc_create_query_all(_query_type, _match_type, _page) {
    if (!tcc_steam_ready() || !is_numeric(_query_type) || !is_numeric(_match_type) || !is_numeric(_page)) return -1;
    var _app = __tcc_steam_ugc_app_id(0);
    if (_app <= 0) return -1;
    var _h = steam_ugc_create_query_all_ugc_request(_query_type, _match_type, 0, _app, _page);
    return tcc_steam_ugc_handle_valid(_h) ? _h : -1;
}
function tcc_steam_ugc_query_set_search_text(_qh, _text) {
    if (!tcc_steam_ready() || !tcc_steam_ugc_handle_valid(_qh)) return false;
    return __tcc_steam_bool(steam_ugc_set_search_text(_qh, string(_text)));
}
/// _file_ids: one id or an array. One query per STEAM_UGC_NUM_RESULTS_PER_PAGE (50) ids; _callback(_ok, _items, _completed) fires once PER
/// CHUNK, so callers match by _item.published_file_id. Ids that are not numeric or <= 0 are dropped (3.0 raises a fatal error on them).
function tcc_steam_ugc_request_item_details(_file_ids, _max_age_seconds, _callback, _owner = noone) {
    if (!tcc_steam_ready() || !is_callable(_callback)) return false;
    var _src = is_array(_file_ids) ? _file_ids : [_file_ids];
    var _ids = [];
    for (var _i = 0; _i < array_length(_src); ++_i) if (tcc_steam_id_valid(_src[_i])) array_push(_ids, __tcc_steam_id(_src[_i]));
    var _age = (is_numeric(_max_age_seconds) && _max_age_seconds > 0) ? floor(_max_age_seconds) : 0;
    var _sent = 0;
    for (var _from = 0; _from < array_length(_ids); _from += STEAM_UGC_NUM_RESULTS_PER_PAGE) {
        var _chunk = array_create(min(STEAM_UGC_NUM_RESULTS_PER_PAGE, array_length(_ids) - _from));
        array_copy(_chunk, 0, _ids, _from, array_length(_chunk));
        var _qh = steam_ugc_create_query_ugc_details_request(_chunk);
        if (!tcc_steam_ugc_handle_valid(_qh)) continue;
        steam_ugc_set_allow_cached_response(_qh, _age);       // return value ignored: documented for user and all-UGC handles only
        if (tcc_steam_ugc_send_query(_qh, _callback, _owner)) _sent++;
    }
    return _sent > 0;
}

// ---- self-check ---------------------------------------------------------------------------------------------------------
// Called once from scr_port_selfcheck() in the Check configuration, which has no Steam binary: the relay, the registries and the pure
// helpers are plain GML. It runs against a private copy of the registry state and of the net mock seam and restores both afterwards,
// so nothing it does leaks into the rest of the run. It never calls a raw Steam function. Failures throw (scr_port_assert).
function __tcc_steam_sc_count(_label) {
    var _sc = __tcc_steam_state().sc;
    _sc[$ _label] = (variable_struct_exists(_sc, _label) ? _sc[$ _label] : 0) + 1;
}
function __tcc_steam_sc_get(_label) {
    var _sc = __tcc_steam_state().sc;
    return variable_struct_exists(_sc, _label) ? _sc[$ _label] : 0;
}
// Named script functions, like every real listener: they run with a shared empty self and touch only globals.
function __tcc_steam_sc_listener(_r)  { __tcc_steam_sc_count("L:" + instanceof(_r)); }
function __tcc_steam_sc_entry(_r)     { __tcc_steam_sc_count("E:" + instanceof(_r)); }
function __tcc_steam_sc_throwing(_r)  { throw "selfcheck: deliberate listener failure"; }
function __tcc_steam_sc_rows(_rows)   { __tcc_steam_sc_count(is_undefined(_rows) ? "rows:undefined" : "rows:array"); }
function __tcc_steam_sc_query(_ok, _items, _completed) { __tcc_steam_sc_count("query:" + (_ok ? "ok" : "fail") + ":" + string(array_length(_items))); }
function __tcc_steam_sc_unknown() constructor { }
/// Emulates the dispatcher: the relay is called with self = a shared empty struct.
function __tcc_steam_sc_deliver(_r) {
    with ({}) method_call(tcc_steam_relay, [_r]);
}

/// S-1: without Steam (Check, QA, iOS, Android, Mac App Store) every wrapper falls back and none reaches a raw call.
function __tcc_steam_sc_offline() {
    if (platform_steam()) return;
    var _me = tcc_steam_get_user_steam_id();
    scr_port_assert(!tcc_steam_ready() && !tcc_steam_initialised() && !tcc_steam_init(), "offline: not ready");
    scr_port_assert(_me == 0 && is_int64(_me), "offline: own id is int64 zero");
    scr_port_assert(tcc_steam_get_app_id() != 1749610, "offline: no app id");
    scr_port_assert(tcc_steam_get_user_avatar(1, TCC_STEAM_AVATAR_MEDIUM) == TCC_AVATAR_NONE, "offline: avatar none");
    scr_port_assert(tcc_steam_get_user_persona_name_sync(1) == "", "offline: persona name empty");
    scr_port_assert(!tcc_steam_lobby_create(SteamMatchmakingLobbyType.FriendsOnly, 4, function(_r) {}, noone), "offline: lobby create refused");
    scr_port_assert(!tcc_steam_download_scores("x", 1, 10, function(_r) {}), "offline: leaderboard download refused");
    scr_port_assert(!tcc_steam_upload_score("x", 5), "offline: leaderboard upload refused");
    scr_port_assert(tcc_steam_inventory_get_all_items() == -1, "offline: inventory handle");
    scr_port_assert(is_undefined(tcc_steam_inventory_result_get_items(1)), "offline: inventory items undefined");
    scr_port_assert(tcc_steam_inventory_exchange_items([], [], function(_r) {}) == -1, "offline: exchange refused");
    scr_port_assert(!tcc_steam_update(), "offline: pump idle");
    scr_port_assert(!tcc_steam_register_callbacks(), "offline: registration refused");
    scr_port_assert(!tcc_steam_get_number_of_current_players(), "offline: player count refused");
    scr_port_assert(!tcc_steam_get_achievement("x") && !tcc_steam_set_achievement("x"), "offline: achievements");
    // persistent slots: no listener is installed and no native slot is touched
    scr_port_assert(!tcc_steam_set_lobby_callbacks(__tcc_steam_sc_listener, __tcc_steam_sc_listener), "offline: lobby callbacks refused");
    scr_port_assert(!tcc_steam_net_set_session_request_callback(__tcc_steam_sc_listener) && !tcc_steam_net_set_session_failed_callback(__tcc_steam_sc_listener), "offline: session callbacks refused");
    scr_port_assert(!tcc_steam_net_clear_session_callbacks(), "offline: session callbacks clear");
    scr_port_assert(!tcc_steam_inventory_set_callback_result_ready(__tcc_steam_sc_listener) && !tcc_steam_inventory_clear_callback_result_ready(), "offline: inventory callback slot");
    // networking, lobby reads, UGC
    var _buffer = buffer_create(16, buffer_fixed, 1);
    var _sent = tcc_steam_net_packet_send(int64(5), _buffer, 8);
    var _received = tcc_steam_net_packet_receive(_buffer);
    buffer_delete(_buffer);
    scr_port_assert(!_sent && tcc_steam_net_last_send_result() == SteamApiResult.None, "offline: send refused before the native");
    scr_port_assert(is_undefined(_received), "offline: receive empty");
    scr_port_assert(tcc_steam_lobby_get_owner_id() == 0 && tcc_steam_lobby_get_member_count() == 0 && tcc_steam_lobby_get_member_id(0) == 0, "offline: lobby reads");
    scr_port_assert(!tcc_steam_lobby_set_data("k", "v", 5) && tcc_steam_lobby_get_data("k", 5) == "", "offline: lobby data");
    scr_port_assert(tcc_steam_ugc_create_query_all(0, 0, 1) == -1 && tcc_steam_ugc_start_item_update(1, 5) == -1, "offline: ugc handles");
    scr_port_assert(!tcc_steam_ugc_create_item(1, 0, __tcc_steam_sc_entry) && !tcc_steam_ugc_send_query(5, __tcc_steam_sc_query) && !tcc_steam_ugc_subscribe_item(5), "offline: ugc calls");
    scr_port_assert(!tcc_steam_ugc_request_item_details([1, 2], 0, __tcc_steam_sc_query) && tcc_steam_ugc_num_subscribed_items() == false, "offline: ugc details");
    scr_port_assert(!tcc_steam_ugc_handle_valid(-1) && !tcc_steam_ugc_handle_valid(0) && !tcc_steam_ugc_handle_valid(undefined) && !tcc_steam_ugc_handle_valid("5") && tcc_steam_ugc_handle_valid(5), "ugc handle test");
}

/// S-2 and S-3: relay routing, consumption rules, error isolation.
function __tcc_steam_sc_relay() {
    var _st = __tcc_steam_state();
    // persistent listener: reaches the callback every time
    __tcc_steam_listener_set("lobby_created", __tcc_steam_sc_listener, noone);
    var _created = new SteamMatchmakingLobbyCreated();
    _created.result = SteamApiResult.Ok;
    __tcc_steam_sc_deliver(_created);
    __tcc_steam_sc_deliver(_created);
    scr_port_assert(__tcc_steam_sc_get("L:SteamMatchmakingLobbyCreated") == 2, "relay: lobby_created listener is not consumed");
    __tcc_steam_listener_set("lobby_entered", __tcc_steam_sc_listener, noone);
    __tcc_steam_listener_set("lobby_chat_update", __tcc_steam_sc_listener, noone);
    __tcc_steam_listener_set("lobby_join_requested", __tcc_steam_sc_listener, noone);
    __tcc_steam_sc_deliver(new SteamMatchmakingLobbyEnter());
    __tcc_steam_sc_deliver(new SteamMatchmakingLobbyChatUpdate());
    __tcc_steam_sc_deliver(new SteamFriendsGameLobbyJoinRequested());
    scr_port_assert(__tcc_steam_sc_get("L:SteamMatchmakingLobbyEnter") == 1 && __tcc_steam_sc_get("L:SteamMatchmakingLobbyChatUpdate") == 1
        && __tcc_steam_sc_get("L:SteamFriendsGameLobbyJoinRequested") == 1, "relay: lobby listeners routed by constructor name");

    // inventory: the keyed entry of that handle first (once), then the owner's listener
    __tcc_steam_listener_set("inv_result_ready", __tcc_steam_sc_listener, noone);
    __tcc_steam_keyed_put("inv", __tcc_steam_key(7), __tcc_steam_sc_entry, noone);
    var _inv = new SteamInventoryResultReady();
    _inv.result_handle = 7;
    _inv.result = SteamApiResult.Ok;
    __tcc_steam_sc_deliver(_inv);
    scr_port_assert(__tcc_steam_sc_get("E:SteamInventoryResultReady") == 1 && __tcc_steam_sc_get("L:SteamInventoryResultReady") == 0, "relay: inventory keyed entry first");
    __tcc_steam_sc_deliver(_inv);
    scr_port_assert(__tcc_steam_sc_get("E:SteamInventoryResultReady") == 1 && __tcc_steam_sc_get("L:SteamInventoryResultReady") == 1, "relay: inventory second delivery falls through to the listener");
    __tcc_steam_keyed_put("inv", __tcc_steam_key(int64(8)), __tcc_steam_sc_entry, noone);     // int64 handle and real handle share one key
    _inv.result_handle = 8;
    __tcc_steam_sc_deliver(_inv);
    scr_port_assert(__tcc_steam_sc_get("E:SteamInventoryResultReady") == 2, "relay: handle keys are type independent");

    // single-flight slots: consumed by the first answer, a second request while pending is refused
    scr_port_assert(__tcc_steam_slot_take("ugc_create", __tcc_steam_sc_entry, noone), "relay: slot free");
    scr_port_assert(!__tcc_steam_slot_take("ugc_create", __tcc_steam_sc_entry, noone), "relay: slot busy while pending");
    var _item = new SteamUgcCreateItemResult();
    _item.result = SteamApiResult.Ok;
    __tcc_steam_sc_deliver(_item);
    __tcc_steam_sc_deliver(_item);
    scr_port_assert(__tcc_steam_sc_get("E:SteamUgcCreateItemResult") == 1, "relay: ugc_create slot consumed once");
    scr_port_assert(__tcc_steam_slot_take("ugc_create", __tcc_steam_sc_entry, noone), "relay: slot free again after the answer");
    __tcc_steam_slot_release("ugc_create");
    __tcc_steam_slot_take("ugc_submit", __tcc_steam_sc_entry, noone);
    __tcc_steam_sc_deliver(new SteamUgcSubmitItemUpdateResult());
    __tcc_steam_slot_take("inv_prices", __tcc_steam_sc_entry, noone);
    __tcc_steam_sc_deliver(new SteamInventoryRequestPricesResult());
    scr_port_assert(__tcc_steam_sc_get("E:SteamUgcSubmitItemUpdateResult") == 1 && __tcc_steam_sc_get("E:SteamInventoryRequestPricesResult") == 1, "relay: submit and prices slots");
    __tcc_steam_slot_take("players", undefined, noone);
    var _players = new SteamUserStatsNumberOfCurrentPlayersResult();
    _players.success = false;                                  // true would write global.playercount
    __tcc_steam_sc_deliver(_players);
    scr_port_assert(__tcc_steam_slot_take("players", undefined, noone), "relay: players slot released by the answer");
    __tcc_steam_slot_release("players");

    // UGC: subscribe and unsubscribe are routed (no unrouted count); a finished query reaches its keyed entry and the entry is consumed
    var _unrouted = _st.unrouted;
    var _sub = new SteamUgcSubscribeItemResult();
    _sub.result = SteamApiResult.Ok;
    _sub.published_file_id = int64(987654321);
    __tcc_steam_sc_deliver(_sub);
    __tcc_steam_sc_deliver(new SteamUgcUnsubscribeItemResult());
    scr_port_assert(_st.unrouted == _unrouted, "relay: subscribe and unsubscribe are routed");
    __tcc_steam_keyed_put("ugc_query", __tcc_steam_key(STEAM_UGC_QUERY_HANDLE_INVALID), __tcc_steam_sc_query, noone);
    var _done = new SteamUgcQueryCompleted();                  // the invalid handle keeps this path free of raw calls
    _done.query_handle = STEAM_UGC_QUERY_HANDLE_INVALID;
    _done.result = SteamApiResult.Fail;
    _done.num_results_returned = 0;
    __tcc_steam_sc_deliver(_done);
    __tcc_steam_sc_deliver(_done);
    scr_port_assert(__tcc_steam_sc_get("query:fail:0") == 1, "relay: query callback gets (ok, items, completed) once");

    // CA-7: the two networking structs; persistent, and delivered with a struct as self
    __tcc_steam_listener_set("net_session_request", __tcc_steam_sc_listener, noone);
    __tcc_steam_listener_set("net_session_failed", __tcc_steam_sc_listener, noone);
    var _request = new SteamNetworkingMessagesSessionRequest();
    _request.steam_id_remote = int64("76561198012345679");
    __tcc_steam_sc_deliver(_request);
    __tcc_steam_sc_deliver(_request);
    var _failed = new SteamNetworkingMessagesSessionFailed();
    _failed.steam_id_remote = int64("76561198012345679");
    _failed.debug_msg = "selfcheck";
    __tcc_steam_sc_deliver(_failed);
    scr_port_assert(__tcc_steam_sc_get("L:SteamNetworkingMessagesSessionRequest") == 2, "relay: session request listener is not consumed");
    scr_port_assert(__tcc_steam_sc_get("L:SteamNetworkingMessagesSessionFailed") == 1, "relay: session failed listener");

    // unrouted: a plain struct, an unknown constructor, a non-struct
    _unrouted = _st.unrouted;
    __tcc_steam_sc_deliver({});
    __tcc_steam_sc_deliver(new __tcc_steam_sc_unknown());
    __tcc_steam_sc_deliver(undefined);
    __tcc_steam_sc_deliver(5);
    scr_port_assert(_st.unrouted == _unrouted + 4, "relay: unknown arguments are counted, not thrown");

    // S-3: a throwing listener never escapes the relay, is counted, and the next delivery works
    var _errors = _st.relay_errors;
    __tcc_steam_listener_set("lobby_created", __tcc_steam_sc_throwing, noone);
    __tcc_steam_sc_deliver(_created);
    scr_port_assert(_st.relay_errors == _errors + 1, "isolation: a throwing listener is counted");
    __tcc_steam_listener_set("lobby_created", __tcc_steam_sc_listener, noone);
    var _hits = __tcc_steam_sc_get("L:SteamMatchmakingLobbyCreated");
    __tcc_steam_sc_deliver(_created);
    scr_port_assert(__tcc_steam_sc_get("L:SteamMatchmakingLobbyCreated") == _hits + 1 && _st.relay_errors == _errors + 1, "isolation: delivery continues after a failure");
    __tcc_steam_listener_clear("lobby_created");
    __tcc_steam_sc_deliver(_created);
    scr_port_assert(__tcc_steam_sc_get("L:SteamMatchmakingLobbyCreated") == _hits + 1, "relay: a cleared listener is not called");
}

/// S-4: an entry whose owner no longer exists is dropped without calling the callback.
function __tcc_steam_sc_owner() {
    scr_port_assert(__tcc_steam_owner_alive(noone) && __tcc_steam_owner_alive(undefined), "owner: none always alive");
    scr_port_assert(!__tcc_steam_owner_alive(987654321), "owner: unknown instance id is dead");
    var _dead = instance_create_depth(0, 0, 0, o_CERSettings);
    instance_destroy(_dead);
    if (!instance_exists(_dead)) {
        scr_port_assert(!__tcc_steam_owner_alive(_dead), "owner: destroyed instance is dead");
        var _enter = new SteamMatchmakingLobbyEnter();
        var _before = __tcc_steam_sc_get("L:SteamMatchmakingLobbyEnter");
        scr_port_assert(!__tcc_steam_deliver({ cb: __tcc_steam_sc_listener, owner: _dead }, [_enter]), "owner: dead owner is not called");
        __tcc_steam_listener_set("lobby_entered", __tcc_steam_sc_listener, _dead);
        __tcc_steam_sc_deliver(_enter);
        scr_port_assert(__tcc_steam_sc_get("L:SteamMatchmakingLobbyEnter") == _before, "owner: listener of a destroyed owner is dropped");
    } else {
        show_debug_message("[STEAM] selfcheck: S-4 destroyed-owner case skipped (instance still exists right after instance_destroy)");
    }
    var _alive = instance_create_depth(0, 0, 0, o_CERSettings);
    __tcc_steam_listener_set("lobby_entered", __tcc_steam_sc_listener, _alive);
    var _count = __tcc_steam_sc_get("L:SteamMatchmakingLobbyEnter");
    __tcc_steam_sc_deliver(new SteamMatchmakingLobbyEnter());
    var _called = (__tcc_steam_sc_get("L:SteamMatchmakingLobbyEnter") == _count + 1);
    var _alive_ok = __tcc_steam_owner_alive(_alive);
    instance_destroy(_alive);
    scr_port_assert(_alive_ok && _called, "owner: a live owner is called");
}

/// S-5: the leaderboard queue fails every waiting job exactly once when Steam is lost (no Steam call is made).
function __tcc_steam_sc_leaderboards() {
    var _lb = __tcc_steam_state().lb;
    var _waiting = { kind: "download", board: "x", cb: __tcc_steam_sc_rows, owner: noone, step: "", handle: 0, deadline: 0 };
    array_push(_lb.queue, _waiting);
    __tcc_steam_lb_fail_all();
    scr_port_assert(__tcc_steam_sc_get("rows:undefined") == 1 && array_length(_lb.queue) == 0, "leaderboard: queued download fails once");
    _lb.cur = { kind: "download", board: "y", cb: __tcc_steam_sc_rows, owner: noone, step: "find", handle: 0, deadline: current_time + 10000 };
    array_push(_lb.queue, { kind: "download", board: "z", cb: __tcc_steam_sc_rows, owner: noone, step: "", handle: 0, deadline: 0 });
    array_push(_lb.queue, { kind: "upload", board: "z", value: 1, how: SteamLeaderboardUploadScoreMethod.KeepBest, step: "", handle: 0, deadline: 0 });
    __tcc_steam_lb_fail_all();
    scr_port_assert(__tcc_steam_sc_get("rows:undefined") == 3 && !is_struct(_lb.cur) && array_length(_lb.queue) == 0, "leaderboard: running and queued jobs fail once each, uploads silently");
    __tcc_steam_lb_fail_all();
    scr_port_assert(__tcc_steam_sc_get("rows:undefined") == 3, "leaderboard: nothing left to fail");
    var _a = { kind: "download", board: "a", cb: __tcc_steam_sc_rows, owner: id, step: "", handle: 0, deadline: 0 };
    var _b = { kind: "download", board: "b", cb: __tcc_steam_sc_rows, owner: noone, step: "", handle: 0, deadline: 0 };
    var _c = { kind: "upload", board: "a", value: 1, how: SteamLeaderboardUploadScoreMethod.KeepBest, step: "", handle: 0, deadline: 0 };
    array_push(_lb.queue, _a, _b, _c);
    __tcc_steam_lb_drop_queued_downloads(noone);
    scr_port_assert(array_length(_lb.queue) == 3, "leaderboard: owner-less downloads are never superseded");
    __tcc_steam_lb_drop_queued_downloads(id);
    scr_port_assert(array_length(_lb.queue) == 2 && _lb.queue[0] == _b && _lb.queue[1] == _c, "leaderboard: a newer download replaces the owner's queued ones only");
    _lb.queue = [];
    __tcc_steam_grow_return_buffer();
    scr_port_assert(buffer_get_size(__ext_core_get_ret_buffer()) >= TCC_STEAM_RETURN_BUFFER_BYTES, "return buffer: grown past the 8192-byte default");
}

/// S-6: ids stay int64.
function __tcc_steam_sc_ids() {
    var _big = int64("76561198000000000");
    var _odd = int64("76561198012345679");                      // not representable as a double: proves the string path keeps all 64 bits
    scr_port_assert(__tcc_steam_id(undefined) == 0 && __tcc_steam_id("x") == 0 && __tcc_steam_id(NaN) == 0 && __tcc_steam_id(infinity) == 0, "ids: junk becomes zero");
    scr_port_assert(is_int64(__tcc_steam_id(undefined)) && is_int64(__tcc_steam_id(5.0)), "ids: always int64");
    scr_port_assert(__tcc_steam_id(_big) == _big && __tcc_steam_id(_odd) == _odd && string(__tcc_steam_id(_odd)) == "76561198012345679", "ids: int64 round trip");
    scr_port_assert(net_parse_id(string(_big)) == _big && net_parse_id(string(_odd)) == _odd, "ids: string round trip through net_parse_id");
    scr_port_assert(!tcc_steam_id_valid(0) && !tcc_steam_id_valid(-1) && !tcc_steam_id_valid(undefined) && !tcc_steam_id_valid("5"), "ids: invalid values");
    scr_port_assert(tcc_steam_id_valid(1) && tcc_steam_id_valid(_big) && tcc_steam_id_valid(_odd), "ids: valid values");
    scr_port_assert(__tcc_steam_key(7) == "7" && __tcc_steam_key(int64(7)) == "7" && __tcc_steam_key(_odd) == "76561198012345679", "ids: registry keys");
    scr_port_assert(__tcc_steam_key_id("76561198012345679") == _odd && __tcc_steam_key_id("nope") == 0, "ids: key parsing");
}

/// Pure helpers and registry housekeeping.
function __tcc_steam_sc_helpers() {
    var _msg = new SteamNetworkingMessage();
    var _dropped = "output buffer exhausted: no room";
    scr_port_assert(tcc_steam_net_classify([_msg], "") == _msg, "classify: a message is returned");
    scr_port_assert(tcc_steam_net_classify([], _dropped) == TCC_NET_RX_DROPPED, "classify: exhausted buffer is a drop");
    scr_port_assert(is_undefined(tcc_steam_net_classify([], "")) && is_undefined(tcc_steam_net_classify([], undefined)), "classify: an empty queue is undefined");
    scr_port_assert(is_undefined(tcc_steam_net_classify(undefined, _dropped)) && is_undefined(tcc_steam_net_classify(5, "")), "classify: a non-array is undefined");
    var _table = {};
    scr_port_assert(__tcc_steam_throttle(_table, "a", 1000000) && !__tcc_steam_throttle(_table, "a", 1000000) && __tcc_steam_throttle(_table, "b", 1000000), "throttle: one request per interval and key");
    scr_port_assert(__tcc_steam_bool(1) && !__tcc_steam_bool(0) && __tcc_steam_bool(true) && !__tcc_steam_bool(undefined) && !__tcc_steam_bool("x"), "bool normalisation");
    scr_port_assert(!__tcc_steam_buffer_ok(undefined) && !__tcc_steam_buffer_ok("x") && !__tcc_steam_buffer_ok({}) && !__tcc_steam_buffer_ok([]) && !__tcc_steam_buffer_ok(-1), "buffer test: junk refused");
    var _buffer = buffer_create(4, buffer_fixed, 1);
    var _buffer_ok = __tcc_steam_buffer_ok(_buffer);
    buffer_delete(_buffer);
    scr_port_assert(_buffer_ok, "buffer test: a live buffer is accepted");
    // keyed entries are consumed by the first take
    __tcc_steam_keyed_put("selfcheck", "1", __tcc_steam_sc_entry, noone);
    scr_port_assert(is_struct(__tcc_steam_keyed_take("selfcheck", "1")) && is_undefined(__tcc_steam_keyed_take("selfcheck", "1")) && is_undefined(__tcc_steam_keyed_take("none", "1")), "keyed: consumed once");
    // an expired slot can be taken again, and the sweep drops expired slots and keyed entries
    scr_port_assert(__tcc_steam_slot_take("selfcheck", undefined, noone, -1) && __tcc_steam_slot_take("selfcheck", undefined, noone, 60000) && !__tcc_steam_slot_take("selfcheck", undefined, noone, 60000), "slot: expiry");
    var _st = __tcc_steam_state();
    _st.slots[$ "selfcheck"] = { cb: undefined, owner: noone, expires: current_time - 1 };
    __tcc_steam_keyed_put("selfcheck", "2", __tcc_steam_sc_entry, noone);
    _st.keyed[$ "selfcheck"][$ "2"].expires = current_time - 1;
    __tcc_steam_sweep();
    scr_port_assert(!variable_struct_exists(_st.slots, "selfcheck") && is_undefined(__tcc_steam_keyed_take("selfcheck", "2")), "sweep: expired entries are dropped");
    // losing Steam forgets every pending request
    __tcc_steam_slot_take("selfcheck", undefined, noone, 60000);
    __tcc_steam_keyed_put("selfcheck", "3", __tcc_steam_sc_entry, noone);
    __tcc_steam_on_lost();
    scr_port_assert(variable_struct_names_count(_st.slots) == 0 && variable_struct_names_count(_st.keyed) == 0, "lost: pending requests are forgotten");
}

/// The mock seam (Check only): the six net wrappers and the three lobby reads consult it first.
function __tcc_steam_sc_seam() {
    scr_port_assert(is_undefined(tcc_steam_net_mock()), "seam: inert without a mock");
    global.tcc_net_mock = {
        sent: [], err_text: "",
        send: function(_id, _buffer, _flags, _channel, _offset, _count) { array_push(sent, [_id, _flags, _channel, _offset, _count]); return SteamApiResult.Ok; },
        receive: function(_channel, _buffer, _count) { return []; },
        last_error: function() { return err_text; },
        accept: function(_id) { return true; },
        close: function(_id) { return true; },
        lobby_owner_id: function() { return 5; },
        lobby_member_count: function() { return 2; },
        lobby_member_id: function(_index) { return 7; },
        set_session_request_callback: function(_callback) { return true; },
        set_session_failed_callback: function(_callback) { return true; }
    };
    var _mock = tcc_steam_net_mock();
    scr_port_assert(is_struct(_mock), "seam: a mock is returned in the Check configuration");
    var _buffer = buffer_create(16, buffer_fixed, 1);
    var _id = int64("76561198012345679");
    var _ok = tcc_steam_net_packet_send(_id, _buffer, 8);
    var _after_ok = tcc_steam_net_last_send_result();
    var _ok_unreliable = tcc_steam_net_packet_send(_id, _buffer, 100, TCC_NET_SEND_UNRELIABLE);
    var _zero = tcc_steam_net_packet_send(_id, _buffer, 0);
    var _after_zero = tcc_steam_net_last_send_result();
    var _bad_id = tcc_steam_net_packet_send(0, _buffer, 8);
    var _bad_buffer = tcc_steam_net_packet_send(_id, "x", 8);
    _mock.err_text = "output buffer exhausted";
    var _drop = tcc_steam_net_packet_receive(_buffer);
    _mock.err_text = "";
    var _empty = tcc_steam_net_packet_receive(_buffer);
    var _no_buffer = tcc_steam_net_packet_receive(undefined);
    buffer_delete(_buffer);
    var _sent = _mock.sent;
    scr_port_assert(_ok && _after_ok == SteamApiResult.Ok && array_length(_sent) == 2, "seam: send reaches the mock and reports Ok");
    scr_port_assert(_sent[0][0] == _id && _sent[0][1] == TCC_NET_SEND_RELIABLE && _sent[0][2] == TCC_NET_CHANNEL && _sent[0][3] == 0 && _sent[0][4] == 8, "seam: reliable by default, game channel, offset 0, exact count");
    scr_port_assert(_ok_unreliable && _sent[1][1] == TCC_NET_SEND_UNRELIABLE && _sent[1][4] == 16, "seam: explicit flags kept, count clamped to the buffer");
    scr_port_assert(!_zero && _after_zero == SteamApiResult.InvalidParam && !_bad_id && !_bad_buffer && array_length(_sent) == 2, "seam: refused arguments never reach the native");
    scr_port_assert(_drop == TCC_NET_RX_DROPPED && is_undefined(_empty) && is_undefined(_no_buffer), "seam: receive classification");
    scr_port_assert(tcc_steam_net_accept_session(_id) && tcc_steam_net_close_p2p_session(_id) && !tcc_steam_net_accept_session(0), "seam: accept and close");
    scr_port_assert(tcc_steam_net_set_session_request_callback(__tcc_steam_sc_listener) && tcc_steam_net_set_session_failed_callback(__tcc_steam_sc_listener), "seam: session callbacks go to the mock");
    scr_port_assert(tcc_steam_lobby_get_owner_id() == 5 && is_int64(tcc_steam_lobby_get_owner_id()) && tcc_steam_lobby_get_member_count() == 2
        && tcc_steam_lobby_get_member_id(0) == 7 && is_int64(tcc_steam_lobby_get_member_id(0)), "seam: lobby reads");
    global.tcc_net_mock = undefined;
    scr_port_assert(is_undefined(tcc_steam_net_mock()), "seam: removed again");
}

function __tcc_steam_selfcheck_run() {
    var _st = __tcc_steam_state();
    _st.sc = {};
    __tcc_steam_sc_offline();
    __tcc_steam_sc_relay();
    __tcc_steam_sc_owner();
    __tcc_steam_sc_leaderboards();
    __tcc_steam_sc_ids();
    __tcc_steam_sc_helpers();
    if (TCC_SELF_CHECK) __tcc_steam_sc_seam();
}

/// Runs the wrapper-layer assertions. Works on a private registry state and mock seam; both are restored, also when an assertion throws.
function tcc_steam_selfcheck() {
    var _saved_state = variable_global_exists("tcc_steam") ? global.tcc_steam : undefined;
    var _saved_mock = variable_global_exists("tcc_net_mock") ? global.tcc_net_mock : undefined;
    global.tcc_steam = undefined;                       // __tcc_steam_state() re-creates a fresh state on the next call
    global.tcc_net_mock = undefined;
    var _failure = undefined;
    try { __tcc_steam_selfcheck_run(); }
    catch (_e) { _failure = _e; }
    global.tcc_steam = _saved_state;
    global.tcc_net_mock = _saved_mock;
    if (!is_undefined(_failure)) throw _failure;
    show_debug_message("TCC_STEAM_WRAPPER_SELF_CHECK_PASS");
    return true;
}
