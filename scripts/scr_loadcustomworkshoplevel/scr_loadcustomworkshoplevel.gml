function scr_loadcustomlevelworkshop() {
    // The nonpersistent loader may first schedule this room from a menu. Let
    // the room's own loader apply the document; never mutate another live room.
    if (room != r_customlevelworkshop) return false;
    var _directory = level_directory(directory_set(global.workshopfolder, 1));
    var _document = level_read(_directory);
    if (is_undefined(_document)) {
        level_load_failure();
        return false;
    }
    global.workshopfolder = _directory;
    var _start_music = (global.workshop == 0) || !variable_global_exists("level_music_directory") || global.level_music_directory != _directory;
    global.workshop = 1;
    global.LEMode = 2;
    var _loaded = level_apply(_document, "workshop");
    if (!_loaded) {
        level_load_failure();
        return false;
    }
    if (_loaded && _start_music) scr_leveleditormusic(_directory);
    return _loaded;
}

// Historical resource/script spelling remains available to existing callers.
function scr_loadcustomworkshoplevel() {
    return scr_loadcustomlevelworkshop();
}
