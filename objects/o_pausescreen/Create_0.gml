depth = -1000000000
vx = 0
vy = 0
if instance_exists(o_smoothcamera) {
vx = camera_get_view_x(view_camera[0])
vy = camera_get_view_y(view_camera[0])
}

x = 288 + vx
y = 288 + vy