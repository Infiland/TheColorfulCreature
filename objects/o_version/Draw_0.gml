draw_set_color(c_white)
draw_set_font(global.deathfont)
draw_text_scribble(588,128,"[wave]" + string(version))

if os_is_network_connected() {
if keyboard_check(vk_control) {
if (global.playercount + global.playercountdemo) = 0 { 
	draw_set_color(c_yellow)
	draw_text(32,712,loc(633) + ": 0 :(") } else {
draw_text(32,712,loc(633)+": " + string(global.playercount + global.playercountdemo)) }
} else { draw_text_scribble(32,712,"[c_white][scale,0.8]Copyright " + string(global.calendarcurrentyear) + " - Infiland") }
if (global.playercount + global.playercountdemo) > 1 {
draw_text_scribble(32,732,"[rainbow][wave]CREDITS MULTIPLIER: " + string(global.creditsmultiplier) + "X")
}} else {
draw_set_color(c_red)
draw_text(32,732,loc(635))	
}

draw_set_color(c_white)
if os_type != os_android {
var userid = steam_get_user_steam_id();
var a = 0
var name = steam_get_persona_name() //steam_get_user_persona_name(test)
draw_set_halign(fa_right)
draw_text(1000,416,string(name))

//draw_text(mouse_x,mouse_y,actualmoni)

draw_set_font(global.coolfont)

/*moni = 0
actualmoni = 0
if steam_user_owns_dlc(2411810) {
	moni = 1
	actualmoni += 2
}
if steam_user_owns_dlc(2411811) {
	moni = 1
	actualmoni += 3
}
if steam_user_owns_dlc(2411812) {
	moni = 1
	actualmoni += 5
}*/
var b=0,s=0,g=0,bl=0

if mouse_x > 930 { //Profile Picture
if mouse_x < 994 {
if mouse_y > 352 {
if mouse_y < 416 {
drawinfoboxbadge(loc(636),c_lime,c_orange)
}}}}
//THE COLORFUL CREATURE
draw_sprite(s_badgesmenu,7,970-a*32,446)
if game1 > 1 { draw_text(1000-a*32,460,game1) }
if mouse_x > (970-a*32) { 
if mouse_x < (1002-a*32) {
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(637),c_lime,c_green)
}}}}
//COMMENTARY
if dlc1 = 1 {
draw_sprite(s_badgesmenu,5,970-a*32-(game1*32),446)
if mouse_x > (970-a*32-(game1*32)) {
if mouse_x < (1002-a*32-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(638),c_yellow,c_orange)
}}}}}
//OST
if dlc2 > 0 {
draw_sprite(s_badgesmenu,6,970-a*32-(dlc1*32)-(game1*32),446)
if mouse_x > (970-a*32-(dlc1*32)-(game1*32)) {
if mouse_x < (1002-a*32-(dlc1*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(639),c_blue,c_aqua)
}}}}}
//ASTEROIDS++
if dlc3 > 0 {
draw_sprite(s_badgesmenu,4,970-a*32-(dlc1*32)-(dlc2*32)-(game1*32),446)
if mouse_x > (970-a*32-(dlc1*32)-(dlc2*32)-(game1*32)) {
if mouse_x < (1002-a*32-(dlc1*32)-(dlc2*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(667),c_gray,c_lime)
}}}}}
//Money
if moni > 0 {
var spr = 0
switch(actualmoni) {
default: moni = 0 break;
case(2): spr = 8 break;
case(3): spr = 9 break;
case(5): spr = 10 break;
case(7): spr = 11 break;
case(8): spr = 12 break;
case(10): spr = 13 break;
}

draw_sprite(s_badgesmenu,spr,970-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(game1*32),446)
if mouse_x > (970-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(game1*32)) {
if mouse_x < (1002-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
	if actualmoni != 10 {
drawinfoboxbadge(loc(668),c_green,c_lime)
	} else {
	drawinfoboxbadge(loc(670),c_yellow,c_orange)	
	}
}}}}}
//1ST PLACE
if e1 > 0 { g=1
draw_sprite(s_badgesmenu,0,970-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),446)
if e1 > 1 { draw_text(1000-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),460,e1) }
if mouse_x > (970-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {
if mouse_x < (1002-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(640),c_olive,c_yellow)
}}}}}
//2ND PLACE
if e2 > 0 { s=1
draw_sprite(s_badgesmenu,1,970-a*32-(g*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),446)
if e2 > 1 { draw_text(1000-a*32-(g*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),460,e2) }
if mouse_x > (970-a*32-(g*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {
if mouse_x < (1002-a*32-(g*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(641),c_gray,c_ltgray)
}}}}}
//3RD PLACE
if e3 > 0 { b=1
draw_sprite(s_badgesmenu,2,970-a*32-(g*32)-(s*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),446)
if e3 > 1 { draw_text(1000-a*32-(g*32)-(s*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),460,e3) }
if mouse_x > (970-a*32-(g*32)-(s*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {
if mouse_x < (1002-a*32-(g*32)-(s*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(642),#804f1c,#b0691c)
}}}}}
//4TH PLACE
if e4 > 0 { bl=1
draw_sprite(s_badgesmenu,3,970-a*32-(g*32)-(s*32)-(b*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),446)
if e4 > 1 { draw_text(1000-a*32-(g*32)-(s*32)-(b*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),460,e4) }
if mouse_x > (970-a*32-(g*32)-(s*32)-(b*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {
if mouse_x < (1002-a*32-(g*32)-(s*32)-(b*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(643),c_gray,c_dkgrey)
}}}}}
//COMMUNITY HAT
if hats > 0 { bl=1
draw_sprite(s_badgesmenu,14,970-a*32-(g*32)-(s*32)-(b*32)-(bl*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),446)
if hats > 1 { draw_text(1000-a*32-(g*32)-(s*32)-(b*32)-(bl*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),460,e4) }
if mouse_x > (970-a*32-(g*32)-(s*32)-(b*32)-(bl*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {
if mouse_x < (1002-a*32-(g*32)-(s*32)-(b*32)-(bl*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge("Made a community hat!",c_green,c_purple)
}}}}}

/*draw_text(mouse_x,mouse_y,g)
draw_text(mouse_x,mouse_y+20,s)
draw_text(mouse_x,mouse_y+40,b)
draw_text(mouse_x,mouse_y+60,bl)*/
global.asteroidskeypoints = 0
global.asteroidskeypoints += game1
global.asteroidskeypoints += e4
global.asteroidskeypoints += e3*2
global.asteroidskeypoints += e2*3
global.asteroidskeypoints += e1*5
global.asteroidskeypoints += dlc1*10
global.asteroidskeypoints += dlc2*5
global.asteroidskeypoints += actualmoni*5
}
 
//steam_get_user_avatar(userid,steam_user_avatar_size_medium);

draw_set_halign(fa_left)
draw_set_font(global.deathfont)
draw_set_color(c_white)

//Splash Text
draw_text_scribble(5,5,splashtext)