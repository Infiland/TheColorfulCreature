// Touch contacts are handled once in the catalog controller.
if (platform_touch()) exit;
if (locked != 0) exit;
var _entry = levelselect_entry(roomselect, levelmusic, level, is_challenge ? challenge_id : -1, level_dir, sequence_index);
levelselect_start(_entry);
