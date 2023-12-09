/// @description Variables
declarecustombutton()
text = loc(145)

image_speed = 0;
depth = -10000

if room != r_support {
vx = 0
vy = 0
if instance_exists(o_smoothcamera) {
vx = camera_get_view_x(view_camera[0])
vy = camera_get_view_y(view_camera[0])

x = 750 + vx
y = 670 + vy
}}