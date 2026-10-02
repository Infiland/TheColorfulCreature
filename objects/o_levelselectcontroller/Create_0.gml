/// @description Load level select pages and spawn first page
pages = get_levelselect_pages();
total_pages = array_length(pages);

// Restore last viewed page if returning from a level
if (variable_global_exists("levelselect_page") && global.levelselect_page >= 0 && global.levelselect_page < total_pages) {
	current_page = global.levelselect_page;
} else {
	current_page = 0;
}

selected_level = 0;
keyboard_focus = false;
spawn_page_buttons();

function spawn_page_buttons() {
	// Destroy existing level buttons
	with (o_levelselectchooselevel) {
		instance_destroy();
	}

	if (current_page < 0 || current_page >= total_pages) return;

    selected_level = 0;
	var _page = pages[current_page];
	var _levels = _page.levels;
	var _count = array_length(_levels);

	var _cols = 10;
	var _start_x = 37.5;
	var _start_y = 250;
	var _spacing_x = 96;
	var _spacing_y = 101;

	for (var i = 0; i < _count; i++) {
		var _col = i mod _cols;
		var _row = i div _cols;
		var _bx = _start_x + (_col * _spacing_x);
		var _by = _start_y + (_row * _spacing_y);

		var _btn = instance_create(_bx, _by, o_levelselectchooselevel);
		_btn.image_xscale = 17;
		_btn.image_yscale = 17;
		_btn.text = _levels[i].text;
		_btn.level = _levels[i].level_num;
		_btn.roomselect = _levels[i].roomselect;
		_btn.levelmusic = _levels[i].levelmusic;
		_btn.is_challenge = _levels[i].is_challenge;
		_btn.challenge_id = _levels[i].challenge_id;
        _btn.catalog_index = i;
        _btn.level_dir = _levels[i].level_dir;
        _btn.sequence_index = _levels[i].sequence_index;
        _btn.locked = levelselect_unlocked(_levels[i]) ? 0 : 1;

	}
}
