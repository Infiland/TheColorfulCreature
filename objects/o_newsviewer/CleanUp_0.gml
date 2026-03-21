/// @description Free loaded image sprites and data structures

var _key = ds_map_find_first(loaded_images)
while (!is_undefined(_key)) {
    var _spr = ds_map_find_value(loaded_images, _key)
    if (sprite_exists(_spr)) {
        sprite_delete(_spr)
    }
    _key = ds_map_find_next(loaded_images, _key)
}
ds_map_destroy(loaded_images)
ds_map_destroy(pending_images)
