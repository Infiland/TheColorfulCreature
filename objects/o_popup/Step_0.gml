box_y = lerp(box_y, box_target_y, 0.2 * (60 / global.maxfps))

// Keep buttons attached to the popup box
var btn_y = box_y + box_h - 80
if instance_exists(btn_ok) { btn_ok.y = btn_y }
if instance_exists(btn_yes) { btn_yes.y = btn_y }
if instance_exists(btn_no) { btn_no.y = btn_y }

// ESC closes (acts as "No" for confirm dialogs)
if keyboard_check_pressed(vk_escape) {
	if mode = 1 && is_callable(cb_no) { cb_no() }
	instance_destroy()
}

