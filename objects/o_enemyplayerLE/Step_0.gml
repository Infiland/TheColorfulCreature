if global.workshop = 0 {
if global.LEMode = 2 {
image_alpha = 0
if canspawn = 1 {
if !place_meeting(x,y,o_enemyplayer) {
if instance_exists(o_player) {
instance_create(x,y,o_enemyplayer)
canspawn = 0
}}}
if !instance_exists(o_player) {
canspawn = 1
}

} else {
image_alpha = 1
if instance_exists(o_enemyplayer) { instance_destroy(o_enemyplayer) }
}}