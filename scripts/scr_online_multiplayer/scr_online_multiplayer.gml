// =============================================================================
// ONLINE MULTIPLAYER - Steam Networking System
// Uses Steam Lobbies + P2P for ghost player synchronization
// =============================================================================

// Packet type constants
#macro NET_PACKET_PLAYER_STATE		1
#macro NET_PACKET_PLAYER_JOIN		2
#macro NET_PACKET_PLAYER_LEAVE		3
#macro NET_PACKET_LEVEL_CHANGE		4
#macro NET_PACKET_HOST_CHANGE		5
#macro NET_PACKET_SKIN_INFO			6
#macro NET_PACKET_PING				7

// NET_MAX_PLAYERS is now controlled by global.netmaxplayers (settings slider)
#macro NET_SEND_RATE				1  // Send every frame (60 ticks/sec at 60fps)

// Only stable built-in cosmetic choices cross the wire. Runtime sprite handles,
// imported PNG paths and cache references always remain local to their owner.
function net_finite(_value) {
    // Native buffer_u8 reads produce an integer value, which is_real() does not
    // accept on every runner. All wire numbers are numeric, not strings/handles.
    return is_numeric(_value) && !is_nan(_value) && !is_infinity(_value);
}
function net_cosmetic_id(_value,_maximum) {
    return net_finite(_value) && floor(_value) == _value && _value >= 0 && _value <= _maximum ? _value : 0;
}
function net_builtin_skin_sprite(_skin,_color,_dead = false) {
    _skin = net_cosmetic_id(_skin,49);
    _color = net_cosmetic_id(_color,4);
    if (_dead) return _skin == 5 ? s_blockplayerdead : (_skin == 19 ? s_hexagonplayerdead : s_playerdead);
    static _skins = [
        [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite],
        [s_kaizoplayerred, s_kaizoplayeryellow, s_kaizoplayergreen, s_kaizoplayerblue, s_kaizoplayerwhite],
        [s_madplayerred, s_madplayeryellow, s_madplayergreen, s_madplayerblue, s_madplayerwhite],
        [s_blindplayerred, s_blindplayeryellow, s_blindplayergreen, s_blindplayerblue, s_blindplayerwhite],
        [s_sadplayerred, s_sadplayeryellow, s_sadplayergreen, s_sadplayerblue, s_sadplayerwhite],
        [s_blockplayerred, s_blockplayeryellow, s_blockplayergreen, s_blockplayerblue, s_blockplayerwhite],
        [s_hdplayerred, s_hdplayeryellow, s_hdplayergreen, s_hdplayerblue, s_hdplayerwhite],
        [s_rewardedplayerred, s_rewardedplayeryellow, s_rewardedplayergreen, s_rewardedplayerblue, s_rewardedplayerwhite],
        [s_angryplayerred, s_angryplayeryellow, s_angryplayergreen, s_angryplayerblue, s_angryplayerwhite],
        [s_coolplayerred, s_coolplayeryellow, s_coolplayergreen, s_coolplayerblue, s_coolplayerwhite],
        [s_thedarkknightskin, s_thedarkknightskin, s_thedarkknightskin, s_thedarkknightskin, s_thedarkknightskin],
        [s_richplayerred, s_richplayeryellow, s_richplayergreen, s_richplayerblue, s_richplayerwhite],
        [s_goldplayerskin, s_goldplayerskin, s_goldplayerskin, s_goldplayerskin, s_goldplayerskin],
        [s_frozenplayerred, s_frozenplayeryellow, s_frozenplayergreen, s_frozenplayerblue, s_frozenplayerwhite],
        [s_kindadeadplayerskin, s_kindadeadplayerskin, s_kindadeadplayerskin, s_kindadeadplayerskin, s_kindadeadplayerskin],
        [s_coronaplayerred, s_coronaplayeryellow, s_coronaplayergreen, s_coronaplayerblue, s_coronaplayerwhite],
        [s_canadianplayerred, s_canadianplayeryellow, s_canadianplayergreen, s_canadianplayerblue, s_canadianplayerwhite],
        [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite],
        [s_babyplayerred, s_babyplayeryellow, s_babyplayergreen, s_babyplayerblue, s_babyplayerwhite],
        [s_hexagonplayerred, s_hexagonplayeryellow, s_hexagonplayergreen, s_hexagonplayerblue, s_hexagonplayerwhite],
        [s_tuxedoplayerred, s_tuxedoplayeryellow, s_tuxedoplayergreen, s_tuxedoplayerblue, s_tuxedoplayerwhite],
        [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite],
        [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite],
        [s_forseneplayerskin, s_forseneplayerskin, s_forseneplayerskin, s_forseneplayerskin, s_forseneplayerskin],
        [s_redballplayerskin, s_redballplayerskin, s_redballplayerskin, s_redballplayerskin, s_redballplayerskin],
        [s_bomberplayerskin, s_bomberplayerskin, s_bomberplayerskin, s_bomberplayerskin, s_bomberplayerskin],
        [s_hitboxplayerskin, s_hitboxplayerskin, s_hitboxplayerskin, s_hitboxplayerskin, s_hitboxplayerskin],
        [s_metallicplayerskin, s_metallicplayerskin, s_metallicplayerskin, s_metallicplayerskin, s_metallicplayerskin],
        [s_monocleplayerskin, s_monocleplayerskin, s_monocleplayerskin, s_monocleplayerskin, s_monocleplayerskin],
        [s_japaneseplayerskin, s_japaneseplayerskin, s_japaneseplayerskin, s_japaneseplayerskin, s_japaneseplayerskin],
        [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite],
        [s_upsidedownplayerskin, s_upsidedownplayerskin, s_upsidedownplayerskin, s_upsidedownplayerskin, s_upsidedownplayerskin],
        [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite],
        [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite],
        [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite],
        [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite],
        [s_arrowplayerskin, s_arrowplayerskin, s_arrowplayerskin, s_arrowplayerskin, s_arrowplayerskin],
        [s_spikeplayerskin, s_spikeplayerskin, s_spikeplayerskin, s_spikeplayerskin, s_spikeplayerskin],
        [s_splitplayerskin, s_splitplayerskin, s_splitplayerskin, s_splitplayerskin, s_splitplayerskin],
        [s_pirateplayerskin, s_pirateplayerskin, s_pirateplayerskin, s_pirateplayerskin, s_pirateplayerskin],
        [s_scifiskinbase, s_scifiskinbase, s_scifiskinbase, s_scifiskinbase, s_scifiskinbase],
        [s_gordonplayerskin, s_gordonplayerskin, s_gordonplayerskin, s_gordonplayerskin, s_gordonplayerskin],
        [s_fancyplayerskin, s_fancyplayerskin, s_fancyplayerskin, s_fancyplayerskin, s_fancyplayerskin],
        [s_steamplayerskin, s_steamplayerskin, s_steamplayerskin, s_steamplayerskin, s_steamplayerskin],
        [s_breakableplayerskin, s_breakableplayerskin, s_breakableplayerskin, s_breakableplayerskin, s_breakableplayerskin],
        [s_smileyplayerskin, s_smileyplayerskin, s_smileyplayerskin, s_smileyplayerskin, s_smileyplayerskin],
        [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite],
        [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite],
        [s_toiletplayerskin, s_toiletplayerskin, s_toiletplayerskin, s_toiletplayerskin, s_toiletplayerskin],
        [s_kratosplayerskin, s_kratosplayerskin, s_kratosplayerskin, s_kratosplayerskin, s_kratosplayerskin]
    ];
    return _skins[_skin][_color];
}
function net_room_asset(_name) {
    if (!is_string(_name) || string_byte_length(_name) > 127) return -1;
    var _asset = asset_get_index(_name);
    return _asset != -1 && asset_get_type(_asset) == asset_room ? _asset : -1;
}
function net_packet_string_end(_buffer,_offset,_size,_limit) {
    if (_offset < 0 || _size > buffer_get_size(_buffer)) return -1;
    var _end = min(_size,_offset+_limit+1);
    for (var _i = _offset; _i < _end; ++_i) if (buffer_peek(_buffer,_i,buffer_u8) == 0) return _i;
    return -1;
}
function net_write_state(_buffer,_state) {
    buffer_seek(_buffer,buffer_seek_start,0);
    buffer_write(_buffer,buffer_u8,NET_PACKET_PLAYER_STATE);
    buffer_write(_buffer,buffer_f32,_state.x);
    buffer_write(_buffer,buffer_f32,_state.y);
    buffer_write(_buffer,buffer_s32,net_builtin_skin_sprite(_state.skin,_state.color,_state.is_dead));
    buffer_write(_buffer,buffer_u8,_state.image_index);
    buffer_write(_buffer,buffer_s32,_state.image_blend);
    buffer_write(_buffer,buffer_f32,_state.image_xscale);
    buffer_write(_buffer,buffer_f32,_state.image_yscale);
    buffer_write(_buffer,buffer_f32,_state.image_angle);
    buffer_write(_buffer,buffer_f32,_state.image_alpha);
    buffer_write(_buffer,buffer_u8,_state.color);
    buffer_write(_buffer,buffer_string,_state.room_name);
    buffer_write(_buffer,buffer_u8,_state.skin);
    buffer_write(_buffer,buffer_u8,_state.hat);
    buffer_write(_buffer,buffer_u8,_state.item);
    buffer_write(_buffer,buffer_f32,_state.hsp);
    buffer_write(_buffer,buffer_f32,_state.vsp);
    buffer_write(_buffer,buffer_u8,_state.is_dead);
    buffer_write(_buffer,buffer_u8,_state.zerogrv);
    return buffer_tell(_buffer);
}
function net_decode_state(_buffer,_size) {
    // The room's NUL terminator must be within this packet, not stale grow-buffer data.
    if (_size < 49 || _size > 1024 || _size > buffer_get_size(_buffer)) return undefined;
    if (buffer_peek(_buffer,0,buffer_u8) != NET_PACKET_PLAYER_STATE) return undefined;
    var _end = net_packet_string_end(_buffer,35,_size,127);
    if (_end < 0 || _end+14 != _size) return undefined;
    buffer_seek(_buffer,buffer_seek_start,1);
    var _state = {};
    _state.x = buffer_read(_buffer,buffer_f32);
    _state.y = buffer_read(_buffer,buffer_f32);
    buffer_read(_buffer,buffer_s32); // Legacy process-local sprite id is intentionally ignored.
    _state.image_index = buffer_read(_buffer,buffer_u8);
    _state.image_blend = buffer_read(_buffer,buffer_s32);
    _state.image_xscale = buffer_read(_buffer,buffer_f32);
    _state.image_yscale = buffer_read(_buffer,buffer_f32);
    _state.image_angle = buffer_read(_buffer,buffer_f32);
    _state.image_alpha = buffer_read(_buffer,buffer_f32);
    _state.color = buffer_read(_buffer,buffer_u8);
    _state.room_name = buffer_read(_buffer,buffer_string);
    _state.skin = net_cosmetic_id(buffer_read(_buffer,buffer_u8),49);
    _state.hat = net_cosmetic_id(buffer_read(_buffer,buffer_u8),67);
    _state.item = net_cosmetic_id(buffer_read(_buffer,buffer_u8),3);
    _state.hsp = buffer_read(_buffer,buffer_f32);
    _state.vsp = buffer_read(_buffer,buffer_f32);
    _state.is_dead = buffer_read(_buffer,buffer_u8);
    _state.zerogrv = buffer_read(_buffer,buffer_u8);
    var _numbers = ["x","y","image_xscale","image_yscale","image_angle","image_alpha","hsp","vsp"];
    for (var _i = 0; _i < array_length(_numbers); ++_i) if (!net_finite(variable_struct_get(_state,_numbers[_i]))) return undefined;
    if (abs(_state.x) > 1048576 || abs(_state.y) > 1048576 || abs(_state.hsp) > 10000 || abs(_state.vsp) > 10000
        || abs(_state.image_xscale) <= 0.0001 || abs(_state.image_yscale) <= 0.0001
        || abs(_state.image_xscale) > 16 || abs(_state.image_yscale) > 16 || abs(_state.image_angle) > 1000000
        || _state.image_alpha < 0 || _state.image_alpha > 1 || _state.color > 4 || _state.is_dead > 1 || _state.zerogrv > 1
        || _state.image_blend < 0 || _state.image_blend > 16777215 || net_room_asset(_state.room_name) == -1) return undefined;
    _state.sprite_index = net_builtin_skin_sprite(_state.skin,_state.color,_state.is_dead);
    _state.image_index = _state.image_index mod max(1,sprite_get_number(_state.sprite_index));
    return _state;
}
function net_lobby_member(_sender) {
    if (_sender == global.net_my_steam_id) return false;
    var _count = tcc_steam_lobby_get_member_count();
    for (var _i = 0; _i < _count; ++_i) if (tcc_steam_lobby_get_member_id(_i) == _sender) return true;
    return false;
}
function net_decode_join(_buffer,_size) {
    if (_size < 12 || _size > 140 || _size > buffer_get_size(_buffer)
        || buffer_peek(_buffer,0,buffer_u8) != NET_PACKET_PLAYER_JOIN) return undefined;
    var _end = net_packet_string_end(_buffer,1,_size,128);
    if (_end < 0 || _end+11 != _size) return undefined;
    buffer_seek(_buffer,buffer_seek_start,1);
    var _username = buffer_read(_buffer,buffer_string);
    var _time = buffer_read(_buffer,buffer_f64);
    var _skin = net_cosmetic_id(buffer_read(_buffer,buffer_u8),49);
    var _hat = net_cosmetic_id(buffer_read(_buffer,buffer_u8),67);
    if (!net_finite(_time)) return undefined;
    return {username:_username,join_time:_time,skin:_skin,hat:_hat};
}
function net_apply_ghost_state(_data,_state) {
    if (_data.room_name != _state.room_name) _data.ghost_alpha = 0;
    _data.target_x = _state.x;
    _data.target_y = _state.y;
    var _fields = ["sprite_index","image_index","image_blend","image_xscale","image_yscale","image_angle","image_alpha", "color","room_name","skin","hat","item","hsp","vsp","is_dead","zerogrv"];
    for (var _i = 0; _i < array_length(_fields); ++_i) variable_struct_set(_data,_fields[_i],variable_struct_get(_state,_fields[_i]));
    // Sender provides the death position/alpha; never invent RNG motion on the peer.
    if (_state.is_dead) { _data.x = _state.x; _data.y = _state.y; }
    _data.last_update = current_time;
}

