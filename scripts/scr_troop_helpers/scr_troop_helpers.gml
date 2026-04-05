/// scr_troop_on_ground() — is the troop standing on a solid block?
function scr_troop_on_ground() {
	return place_meeting(x, y+1, o_anyblock);
}

/// scr_troop_head_clear() — is there space above the troop to jump?
function scr_troop_head_clear() {
	return !place_meeting(x, y-32, o_anyblock);
}

/// scr_troop_wall_ahead(dx) — is there a solid wall at horizontal offset dx?
function scr_troop_wall_ahead(dx) {
	return place_meeting(x + dx, y, o_anyblock);
}

/// scr_troop_ledge_ahead(dx) — is there a block to climb over at offset dx?
function scr_troop_ledge_ahead(dx) {
	return place_meeting(x + dx, y - 1, o_anyblock);
}

// =============================================================
// PATHFINDING + LADDER HELPERS
// =============================================================

/// scr_troop_on_ladder() — is the troop overlapping a ladder?
function scr_troop_on_ladder() {
	return place_meeting(x, y, o_ladder);
}

/// scr_troop_find_ladder_column(ladder_inst) — get full vertical extent of a ladder column
/// Returns struct { col_x, top_y, bottom_y }
function scr_troop_find_ladder_column(ladder_inst) {
	var _cx = ladder_inst.x;
	var _top = ladder_inst.y;
	var _bot = ladder_inst.y;

	// Scan upward
	var _check_y = _top - 32;
	while (position_meeting(_cx + 16, _check_y + 16, o_ladder)) {
		_top = _check_y;
		_check_y -= 32;
	}

	// Scan downward
	_check_y = _bot + 32;
	while (position_meeting(_cx + 16, _check_y + 16, o_ladder)) {
		_bot = _check_y;
		_check_y += 32;
	}

	return { col_x: _cx, top_y: _top, bottom_y: _bot + 32 };
}

// =============================================================
// GRID-BASED A* PATHFINDING
// =============================================================

// Grid cell types
#macro NAV_SOLID 0
#macro NAV_WALKABLE 1
#macro NAV_AIR 2
#macro NAV_LADDER 3

/// scr_troop_build_grid() — build walkability grid for the room
/// Returns ds_grid (caller must ds_grid_destroy)
function scr_troop_build_grid() {
	var _gw = room_width div 32;
	var _gh = room_height div 32;
	var _grid = ds_grid_create(_gw, _gh);

	for (var _gy = 0; _gy < _gh; _gy++) {
		for (var _gx = 0; _gx < _gw; _gx++) {
			var _wx = _gx * 32 + 16;
			var _wy = _gy * 32 + 16;

			if position_meeting(_wx, _wy, o_anyblock) {
				ds_grid_set(_grid, _gx, _gy, NAV_SOLID);
			} else if position_meeting(_wx, _wy, o_ladder) {
				ds_grid_set(_grid, _gx, _gy, NAV_LADDER);
			} else if _gy < _gh - 1 && (position_meeting(_wx, _wy + 32, o_anyblock) || position_meeting(_wx, _wy + 32, o_onewayupblock)) {
				ds_grid_set(_grid, _gx, _gy, NAV_WALKABLE);
			} else {
				ds_grid_set(_grid, _gx, _gy, NAV_AIR);
			}
		}
	}

	return _grid;
}

/// _nav_cell(grid, gx, gy, gw, gh) — safe grid read (out of bounds = SOLID)
function _nav_cell(grid, gx, gy, gw, gh) {
	if gx < 0 || gx >= gw || gy < 0 || gy >= gh { return NAV_SOLID; }
	return ds_grid_get(grid, gx, gy);
}

/// _nav_key(gx, gy) — encode grid coords as single number for ds_map keys
function _nav_key(gx, gy) {
	return gx * 10000 + gy;
}

