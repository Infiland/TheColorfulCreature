if global.pause = 1{ image_speed = 0 }
if global.pause = 0{ image_speed = 1 }
if died = 0 {
if holding = 1 {
if instance_exists(o_player) {	
if o_player.torchcount = 2 {
sprite_index = s_twotorches	
}
if o_player.zerogrv = 0 {
x = o_player.x + 13
y = o_player.y + 4
} else {
x = o_player.x - 3
y = o_player.y - 12
}
}}}
if holding = 1 {
if !instance_exists(o_player) {
if global.pause = 1{ exit }
sprite_index = s_torch
died = 1
}}

if died = 1 { fall += 0.25
randomize()
image_alpha -= 0.025
if image_alpha < 0 {
instance_destroy()	
}
y -= 5 - fall
image_angle += rotate
x = x + gotheredead
}