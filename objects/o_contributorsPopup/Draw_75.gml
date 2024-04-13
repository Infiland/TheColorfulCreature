draw_set_alpha(0.95)
draw_rectangle_color(0,0,2000,2000,c_black,c_black,c_black,c_black,false)

draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_set_font(global.deathfont)
draw_text_transformed(room_width/2,70,loc(681) + ":",2,2,0)

draw_set_font(global.cool2font)
//YOU EDIT THIS FILE

draw_text_scribble_ext(room_width/2,160,names,900)

draw_set_halign(fa_left)
draw_set_valign(fa_top)