/// @function		net_init()
/// @description	Initialize all online multiplayer global variables
function net_init() {
	// Note: global.onlinemultiplayersettings is set in scr_loading()
	// and loaded from save in scr_loadsettings(). Do NOT set it here.

	// Preserve any pending join that was set before init (menu/cold-launch join flow
	// sets this before the network manager is created, and Create_0 re-calls net_init)
	var _saved_pending_join = -1
	if (variable_global_exists("net_pending_join") && global.net_pending_join != -1) {
		_saved_pending_join = global.net_pending_join
	}

	global.net_active = false
	global.net_lobby_id = -1
	global.net_is_host = false
	global.net_my_steam_id = -1
	global.net_send_timer = 0
	global.net_ping_at = 0
	global.net_last_skin = 0
	global.net_join_time = 0		// Timestamp when we joined the lobby

	// Connection overlay state
	// 0 = idle, 1 = creating lobby, 2 = joining lobby, 3 = success flash, 4 = failure flash
	global.net_connect_state = 0
	global.net_connect_timer = 0     // Counts up while connecting (for dots animation)
	global.net_connect_flash = 0     // Counts down for success/failure flash display
	global.net_connect_msg = ""      // Extra message for success/failure
	global.net_pending_join = _saved_pending_join  // Restore preserved pending join
	// Pending native calls outlive a manager room/lifetime. Clear only on reply.
	if (!variable_global_exists("net_create_pending")) global.net_create_pending = false;
	if (!variable_global_exists("net_join_pending_id")) global.net_join_pending_id = -1;
	if (!variable_global_exists("net_join_defer_tick")) global.net_join_defer_tick = -1;
	global.net_host_intent = false;

	// Clean up old resources if re-initializing (prevents memory leaks)
	if (variable_global_exists("net_players") && ds_exists(global.net_players, ds_type_map)) {
		ds_map_destroy(global.net_players)
	}
	if (variable_global_exists("net_recv_buffer") && buffer_exists(global.net_recv_buffer)) {
		buffer_delete(global.net_recv_buffer)
	}
	if (variable_global_exists("net_send_buffer") && buffer_exists(global.net_send_buffer)) {
		buffer_delete(global.net_send_buffer)
	}

	// Remote player data: ds_map keyed by steam_id (as string)
	// Each entry is a struct with: x, y, sprite_index, image_index, image_blend,
	//   skin, hat, item, color, room_name, username, join_time, last_update, image_xscale
	global.net_players = ds_map_create()
	global.net_recv_buffer = buffer_create(512, buffer_grow, 1)
	global.net_send_buffer = buffer_create(256, buffer_grow, 1)
}

