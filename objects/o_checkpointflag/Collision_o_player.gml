if o_player.vsp = 0 {
if image_index = 0 {
global.checkpointX = o_player.x
global.checkpointY = o_player.y
global.checkpointCOLOR = global.color
global.checkpointGRV = o_player.grv
global.checkpointAMMO = global.gunammo
if instance_exists(o_gunequipped) {
global.checkpointGUN = true	
}
image_index = 1
if !steam_get_achievement("CHECKPOINT") { steam_set_achievement("CHECKPOINT") }
}}