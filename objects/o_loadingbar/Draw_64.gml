draw_healthbar(224,672,768,704,timer*6.66,c_black,c_black,c_white,0,true,false)
draw_set_alpha((timer*6.66)/100)
draw_set_font(global.deathfont)
draw_text(loadingtextxposition,645,loc(665))
draw_set_alpha(1)
//Formula: 100 divided with timer 100/15