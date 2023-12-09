scr_playercontrolsconfig()

randomize()
depth = 7
caninteract = 0
interacted = 0
color = make_color_rgb(255,200,200)

if global.world5 = 0 {
textnumber = irandom_range(1,15)
} else { textnumber = irandom_range(1,16) }
text = ""