/// @description Free loaded image sprites, data structures, and temp files

// A delegated Back handler must stop before reading these freed maps.
news_images_closing = true
// Pending paths stay owned until their real terminal HTTP callback.
news_images_release(id, news_image_view)

// Delete loaded sprites
var _key = ds_map_find_first(loaded_images)
while (!is_undefined(_key)) {
    var _spr = ds_map_find_value(loaded_images, _key)
    if (sprite_exists(_spr)) {
        sprite_delete(_spr)
    }
    _key = ds_map_find_next(loaded_images, _key)
}
ds_map_destroy(loaded_images)
ds_map_destroy(pending_image_reqs)

// Delete temp image files
for (var _i = 0; _i < array_length(temp_image_files); _i++) {
    if (file_exists(temp_image_files[_i])) {
        file_delete(temp_image_files[_i])
    }
}
