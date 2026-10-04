// =============================================================================
// ONLINE MULTIPLAYER - Steam lobbies + P2P ghost players (protocol 2)
//
// Every Steam player owns a friends-only lobby ("session") while online
// multiplayer is enabled, so friends can always join from the Steam overlay,
// the Steam friends list or the in-game Friends panel. Everyone controls their
// own character; players on the same level see each other as ghosts.
// A player who joins someone follows that host: whenever the host starts a new
// mode, run or level from a menu, followers are taken along (see
// scr_online_session). Local levels are transferred peer to peer
// (scr_online_levelshare). The manager object is created once at boot.
// =============================================================================

#macro NET_PROTOCOL				2
#macro NET_GAME_NAME			"TheColorfulCreature"
#macro NET_MAX_LOBBY			250

// Protocol 2 packet ids. Protocol 1 used 1-7; those are ignored, and protocol
// 1 clients ignore these, so mixed versions can never misread each other.
#macro NET_PACKET_STATE			16	// unreliable ghost state
#macro NET_PACKET_HELLO			17	// reliable identity
#macro NET_PACKET_BYE			18	// reliable leave
#macro NET_PACKET_PING			19	// unreliable keepalive + location
#macro NET_PACKET_PONG			20	// unreliable round trip reply
#macro NET_PACKET_ER_PICKS		21	// reliable shared Endless Run picks
#macro NET_PACKET_LEVEL_REQUEST	22	// reliable shared level request
#macro NET_PACKET_LEVEL_CHUNK	23	// reliable shared level data
#macro NET_PACKET_LEVEL_DENY	24	// reliable shared level unavailable

#macro NET_PACKET_MAX_SIZE		1024
#macro NET_CHUNK_DATA_SIZE		8192
#macro NET_CHUNK_MAX_SIZE		8448
#macro NET_STATE_HEADER			33	// byte offset of the room string in a state packet
#macro NET_PEER_TIMEOUT_MS		10000
#macro NET_PING_INTERVAL_MS		2000
#macro NET_REFRESH_TICKS		30

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
// Level keys identify level content ("r_lvl12", "ws:<id>", "lv:<md5>", ...).
function net_key_valid(_key) {
    return is_string(_key) && string_byte_length(_key) > 0 && string_byte_length(_key) <= 127;
}
function net_packet_string_end(_buffer,_offset,_size,_limit) {
    if (_offset < 0 || _size > buffer_get_size(_buffer)) return -1;
    var _end = min(_size,_offset+_limit+1);
    for (var _i = _offset; _i < _end; ++_i) if (buffer_peek(_buffer,_i,buffer_u8) == 0) return _i;
    return -1;
}
function net_clean_name(_name) {
    return string_copy(string_replace_all(string_replace_all(string(_name),chr(10)," "),chr(13)," "),1,64);
}

// -----------------------------------------------------------------------------
// Wire format
// -----------------------------------------------------------------------------
function net_write_state(_buffer,_state) {
    buffer_seek(_buffer,buffer_seek_start,0);
    buffer_write(_buffer,buffer_u8,NET_PACKET_STATE);
    buffer_write(_buffer,buffer_u16,_state.seq & $FFFF);
    buffer_write(_buffer,buffer_f32,_state.x);
    buffer_write(_buffer,buffer_f32,_state.y);
    buffer_write(_buffer,buffer_u8,_state.image_index);
    buffer_write(_buffer,buffer_s32,_state.image_blend);
    buffer_write(_buffer,buffer_f32,_state.image_xscale);
    buffer_write(_buffer,buffer_f32,_state.image_yscale);
    buffer_write(_buffer,buffer_f32,_state.image_angle);
    buffer_write(_buffer,buffer_f32,_state.image_alpha);
    buffer_write(_buffer,buffer_u8,_state.color);
    buffer_write(_buffer,buffer_string,_state.room_name);
    buffer_write(_buffer,buffer_string,_state.level_key);
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
    // Both NUL terminators must be within this packet, not stale grow-buffer data.
    if (_size < 48 || _size > NET_PACKET_MAX_SIZE || _size > buffer_get_size(_buffer)) return undefined;
    if (buffer_peek(_buffer,0,buffer_u8) != NET_PACKET_STATE) return undefined;
    var _room_end = net_packet_string_end(_buffer,NET_STATE_HEADER,_size,127);
    if (_room_end < 0) return undefined;
    var _key_end = net_packet_string_end(_buffer,_room_end+1,_size,127);
    if (_key_end < 0 || _key_end+14 != _size) return undefined;
    buffer_seek(_buffer,buffer_seek_start,1);
    var _state = {};
    _state.seq = buffer_read(_buffer,buffer_u16);
    _state.x = buffer_read(_buffer,buffer_f32);
    _state.y = buffer_read(_buffer,buffer_f32);
    _state.image_index = buffer_read(_buffer,buffer_u8);
    _state.image_blend = buffer_read(_buffer,buffer_s32);
    _state.image_xscale = buffer_read(_buffer,buffer_f32);
    _state.image_yscale = buffer_read(_buffer,buffer_f32);
    _state.image_angle = buffer_read(_buffer,buffer_f32);
    _state.image_alpha = buffer_read(_buffer,buffer_f32);
    _state.color = buffer_read(_buffer,buffer_u8);
    _state.room_name = buffer_read(_buffer,buffer_string);
    _state.level_key = buffer_read(_buffer,buffer_string);
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
        || _state.image_blend < 0 || _state.image_blend > 16777215 || net_room_asset(_state.room_name) == -1
        || !net_key_valid(_state.level_key)) return undefined;
    _state.sprite_index = net_builtin_skin_sprite(_state.skin,_state.color,_state.is_dead);
    _state.image_index = _state.image_index mod max(1,sprite_get_number(_state.sprite_index));
    return _state;
}
function net_write_hello(_buffer,_reply) {
    buffer_seek(_buffer,buffer_seek_start,0);
    buffer_write(_buffer,buffer_u8,NET_PACKET_HELLO);
    buffer_write(_buffer,buffer_u8,NET_PROTOCOL);
    buffer_write(_buffer,buffer_u8,_reply ? 1 : 0);
    buffer_write(_buffer,buffer_string,net_clean_name(tcc_steam_get_persona_name()));
    buffer_write(_buffer,buffer_f64,global.net_join_time);
    buffer_write(_buffer,buffer_u8,net_cosmetic_id(global.skinselected,49));
    buffer_write(_buffer,buffer_u8,net_cosmetic_id(global.hatselected,67));
    return buffer_tell(_buffer);
}
function net_decode_hello(_buffer,_size) {
    if (_size < 14 || _size > 150 || _size > buffer_get_size(_buffer)
        || buffer_peek(_buffer,0,buffer_u8) != NET_PACKET_HELLO) return undefined;
    var _end = net_packet_string_end(_buffer,3,_size,128);
    if (_end < 0 || _end+11 != _size) return undefined;
    buffer_seek(_buffer,buffer_seek_start,1);
    var _proto = buffer_read(_buffer,buffer_u8);
    var _reply = buffer_read(_buffer,buffer_u8);
    var _username = buffer_read(_buffer,buffer_string);
    var _time = buffer_read(_buffer,buffer_f64);
    var _skin = net_cosmetic_id(buffer_read(_buffer,buffer_u8),49);
    var _hat = net_cosmetic_id(buffer_read(_buffer,buffer_u8),67);
    if (_proto != NET_PROTOCOL || _reply > 1 || !net_finite(_time)) return undefined;
    return {username:net_clean_name(_username),join_time:_time,skin:_skin,hat:_hat,reply:_reply == 1};
}
function net_write_ping(_buffer) {
    buffer_seek(_buffer,buffer_seek_start,0);
    buffer_write(_buffer,buffer_u8,NET_PACKET_PING);
    buffer_write(_buffer,buffer_u32,current_time & $FFFFFFFF);
    buffer_write(_buffer,buffer_string,room_get_name(room));
    buffer_write(_buffer,buffer_string,global.net_level_key);
    buffer_write(_buffer,buffer_string,global.net_session_sid);
    return buffer_tell(_buffer);
}
function net_decode_ping(_buffer,_size) {
    if (_size < 8 || _size > NET_PACKET_MAX_SIZE || _size > buffer_get_size(_buffer)
        || buffer_peek(_buffer,0,buffer_u8) != NET_PACKET_PING) return undefined;
    var _room_end = net_packet_string_end(_buffer,5,_size,127);
    if (_room_end < 0) return undefined;
    var _key_end = net_packet_string_end(_buffer,_room_end+1,_size,127);
    if (_key_end < 0) return undefined;
    var _sid_end = net_packet_string_end(_buffer,_key_end+1,_size,64);
    if (_sid_end < 0 || _sid_end+1 != _size) return undefined;
    buffer_seek(_buffer,buffer_seek_start,1);
    var _ping = {};
    _ping.stamp = buffer_read(_buffer,buffer_u32);
    _ping.room_name = buffer_read(_buffer,buffer_string);
    _ping.level_key = buffer_read(_buffer,buffer_string);
    _ping.sid = buffer_read(_buffer,buffer_string);
    if (net_room_asset(_ping.room_name) == -1) return undefined;
    if (_ping.level_key != "" && !net_key_valid(_ping.level_key)) return undefined;
    return _ping;
}

