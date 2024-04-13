//Logic for the quests menu to appear
alphalerp = lerp(alphalerp,0.8,0.1)
draw_set_alpha(alphalerp)
draw_set_color(c_white)
draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_set_font(global.deathfont)
draw_rectangle_color(0,0,1024,768,c_black,c_black,c_black,c_black,false)

draw_set_alpha(alphalerp*3)
draw_text_transformed(room_width/2,70,"Quests",2,2,0)

//QUEST 1
draw_rectangle_color(100,150,924,300,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(100,150,924,300,c_white,c_white,c_white,c_white,true)

draw_set_halign(fa_left)