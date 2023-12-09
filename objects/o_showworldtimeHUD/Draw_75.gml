draw_set_font(global.deathfont)
draw_set_color(c_yellow)

y = lerp(y,696,0.1 * (60 / global.maxfps))
draw_text_color(room_width-room_width+80+string_width(global.time),y,string_hash_to_newline(string_format(text,1,2 - global.decimalsettings)),c_yellow,c_orange,c_yellow,c_orange,image_alpha)
draw_set_color(c_white)

if y < 697 {
image_alpha -= 0.01	* (60 / global.maxfps)
}
if image_alpha < 0 { instance_destroy() }