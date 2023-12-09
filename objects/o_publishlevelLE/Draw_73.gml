draw_set_alpha(0.5)
var camx = camera_get_view_x(view_camera[0])
var camy = camera_get_view_y(view_camera[0])

draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_font(global.gamemodefont)
draw_set_alpha(1)
draw_set_color(c_white)
draw_set_halign(fa_center)
draw_text(camx+512,camy+100,"Publish your level!")
draw_set_font(global.deathfont)
if global.LEVerified = 1 {
if global.cheats = 0 {
if global.steam_api = true {
if steam_is_user_logged_on() {
if global.levelname != "" {
if global.LEDiamondMedalTime >= global.LESavedWinTime {
if instance_exists(o_playerspawner) || instance_exists(o_door) {
draw_set_color(c_lime)
draw_text(camx+512,camy+200,"You can publish your level on Steam Workshop!")
draw_set_color(c_yellow)
draw_text(camx+512,camy+230,loc(555))
if !instance_exists(o_readworkshoprulesLE) {
var button = instance_create(400,340,o_readworkshoprulesLE)
with button {
image_xscale = 45.8
image_yscale = 20.2
}}
if !instance_exists(o_publishlevelbuttonLE) {
var button = instance_create(400,460,o_publishlevelbuttonLE)
with button {
image_xscale = 45.8
image_yscale = 20.2
}}
} else { draw_text(camx+512,camy+200,loc(557)) }
} else { draw_text(camx+512,camy+200,loc(563))  }
} else { draw_text(camx+512,camy+200,"The level must have a name in order to be able to publish it on Steam Workshop!") }
} else { draw_text(camx+512,camy+200,"You must be logged on Steam to publish a level!") }
} else { draw_text(camx+512,camy+200,"Steam API must be enabled!") }
} else { draw_text(camx+512,camy+200,"Cheats must be disabled. Disable them by restarting the game.") }
//} else { draw_text(camx+512,200,loc(593)) }
} else {
if !instance_exists(o_playerspawner) || !instance_exists(o_door) {
draw_text(camx+512,camy+200,loc(557))
} else {
draw_text(camx+512,camy+200,loc(554))
}
}

draw_set_color(c_white)
draw_text(camx+512,camy+600,"You can press ENTER to leave!")
draw_set_halign(fa_left)