if (global.pause != 0) exit;

if (key_interact || (platform_mobile() && key_interact_h)) {
global.color = 0
passblockcooldown = 10
scr_changecolorplayervx()
if room != r_leveleditor {
	increase_stat("totalusepickups","QUESTusepickups",1)
	}
var item = instance_nearest(x+16,y+16,o_redspiral)
with item {
instance_destroy()
}
audio_play_sound(snd_pickup,5,0);
if global.itempar = 1 { instance_create(x+8,y+8,o_redpickup) }
}
