if global.workshop = 0 {
if global.LEMode = 2 {
image_alpha = 0
if spawn = 1 {
if instance_exists(o_player) {
if !place_meeting(x,y,o_spikemovingupdown) {
instance_create(x,y,o_spikemovingupdown)
spawn = 0
}}}

if !instance_exists(o_player) {
spawn = 1
instance_destroy(o_spikemovingupdown)
}

} else {
if instance_exists(o_spikemovingupdown) { instance_destroy(o_spikemovingupdown) }
image_alpha = 1
}}