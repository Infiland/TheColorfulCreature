if global.workshop = 0 {
image_alpha = 0.2
image_speed = 0
depth = 10
if !place_meeting(x,y,o_speed10) {
instance_create(x,y,o_speed10)
}

if global.oldGSsettings = 1 {sprite_index = s_speed10_o}
mask_index = s_leveleditorhitbox
} else { alarm[0] = 1 }