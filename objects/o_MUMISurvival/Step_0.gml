if global.chooseminigameMU = true { 
	x = lerp(x,420,0.2 * (60 / global.maxfps)) 
	instance_deactivate_object(o_skinsselectbuttonMU)
	instance_deactivate_object(o_hatsselectbuttonMU)
	instance_deactivate_object(o_itemsselectbuttonMU)
	} else { x = lerp(x,originalx,0.2 * (60 / global.maxfps)) }
mouseon = image_index