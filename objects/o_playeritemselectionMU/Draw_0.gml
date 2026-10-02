if global.chooseminigameMU = false {
	draw_sprite_ext(s_liquidarrow,0,490,320,1,ui_arrow_yscale,0,c_white,1)
	draw_rectangle_color(0,205,1024,320,c_black,c_black,c_black,c_black,false)

// Custom asset occupies the existing -1 slot.
var _custom_x = 335 + realspritedistance;
draw_rectangle_color(_custom_x,205,_custom_x+100,305,c_dkgray,c_dkgray,c_dkgray,c_dkgray,false);
if (is_struct(custom_preview)) {
    cosmetics_draw_preview(custom_preview,_custom_x+50,255,90);
} else {
    draw_set_halign(fa_center);
    draw_set_font(global.deathfont);
    draw_text_color(_custom_x+50,240,"NO\nCUSTOM",c_gray,c_gray,c_gray,c_gray,1);
    draw_set_halign(fa_left);
}
for (var i = 0; i < global.MU_item_count; i++) {
	var _xpos = 455 + i * 120 + realspritedistance
	if (i > 0 && global.item[i] < 1) {
		draw_sprite(s_lockedhaticon,0,_xpos,205)
	} else {
		draw_sprite(global.MU_item_sprite[i],0,_xpos,205)
	}
}

draw_rectangle_color(822,205,1024,310,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(0,205,170,310,c_black,c_black,c_black,c_black,false)
draw_line_width_color(170,205,822,205,4,c_white,c_white)
draw_line_width_color(170,205,170,310,4,c_white,c_white)
draw_line_width_color(822,205,822,310,4,c_white,c_white)
draw_line_width_color(170,310,822,310,4,c_white,c_white)
}