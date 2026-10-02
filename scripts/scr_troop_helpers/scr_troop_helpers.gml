/// scr_troop_on_ground() — is the troop standing on a solid block?
function scr_troop_on_ground() {
	return place_meeting(x, y+1, o_anyblock) || scr_slope_place(x, y+1) != noone;
}

/// scr_troop_head_clear() — is there space above the troop to jump?
function scr_troop_head_clear() {
	return !place_meeting(x, y-32, o_anyblock) && scr_slope_place(x, y-32) == noone;
}

/// scr_troop_wall_ahead(dx) — is there a solid wall at horizontal offset dx?
function scr_troop_wall_ahead(dx) {
	return place_meeting(x + dx, y, o_anyblock) || scr_slope_place(x + dx, y) != noone;
}

/// scr_troop_ledge_ahead(dx) — is there a block to climb over at offset dx?
function scr_troop_ledge_ahead(dx) {
	return place_meeting(x + dx, y - 1, o_anyblock) || scr_slope_place(x + dx, y - 1) != noone;
}

// One geometry cache per room. Culling changes activation, not geometry; a
// cache rebuild explicitly activates all navigation geometry before sampling.
// Create/destroy, editor rotation, and key-block state changes mark it dirty.
function scr_troop_nav_cache() {
	if (!variable_global_exists("troop_navigation")) {
		global.troop_navigation = {
			room_id: room, grid: -1, generation: 0, built_generation: -1,
			width: 0, height: 0, builds: 0, cache_hits: 0, build_us: 0,
			path_requests: 0, path_us: 0, search_iterations: 0, max_search_iterations: 0,
			budget_time: -1, budget_used: 0, budget_deferrals: 0,
			geometry_reference_us: 0, geometry_instance_us: 0,
			geometry_comparisons: 0, geometry_mismatches: 0
		};
	}
	var _cache = global.troop_navigation;
	if (_cache.room_id != room) {
		if (ds_exists(_cache.grid, ds_type_grid)) ds_grid_destroy(_cache.grid);
		_cache.grid = -1;
		_cache.room_id = room;
		_cache.generation += 1;
		_cache.built_generation = -1;
	}
	return _cache;
}

function scr_troop_nav_mark_dirty() {
	var _cache = scr_troop_nav_cache();
	_cache.generation += 1;
}

function scr_troop_nav_grid() {
	var _cache = scr_troop_nav_cache();
	var _width = max(1, ceil(room_width / 32));
	var _height = max(1, ceil(room_height / 32));
	// Diagnostic comparison only: run this same geometry builder and path
	// algorithm for every request, keeping the ordinary request budget/inputs.
	// Shipping builds always reuse the cache. No historical-baseline claim.
	var _force_rebuild = false;
	if (TCC_GAMEPLAY_QA && qa_active()) {
		var _qa_spec = global.tcc_qa.spec;
		_force_rebuild = variable_struct_exists(_qa_spec, "navMode") && _qa_spec.navMode == "rebuild";
	}
	if (!_force_rebuild && ds_exists(_cache.grid, ds_type_grid)
		&& _cache.built_generation == _cache.generation
		&& _cache.width == _width && _cache.height == _height) {
		_cache.cache_hits += 1;
		return _cache.grid;
	}
	var _start = get_timer();
	// Deactivated instances are absent from collision queries. They must be
	// included once per geometry revision, then normal camera culling resumes.
	timing_activate_object(o_anyblock);
	timing_activate_object(o_ladder);
	timing_activate_object(o_onewayupblock);
	timing_activate_object(o_slope);
	timing_activate_object(o_lockedblock);
	timing_activate_object(o_unlockedblock);
	if (ds_exists(_cache.grid, ds_type_grid)) ds_grid_destroy(_cache.grid);
	_cache.grid = scr_troop_build_grid();
	_cache.width = _width;
	_cache.height = _height;
	_cache.built_generation = _cache.generation;
	_cache.builds += 1;
	_cache.build_us += get_timer() - _start;
	return _cache.grid;
}

function scr_troop_nav_request_ready() {
	var _cache = scr_troop_nav_cache();
	// The persistent controller advances a deterministic step counter. Defer excess
	// requests to the next step; keep their old path/reactive movement meanwhile.
	if (!variable_global_exists("troop_nav_step")) global.troop_nav_step = 0;
	if (_cache.budget_time != global.troop_nav_step) {
		_cache.budget_time = global.troop_nav_step;
		_cache.budget_used = 0;
	}
	if (_cache.budget_used >= 2) {
		_cache.budget_deferrals += 1;
		return false;
	}
	_cache.budget_used += 1;
	return true;
}

