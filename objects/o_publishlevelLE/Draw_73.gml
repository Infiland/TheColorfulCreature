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
draw_text(camx+512,camy+230,loc("READ_RULES_BEFORE_YOU_DO_SO_OTHERWISE_MODS_WILL_BE_VERY_ANGR"))
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
} else { draw_text(camx+512,camy+200,loc("THE_LEVEL_MUST_HAVE_A_PLAYER_AND_A_DOOR_PLACED_IN_ORDER_TO_B")) }
} else { draw_text(camx+512,camy+200,loc("DIAMOND_MEDAL_TIME_MUST_BE_THE_SAME_OR_HIGHER_THAN_YOUR_LEVE"))  }
} else { draw_text(camx+512,camy+200,loc("THE_LEVEL_MUST_HAVE_A_NAME_IN_ORDER_TO_BE_ABLE_TO_PUBLISH_IT")) }
} else { draw_text(camx+512,camy+200,"You must be logged on Steam to publish a level!") }
} else { draw_text(camx+512,camy+200,"Steam API must be enabled!") }
} else { draw_text(camx+512,camy+200,"Cheats must be disabled. Disable them by restarting the game.") }
//} else { draw_text(camx+512,200,loc("A_THUMBNAIL_IS_MISSING_TAKE_A_PICTURE_OF_THE_LEVEL")) }
} else {
if !instance_exists(o_playerspawner) || !instance_exists(o_door) {
draw_text(camx+512,camy+200,loc("THE_LEVEL_MUST_HAVE_A_PLAYER_AND_A_DOOR_PLACED_IN_ORDER_TO_B"))
} else {
draw_text(camx+512,camy+200,loc("COMPLETE_THE_LEVEL_IN_ORDER_TO_BE_ABLE_TO_PUBLISH_IT_ON_STEA"))
}
}

draw_set_color(c_white)
draw_text(camx+512,camy+600,"You can press ENTER to leave!")
draw_set_halign(fa_left)