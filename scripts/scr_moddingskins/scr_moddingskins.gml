function scr_moddingskins(path){
	skinxscale = 1
	skinyscale = 1
	if os_type != os_gxgames {
		var dir = game_save_id + "//Custom//Player Skins//" + path
		if file_exists(dir) {
		customskin_spr = sprite_add(dir,9,false,false,0,0)
		var wid = sprite_get_width(customskin_spr)
		var hig = sprite_get_height(customskin_spr)
		if global.customskinautoscale = 1 {
		skinxscale = 32 / wid
		skinyscale = 32 / hig
		}
		show_debug_message(customskin_spr)
		customskin = 1
		}
	}
}
