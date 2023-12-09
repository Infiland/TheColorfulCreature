y = camera_get_view_y(view_camera[0])
if x > (room_width + 1000) {
gotodirection = 1
image_speed = -1
}

if x < -1000 {
gotodirection = 0
image_speed = 1
}
if gotodirection = 0 { x += 1 / (global.maxfps / 144) }
if gotodirection = 1 { x -= 1 / (global.maxfps / 144) }