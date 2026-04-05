/// @description Draw loading overlay (Draw GUI) - only when waiting

if state != "waiting" { exit }

// Dark overlay
draw_set_alpha(0.85)
draw_set_color(c_black)
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false)
draw_set_alpha(1)

// Loading text
draw_set_color(c_white)
draw_set_font(global.deathfont)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)

var dotstr = ""
repeat(dots) { dotstr += "." }

draw_text(display_get_gui_width() / 2, display_get_gui_height() / 2 - 30, loc("WORKSHOP_ER_DOWNLOADING") + dotstr)

// Level counter
draw_text(display_get_gui_width() / 2, display_get_gui_height() / 2 + 30, string(global.endlesslevel + 1))

draw_set_halign(fa_left)
draw_set_valign(fa_top)