/// @function		net_cleanup()
/// @description	Clean up all networking resources
function net_cleanup() {
    var _players = variable_global_exists("net_players") && (is_real(global.net_players) || is_handle(global.net_players)) && ds_exists(global.net_players,ds_type_map);
    if (variable_global_exists("net_lobby_id") && global.net_lobby_id != -1) {
        if (_players && global.net_is_host && tcc_steam_lobby_get_member_count() > 1) {
            var _earliest = infinity, _successor = -1;
            var _key = ds_map_find_first(global.net_players);
            while (!is_undefined(_key)) {
                var _data = global.net_players[? _key];
                if (_data.join_time < _earliest) { _earliest = _data.join_time; _successor = _data.steam_id; }
                _key = ds_map_find_next(global.net_players,_key);
            }
            if (_successor != -1) tcc_steam_lobby_set_owner_id(_successor);
        }
        tcc_steam_lobby_leave();
    }
    if (_players) {
        var _key = ds_map_find_first(global.net_players);
        while (!is_undefined(_key)) {
            tcc_steam_net_close_p2p_session(global.net_players[? _key].steam_id);
            _key = ds_map_find_next(global.net_players,_key);
        }
        ds_map_destroy(global.net_players);
    }
    if (variable_global_exists("net_recv_buffer") && buffer_exists(global.net_recv_buffer)) buffer_delete(global.net_recv_buffer);
    if (variable_global_exists("net_send_buffer") && buffer_exists(global.net_send_buffer)) buffer_delete(global.net_send_buffer);
    global.net_players = -1; global.net_recv_buffer = -1; global.net_send_buffer = -1;
    global.net_active = false; global.net_lobby_id = -1; global.net_is_host = false;
    global.net_host_intent = false; global.net_pending_join = -1;
    // Do not erase native create/join ownership here: the callback must settle
    // before a later manager is allowed to issue another lobby operation.
}

