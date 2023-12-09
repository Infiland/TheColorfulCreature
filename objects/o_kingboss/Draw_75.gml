if state != 0 {
if hp != 0 {
draw_set_font(global.deathfont)
//draw_text(100,100,"HP: " + string(hp))
//draw_text(100,120,string(x))
//draw_text(100,140,string(y))

if hp > maxhp - ((maxhp / 3) * 2) {
draw_set_color(c_yellow)
} else { draw_set_color(c_red) }
if hp > maxhp - (maxhp / 3) {
draw_set_color(c_lime)
}
draw_rectangle(100,70,100+hp,80,false)
draw_set_color(c_white)
}}