event_inherited()
image_index = global.berserk
if global.choosesettings != 4 { x = lerp(x,camera_get_view_x(view_camera[0])-256,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 4 { x = lerp(x,camera_get_view_x(view_camera[0])+32,0.2 * (60 / global.maxfps)) }

if global.cheats = 0 {
image_alpha = 0.5
} else { image_alpha = 1 }