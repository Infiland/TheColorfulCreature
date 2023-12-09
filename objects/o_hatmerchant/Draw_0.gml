draw_self()
scr_playercontrolsconfig()
draw_set_halign(fa_center)
draw_set_font(global.cool2font)
color = make_color_rgb(255,200,200)
draw_set_color(color)
if interacted = 0 {
if caninteract = 1 {

draw_set_color(c_white)
if os_type != os_android {
controls_key_display(global.controlsinteract)
draw_text(x+16,ystart - 64,"Press [" + string(keyd) + "] to interact.")
} else { draw_text(x+16,ystart - 64,"Press [I] to interact.") }
}} else {
if global.creditscurrency < 50 {
if global.hardmode = 0 { draw_text(x+16,ystart - 64,loc(208)) }
if global.hardmode = 1 { draw_text(x+16,ystart - 64,loc(209)) }
if !instance_exists(o_creditscounter) {
instance_create(x,y,o_creditscounter)
}
} else {
if instance_exists(o_hatshopmenu) {
draw_text(x+16,ystart - 64,text)
} else { draw_text(x+16,ystart - 64,loc(210)) } 
//Shop Appears
if !instance_exists(o_creditscounter) {
instance_create(x,y,o_creditscounter)
instance_create(x,y,o_hatshopmenu)
}
}
}
draw_set_halign(fa_left)