if !instance_exists(o_smoothcamera) {
x = lerp(x,room_width/2,0.1* (60 / global.maxfps))
}
if instance_exists(o_smoothcamera) {
x = lerp(x,o_smoothcamera.x,0.1* (60 / global.maxfps))
}
timergunlogo += 1* (60 / global.maxfps)
if instance_place(x,y,o_player) {
timergunlogo += 1* (60 / global.maxfps)
}
if timergunlogo > 70 {
image_alpha -= 0.02* (60 / global.maxfps)
if image_alpha < 0 {
instance_destroy()	
}
}