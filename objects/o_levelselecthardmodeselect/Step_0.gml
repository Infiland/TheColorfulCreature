if room = r_levelselectmenu { //This is shit code lol
	if keyboard_check_pressed(ord("H")) {
		if global.hardmode = 0 {
			global.hardmode = 1	option = "on"
		} else { global.hardmode = 0 option = "off" }
		text = "Press H to change to hardmode: " + string(option)
	}
}