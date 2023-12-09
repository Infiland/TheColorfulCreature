//Command

if instance_exists(o_leveleditorleaveask) { exit }
if instance_exists(o_namelevelLE) { exit}
image_alpha = 1
if global.LEMode = 1 {
if global.writingmode = 0 {
if mouse_wheel_down() || keyboard_check_pressed(vk_left) {
global.LES -= 1	
image_speed = 1 * (60 / global.maxfps)
}
if mouse_wheel_up() || keyboard_check_pressed(vk_right) {
global.LES += 1	
image_speed = 1 * (60 / global.maxfps)
}}}
if keyboard_check_pressed(vk_escape) {
if !instance_exists(o_chooseleveleditorlevel) {
if !instance_exists(o_leveleditorleaveask) {
instance_create(x,y,o_leveleditorleaveask)
}}
}

if global.LEMode = 1 {
if global.LEBuild = 1 {
if global.writingmode = 0 {
if keyboard_check_pressed(vk_numpad1) || keyboard_check_pressed(ord("1")) { global.LES = 0 }
if keyboard_check_pressed(vk_numpad2) || keyboard_check_pressed(ord("2")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 8)) }
if keyboard_check_pressed(vk_numpad3) || keyboard_check_pressed(ord("3")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 7)) }
if keyboard_check_pressed(vk_numpad4) || keyboard_check_pressed(ord("4")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 6)) }
if keyboard_check_pressed(vk_numpad5) || keyboard_check_pressed(ord("5")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 5)) }
if keyboard_check_pressed(vk_numpad6) || keyboard_check_pressed(ord("6")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 4)) }
if keyboard_check_pressed(vk_numpad7) || keyboard_check_pressed(ord("7")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 3)) }
if keyboard_check_pressed(vk_numpad8) || keyboard_check_pressed(ord("8")) { global.LES = floor(maxblocks - ((maxblocks / 9) * 2)) }
if keyboard_check_pressed(vk_numpad9) || keyboard_check_pressed(ord("9")) { global.LES = floor(maxblocks - ((maxblocks / 9))) }
if keyboard_check_pressed(vk_numpad0) || keyboard_check_pressed(ord("0")) { global.LES = maxblocks }
}}
if global.LES > maxblocks {global.LES = maxblocks}
}
//Background
if global.LEBuild = 2 {
if global.writingmode = 0 {
if keyboard_check_pressed(vk_numpad1) || keyboard_check_pressed(ord("1")) { global.LES = 0 }
if keyboard_check_pressed(vk_numpad2) || keyboard_check_pressed(ord("2")) { global.LES = floor(maxback - ((maxback / 9) * 8)) }
if keyboard_check_pressed(vk_numpad3) || keyboard_check_pressed(ord("3")) { global.LES = floor(maxback - ((maxback / 9) * 7)) }
if keyboard_check_pressed(vk_numpad4) || keyboard_check_pressed(ord("4")) { global.LES = floor(maxback - ((maxback / 9) * 6)) }
if keyboard_check_pressed(vk_numpad5) || keyboard_check_pressed(ord("5")) { global.LES = floor(maxback - ((maxback / 9) * 5)) }
if keyboard_check_pressed(vk_numpad6) || keyboard_check_pressed(ord("6")) { global.LES = floor(maxback - ((maxback / 9) * 4)) }
if keyboard_check_pressed(vk_numpad7) || keyboard_check_pressed(ord("7")) { global.LES = floor(maxback - ((maxback / 9) * 3)) }
if keyboard_check_pressed(vk_numpad8) || keyboard_check_pressed(ord("8")) { global.LES = floor(maxback - ((maxback / 9) * 2)) }
if keyboard_check_pressed(vk_numpad9) || keyboard_check_pressed(ord("9")) { global.LES = floor(maxback - ((maxback / 9))) }
if keyboard_check_pressed(vk_numpad0) || keyboard_check_pressed(ord("0")) { global.LES = maxback }
}
image_alpha = 1
image_index = 0
if global.LES > maxback { global.LES = maxback }
}
if global.LEBuild = 3 {
if global.LES > maxliquid {global.LES = maxliquid}
}

if global.LES < 0 {global.LES = 0}