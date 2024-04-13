if global.chooseminigameMU = false {
if global.multiplayerplayerconfigchoose = 1 {
spritedistance = -global.multiplayerplayeritem[0] * 120
}
if global.multiplayerplayerconfigchoose = 2 {
spritedistance = -global.multiplayerplayeritem[1] * 120
}
if global.multiplayerplayerconfigchoose = 3 {
spritedistance = -global.multiplayerplayeritem[2] * 120
}
if global.multiplayerplayerconfigchoose = 4 {
spritedistance = -global.multiplayerplayeritem[3] * 120
}
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
draw_sprite(s_nohaticon,0,455+realspritedistance,205)
if global.item[1] < 1 { draw_sprite(s_lockedhaticon,0,575+realspritedistance,205) } else {
draw_sprite(s_paintbrushitembutton,0,575+realspritedistance,205) }

draw_rectangle_color(822,205,1024,310,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(0,205,170,310,c_black,c_black,c_black,c_black,false)
draw_line_width_color(170,205,822,205,4,c_white,c_white)
draw_line_width_color(170,205,170,310,4,c_white,c_white)
draw_line_width_color(822,205,822,310,4,c_white,c_white)
draw_line_width_color(170,310,822,310,4,c_white,c_white)
}