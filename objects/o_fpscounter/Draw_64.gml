depth = -10000
timer += 1 * (60 / global.maxfps)
if timer > 15 {
fpsvariable = fps_real
timer = 0
}
if global.fpssettings = 2 { y2 = lerp(y2,140,0.5)} else {y2 = lerp(y2,120,0.5)}
if fpsvariable < 10000 { x2 = lerp(x2,990,0.3) }
if fpsvariable < 1000 { x2 = lerp(x2,975,0.3) }
if fpsvariable < 100 { x2 = lerp(x2,960,0.3) }
if room != r_tale {
draw_set_font(global.coolfont)
if fpsvariable < 2400 { draw_set_color(c_blue) }
if fpsvariable < 960 { draw_set_color(c_green) }
if fpsvariable < 144 { draw_set_color(c_yellow) }
if fpsvariable < 60 { draw_set_color(c_red) }
if fpsvariable > 2399 { draw_set_color(c_purple) }
draw_set_alpha(0.6)
draw_rectangle_color(893,96,x2,y2,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)
draw_set_halign(fa_left)
draw_text(896,96,string_hash_to_newline("FPS: "+string(round(fpsvariable))))
if global.fpssettings = 2 {draw_text(920,118,string("("+string(round(fps))+")"))}
draw_set_color(c_white)
}
if debug_mode = true {
show_debug_overlay(true)
}


//draw_text(mouse_x,mouse_y,string(xx)+"\n"+string(yy)+"\n"+string(ww)+"\n"+string(hh)+"\n")