function scr_troop_nav_stats() {
	var _c = scr_troop_nav_cache();
	var _mode = "cached";
	if (TCC_GAMEPLAY_QA && qa_active()) {
		var _qa_spec = global.tcc_qa.spec;
		if (variable_struct_exists(_qa_spec, "navMode") && _qa_spec.navMode == "rebuild") _mode = "rebuild-per-request";
	}
	return {room_name: room_get_name(room), generation: _c.generation,
		cache_mode:_mode,
		builds: _c.builds, cache_hits: _c.cache_hits, build_us: _c.build_us,
		path_requests: _c.path_requests, path_us: _c.path_us,
		search_iterations: _c.search_iterations, max_search_iterations: _c.max_search_iterations,
		budget_deferrals: _c.budget_deferrals, width: _c.width, height: _c.height,
		geometry_mode:scr_troop_nav_geometry_mode(),
		geometry_reference_us:_c.geometry_reference_us, geometry_instance_us:_c.geometry_instance_us,
		geometry_comparisons:_c.geometry_comparisons, geometry_mismatches:_c.geometry_mismatches};
}

function scr_troop_nav_solid_point(_px, _py, _list) {
	ds_list_clear(_list);
	var _count = collision_point_list(_px, _py, o_anyblock, false, true, _list, false);
	for (var _i = 0; _i < _count; ++_i) {
		var _block = _list[| _i];
		// Moving platforms are transient support, not static navigation walls.
		if (_block.object_index != o_movingplatforms
			&& !object_is_ancestor(_block.object_index, o_movingplatforms)) return true;
	}
	if (scr_slope_rect(_px, _py, _px, _py) != noone) return true;
	var _lock = instance_position(_px, _py, o_lockedblock);
	if (_lock != noone && _lock.sprite_index == s_lockedblock) return true;
	_lock = instance_position(_px, _py, o_unlockedblock);
	return _lock != noone && _lock.sprite_index == s_lockedblock;
}

