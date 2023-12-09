if room = r_leveleditor {
	if global.LEMode = 1 {
	instance_destroy()	
	}
}
if global.pause = 1 { exit }
if place_meeting(x,y,o_allliquids) { inwater = 2 } else { inwater = 1 }
x += (5 / inwater) * (60 / global.maxfps)
image_angle += 3 * (60 / global.maxfps)
if place_meeting(x,y,o_redblock) or place_meeting(x,y,o_yellowblock) or place_meeting(x,y,o_greenblock) or place_meeting(x,y,o_blueblock) or place_meeting(x,y,o_whiteblock) or place_meeting(x,y,o_iceblock) or place_meeting(x,y,o_deathblock) or place_meeting(x,y,o_box) or collision_rectangle(x+4,y+4,x-4,y-4,o_onewayleftblock,true,true){
instance_destroy()
}
if instance_exists(o_lockedblock) {
if place_meeting(x,y,o_lockedblock) {
if o_lockedblock.sprite_index = s_lockedblock {
instance_destroy()
}}}
if instance_exists(o_unlockedblock) {
if place_meeting(x,y,o_unlockedblock) {
if o_unlockedblock.sprite_index = s_lockedblock {
instance_destroy()
}}}
timer -= 1 * (60 / global.maxfps);
if timer < 0 {
if place_meeting(x,y,o_shooter) or place_meeting(x,y,o_shooterright) or x > room_width {
instance_destroy()	
}}

scr_activateobjects()