draw_set_alpha(0.5)
draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_font(global.gamemodefont)
draw_set_alpha(1)
draw_set_color(c_white)
draw_set_halign(fa_center)
draw_text(512,100,loc(139))
draw_text(512,200,string_format(global.LEStarRotation,0,0))
draw_set_font(global.deathfont)
if global.LEStarRotation < 10 {
draw_text(527,195,"o")
}
if global.LEStarRotation < 100 {
if global.LEStarRotation > 9 {
draw_text(552,195,"o")
}}
if global.LEStarRotation > 99 {
draw_text(577,195,"o")
}
draw_set_font(global.gamemodefont)
draw_text(512,300,loc(65) +".\n" + loc(135))
draw_set_halign(fa_left)