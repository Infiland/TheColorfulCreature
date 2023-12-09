function scr_renderblocks(){

if room != r_leveleditor {
if hidesprites = true {
if distance_to_object(o_player)	< 1100 {
hidesprites = false 	
}}} else {
if global.LEMode = 1 {
hidesprites = false
} else {
if hidesprites = true {
if distance_to_object(o_player)	< 1100 {
hidesprites = false 
}}}
}
	
	if hidesprites = true { exit }
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

}