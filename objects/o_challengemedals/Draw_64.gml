draw_set_halign(fa_right)
draw_set_font(global.deathfont)
draw_set_color(c_white)
draw_set_alpha(1)
//Time
var _def = scr_challenge_get_def(challenge);
if (!is_undefined(_def) && scr_challenge_is_unlocked(_def)) {
	time = scr_challenge_get_time(_def.id);
	deaths = scr_challenge_get_deaths(_def.id);
}

//Draw
if global.challengeinfo = true {
draw_set_halign(fa_left)
draw_text(x-270,y-50,BESTTIME + string(time))
if deaths != 999999 {
	draw_text(x-270,y-30,LEASTDEATHS + string(deaths))
	
if deaths > 100 { 
	draw_set_color(c_red)
	draw_text(x-270,y-10,TERRIBLE) }
if deaths >= 20 { 
if deaths < 100 { 
	draw_set_color(c_yellow)
	draw_text(x-270,y-10,MEDIOCRE) }}
if deaths >= 5 { 
if deaths < 20 { 
	draw_set_color(c_lime)
	draw_text(x-270,y-10,GOODJOB) }}
if deaths < 5 { 
if deaths != 0{ draw_set_color(c_fuchsia)
	draw_text(x-270,y-10,EPIC) }}
if deaths = 0 {
	draw_set_color(c_aqua)
	draw_text(x-270,y-10,PERFECT) }
}
}
