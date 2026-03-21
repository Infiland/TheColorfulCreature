var camy = camera_get_view_y(view_camera[0])
if global.LEMode != 1 {
	instance_destroy()
	exit
}
var menu_open = instance_exists(o_itemmenuLE) || instance_exists(o_itemmenuselectLE)

// Grid snapping: snap mouse position to 32px grid when grid is enabled
var _grid_on = (instance_exists(o_LEgrid) && o_LEgrid.grid == 1);
var _mx = mouse_x;
var _my = mouse_y;
if (_grid_on) {
	_mx = round(mouse_x / 32) * 32;
	_my = round(mouse_y / 32) * 32;
}

if !menu_open && mouse_check_button_pressed(mb_left) {
if mouse_y > camy+64 {
if clicked = 0 {
x1 = _mx
y1 = _my
}
if clicked = 1 {
x2 = _mx
y2 = _my
}
if bad = 0 {
clicked += 1
}
}
if clicked = 2 {
if global.LEBuild = 3 {
var liquid = -1
if global.LES = 0 { liquid = o_water }
if global.LES = 1 { liquid = o_lava }
if liquid != -1 {
var createliquid = instance_create(x1,y1,liquid)
with createliquid {
image_xscale = -(other.x1-other.x2) / 1024
image_yscale = -(other.y1-other.y2) / 232
}
}
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
if collision_rectangle(x1,y1,_mx,_my,o_water,true,true) { bad = 1 }
if collision_rectangle(x1,y1,_mx,_my,o_lava,true,true) { bad = 1 }
