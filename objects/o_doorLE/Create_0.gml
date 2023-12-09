depth = 10
image_speed = 0.5;
if room = r_boss1 {
if !global.boss1 = 1 {
instance_destroy()
}
}
if room = r_boss2 {
if !global.boss2 = 1 {
instance_destroy()
}
}