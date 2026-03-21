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

#macro NET_MAX_PLAYERS				8
#macro NET_SEND_RATE				1  // Send every frame (60 ticks/sec at 60fps)

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
	global.net_join_time = 0		// Timestamp when we joined the lobby
	
	// Connection overlay state
	// 0 = idle, 1 = creating lobby, 2 = joining lobby, 3 = success flash, 4 = failure flash
	global.net_connect_state = 0
	global.net_connect_timer = 0     // Counts up while connecting (for dots animation)
	global.net_connect_flash = 0     // Counts down for success/failure flash display
	global.net_connect_msg = ""      // Extra message for success/failure
	global.net_pending_join = _saved_pending_join  // Restore preserved pending join
	
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
	if (global.net_lobby_id != -1) {
		// If we're host and others are in the lobby, transfer ownership
		if (global.net_is_host && steam_lobby_get_member_count() > 1) {
			// Find the player who joined earliest (longest stay)
			var _earliest_time = infinity
			var _earliest_id = -1
			var _key = ds_map_find_first(global.net_players)
			while (!is_undefined(_key)) {
				var _data = global.net_players[? _key]
				if (_data.join_time < _earliest_time) {
					_earliest_time = _data.join_time
					_earliest_id = _data.steam_id
				}
				_key = ds_map_find_next(global.net_players, _key)
			}
			if (_earliest_id != -1) {
				steam_lobby_set_owner_id(_earliest_id)
			}
		}
		steam_lobby_leave()
	}
	
	// Close P2P sessions with all players
	var _key = ds_map_find_first(global.net_players)
	while (!is_undefined(_key)) {
		var _data = global.net_players[? _key]
		steam_net_close_p2p_session(_data.steam_id)
		_key = ds_map_find_next(global.net_players, _key)
	}
	
	ds_map_destroy(global.net_players)
	buffer_delete(global.net_recv_buffer)
	buffer_delete(global.net_send_buffer)
	
	global.net_active = false
	global.net_lobby_id = -1
	global.net_is_host = false
}

/// @function		net_host_lobby()
/// @description	Create a new Steam lobby (friends only so people can join via overlay)
function net_host_lobby() {
	if (!steam_initialised()) return;
	if (global.net_active) return;
	
	global.net_my_steam_id = steam_get_user_steam_id()
	global.net_connect_state = 1
	global.net_connect_timer = 0
	steam_lobby_create(steam_lobby_type_friends_only, NET_MAX_PLAYERS)
	show_debug_message("[NET] Creating lobby...")
}

/// @function		net_join_lobby(lobby_id)
/// @description	Join an existing lobby by ID
function net_join_lobby(_lobby_id) {
	if (!steam_initialised()) return;
	if (global.net_active) return;
	
	global.net_my_steam_id = steam_get_user_steam_id()
	global.net_connect_state = 2
	global.net_connect_timer = 0
	steam_lobby_join_id(_lobby_id)
	show_debug_message("[NET] Joining lobby: " + string(_lobby_id))
}

/// @function		net_send_player_state()
/// @description	Broadcast local player position and state to all peers
function net_send_player_state() {
	if (!global.net_active) return;
	
	var _is_dead = 0
	var _zerogrv = 0
	var _px = 0, _py = 0, _spr = s_playerred, _img = 0, _blend = c_white
	var _xscale = 1, _yscale = 1, _angle = 0, _alpha = 1
	var _hsp = 0, _vsp = 0
	
	if (instance_exists(o_player)) {
		_px = o_player.x
		_py = o_player.y
		_spr = o_player.sprite_index
		_img = floor(o_player.image_index)
		_blend = o_player.image_blend
		_xscale = o_player.image_xscale
		_yscale = o_player.image_yscale
		_angle = o_player.image_angle
		_alpha = o_player.image_alpha
		_hsp = o_player.hsp
		_vsp = o_player.vsp
		_is_dead = 0
		_zerogrv = o_player.zerogrv
	} else if (instance_exists(o_playerdead)) {
		_px = o_playerdead.x
		_py = o_playerdead.y
		_spr = o_playerdead.sprite_index
		_img = floor(o_playerdead.image_index)
		_blend = o_playerdead.image_blend
		_xscale = 1
		_yscale = 1
		_angle = 0
		_alpha = o_playerdead.image_alpha
		_is_dead = 1
	} else {
		return; // Neither alive nor dead, nothing to send
	}
	
	global.net_send_timer++
	if (global.net_send_timer < NET_SEND_RATE) return;
	global.net_send_timer = 0
	
	var _buf = global.net_send_buffer
	buffer_seek(_buf, buffer_seek_start, 0)
	
	buffer_write(_buf, buffer_u8, NET_PACKET_PLAYER_STATE)
	buffer_write(_buf, buffer_f32, _px)
	buffer_write(_buf, buffer_f32, _py)
	buffer_write(_buf, buffer_s32, _spr)
	buffer_write(_buf, buffer_u8, _img)
	buffer_write(_buf, buffer_s32, _blend)
	buffer_write(_buf, buffer_f32, _xscale)
	buffer_write(_buf, buffer_f32, _yscale)
	buffer_write(_buf, buffer_f32, _angle)
	buffer_write(_buf, buffer_f32, _alpha)
	buffer_write(_buf, buffer_u8, global.color)
	buffer_write(_buf, buffer_string, room_get_name(room))
	buffer_write(_buf, buffer_u8, global.skinselected)
	buffer_write(_buf, buffer_u8, global.hatselected)
	buffer_write(_buf, buffer_u8, global.itemselected)
	buffer_write(_buf, buffer_f32, _hsp)
	buffer_write(_buf, buffer_f32, _vsp)
	buffer_write(_buf, buffer_u8, _is_dead)
	buffer_write(_buf, buffer_u8, _zerogrv)
	
	var _size = buffer_tell(_buf)
	
	// Send to all lobby members except self
	var _count = steam_lobby_get_member_count()
	for (var i = 0; i < _count; i++) {
		var _member = steam_lobby_get_member_id(i)
		if (_member != global.net_my_steam_id) {
			steam_net_packet_send(_member, _buf, _size, steam_net_packet_type_unreliable)
		}
	}
}

