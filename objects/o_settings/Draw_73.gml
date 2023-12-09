draw_self()
draw_set_font(global.deathfont)
if x < 950 {
draw_text(320,600,"Wow! The cog is " + string(abs(x-950)) + " pixels away!")
}