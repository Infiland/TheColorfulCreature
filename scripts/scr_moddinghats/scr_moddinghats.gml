function scr_moddinghats(path){
	hatxscale = 1
	hatyscale = 1
	if os_type != os_gxgames {
		var dir = game_save_id + "//Custom//Player Hats//" + path
		if file_exists(dir) {
		//show_debug_message("LOL")
		curhat = sprite_add(dir,1,false,false,12,24)
		var wid = sprite_get_width(curhat)
		var hig = sprite_get_height(curhat)
		sprite_set_offset(curhat,wid/2,hig)
		if global.customhatautoscale = 1 {
		hatxscale = 32 / wid
		hatyscale = 32 / hig
		}
		show_debug_message(curhat)
		customhat = 1
		}
	}
}