/// @function		net_receive_packets()
/// @description	Poll and process all incoming P2P packets
function net_receive_packets() {
	if (!global.net_active) return;
	
	var _buf = global.net_recv_buffer
	
	while (steam_net_packet_receive()) {
		var _sender = steam_net_packet_get_sender_id()
		var _size = steam_net_packet_get_size()
		
		steam_net_packet_get_data(_buf)
		buffer_seek(_buf, buffer_seek_start, 0)
		
		var _type = buffer_read(_buf, buffer_u8)
		
		switch (_type) {
			case NET_PACKET_PLAYER_STATE:
				var _px = buffer_read(_buf, buffer_f32)
				var _py = buffer_read(_buf, buffer_f32)
				var _spr = buffer_read(_buf, buffer_s32)
				var _img = buffer_read(_buf, buffer_u8)
				var _blend = buffer_read(_buf, buffer_s32)
				var _xscale = buffer_read(_buf, buffer_f32)
				var _yscale = buffer_read(_buf, buffer_f32)
				var _angle = buffer_read(_buf, buffer_f32)
				var _alpha = buffer_read(_buf, buffer_f32)
				var _color = buffer_read(_buf, buffer_u8)
				var _room_name = buffer_read(_buf, buffer_string)
				var _skin = buffer_read(_buf, buffer_u8)
				var _hat = buffer_read(_buf, buffer_u8)
				var _item = buffer_read(_buf, buffer_u8)
				var _hsp = buffer_read(_buf, buffer_f32)
				var _vsp = buffer_read(_buf, buffer_f32)
				var _is_dead = buffer_read(_buf, buffer_u8)
				var _zerogrv = buffer_read(_buf, buffer_u8)
				
				var _key = string(_sender)
				if (ds_map_exists(global.net_players, _key)) {
					var _data = global.net_players[? _key]
					_data.target_x = _px
					_data.target_y = _py
					_data.sprite_index = _spr
					_data.image_index = _img
					_data.image_blend = _blend
					_data.image_xscale = _xscale
					_data.image_yscale = _yscale
					_data.image_angle = _angle
					_data.image_alpha = _alpha
					_data.color = _color
					_data.room_name = _room_name
					_data.skin = _skin
					_data.hat = _hat
					_data.item = _item
					_data.hsp = _hsp
					_data.vsp = _vsp
					_data.is_dead = _is_dead
					_data.zerogrv = _zerogrv
					_data.last_update = current_time
					
					// Compute correct image_index from hsp/vsp for alive ghosts
					if (_is_dead == 0 && _data.skin != 23) {
						var _gi = _img // fallback to received
						if (_vsp < -0.3 && _hsp == 0) { _gi = 6 }
						if (_vsp > 0.3 && _hsp == 0) { _gi = 3 }
						if (_hsp > 0.1 && abs(_vsp) <= 0.3) { _gi = 1 }
						if (_hsp > 0.1 && _vsp < -0.3) { _gi = 7 }
						if (_hsp > 0.1 && _vsp > 0.3) { _gi = 4 }
						if (_hsp < -0.1 && abs(_vsp) <= 0.3) { _gi = 2 }
						if (_hsp < -0.1 && _vsp < -0.3) { _gi = 8 }
						if (_hsp < -0.1 && _vsp > 0.3) { _gi = 5 }
						if (_hsp == 0 && abs(_vsp) <= 0.3) { _gi = 0 }
						_data.image_index = _gi
					}
				}
				break;
				
			case NET_PACKET_PLAYER_JOIN:
				var _username = buffer_read(_buf, buffer_string)
				var _join_time = buffer_read(_buf, buffer_f64)
				var _skin = buffer_read(_buf, buffer_u8)
				var _hat = buffer_read(_buf, buffer_u8)
				net_register_player(_sender, _username, _join_time, _skin, _hat)
				// Send our info back
				net_send_join_info(_sender)
				break;
				
			case NET_PACKET_PLAYER_LEAVE:
				net_remove_player(_sender)
				break;
				
			case NET_PACKET_HOST_CHANGE:
				var _new_host_id = buffer_read(_buf, buffer_f64)
				if (_new_host_id == global.net_my_steam_id) {
					global.net_is_host = true
					show_debug_message("[NET] We are now the host!")
				}
				break;
				
			case NET_PACKET_PING:
				// Simple keep-alive, do nothing
				break;
		}
	}
}

