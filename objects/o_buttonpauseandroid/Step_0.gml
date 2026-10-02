if (!timing_instance_step()) exit;
if (!press) exit;
if (!platform_pause_menu_allowed()) exit;
qa_record_pause_action("touch");
platform_clear_input();
if global.pause = 0 {
global.pause = 1
timing_sequence_flush();

instance_destroy(o_buttonleftandroid)
instance_destroy(o_buttonrightandroid)
instance_destroy(o_buttoninteractandroid)
instance_destroy(o_buttonjumpandroid)
instance_destroy(o_buttonskipandroid)
instance_destroy(o_buttonrestartandroid)

ads_show_banner(false)
   scr_savestats()
   audio_group_set_gain(Music,global.musicvolume/5,1000)

   platform_pause_menu_create();
} else {
   global.pause = 0
   ads_hide_banner()
      scr_savestats()
	  	if !instance_exists(o_buttonleftandroid) { instance_create(x,y,o_buttonleftandroid) }
	if !instance_exists(o_buttonrightandroid) { instance_create(x,y,o_buttonrightandroid) }
	if !instance_exists(o_buttonjumpandroid) { instance_create(x,y,o_buttonjumpandroid) }
	if !instance_exists(o_buttoninteractandroid) { instance_create(x,y,o_buttoninteractandroid) }
	if !instance_exists(o_buttonrestartandroid) { instance_create(x,y,o_buttonrestartandroid) }
	if !instance_exists(o_buttonpauseandroid) { instance_create(x,y,o_buttonpauseandroid) }
   audio_group_set_gain(Music,global.musicvolume,1000)
   instance_destroy(o_returnbutton)
   instance_destroy(o_givefeedback)
   instance_destroy(o_restartchallengebutton)
   instance_destroy(o_pausescreen)
   instance_destroy(o_settings)
}
