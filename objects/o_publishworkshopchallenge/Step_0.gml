if (!timing_instance_step()) exit;
// Like o_publishinghappenshere: stay while a create or submit is outstanding. Leaving would keep the single-flight slot busy until
// Steam answers, and an immediate second upload would then be refused or leave an orphan item.
if timing_keyboard_pressed(vk_escape) && result != 0.1 && result != 0.5 {
	instance_destroy()
	exit
}

if (timer > 0) {
	timer -= 1 * (60 / global.maxfps)
	if timer <= 0 {
		instance_destroy()
	}
}
