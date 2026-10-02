if (!timing_is_tick()) exit;
fall = random_range((-0.2 - (2 * jumped)),0.2)
dir = random_range(0.12 * (5 * jumped),-0.12 * (5 * jumped))

if instance_exists(o_player) {
scr_playercontrolsconfig()
//Left
if !platform_mobile() {
if leftcontrols = 0 {
key_left = (tcc_gamepad_button_check(4,gp_padl)) || timing_keyboard_down(ord(global.controlsmoveleft)); //timing_keyboard_down(vk_left) ||
}
if leftcontrols = 1 {
key_left = (tcc_gamepad_button_check(4,gp_padl)) || timing_keyboard_down(global.controlsmoveleft);
}
//Right
if rightcontrols = 0 {
key_right = (tcc_gamepad_button_check(4,gp_padr)) || timing_keyboard_down(ord(global.controlsmoveright));
}
if rightcontrols = 1 {
key_right = (tcc_gamepad_button_check(4,gp_padr)) || timing_keyboard_down(global.controlsmoveright); //timing_keyboard_down(vk_right) ||
}} else {
key_left = o_buttonleftandroid.image_index = 1;
key_right = o_buttonrightandroid.image_index = 1;
}

if key_left {dir = random_range(0,(-0.25 * (5 * jumped)) * (60 / TCC_SIM_HZ))}
if key_right {dir = random_range(0,(0.25 * (5 * jumped)) * (60 / TCC_SIM_HZ))}
}
