/// @description Build together: invite friends to this level, or see who builds it

// A child of o_leveleditorleaveask so the editor treats it as modal: nothing is
// placed, erased or play-tested underneath. It is never a Y/N confirmation.
timing_confirmation_dialog = false
overlay_alpha = 0
close_requested = false
// The click that opened the panel may still be latched for the next tick.
input_delay = 3

px0 = 212
py0 = 60
px1 = 812
py1 = 708
row_h = 56

builders = []
builders_y = 0
friends_y = 0
list_top = 0
list_bottom = 0
scroll = 0
scroll_target = 0
scroll_max = 0
buttons = []
friends = net_friends_list()
refresh_timer = 90
net_coop_panel_layout()
