function scr_saveleveleditor() {
    var _directory = level_editor_directory();
    return level_write(_directory, level_capture());
}
