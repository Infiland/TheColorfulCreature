mask_index = s_onewayupblock;

if global.pause = 1 { image_speed = 0 }
if global.pause = 0 { image_speed = 1 * (60 / global.maxfps) }

if instance_exists(o_deleteblock) {
mask_index = s_onewayupblock	
}