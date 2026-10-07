if (platform_mobile()) {
    var _mobile_labels = ["MOVE_RIGHT", "MOVE_LEFT", "JUMP", "INTERACT", "SKIP_LEVEL", "RESTART"];
    var _mobile_device = gamepad_remap_active_device();
    var _binding = ischanging ? "..." : (_mobile_device >= 0 ? gamepad_button_display_name(gamepad_remap_get(controls)) : settings_keyboard_display(controlschoose));
    settings_mobile_draw_card(settings_text(_mobile_labels[controls]), _binding);
    exit;
}
draw_self();
draw_set_color(ischanging ? c_yellow : c_white);
draw_set_font(global.coolfont);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
var _labels = ["MOVE_RIGHT", "MOVE_LEFT", "JUMP", "INTERACT", "SKIP_LEVEL", "RESTART"];
draw_text(x, y + 50, settings_text(_labels[controls]));
draw_set_font(global.deathfont);
draw_set_halign(fa_center);
if (ischanging) {
    draw_text(x + 60, y + 12, "...");
    draw_set_halign(fa_left);
    draw_text(camera_get_view_x(view_camera[0]) + 32, camera_get_view_y(view_camera[0]) + 716,
        settings_text(capture_hint == "" ? "Press a key or controller button. Esc cancels." : capture_hint));
} else {
    var _device = gamepad_remap_active_device();
    if (_device >= 0) {
        draw_text_transformed(x + 60, y + 2, settings_keyboard_display(controlschoose), 0.85, 0.85, 0);
        draw_set_color(c_aqua);
        draw_text_transformed(x + 60, y + 26, "Pad " + string(_device + 1) + ": " + gamepad_button_display_name(gamepad_remap_get(controls)), 0.85, 0.85, 0);
        if (controls == 0 && global.choosesettings == 3 && !gamepad_remap_capture_active()) {
            draw_set_halign(fa_left);
            draw_text(camera_get_view_x(view_camera[0]) + 32, camera_get_view_y(view_camera[0]) + 716,
                string_replace_all(loc("CONTROLLER_PAUSE_BUTTON"), "{BUTTON}", gamepad_button_display_name(gamepad_remap_pause_button())));
        }
    } else draw_text(x + 60, y + 12, settings_keyboard_display(controlschoose));
}
draw_set_color(c_white);
draw_set_halign(fa_left);
