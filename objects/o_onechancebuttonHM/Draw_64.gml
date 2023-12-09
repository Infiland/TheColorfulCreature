scr_custombutton()
draw_set_font(global.deathfont)
if global.hardmodeunlock > 4 {
if mouseon = 1 { draw_text(32,672,"You start with only one life, getting 1UPs is more rare. You will regret this.") }
}