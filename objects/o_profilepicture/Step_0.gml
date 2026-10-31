if (!timing_instance_step()) exit;
if !platform_steam() { exit }
if (!avatar_done && current_time >= avatar_next)
	avatar_poll();
