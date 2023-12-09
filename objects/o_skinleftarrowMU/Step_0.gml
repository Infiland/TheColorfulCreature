if global.multiplayerplayers = 1 { x = lerp(x,originalx,0.2 * (60 / global.maxfps)) } else {
	if global.chooseminigameMU = false {
	x = lerp(x,140,0.2 * (60 / global.maxfps))
	} else { x = lerp(x,-300,0.2 * (60 / global.maxfps)) }
}
if global.multiplayerplayerconfigchoose != 5 {
switch(global.customizeselectMU) {
case(1): if global.multiplayerplayerskin[global.multiplayerplayerconfigchoose-1] = limit { image_alpha = 0.5 } else { image_alpha = 1 } break;
case(2): if global.multiplayerplayerhat[global.multiplayerplayerconfigchoose-1] = limit { image_alpha = 0.5 } else { image_alpha = 1 } break;
case(3): if global.multiplayerplayeritem[global.multiplayerplayerconfigchoose-1] = limit { image_alpha = 0.5 } else { image_alpha = 1 } break;
}
}

//Pressing/Holding Left
if !keyboard_check(vk_right) {
if keyboard_check(vk_left) {
if global.chooseminigameMU = false {
if image_alpha != 0.5 {
if global.multiplayerplayerconfigchoose != 5 {
if press = 0 {
switch(global.customizeselectMU) {
case(1): global.multiplayerplayerskin[global.multiplayerplayerconfigchoose-1] -= 1 break;
case(2): global.multiplayerplayerhat[global.multiplayerplayerconfigchoose-1] -= 1 break;
case(3): global.multiplayerplayeritem[global.multiplayerplayerconfigchoose-1] -= 1 break;
}
press = 1
} else {
holdcooldown -= 1 * (60 / global.maxfps)
if holdcooldown < 0 {
switch(global.customizeselectMU) {
case(1): global.multiplayerplayerskin[global.multiplayerplayerconfigchoose-1] -= 1 break;
case(2): global.multiplayerplayerhat[global.multiplayerplayerconfigchoose-1] -= 1 break;
case(3): global.multiplayerplayeritem[global.multiplayerplayerconfigchoose-1] -= 1 break;
}
holdcooldown = 4
}
}
}}}

}
}

if keyboard_check_released(vk_left) {
press = 0
holdcooldown = 40
}