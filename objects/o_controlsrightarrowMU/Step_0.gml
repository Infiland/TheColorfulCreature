if global.multiplayerplayers = 1 { x = lerp(x,originalx,0.2 * (60 / global.maxfps)) } else {
	if global.chooseminigameMU = false {
	x = lerp(x,750,0.2 * (60 / global.maxfps))
	} else { x = lerp(x,-300,0.2 * (60 / global.maxfps)) }
}
if global.multiplayerplayerconfigchoose != 5 {
if global.multiplayerplayercontrols[global.multiplayerplayerconfigchoose-1] = 3 { image_alpha = 0.5 } else { image_alpha = 1 }
}