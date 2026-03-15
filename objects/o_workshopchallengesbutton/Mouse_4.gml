if steam_get_app_id() = 1749610 {
	if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
	exit
}

if !global.steam_api {
	if !instance_exists(o_popup) {
		global.popup_config = {
			title: "Steam Workshop",
			message: "Steam API must be enabled!",
			mode: 0
		}
		instance_create(0, 0, o_popup)
	}
	exit
}

room_goto(r_workshopchallengemenu)
