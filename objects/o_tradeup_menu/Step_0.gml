scr_playercontrolsconfig()

var entry_count = array_length(entries)

// Close on ESC or gamepad B
if keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_face2) {
	instance_destroy()
	exit
}

// No entries - nothing to navigate
if entry_count = 0 { exit }

// Interact - confirm trade
if os_type != os_android {
	if interactcontrols = 0 {
		key_interact = keyboard_check_pressed(ord(global.controlsinteract)) || (gamepad_button_check_pressed(0,global.gp_bind_interact))
	} else { key_interact = keyboard_check_pressed(global.controlsinteract) || (gamepad_button_check_pressed(0,global.gp_bind_interact)) }
} else {
	key_interact = false
}

if (keyboard_check_pressed(vk_enter) || key_interact) && !trade_in_progress {
	var entry = entries[selected]
	var tier_name = scr_get_tier_name(entry.tier)
	var next_tier_name = scr_get_tier_name(entry.tier + 1)

	// Verify item_ids are available
	var source_def = entry.item_def
	if is_array(global.item_ids[source_def]) {
		var _self = id
		if !instance_exists(o_popup) {
			global.popup_config = {
				title: loc("TRADE_UP"),
				message: "Trade 5x " + tier_name + " " + entry.name + " for 1x " + next_tier_name + " " + entry.name + "?",
				mode: 1,
				cb_yes: method(_self, function() {
					var entry = entries[selected]
					trade_handle = scr_execute_trade_up(entry.skin_id, entry.tier)
					if trade_handle != undefined {
						trade_in_progress = true
					}
				}),
				cb_no: undefined
			}
			instance_create(0, 0, o_popup)
		}
	}
}

// Navigate left
if selected > 0 {
	if keyboard_check(vk_left) || gamepad_button_check(0,gp_padl) {
		if press = 0 {
			selected -= 1
			press = 1
		} else {
			holdcooldown -= 1 * (60 / global.maxfps)
			if holdcooldown < 0 {
				selected -= 1
				holdcooldown = 4
			}
		}
	}
}

if keyboard_check_released(vk_left) || gamepad_button_check_released(0,gp_padl) {
	press = 0
	holdcooldown = 40
}

// Navigate right
if selected < entry_count - 1 {
	if keyboard_check(vk_right) || gamepad_button_check(0,gp_padr) {
		if press = 0 {
			selected += 1
			press = 1
		} else {
			holdcooldown -= 1 * (60 / global.maxfps)
			if holdcooldown < 0 {
				selected += 1
				holdcooldown = 4
			}
		}
	}
}

if keyboard_check_released(vk_right) || gamepad_button_check_released(0,gp_padr) {
	press = 0
	holdcooldown = 40
}

// Clamp selection
selected = clamp(selected, 0, max(entry_count - 1, 0))