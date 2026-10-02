if (!timing_instance_step()) exit;
if instance_exists(o_player) {
if (o_player.bbox_top) < y {
mask_index = -1;
}
else {mask_index = s_onewaydownblock }
}

if global.pause = 1 { image_speed = 0 }
if global.pause = 0 { image_speed = 1 * (60 / TCC_SIM_HZ) }

if instance_exists(o_deleteblock) {
mask_index = s_onewayupblock	
}