draw_self()
draw_set_font(global.deathfont)
draw_set_color(c_white)
if global.wheeltimeleft > 0 {
var mins = string_format((global.wheeltimeleft/60),0,0)
draw_set_halign(fa_center)
draw_text(x,y+52,mins + "m")
draw_set_halign(fa_left)
if image_angle != 0 {
image_angle = 0	
}
} else {
image_angle += 3
}