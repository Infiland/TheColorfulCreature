if instance_exists(o_player) {
if instance_place(x,y,o_player) {
draw_set_font(global.deathfont)
draw_set_color(c_black) draw_set_alpha(0.5)
draw_rectangle(x-204,y-80,x+236,(y-80)+string_length(text),false)
draw_set_color(c_white) draw_set_alpha(1)
draw_set_halign(fa_center)
draw_text_scribble_ext(x+16,y-80,string(text),400)
draw_set_halign(fa_left)
}}
