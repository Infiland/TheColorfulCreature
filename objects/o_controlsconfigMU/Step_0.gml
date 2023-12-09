if global.multiplayerplayers = 1 { x = lerp(x,originalx,0.2 * (60 / global.maxfps)) } else {
	if global.chooseminigameMU = false {
	x = lerp(x,299,0.2 * (60 / global.maxfps))
	} else { x = lerp(x,-500,0.2 * (60 / global.maxfps)) }
}
switch(global.multiplayerplayerconfigchoose) {
case(1): image_index = global.multiplayerplayercontrols[0] break;
case(2): image_index = global.multiplayerplayercontrols[1] break;
case(3): image_index = global.multiplayerplayercontrols[2] break;
case(4): image_index = global.multiplayerplayercontrols[3] break;
}

image_blend = c_white
if global.multiplayerplayercontrols[0] = global.multiplayerplayercontrols[1] { image_blend = c_red }
if global.multiplayerplayercontrols[0] = global.multiplayerplayercontrols[2] { image_blend = c_red }
if global.multiplayerplayercontrols[0] = global.multiplayerplayercontrols[3] { image_blend = c_red }
if global.multiplayerplayercontrols[1] = global.multiplayerplayercontrols[2] { image_blend = c_red }
if global.multiplayerplayercontrols[1] = global.multiplayerplayercontrols[3] { image_blend = c_red }
if global.multiplayerplayercontrols[3] = global.multiplayerplayercontrols[2] { image_blend = c_red }

/*
switch(global.multiplayerplayers) {
case(2): if global.multiplayerplayercontrols[0] = global.multiplayerplayercontrols[1] { image_blend = c_red } else { image_blend = c_white } break;
case(3): if global.multiplayerplayercontrols[0] = global.multiplayerplayercontrols[1] = global.multiplayerplayercontrols[2] { image_blend = c_red } else { image_blend = c_white } break;
case(4): if global.multiplayerplayercontrols[0] = global.multiplayerplayercontrols[1] = global.multiplayerplayercontrols[2] { image_blend = c_red } else { image_blend = c_white } break;
}