// -----------------------------------------------------------------------------
// Lifetime
// -----------------------------------------------------------------------------

/// @function		net_init()
/// @description	Initialize online multiplayer globals once at boot. Later calls only
///					repair missing state, so a live lobby or queued join is never lost.
function net_init() {
	// Note: global.onlinemultiplayersettings is set in scr_loading()
	// and loaded from save in scr_loadsettings(). Do NOT set it here.
	if (variable_global_exists("net_ready") && global.net_ready) return;
	global.net_ready = true;
	global.net_active = false;
	global.net_lobby_id = -1;
	global.net_is_host = false;
	global.net_owner_id = int64(0);
	global.net_my_steam_id = int64(0);
	global.net_send_timer = 0;
	global.net_send_seq = 0;
	global.net_send_signature = "";
	global.net_send_idle = 0;
	global.net_ping_at = 0;
	global.net_last_skin = 0;
	global.net_join_time = 0;
	global.net_refresh_tick = 0;
	global.net_refresh_forced_tick = -1;
	global.net_p2p_accept = false;
	global.net_host_retry_at = 0;
	global.net_presence_group = "";

	// Connection banner: 0 idle, 1 creating, 2 joining, 3 success, 4 failure.
	global.net_connect_state = 0;
	global.net_connect_timer = 0;
	global.net_connect_flash = 0;
	global.net_connect_msg = "";
	global.net_notices = [];

	// Native create/join calls outlive rooms. Clear only on their reply.
	global.net_pending_join = -1;
	global.net_create_pending = false;
	global.net_join_pending_id = -1;
	global.net_join_defer_tick = -1;
	global.net_host_intent = false;
	global.net_join_announced = false;

	// Following: set when this player joined someone else's session.
	global.net_follow_host = false;

	global.net_players = ds_map_create();
	global.net_members = ds_map_create();
	global.net_member_list = [];
	global.net_lobby_data = ds_map_create();
	global.net_recv_buffer = buffer_create(1024, buffer_grow, 1);
	global.net_send_buffer = buffer_create(1024, buffer_grow, 1);

	net_session_init();
	net_levelshare_init();
}

/// The manager is persistent and created once at boot. Anything that might run
/// before (or after an unexpected destroy) can call this safely.
function net_ensure_manager() {
	net_init();
	if (!instance_exists(o_networkmanager)) instance_create(0, 0, o_networkmanager);
}

function net_enabled() {
	return variable_global_exists("onlinemultiplayersettings") && global.onlinemultiplayersettings == 1
		&& platform_steam() && tcc_steam_initialised() && !TCC_GAMEPLAY_QA;
}

/// @function		net_cleanup()
/// @description	Release every networking resource (game end only).
function net_cleanup() {
    if (!variable_global_exists("net_ready") || !global.net_ready) return;
    net_leave_lobby(false);
    net_levelshare_cleanup();
    net_session_cleanup();
    net_avatars_free();
    if (ds_exists(global.net_players,ds_type_map)) ds_map_destroy(global.net_players);
    if (ds_exists(global.net_members,ds_type_map)) ds_map_destroy(global.net_members);
    if (ds_exists(global.net_lobby_data,ds_type_map)) ds_map_destroy(global.net_lobby_data);
    if (buffer_exists(global.net_recv_buffer)) buffer_delete(global.net_recv_buffer);
    if (buffer_exists(global.net_send_buffer)) buffer_delete(global.net_send_buffer);
    global.net_ready = false;
}

function net_notice(_text) {
    if (!variable_global_exists("net_notices")) return;
    array_push(global.net_notices,{text:string(_text),timer:300});
    if (array_length(global.net_notices) > 4) array_delete(global.net_notices,0,1);
    show_debug_message("[NET] " + string(_text));
}
function net_flash(_success,_text) {
    global.net_connect_state = _success ? 3 : 4;
    global.net_connect_flash = _success ? 180 : 300;
    global.net_connect_msg = string(_text);
}

// Forget everything about the current lobby without consuming native replies.
function net_reset_lobby_state() {
    ds_map_clear(global.net_players);
    ds_map_clear(global.net_members);
    ds_map_clear(global.net_lobby_data);
    global.net_member_list = [];
    global.net_active = false;
    global.net_lobby_id = -1;
    global.net_is_host = false;
    global.net_owner_id = int64(0);
    global.net_follow_host = false;
    global.net_join_defer_tick = timing_tick_id();
    net_session_lobby_reset();
    net_levelshare_lobby_reset();
    net_presence_update(true);
}

