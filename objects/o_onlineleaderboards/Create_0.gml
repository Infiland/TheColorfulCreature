minselect = -4
maxselect = 22
scroll = 0
userID = noone
avatar_draw_size = 16
avatar_padding = 4
avatar_request_size = steam_user_avatar_size_small
steam_userid = array_create(100, noone)
avatar_sprites = ds_map_create()

steam_image_create_sprite = function(l_img)
{
	var l_dims = steam_image_get_size(l_img);
	if (l_dims == undefined) 
		return -1;
	
	var buff_size = l_dims[0] * l_dims[1] * 4
	var l_cols = buffer_create(buff_size, buffer_fixed, 1);
	var l_sprite, l_ok;
	
	l_ok = steam_image_get_rgba(l_img, l_cols, buff_size);

	if (l_ok) 
	{
		var l_surf = surface_create(l_dims[0], l_dims[1]);
		buffer_set_surface(l_cols, l_surf, 0);
		l_sprite = sprite_create_from_surface(l_surf, 0, 0, l_dims[0], l_dims[1], false, false, 0, 0);
		surface_free(l_surf);
	} 
	else 
		l_sprite = -1;
		
	buffer_delete(l_cols);
	return l_sprite;
}

reloadleaderboards()
