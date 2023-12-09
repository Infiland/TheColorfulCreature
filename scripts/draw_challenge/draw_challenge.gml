function draw_challenge(){
y = lerp(y,ystart - global.challengescroll,0.1 * (60 / global.maxfps))	
	
draw_set_color(c_white)
draw_set_font(global.deathfont)

draw_sprite_ext(s_challengetemplatebox,0,x,y,image_xscale,image_yscale,0,wincol,1)

if gamepad_axis_value(0,gp_axisrv) < -0.2 || gamepad_axis_value(0,gp_axisrv) > 0.2 { global.challengescroll += 2.5 * gamepad_axis_value(0,gp_axisrv) }

if mouse_wheel_down() {
global.challengescroll += 12
}
if mouse_wheel_up() {
global.challengescroll -= 12
}

if global.challengescroll < 0 {
global.challengescroll = 0	
}
if global.challengescroll > 500 {
global.challengescroll = 500
}

if os_type = os_android {
if mouse_check_button(mb_left) {
if mouse_y > 512 {global.challengescroll += 1} else { global.challengescroll -= 1 }
}}

//Text
draw_text(x-140,y-65,text)

 //Difficulty
 var diffspr = noone
  var sprnum = 0
 for(var i=0;i<difficulty;i++) {
	 switch(difficulty) {
	case(1): diffspr = s_playerwhite break; 
	case(2): diffspr = s_playerblue break; 
	case(3): diffspr = s_playergreen break; 
	case(4): diffspr = s_playeryellow break; 
	case(5): diffspr = s_playerred break; 
	default: diffspr = s_playerdead
	sprnum = 5
	break; 
	 }
	 
    draw_sprite_ext(diffspr,sprnum,x-(140-(i*25)),y+35,0.7,0.7,0,c_white,1)
 }
 
 if difficulty > 5 { draw_set_color(c_red) }
	draw_text(x-140,y+10,loc(656))
 
 draw_set_color(c_white)
draw_set_alpha(1)


if deaths = 0 {
	global.perfectscorecount = 0
	global.perfectscorecount += 1
	if !steam_get_achievement("PERFECT_CHALLENGE") { steam_set_achievement("PERFECT_CHALLENGE") }
	if global.perfectscorecount > 4 {
		if !steam_get_achievement("THE_ANTI_DEATH") { steam_set_achievement("THE_ANTI_DEATH") }
	}}

//Draw

draw_sprite_ext(s_medals,medalsprite,x+125,y+20,0.06,0.06,0,c_white,image_alpha)

draw_set_halign(fa_left)
if time != 9999 { draw_text(x-140,y-30,string(BESTTIME) + string(time)) }
if deaths != 999999 {
	draw_text(x-140,y-10,LEASTDEATHS + string(deaths))

draw_set_halign(fa_right)
if deaths > 49 { 
	draw_set_color(c_red)
	draw_text(x+140,y-30,TERRIBLE) }
if deaths >= 20 { 
if deaths < 50 { 
	draw_set_color(c_yellow)
	draw_text(x+140,y-30,MEDIOCRE) }}
if deaths >= 5 { 
if deaths < 20 { 
	draw_set_color(c_lime)
	draw_text(x+140,y-30,GOODJOB) }}
if deaths < 5 { 
if deaths != 0{ draw_set_color(c_fuchsia)
	draw_text(x+140,y-30,EPIC) }}
if deaths = 0 {
	draw_set_color(c_aqua)
	draw_text(x+140,y-30,PERFECT) }
}

if locked = 1 {
draw_set_color(c_black)
draw_set_alpha(0.9)
draw_rectangle(x-(150*image_xscale),y-(70*image_yscale),x+(150*image_xscale),y+(70*image_yscale),false)
draw_set_alpha(1)
draw_sprite(s_lock,0,x,y)
draw_set_color(c_white)
}
draw_set_halign(fa_left)
}