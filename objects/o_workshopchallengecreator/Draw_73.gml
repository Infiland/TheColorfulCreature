draw_set_font(fnt_mainmenu)
draw_set_halign(fa_center)
draw_set_color(c_white)
draw_text(512,40,"Create Workshop Challenge")

draw_set_font(global.deathfont)
draw_set_halign(fa_left)

// Title field
draw_set_color(c_black)
draw_rectangle(160,110,864,150,false)
draw_set_color(c_white)
draw_rectangle(160,110,864,150,true)
var title_text = "Title: " + string(title)
if editing_title = 1 { title_text = "Title: " + string(keyboard_string) }
draw_text(170,120,title_text)

// Stats
draw_text(170,170,"Selected levels: " + string(selected_count))
draw_text(170,200,"Total diamond time: " + string(diamond_sum) + "s")
draw_text(170,230,"Average difficulty:")

// Difficulty icons (rounded)
var diff_disp = round(difficulty_avg)
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
	draw_sprite_ext(diffspr,sprnum,455 + (i*25),248,0.7,0.7,0,c_white,1)
}
if diff_disp = 0 {
	draw_set_color(c_white)
	draw_text_transformed(455,250,"Not rated",0.6,0.6,0)
}
draw_set_color(c_white)

draw_set_halign(fa_left)
draw_set_color(c_white)
draw_text(170,300,"Select workshop levels below. Press ESC to close.")
