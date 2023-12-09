draw_self();
draw_set_alpha(1)
draw_set_color(c_white)
if grab = true {
draw_set_font(global.coolfont)
if global.soundvolume > 0{
if global.soundvolume < 1{
draw_text(x-15,y+20,string_format(global.soundvolume * 100,0,0) + "%")
}}
if global.soundvolume = 0 { draw_text(x-20,y+20,"quiet") }
if global.soundvolume = 1 { draw_text(x-20,y+20,"LOUD") }
}