// Copy the requested ID while async_load is live; never retain its DS map.
function net_queue_join(_lobby_id) {
    global.net_host_intent = false;
    if (global.net_active) {
        net_send_leave_info();
        tcc_steam_lobby_leave();
        ds_map_clear(global.net_players);
        global.net_active = false; global.net_lobby_id = -1; global.net_is_host = false;
    }
    global.net_pending_join = _lobby_id;
    global.net_join_defer_tick = timing_tick_id();
    global.net_connect_state = 2; global.net_connect_timer = 0;
}

// Even an unexplained native success has changed the extension's current lobby.
// Fail closed: leave it and clear active state without consuming another reply.
function net_discard_lobby_reply(_success) {
    if (_success) tcc_steam_lobby_leave();
    if (variable_global_exists("net_players") && (is_real(global.net_players) || is_handle(global.net_players))
        && ds_exists(global.net_players, ds_type_map)) ds_map_clear(global.net_players);
    global.net_active = false; global.net_lobby_id = -1; global.net_is_host = false;
    global.net_join_defer_tick = timing_tick_id();
}


/// @function		net_host_lobby()
/// @description	Create a new Steam lobby (friends only so people can join via overlay)
function net_host_lobby() {
	if (!tcc_steam_initialised() || global.net_active || global.net_pending_join != -1) return;
	global.net_host_intent = true;
	if (global.net_create_pending || global.net_join_pending_id != -1) return;
	global.net_my_steam_id = tcc_steam_get_user_steam_id();
	global.net_connect_state = 1; global.net_connect_timer = 0;
	global.net_create_pending = true;
	if (!tcc_steam_lobby_create(steam_lobby_type_friends_only, global.netmaxplayers)) {
		global.net_create_pending = false; global.net_host_intent = false;
		global.net_connect_state = 4; global.net_connect_flash = 240;
		global.net_connect_msg = "Failed to create lobby";
	}
}

/// @function net_join_lobby(lobby_id)
/// @description Issue the queued join only after earlier native calls settle.
function net_join_lobby(_lobby_id) {
	if (!tcc_steam_initialised() || global.net_active || global.net_create_pending
		|| global.net_join_pending_id != -1 || global.net_pending_join != _lobby_id
		|| timing_tick_id() <= global.net_join_defer_tick) return;
	global.net_host_intent = false;
	global.net_my_steam_id = tcc_steam_get_user_steam_id();
	global.net_connect_state = 2; global.net_connect_timer = 0;
	global.net_join_pending_id = _lobby_id;
	if (!tcc_steam_lobby_join_id(_lobby_id)) {
		global.net_join_pending_id = -1; global.net_pending_join = -1;
		global.net_connect_state = 4; global.net_connect_flash = 240;
		global.net_connect_msg = "Failed to connect";
	}
}

/// @function		net_send_player_state()
/// @description	Broadcast local player position and state to all peers
function net_send_player_state() {
    if (!global.net_active) return;
    var _player = instance_exists(o_player) ? instance_find(o_player,0) : noone;
    var _dead = _player == noone;
    if (_dead) _player = instance_exists(o_playerdead) ? instance_find(o_playerdead,0) : noone;
    if (_player == noone) return;
    var _skin = net_cosmetic_id(global.skinselected,49);
    if (!_dead) {
        if (_player.customskin == 1) _skin = 0;
        global.net_last_skin = _skin;
    } else _skin = global.net_last_skin;
    global.net_send_timer++;
    if (global.net_send_timer < NET_SEND_RATE) return;
    global.net_send_timer = 0;
    var _state = {
        x:_player.x, y:_player.y, image_index:floor(_player.image_index),
        image_blend:(!_dead && _player.customskin == 1) ? c_white : _player.image_blend,
        image_xscale:_dead ? 1 : _player.image_xscale, image_yscale:_dead ? 1 : _player.image_yscale,
        image_angle:_dead ? 0 : _player.image_angle, image_alpha:clamp(_player.image_alpha,0,1),
        color:net_cosmetic_id(global.color,4), room_name:room_get_name(room), skin:_skin,
        // Imported hats/items use the equipped built-in choice as the peer fallback.
        hat:net_cosmetic_id(global.hatselected,67), item:net_cosmetic_id(global.itemselected,3),
        hsp:_dead ? 0 : _player.hsp, vsp:_dead ? 0 : _player.vsp,
        is_dead:_dead ? 1 : 0, zerogrv:_dead ? 0 : _player.zerogrv
    };
    var _size = net_write_state(global.net_send_buffer,_state);
    var _count = tcc_steam_lobby_get_member_count();
    for (var _i = 0; _i < _count; ++_i) {
        var _member = tcc_steam_lobby_get_member_id(_i);
        if (_member != global.net_my_steam_id) tcc_steam_net_packet_send(_member,global.net_send_buffer,_size,steam_net_packet_type_unreliable);
    }
}

function net_send_ping() {
    if (!global.net_active || current_time < global.net_ping_at) return;
    global.net_ping_at = current_time + 2000;
    var _buf = global.net_send_buffer;
    buffer_seek(_buf,buffer_seek_start,0);
    buffer_write(_buf,buffer_u8,NET_PACKET_PING);
    buffer_write(_buf,buffer_string,room_get_name(room));
    var _size = buffer_tell(_buf);
    var _count = tcc_steam_lobby_get_member_count();
    for (var _i = 0; _i < _count; ++_i) {
        var _member = tcc_steam_lobby_get_member_id(_i);
        if (_member != global.net_my_steam_id) tcc_steam_net_packet_send(_member,_buf,_size,steam_net_packet_type_unreliable);
    }
}

