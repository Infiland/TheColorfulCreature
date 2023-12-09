if boredom > 310 {
instance_destroy()
}
if boredom < 300 {
image_index = 2	
}
if boredom < 200 {
image_index = 1
}
if boredom < 100 {
image_index = 0	
}
if boredom < -100 {
instance_destroy()
}
if instance_exists(o_enemyplayer) {
if distance_to_object(o_enemyplayer) < 50 {
boredom += 1
}}
if instance_exists(o_enemyplayer) {
if distance_to_object(o_enemyplayer) > 50 {
boredom -= 1
}}