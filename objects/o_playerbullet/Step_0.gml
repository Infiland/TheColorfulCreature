if global.pause = 1 { 
	speed = 0
	exit }


speed = (7 * (60/global.maxfps)) / inwater

if playerbullet = 0 {
image_xscale += 0.2
image_yscale += 0.2
if image_xscale > 5 {
image_alpha -= 0.1 
if image_alpha < 0 {
instance_destroy()
}
}
}
if place_meeting(x,y,o_allliquids) { inwater = 2 } else { inwater = 1 }
if room = r_leveleditor {
if !instance_exists(o_player) {
instance_destroy();
}}


if hp = 0 {instance_destroy()}
if place_meeting(x,y,o_iceblock) {instance_destroy()}
if place_meeting(x,y,o_redblockmove) {instance_destroy()}
if place_meeting(x,y,o_yellowblockmove) {instance_destroy()}
if place_meeting(x,y,o_greenblockmove) {instance_destroy()}
if place_meeting(x,y,o_blueblockmove) {instance_destroy()}
if place_meeting(x,y,o_whiteblockmove) {instance_destroy()}
if place_meeting(x,y,o_deathblock) {instance_destroy()}
if place_meeting(x,y,o_shooter) {instance_destroy()}
if place_meeting(x,y,o_shooterright) {instance_destroy()}
if place_meeting(x,y,o_rocketlauncher) {instance_destroy()}
if place_meeting(x,y,o_rocketlauncherright) {instance_destroy()}
if playerbullet = 1 {
if place_meeting(x,y,o_onewayleftblock) {instance_destroy()}
}
if playerbullet = 2 {
if place_meeting(x,y,o_onewayrightblock) {instance_destroy()}
}