/// @function		net_receive_packets()
/// @description	Poll and process all incoming P2P packets
function net_receive_packets() {
    if (!global.net_active) return;
    var _buf = global.net_recv_buffer;
    var _processed = 0;
    while (_processed < 64 && tcc_steam_net_packet_receive()) {
        ++_processed;
        var _sender = tcc_steam_net_packet_get_sender_id();
        var _size = tcc_steam_net_packet_get_size();
        if (_size < 1 || _size > 1024 || !net_lobby_member(_sender)) continue;
        tcc_steam_net_packet_get_data(_buf);
        buffer_seek(_buf,buffer_seek_start,0);
        var _type = buffer_read(_buf,buffer_u8);
        var _key = string(_sender);
        switch (_type) {
            case NET_PACKET_PLAYER_STATE:
                var _state = net_decode_state(_buf,_size);
                if (is_undefined(_state)) break;
                // A peer returning after a timeout can recover from its next valid state.
                if (!ds_map_exists(global.net_players,_key))
                    net_register_player(_sender,tcc_steam_get_user_persona_name(_sender),current_time,_state.skin,_state.hat);
                net_apply_ghost_state(global.net_players[? _key],_state);
                break;
            case NET_PACKET_PLAYER_JOIN:
                var _join = net_decode_join(_buf,_size);
                if (is_undefined(_join)) break;
                // Reply only to a new peer: replying to every JOIN caused an endless ping-pong.
                if (net_register_player(_sender,_join.username,_join.join_time,_join.skin,_join.hat)) net_send_join_info(_sender);
                break;
            case NET_PACKET_PLAYER_LEAVE:
                if (_size == 1) net_remove_player(_sender);
                break;
            case NET_PACKET_HOST_CHANGE:
                // Steam lobby ownership is authoritative. A peer's float64 ID loses precision.
                if (_size == 9) global.net_is_host = tcc_steam_lobby_is_owner();
                break;
            case NET_PACKET_PING:
                if (!ds_map_exists(global.net_players,_key)) break;
                var _data = global.net_players[? _key];
                if (_size > 1) {
                    var _end = net_packet_string_end(_buf,1,_size,127);
                    if (_end != _size-1) break;
                    var _peer_room = buffer_read(_buf,buffer_string);
                    if (net_room_asset(_peer_room) == -1) break;
                    if (_data.room_name != _peer_room) _data.ghost_alpha = 0;
                    _data.room_name = _peer_room;
                }
                _data.last_update = current_time;
                break;
        }
    }
}

/// @function		net_register_player(steam_id, username, join_time, skin, hat)
/// @description	Register a remote player in our tracking map
function net_register_player(_steam_id, _username, _join_time, _skin, _hat) {
	var _key = string(_steam_id)

	if (ds_map_exists(global.net_players, _key)) return false; // Already registered

	// Start ghost at player's position so it doesn't lerp from (0,0)
	var _init_x = 0
	var _init_y = 0
	if (instance_exists(o_player)) {
		_init_x = o_player.x
		_init_y = o_player.y
	}

	var _data = {
		steam_id: _steam_id,
		username: string_copy(string_replace_all(string_replace_all(string(_username),chr(10)," "),chr(13)," "),1,64),
		x: _init_x,
		y: _init_y,
		target_x: _init_x,
		target_y: _init_y,
		sprite_index: s_playerred,
		image_index: 0,
		image_blend: c_white,
		image_xscale: 1,
		image_yscale: 1,
		image_angle: 0,
		image_alpha: 1,
		color: 0,
		room_name: "",
		skin: net_cosmetic_id(_skin,49),
		hat: net_cosmetic_id(_hat,67),
		item: 0,
		hsp: 0,
		vsp: 0,
		is_dead: 0,
		zerogrv: 0,
		dead_timer: 0,      // Local death animation timer
		dead_drift: 0,      // Death horizontal drift
		dead_fall: 0,       // Death vertical speed
		join_time: current_time,
		last_update: current_time,
		ghost_alpha: 0  // Fade in
	}

	ds_map_add(global.net_players, _key, _data)
	show_debug_message("[NET] Player joined: " + _data.username + " (ID: " + _key + ")")
	return true;
}

/// @function		net_remove_player(steam_id)
/// @description	Remove a remote player from our tracking map
function net_remove_player(_steam_id) {
	var _key = string(_steam_id)
	if (ds_map_exists(global.net_players, _key)) {
		var _data = global.net_players[? _key]
		show_debug_message("[NET] Player left: " + _data.username)
		ds_map_delete(global.net_players, _key)
	}
	tcc_steam_net_close_p2p_session(_steam_id)
}

/// @function		net_send_join_info(target_id)
/// @description	Send our join/identity info to a specific player (or broadcast)
function net_send_join_info(_target_id) {
	var _buf = global.net_send_buffer
	buffer_seek(_buf, buffer_seek_start, 0)

	buffer_write(_buf, buffer_u8, NET_PACKET_PLAYER_JOIN)
	buffer_write(_buf, buffer_string, tcc_steam_get_persona_name())
	buffer_write(_buf, buffer_f64, global.net_join_time)
	buffer_write(_buf, buffer_u8, net_cosmetic_id(global.skinselected,49))
	buffer_write(_buf, buffer_u8, net_cosmetic_id(global.hatselected,67))

	var _size = buffer_tell(_buf)

	if (_target_id == -1) {
		// Broadcast to all
		var _count = tcc_steam_lobby_get_member_count()
		for (var i = 0; i < _count; i++) {
			var _member = tcc_steam_lobby_get_member_id(i)
			if (_member != global.net_my_steam_id) {
				tcc_steam_net_packet_send(_member, _buf, _size, steam_net_packet_type_reliable)
			}
		}
	} else {
		tcc_steam_net_packet_send(_target_id, _buf, _size, steam_net_packet_type_reliable)
	}
}

/// @function		net_send_leave_info()
/// @description	Broadcast that we are leaving
function net_send_leave_info() {
	var _buf = global.net_send_buffer
	buffer_seek(_buf, buffer_seek_start, 0)
	buffer_write(_buf, buffer_u8, NET_PACKET_PLAYER_LEAVE)
	var _size = buffer_tell(_buf)

	var _count = tcc_steam_lobby_get_member_count()
	for (var i = 0; i < _count; i++) {
		var _member = tcc_steam_lobby_get_member_id(i)
		if (_member != global.net_my_steam_id) {
			tcc_steam_net_packet_send(_member, _buf, _size, steam_net_packet_type_reliable)
		}
	}
}

