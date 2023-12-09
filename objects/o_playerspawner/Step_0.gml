if global.workshop = 0 {
if global.LEMode = 2 {
image_alpha = 0
if !instance_exists(o_player) {
leveleditorrespawncooldown -= 1
if leveleditorrespawncooldown = 0 {
leveleditorrespawncooldown = 3
if !instance_exists(o_playerdeadLE) {
instance_destroy(o_playerdead)
var createplayer = instance_create(x,y,o_player)
with createplayer { global.color = global.defaultcolorLE }
instance_destroy(o_playerdead)
}
}
}

} else {
image_alpha = 1
if instance_exists(o_player) { instance_destroy(o_player) }
}}