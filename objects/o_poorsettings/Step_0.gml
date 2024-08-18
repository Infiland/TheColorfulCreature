event_inherited()
if global.vignettesettings = 0 and global.background = 0 and global.stars = 0 and global.itempar = 0 and global.playerpar = 0 and global.blockbackgroundsettings = 0 and global.whiteblock = 0 and global.visual3dsettings = 0 and global.watershadersettings = 0 {
image_alpha = 0.5	
} else { image_alpha = 1 }
if global.choosesettings != 1 { x = lerp(x,camera_get_view_x(view_camera[0])+1030,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 1 { x = lerp(x,camera_get_view_x(view_camera[0])+829,0.2 * (60 / global.maxfps)) }