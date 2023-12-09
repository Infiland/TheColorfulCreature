var camy = camera_get_view_y(view_camera[0])

if mouse_check_button_pressed(mb_left) {
if mouse_y > camy+64 {
if clicked = 0 {
global.x1liquid = mouse_x
global.y1liquid = mouse_y
}
if clicked = 1 {
global.x2liquid = mouse_x
global.y2liquid = mouse_y
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
createliquid = instance_create(global.x1liquid,global.y1liquid,liquid)
with createliquid {
image_xscale = -(global.x1liquid-global.x2liquid) / 1024
image_yscale = -(global.y1liquid-global.y2liquid) / 232
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
if collision_rectangle(global.x1liquid,global.y1liquid,mouse_x,mouse_y,o_water,true,true) { bad = 1 }
if collision_rectangle(global.x1liquid,global.y1liquid,mouse_x,mouse_y,o_lava,true,true) { bad = 1 }