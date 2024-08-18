event_inherited()
if global.vignettesettings = 1 and global.background = 1 and global.stars = 2 and global.itempar = 1 and global.playerpar = 2 and global.blockbackgroundsettings = 1 and global.whiteblock = 2 and global.visual3dsettings = 1 and global.watershadersettings = 1 {
image_alpha = 0.5	
} else { image_alpha = 1 }
if global.choosesettings != 1 { x = lerp(x,camera_get_view_x(view_camera[0])+1030,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 1 { x = lerp(x,camera_get_view_x(view_camera[0])+900,0.2 * (60 / global.maxfps)) }