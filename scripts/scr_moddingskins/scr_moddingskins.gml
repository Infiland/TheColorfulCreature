function scr_moddingskins(path){
    if (platform_mobile() || !is_string(path) || path == "" || filename_name(path) != path) return;
	skinxscale = 1
	skinyscale = 1
	if os_type != os_gxgames {
		var dir = game_save_id + "//Custom//Player Skins//" + path
		if (file_exists(dir) && !directory_exists(dir)) {
		customskin_spr = sprite_add(dir,9,false,false,0,0)
        if (!sprite_exists(customskin_spr)) return;
		var wid = sprite_get_width(customskin_spr)
		var hig = sprite_get_height(customskin_spr)
        if (wid <= 0 || hig <= 0) { sprite_delete(customskin_spr); return; }
		if global.customskinautoscale = 1 {
		skinxscale = 32 / wid
		skinyscale = 32 / hig
		}
		show_debug_message(customskin_spr)
		customskin = 1
		}
	}
}
