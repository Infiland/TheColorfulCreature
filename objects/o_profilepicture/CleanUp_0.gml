if os_type = os_android || os_type = os_gxgames { exit }
if (sprite_exists(avatar_sprite)) 
{
	sprite_delete(avatar_sprite);
	avatar_sprite = -1;
}