if image_index = image_number - 2 {
	audio_sound_gain(m_trueending,0,8000)
}

image_alpha += 0.1

image_xscale = 2.5
image_yscale = 2.5

var image = image_index
var dth = depth

if image_index != image_number - 1 {
if image_alpha = 5 {
var ending = instance_create(x,y,o_endingslides)	
with ending {
image_index = image+1	
depth = dth - 1
}
}}

if image_alpha > 10 {
instance_destroy()	
if image_index = image_number - 1 {
if !instance_exists(o_endingslides) {
game_restart()
}}
}
alarm[0] = 5