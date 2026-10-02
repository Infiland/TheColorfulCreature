if (!timing_instance_step()) exit;
stats_ach_tick += 1
if stats_ach_tick >= stats_ach_update_rate {
	stats_refresh_achievements()
	stats_ach_tick = 0
}
stats_refresh()

// Color
if change = 0 {
	blue += 3
	if blue > 255 {
		blue = 255
		change = 1
	}
}
if change = 1 {
	red -= 3
	if red < 0 {
		red = 0
		change = 2
	}
}
if change = 2 {
	green += 3
	if green > 255 {
		green = 255
		change = 3
	}
}
if change = 3 {
	blue -= 3
	if blue < 0 {
		blue = 0
		change = 4
	}
}
if change = 4 {
	red += 3
	if red > 255 {
		red = 255
		change = 5
	}
}
if change = 5 {
	green -= 3
	if green < 0 {
		green = 0
		change = 0
	}
}

color = make_color_rgb(red, green, blue)

key_down = timing_keyboard_down(vk_up) || timing_keyboard_down(ord("W"))
key_up = timing_keyboard_down(vk_down) || timing_keyboard_down(ord("S"))
if timing_mouse_wheel_up() { yscrollreal -= 4000 * timing_tick_seconds() }
if timing_mouse_wheel_down() { yscrollreal += 4000 * timing_tick_seconds() }

if platform_touch() {
	if timing_mouse_down(mb_left) {
		if mouse_y < 512 { key_down = true } else { key_up = true }
	} else {
		key_up = false
		key_down = false
	}
}

if key_down { yscrollreal -= 500 * timing_tick_seconds() }
if key_up { yscrollreal += 500 * timing_tick_seconds() }

if yscrollreal < 0 { yscrollreal = 0 }
if yscrollreal > stats_scroll_max { yscrollreal = stats_scroll_max }

yscroll = lerp(yscroll, yscrollreal, 0.2)
