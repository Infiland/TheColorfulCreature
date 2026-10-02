function LEVELEDITORSETUP(_restart = 0) {
    if (_restart == 1) {
        if (!scr_saveleveleditor()) {
            global.LEsetup_error = variable_global_exists("level_last_error") ? global.level_last_error : "The level could not be saved.";
            return false;
        }
        global.LEsetup_error = "";
        room_set_height(r_leveleditor, 64 + 32 * global.LELevelHeightBlocks);
        room_set_width(r_leveleditor, 32 * global.LELevelWidthBlocks);
        room_restart();
        LEVELEDITORSETUP(0);
        show_debug_message("Level Editor Setup Restart");
    } else {
        show_debug_message("Level Editor Setup Ready");
        instance_create(x, y, o_spawnthing);
        instance_destroy();
    }
    return true;
}
