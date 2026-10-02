function scr_loadleveleditor() {
    var _directory = level_editor_directory();
    var _document = level_read(_directory);
    instance_destroy(o_savedandloaded);
    var _notice = instance_create(x, y, o_savedandloaded);
    _notice.image_index = is_undefined(_document) ? 3 : 1;
    if (is_undefined(_document)) return false;
    global.LELevelPreviousWidthBlocks = global.LELevelWidthBlocks;
    global.LELevelPreviousHeightBlocks = global.LELevelHeightBlocks;
    return level_apply(_document, "editor");
}
