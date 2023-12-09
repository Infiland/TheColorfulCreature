scr_playercontrolsconfig()

if global.hardmode = 1 {
instance_destroy()	
}

if os_type != os_android {
key_skip = keyboard_check(ord(global.controlsskiplevel))
} else { 
	if instance_exists(o_buttonskipandroid) {
	key_skip = o_buttonskipandroid.image_index = 1;
	}}

skipcontrols = 0
timer = 0.7
reqcoin = 4
keyd = "";
if global.skiplevelholdsettings = 0 {
skip = "Press [" + string(keyd) + "] to skip\n a level ("+ string(reqcoin) + " Coins)"
}
if global.skiplevelholdsettings = 1 {
skip = "Hold [" + string(keyd) + "] to skip\n a level ("+ string(reqcoin) + " Coins)"
}