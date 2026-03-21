/// @description Level select data - provides page-based level data for the level select menu

/// Returns an array of page structs for the level select menu.
/// Each page has: { title, levels, is_world, challenge_id }
/// Each level has: { text, roomselect, levelmusic, level_num, is_challenge, challenge_id }
function get_levelselect_pages() {
	var _pages = [];

	// World 1-5 main campaign pages
	array_push(_pages, build_world_page("World 1", 1, 20, m_basics));
	array_push(_pages, build_world_page("World 2", 21, 40, m_owthespikes));
	array_push(_pages, build_world_page("World 3", 41, 60, m_everythingismoving));
	array_push(_pages, build_world_page_w4());
	array_push(_pages, build_world_page("World 5", 81, 100, m_thecastle));

	// Challenge pages (from loaded challenge definitions)
	if (variable_global_exists("challenge_order")) {
		for (var i = 0; i < ds_list_size(global.challenge_order); i++) {
			var _id = global.challenge_order[| i];
			var _def = scr_challenge_get_def(_id);
			if (is_undefined(_def)) continue;
			if (_def.is_custom == true) continue;
			if (_def.enabled != 1) continue;
			var _page = build_challenge_page(_def);
			if (array_length(_page.levels) > 0) {
				array_push(_pages, _page);
			}
		}
	}

	return _pages;
}

/// Builds a world page with levels sharing the same music track.
function build_world_page(_title, _start, _end, _music) {
	var _page = {
		title: _title,
		levels: [],
		is_world: true,
		challenge_id: -1
	};
	for (var i = _start; i <= _end; i++) {
		var _room = asset_get_index("r_lvl" + string(i));
		array_push(_page.levels, {
			text: string(i),
			roomselect: _room,
			levelmusic: _music,
			level_num: i,
			is_challenge: false,
			challenge_id: -1
		});
	}
	return _page;
}

/// Builds World 4 page with its mixed music tracks.
function build_world_page_w4() {
	var _page = {
		title: "World 4",
		levels: [],
		is_world: true,
		challenge_id: -1
	};
	for (var i = 61; i <= 80; i++) {
		var _music;
		if (i <= 68) _music = m_corruptedworld;
		else if (i == 69) _music = m_breakfromcorruption;
		else _music = m_lesscorruption;

		array_push(_page.levels, {
			text: string(i),
			roomselect: asset_get_index("r_lvl" + string(i)),
			levelmusic: _music,
			level_num: i,
			is_challenge: false,
			challenge_id: -1
		});
	}
	return _page;
}

/// Builds a challenge page from a challenge definition struct.
/// Derives individual level rooms from the room name prefix pattern.
function build_challenge_page(_def) {
	var _title = scr_challenge_get_title(_def);
	var _page = {
		title: _title,
		levels: [],
		is_world: false,
		challenge_id: _def.id
	};

	var _music_asset = -1;
	if (is_string(_def.music) && _def.music != "") {
		_music_asset = asset_get_index(_def.music);
	}

	// If the def has an explicit rooms array, use it
	if (array_length(_def.rooms) > 0) {
		for (var i = 0; i < array_length(_def.rooms); i++) {
			if (_def.rooms[i] == "") continue;
			var _room = asset_get_index(_def.rooms[i]);
			if (_room == -1) continue;
			array_push(_page.levels, {
				text: string(array_length(_page.levels) + 1),
				roomselect: _room,
				levelmusic: _music_asset,
				level_num: array_length(_page.levels) + 1,
				is_challenge: true,
				challenge_id: _def.id
			});
		}
	}
	// Otherwise, derive rooms from the prefix pattern (e.g., r_kaizolvl1, r_kaizolvl2...)
	else if (_def.room != "") {
		var _base_room = _def.room;
		// Extract prefix by finding "lvl" and keeping everything up to and including it
		var _lvl_pos = string_pos("lvl", _base_room);
		if (_lvl_pos > 0) {
			var _prefix = string_copy(_base_room, 1, _lvl_pos + 2); // e.g., "r_kaizolvl"
			var _num = 1;
			while (asset_get_index(_prefix + string(_num)) != -1) {
				array_push(_page.levels, {
					text: string(_num),
					roomselect: asset_get_index(_prefix + string(_num)),
					levelmusic: _music_asset,
					level_num: _num,
					is_challenge: true,
					challenge_id: _def.id
				});
				_num++;
			}
		}
	}

	return _page;
}
