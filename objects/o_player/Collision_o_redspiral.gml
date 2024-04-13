if os_type != os_android {
if interactcontrols = 0 {
key_interact = keyboard_check_pressed(ord(global.controlsinteract)) || (gamepad_button_check_pressed(0,gp_face2))
} else { key_interact = keyboard_check_pressed(global.controlsinteract) || (gamepad_button_check(0,gp_face2))  }} else {
key_interact = o_buttoninteractandroid.image_index = 1;
}

if key_interact {
global.color = 0
passblockcooldown = 10
scr_changecolorplayervx()
if room != r_leveleditor { 
	global.totalusepickups += 1
	}
var item = instance_nearest(x+16,y+16,o_redspiral)
with item {
instance_destroy()
}
audio_play_sound(snd_pickup,5,0);
if global.itempar = 1 { instance_create(x+8,y+8,o_redpickup) } 
}