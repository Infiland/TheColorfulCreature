if global.pause = 1 { exit }

/*if creditsborder = credits {
if redB >= 0 {
redB -= 1
}} else {
if redB <= 255 {
redB += 5
}}*/
draw_set_color(c_black)
draw_rectangle(p1,p3,p2,p4,false)
draw_set_color(c_white)
draw_set_color(ui_credits_border_color)

//draw_set_color(colorB)
draw_line_width(p1,p3,p2,p3,2)
draw_line_width(p1,p3,p1,p4,2)
draw_line_width(p2,p3,p2,p4,2)
draw_line_width(p1,p4,p2,p4,2)
draw_set_color(c_white)
draw_sprite_ext(s_creditscurrency,0,creditsiconx,creditsicony,2,2,0,c_white,1)
draw_set_halign(fa_right)
draw_set_font(global.deathfont)
	var num_digits = 7
credits_text = string(round(credits));
credits_text = string_repeat("0", num_digits - string_length(credits_text)) + credits_text;
if credits < 10000000 {
draw_text(creditsx,creditsy,credits_text)
} 
if credits > 9999999 {
if credits < 1000000000 {
	draw_set_color(make_color_rgb(red,green,blue))
	draw_text(creditsx,creditsy,string(credits / 1000000) + "M")
	}}
if credits > 999999999 {
if credits < 1000000000000 {
	draw_set_color(make_color_rgb(red,green,blue))
	draw_text(creditsx,creditsy,string(credits / 1000000000) + "B")
	}}
if credits > 999999999999 {
	draw_set_color(c_red)
	draw_text(creditsx,creditsy,"Cheater")
}
	
draw_set_color(c_white)
draw_set_halign(fa_left)