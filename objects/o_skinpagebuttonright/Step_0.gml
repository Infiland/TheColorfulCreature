//Pressing/Holding Right
if !keyboard_check(vk_left) && !gamepad_button_check(0,gp_shoulderl) {
if keyboard_check(vk_right) || gamepad_button_check(0,gp_shoulderr) {

switch(global.customizeselect) {
case(1):
if global.skinpage < skinpage {
	if press = 0 {
		global.skinpage += 1
		press = 1
	} else {
		holdcooldown -= 1 * (60 / global.maxfps)
		if holdcooldown < 0 {
			var _step = 1
			if keyboard_check(vk_shift) { _step = 3 }
			global.skinpage += _step
			global.skinpage = clamp(global.skinpage, 1, skinpage)
			holdcooldown = 4
		}
	}
}
break;
case(2):
if global.hatpage < hatpage {
	if press = 0 {
		global.hatpage += 1
		press = 1
	} else {
		holdcooldown -= 1 * (60 / global.maxfps)
		if holdcooldown < 0 {
			var _step = 1
			if keyboard_check(vk_shift) { _step = 3 }
			global.hatpage += _step
			global.hatpage = clamp(global.hatpage, 1, hatpage)
			holdcooldown = 4
		}
	}
}
break;
case(3):
if global.itempage < itempage {
	if press = 0 {
		global.itempage += 1
		press = 1
	} else {
		holdcooldown -= 1 * (60 / global.maxfps)
		if holdcooldown < 0 {
			var _step = 1
			if keyboard_check(vk_shift) { _step = 3 }
			global.itempage += _step
			global.itempage = clamp(global.itempage, 1, itempage)
			holdcooldown = 4
		}
	}
}
break;
}

}
}

if keyboard_check_released(vk_right) || gamepad_button_check_released(0,gp_shoulderr) {
press = 0
holdcooldown = 40
}

//Arrow visibility
switch(global.customizeselect) {
case(1):
if global.skinpage = skinpage { x = lerp(x,1100,0.2) } else { x = lerp(x,1000,0.2) }
break;
case(2):
if global.hatpage = hatpage { x = lerp(x,1100,0.2) } else { x = lerp(x,1000,0.2) }
break;
case(3):
if global.itempage = itempage { x = lerp(x,1100,0.2) } else { x = lerp(x,1000,0.2) }
break;
}