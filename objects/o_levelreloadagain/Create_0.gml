var _directory = level_editor_directory();
pending_document = level_read(_directory);
if (is_undefined(pending_document)) {
    instance_destroy(o_savedandloaded);
    var _notice = instance_create(x, y, o_savedandloaded);
    _notice.image_index = 3;
    instance_destroy();
    exit;
}
// This instance is persistent: retain the validated document through room_restart.
room_set_width(r_leveleditor, pending_document.metadata.widthBlocks * 32);
room_set_height(r_leveleditor, 64 + pending_document.metadata.heightBlocks * 32);
room_restart();
alarm[0] = 1;