/// Leave the current lobby, handing ownership to the longest-standing member.
function net_leave_lobby(_announce = true) {
    if (!global.net_active) return;
    net_send_bye();
    if (global.net_is_host && array_length(global.net_member_list) > 0) {
        var _earliest = infinity, _successor = int64(0);
        for (var _i = 0; _i < array_length(global.net_member_list); ++_i) {
            var _member = global.net_member_list[_i];
            var _data = global.net_players[? string(_member)];
            var _time = is_struct(_data) ? _data.join_time : infinity;
            if (_successor == 0 || _time < _earliest) { _earliest = _time; _successor = _member; }
        }
        if (_successor != 0) tcc_steam_lobby_set_owner_id(_successor);
    }
    tcc_steam_lobby_leave();
    for (var _i = 0; _i < array_length(global.net_member_list); ++_i) tcc_steam_net_close_p2p_session(global.net_member_list[_i]);
    net_reset_lobby_state();
    if (_announce) net_notice(loc("NET_LEFT_SESSION"));
}

// Copy the requested ID while async_load is live; never retain its DS map.
function net_queue_join(_lobby_id) {
    global.net_host_intent = false;
    net_leave_lobby(false);
    global.net_pending_join = _lobby_id;
    global.net_join_defer_tick = timing_tick_id();
    global.net_connect_state = 2; global.net_connect_timer = 0;
}

/// Join a friend's session from the overlay, the Friends panel or a launch
/// argument. Joining is an explicit opt-in, so it also enables the setting.
function net_request_join(_lobby_id) {
    if (!platform_steam() || !tcc_steam_initialised()) return false;
    _lobby_id = int64(_lobby_id);
    if (_lobby_id == 0) return false;
    net_ensure_manager();
    if (global.onlinemultiplayersettings != 1) {
        global.onlinemultiplayersettings = 1;
        scr_savesettings();
        net_notice(loc("NET_ONLINE_ENABLED"));
    }
    if (global.net_active && global.net_lobby_id == _lobby_id) {
        // Already here: take us to wherever the host is right now.
        if (!global.net_is_host) { global.net_follow_host = true; net_follow_now(); }
        return true;
    }
    if (global.net_pending_join == _lobby_id || global.net_join_pending_id == _lobby_id) return true;
    net_queue_join(_lobby_id);
    global.net_follow_host = true;
    global.net_join_announced = false;
    return true;
}

/// @function		net_host_lobby()
/// @description	Create a new friends-only Steam lobby so friends can join via overlay.
function net_host_lobby() {
	if (!net_enabled() || global.net_active || global.net_pending_join != -1) return;
	global.net_host_intent = true;
	if (global.net_create_pending || global.net_join_pending_id != -1) return;
	global.net_my_steam_id = tcc_steam_get_user_steam_id();
	global.net_create_pending = true;
	if (!tcc_steam_lobby_create(steam_lobby_type_friends_only, clamp(round(global.netmaxplayers), 2, NET_MAX_LOBBY))) {
		global.net_create_pending = false; global.net_host_intent = false;
		global.net_host_retry_at = current_time + 15000;
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
		global.net_follow_host = false;
		net_flash(false,loc("NET_JOIN_FAILED"));
	}
}

// Even an unexplained native success has changed the extension's current lobby.
// Fail closed: leave it and clear active state without consuming another reply.
function net_discard_lobby_reply(_success) {
    if (_success) tcc_steam_lobby_leave();
    net_reset_lobby_state();
}

function net_lobby_set(_key,_value) {
    _value = string(_value);
    if (global.net_lobby_data[? _key] == _value) return;
    if (tcc_steam_lobby_set_data(_key,_value)) global.net_lobby_data[? _key] = _value;
}

// Called whenever we start owning the lobby (creation or migration).
function net_become_host() {
    global.net_is_host = true;
    global.net_follow_host = false;
    ds_map_clear(global.net_lobby_data);
    net_lobby_set("game_name",NET_GAME_NAME);
    net_lobby_set("proto",NET_PROTOCOL);
    net_lobby_set("host_name",net_clean_name(tcc_steam_get_persona_name()));
    net_session_publish(true);
}

function net_refresh_members() {
    ds_map_clear(global.net_members);
    global.net_member_list = [];
    var _count = tcc_steam_lobby_get_member_count();
    if (!net_finite(_count)) _count = 0;
    for (var _i = 0; _i < _count; ++_i) {
        var _member = tcc_steam_lobby_get_member_id(_i);
        if (!is_numeric(_member) || _member == 0) continue;
        global.net_members[? string(_member)] = _member;
        if (_member != global.net_my_steam_id) array_push(global.net_member_list,_member);
    }
    // Ghosts belong to current members only.
    var _key = ds_map_find_first(global.net_players);
    while (!is_undefined(_key)) {
        var _next = ds_map_find_next(global.net_players,_key);
        if (!ds_map_exists(global.net_members,_key)) net_remove_player(global.net_players[? _key].steam_id,false);
        _key = _next;
    }
    return _count;
}
function net_lobby_member(_sender) {
    if (_sender == global.net_my_steam_id) return false;
    return ds_map_exists(global.net_members,string(_sender));
}
function net_member_count() {
    return global.net_active ? array_length(global.net_member_list) + 1 : 0;
}

