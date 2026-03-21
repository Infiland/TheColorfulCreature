y = lerp(y,ystart - global.workshopchallenges_scroll,0.1 * (60 / global.maxfps))

if y < -90 { exit; }
if y > 680 { exit; }

draw_rectangle_color(room_width/2-200,y,room_width/2+200,y+90,c_black,$1d1d1d,c_black,$1d1d1d,false)
draw_rectangle_color(room_width/2-200,y,room_width/2+200,y+90,c_white,c_white,c_white,c_white,true)
draw_set_color(c_white)
draw_set_font(global.deathfont)
draw_set_halign(fa_center)

if invalid = 1 {
	draw_set_color(c_red)
	draw_text(room_width/2,y+12,string(title))
	draw_set_color(c_white)
	draw_text(room_width/2,y+48,"Missing or invalid challenge.json")
	draw_set_halign(fa_left)
	exit;
}

draw_text_ext(room_width/2,y+2,string(title),20,300)
draw_text(room_width/2,y+42,"Levels: " + string(level_count))

draw_set_halign(fa_left)
draw_text(room_width/2-190,y+70,"Diamond: " + string(diamond_time) + "s")

//Difficulty (rounded display)
var diff_disp = round(difficulty)
if diff_disp < 0 { diff_disp = 0 }
if diff_disp > 6 { diff_disp = 6 }

var diffspr = noone
var sprnum = 0
for(var i=0;i<diff_disp;i++) {
	switch(diff_disp) {
	case(1): diffspr = s_playerwhite break; 
	case(2): diffspr = s_playerblue break; 
	case(3): diffspr = s_playergreen break; 
	case(4): diffspr = s_playeryellow break; 
	case(5): diffspr = s_playerred break; 
	case(6):
		diffspr = s_playerdead
		draw_set_color(c_red)
		sprnum = 5
	break; 
	}
	draw_sprite_ext(diffspr,sprnum,(room_width/2+110) + (i*25),y+68,0.7,0.7,0,c_white,1)
}
if diff_disp = 0 {
	draw_set_color(c_white)
	draw_text_transformed(room_width/2+190,y+70,"Not rated",0.6,0.6,0)
}

// Missing levels warning
if missing_levels > 0 {
	draw_set_halign(fa_right)
	draw_set_color(c_yellow)
	draw_text(room_width/2+190,y+42,string(missing_levels) + " missing")
}

draw_set_halign(fa_left)
draw_set_color(c_white)

