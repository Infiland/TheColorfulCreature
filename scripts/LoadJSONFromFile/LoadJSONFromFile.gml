function LoadJSONFromFile(_filename) {
    if (!is_string(_filename) || !file_exists(_filename)) return undefined;
    var _buffer = buffer_load(_filename);
    if (_buffer < 0) return undefined;
    var _json = undefined;
    try {
        var _string = buffer_read(_buffer, buffer_string);
        _json = json_decode(_string);
        if (!(is_real(_json) || is_handle(_json)) || !ds_exists(_json, ds_type_map)) _json = undefined;
    } catch (_error) {
        show_debug_message("Could not read " + _filename + ": " + string(_error));
    }
    buffer_delete(_buffer);
    return _json;
}
