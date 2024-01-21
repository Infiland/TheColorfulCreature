switch(global.customizeselect) {
case(1):

if global.skinpage > 1 {
	if keyboard_check_pressed(vk_left) || gamepad_button_check_pressed(0,gp_shoulderl) {global.skinpage -= 1}
	}
	
if global.skinpage = 1 { x = lerp(x,-32,0.2) } else {
x = lerp(x,10,0.2)	
}

break;
case(2):

if global.hatpage > 1 {
	if keyboard_check_pressed(vk_left) || gamepad_button_check_pressed(0,gp_shoulderl) {global.hatpage -= 1}
	}

if global.hatpage = 1 { x = lerp(x,-32,0.2) } else { x = lerp(x,10,0.2) }
break;
case(3):

if global.itempage > 1 {
	if keyboard_check_pressed(vk_left) || gamepad_button_check_pressed(0,gp_shoulderl) {global.itempage -= 1}
	}

if global.itempage = 1 { x = lerp(x,-32,0.2) } else { x = lerp(x,10,0.2) }
break;
}