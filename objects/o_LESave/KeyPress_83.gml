// Only the level's creator saves, loads and publishes a level built together.
if (net_coop_is_guest()) exit;
event_perform(ev_mouse,ev_left_press)