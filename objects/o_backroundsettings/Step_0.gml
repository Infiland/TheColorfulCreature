event_inherited()
image_index = global.backround
if global.choosesettings != 1 { x = lerp(x,camera_get_view_x(view_camera[0])-256,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 1 { x = lerp(x,camera_get_view_x(view_camera[0])+32,0.2 * (60 / global.maxfps)) }