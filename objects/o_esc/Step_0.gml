if instance_exists(o_namelevelLE) { exit }
if instance_exists(o_popup) { exit }
if instance_exists(o_tradeup_menu) { exit }
if room == r_challenges {
	if !variable_global_exists("challenge_custom_spawned") { global.challenge_custom_spawned = false }
	if !global.challenge_custom_spawned {
		scr_challenge_spawn_custom_buttons();
		global.challenge_custom_spawned = true;
	}
} else {
	if variable_global_exists("challenge_custom_spawned") { global.challenge_custom_spawned = false }
}
if keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0,gp_face2) {
		if room == r_workshopchallengemenu {
			if instance_exists(o_workshopchallengecreator) {
				with (o_workshopchallengecreatorbg) instance_destroy()
				with (o_workshoplevelselectbutton) instance_destroy()
				instance_destroy(o_workshopchallengecreator)
				exit
		}
		if instance_exists(o_showsubscribedchallenges) {
			with (o_workshopchallengeitembutton) instance_destroy()
			instance_destroy(o_showsubscribedchallenges)
			exit
		}
	}
	scr_back()
}
