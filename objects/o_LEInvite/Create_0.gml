/// @description Toolbar button: build this level together with friends
// The sprite only gives the button its 50x50 mask; Draw End draws it.
image_alpha = 0
alpha = 1
depth = -11000
hover = 0

ui_draw_alpha = alpha;
timing_ui_register_target("editor-toolbar");
