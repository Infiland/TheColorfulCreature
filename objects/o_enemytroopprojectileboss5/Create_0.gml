speed = 10 * (60 / TCC_SIM_HZ)
if instance_exists(o_player) {
direction = point_direction(x,y,o_player.x+16,o_player.y+16)
}