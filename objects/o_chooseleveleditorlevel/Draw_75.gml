draw_set_alpha(0.9);
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_set_font(global.deathfont);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
var _xcam = camera_get_view_x(view_camera[0]) + 512;
if (len == 0) draw_text(_xcam, 350, "No saved levels in this profile.\nSave a level first, or copy a level folder into LevelEditor Files.");
for (var _row = 0; _row < 15; ++_row) {
    var _index = (page - 1) * 15 + _row;
    if (_index >= len) break;
    var _top = 85 + _row * 40;
    var _hover = point_in_rectangle(mouse_x, mouse_y, _xcam - 300, _top, _xcam + 300, _top + 30);
    var _color = (_hover || selection == _index) ? c_yellow : c_white;
    if (variable_global_exists("level_editor_folder") && files[_index] == global.level_editor_folder) _color = c_lime;
    draw_set_color(_color);
    draw_rectangle(_xcam - 300, _top, _xcam + 300, _top + 30, true);
    draw_text(_xcam, _top + 2, files[_index]);
}
draw_set_color(c_white);
draw_text(_xcam, 700, "Left / Right or LB / RB: pages   Up / Down: choose   Enter / A: load   Esc / B: close");
draw_text(_xcam, 722, "Page " + string(page) + " / " + string(maxpage));
if (error_text != "") { draw_set_color(c_red); draw_text_ext(_xcam, 658, error_text, 18, 850); }
draw_set_color(c_white);
draw_set_halign(fa_left);
