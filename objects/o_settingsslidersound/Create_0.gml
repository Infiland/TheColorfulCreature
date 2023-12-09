y = camera_get_view_y(view_camera[0]) + 377
depth = -10000000001
image_speed = 0
grab = false

xcam = camera_get_view_x(view_camera[0])
x = xcam + 116 + (global.soundvolume * 146) - 200
beginx = xcam + 116
endx = xcam + 262