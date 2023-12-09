/// @description Variables
declarecustombutton()
image_xscale = 20
image_yscale = 10
xscale = 0.5
yscale = 0.5
width = 3

text = loc(7);

ingame = false
image_speed = 0;
if room = r_leveleditor {
alarm[0] = 1	
}
if instance_exists(o_pausescreen) {
vx = 0
vy = 0

text = loc(62)
xscale = 0.3
yscale = 0.3
if instance_exists(o_smoothcamera) {
vx = camera_get_view_x(view_camera[0])
vy = camera_get_view_y(view_camera[0])
}

oldx = 480 + vx
oldy = 490 + vy
}