/// @function		net_handle_async_steam(async_map)
/// @description	Handle Steam async events for lobby management
function net_handle_async_steam(_map) {
	var _event_type = _map[? "event_type"]

	switch (_event_type) {
		case "lobby_created":
			var _create_owned = global.net_create_pending;
			global.net_create_pending = false;
			var _host_wanted = global.net_host_intent;
			global.net_host_intent = false;
			if (!_create_owned || !_host_wanted || global.net_pending_join != -1
				|| !instance_exists(o_networkmanager)) {
				// The extension has already selected this created lobby. Leave it
				// before issuing the desired join on a later logical tick.
				net_discard_lobby_reply(_map[? "success"]);
				break;
			}

			if (_map[? "success"]) {
				global.net_lobby_id = _map[? "lobby_id"]
				global.net_active = true
				global.net_is_host = true
				global.net_join_time = current_time

				tcc_steam_lobby_set_data("game_name", "TheColorfulCreature")
				tcc_steam_lobby_set_data("version", "1.0")
				tcc_steam_lobby_set_data("host_name", tcc_steam_get_persona_name())
				tcc_steam_lobby_set_data("current_room", room_get_name(room))

				global.net_connect_state = 3
				global.net_connect_flash = 180
				global.net_connect_msg = "Lobby created"
				show_debug_message("[NET] Lobby created! ID: " + string(global.net_lobby_id))
			} else {
				global.net_connect_state = 4
				global.net_connect_flash = 240
				global.net_connect_msg = "Failed to create lobby"
				show_debug_message("[NET] Failed to create lobby")
			}
			break;

		case "lobby_joined":
			var _reply_id = _map[? "lobby_id"];
			var _expected_id = global.net_join_pending_id;
			if (_expected_id == -1 || _reply_id != _expected_id) {
				// No unexplained response can activate the manager or move rooms.
				net_discard_lobby_reply(_map[? "success"]);
				break;
			}
			global.net_join_pending_id = -1;
			if (!instance_exists(o_networkmanager) || global.net_pending_join != _expected_id) {
				// Cancelled manager or a newer invite: settle this reply first.
				net_discard_lobby_reply(_map[? "success"]);
				break;
			}
			global.net_pending_join = -1;
			if (_map[? "success"]) {
				global.net_lobby_id = _map[? "lobby_id"]
				global.net_active = true
				global.net_join_time = current_time

				// Check if we are the owner
				global.net_is_host = tcc_steam_lobby_is_owner()

				if (!global.net_is_host) {
					// Send our join info to everyone
					net_send_join_info(-1)

					// Treat joining as entering level select for the client
					global.levelselect = 1

					// Read the host's current room from lobby data and go there
					var _host_room = tcc_steam_lobby_get_data("current_room")
					if (net_room_asset(_host_room) != -1) {
						show_debug_message("[NET] Going to host's room: " + _host_room)
						room_goto(net_room_asset(_host_room))
						if (!instance_exists(o_time)) {
							loadhud()
						}
					}
				}

				global.net_connect_state = 3
				global.net_connect_flash = 180
				global.net_connect_msg = "Connected!"
				show_debug_message("[NET] Joined lobby! Host: " + string(global.net_is_host))
			} else {
				global.net_connect_state = 4
				global.net_connect_flash = 240
				global.net_connect_msg = "Failed to connect"
				show_debug_message("[NET] Failed to join lobby")
			}
			break;

		case "lobby_chat_update":
			if (!global.net_active || _map[? "lobby_id"] != global.net_lobby_id) break;
			var _flags = _map[? "change_flags"]
			var _uid = _map[? "user_id"]

			// Player left or disconnected
			if (_flags & 2 || _flags & 4) {
				net_remove_player(_uid)

				// Check if we became the new owner (Steam auto-transfers)
				if (tcc_steam_lobby_is_owner() && !global.net_is_host) {
					global.net_is_host = true
					show_debug_message("[NET] Host migration: we are now the host")

					// Notify everyone about the host change
					var _buf = global.net_send_buffer
					buffer_seek(_buf, buffer_seek_start, 0)
					buffer_write(_buf, buffer_u8, NET_PACKET_HOST_CHANGE)
					buffer_write(_buf, buffer_f64, global.net_my_steam_id)
					var _size = buffer_tell(_buf)

					var _count = tcc_steam_lobby_get_member_count()
					for (var i = 0; i < _count; i++) {
						var _member = tcc_steam_lobby_get_member_id(i)
						if (_member != global.net_my_steam_id) {
							tcc_steam_net_packet_send(_member, _buf, _size, steam_net_packet_type_reliable)
						}
					}
				}

				// If we're the only one left, check if we should close
				if (tcc_steam_lobby_get_member_count() <= 1 && ds_map_size(global.net_players) == 0) {
					show_debug_message("[NET] All players left, lobby still active for new joins")
				}
			}

			// Player joined
			if (_flags & 1) {
				show_debug_message("[NET] Someone joined the lobby: " + string(_uid))
			}
			break;

		case "lobby_join_requested":
			// Someone accepted our invite or clicked "Join Game" in Steam overlay
			var _lobby_id = _map[? "lobby_id"]
			show_debug_message("[NET] Join request received for lobby: " + string(_lobby_id))

			net_queue_join(_lobby_id);
			break;
	}
}

/// @function		net_get_ghost_count()
/// @description	Returns the number of ghosts in the current room
function net_get_ghost_count() {
	var _count = 0
	var _current_room = room_get_name(room)
	var _key = ds_map_find_first(global.net_players)
	while (!is_undefined(_key)) {
		var _data = global.net_players[? _key]
		if (_data.room_name == _current_room) {
			_count++
		}
		_key = ds_map_find_next(global.net_players, _key)
	}
	return _count
}

/// @function		net_update_ghosts()
/// @description	Update ghost positions and state
function net_update_ghosts() {
	if (!global.net_active) return;

	var _current_room = room_get_name(room)

	var _key = ds_map_find_first(global.net_players)
	while (!is_undefined(_key)) {
		var _data = global.net_players[? _key]

        // Death and respawn both follow the sender. Rendering a remote death
        // never changes local RNG or owns/releases any imported sprite.
        _data.x = _data.target_x;
        _data.y = _data.target_y;
        var _visible = _data.room_name == _current_room ? 1 : 0;
        var _rate = min(1,(_visible ? 0.05 : 0.1) * (60/global.maxfps));
        _data.ghost_alpha = lerp(_data.ghost_alpha,_visible,_rate);

		// Timeout: remove players we haven't heard from in 10 seconds
		if (current_time - _data.last_update > 10000) {
			var _next_key = ds_map_find_next(global.net_players, _key)
			net_remove_player(_data.steam_id)
			_key = _next_key
			continue;
		}

		_key = ds_map_find_next(global.net_players, _key)
	}
}

