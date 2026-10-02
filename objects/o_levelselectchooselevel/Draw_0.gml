var _focused = false;
if (instance_exists(o_levelselectcontroller)) _focused = o_levelselectcontroller.keyboard_focus && o_levelselectcontroller.selected_level == catalog_index;
var _hover = point_in_rectangle(mouse_x, mouse_y, x, y, x + 85, y + 85);
draw_set_alpha(1);
draw_set_color((_focused || _hover) && locked == 0 ? make_color_rgb(35,38,48) : c_black);
draw_rectangle(x, y, x + 85, y + 85, false);
draw_set_color(locked ? make_color_rgb(75,78,85) : (_focused ? c_yellow : c_white));
draw_rectangle(x, y, x + 85, y + 85, true);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_mainmenu);
draw_text_transformed(x + 42.5, y + (locked ? 34 : 42.5), string(level), 0.85, 0.85, 0);
if (locked) {
    draw_set_font(fnt_death);
    draw_text_transformed(x + 42.5, y + 65, "Locked", 0.75, 0.75, 0);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
