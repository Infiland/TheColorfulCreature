if (!timing_instance_step()) exit;
if global.pause = 1 { gamepad_set_vibration(0,0,0) }

if room = r_theend { instance_destroy(); exit; }
if instance_exists(o_settingspausemenu) { exit }
if instance_exists(o_hatshopmenu) { exit }
if global.autopausesettings = 1 {
if timing_background_event() {
if room != r_tale {
if (global.pause = 0) {
   global.pause = 1
   
   timing_sequence_flush();
	if window_get_cursor() = cr_none {
	window_set_cursor(cr_arrow)	
	}
   scr_savestats()
   audio_group_set_gain(Music,global.musicvolume/5,1000)

   platform_pause_menu_create();
}}}}

if player_pause_pressed() {
if room != r_tale {
qa_record_pause_action("keyboard-controller");
if (global.pause = 0) {
   global.pause = 1
   
   timing_sequence_flush();
   	if window_get_cursor() = cr_none {
	window_set_cursor(cr_arrow)	
	}
   scr_savestats()
   audio_group_set_gain(Music,global.musicvolume/5,1000)
   
   platform_pause_menu_create();
} else {
   global.pause = 0
   timing_sequence_flush();
   scr_savestats()
   audio_group_set_gain(Music,global.musicvolume,1000)
   instance_destroy(o_returnbutton)
   instance_destroy(o_givefeedback)
   instance_destroy(o_restartchallengebutton)
}}}