function scr_troop_defeat(_count_kill = false) {
	if (troop_defeated) return;
	troop_defeated = true;
	if (_count_kill && room != r_leveleditor) increase_stat("totalenemykills", "QUESTenemykills", 1);
	instance_destroy();
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
function scr_troop_build_grid_reference() {
	var _gw = max(1, ceil(room_width / 32));
	var _gh = max(1, ceil(room_height / 32));
	var _grid = ds_grid_create(_gw, _gh);
	var _points = ds_list_create();

	for (var _gy = 0; _gy < _gh; _gy++) {
		for (var _gx = 0; _gx < _gw; _gx++) {
			var _wx = _gx * 32 + 16;
			var _wy = _gy * 32 + 16;

			if scr_troop_nav_solid_point(_wx, _wy, _points) {
				ds_grid_set(_grid, _gx, _gy, NAV_SOLID);
			} else if position_meeting(_wx, _wy, o_ladder) {
				ds_grid_set(_grid, _gx, _gy, NAV_LADDER);
			} else if _gy < _gh - 1 && (scr_troop_nav_solid_point(_wx, _wy + 32, _points) || position_meeting(_wx, _wy + 32, o_onewayupblock)) {
				ds_grid_set(_grid, _gx, _gy, NAV_WALKABLE);
			} else {
				ds_grid_set(_grid, _gx, _gy, NAV_AIR);
			}
		}
	}

	ds_list_destroy(_points);
	return _grid;
}

// Bounds only select possible cell centres. Native point tests retain mask,
// transform, edge rounding, and calling-instance semantics. No authored
// coordinate/sprite approximation decides occupancy.
function scr_troop_nav_mark_cells(_grid, _instance, _kind) {
	var _padding = (_kind == 4) ? 3 : 1;
	var _x1 = max(0, ceil((_instance.bbox_left - 16 - _padding) / 32));
	var _x2 = min(ds_grid_width(_grid) - 1, floor((_instance.bbox_right - 16 + _padding) / 32));
	var _y1 = max(0, ceil((_instance.bbox_top - 16 - _padding) / 32));
	var _y2 = min(ds_grid_height(_grid) - 1, floor((_instance.bbox_bottom - 16 + _padding) / 32));
	for (var _gy = _y1; _gy <= _y2; ++_gy) {
		for (var _gx = _x1; _gx <= _x2; ++_gx) {
			if (_grid[# _gx, _gy]) continue;
			var _px = _gx * 32 + 16, _py = _gy * 32 + 16;
			var _hit = false;
			switch (_kind) {
				case 0: _hit = collision_point(_px, _py, _instance, false, true) != noone; break;
				case 1:
				case 2: _hit = position_meeting(_px, _py, _instance); break;
				// Locks retain the original selected-instance query below. A union
				// of closed masks could disagree when an open mask overlaps one.
				case 3: _hit = true; break;
				case 4:
					_hit = collision_rectangle(_px - 2, _py - 2, _px + 2, _py + 2,
						_instance, false, true) != noone
						&& scr_slope_rect_hit(_instance, _px, _py, _px, _py);
					break;
			}
			if (_hit) _grid[# _gx, _gy] = 1;
		}
	}
}

function scr_troop_build_grid_instances() {
	var _gw = max(1, ceil(room_width / 32));
	var _gh = max(1, ceil(room_height / 32));
	var _solid = ds_grid_create(_gw, _gh), _ladder = ds_grid_create(_gw, _gh);
	var _oneway = ds_grid_create(_gw, _gh), _locks = ds_grid_create(_gw, _gh);
	var _grid = ds_grid_create(_gw, _gh);
	ds_grid_clear(_solid, 0); ds_grid_clear(_ladder, 0);
	ds_grid_clear(_oneway, 0); ds_grid_clear(_locks, 0);
	try {
		// These are live, activated instances after the existing cache rebuild
		// activation. Destroyed boxes and current masks/sprites are respected.
		for (var _i = 0; _i < instance_number(o_anyblock); ++_i) {
			var _instance = instance_find(o_anyblock, _i);
			if (_instance.object_index == o_movingplatforms
				|| object_is_ancestor(_instance.object_index, o_movingplatforms)) continue;
			scr_troop_nav_mark_cells(_solid, _instance, 0);
		}
		for (var _i = 0; _i < instance_number(o_slope); ++_i) {
			scr_troop_nav_mark_cells(_solid, instance_find(o_slope, _i), 4);
		}
		for (var _i = 0; _i < instance_number(o_ladder); ++_i) {
			scr_troop_nav_mark_cells(_ladder, instance_find(o_ladder, _i), 1);
		}
		for (var _i = 0; _i < instance_number(o_onewayupblock); ++_i) {
			scr_troop_nav_mark_cells(_oneway, instance_find(o_onewayupblock, _i), 2);
		}
		for (var _i = 0; _i < instance_number(o_lockedblock); ++_i) {
			scr_troop_nav_mark_cells(_locks, instance_find(o_lockedblock, _i), 3);
		}
		for (var _i = 0; _i < instance_number(o_unlockedblock); ++_i) {
			scr_troop_nav_mark_cells(_locks, instance_find(o_unlockedblock, _i), 3);
		}
		for (var _gy = 0; _gy < _gh; ++_gy) {
			for (var _gx = 0; _gx < _gw; ++_gx) {
				if (!_solid[# _gx, _gy] && _locks[# _gx, _gy]) {
					var _px = _gx * 32 + 16, _py = _gy * 32 + 16;
					var _lock = instance_position(_px, _py, o_lockedblock);
					if (_lock != noone && _lock.sprite_index == s_lockedblock) {
						_solid[# _gx, _gy] = 1;
					} else {
						_lock = instance_position(_px, _py, o_unlockedblock);
						if (_lock != noone && _lock.sprite_index == s_lockedblock) _solid[# _gx, _gy] = 1;
					}
				}
			}
		}
		for (var _gy = 0; _gy < _gh; ++_gy) {
			for (var _gx = 0; _gx < _gw; ++_gx) {
				if (_solid[# _gx, _gy]) _grid[# _gx, _gy] = NAV_SOLID;
				else if (_ladder[# _gx, _gy]) _grid[# _gx, _gy] = NAV_LADDER;
				else if (_gy < _gh - 1 && (_solid[# _gx, _gy + 1] || _oneway[# _gx, _gy + 1])) {
					_grid[# _gx, _gy] = NAV_WALKABLE;
				} else _grid[# _gx, _gy] = NAV_AIR;
			}
		}
	} catch (_error) {
		ds_grid_destroy(_grid);
		ds_grid_destroy(_solid); ds_grid_destroy(_ladder);
		ds_grid_destroy(_oneway); ds_grid_destroy(_locks);
		throw _error;
	}
	ds_grid_destroy(_solid); ds_grid_destroy(_ladder);
	ds_grid_destroy(_oneway); ds_grid_destroy(_locks);
	return _grid;
}

function scr_troop_nav_grid_difference(_reference, _candidate) {
	var _dimensions = ds_grid_width(_reference) == ds_grid_width(_candidate)
		&& ds_grid_height(_reference) == ds_grid_height(_candidate);
	var _mismatches = 0, _samples = [], _cells = 0;
	for (var _gy = 0; _gy < min(ds_grid_height(_reference), ds_grid_height(_candidate)); ++_gy) {
		for (var _gx = 0; _gx < min(ds_grid_width(_reference), ds_grid_width(_candidate)); ++_gx) {
			_cells += 1;
			if (_reference[# _gx, _gy] != _candidate[# _gx, _gy]) {
				_mismatches += 1;
				if (array_length(_samples) < 16) array_push(_samples,
					{gx:_gx, gy:_gy, reference:_reference[# _gx, _gy], candidate:_candidate[# _gx, _gy]});
			}
		}
	}
	return {equal:_dimensions && _mismatches == 0, dimensions_equal:_dimensions,
		cells:_cells, mismatches:_mismatches, samples:_samples};
}

function scr_troop_nav_geometry_mode() {
	if (TCC_GAMEPLAY_QA && qa_active()) {
		var _spec = global.tcc_qa.spec;
		if (variable_struct_exists(_spec, "navGeometryMode")) {
			if (_spec.navGeometryMode != "instances" && _spec.navGeometryMode != "reference"
				&& _spec.navGeometryMode != "compare") throw "Unknown diagnostic navGeometryMode";
			return _spec.navGeometryMode;
		}
	}
	return "instances";
}

function scr_troop_build_grid() {
	var _mode = scr_troop_nav_geometry_mode(), _cache = scr_troop_nav_cache();
	var _start = get_timer();
	if (_mode == "reference") {
		var _reference = scr_troop_build_grid_reference();
		_cache.geometry_reference_us += get_timer() - _start;
		return _reference;
	}
	var _candidate = scr_troop_build_grid_instances();
	_cache.geometry_instance_us += get_timer() - _start;
	if (_mode == "compare") {
		_start = get_timer();
		var _reference = scr_troop_build_grid_reference();
		_cache.geometry_reference_us += get_timer() - _start;
		var _difference = scr_troop_nav_grid_difference(_reference, _candidate);
		_cache.geometry_comparisons += 1;
		_cache.geometry_mismatches += _difference.mismatches + (_difference.dimensions_equal ? 0 : 1);
		show_debug_message("TCC_NAV_GRID_EQUIVALENCE " + json_stringify({room:room_get_name(room),
			generation:_cache.generation, comparison:_cache.geometry_comparisons, result:_difference}));
		ds_grid_destroy(_reference);
		if (!_difference.equal) {
			ds_grid_destroy(_candidate);
			throw "Instance-oriented navigation grid differs from preserved reference";
		}
	}
	return _candidate;
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
	var _started = get_timer();
	var _grid = scr_troop_nav_grid();
	var _cache = scr_troop_nav_cache();
	_cache.path_requests += 1;
	var _gw = ds_grid_width(_grid);
	var _gh = ds_grid_height(_grid);

	var _sx = clamp(start_x div 32, 0, _gw - 1);
	var _sy = clamp(start_y div 32, 0, _gh - 1);
	var _ex = clamp(end_x div 32, 0, _gw - 1);
	var _ey = clamp(end_y div 32, 0, _gh - 1);

	// Bail if start or end cells are not navigable
	var _sc = _nav_cell(_grid, _sx, _sy, _gw, _gh);
	var _ec = _nav_cell(_grid, _ex, _ey, _gw, _gh);
	if _sc == NAV_SOLID || _sc == NAV_AIR {
		_cache.path_us += get_timer() - _started;
		return [];
	}
	if _ec == NAV_SOLID || _ec == NAV_AIR {
		_cache.path_us += get_timer() - _started;
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
	_cache.search_iterations += _iter;
	_cache.max_search_iterations = max(_cache.max_search_iterations, _iter);
	_cache.path_us += get_timer() - _started;

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
	// Path, ledge, high-target and boredom jumps all share this gate.
	if state == 1 && reactiontime > 0 && noreaction != 1 { return; }
	if scr_troop_head_clear() {
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
