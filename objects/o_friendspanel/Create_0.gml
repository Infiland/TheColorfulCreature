/// @description Friends panel: Steam friends playing the game and our online session

// A child of o_progressask so every main menu button treats it as modal. It is
// never a Y/N confirmation, so the shared confirmation tick must skip it.
timing_confirmation_dialog = false
overlay_alpha = 0
close_requested = false
// The click that opened the panel may still be latched for the next tick.
input_delay = 3

px0 = 240
py0 = 40
px1 = 984
py1 = 728
row_h = 56

session_y = 0
members_y = 0
friends_y = 0
list_top = 0
list_bottom = 0
scroll = 0
scroll_target = 0
scroll_max = 0
buttons = []
friends = net_friends_list()
refresh_timer = 90
net_friends_panel_layout()
