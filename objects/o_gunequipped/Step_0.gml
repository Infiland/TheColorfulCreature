key_interact = keyboard_check_pressed(ord(global.controlsinteract)) || (gamepad_button_check_pressed(4,gp_shoulderr));
if instance_exists(o_player) {

if o_player.zerogrv = 0 {
x = o_player.x + xcord + 9
y = o_player.y + ycord + 23
} else {
x = o_player.x + xcord - 7
y = o_player.y + ycord + 7
}

//Right
if timer < 30 {
if global.playermove = 1 {
	gunrotation = 0
	xcord = lerp(xcord,-2,0.2)
	ycord = lerp(ycord,10,0.2)
	}
//Left
if global.playermove = -1 {
	gunrotation = 60
	xcord = lerp(xcord,-5,0.2)
	ycord = lerp(ycord,10,0.2)
	}
}
timer += 1* (60 / global.maxfps)
image_index = lerp(image_index,gunrotation,0.1* (60 / global.maxfps))
image_angle = lerp(image_angle,0,0.3* (60 / global.maxfps))
}
if instance_exists(o_playerdead) {
image_speed = 2
}
if !instance_exists(o_player) {
if room = r_leveleditor {
instance_destroy()	
}}
if timer > 30 {
gunrotation = 30
xcord = lerp(xcord,9,0.2* (60 / global.maxfps))
	ycord = lerp(ycord,5,0.2* (60 / global.maxfps))
}
if instance_exists(o_player) {
if key_interact {
if o_player.inwater = 1 {
if global.gunammo > 0 {
timer = 0
if global.playermove = -1 {
if global.playerpar = 1 { instance_create(x+20,y-10,o_ammoparticle) }
	image_angle = -40
}
if global.playermove = 1 {
if global.playerpar = 1 { instance_create(x,y-10,o_ammoparticle) }
	image_angle = 40
}}}}}