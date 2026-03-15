depth = -50000

// Full-screen hitbox to block underlying mouse events
x = 0
y = 0
image_xscale = room_width / 5
image_yscale = room_height / 5

title = ""
message = ""
mode = 0 // 0 = OK, 1 = YES/NO

ok_text = "OK"
yes_text = "Yes"
no_text = "No"

cb_ok = undefined
cb_yes = undefined
cb_no = undefined

box_x1 = 200
box_x2 = 824
box_h = 240
box_y = -300
box_target_y = 240

btn_ok = noone
btn_yes = noone
btn_no = noone

if variable_global_exists("popup_config") {
	var cfg = global.popup_config
	global.popup_config = undefined
	if is_struct(cfg) {
		if variable_struct_exists(cfg, "title") { title = string(cfg.title) }
		if variable_struct_exists(cfg, "message") { message = string(cfg.message) }
		if variable_struct_exists(cfg, "mode") { mode = cfg.mode }

		if variable_struct_exists(cfg, "ok_text") { ok_text = string(cfg.ok_text) }
		if variable_struct_exists(cfg, "yes_text") { yes_text = string(cfg.yes_text) }
		if variable_struct_exists(cfg, "no_text") { no_text = string(cfg.no_text) }

		if variable_struct_exists(cfg, "cb_ok") { cb_ok = cfg.cb_ok }
		if variable_struct_exists(cfg, "cb_yes") { cb_yes = cfg.cb_yes }
		if variable_struct_exists(cfg, "cb_no") { cb_no = cfg.cb_no }
	}
}

var btn_w = 200
var btn_h = 60
var btn_ix = btn_w / 5
var btn_iy = btn_h / 5

if mode = 0 {
	btn_ok = instance_create(0, 0, o_popupbutton)
	with (btn_ok) {
		popup = other.id
		role = 0
		text = other.ok_text
		image_xscale = btn_ix
		image_yscale = btn_iy
		x = 512 - (btn_w / 2)
		y = other.box_y + other.box_h - 80
	}
} else {
	btn_yes = instance_create(0, 0, o_popupbutton)
	with (btn_yes) {
		popup = other.id
		role = 1
		text = other.yes_text
		image_xscale = btn_ix
		image_yscale = btn_iy
		x = 512 - btn_w - 20
		y = other.box_y + other.box_h - 80
	}

	btn_no = instance_create(0, 0, o_popupbutton)
	with (btn_no) {
		popup = other.id
		role = 2
		text = other.no_text
		image_xscale = btn_ix
		image_yscale = btn_iy
		x = 512 + 20
		y = other.box_y + other.box_h - 80
	}
}
