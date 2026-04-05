/// @description Clean up resources

// Free loaded thumbnail sprites
for (var i = 0; i < levels_count; i++) {
	if levels[i].thumb_spr != -1 {
		sprite_delete(levels[i].thumb_spr)
	}
}

for (var i = 0; i < browse_count; i++) {
	if browse_levels[i].thumb_spr != -1 {
		sprite_delete(browse_levels[i].thumb_spr)
	}
}

// Destroy async tracking maps
ds_map_destroy(async_details)
ds_map_destroy(async_names)
