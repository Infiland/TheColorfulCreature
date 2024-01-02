if instance_exists(o_player) {
if distance_to_object(o_player) > 100 {
image_alpha = 0	
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
image_alpha = 0	
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
}}

if global.visiblethings = 1 { image_alpha = 1 }