/// Lobby lifecycle, run every simulation tick by the persistent manager.
function net_tick() {
    if (!variable_global_exists("net_ready") || !global.net_ready) return;
    if (!platform_steam() || !tcc_steam_initialised()) return;
    if (global.net_my_steam_id == 0) global.net_my_steam_id = tcc_steam_get_user_steam_id();
    if (!global.net_p2p_accept) {
        // P2P packets are accepted only from current lobby members (net_lobby_member).
        tcc_steam_net_set_auto_accept_p2p_sessions(true);
        global.net_p2p_accept = true;
    }

    // Cold launch from Steam ("+connect_lobby <id>") once the menu is up.
    if (variable_global_exists("net_launch_lobby") && global.net_launch_lobby != ""
        && room != r_loading && room != r_logointro) {
        var _launch = global.net_launch_lobby;
        global.net_launch_lobby = "";
        var _launch_id = int64(0);
        try { _launch_id = int64(_launch); } catch (_error) { _launch_id = int64(0); }
        if (_launch_id != 0) net_request_join(_launch_id);
    }

    if (!net_enabled()) {
        if (global.net_active) net_leave_lobby(false);
        global.net_pending_join = -1;
        global.net_host_intent = false;
        return;
    }

    // Queued join (must wait a tick after leaving a lobby).
    if (global.net_pending_join != -1 && !global.net_create_pending
        && global.net_join_pending_id == -1 && timing_tick_id() > global.net_join_defer_tick) {
        net_join_lobby(global.net_pending_join);
    }
    // Everyone online owns a lobby, so friends can always find and join them.
    if (!global.net_active && global.net_pending_join == -1 && !global.net_create_pending
        && global.net_join_pending_id == -1 && timing_tick_id() > global.net_join_defer_tick
        && current_time >= global.net_host_retry_at && room != r_loading && room != r_logointro) net_host_lobby();

    if (!global.net_active) return;

    if (timing_tick_id() >= global.net_refresh_tick) {
        global.net_refresh_tick = timing_tick_id() + NET_REFRESH_TICKS;
        if (net_refresh_members() <= 0) {
            // Steam no longer reports us in the lobby (kicked, lobby lost or offline).
            net_reset_lobby_state();
            net_notice(loc("NET_DISCONNECTED"));
            return;
        }
        var _owner = tcc_steam_lobby_get_owner_id();
        if (_owner != 0 && _owner != global.net_owner_id) {
            var _was_host = global.net_is_host;
            global.net_owner_id = _owner;
            global.net_is_host = (_owner == global.net_my_steam_id);
            if (global.net_is_host && !_was_host) {
                net_become_host();
                if (array_length(global.net_member_list) > 0) net_notice(loc("NET_YOU_ARE_HOST"));
            } else if (!global.net_is_host) {
                net_session_owner_changed();
            }
        }
        net_presence_update(false);
    }

    if (global.net_is_host) net_session_publish(false);
    else net_follow_poll();

    net_send_player_state();
    net_send_ping();
    net_receive_packets();
    net_update_ghosts();
    net_levelshare_tick();
}

// -----------------------------------------------------------------------------
// Sending
// -----------------------------------------------------------------------------
function net_send_to(_member,_size,_reliable) {
    return tcc_steam_net_packet_send(_member,global.net_send_buffer,_size,
        _reliable ? steam_net_packet_type_reliable : steam_net_packet_type_unreliable);
}
function net_broadcast(_size,_reliable) {
    for (var _i = 0; _i < array_length(global.net_member_list); ++_i) net_send_to(global.net_member_list[_i],_size,_reliable);
}
function net_send_hello(_target,_reply) {
    if (!global.net_active) return;
    var _size = net_write_hello(global.net_send_buffer,_reply);
    if (_target == -1) net_broadcast(_size,true); else net_send_to(_target,_size,true);
}
function net_send_bye() {
    if (!global.net_active) return;
    buffer_seek(global.net_send_buffer,buffer_seek_start,0);
    buffer_write(global.net_send_buffer,buffer_u8,NET_PACKET_BYE);
    net_broadcast(1,true);
}

/// @function		net_send_player_state()
/// @description	Send local player state to peers on the same level only. The
///					rate adapts to the crowd and drops while the player is idle.
function net_send_player_state() {
    if (!global.net_active || global.net_level_key == "") return;
    var _player = instance_exists(o_player) ? instance_find(o_player,0) : noone;
    var _dead = _player == noone;
    if (_dead) _player = instance_exists(o_playerdead) ? instance_find(o_playerdead,0) : noone;
    if (_player == noone) return;
    var _targets = [];
    for (var _i = 0; _i < array_length(global.net_member_list); ++_i) {
        var _member = global.net_member_list[_i];
        var _data = global.net_players[? string(_member)];
        if (is_struct(_data) && _data.level_key == global.net_level_key) array_push(_targets,_member);
    }
    var _count = array_length(_targets);
    if (_count == 0) return;
    var _skin = net_cosmetic_id(global.skinselected,49);
    if (!_dead) {
        if (_player.customskin == 1) _skin = 0;
        global.net_last_skin = _skin;
    } else _skin = global.net_last_skin;
    var _state = {
        seq:global.net_send_seq, x:_player.x, y:_player.y, image_index:floor(_player.image_index) & $FF,
        image_blend:(!_dead && _player.customskin == 1) ? c_white : _player.image_blend,
        image_xscale:_dead ? 1 : _player.image_xscale, image_yscale:_dead ? 1 : _player.image_yscale,
        image_angle:_dead ? 0 : _player.image_angle, image_alpha:clamp(_player.image_alpha,0,1),
        color:net_cosmetic_id(global.color,4), room_name:room_get_name(room), level_key:global.net_level_key, skin:_skin,
        // Imported hats/items use the equipped built-in choice as the peer fallback.
        hat:net_cosmetic_id(global.hatselected,67), item:net_cosmetic_id(global.itemselected,3),
        hsp:_dead ? 0 : _player.hsp, vsp:_dead ? 0 : _player.vsp,
        is_dead:_dead ? 1 : 0, zerogrv:_dead ? 0 : _player.zerogrv
    };
    // Large lobbies share bandwidth; a motionless player only needs a heartbeat.
    var _interval = _count <= 8 ? 1 : (_count <= 16 ? 2 : (_count <= 32 ? 3 : 4));
    var _signature = string(_state.x) + "," + string(_state.y) + "," + string(_state.image_index) + "," + string(_state.image_xscale)
        + "," + string(_state.image_angle) + "," + string(_state.image_alpha) + "," + string(_state.is_dead) + "," + string(_state.color)
        + "," + string(_state.image_blend) + "," + _state.level_key;
    if (_signature == global.net_send_signature) {
        if (global.net_send_idle < 1000) global.net_send_idle += 1;
        if (global.net_send_idle > 2) _interval = max(_interval,12);
    } else {
        global.net_send_signature = _signature;
        global.net_send_idle = 0;
    }
    global.net_send_timer++;
    if (global.net_send_timer < _interval) return;
    global.net_send_timer = 0;
    global.net_send_seq = (global.net_send_seq + 1) & $FFFF;
    var _size = net_write_state(global.net_send_buffer,_state);
    for (var _i = 0; _i < _count; ++_i) net_send_to(_targets[_i],_size,false);
}

function net_send_ping() {
    if (!global.net_active || current_time < global.net_ping_at) return;
    global.net_ping_at = current_time + NET_PING_INTERVAL_MS;
    net_broadcast(net_write_ping(global.net_send_buffer),false);
}

// -----------------------------------------------------------------------------
// Receiving
// -----------------------------------------------------------------------------

