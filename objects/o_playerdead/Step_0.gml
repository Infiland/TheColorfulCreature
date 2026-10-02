if (!timing_instance_step()) exit;
if global.pause = 1{
	image_speed = 0
	gamepad_set_vibration(0, 0, 0);
	exit
	}
image_speed = 1/3 * (60 / TCC_SIM_HZ)
fall += 0.25 * (60 / TCC_SIM_HZ)
tcc_randomize()
image_alpha -= 0.025 * (60 / TCC_SIM_HZ)
y -= (5 - fall) * (60 / TCC_SIM_HZ)

var vibx1 = (x/room_width)
var vibx2 = 1 - (x/room_width)

if room_width > 1024 {
	vibx1 = 0.5
	vibx2 = 0.5
}

var vb = global.controllervibrationsettings

gamepad_set_vibration(0, (vibx2 * image_alpha)*vb, (vibx1 * image_alpha)*vb);
if image_alpha < 0 {
if room != r_hardmodedeathroom {
room_restart()
instance_destroy()
gamepad_set_vibration(0, 0, 0);
} else {
	hideandroidbuttons()
	instance_destroy() }
if global.challenges = 0 {
if global.hardmode = 0 {
if global.endless = 0 {
if global.levelselect = 0 {
scr_savegame()
}}}}
}
x += gotheredead
if image_index = 5 { image_speed = 0 }
