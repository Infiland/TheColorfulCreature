if global.workshop = 0 {
if global.LEMode = 2 {
image_alpha = 0
if spawn = 1 {
if instance_exists(o_player) {
if !place_meeting(x,y,o_spikemovingrightleft) {
instance_create(x,y,o_spikemovingrightleft)
spawn = 0
}}}

if !instance_exists(o_player) {
spawn = 1
instance_destroy(o_spikemovingrightleft)
}

} else {
if instance_exists(o_spikemovingrightleft) { instance_destroy(o_spikemovingrightleft) }
image_alpha = 1
}}