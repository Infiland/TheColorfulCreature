/// @description Variables
declarecustombutton()
text = loc(612)

challenge = r_tutoriallvl1

image_speed = 0;
image_index = 0
depth = -10000

if room != r_support {
vx = 0
vy = 0
if instance_exists(o_smoothcamera) {
vx = camera_get_view_x(view_camera[0])
vy = camera_get_view_y(view_camera[0])

x = 570 + vx
y = 670 + vy
}}