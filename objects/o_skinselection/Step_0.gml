if (!timing_instance_step()) exit;
image_blend = c_white
anim += 0.5 * (60 / global.maxfps)

sprite_index = global.skin_preview_spr[global.skinselected]
image_blend = global.skin_preview_blend[global.skinselected]
scr_moddingskins(global.CUSTOMskin);
cosmetics_item_init(global.CUSTOMitem);
