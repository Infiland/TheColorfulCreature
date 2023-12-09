if instance_exists(o_player) {
if (o_player.bbox_bottom) > y {
mask_index = -1;
}
else {mask_index = s_onewayupblock }
}

if global.pause = 1 { image_speed = 0 }
if global.pause = 0 { image_speed = 1 * (60 / global.maxfps) }

if instance_exists(o_deleteblock) {
mask_index = s_onewayupblock	
}