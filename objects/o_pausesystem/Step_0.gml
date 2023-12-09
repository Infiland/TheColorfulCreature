if global.pause = 1 { gamepad_set_vibration(0,0,0) }

if room = r_theend { instance_destroy() }
if instance_exists(o_settingspausemenu) { exit }
if instance_exists(o_hatshopmenu) { exit }
if global.autopausesettings = 1 {
if os_is_paused() {
if room != r_tale {
if (global.pause = 0) {
   global.pause = 1
   
	if window_get_cursor() = cr_none {
	window_set_cursor(cr_arrow)	
	}
   scr_savestats()
   audio_group_set_gain(Music,global.musicvolume/5,1000)

	instance_create(288,288,o_pausescreen)
	instance_create(480,490,o_returnbutton)
	with(o_returnbutton) {
		ingame = true
	}
	instance_create(960,704,o_settings)
	with(o_settings) {
	image_xscale = 2
	image_yscale = 2
	}
	instance_create(750,670,o_givefeedback)
	with(o_givefeedback) {
	image_xscale = 32.8
	image_yscale = 16.1
	xscale = 0.65
	yscale = 0.65
	}
	if global.challenges = 1 {
	instance_create(550,670,o_restartchallengebutton)
	with(o_restartchallengebutton) {
	image_xscale = 32.8
	image_yscale = 16.1
	xscale = 0.5
	yscale = 0.5
	}
	}
	
   instance_activate_object(o_pausescreen)
}}}}

if keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0,gp_start) {
if room != r_tale {
if (global.pause = 0) {
   global.pause = 1
   
   	if window_get_cursor() = cr_none {
	window_set_cursor(cr_arrow)	
	}
   scr_savestats()
   audio_group_set_gain(Music,global.musicvolume/5,1000)
   
	instance_create(288,288,o_pausescreen)
	instance_create(480,490,o_returnbutton)
	with(o_returnbutton) {
		ingame = true
	}
	instance_create(960,704,o_settings)
	with(o_settings) {
	image_xscale = 2
	image_yscale = 2
	}
	instance_create(750,670,o_givefeedback)
	with(o_givefeedback) {
	image_xscale = 31
	image_yscale = 16
	xscale = 0.6
	yscale = 0.6
	}
	if global.challenges = 1 {
	instance_create(570,670,o_restartchallengebutton)
	with(o_restartchallengebutton) {
	image_xscale = 32.8
	image_yscale = 16.1
	xscale = 0.5
	yscale = 0.5
	}
	}
	
   instance_activate_object(o_pausescreen)
} else {
   global.pause = 0
   scr_savestats()
   audio_group_set_gain(Music,global.musicvolume,1000)
   instance_destroy(o_returnbutton)
   instance_destroy(o_givefeedback)
   instance_destroy(o_restartchallengebutton)
}}}