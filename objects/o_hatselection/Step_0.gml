if (!timing_instance_step()) exit;
image_blend = c_white
image_alpha = 1
image_xscale = 5

// Invalid/missing imports leave the existing built-in selection visible.
scr_moddinghats(global.CUSTOMhat);
if (customhat == 1) { image_alpha = 1; exit; }
image_yscale = 5;

//No hat
if global.hatselected = 0 { image_alpha = 0; exit }

//Built-in hat from preview data
sprite_index = global.hat_preview_spr[global.hatselected]
image_blend = global.hat_preview_blend[global.hatselected]
image_xscale = global.hat_preview_xscale[global.hatselected]

//Invisible spike hat special case
if global.hatselected = 21 { image_alpha = random_range(0.5,1) }
