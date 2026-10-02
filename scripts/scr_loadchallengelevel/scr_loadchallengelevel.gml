function scr_loadchallengelevel(_directory = "") {
    if (_directory == "" && variable_global_exists("challenge_level_dir")) _directory = global.challenge_level_dir;
    if (_directory == "") _directory = "Lunar Base Challenge/1";
    _directory = string_replace_all(_directory, "\\", "/");
    if (string_pos(":", _directory) == 0 && string_copy(_directory, 1, 1) != "/") {
        var _base = variable_global_exists("challenge_base_dir") ? global.challenge_base_dir : "";
        if (_base == "") _base = scr_challenge_get_base_dir();
        _directory = level_directory(_base) + _directory;
    }
    var _document = level_read(_directory);
    if (is_undefined(_document)) {
        level_load_failure();
        return false;
    }
    global.LEMode = 2;
    return level_apply(_document, "challenge");
}
