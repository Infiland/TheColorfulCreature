if !instance_exists(o_bigwheel) {
instance_create(512,1056,o_bigwheel)
}

if global.wheeltimeleft > 0 {
if !instance_exists(o_wheelpaycooldown) {
instance_create(32,224,o_wheelpaycooldown)
}
}