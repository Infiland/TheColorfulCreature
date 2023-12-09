//Controls
image_alpha = 0

if instance_exists(o_leveleditormenusetup) { exit }
if instance_exists(o_leveleditorleaveask) { exit }
if instance_exists(o_chooseleveleditorlevel) { exit }
image_blend = c_white
x = (mouse_x div 32) * 32
y = (mouse_y div 32) * 32
image_alpha = 0
image_speed = 1

//IMPORTANT CHECK O_ANIMATEDLEICON
scr_leveleditorsprites(global.LES)
image_blend = c_white
mask_index = s_block
if y < 64 + camera_get_view_y(view_camera[0]) {
image_alpha = 0
sprite_index = s_cannotplace
}
if global.LEBuild = 1 {
if place_meeting(x,y,o_player) || place_meeting(x,y,o_redblockslope) || place_meeting(x,y,o_editoritems) || place_meeting(x,y,o_anyblock) ||place_meeting(x,y,o_allspikes) || place_meeting(x,y,o_allinvspikes) || place_meeting(x,y,o_door) || place_meeting(x,y,o_portalpurpleclosed) || place_meeting(x,y,o_portalpurpleopen) || place_meeting(x,y,o_redpassblock) || place_meeting(x,y,o_yellowpassblock) || place_meeting(x,y,o_greenpassblock) || place_meeting(x,y,o_bluepassblock) || place_meeting(x,y,o_whitepassblock) || place_meeting(x,y,o_torchLE) || place_meeting(x,y,o_enemyplayerLE) || place_meeting(x,y,o_enemyplayer) || place_meeting(x,y,o_ladder) || place_meeting(x,y,o_deathblock) || place_meeting(x,y,o_blockcheck2) || place_meeting(x,y,o_gravitylimit01) || place_meeting(x,y,o_gravitylimit05) || place_meeting(x,y,o_gravitylimit15) || place_meeting(x,y,o_gravitylimit25) || place_meeting(x,y,o_speedlimit5) || place_meeting(x,y,o_speedlimit7) || place_meeting(x,y,o_speedlimit10) || place_meeting(x,y,o_speedlimit15) || place_meeting(x,y,o_lockedblock) || place_meeting(x,y,o_unlockedblock) || place_meeting(x,y,o_zerogravitylimit) {
sprite_index = s_cannotplace
}}
if global.LEBuild = 2 {
if instance_position(x,y,o_anyblock) || instance_position(x,y,o_deathblock) || instance_position(x,y,o_boxLE) || instance_position(x,y,o_anybackgroundblock) || instance_position(x,y,o_onewaydownblock) || instance_position(x,y,o_onewayupblock) || instance_position(x,y,o_onewayleftblock) || instance_position(x,y,o_onewayrightblock){
sprite_index = s_cannotplace
}
}

//Checking
global.canchange = false
if global.LEBuild = 1 {
if global.LES = 6 || global.LES = 7 || global.LES = 8 || global.LES = 9 || global.LES = 10{
if place_meeting(x,y,o_playerspawner) || place_meeting(x,y,o_redblock) || place_meeting(x,y,o_yellowblock) || place_meeting(x,y,o_greenblock) || place_meeting(x,y,o_blueblock) || place_meeting(x,y,o_whiteblock){
	global.canchange = true
}}
if global.LES = 6 || global.LES = 7 || global.LES = 8 || global.LES = 9 {
if place_meeting(x,y,o_yellowpassblock) || place_meeting(x,y,o_redpassblock) || place_meeting(x,y,o_greenpassblock) || place_meeting(x,y,o_bluepassblock) {	
global.canchange = true
}}
if global.LES = 57 || global.LES = 58 {
if place_meeting(x,y,o_box)	 {
global.canchange = true
}}
if global.LES = 60 || global.LES = 58 {
if place_meeting(x,y,o_boxwithammo)	 {
global.canchange = true
}}
if global.LES = 60 || global.LES = 57 {
if place_meeting(x,y,o_boxwithinfiniteammo)	 {
global.canchange = true
}}
}
if global.LEBuild = 2 {
if place_meeting(x,y,o_redblockbackgroundslope) || place_meeting(x,y,o_yellowblockbackgroundslope) || place_meeting(x,y,o_greenblockbackgroundslope) || place_meeting(x,y,o_blueblockbackgroundslope) || place_meeting(x,y,o_whiteblockbackgroundslope) || place_meeting(x,y,o_iceblockbackgroundslope) || place_meeting(x,y,o_deathblockbackgroundslope) || place_meeting(x,y,o_boxblockbackgroundslope) {
global.canchange = true
}}

//if global.LEMode = 2 { image_alpha = 0 }

//LEFT DOWN
if mouse_check_button(mb_left) {
	scr_leftdownplacementLE()
}
if mouse_check_button_pressed(mb_right) {
	if instance_exists(o_leveleditorleaveask) { exit }

if global.LEMode = 1 {
if instance_exists(o_namelevelLE) { exit }
global.LEVerified = 0
instance_create(mouse_x,mouse_y,o_deleteblock)
instance_destroy()
}
}