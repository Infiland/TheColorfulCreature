fall += 0.5
randomize()
image_alpha -= 0.05
y -= 7 - fall
if image_alpha < 0 {
instance_destroy();

if instance_exists(o_smoothcamera) {
o_smoothcamera.x = x
o_smoothcamera.y = y
}

}
x = x + gotheredead
if image_index = 5 { image_speed = 0 }