old_gui_width = display_get_gui_width();
old_gui_height = display_get_gui_height();
display_set_gui_size(1024, 768);
art_sprite = -1;
art_owned = false;
catalog = undefined;
chapter_index = 0;
source_index = 0;
show_sources = false;
position_dirty = false;
save_wait = 0;
access_wait = 2;
status_text = "";
has_access = commentary_has_access();

release_art = function() {
    if (art_owned && art_sprite >= 0 && sprite_exists(art_sprite)) sprite_delete(art_sprite);
    art_sprite = -1;
    art_owned = false;
};
set_chapter = function(_index) {
    if (!has_access || is_undefined(catalog)) return;
    _index = clamp(floor(_index), 0, array_length(catalog.chapters) - 1);
    release_art();
    chapter_index = _index;
    source_index = 0;
    show_sources = false;
    var _art = catalog.chapters[chapter_index].art;
    if (_art.kind == "file") {
        art_sprite = sprite_add(level_bundled_path(_art.path), 1, false, false, 0, 0);
        art_owned = art_sprite >= 0;
        if (!art_owned) status_text = "The chapter image could not be loaded.";
    }
    position_dirty = true;
    save_wait = 0.5;
};
leave_gallery = function() {
    if (position_dirty && !is_undefined(catalog)) {
        if (commentary_position_write(catalog, chapter_index)) position_dirty = false;
    }
    window_set_cursor(cr_default);
    room_goto(r_support);
};
if (has_access) {
    catalog = commentary_read();
    if (is_undefined(catalog)) {
        status_text = "The commentary files could not be loaded.";
    } else {
        set_chapter(commentary_position_read(catalog));
        position_dirty = false;
    }
}
