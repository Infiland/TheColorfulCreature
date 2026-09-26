image_blend = c_white
image_alpha = 1
image_xscale = 5

//Custom hat display
if global.CUSTOMhat != "" {
	if !platform_mobile() {
		if global.CUSTOMhat != custom_hat_name {
			if custom_hat_spr != -1 { sprite_delete(custom_hat_spr) }
			var _dir = directory_set("/Custom/Player Hats/") + global.CUSTOMhat
			if (filename_name(global.CUSTOMhat) == global.CUSTOMhat && file_exists(_dir) && !directory_exists(_dir)) {
				custom_hat_spr = sprite_add(_dir, 1, false, false, 0, 0)
			} else {
				custom_hat_spr = -1
			}
			custom_hat_name = global.CUSTOMhat
		}
		if custom_hat_spr != -1 {
			sprite_index = custom_hat_spr
		}
		exit
	}
}

//No hat
if global.hatselected = 0 { image_alpha = 0; exit }

//Built-in hat from preview data
sprite_index = global.hat_preview_spr[global.hatselected]
image_blend = global.hat_preview_blend[global.hatselected]
image_xscale = global.hat_preview_xscale[global.hatselected]

//Invisible spike hat special case
if global.hatselected = 21 { image_alpha = random_range(0.5,1) }
