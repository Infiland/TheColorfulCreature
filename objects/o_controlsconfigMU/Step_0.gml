if global.multiplayerplayers = 1 { x = lerp(x,originalx,0.2 * (60 / global.maxfps)) } else {
	if global.chooseminigameMU = false {
	x = lerp(x,299,0.2 * (60 / global.maxfps))
	} else { x = lerp(x,-500,0.2 * (60 / global.maxfps)) }
}
image_index = global.multiplayerplayercontrols[global.multiplayerplayerconfigchoose - 1]

image_blend = c_white
for (var i = 0; i < global.multiplayerplayers; i++) {
	for (var j = i + 1; j < global.multiplayerplayers; j++) {
		if (global.multiplayerplayercontrols[i] = global.multiplayerplayercontrols[j]) { image_blend = c_red }
	}
}