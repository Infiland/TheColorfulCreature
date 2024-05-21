if global.pause = 1 { exit }

if room != r_leveleditor {
	if instance_exists(o_player) {
		x = lerp(x,o_player.x,(0.05 * (60 / global.maxfps)))
		y = lerp(y,o_player.y,(0.05 * (60 / global.maxfps)))
	} 
	if instance_exists(o_playerdead) {
		x = lerp(x,o_playerdead.x,(0.05 * (60 / global.maxfps)))
		y = lerp(y,o_playerdead.y,(0.05 * (60 / global.maxfps)))
	}
} else {
	if global.LEMode = 1 {
		if keyboard_check(vk_control) {
			if mouse_y > 64 {
				x = lerp(x,mouse_x,(0.05 * (60 / global.maxfps)))
				y = lerp(y,mouse_y,(0.05 * (60 / global.maxfps)))
			}	
		}
	} else {
		if instance_exists(o_player) {
			x = lerp(x,o_player.x,(0.05 * (60 / global.maxfps)))
			y = lerp(y,o_player.y,(0.05 * (60 / global.maxfps)))	
		}
		if instance_exists(o_playerdead) {
			x = lerp(x,o_playerspawner.x,(0.05 * (60 / global.maxfps)))
			y = lerp(y,o_playerspawner.y,(0.05 * (60 / global.maxfps)))
		}
	}
}

if holdctrl = 1 {
txtsize = lerp(txtsize,1,0.1 * (60 / global.maxfps))
} else {
	if keyboard_check(vk_control) {
	holdctrl = 1
	}
}
/*
x += (xTo - x)/25
y += (yTo - y)/25

if !instance_exists(o_player) {
follow = o_playerdead
xzoom -= 8
yzoom -= 6
}

if (follow != noone) {
xTo = follow.x
yTo = follow.y
}