/// @function		net_receive_packets()
/// @description	Poll and process incoming P2P packets from lobby members only.
function net_receive_packets() {
    if (!global.net_active) return;
    var _buf = global.net_recv_buffer;
    var _processed = 0;
    while (_processed < 128 && tcc_steam_net_packet_receive()) {
        ++_processed;
        var _sender = tcc_steam_net_packet_get_sender_id();
        var _size = tcc_steam_net_packet_get_size();
        if (!net_finite(_size) || _size < 1 || _size > NET_CHUNK_MAX_SIZE) continue;
        if (!net_lobby_member(_sender)) {
            // A newcomer's first packet can beat Steam's membership callback.
            if (global.net_refresh_forced_tick == timing_tick_id()) continue;
            global.net_refresh_forced_tick = timing_tick_id();
            net_refresh_members();
            if (!net_lobby_member(_sender)) continue;
        }
        tcc_steam_net_packet_get_data(_buf);
        if (_size > buffer_get_size(_buf)) continue;
        var _type = buffer_peek(_buf,0,buffer_u8);
        var _key = string(_sender);
        switch (_type) {
            case NET_PACKET_STATE:
                var _state = net_decode_state(_buf,_size);
                if (is_undefined(_state)) break;
                // A peer returning after a timeout can recover from its next valid state.
                if (!ds_map_exists(global.net_players,_key))
                    net_register_player(_sender,tcc_steam_get_user_persona_name_sync(_sender),current_time,_state.skin,_state.hat);
                net_apply_ghost_state(global.net_players[? _key],_state);
                break;
            case NET_PACKET_HELLO:
                var _hello = net_decode_hello(_buf,_size);
                if (is_undefined(_hello)) break;
                net_register_player(_sender,_hello.username,_hello.join_time,_hello.skin,_hello.hat);
                var _peer = global.net_players[? _key];
                _peer.username = _hello.username; _peer.join_time = _hello.join_time;
                _peer.skin = _hello.skin; _peer.hat = _hello.hat; _peer.last_update = current_time;
                // Only answer an announcement: replying to replies caused endless ping-pong.
                if (!_hello.reply) {
                    net_send_hello(_sender,true);
                    if (_peer.announced == false) net_notice(string_replace(loc("NET_PLAYER_JOINED"),"{NAME}",_peer.username));
                }
                _peer.announced = true;
                break;
            case NET_PACKET_BYE:
                if (_size == 1) net_remove_player(_sender,true);
                break;
            case NET_PACKET_PING:
                var _ping = net_decode_ping(_buf,_size);
                if (is_undefined(_ping)) break;
                if (!ds_map_exists(global.net_players,_key))
                    net_register_player(_sender,tcc_steam_get_user_persona_name_sync(_sender),current_time,0,0);
                var _data = global.net_players[? _key];
                if (_data.level_key != _ping.level_key) _data.ghost_alpha = 0;
                var _sid_changed = _data.sid != _ping.sid;
                _data.room_name = _ping.room_name;
                _data.level_key = _ping.level_key;
                _data.sid = _ping.sid;
                _data.last_update = current_time;
                if (_sid_changed) net_er_peer_joined_run(_sender,_ping.sid);
                buffer_seek(global.net_send_buffer,buffer_seek_start,0);
                buffer_write(global.net_send_buffer,buffer_u8,NET_PACKET_PONG);
                buffer_write(global.net_send_buffer,buffer_u32,_ping.stamp);
                net_send_to(_sender,5,false);
                break;
            case NET_PACKET_PONG:
                if (_size != 5 || !ds_map_exists(global.net_players,_key)) break;
                var _stamp = buffer_peek(_buf,1,buffer_u32);
                var _rtt = ((current_time & $FFFFFFFF) - _stamp) & $FFFFFFFF;
                if (_rtt < 60000) {
                    var _peer_rtt = global.net_players[? _key];
                    _peer_rtt.rtt = _peer_rtt.rtt < 0 ? _rtt : lerp(_peer_rtt.rtt,_rtt,0.3);
                }
                break;
            case NET_PACKET_ER_PICKS:
                net_er_receive_picks(_buf,_size);
                break;
            case NET_PACKET_LEVEL_REQUEST:
            case NET_PACKET_LEVEL_CHUNK:
            case NET_PACKET_LEVEL_DENY:
                net_levelshare_receive(_sender,_type,_buf,_size);
                break;
        }
    }
}

/// @function		net_register_player(steam_id, username, join_time, skin, hat)
/// @description	Register a remote player in our tracking map. Returns true if new.
function net_register_player(_steam_id, _username, _join_time, _skin, _hat) {
	var _key = string(_steam_id);
	if (ds_map_exists(global.net_players, _key)) return false;

	// Start ghost at player's position so it doesn't lerp from (0,0)
	var _init_x = 0;
	var _init_y = 0;
	if (instance_exists(o_player)) {
		_init_x = o_player.x;
		_init_y = o_player.y;
	}
	var _data = {
		steam_id: _steam_id,
		username: net_clean_name(_username),
		x: _init_x, y: _init_y, prev_x: _init_x, prev_y: _init_y,
		target_x: _init_x, target_y: _init_y,
		sprite_index: s_playerred, image_index: 0, image_blend: c_white,
		image_xscale: 1, image_yscale: 1, image_angle: 0, image_alpha: 1,
		color: 0, room_name: "", level_key: "", sid: "",
		skin: net_cosmetic_id(_skin,49), hat: net_cosmetic_id(_hat,67), item: 0,
		hsp: 0, vsp: 0, is_dead: 0, zerogrv: 0,
		seq: -1, recv_tick: -1, predict: 0, snap: true, rtt: -1,
		join_time: net_finite(_join_time) ? _join_time : current_time,
		last_update: current_time,
		announced: false,
		ghost_alpha: 0  // Fade in
	};
	ds_map_add(global.net_players, _key, _data);
	tcc_steam_user_set_played_with(_steam_id);
	show_debug_message("[NET] Player joined: " + _data.username + " (ID: " + _key + ")");
	return true;
}

/// @function		net_remove_player(steam_id, announce)
/// @description	Remove a remote player from our tracking map
function net_remove_player(_steam_id, _announce = false) {
	var _key = string(_steam_id);
	if (ds_map_exists(global.net_players, _key)) {
		var _data = global.net_players[? _key];
		show_debug_message("[NET] Player left: " + _data.username);
		if (_announce && _data.announced) net_notice(string_replace(loc("NET_PLAYER_LEFT"),"{NAME}",_data.username));
		ds_map_delete(global.net_players, _key);
	}
	tcc_steam_net_close_p2p_session(_steam_id);
}

// Unreliable packets can arrive late or twice: only newer sequence numbers count.
function net_seq_newer(_seq,_last) {
    if (_last < 0) return true;
    var _delta = (_seq - _last) & $FFFF;
    return _delta > 0 && _delta < 32768;
}
function net_apply_ghost_state(_data,_state) {
    if (!net_seq_newer(_state.seq,_data.seq)) return false;
    _data.seq = _state.seq;
    if (_data.level_key != _state.level_key) { _data.ghost_alpha = 0; _data.snap = true; }
    _data.target_x = _state.x;
    _data.target_y = _state.y;
    var _fields = ["sprite_index","image_index","image_blend","image_xscale","image_yscale","image_angle","image_alpha",
        "color","room_name","level_key","skin","hat","item","hsp","vsp","is_dead","zerogrv"];
    for (var _i = 0; _i < array_length(_fields); ++_i) variable_struct_set(_data,_fields[_i],variable_struct_get(_state,_fields[_i]));
    // Sender provides the death position/alpha; never invent RNG motion on the peer.
    if (_state.is_dead) _data.snap = true;
    _data.recv_tick = timing_tick_id();
    _data.predict = 0;
    _data.last_update = current_time;
    return true;
}

