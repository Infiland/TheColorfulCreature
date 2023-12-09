if global.pause = 0 {
global.pause = 1

instance_destroy(o_buttonleftandroid)
instance_destroy(o_buttonrightandroid)
instance_destroy(o_buttoninteractandroid)
instance_destroy(o_buttonjumpandroid)
instance_destroy(o_buttonskipandroid)
instance_destroy(o_buttonrestartandroid)

AdMob_Banner_Create(AdMob_Banner_SMART,false)
AdMob_Banner_Show()
banner = 100
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
	
   instance_activate_object(o_pausescreen)
} else {
   global.pause = 0
   AdMob_Banner_Hide()
   banner = 0
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
   instance_destroy(o_pausescreen)
   instance_destroy(o_settings)
}