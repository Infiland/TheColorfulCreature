function getwheelskin(skin,maxS){
if skin < 10 {
var strS = "skin00" + string(skin)
} else {
var strS = "skin0" + string(skin)
}

if variable_global_get(strS) = 1 {
	var rand = choose(-1,1)
	if (skin+rand) > 1 || (skin+rand) < maxS {
		getwheelskin(skin+rand,maxS)
	} else {
		getwheelskin(irandom_range(2,maxS),maxS)	
	}
} else {
	variable_global_set(strS,1)
	//show_debug_message(strS)
	scr_saveskins()
}

}