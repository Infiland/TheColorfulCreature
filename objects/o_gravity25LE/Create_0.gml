if global.workshop = 0 {
image_alpha = 0.2
image_speed = 0
depth = 10
if !place_meeting(x,y,o_gravity25) {
instance_create(x,y,o_gravity25)
}

mask_index = s_leveleditorhitbox
if global.oldGSsettings = 1 {sprite_index = s_gravity25_o}
} else { alarm[0] = 1 }