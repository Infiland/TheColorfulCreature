switch(global.customizeselect) {
case(1):

if global.skinpage < skinpage {
	if keyboard_check_pressed(vk_right) {global.skinpage += 1}
	}

if global.skinschange = 0 {
if global.skinpage = skinpage { x = lerp(x,1100,0.2) } else {
	x = lerp(x,1000,0.2)
}
}
if global.skinschange = 1 {x = lerp(x,1100,0.2)}
break;

case(2):
if global.hatpage < hatpage {
	if keyboard_check_pressed(vk_right) {global.hatpage += 1}
	}

if global.hatpage = hatpage { x = lerp(x,1100,0.2) } else {
	x = lerp(x,1000,0.2)
}
break;
case(3):
if global.itempage < itempage {
	if keyboard_check_pressed(vk_right) {global.itempage += 1}
	}

if global.itempage = itempage { x = lerp(x,1100,0.2) } else {
	x = lerp(x,1000,0.2)
}
break;
}