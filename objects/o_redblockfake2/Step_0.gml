if global.visual3dsettings = 1 {
hdepth = (obj_to_follow.x-x)/factor;
vdepth = (obj_to_follow.y-y)/factor;

if (hdepth > max_depth/2) {

    hdepth=max_depth/2;

}

if (hdepth < -max_depth/2) {

    hdepth=-max_depth/2;

}

if (vdepth > max_depth/2) {

    vdepth=max_depth/2;

}

if (vdepth < -max_depth/2) {

    vdepth=-max_depth/2;

}
}

if global.level100trap = 1 {
if fake = 0 {
if x > 704 {
x -= 5
}
if x < 704 {
x = 704	
}
}
if fake = 1 {
if x < 512 {
x += 10
}
if x > 512 {
x = 512	
}
}
}