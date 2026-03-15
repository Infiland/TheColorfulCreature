if filtered_out = 1 { exit; }

y = lerp(y,base_y - global.workshopchallenge_scroll,0.1 * (60 / global.maxfps))

if y < 320 { exit; }
if y > 610 { exit; }

var border_col = c_white
if selected = 1 { border_col = c_lime }

draw_rectangle_color(room_width/2-200,y,room_width/2+200,y+90,c_black,$1d1d1d,c_black,$1d1d1d,false)
draw_rectangle_color(room_width/2-200,y,room_width/2+200,y+90,border_col,border_col,border_col,border_col,true)
draw_set_color(c_white)
draw_set_font(global.deathfont)
draw_set_halign(fa_left)

var check = selected ? ("[" + string(selected_order) + "] ") : "[ ] "
draw_text(room_width/2-190,y+10,check + string(mTitle))
draw_text(room_width/2-190,y+40,"Diamond: " + string(diamond_time) + "s")

//Difficulty icons
var diff_disp = difficulty
if diff_disp < 0 { diff_disp = 0 }
if diff_disp > 6 { diff_disp = 6 }

var diffspr = noone
var sprnum = 0
draw_set_color(c_white)
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
	draw_sprite_ext(diffspr,sprnum,(room_width/2+110) + (i*25),y+65,0.7,0.7,0,c_white,1)
}
if diff_disp = 0 {
	draw_set_color(c_white)
	draw_text_transformed(room_width/2+190,y+70,"Not rated",0.6,0.6,0)
}

draw_set_color(c_white)
