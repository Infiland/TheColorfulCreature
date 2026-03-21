/// @description Handle async image loaded

var _sprite = async_load[? "id"]
var _status = async_load[? "status"]

if (ds_map_exists(pending_images, _sprite)) {
    var _url = ds_map_find_value(pending_images, _sprite)
    ds_map_delete(pending_images, _sprite)

    if (_status >= 0 && sprite_exists(_sprite)) {
        ds_map_add(loaded_images, _url, _sprite)
        needs_recalc = true
    }
}

loading_image = false
