texty = 40
text = loc("ADJUST_OPTIONS");
set_rich_presence()

// Destroy old room-placed settings objects and spawn new data-driven ones
instance_destroy(o_allsettings)
instance_create(x, y, o_info)
scr_spawn_settings_buttons()
