fall = random_range((-0.2 - (2 * jumped)),0.2)
dir = random_range(0.12 * (5 * jumped),-0.12 * (5 * jumped))

if instance_exists(o_player) {
scr_playercontrolsconfig()
//Left
if os_type != os_android {
if leftcontrols = 0 {
key_left = (gamepad_button_check(4,gp_padl)) || keyboard_check(ord(global.controlsmoveleft)); //keyboard_check(vk_left) ||
}
if leftcontrols = 1 {
key_left = (gamepad_button_check(4,gp_padl)) || keyboard_check(global.controlsmoveleft);
}
//Right
if rightcontrols = 0 {
key_right = (gamepad_button_check(4,gp_padr)) || keyboard_check(ord(global.controlsmoveright));
}
if rightcontrols = 1 {
key_right = (gamepad_button_check(4,gp_padr)) || keyboard_check(global.controlsmoveright); //keyboard_check(vk_right) ||
}} else {
key_left = o_buttonleftandroid.image_index = 1;
key_right = o_buttonrightandroid.image_index = 1;
}

if key_left {dir = random_range(0,(-0.25 * (5 * jumped)) * (60 / global.maxfps))}
if key_right {dir = random_range(0,(0.25 * (5 * jumped)) * (60 / global.maxfps))}
}