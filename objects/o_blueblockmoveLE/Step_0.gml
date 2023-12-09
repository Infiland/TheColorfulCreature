if global.workshop = 0 {
if global.LEMode = 2 {
image_alpha = 0
if spawn = 1 {
if instance_exists(o_player) {
if !place_meeting(x,y,o_blueblockmove) {
instance_create(x,y,o_blueblockmove)
spawn = 0
}}}

if !instance_exists(o_player) {
spawn = 1
instance_destroy(o_blueblockmove)
}

} else {
image_alpha = 1
if instance_exists(o_blueblockmove) { instance_destroy(o_blueblockmove) }
}}