if (!timing_instance_step()) exit;
//Command

if instance_exists(o_leveleditorleaveask) { exit }
if instance_exists(o_namelevelLE) { exit}
image_alpha = 1
if global.LEMode = 1 {
if global.writingmode = 0 {
if timing_mouse_wheel_down() || timing_keyboard_pressed(vk_left) {
global.LES -= 1	
image_speed = 1 * (60 / global.maxfps)
}
if timing_mouse_wheel_up() || timing_keyboard_pressed(vk_right) {
global.LES += 1	
image_speed = 1 * (60 / global.maxfps)
}}}
if timing_keyboard_pressed(vk_up) {
	if global.LEBuild != 3 {
		global.LEBuild += 1
	}
}
if timing_keyboard_pressed(vk_down) {
	if global.LEBuild != 1 {
		global.LEBuild -= 1
	}
}
if timing_keyboard_pressed(vk_escape) {
if !instance_exists(o_chooseleveleditorlevel) {
if !instance_exists(o_leveleditorleaveask) {
instance_create(x,y,o_leveleditorleaveask)
}}
}

if global.LEMode = 1 {
if global.LEBuild = 1 {
if global.writingmode = 0 {
if timing_keyboard_pressed(vk_numpad1) || timing_keyboard_pressed(ord("1")) { global.LES = 0 }
if timing_keyboard_pressed(vk_numpad2) || timing_keyboard_pressed(ord("2")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 8)) }
if timing_keyboard_pressed(vk_numpad3) || timing_keyboard_pressed(ord("3")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 7)) }
if timing_keyboard_pressed(vk_numpad4) || timing_keyboard_pressed(ord("4")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 6)) }
if timing_keyboard_pressed(vk_numpad5) || timing_keyboard_pressed(ord("5")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 5)) }
if timing_keyboard_pressed(vk_numpad6) || timing_keyboard_pressed(ord("6")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 4)) }
if timing_keyboard_pressed(vk_numpad7) || timing_keyboard_pressed(ord("7")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 3)) }
if timing_keyboard_pressed(vk_numpad8) || timing_keyboard_pressed(ord("8")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 2)) }
if timing_keyboard_pressed(vk_numpad9) || timing_keyboard_pressed(ord("9")) { global.LES = floor(maxblocks - ((maxblocks / 9))) }
if timing_keyboard_pressed(vk_numpad0) || timing_keyboard_pressed(ord("0")) { global.LES = maxblocks }
}}
if global.LES > maxblocks {global.LES = maxblocks}
}
//Background
if global.LEBuild = 2 {
if global.writingmode = 0 {
if timing_keyboard_pressed(vk_numpad1) || timing_keyboard_pressed(ord("1")) { global.LES = 0 }
if timing_keyboard_pressed(vk_numpad2) || timing_keyboard_pressed(ord("2")) { global.LES = floor(maxback - ((maxback / 9) * 8)) }
if timing_keyboard_pressed(vk_numpad3) || timing_keyboard_pressed(ord("3")) { global.LES = floor(maxback - ((maxback / 9) * 7)) }
if timing_keyboard_pressed(vk_numpad4) || timing_keyboard_pressed(ord("4")) { global.LES = floor(maxback - ((maxback / 9) * 6)) }
if timing_keyboard_pressed(vk_numpad5) || timing_keyboard_pressed(ord("5")) { global.LES = floor(maxback - ((maxback / 9) * 5)) }
if timing_keyboard_pressed(vk_numpad6) || timing_keyboard_pressed(ord("6")) { global.LES = floor(maxback - ((maxback / 9) * 4)) }
if timing_keyboard_pressed(vk_numpad7) || timing_keyboard_pressed(ord("7")) { global.LES = floor(maxback - ((maxback / 9) * 3)) }
if timing_keyboard_pressed(vk_numpad8) || timing_keyboard_pressed(ord("8")) { global.LES = floor(maxback - ((maxback / 9) * 2)) }
if timing_keyboard_pressed(vk_numpad9) || timing_keyboard_pressed(ord("9")) { global.LES = floor(maxback - ((maxback / 9))) }
if timing_keyboard_pressed(vk_numpad0) || timing_keyboard_pressed(ord("0")) { global.LES = maxback }
}
image_alpha = 1
image_index = 0
if global.LES > maxback { global.LES = maxback }
}
if global.LEBuild = 3 {
if global.LES > maxliquid {global.LES = maxliquid}
}

if global.LES < 0 {global.LES = 0}