/// @function		net_register_player(steam_id, username, join_time, skin, hat)
/// @description	Register a remote player in our tracking map
function net_register_player(_steam_id, _username, _join_time, _skin, _hat) {
	var _key = string(_steam_id)
	
	if (ds_map_exists(global.net_players, _key)) return; // Already registered
	
	// Start ghost at player's position so it doesn't lerp from (0,0)
	var _init_x = 0
	var _init_y = 0
	if (instance_exists(o_player)) {
		_init_x = o_player.x
		_init_y = o_player.y
	}
	
	var _data = {
		steam_id: _steam_id,
		username: _username,
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
		skin: _skin,
		hat: _hat,
		item: 0,
		hsp: 0,
		vsp: 0,
		is_dead: 0,
		zerogrv: 0,
		dead_timer: 0,      // Local death animation timer
		dead_drift: 0,      // Death horizontal drift
		dead_fall: 0,       // Death vertical speed
		join_time: _join_time,
		last_update: current_time,
		ghost_alpha: 0  // Fade in
	}
	
	ds_map_add(global.net_players, _key, _data)
	show_debug_message("[NET] Player joined: " + _username + " (ID: " + _key + ")")
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
	steam_net_close_p2p_session(_steam_id)
}

/// @function		net_send_join_info(target_id)
/// @description	Send our join/identity info to a specific player (or broadcast)
function net_send_join_info(_target_id) {
	var _buf = global.net_send_buffer
	buffer_seek(_buf, buffer_seek_start, 0)
	
	buffer_write(_buf, buffer_u8, NET_PACKET_PLAYER_JOIN)
	buffer_write(_buf, buffer_string, steam_get_persona_name())
	buffer_write(_buf, buffer_f64, global.net_join_time)
	buffer_write(_buf, buffer_u8, global.skinselected)
	buffer_write(_buf, buffer_u8, global.hatselected)
	
	var _size = buffer_tell(_buf)
	
	if (_target_id == -1) {
		// Broadcast to all
		var _count = steam_lobby_get_member_count()
		for (var i = 0; i < _count; i++) {
			var _member = steam_lobby_get_member_id(i)
			if (_member != global.net_my_steam_id) {
				steam_net_packet_send(_member, _buf, _size, steam_net_packet_type_reliable)
			}
		}
	} else {
		steam_net_packet_send(_target_id, _buf, _size, steam_net_packet_type_reliable)
	}
}

/// @function		net_send_leave_info()
/// @description	Broadcast that we are leaving
function net_send_leave_info() {
	var _buf = global.net_send_buffer
	buffer_seek(_buf, buffer_seek_start, 0)
	buffer_write(_buf, buffer_u8, NET_PACKET_PLAYER_LEAVE)
	var _size = buffer_tell(_buf)
	
	var _count = steam_lobby_get_member_count()
	for (var i = 0; i < _count; i++) {
		var _member = steam_lobby_get_member_id(i)
		if (_member != global.net_my_steam_id) {
			steam_net_packet_send(_member, _buf, _size, steam_net_packet_type_reliable)
		}
	}
}

