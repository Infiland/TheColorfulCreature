if (!timing_instance_step()) exit;
if timing_keyboard_pressed(vk_escape) {
	instance_destroy()
	exit
}

if (timer > 0) {
	timer -= 1 * (60 / global.maxfps)
	if timer <= 0 {
		instance_destroy()
	}
}
