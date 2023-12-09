if room != r_leveleditor {
if instance_exists(o_player) {
x = o_player.x+16
y = o_player.y+16
} if instance_exists(o_playerdead) {
x = o_playerdead.x+16
y = o_playerdead.y+16
}}

if room = r_leveleditor {
if instance_exists(o_player) {
x = o_player.x+16
y = o_player.y+16
}
if !instance_exists(o_player) {
instance_destroy()	
}}