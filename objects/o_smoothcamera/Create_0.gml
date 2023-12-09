depth = -100

txtsize = 0
holdctrl = 0


if global.pause = 1 { exit }
if global.biglevelperfsettings = 0 { exit } else {
	instance_deactivate_object(o_anybackgroundblock)
}
if global.biglevelperfsettings > 1 {
instance_deactivate_object(o_anyblock)
instance_deactivate_object(o_anyitem)
}
var cam, cl, ct, cw, ch;
cam = view_camera[0]
cl = camera_get_view_x(cam)
ct = camera_get_view_y(cam)
cw = camera_get_view_width(cam)
ch = camera_get_view_height(cam)

instance_activate_region(cl-100,ct-100,cw+100,ch+100,true)

alarm[0] = 10

/*
camera = camera_create();
xzoom = 1024
yzoom = 768
var vm = matrix_build_lookat(x,y,-10,x,y,0,0,1,0)
var pm = matrix_build_projection_ortho(xzoom,yzoom,1,10000)
camera_set_view_mat(camera,vm)
camera_set_proj_mat(camera,pm)

view_camera[0] = camera
follow = o_player;
xTo = y;
yTo = y;