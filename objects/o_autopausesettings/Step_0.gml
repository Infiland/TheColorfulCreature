event_inherited()
image_index = global.autopausesettings
if global.choosesettings != 0 { x = lerp(x,camera_get_view_x(view_camera[0])-256,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 0 { x = lerp(x,camera_get_view_x(view_camera[0])+32,0.2 * (60 / global.maxfps)) }