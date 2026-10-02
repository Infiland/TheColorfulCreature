if (!timing_instance_step()) exit;
mask_index = s_onewayupblock;

if global.pause = 1 { image_speed = 0 }
if global.pause = 0 { image_speed = 1 * (60 / TCC_SIM_HZ) }

if instance_exists(o_deleteblock) {
mask_index = s_onewayupblock	
}