/// @function		net_draw_ghosts()
/// @description	Draw all ghost players that are in the same room
function net_draw_ghosts() {
	if (!global.net_active) return;

	var _current_room = room_get_name(room)

	var _key = ds_map_find_first(global.net_players)
	while (!is_undefined(_key)) {
		var _data = global.net_players[? _key]

		// Only draw ghosts that are in the same room and visible
		if (_data.room_name == _current_room && _data.ghost_alpha * _data.image_alpha > 0.01) {
			// Compensate for sprite offset mismatch between local and remote player.
			// When in zero gravity, the sender's sprite offset was (16,16) and position
			// was shifted +16. The local sprite offset may differ, so we correct here.
			var _sox = sprite_get_xoffset(_data.sprite_index)
			var _soy = sprite_get_yoffset(_data.sprite_index)
			var _ghost_ox = _data.zerogrv * 16
			var _ghost_oy = _data.zerogrv * 16
			var _draw_x = _data.x + (_sox - _ghost_ox)
			var _draw_y = _data.y + (_soy - _ghost_oy)

			// Draw the ghost player sprite
			draw_sprite_ext(
				_data.sprite_index,
				_data.image_index,
				_draw_x,
				_draw_y,
				_data.image_xscale,
				_data.image_yscale,
				_data.image_angle,
				_data.image_blend,
				_data.ghost_alpha * _data.image_alpha
			)

			// Draw hat on ghost
			net_draw_ghost_hat(_data)

			// Draw item on ghost
			net_draw_ghost_item(_data)

			// Visual center of the ghost sprite (accounts for zero gravity offset)
			var _center_x = _data.x + 16 - (_data.zerogrv * 16)
			var _text_y = _data.y - 8 - (_data.zerogrv * 16)

			// Draw username above the ghost
			draw_set_font(fnt_multiplayerfont)
			draw_set_halign(fa_center)
			draw_set_valign(fa_bottom)
			draw_set_alpha(_data.ghost_alpha * _data.image_alpha)

			// Text outline
			draw_set_color(c_black)
			draw_text(_center_x + 1, _text_y + 1, _data.username)
			draw_text(_center_x - 1, _text_y - 1, _data.username)
			draw_text(_center_x + 1, _text_y - 1, _data.username)
			draw_text(_center_x - 1, _text_y + 1, _data.username)

			// Text fill
			draw_set_color(c_white)
			draw_text(_center_x, _text_y, _data.username)

			draw_set_alpha(1)
			draw_set_halign(fa_left)
			draw_set_valign(fa_top)
		}

		_key = ds_map_find_next(global.net_players, _key)
	}
}

/// @function		net_draw_ghost_hat(data)
/// @description	Draw a ghost player's hat (simplified version of scr_hats)
function net_draw_ghost_hat(_data) {
	var _hat = _data.hat
	if (_hat <= 0) return;

	var _zg = _data.zerogrv * 16
	var _xx = _data.x + 16 - _zg
	var _yy = _data.y + 8 - _zg
	var _alpha = _data.ghost_alpha * _data.image_alpha
	var _hatspr = s_graduationhat
	var _colorhat = c_white

	switch(_hat) {
		case 1: _hatspr = s_graduationhat; break;
		case 2: _hatspr = s_conehat; break;
		case 3: _hatspr = s_partyhat; break;
		case 4: _hatspr = s_paperhat; break;
		case 5: _hatspr = s_tophat; break;
		case 6: _hatspr = s_yellowtophat; break;
		case 8: _hatspr = s_santahat; break;
		case 9: _hatspr = s_witchhat; break;
		case 10: _hatspr = s_pumpkinhat; break;
		case 11: _hatspr = s_brownhat; break;
		case 12: _hatspr = s_grayhat; break;
		case 13: _hatspr = s_whitehat; break;
		case 14: _hatspr = s_sunhat; break;
		case 15: _hatspr = s_redblockhat; break;
		case 16: _hatspr = s_yellowblockhat; break;
		case 17: _hatspr = s_greenblockhat; break;
		case 18: _hatspr = s_blueblockhat; break;
		case 19: _hatspr = s_whiteblockhat; break;
		case 20: _hatspr = s_spikehat; break;
		case 24: _hatspr = s_hexagonhat; break;
		case 25: _hatspr = s_breadhat; break;
		case 26: _hatspr = s_soldierhat; break;
		case 27: _hatspr = s_samuraihat; break;
		case 33: _hatspr = s_piratehat; break;
		case 35: _hatspr = s_kingshat; break;
		case 37: _hatspr = s_comradehat; break;
		case 38: _hatspr = s_vikinghat; break;
		case 39: _hatspr = s_cowboyhat; break;
		case 45: _hatspr = s_flowerhat; break;
		default: return; // Unknown hat, skip
	}

	draw_sprite_ext(_hatspr, 0, _xx, _yy, 1, 1, _data.image_angle, _colorhat, _alpha)
}

/// @function		net_draw_ghost_item(data)
/// @description	Draw a ghost player's item (simplified version of scr_items)
function net_draw_ghost_item(_data) {
	var _item = _data.item
	if (_item <= 0) return;

	var _zg = _data.zerogrv * 16
	var _xx = _data.x - _zg
	var _yy = _data.y + 20 - _zg
	var _alpha = _data.ghost_alpha * _data.image_alpha
	var _itemspr = -1

	switch(_item) {
		case 1: _itemspr = s_paintbrushitem; break;
		case 2: _itemspr = s_floweritem; break;
		case 3: _itemspr = s_shielditem; break;
		default: return;
	}

	// Simple bobbing animation using current_time
	var _rot = sin(current_time / 500) * 30
	draw_sprite_ext(_itemspr, 0, _xx, _yy, 1, 1, _rot, c_white, _alpha)
}

/// @function		net_is_main_game()
/// @description	Returns whether we're currently in the main game (not menus, editor, etc.)
function net_is_main_game() {
	if (room == r_mainmenu) return false;
	if (room == r_logointro) return false;
	if (room == r_loading) return false;
	if (room == r_gamemode) return false;
	if (room == r_skinmenu) return false;
	if (room == r_settings) return false;
	if (room == r_achievements) return false;
	if (room == r_stats) return false;
	if (room == r_credits) return false;
	if (room == r_support) return false;
	if (room == r_levelselectmenu) return false;
	if (room == r_endlessrunmenu) return false;
	if (room == r_localmultiplayermenu) return false;
	if (room == r_funmodemenu) return false;
	if (room == r_customlevelmenu) return false;
	if (room == r_customlevelworkshop) return false;
	if (room == r_soundtestmenu) return false;
	if (room == r_hardmodediff) return false;
	if (room == r_leveleditor) return false;
	if (room == r_hatmerchantroom) return false;
	if (room == r_onlineleaderboard) return false;
	return true;
}

