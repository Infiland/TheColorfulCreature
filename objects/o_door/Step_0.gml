if room != r_leveleditor {
if instance_exists(o_key) { instance_change(o_lockeddoor,1)}
}
if room = r_leveleditor {
	if instance_exists(o_key) {
	sprite_index = s_lockeddoor } else { sprite_index = s_door}
}
if global.pause = 0 { image_speed = 0.5 }
if global.pause = 1 { image_speed = 0 }