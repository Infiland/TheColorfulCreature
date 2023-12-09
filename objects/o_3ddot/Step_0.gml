if !instance_exists(o_smoothcamera) {
/*if instance_exists(o_player) {
x = o_player.x
y = o_player.y
}
if !instance_exists(o_player) {
x = room_width/2
y = room_height/2
}*/
x = room_width/2
y = room_height/2
}
if instance_exists(o_smoothcamera) {
x = o_smoothcamera.x
y = o_smoothcamera.y
}