/// Buffer/ghost lifecycle fixtures use no Steam API, lobby, peer, imported file or save.
function scr_online_cosmetics_selfcheck() {
    var _buffer = buffer_create(512,buffer_grow,1);
    buffer_write(_buffer,buffer_u8,3);
    scr_port_assert(net_cosmetic_id(buffer_peek(_buffer,0,buffer_u8),4) == 3,
        "native unsigned-byte cosmetic ids retain their integer value");
    scr_port_assert(net_cosmetic_id(int64(3),4) == 3 && net_cosmetic_id("3",4) == 0
        && net_cosmetic_id(-1,4) == 0 && net_cosmetic_id(3.5,4) == 0,
        "cosmetic ids accept numeric integers only within their built-in range");
    var _state = {
        x:96, y:128, image_index:7, image_blend:c_white, image_xscale:1, image_yscale:1,
        image_angle:0, image_alpha:1, color:3, room_name:"r_lvl1", skin:0, hat:1, item:2,
        hsp:4, vsp:-3, is_dead:0, zerogrv:0
    };
    var _size = net_write_state(_buffer,_state);
    var _read = net_decode_state(_buffer,_size);
    // Keep a bounded, synthetic-packet diagnostic before the first assertion so
    // the native runner can distinguish serialization and validation failures.
    var _probe = {
        size:_size, packetType:buffer_peek(_buffer,0,buffer_u8),
        roomEnd:net_packet_string_end(_buffer,35,_size,127),
        wireRoom:buffer_peek(_buffer,35,buffer_string),
        roomAsset:string(net_room_asset("r_lvl1")),
        wireX:buffer_peek(_buffer,1,buffer_f32), wireY:buffer_peek(_buffer,5,buffer_f32),
        wireBlend:buffer_peek(_buffer,14,buffer_s32),
        wireScaleX:buffer_peek(_buffer,18,buffer_f32), wireScaleY:buffer_peek(_buffer,22,buffer_f32),
        wireAlpha:buffer_peek(_buffer,30,buffer_f32), wireColor:buffer_peek(_buffer,34,buffer_u8),
        numericFloat:net_finite(buffer_peek(_buffer,1,buffer_f32)),
        numericByte:net_cosmetic_id(buffer_peek(_buffer,34,buffer_u8),4),
        decoded:!is_undefined(_read)
    };
    if (!is_undefined(_read)) {
        _probe.skin = _read.skin; _probe.hat = _read.hat; _probe.item = _read.item;
        _probe.sprite = string(_read.sprite_index); _probe.expectedSprite = string(s_playerblue);
    }
    show_debug_message("TCC_GHOST_PACKET_PROBE " + json_stringify(_probe));
    scr_port_assert(!is_undefined(_read),"well-formed ghost packet decodes");
    scr_port_assert(_read.x == 96 && _read.y == 128
        && _read.sprite_index == s_playerblue && _read.hat == 1 && _read.item == 2,
        "ghost packet retains position and built-in cosmetic choices");
    // Raw sprite indices can name an unrelated or deleted runtime asset on a peer.
    buffer_poke(_buffer,9,buffer_s32,2147483647);
    scr_port_assert(net_decode_state(_buffer,_size).sprite_index == s_playerblue,
        "untrusted sprite handle is replaced by a local built-in sprite");
    for (var _length = 0; _length < _size; ++_length)
        scr_port_assert(is_undefined(net_decode_state(_buffer,_length)),"truncated packet cannot read stale receive-buffer bytes");
    buffer_poke(_buffer,1,buffer_u32,$7fc00000);
    scr_port_assert(is_undefined(net_decode_state(_buffer,_size)),"NaN player position is rejected");
    _size = net_write_state(_buffer,_state);
    _state.image_xscale = 0;
    _size = net_write_state(_buffer,_state);
    scr_port_assert(is_undefined(net_decode_state(_buffer,_size)),"zero sprite scale is rejected");
    _state.image_xscale = 1;
    _state.room_name = "o_player";
    _size = net_write_state(_buffer,_state);
    scr_port_assert(is_undefined(net_decode_state(_buffer,_size)) && net_room_asset("o_player") == -1,
        "peer room names cannot refer to object or sprite resources");
    _state.room_name = "r_lvl1";
    _state.skin = 255; _state.hat = 255; _state.item = 255;
    _size = net_write_state(_buffer,_state);
    _read = net_decode_state(_buffer,_size);
    scr_port_assert(_read.skin == 0 && _read.hat == 0 && _read.item == 0 && _read.sprite_index == s_playerblue,
        "unknown/custom cosmetic ids have built-in or unequipped fallbacks");
    var _ghost = {room_name:"r_lvl2",ghost_alpha:1,x:0,y:0};
    net_apply_ghost_state(_ghost,_read);
    scr_port_assert(_ghost.ghost_alpha == 0 && _ghost.target_x == 96,"room change resets ghost fade without teleporting gameplay");
    _state.skin = 0; _state.is_dead = 1; _state.image_alpha = 0.5; _state.x = 100;
    _size = net_write_state(_buffer,_state);
    _read = net_decode_state(_buffer,_size);
    var _seed = random_get_seed();
    net_apply_ghost_state(_ghost,_read);
    scr_port_assert(_ghost.is_dead == 1 && _ghost.sprite_index == s_playerdead && _ghost.x == 100
        && _ghost.image_alpha == 0.5 && random_get_seed() == _seed,
        "ghost death follows sender without acquiring a PNG or consuming gameplay RNG");
    _state.is_dead = 0; _state.image_alpha = 1; _state.x = 96;
    _size = net_write_state(_buffer,_state);
    net_apply_ghost_state(_ghost,net_decode_state(_buffer,_size));
    scr_port_assert(_ghost.is_dead == 0 && _ghost.sprite_index == s_playerblue && _ghost.image_alpha == 1,
        "respawn restores built-in appearance after remote death");
    buffer_seek(_buffer,buffer_seek_start,0);
    buffer_write(_buffer,buffer_u8,NET_PACKET_PLAYER_JOIN);
    buffer_write(_buffer,buffer_string,"Player");
    buffer_write(_buffer,buffer_f64,123);
    buffer_write(_buffer,buffer_u8,0);
    buffer_write(_buffer,buffer_u8,0);
    _size = buffer_tell(_buffer);
    scr_port_assert(net_decode_join(_buffer,_size).username == "Player","identity packet round trip");
    scr_port_assert(is_undefined(net_decode_join(_buffer,_size-1)),"truncated identity packet rejected");
    buffer_delete(_buffer);
    for (var _skin = 0; _skin < 50; ++_skin) for (var _color = 0; _color < 5; ++_color)
        scr_port_assert(sprite_exists(net_builtin_skin_sprite(_skin,_color)),"every built-in ghost skin/color resolves locally");
    show_debug_message("TCC_ONLINE_COSMETICS_SELF_CHECK_PASS");
}
