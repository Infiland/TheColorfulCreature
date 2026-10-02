// Keep the legacy INI format. Copy verification is byte-for-byte via buffer hashes.
function scr_files_equal(_a, _b) {
    if (!file_exists(_a) || !file_exists(_b)) return false;
    var _left = buffer_load(_a);
    var _right = buffer_load(_b);
    var _equal = false;
    if (_left >= 0 && _right >= 0) {
        var _size = buffer_get_size(_left);
        _equal = _size == buffer_get_size(_right)
            && buffer_sha1(_left, 0, _size) == buffer_sha1(_right, 0, _size);
    }
    if (_left >= 0) buffer_delete(_left);
    if (_right >= 0) buffer_delete(_right);
    return _equal;
}

function scr_migrate_saves(_directory, _source_directory = "") {
    if (!directory_exists(_directory)) directory_create(_directory);
    if (qa_active() && _source_directory == "") return;
    var _names = ["Achievements", "Stats", "Skins", "Settings", "Hats", "Items", "Hardmode",
        "Endless", "SaveFile", "ChallengeTime", "ChallengeDeaths", "Calendar"];
    for (var _i = 0; _i < array_length(_names); ++_i) {
        var _source = _source_directory + _names[_i] + ".sav";
        var _target = _directory + _names[_i] + ".sav";
        if (!file_exists(_source) || file_exists(_target)) continue;
        file_copy(_source, _target);
        if (!scr_files_equal(_source, _target)) {
            if (file_exists(_target)) file_delete(_target);
            show_debug_message("Save migration failed: " + _source);
        }
        // The original is the migration backup; never delete it.
    }
}

function scr_save_begin(_path) {
    var _pending = _path + ".pending";
    if (file_exists(_pending)) file_delete(_pending);
    ini_open(_pending);
}

function scr_save_finish(_path) {
    ini_close();
    var _pending = _path + ".pending";
    var _backup = _path + ".bak";
    if (!file_exists(_pending)) return false;
    if (file_exists(_path)) {
        if (file_exists(_backup)) file_delete(_backup);
        file_copy(_path, _backup);
        if (!scr_files_equal(_path, _backup)) return false;
        file_delete(_path);
    }
    file_rename(_pending, _path);
    if (file_exists(_path)) return true;
    if (file_exists(_backup)) file_copy(_backup, _path);
    return false;
}

function scr_save_recover(_path) {
    if (!file_exists(_path) && file_exists(_path + ".bak")) file_copy(_path + ".bak", _path);
}

function scr_saved_room(_name) {
    if (!is_string(_name)) return -1;
    var _asset = asset_get_index(_name);
    if (_asset == -1 || asset_get_type(_asset) != asset_room) return -1;
    // Campaign rooms only. A valid editor, challenge or menu room is not a campaign save.
    if (string_pos("r_lvl", _name) != 1 && string_pos("r_boss", _name) != 1
        && _name != "r_hatmerchantroom") return -1;
    return _asset;
}

function scr_save_number(_section, _key, _default = 0) {
    var _value = ini_read_real(_section, _key, _default);
    if (!is_real(_value) || is_nan(_value) || is_infinity(_value) || _value < 0) return _default;
    return _value;
}
