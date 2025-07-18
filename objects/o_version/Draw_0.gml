draw_set_color(c_white)
draw_set_font(global.deathfont)
draw_text_scribble(588,128,"[wave]" + string(version))

if os_is_network_connected() {
if keyboard_check(vk_control) {
if (global.playercount + global.playercountdemo) = 0 { 
	draw_set_color(c_yellow)
	draw_text(32,712,loc(633) + ": 0 :(") } else {
draw_text(32,712,loc(633)+": " + string(global.playercount + global.playercountdemo)) }
} else { draw_text_scribble(32,712,"[c_white][scale,0.8]Original Author (2018 - " + string(global.calendarcurrentyear) + ") - Infiland") }
if (global.playercount + global.playercountdemo) > 1 {
draw_text_scribble(32,732,"[rainbow][wave]CREDITS MULTIPLIER: " + string(global.creditsmultiplier) + "X")
}} else {
draw_set_color(c_red)
draw_text(32,732,loc(635))	
}

draw_set_color(c_white)
if os_type != os_android {
var userid = steam_get_user_steam_id();
var name = steam_get_persona_name() //steam_get_user_persona_name(test)
draw_set_halign(fa_right)
draw_text(1000,416,string(name))

draw_set_font(global.coolfont)

if mouse_x > 930 { //Profile Picture
if mouse_x < 994 {
if mouse_y > 352 {
if mouse_y < 416 {
drawinfoboxbadge(loc(636),c_lime,c_orange)
}}}}

// Steam Avatar display would go here if needed
// steam_get_user_avatar(userid,steam_user_avatar_size_medium);
}
 
draw_set_halign(fa_left)
draw_set_font(global.deathfont)
draw_set_color(c_white)

//Splash Text
draw_text_scribble(5,5,splashtext)