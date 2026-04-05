// Modal popup blocks this menu
if instance_exists(o_popup) { exit }

// Close
if keyboard_check_pressed(vk_escape) {
	with (o_workshopchallengecreatorbg) instance_destroy()
	with (o_workshopchallengecreatorbutton) instance_destroy()
	with (o_workshoplevelselectbutton) instance_destroy()
	instance_destroy()
	exit
}

var mx = mouse_x
var my = mouse_y
var clicked = mouse_check_button_pressed(mb_left)

// Scroll
if mouse_wheel_up() { global.workshopchallenge_scroll -= 60 }
if mouse_wheel_down() { global.workshopchallenge_scroll += 60 }

// Layout grid + scrollmax (based on filter)
var list_top_y = 320
var _tile_h = 140
var _grid_x1 = 110
var _grid_x2 = 520
var _cols = 2
var visible_count = 0
var my_steam_id = steam_get_user_steam_id()

for (var i = 0; i < array_length(level_buttons); i++) {
	var btn = level_buttons[i]
	if instance_exists(btn) {
		var show = 1
		if filter_mode = 1 {
			if btn.loaded = 1 {
				show = (btn.owner_id == my_steam_id)
			} else {
				show = 0
			}
		}
		btn.filtered_out = 1 - show
		if show = 1 {
			var _col = visible_count mod _cols
			var _row = visible_count div _cols
			btn.base_x = (_col == 0) ? _grid_x1 : _grid_x2
			btn.base_y = list_top_y + (_row * _tile_h)
			btn.grid_col = _col
			visible_count += 1
		}
	}
}

var _total_rows = ceil(visible_count / _cols)
var _visible_rows = 2
global.workshopchallenge_scrollmax = 0
if _total_rows > _visible_rows { global.workshopchallenge_scrollmax = (_total_rows - _visible_rows) * _tile_h }

if global.workshopchallenge_scroll < 0 { global.workshopchallenge_scroll = 0 }
if global.workshopchallenge_scroll > global.workshopchallenge_scrollmax { global.workshopchallenge_scroll = global.workshopchallenge_scrollmax }

// Compute current selection + stats
selected_count = 0
diamond_sum = 0
var diff_sum = 0

var ids = []
var idx = 0
var order_i = 1

for (var s = 0; s < array_length(level_buttons); s++) {
	var btn2 = level_buttons[s]
	if instance_exists(btn2) {
		btn2.selected_order = 0
		if btn2.selected = 1 {
			btn2.selected_order = order_i
			order_i += 1

			selected_count += 1
			diamond_sum += btn2.diamond_time
			diff_sum += btn2.difficulty
			ids[idx] = btn2.level
			idx += 1
		}
	}
}

if selected_count > 0 { difficulty_avg = diff_sum / selected_count } else { difficulty_avg = 0 }

// Title editing toggle
var title_box_x1 = 160
var title_box_y1 = 110
var title_box_x2 = 864
var title_box_y2 = 150

if clicked {
	var _in_title = (mx > title_box_x1 && mx < title_box_x2 && my > title_box_y1 && my < title_box_y2)
	if _in_title {
		if editing_title = 0 {
			editing_title = 1
			keyboard_string = title
		} else {
			editing_title = 0
			title = keyboard_string
			keyboard_string = ""
		}
	} else if editing_title = 1 {
		// Click outside title field deselects it
		editing_title = 0
		title = keyboard_string
		keyboard_string = ""
	}
}

if editing_title = 1 {
	badwords()
	if string_length(keyboard_string) > 40 {
		keyboard_string = string_copy(keyboard_string,1,40)
	}
	title = keyboard_string
}

signature_current = scr_workshopchallenge_signature(title, ids)
