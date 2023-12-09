//SPAWNED BY o_fullscreensystem

randomize();
var sw = choose(0,1)
previousspeed = speed
distance = 0

//Define Direction Angle
if room = r_leveleditor { 
direction = global.LEStarRotation	
} else {
if instance_exists(o_customstarbackground) {
direction = o_customstarbackground.customdirection
} else {
direction = 0
}}

//Going Left
if direction = 0 || direction = 360 {
if instance_exists(o_smoothcamera) {
x = o_smoothcamera.x + 1024
y = random_range(o_smoothcamera.y + 384,o_smoothcamera.y - 384);
} else {
x = room_width
y = random_range(0,room_height);
}}

//Going Between Left and Down
if direction < 90 and direction > 0 {
if instance_exists(o_smoothcamera) {
if sw = 0 {
x = o_smoothcamera.x + 1024
y = random_range(o_smoothcamera.y + 384,o_smoothcamera.y - 384);
} else {
y = o_smoothcamera.y
x = random_range(o_smoothcamera.x + 512,o_smoothcamera.x - 512);
}
} else {
if sw = 0 {
x = room_width
y = random_range(0,room_height);
} else {
y = 0
x = random_range(0,room_width);
}}}

//Going Down
if direction = 90 {
if instance_exists(o_smoothcamera) { 
y = o_smoothcamera.y
x = random_range(o_smoothcamera.x + 512,o_smoothcamera.x - 512);
} else {
y = 0
x = random_range(0,room_width);
}}

//Going Between Down and Right
if direction < 180 and direction > 90 {
if instance_exists(o_smoothcamera) {
if sw = 0 {
x = o_smoothcamera.x
y = random_range(o_smoothcamera.y + 384,o_smoothcamera.y - 384);
} else {
y = o_smoothcamera.y
x = random_range(o_smoothcamera.x + 512,o_smoothcamera.x - 512);
}
} else {
if sw = 0 {
x = 0
y = random_range(0,room_height);
} else {
y = 0
x = random_range(0,room_width);
}}}

//Going Right
if direction = 180 {
if instance_exists(o_smoothcamera) {
x = o_smoothcamera.x
y = random_range(o_smoothcamera.y + 384,o_smoothcamera.y - 384);
} else {
x = 0
y = random_range(0,room_height);
}}

//Going Between Right and Up
if direction < 270 and direction > 180 {
if instance_exists(o_smoothcamera) {
if sw = 0 {
x = o_smoothcamera.x
y = random_range(o_smoothcamera.y + 384,o_smoothcamera.y - 384);
} else {
y = o_smoothcamera.y + 768
x = random_range(o_smoothcamera.x + 512,o_smoothcamera.x - 512);
}
} else {
if sw = 0 {
x = 0
y = random_range(0,room_height);
} else {
y = room_height
x = random_range(0,room_width);
}}}

//Going Up
if direction = 270 {
if instance_exists(o_smoothcamera) { 
y = o_smoothcamera.y + 768
x = random_range(o_smoothcamera.x + 512,o_smoothcamera.x - 512);
} else {
y = room_height
x = random_range(0,room_width);
}}

//Going Between Up and Left
if direction < 360 and direction > 270 {
if instance_exists(o_smoothcamera) {
if sw = 0 {
x = o_smoothcamera.x + 1024
y = random_range(o_smoothcamera.y + 384,o_smoothcamera.y - 384);
} else {
y = o_smoothcamera.y + 768
x = random_range(o_smoothcamera.x + 512,o_smoothcamera.x - 512);
}
} else {
if sw = 0 {
x = 1024
y = random_range(0,room_height);
} else {
y = room_height
x = random_range(0,room_width);
}}}



speed = -1

if global.stars = 1 {zdepth = 1} else if global.stars = 2 {
zdepth = random_range(1,5)
image_xscale = 1 / zdepth
image_yscale = 1 / zdepth
image_alpha = 1 / zdepth
}

depth = 50 * (zdepth / 2)

image_angle = random_range(0,360)
if room = r_credits { instance_destroy() }