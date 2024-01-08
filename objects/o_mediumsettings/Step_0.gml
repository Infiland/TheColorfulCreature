event_inherited()
if global.vignettesettings = 1 and global.backround = 1 and global.stars = 1 and global.itempar = 1 and global.playerpar = 1 and global.blockbackgroundsettings = 1 and global.whiteblock = 1 and global.visual3dsettings = 0 and global.watershadersettings = 1 {
image_alpha = 0.5	
} else { image_alpha = 1 }
if global.choosesettings != 1 { x = lerp(x,camera_get_view_x(view_camera[0])+1030,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 1 { x = lerp(x,camera_get_view_x(view_camera[0])+829,0.2 * (60 / global.maxfps)) }