/// @function		net_handle_async_steam(async_map)
/// @description	Handle Steam async events for lobby management
function net_handle_async_steam(_map) {
	var _event_type = _map[? "event_type"]
	
	switch (_event_type) {
		case "lobby_created":
			// If we have a pending join, discard our own lobby creation
			// (the player clicked "Join Game" before our lobby finished creating)
			if (global.net_pending_join != -1) {
				if (_map[? "success"]) {
					show_debug_message("[NET] Own lobby created but pending join exists - leaving it")
					steam_lobby_leave()
				}
				break;
			}
			
			if (_map[? "success"]) {
				global.net_lobby_id = _map[? "lobby_id"]
				global.net_active = true
				global.net_is_host = true
				global.net_join_time = current_time
				
				steam_lobby_set_data("game_name", "TheColorfulCreature")
				steam_lobby_set_data("version", "1.0")
				steam_lobby_set_data("host_name", steam_get_persona_name())
				steam_lobby_set_data("current_room", room_get_name(room))
				
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
			if (_map[? "success"]) {
				global.net_lobby_id = _map[? "lobby_id"]
				global.net_active = true
				global.net_join_time = current_time
				
				// Check if we are the owner
				global.net_is_host = steam_lobby_is_owner()
				
				if (!global.net_is_host) {
					// Send our join info to everyone
					net_send_join_info(-1)
					
					// Treat joining as entering level select for the client
					global.levelselect = 1
					
					// Read the host's current room from lobby data and go there
					var _host_room = steam_lobby_get_data("current_room")
					if (_host_room != "" && asset_get_index(_host_room) != -1) {
						show_debug_message("[NET] Going to host's room: " + _host_room)
						room_goto(asset_get_index(_host_room))
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
			var _flags = _map[? "change_flags"]
			var _uid = _map[? "user_id"]
			
			// Player left or disconnected
			if (_flags & 2 || _flags & 4) {
				net_remove_player(_uid)
				
				// Check if we became the new owner (Steam auto-transfers)
				if (steam_lobby_is_owner() && !global.net_is_host) {
					global.net_is_host = true
					show_debug_message("[NET] Host migration: we are now the host")
					
					// Notify everyone about the host change
					var _buf = global.net_send_buffer
					buffer_seek(_buf, buffer_seek_start, 0)
					buffer_write(_buf, buffer_u8, NET_PACKET_HOST_CHANGE)
					buffer_write(_buf, buffer_f64, global.net_my_steam_id)
					var _size = buffer_tell(_buf)
					
					var _count = steam_lobby_get_member_count()
					for (var i = 0; i < _count; i++) {
						var _member = steam_lobby_get_member_id(i)
						if (_member != global.net_my_steam_id) {
							steam_net_packet_send(_member, _buf, _size, steam_net_packet_type_reliable)
						}
					}
				}
				
				// If we're the only one left, check if we should close
				if (steam_lobby_get_member_count() <= 1 && ds_map_size(global.net_players) == 0) {
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
			
			// Leave our current lobby first if we have one
			if (global.net_active) {
				show_debug_message("[NET] Leaving current lobby to join another")
				net_send_leave_info()
				steam_lobby_leave()
				ds_map_clear(global.net_players)
				global.net_active = false
				global.net_lobby_id = -1
				global.net_is_host = false
			}
			
			// Defer the join to next frame so Steam can fully process the leave
			global.net_pending_join = _lobby_id
			global.net_connect_state = 2
			global.net_connect_timer = 0
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
		
		// Death animation: when ghost dies, play a local rising/fading animation
		if (_data.is_dead == 1) {
			if (_data.dead_timer == 0) {
				// Just died - initialize death animation
				_data.dead_drift = random_range(-2.5, 2.5)
				_data.dead_fall = random_range(-1, 1)
				_data.dead_timer = 1
			}
			_data.dead_fall += 0.25
			_data.x += _data.dead_drift
			_data.y -= (5 - _data.dead_fall)
			_data.ghost_alpha -= 0.025
			if (_data.ghost_alpha < 0) _data.ghost_alpha = 0
		} else {
			_data.dead_timer = 0
			// Snap to received position
			_data.x = _data.target_x
			_data.y = _data.target_y
		
			// Fade ghost alpha based on same room - fully opaque
			if (_data.room_name == _current_room) {
				_data.ghost_alpha = lerp(_data.ghost_alpha, 1.0, 0.05)
			} else {
				_data.ghost_alpha = lerp(_data.ghost_alpha, 0, 0.1)
			}
		}
		
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
		if (_data.room_name == _current_room && _data.ghost_alpha > 0.01) {
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
				_data.ghost_alpha
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
			draw_set_alpha(_data.ghost_alpha)
			
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
	var _alpha = _data.ghost_alpha
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
	var _alpha = _data.ghost_alpha
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
