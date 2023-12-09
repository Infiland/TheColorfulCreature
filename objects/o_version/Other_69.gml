/*
var l_img = steam_get_user_avatar(steam_get_user_steam_id(),
steam_user_avatar_size_medium);
// Check if avatar is ready
if (l_img > 0)
{
var l_dims = steam_image_get_size(l_img);
var buff_size = l_dims[0] * l_dims[1] * 4
var l_cols = buffer_create(buff_size, buffer_fixed, 1);
l_ok = steam_image_get_rgba(l_img, l_cols, buff_size);
if(!l_ok)
{
buffer_delete(l_cols);
}
var l_surf = surface_create(l_dims[0], l_dims[1]);
buffer_set_surface(l_cols, l_surf, 0);
l_sprite = sprite_create_from_surface(l_surf, 945, 420, l_dims[0], l_dims[1], false,
false, 0, 0);
surface_free(l_surf);
buffer_delete(l_cols);
}