/// @function		net_get_ghost_count()
/// @description	Returns the number of ghosts on the current level
function net_get_ghost_count() {
	var _count = 0;
	if (global.net_level_key == "") return 0;
	var _key = ds_map_find_first(global.net_players);
	while (!is_undefined(_key)) {
		if (global.net_players[? _key].level_key == global.net_level_key) _count++;
		_key = ds_map_find_next(global.net_players, _key);
	}
	return _count;
}

/// @function		net_update_ghosts()
/// @description	Advance ghost positions once per simulation tick. Missing
///					packets are bridged by brief prediction; teleports snap.
function net_update_ghosts() {
	if (!global.net_active) return;
	var _tick = timing_tick_id();
	var _key = ds_map_find_first(global.net_players);
	while (!is_undefined(_key)) {
		var _data = global.net_players[? _key];
		var _next_key = ds_map_find_next(global.net_players, _key);
		// Timeout: remove players we haven't heard from in 10 seconds
		if (current_time - _data.last_update > NET_PEER_TIMEOUT_MS) {
			net_remove_player(_data.steam_id, false);
			_key = _next_key;
			continue;
		}
		if (!_data.is_dead && _data.recv_tick != _tick && _data.predict < 3) {
			_data.target_x += _data.hsp;
			_data.target_y += _data.vsp;
			_data.predict += 1;
		}
		_data.prev_x = _data.x;
		_data.prev_y = _data.y;
		var _dx = _data.target_x - _data.x;
		var _dy = _data.target_y - _data.y;
		if (_data.snap || abs(_dx) > 96 || abs(_dy) > 96) {
			_data.x = _data.target_x; _data.y = _data.target_y;
			_data.prev_x = _data.x; _data.prev_y = _data.y;
			_data.snap = false;
		} else {
			_data.x += _dx * 0.6;
			_data.y += _dy * 0.6;
		}
		var _visible = (global.net_level_key != "" && _data.level_key == global.net_level_key) ? 1 : 0;
		_data.ghost_alpha = lerp(_data.ghost_alpha, _visible, _visible ? 0.05 : 0.1);
		_key = _next_key;
	}
}

// Render frames between simulation ticks use the same blend as native actors.
function net_draw_blend() {
	if (!variable_global_exists("tcc_timing") || global.renderfps <= TCC_SIM_HZ) return 1;
	return clamp(global.tcc_timing.accumulator_us * TCC_SIM_HZ / 1000000, 0, 1);
}

