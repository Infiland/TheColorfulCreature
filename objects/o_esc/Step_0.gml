if (!timing_instance_step()) exit;
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
var _back_device = gamepad_remap_active_device(true);
// While listening, B belongs to the requested mapping. Escape still cancels.
if gamepad_remap_back_input(timing_keyboard_pressed(vk_escape),
    _back_device >= 0 && tcc_gamepad_button_check_pressed(_back_device,gp_face2), gamepad_remap_capture_active()) {
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
