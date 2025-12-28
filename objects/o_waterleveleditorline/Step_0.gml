var camy = camera_get_view_y(view_camera[0])
if global.LEMode != 1 {
	instance_destroy()
	exit
}
var menu_open = instance_exists(o_itemmenuLE) || instance_exists(o_itemmenuselectLE)

if !menu_open && mouse_check_button_pressed(mb_left) {
if mouse_y > camy+64 {
if clicked = 0 {
x1 = mouse_x
y1 = mouse_y
}
if clicked = 1 {
x2 = mouse_x
y2 = mouse_y
}
if bad = 0 {
clicked += 1
}
}
if clicked = 2 {
if global.LEBuild = 3 {
if global.LES = 0 { liquid = o_water }
if global.LES = 1 { liquid = o_lava }
}
var createliquid = instance_create(x1,y1,liquid)
with createliquid {
image_xscale = -(other.x1-other.x2) / 1024
image_yscale = -(other.y1-other.y2) / 232
}
instance_destroy()
}
}

if instance_exists(o_deleteblock) { instance_destroy() }
if global.LEBuild != 3 { instance_destroy() }
bad = 0
if mouse_y < camy+64 { bad = 1 }
if mouse_x < 0 { bad = 1 }
if mouse_x > room_width { bad = 1 }
if collision_rectangle(x1,y1,mouse_x,mouse_y,o_water,true,true) { bad = 1 }
if collision_rectangle(x1,y1,mouse_x,mouse_y,o_lava,true,true) { bad = 1 }
