if global.workshop = 0 {
image_alpha = 0.2
image_speed = 0
depth = 10
if !place_meeting(x,y,o_bluespiral) {
instance_create(x,y,o_bluespiral)
}

mask_index = s_leveleditorhitbox
} else { alarm[0] = 1 }