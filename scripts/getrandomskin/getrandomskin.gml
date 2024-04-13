function getwheelskin(skin,maxS){

if global.skin[skin] = 1 {
	var rand = choose(-1,1)
	if (skin+rand) > 1 || (skin+rand) < maxS {
		getwheelskin(skin+rand,maxS)
	} else {
		getwheelskin(irandom_range(2,maxS),maxS)	
	}
} else {
	global.skin[skin] = 1
	//show_debug_message(strS)
	scr_saveskins()
}

}