/// scr_troop_grid_neighbors(grid, gx, gy, gw, gh) — get reachable neighbors
/// Returns array of { nx, ny, action, cost }
function scr_troop_grid_neighbors(grid, gx, gy, gw, gh) {
	var _result = [];
	var _cell = ds_grid_get(grid, gx, gy);

	if _cell == NAV_SOLID || _cell == NAV_AIR { return _result; }

	// --- WALKABLE cell ---
	if _cell == NAV_WALKABLE {
		for (var _dx = -1; _dx <= 1; _dx += 2) {
			var _nx = gx + _dx;
			var _nc = _nav_cell(grid, _nx, gy, gw, gh);

			if _nc == NAV_WALKABLE || _nc == NAV_LADDER {
				// Walk horizontally
				array_push(_result, { nx: _nx, ny: gy, action: "walk", cost: 1 });
			} else if _nc == NAV_AIR {
				// Drop off edge — scan down to find landing
				for (var _fall = 1; _fall < gh - gy; _fall++) {
					var _below = _nav_cell(grid, _nx, gy + _fall, gw, gh);
					if _below == NAV_WALKABLE || _below == NAV_LADDER {
						array_push(_result, { nx: _nx, ny: gy + _fall, action: "walk", cost: 1 + _fall });
						break;
					}
					if _below == NAV_SOLID {
						// Land on top of this block
						var _land_y = gy + _fall - 1;
						if _land_y > gy {
							var _land_c = _nav_cell(grid, _nx, _land_y, gw, gh);
							if _land_c != NAV_SOLID {
								array_push(_result, { nx: _nx, ny: _land_y, action: "walk", cost: 1 + _fall });
							}
						}
						break;
					}
				}
			}
		}

		// Jump neighbors (head clearance required)
		if _nav_cell(grid, gx, gy - 1, gw, gh) != NAV_SOLID {
			// Jump targets: up to 3 blocks up, 2 blocks horizontal, gap jumps
			var _jumps = [
				[0,-1], [0,-2], [0,-3],
				[-1,-1], [-1,-2], [-1,-3], [1,-1], [1,-2], [1,-3],
				[-2,-1], [-2,-2], [2,-1], [2,-2],
				[-2,0], [2,0], [-3,0], [3,0]
			];

			for (var i = 0; i < array_length(_jumps); i++) {
				var _jx = gx + _jumps[i][0];
				var _jy = gy + _jumps[i][1];
				if _nav_cell(grid, _jx, _jy, gw, gh) != NAV_WALKABLE { continue; }

				// Check vertical clearance above start
				var _blocked = false;
				var _top = min(gy - 1, _jy);
				for (var _cy = gy - 1; _cy >= _top; _cy--) {
					if _nav_cell(grid, gx, _cy, gw, gh) == NAV_SOLID { _blocked = true; break; }
				}
				if _blocked { continue; }

				// Check horizontal clearance at peak height
				var _lo_x = min(gx, _jx);
				var _hi_x = max(gx, _jx);
				for (var _cx = _lo_x; _cx <= _hi_x; _cx++) {
					if _nav_cell(grid, _cx, _top, gw, gh) == NAV_SOLID { _blocked = true; break; }
				}
				if _blocked { continue; }

				array_push(_result, { nx: _jx, ny: _jy, action: "jump", cost: 2 });
			}
		}
	}

	// --- LADDER cell ---
	if _cell == NAV_LADDER {
		// Climb up
		if _nav_cell(grid, gx, gy - 1, gw, gh) == NAV_LADDER {
			array_push(_result, { nx: gx, ny: gy - 1, action: "climb", cost: 1 });
		}
		// Climb down
		var _below = _nav_cell(grid, gx, gy + 1, gw, gh);
		if _below == NAV_LADDER || _below == NAV_WALKABLE {
			array_push(_result, { nx: gx, ny: gy + 1, action: "descend", cost: 1 });
		}
		// Step off horizontally
		for (var _dx = -1; _dx <= 1; _dx += 2) {
			if _nav_cell(grid, gx + _dx, gy, gw, gh) == NAV_WALKABLE {
				array_push(_result, { nx: gx + _dx, ny: gy, action: "walk", cost: 1 });
			}
		}
		// Step off at top of ladder
		if _nav_cell(grid, gx, gy - 1, gw, gh) != NAV_LADDER {
			for (var _dx = -1; _dx <= 1; _dx += 2) {
				if _nav_cell(grid, gx + _dx, gy - 1, gw, gh) == NAV_WALKABLE {
					array_push(_result, { nx: gx + _dx, ny: gy - 1, action: "walk", cost: 1 });
				}
			}
		}
	}

	return _result;
}

