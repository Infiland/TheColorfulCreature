switch(global.customizeselect) {
case(1):

if global.skinpage > 1 {
	if keyboard_check_pressed(vk_left) {global.skinpage -= 1}
	}
	
if global.skinpage = 1 { x = lerp(x,-32,0.2) } else {
x = lerp(x,10,0.2)	
}

break;
case(2):

if global.hatpage > 1 {
	if keyboard_check_pressed(vk_left) {global.hatpage -= 1}
	}

if global.hatpage = 1 { x = lerp(x,-32,0.2) } else { x = lerp(x,10,0.2) }
break;
case(3):

if global.itempage > 1 {
	if keyboard_check_pressed(vk_left) {global.itempage -= 1}
	}

if global.itempage = 1 { x = lerp(x,-32,0.2) } else { x = lerp(x,10,0.2) }
break;
}