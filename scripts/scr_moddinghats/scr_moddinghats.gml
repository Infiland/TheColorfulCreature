function scr_moddinghats(path){
    if (platform_mobile() || !is_string(path) || path == "" || filename_name(path) != path) return;
	hatxscale = 1
	hatyscale = 1
	if os_type != os_gxgames {
		var dir = game_save_id + "//Custom//Player Hats//" + path
		if (file_exists(dir) && !directory_exists(dir)) {
		//show_debug_message("LOL")
		curhat = sprite_add(dir,1,false,false,12,24)
        if (!sprite_exists(curhat)) return;
		var wid = sprite_get_width(curhat)
		var hig = sprite_get_height(curhat)
        if (wid <= 0 || hig <= 0) { sprite_delete(curhat); return; }
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