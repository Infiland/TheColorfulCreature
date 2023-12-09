if global.pause = 1 { exit }

if instance_exists(o_player) {
dir = point_direction(x,y,o_player.x,o_player.y)
}
image_angle = lerp(image_angle,dir,0.03 * (60 / global.maxfps))
direction = image_angle

timer -= 1 * (60 / global.maxfps)
if timer < 0 {
var bullet = instance_create(x,y,o_SSUbullet)
with(bullet) {
if instance_exists(o_player) {
direction = o_SSUship.direction
}	
}
timer = 30
}