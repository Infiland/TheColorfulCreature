if instance_exists(o_pausescreen) { instance_destroy() }

if room = r_hardmodedeathroom {instance_destroy()}

if !instance_exists(o_smoothcamera) {
y = lerp(y,room_height/2,0.1* (60 / global.maxfps))
x = room_width / 2
} else {
y = lerp(y,o_smoothcamera.y,0.1* (60 / global.maxfps))
x = camera_get_view_border_x(view_camera[0]) / 2
}
timerdifficultylogo += 1* (60 / global.maxfps)
if instance_place(x,y,o_player) {
timerdifficultylogo += 1* (60 / global.maxfps)
}
if timerdifficultylogo > 70 {
image_alpha -= 0.02* (60 / global.maxfps)
if image_alpha < 0 {
instance_destroy()	
}
}