/// @function		net_draw_ghosts()
/// @description	Draw all ghost players that are on the same level
function net_draw_ghosts() {
	if (!global.net_active || global.net_level_key == "") return;
	var _blend = net_draw_blend();
	var _key = ds_map_find_first(global.net_players);
	while (!is_undefined(_key)) {
		var _data = global.net_players[? _key];
		_key = ds_map_find_next(global.net_players, _key);
		if (_data.level_key != global.net_level_key || _data.ghost_alpha * _data.image_alpha <= 0.01) continue;
		var _gx = _data.x, _gy = _data.y;
		if (point_distance(_data.prev_x, _data.prev_y, _data.x, _data.y) <= 64) {
			_gx = lerp(_data.prev_x, _data.x, _blend);
			_gy = lerp(_data.prev_y, _data.y, _blend);
		}
		var _alpha = _data.ghost_alpha * _data.image_alpha;
		// Compensate for sprite offset mismatch between local and remote player.
		// When in zero gravity, the sender's sprite offset was (16,16) and position
		// was shifted +16. The local sprite offset may differ, so we correct here.
		var _sox = sprite_get_xoffset(_data.sprite_index);
		var _soy = sprite_get_yoffset(_data.sprite_index);
		var _zg = _data.zerogrv * 16;
		draw_sprite_ext(_data.sprite_index, _data.image_index, _gx + (_sox - _zg), _gy + (_soy - _zg),
			_data.image_xscale, _data.image_yscale, _data.image_angle, _data.image_blend, _alpha);
		net_draw_ghost_hat(_data, _gx, _gy);
		net_draw_ghost_item(_data, _gx, _gy);

		// Username above the ghost (visual center accounts for zero gravity offset)
		var _center_x = _gx + 16 - _zg;
		var _text_y = _gy - 8 - _zg;
		draw_set_font(fnt_multiplayerfont);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_set_alpha(_alpha);
		draw_set_color(c_black);
		draw_text(_center_x + 1, _text_y + 1, _data.username);
		draw_text(_center_x - 1, _text_y - 1, _data.username);
		draw_text(_center_x + 1, _text_y - 1, _data.username);
		draw_text(_center_x - 1, _text_y + 1, _data.username);
		draw_set_color(c_white);
		draw_text(_center_x, _text_y, _data.username);
		draw_set_alpha(1);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
}

/// @function		net_draw_ghost_hat(data, x, y)
/// @description	Draw a ghost player's hat (simplified version of scr_hats)
function net_draw_ghost_hat(_data, _gx, _gy) {
	var _hat = _data.hat;
	if (_hat <= 0) return;
	var _zg = _data.zerogrv * 16;
	var _hatspr = s_graduationhat;
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
	draw_sprite_ext(_hatspr, 0, _gx + 16 - _zg, _gy + 8 - _zg, 1, 1, _data.image_angle, c_white, _data.ghost_alpha * _data.image_alpha);
}

/// @function		net_draw_ghost_item(data, x, y)
/// @description	Draw a ghost player's item (simplified version of scr_items)
function net_draw_ghost_item(_data, _gx, _gy) {
	var _item = _data.item;
	if (_item <= 0) return;
	var _zg = _data.zerogrv * 16;
	var _itemspr = -1;
	switch(_item) {
		case 1: _itemspr = s_paintbrushitem; break;
		case 2: _itemspr = s_floweritem; break;
		case 3: _itemspr = s_shielditem; break;
		default: return;
	}
	// Simple bobbing animation using current_time
	var _rot = sin(current_time / 500) * 30;
	draw_sprite_ext(_itemspr, 0, _gx - _zg, _gy + 20 - _zg, 1, 1, _rot, c_white, _data.ghost_alpha * _data.image_alpha);
}

// -----------------------------------------------------------------------------
// Steam async events (lobby management). The manager receives these in every room.
// -----------------------------------------------------------------------------

/// @function		net_handle_async_steam(async_map)
/// @description	Handle Steam async events for lobby management
function net_handle_async_steam(_map) {
	if (!variable_global_exists("net_ready") || !global.net_ready) return;
	var _event_type = _map[? "event_type"];

	switch (_event_type) {
		case "lobby_created":
			var _create_owned = global.net_create_pending;
			global.net_create_pending = false;
			var _host_wanted = global.net_host_intent;
			global.net_host_intent = false;
			if (!_create_owned || !_host_wanted || global.net_pending_join != -1
				|| global.net_active || !net_enabled()) {
				// The extension has already selected this created lobby. Leave it
				// before issuing the desired join on a later logical tick.
				if (!global.net_active) net_discard_lobby_reply(_map[? "success"]);
				break;
			}
			if (_map[? "success"]) {
				global.net_lobby_id = _map[? "lobby_id"];
				global.net_active = true;
				global.net_join_time = current_time;
				global.net_owner_id = global.net_my_steam_id;
				global.net_refresh_tick = 0;
				net_refresh_members();
				net_become_host();
				show_debug_message("[NET] Lobby created! ID: " + string(global.net_lobby_id));
			} else {
				// Hosting is automatic and silent; retry later instead of nagging.
				global.net_host_retry_at = current_time + 30000;
				show_debug_message("[NET] Failed to create lobby");
			}
			break;

		case "lobby_joined":
			var _reply_id = _map[? "lobby_id"];
			var _expected_id = global.net_join_pending_id;
			if (_expected_id == -1) {
				// No unexplained response can activate the manager or move rooms.
				if (!global.net_active) net_discard_lobby_reply(_map[? "success"]);
				break;
			}
			global.net_join_pending_id = -1;
			if (global.net_pending_join != _expected_id) {
				// A newer invite replaced this one: settle this reply first.
				net_discard_lobby_reply(_map[? "success"]);
				break;
			}
			global.net_pending_join = -1;
			if (!_map[? "success"]) {
				tcc_steam_lobby_leave();
				net_reset_lobby_state();
				net_flash(false, loc("NET_JOIN_FAILED"));
				show_debug_message("[NET] Failed to join lobby");
				break;
			}
			// Steam reports IO success even for a full or vanished lobby, and it may
			// change the instance bits of the ID: validate the lobby we actually entered.
			global.net_lobby_id = _reply_id;
			global.net_my_steam_id = tcc_steam_get_user_steam_id();
			var _members = net_refresh_members();
			var _game = tcc_steam_lobby_get_data("game_name");
			var _proto = tcc_steam_lobby_get_data("proto");
			if (_members <= 0) {
				tcc_steam_lobby_leave();
				net_reset_lobby_state();
				net_flash(false, loc("NET_SESSION_UNAVAILABLE"));
				break;
			}
			if (_game != NET_GAME_NAME || _proto != string(NET_PROTOCOL)) {
				tcc_steam_lobby_leave();
				net_reset_lobby_state();
				net_flash(false, loc("NET_VERSION_MISMATCH"));
				break;
			}
			global.net_active = true;
			global.net_join_time = current_time;
			global.net_refresh_tick = 0;
			global.net_owner_id = tcc_steam_lobby_get_owner_id();
			global.net_is_host = (global.net_owner_id == global.net_my_steam_id);
			global.net_follow_host = !global.net_is_host;
			net_send_hello(-1, false);
			global.net_ping_at = 0;
			if (global.net_is_host) {
				net_become_host();
			} else {
				net_session_joined_lobby();
			}
			var _host = tcc_steam_lobby_get_data("host_name");
			net_flash(true, string_replace(loc("NET_JOINED_SESSION"), "{NAME}", net_clean_name(_host)));
			net_presence_update(true);
			show_debug_message("[NET] Joined lobby! Host: " + string(global.net_is_host));
			break;

		case "lobby_chat_update":
			if (!global.net_active || _map[? "lobby_id"] != global.net_lobby_id) break;
			var _flags = _map[? "change_flags"];
			var _uid = _map[? "user_id"];
			// Left, disconnected, kicked or banned.
			if (_flags & (2 | 4 | 8 | 16)) {
				if (_uid == global.net_my_steam_id) {
					net_reset_lobby_state();
					net_notice(loc("NET_DISCONNECTED"));
					break;
				}
				net_remove_player(_uid, true);
			}
			// Membership and ownership are re-read on the next tick.
			global.net_refresh_tick = 0;
			break;

		case "lobby_join_requested":
			// Someone accepted our invite or clicked "Join Game" in the Steam overlay,
			// in any room or mode.
			var _lobby_id = _map[? "lobby_id"];
			show_debug_message("[NET] Join request received for lobby: " + string(_lobby_id));
			net_request_join(_lobby_id);
			break;

		case "avatar_image_loaded":
			net_friends_avatar_loaded(_map);
			break;
	}
}

/// @function		net_is_main_game()
/// @description	Returns whether we're currently in gameplay (not menus, editor, etc.)
function net_is_main_game() {
	return net_room_class(room) == NET_ROOM_PLAY;
}

/// Steam friends list grouping ("Playing with ...").
function net_presence_update(_force) {
	if (!platform_steam() || !tcc_steam_initialised()) return;
	var _group = "";
	if (global.net_active && net_member_count() > 1) _group = string(global.net_lobby_id) + "|" + string(net_member_count());
	if (!_force && _group == global.net_presence_group) return;
	global.net_presence_group = _group;
	if (_group == "") {
		tcc_steam_set_rich_presence("steam_player_group", "");
		tcc_steam_set_rich_presence("steam_player_group_size", "");
	} else {
		tcc_steam_set_rich_presence("steam_player_group", string(global.net_lobby_id));
		tcc_steam_set_rich_presence("steam_player_group_size", string(net_member_count()));
	}
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
        seq:7, x:96, y:128, image_index:7, image_blend:c_white, image_xscale:1, image_yscale:1,
        image_angle:0, image_alpha:1, color:3, room_name:"r_lvl1", level_key:"r_lvl1", skin:0, hat:1, item:2,
        hsp:4, vsp:-3, is_dead:0, zerogrv:0
    };
    var _size = net_write_state(_buffer,_state);
    var _read = net_decode_state(_buffer,_size);
    // Keep a bounded, synthetic-packet diagnostic before the first assertion so
    // the native runner can distinguish serialization and validation failures.
    var _probe = {
        size:_size, packetType:buffer_peek(_buffer,0,buffer_u8),
        roomEnd:net_packet_string_end(_buffer,NET_STATE_HEADER,_size,127),
        wireRoom:buffer_peek(_buffer,NET_STATE_HEADER,buffer_string),
        roomAsset:string(net_room_asset("r_lvl1")),
        wireSeq:buffer_peek(_buffer,1,buffer_u16),
        wireX:buffer_peek(_buffer,3,buffer_f32), wireY:buffer_peek(_buffer,7,buffer_f32),
        wireBlend:buffer_peek(_buffer,12,buffer_s32),
        wireScaleX:buffer_peek(_buffer,16,buffer_f32), wireScaleY:buffer_peek(_buffer,20,buffer_f32),
        wireAlpha:buffer_peek(_buffer,28,buffer_f32), wireColor:buffer_peek(_buffer,32,buffer_u8),
        numericFloat:net_finite(buffer_peek(_buffer,3,buffer_f32)),
        numericByte:net_cosmetic_id(buffer_peek(_buffer,32,buffer_u8),4),
        decoded:!is_undefined(_read)
    };
    if (!is_undefined(_read)) {
        _probe.skin = _read.skin; _probe.hat = _read.hat; _probe.item = _read.item;
        _probe.sprite = string(_read.sprite_index); _probe.expectedSprite = string(s_playerblue);
    }
    show_debug_message("TCC_GHOST_PACKET_PROBE " + json_stringify(_probe));
    scr_port_assert(!is_undefined(_read),"well-formed ghost packet decodes");
    scr_port_assert(_read.x == 96 && _read.y == 128 && _read.seq == 7 && _read.level_key == "r_lvl1"
        && _read.sprite_index == s_playerblue && _read.hat == 1 && _read.item == 2,
        "ghost packet retains position, level key and built-in cosmetic choices");
    for (var _length = 0; _length < _size; ++_length)
        scr_port_assert(is_undefined(net_decode_state(_buffer,_length)),"truncated packet cannot read stale receive-buffer bytes");
    buffer_poke(_buffer,3,buffer_u32,$7fc00000);
    scr_port_assert(is_undefined(net_decode_state(_buffer,_size)),"NaN player position is rejected");
    _state.image_xscale = 0;
    _size = net_write_state(_buffer,_state);
    scr_port_assert(is_undefined(net_decode_state(_buffer,_size)),"zero sprite scale is rejected");
    _state.image_xscale = 1;
    _state.room_name = "o_player";
    _size = net_write_state(_buffer,_state);
    scr_port_assert(is_undefined(net_decode_state(_buffer,_size)) && net_room_asset("o_player") == -1,
        "peer room names cannot refer to object or sprite resources");
    _state.room_name = "r_lvl1";
    _state.level_key = "";
    _size = net_write_state(_buffer,_state);
    scr_port_assert(is_undefined(net_decode_state(_buffer,_size)),"ghost state requires a level key");
    _state.level_key = "ws:123";
    _state.skin = 255; _state.hat = 255; _state.item = 255;
    _size = net_write_state(_buffer,_state);
    _read = net_decode_state(_buffer,_size);
    scr_port_assert(_read.skin == 0 && _read.hat == 0 && _read.item == 0 && _read.sprite_index == s_playerblue,
        "unknown/custom cosmetic ids have built-in or unequipped fallbacks");
    var _ghost = {level_key:"r_lvl2",ghost_alpha:1,x:0,y:0,seq:-1,snap:false};
    scr_port_assert(net_apply_ghost_state(_ghost,_read),"first state is accepted");
    scr_port_assert(_ghost.ghost_alpha == 0 && _ghost.target_x == 96 && _ghost.snap,"level change resets ghost fade and snaps");
    _read.seq = 6;
    scr_port_assert(!net_apply_ghost_state(_ghost,_read),"older sequence is ignored");
    scr_port_assert(net_seq_newer(1,65535) && !net_seq_newer(65535,1) && net_seq_newer(0,-1),"sequence numbers wrap");
    _state.seq = 8; _state.skin = 0; _state.is_dead = 1; _state.image_alpha = 0.5; _state.x = 100;
    _size = net_write_state(_buffer,_state);
    _read = net_decode_state(_buffer,_size);
    var _seed = random_get_seed();
    net_apply_ghost_state(_ghost,_read);
    scr_port_assert(_ghost.is_dead == 1 && _ghost.sprite_index == s_playerdead && _ghost.target_x == 100
        && _ghost.image_alpha == 0.5 && random_get_seed() == _seed,
        "ghost death follows sender without acquiring a PNG or consuming gameplay RNG");
    _state.seq = 9; _state.is_dead = 0; _state.image_alpha = 1; _state.x = 96;
    _size = net_write_state(_buffer,_state);
    net_apply_ghost_state(_ghost,net_decode_state(_buffer,_size));
    scr_port_assert(_ghost.is_dead == 0 && _ghost.sprite_index == s_playerblue && _ghost.image_alpha == 1,
        "respawn restores built-in appearance after remote death");
    buffer_seek(_buffer,buffer_seek_start,0);
    buffer_write(_buffer,buffer_u8,NET_PACKET_HELLO);
    buffer_write(_buffer,buffer_u8,NET_PROTOCOL);
    buffer_write(_buffer,buffer_u8,0);
    buffer_write(_buffer,buffer_string,"Player");
    buffer_write(_buffer,buffer_f64,123);
    buffer_write(_buffer,buffer_u8,0);
    buffer_write(_buffer,buffer_u8,0);
    _size = buffer_tell(_buffer);
    var _hello = net_decode_hello(_buffer,_size);
    scr_port_assert(!is_undefined(_hello) && _hello.username == "Player" && !_hello.reply,"identity packet round trip");
    scr_port_assert(is_undefined(net_decode_hello(_buffer,_size-1)),"truncated identity packet rejected");
    buffer_poke(_buffer,1,buffer_u8,1);
    scr_port_assert(is_undefined(net_decode_hello(_buffer,_size)),"other protocol versions are rejected");
    buffer_seek(_buffer,buffer_seek_start,0);
    buffer_write(_buffer,buffer_u8,NET_PACKET_PING);
    buffer_write(_buffer,buffer_u32,77);
    buffer_write(_buffer,buffer_string,"r_lvl1");
    buffer_write(_buffer,buffer_string,"");
    buffer_write(_buffer,buffer_string,"");
    _size = buffer_tell(_buffer);
    var _ping = net_decode_ping(_buffer,_size);
    scr_port_assert(!is_undefined(_ping) && _ping.stamp == 77 && _ping.level_key == "" && _ping.room_name == "r_lvl1",
        "menu keepalive round trip");
    scr_port_assert(is_undefined(net_decode_ping(_buffer,_size-1)),"truncated keepalive rejected");
    buffer_delete(_buffer);
    for (var _skin = 0; _skin < 50; ++_skin) for (var _color = 0; _color < 5; ++_color)
        scr_port_assert(sprite_exists(net_builtin_skin_sprite(_skin,_color)),"every built-in ghost skin/color resolves locally");
    show_debug_message("TCC_ONLINE_COSMETICS_SELF_CHECK_PASS");
}
