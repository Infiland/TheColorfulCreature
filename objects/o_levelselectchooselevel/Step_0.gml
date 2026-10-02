if (!timing_instance_step()) exit;
var _entry = levelselect_entry(roomselect, levelmusic, level, is_challenge ? challenge_id : -1, level_dir, sequence_index);
locked = levelselect_unlocked(_entry) ? 0 : 1;
// Locks are evaluated from the same policy used by launch.
text = string(level);
lockedtext = text;
