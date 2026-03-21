if global.chooseminigameMU = false {
spritedistance = -global.multiplayerplayerskin[global.multiplayerplayerconfigchoose - 1] * 120
realspritedistance = lerp(realspritedistance,spritedistance,0.2 * (60 / global.maxfps))
	draw_sprite_ext(s_liquidarrow,0,490,320,1,arrowyscale,0,c_white,1)
	draw_rectangle_color(0,205,1024,320,c_black,c_black,c_black,c_black,false)
	if arrowyscale > 1 {
	change = 0
	}
	if arrowyscale < 0.9 {
	change = 1
	}
	if change = 0 { arrowyscale = lerp(arrowyscale,0.89,0.1 * (60 / global.maxfps)) } else { arrowyscale = lerp(arrowyscale,1.01,0.1 * (60 / global.maxfps)) }
//Custom Skin slot (index -1)
if global.CUSTOMskin != "" {
draw_set_halign(fa_center)
draw_set_font(global.deathfont)
draw_rectangle_color(335+realspritedistance,205,335+100+realspritedistance,205+100,c_purple,c_purple,c_purple,c_purple,false)
draw_rectangle_color(335+realspritedistance,205,335+100+realspritedistance,205+100,c_white,c_white,c_white,c_white,true)
draw_text_color(335+50+realspritedistance,240,"CUSTOM\nSKIN",c_white,c_white,c_white,c_white,1)
draw_set_halign(fa_left)
} else {
draw_set_halign(fa_center)
draw_set_font(global.deathfont)
draw_rectangle_color(335+realspritedistance,205,335+100+realspritedistance,205+100,c_dkgray,c_dkgray,c_dkgray,c_dkgray,false)
draw_text_color(335+50+realspritedistance,240,"NO\nCUSTOM",c_gray,c_gray,c_gray,c_gray,1)
draw_set_halign(fa_left)
}
for (var i = 0; i < global.MU_skin_count; i++) {
	var _xpos = 455 + i * 120 + realspritedistance
	if (i > 0 && global.skin[i + 1] < 1) {
		draw_sprite(s_lockedskinicon,0,_xpos,205)
	} else {
		draw_sprite(global.MU_skin_sprite[i],0,_xpos,205)
	}
}
draw_rectangle_color(822,205,1024,310,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(0,205,170,310,c_black,c_black,c_black,c_black,false)
draw_line_width_color(170,205,822,205,4,c_white,c_white)
draw_line_width_color(170,205,170,310,4,c_white,c_white)
draw_line_width_color(822,205,822,310,4,c_white,c_white)
draw_line_width_color(170,310,822,310,4,c_white,c_white)
}