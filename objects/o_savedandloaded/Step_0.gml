var camy = camera_get_view_y(view_camera[0])

if timer > 0 {
timer -= 1	
}
if timer < 1 {
alpha -= 0.03 * (60 / global.maxfps)
}
if alpha < 0 { instance_destroy() }
y = lerp(y,camy+416,0.2 * (60 / global.maxfps))