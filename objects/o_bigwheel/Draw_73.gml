draw_set_alpha(0.5)
draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)
draw_self()
depth = -100
draw_triangle(x-10,y-285,x+10,y-285,x,y-265,false)
draw_set_font(global.deathfont)
draw_set_halign(fa_center)
var mins = string_format((global.wheeltimeleft/60),0,0)
if global.wheeltimeleft > 0 {
draw_text_color(room_width / 2,y+300,string(text) + string(mins) + string(text2),c_yellow,c_orange,c_yellow,c_orange,1)
}
draw_set_font(fnt_secret1)

var col1 = c_orange
var col2 = c_red
if global.creditsmultiplier > 4.49 {
col1 = c_yellow
col2 = c_orange
}
if global.creditsmultiplier > 5.99 {
col1 = c_lime
col2 = c_yellow
}
if global.creditsmultiplier > 7.49 {
col1 = c_aqua
col2 = c_lime
}
if global.creditsmultiplier > 8.99 {
col1 = c_fuchsia
col2 = c_aqua
}

draw_text_color(room_width / 2,y+330,"MULTIPLIER: " + string(multi) + "X",col1,col2,col1,col2,1)

draw_set_halign(fa_left)