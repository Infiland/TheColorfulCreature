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

if instance_exists(o_player) {
if distance_to_object(o_player) > 100 {
hidesprites = true
}
if distance_to_object(o_player) < 100 {
image_alpha = 0.1	
}
if distance_to_object(o_player) < 80 {
image_alpha = 0.2	
}
if distance_to_object(o_player) < 60 {
image_alpha = 0.3	
}
if distance_to_object(o_player) < 50 {
image_alpha = 0.4	
}
if distance_to_object(o_player) < 40 {
image_alpha = 0.5	
}}
if instance_exists(o_playerdead) {
if distance_to_object(o_playerdead) > 100 {
hidesprites = true
}
if distance_to_object(o_playerdead) < 100 {
image_alpha = 0.1	
}
if distance_to_object(o_playerdead) < 80 {
image_alpha = 0.2	
}
if distance_to_object(o_playerdead) < 60 {
image_alpha = 0.3	
}
if distance_to_object(o_playerdead) < 50 {
image_alpha = 0.4	
}
if distance_to_object(o_playerdead) < 40 {
image_alpha = 0.5	
}}

if room = r_leveleditor {
if global.LEMode = 1 {
image_alpha = 0.5
hidesprites = false
} else {
if hidesprites = true {
if distance_to_object(o_player)	< 100 {
hidesprites = false 	
}}

}
} else {

if hidesprites = true {
if distance_to_object(o_player)	< 100 {
hidesprites = false 	
}}

}

if global.visiblethings = 1 { image_alpha = 1 hidesprites = false}