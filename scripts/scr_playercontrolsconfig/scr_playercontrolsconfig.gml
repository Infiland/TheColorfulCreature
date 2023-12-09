function scr_playercontrolsconfig(){
	if os_type != os_android {
leftcontrols = 0
rightcontrols = 0
jumpcontrols = 0
interactcontrols = 0
skipcontrols = 0
restartcontrols = 0
//Left
switch(global.controlsmoveleft) {
case("40"): leftcontrols = 1
global.controlsmoveleft = vk_down break;
case("39"): leftcontrols = 1
global.controlsmoveleft = vk_right break;
case("38"): leftcontrols = 1
global.controlsmoveleft = vk_up break;
case("37"): leftcontrols = 1
global.controlsmoveleft = vk_left break;
case("32"): leftcontrols = 1
global.controlsmoveleft = vk_space break;
case("17"): leftcontrols = 1
global.controlsmoveleft = vk_control break;
case("13"): leftcontrols = 1
global.controlsmoveleft = vk_enter break;
case("16"): leftcontrols = 1
global.controlsmoveleft = vk_shift break;
case("9"): leftcontrols = 1
global.controlsmoveleft = vk_tab break;
case("18"): leftcontrols = 1
global.controlsmoveleft = vk_alt break;
case("191"): leftcontrols = 1
global.controlsmoveleft = vk_divide break;
case("8"): leftcontrols = 1
global.controlsmoveleft = vk_backspace break;
}

//Right
switch(global.controlsmoveright) {
case("40"): rightcontrols = 1
global.controlsmoveright = vk_down break;
case("39"): rightcontrols = 1
global.controlsmoveright = vk_right break;
case("38"): rightcontrols = 1
global.controlsmoveright = vk_up break;
case("37"): rightcontrols = 1
global.controlsmoveright = vk_left break;
case("32"): rightcontrols = 1
global.controlsmoveright = vk_space break;
case("17"): rightcontrols = 1
global.controlsmoveright = vk_control break;
case("13"): rightcontrols = 1
global.controlsmoveright = vk_enter break;
case("16"): rightcontrols = 1
global.controlsmoveright = vk_shift break;
case("9"): rightcontrols = 1
global.controlsmoveright = vk_tab break;
case("18"): rightcontrols = 1
global.controlsmoveright = vk_alt break;
case("191"): rightcontrols = 1
global.controlsmoveright = vk_divide break;
case("8"): rightcontrols = 1
global.controlsmoveright = vk_backspace break;
}
//Jump
switch(global.controlsjump) {
case("40"): jumpcontrols = 1
global.controlsjump = vk_down break;
case("39"): jumpcontrols = 1
global.controlsjump = vk_right break;
case("38"): jumpcontrols = 1
global.controlsjump = vk_up break;
case("37"): jumpcontrols = 1
global.controlsjump = vk_left break;
case("32"): jumpcontrols = 1
global.controlsjump = vk_space break;
case("17"): jumpcontrols = 1
global.controlsjump = vk_control break;
case("13"): jumpcontrols = 1
global.controlsjump = vk_enter break;
case("16"): jumpcontrols = 1
global.controlsjump = vk_shift break;
case("9"): jumpcontrols = 1
global.controlsjump = vk_tab break;
case("18"): jumpcontrols = 1
global.controlsjump = vk_alt break;
case("191"): jumpcontrols = 1
global.controlsjump = vk_divide break;
case("8"): jumpcontrols = 1
global.controlsjump = vk_backspace break;
}
//Interact
switch(global.controlsinteract) {
case("40"): interactcontrols = 1
global.controlsinteract = vk_down break;
case("39"): interactcontrols = 1
global.controlsinteract = vk_right break;
case("38"): interactcontrols = 1
global.controlsinteract = vk_up break;
case("37"): interactcontrols = 1
global.controlsinteract = vk_left break;
case("32"): interactcontrols = 1
global.controlsinteract = vk_space break;
case("17"): interactcontrols = 1
global.controlsinteract = vk_control break;
case("13"): interactcontrols = 1
global.controlsinteract = vk_enter break;
case("16"): interactcontrols = 1
global.controlsinteract = vk_shift break;
case("9"): interactcontrols = 1
global.controlsinteract = vk_tab break;
case("18"): interactcontrols = 1
global.controlsinteract = vk_alt break;
case("191"): interactcontrols = 1
global.controlsinteract = vk_divide break;
case("8"): interactcontrols = 1
global.controlsinteract = vk_backspace break;
}
//Skip
switch(global.controlsskiplevel) {
case("40"): skipcontrols = 1
global.controlsskiplevel = vk_down break;
case("39"): skipcontrols = 1
global.controlsskiplevel = vk_right break;
case("38"): skipcontrols = 1
global.controlsskiplevel = vk_up break;
case("37"): skipcontrols = 1
global.controlsskiplevel = vk_left break;
case("32"): skipcontrols = 1
global.controlsskiplevel = vk_space break;
case("17"): skipcontrols = 1
global.controlsskiplevel = vk_control break;
case("13"): skipcontrols = 1
global.controlsskiplevel = vk_enter break;
case("16"): skipcontrols = 1
global.controlsskiplevel = vk_shift break;
case("9"): skipcontrols = 1
global.controlsskiplevel = vk_tab break;
case("18"): skipcontrols = 1
global.controlsskiplevel = vk_alt break;
case("191"): skipcontrols = 1
global.controlsskiplevel = vk_divide break;
case("8"): skipcontrols = 1
global.controlsskiplevel = vk_backspace break;
}
//Restart
switch(global.controlsrestart) {
case("40"): restartcontrols = 1
global.controlsrestart = vk_down break;
case("39"): restartcontrols = 1
global.controlsrestart = vk_right break;
case("38"): restartcontrols = 1
global.controlsrestart = vk_up break;
case("37"): restartcontrols = 1
global.controlsrestart = vk_left break;
case("32"): restartcontrols = 1
global.controlsrestart = vk_space break;
case("17"): restartcontrols = 1
global.controlsrestart = vk_control break;
case("13"): restartcontrols = 1
global.controlsrestart = vk_enter break;
case("16"): restartcontrols = 1
global.controlsrestart = vk_shift break;
case("9"): restartcontrols = 1
global.controlsrestart = vk_tab break;
case("18"): restartcontrols = 1
global.controlsrestart = vk_alt break;
case("191"): restartcontrols = 1
global.controlsrestart = vk_divide break;
case("8"): restartcontrols = 1
global.controlsrestart = vk_backspace break;
}
	} else {
	if room != r_mainmenu {
	if global.pause = 0 {
	if !instance_exists(o_buttonleftandroid) { instance_create(x,y,o_buttonleftandroid) }
	if !instance_exists(o_buttonrightandroid) { instance_create(x,y,o_buttonrightandroid) }
	if !instance_exists(o_buttonjumpandroid) { instance_create(x,y,o_buttonjumpandroid) }
	if !instance_exists(o_buttoninteractandroid) { instance_create(x,y,o_buttoninteractandroid) }
	if !instance_exists(o_buttonrestartandroid) { instance_create(x,y,o_buttonrestartandroid) }
	if !instance_exists(o_buttonpauseandroid) { instance_create(x,y,o_buttonpauseandroid) }
	if global.challenges = 0 {
	if global.endless = 0 {
	if global.dailylevel = 0 {
	if global.calendar = 0 {
	if !instance_exists(o_buttonskipandroid) { instance_create(x,y,o_buttonskipandroid) }
	}}}}}}
	}
}