if global.workshop = 0 {
if global.LEMode = 2 {
image_alpha = 0
if !place_meeting(x,y,o_redspiral) {
if !instance_exists(o_player) {
instance_create(x,y,o_redspiral)
}}

} else {
image_alpha = 1
if instance_exists(o_redspiral) { instance_destroy(o_redspiral) }
}}