/// scr_troop_pathfind(start_x, start_y, end_x, end_y) — A* on walkability grid
/// Returns array of { gx, gy, action } grid steps, or empty array if no path
function scr_troop_pathfind(start_x, start_y, end_x, end_y) {
	var _grid = scr_troop_build_grid();
	var _gw = room_width div 32;
	var _gh = room_height div 32;

	var _sx = clamp(start_x div 32, 0, _gw - 1);
	var _sy = clamp(start_y div 32, 0, _gh - 1);
	var _ex = clamp(end_x div 32, 0, _gw - 1);
	var _ey = clamp(end_y div 32, 0, _gh - 1);

	// Bail if start or end cells are not navigable
	var _sc = _nav_cell(_grid, _sx, _sy, _gw, _gh);
	var _ec = _nav_cell(_grid, _ex, _ey, _gw, _gh);
	if _sc == NAV_SOLID || _sc == NAV_AIR {
		ds_grid_destroy(_grid);
		return [];
	}
	if _ec == NAV_SOLID || _ec == NAV_AIR {
		ds_grid_destroy(_grid);
		return [];
	}

	var _start_key = _nav_key(_sx, _sy);
	var _end_key = _nav_key(_ex, _ey);

	// A* data structures
	var _open = ds_priority_create();
	var _g_score = ds_map_create();
	var _came_from = ds_map_create();
	var _came_action = ds_map_create();
	var _closed = ds_map_create();

	ds_map_add(_g_score, _start_key, 0);
	ds_priority_add(_open, _start_key, abs(_ex - _sx) + abs(_ey - _sy));

	var _found = false;
	var _iter = 0;

	while (ds_priority_size(_open) > 0 && _iter < 2000) {
		_iter++;

		var _cur = ds_priority_delete_min(_open);
		if _cur == _end_key { _found = true; break; }
		if ds_map_exists(_closed, _cur) { continue; }
		ds_map_add(_closed, _cur, true);

		var _cgx = _cur div 10000;
		var _cgy = _cur mod 10000;
		var _cur_g = ds_map_find_value(_g_score, _cur);

		var _neighbors = scr_troop_grid_neighbors(_grid, _cgx, _cgy, _gw, _gh);

		for (var i = 0; i < array_length(_neighbors); i++) {
			var _n = _neighbors[i];
			var _nkey = _nav_key(_n.nx, _n.ny);

			if ds_map_exists(_closed, _nkey) { continue; }

			var _new_g = _cur_g + _n.cost;
			var _old_g = ds_map_exists(_g_score, _nkey) ? ds_map_find_value(_g_score, _nkey) : 99999;

			if _new_g < _old_g {
				ds_map_replace(_g_score, _nkey, _new_g);
				ds_map_replace(_came_from, _nkey, _cur);
				ds_map_replace(_came_action, _nkey, _n.action);

				var _h = abs(_ex - _n.nx) + abs(_ey - _n.ny);
				ds_priority_add(_open, _nkey, _new_g + _h);
			}
		}
	}

	// Reconstruct path
	var _path = [];
	if _found {
		var _key = _end_key;
		while (ds_map_exists(_came_from, _key)) {
			var _pgx = _key div 10000;
			var _pgy = _key mod 10000;
			var _act = ds_map_find_value(_came_action, _key);
			array_insert(_path, 0, { gx: _pgx, gy: _pgy, action: _act });
			_key = ds_map_find_value(_came_from, _key);
		}
	}

	// Cleanup
	ds_priority_destroy(_open);
	ds_map_destroy(_g_score);
	ds_map_destroy(_came_from);
	ds_map_destroy(_came_action);
	ds_map_destroy(_closed);
	ds_grid_destroy(_grid);

	return _path;
}

