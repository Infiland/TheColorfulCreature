if global.LEMode = 1 {
depth = -10000
var obj = instance_number(o_leveleditorloadplacement)
draw_set_font(global.deathfont)
draw_set_halign(fa_right)
draw_set_color(c_white)
if obj > 1500 { draw_set_color(c_yellow) }
if obj > 3000 { draw_set_color(c_red) }
draw_text(992,736,"OBJ: " + string(obj))
draw_set_halign(fa_left)
}