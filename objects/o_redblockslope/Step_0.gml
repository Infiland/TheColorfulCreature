//event_inherited()

if room = r_leveleditor {
if global.LEMode = 1 {
mask_index = s_redblock
if global.LEBuild = 1 {
if place_meeting(x,y,o_placeblock) {
if mouse_check_button_pressed(mb_left) {	
image_index += 1
}}}} else {
mask_index = s_redblockslope	
}}

if global.LEBuild = 1 {
if instance_place(x,y,o_deleteblock) { instance_destroy() }
}