/// scr_troop_grid_to_waypoints(grid_path) — merge grid steps into nav waypoints
/// Returns array of { wx, wy, action } for scr_troop_follow_path()
function scr_troop_grid_to_waypoints(grid_path) {
	if array_length(grid_path) == 0 { return []; }

	var _waypoints = [];
	var _cur_action = grid_path[0].action;
	var _last = grid_path[0];

	for (var i = 1; i < array_length(grid_path); i++) {
		var _step = grid_path[i];

		if _step.action != _cur_action {
			array_push(_waypoints, {
				wx: _last.gx * 32 + 16,
				wy: _last.gy * 32 + 16,
				action: _cur_action
			});
			_cur_action = _step.action;
		}
		_last = _step;
	}

	// Final waypoint
	array_push(_waypoints, {
		wx: _last.gx * 32 + 16,
		wy: _last.gy * 32 + 16,
		action: _cur_action
	});

	return _waypoints;
}

/// scr_troop_build_nav_path(target_x, target_y) — build waypoint path to target
/// Returns array of { wx, wy, action } structs, or empty array for reactive fallback
function scr_troop_build_nav_path(target_x, target_y) {
	var _dy = target_y - y;

	// Same level with clear line of sight — use reactive AI
	if abs(_dy) <= 48 {
		if !collision_line(x + 16, y + 16, target_x + 16, target_y + 16, o_anyblock, false, false) {
			return [];
		}
	}

	// Run A* grid pathfinder
	var _grid_path = scr_troop_pathfind(x, y, target_x, target_y);
	if array_length(_grid_path) == 0 { return []; }

	return scr_troop_grid_to_waypoints(_grid_path);
}

/// scr_troop_follow_path() — follow the current nav_path waypoints
function scr_troop_follow_path() {
	if nav_path_index >= array_length(nav_path) {
		// Path complete
		nav_path = [];
		climbing = 0;
		return;
	}

	var _wp = nav_path[nav_path_index];
	var _dx = _wp.wx - x;
	var _dy = _wp.wy - y;

	switch (_wp.action) {
		case "walk":
			if abs(_dx) > 8 {
				move = sign(_dx);
				// Jump over walls while walking toward waypoint
				if scr_troop_on_ground() {
					if scr_troop_wall_ahead(sign(_dx) * 20) {
						if scr_troop_head_clear() { scr_troop_jump(); }
					}
				}
			} else {
				nav_path_index += 1;
			}
			break;

		case "climb":
			if abs(_dx) > 6 {
				// Walk to the ladder first
				move = sign(_dx);
				climbing = 0;
			} else {
				// At the ladder column
				move = 0;
				if place_meeting(x, y, o_ladder) {
					climbing = 1;
					climb_target_y = _wp.wy;
					if y <= _wp.wy + 8 {
						climbing = 0;
						vsp = 0;
						nav_path_index += 1;
					}
				} else {
					// Not on ladder — abort path
					nav_path = [];
					climbing = 0;
				}
			}
			break;

		case "jump":
			if scr_troop_on_ground() {
				move = sign(_dx);
				if scr_troop_head_clear() { scr_troop_jump(); }
			}
			if y <= _wp.wy + 16 {
				nav_path_index += 1;
			}
			break;

		case "descend":
			if abs(_dx) > 6 {
				move = sign(_dx);
			} else {
				move = 0;
				if place_meeting(x, y, o_ladder) {
					climbing = 0;
					vsp = 3;
					if y >= _wp.wy - 8 {
						vsp = 0;
						nav_path_index += 1;
					}
				} else {
					// Off ladder, let gravity handle it
					if scr_troop_on_ground() && abs(_dy) < 16 {
						nav_path_index += 1;
					}
				}
			}
			break;
	}
}

// =============================================================
// MOVEMENT HELPERS (original)
// =============================================================

/// scr_troop_jump() — enemy jump with sound handling
function scr_troop_jump() {
	if !place_meeting(x, y-32, o_anyblock) {
		vsp = -10.5
		onground = 0
		audio_sound_pitch(snd_enemyjump, random_range(0.6, 0.8))
		if instance_exists(o_player) {
			if distance_to_object(o_player) > 250 {
				audio_sound_gain(snd_enemyjump, 0, 1)
			} else {
				audio_sound_gain(snd_enemyjump, global.soundvolume, 1)
			}
			if distance_to_object(o_player) < 250 {
				if !audio_is_playing(snd_enemyjump) {
					audio_play_sound(snd_enemyjump, 5, 0)
				}
			}
		}
	}
}
