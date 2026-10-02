function LoadJSONFromFile(_filename) {
    // Preserve the DS-map adapter used by older callers, while sharing the safe
    // terminated/rewound UTF-8 reader with ordinary JSON and legacy NUL files.
    var _document = level_parse_json_file(_filename);
    if (is_undefined(_document)) return undefined;
    try {
        var _map = json_decode(json_stringify(_document));
        if ((is_real(_map) || is_handle(_map)) && ds_exists(_map, ds_type_map)) return _map;
    } catch (_error) {
        show_debug_message("Could not decode " + _filename + ": " + string(_error));
    }
    return undefined;
}
