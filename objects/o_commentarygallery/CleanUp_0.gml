if (position_dirty && !is_undefined(catalog)) commentary_position_write(catalog, chapter_index);
release_art();
display_set_gui_size(old_gui_width, old_gui_height);
