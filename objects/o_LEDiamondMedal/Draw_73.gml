var camx = camera_get_view_x(view_camera[0])
var camy = camera_get_view_y(view_camera[0])
draw_sprite_ext(s_LEDiamondMedalTime,image_index,265 + camx,camy +(9 - (notselected * 64)),image_xscale,image_yscale,0,c_white,alpha)

x = camx + 265
y = camy + (9 - (notselected * 64))
if page = global.LEbuttonpage {
	notselected = lerp(notselected,0,0.2 * (60 / global.maxfps))
	} else {
notselected = lerp(notselected,1,0.2 * (60 / global.maxfps))
}

if y < -51+camy { alpha = 0 } else {
if global.LEMode = 1 { alpha = 1 } else
{ alpha = 0.5 }}