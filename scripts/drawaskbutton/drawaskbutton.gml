function drawaskbutton(){

if (platform_touch()) {
    draw_mobile_confirmation();
    return;
}

draw_set_alpha(0.5)
draw_rectangle_color(0,0,2000,2000,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)

draw_rectangle_color(200,y,824,y+50,c_black,c_black,c_black,c_black,false)
draw_rectangle(200,y,824,y+50,true)

draw_set_font(global.deathfont)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text_scribble_ext(512,y+25,text,1000)
y = lerp(y,384,0.2 * (60 / global.maxfps))
draw_set_halign(fa_left)
draw_set_valign(fa_top)

if delay < 0 {
if tcc_gamepad_button_check_pressed(0,gp_face1) {
event_perform(ev_keypress,ord("Y"))
}
if tcc_gamepad_button_check_pressed(0,gp_face2) {
event_perform(ev_keypress,ord("N"))
}} else {
delay -= 1
}

}

function mobile_confirmation_init() {
    if (!platform_touch()) return;
    global.mobile_confirmation = id;
    confirmation_ready = false;
    confirmation_touch = -1;
    confirmation_choice = 0;
    platform_clear_input();
}

// 288 x 96 GUI targets, with a 64-pixel gap between the two actions.
function mobile_confirmation_hit(_x, _y) {
    if (point_in_rectangle(_x, _y, 192, 424, 480, 520)) return ord("N");
    if (point_in_rectangle(_x, _y, 544, 424, 832, 520)) return ord("Y");
    return 0;
}

function mobile_confirmation_step() {
    var _held = false;
    for (var _i = 0; _i < 6; ++_i) {
        if (!device_mouse_check_button(_i, mb_left)) continue;
        _held = true;
        if (confirmation_ready && confirmation_touch == -1) {
            confirmation_touch = _i;
            confirmation_choice = mobile_confirmation_hit(device_mouse_x_to_gui(_i), device_mouse_y_to_gui(_i));
        }
    }
    if (!_held) confirmation_ready = true;
    if (confirmation_touch != -1 && !device_mouse_check_button(confirmation_touch, mb_left)) {
        var _choice = confirmation_choice;
        if (mobile_confirmation_hit(device_mouse_x_to_gui(confirmation_touch), device_mouse_y_to_gui(confirmation_touch)) != _choice) _choice = 0;
        confirmation_touch = -1;
        confirmation_choice = 0;
        // Dispatch the dialog's own action, after consuming the touch.
        if (_choice != 0) {
            mobile_confirmation_submit(_choice);
            return;
        }
    }
    // Modal input must not reach the menu underneath the dialog.
    mouse_clear(mb_any);
    if (confirmation_ready) {
        if (tcc_gamepad_button_check_pressed(0, gp_face1)) mobile_confirmation_submit(ord("Y"));
        else if (tcc_gamepad_button_check_pressed(0, gp_face2)) mobile_confirmation_submit(ord("N"));
    }
}

function mobile_confirmation_submit(_choice) {
    if (_choice != ord("Y") && _choice != ord("N")) return;
    platform_clear_input();
    event_perform(ev_keypress, _choice);
}

function draw_mobile_confirmation() {
    draw_set_alpha(0.75);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 1024, 768, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(24, 24, 32));
    draw_rectangle(160, 240, 864, 552, false);
    draw_set_color(c_white);
    draw_rectangle(160, 240, 864, 552, true);
    draw_set_font(fnt_mainmenu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _text = string_replace_all(text, " (Y/N)", "");
    _text = string_replace_all(_text, " [s_xboxcontrollerscheme,5] / [s_xboxcontrollerscheme,7]", "");
    draw_text_scribble_ext(512, 328, _text, 624);
    for (var _i = 0; _i < 2; ++_i) {
        var _left = 192 + _i * 352;
        var _choice = _i == 0 ? ord("N") : ord("Y");
        draw_set_color(confirmation_choice == _choice ? make_color_rgb(72, 72, 88) : make_color_rgb(40, 40, 52));
        draw_rectangle(_left, 424, _left + 288, 520, false);
        draw_set_color(c_white);
        draw_rectangle(_left, 424, _left + 288, 520, true);
        draw_text_scribble_ext(_left + 144, 472, loc(_i == 0 ? "CONFIRM_NO" : "CONFIRM_YES"), 264);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
