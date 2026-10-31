if !platform_steam() {
	instance_destroy()
	exit
	}


if !tcc_steam_init() { instance_destroy() }

avatar_sprite = -1;
avatar_tries = 0;
avatar_next = current_time;
avatar_done = false;

// Steam may not have our picture yet: ask again from Step, a bounded number of times
function avatar_poll()
{
	if (avatar_done) return;

	var av = tcc_steam_get_user_avatar(tcc_steam_get_user_steam_id(), TCC_STEAM_AVATAR_MEDIUM);
	if (av > 0)
	{
		avatar_sprite = tcc_steam_image_to_sprite(av);
		avatar_done = true;
	}
	else if (av == TCC_AVATAR_PENDING && avatar_tries < TCC_AVATAR_RETRY_MAX)
	{
		avatar_tries++;
		avatar_next = current_time + TCC_AVATAR_RETRY_MS;
	}
	else
		avatar_done = true;
}

avatar_poll();
