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
draw_set_halign(fa_left)
draw_set_valign(fa_top)
}

function mobile_confirmation_init() {
    // Desktop and touch dialogs share one logical-tick action owner.
    timing_confirmation_dialog = true;
    timing_confirmation_last_tick = -1;
    timing_confirmation_pending = 0;
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
        // Capture only. The end-of-tick helper owns the dialog action.
        if (_choice != 0) {
            mobile_confirmation_submit(_choice);
            return;
        }
    }
    // Modal input must not reach the menu underneath the dialog.
    mouse_clear(mb_any);
}

function mobile_confirmation_submit(_choice) {
    if (_choice != ord("Y") && _choice != ord("N")) return;
    if (timing_confirmation_pending == 0) timing_confirmation_pending = _choice;
    platform_clear_input();
}

function confirmation_tick_update() {
    if (!timing_is_tick() || !timing_confirmation_dialog) return;
    var _tick = timing_tick_id();
    if (timing_confirmation_last_tick == _tick) return;
    timing_confirmation_last_tick = _tick;
    var _choice = timing_confirmation_pending;
    timing_confirmation_pending = 0;
    var _pad_ready;
    if (platform_touch()) {
        _pad_ready = confirmation_ready;
    } else {
        y = lerp(y, 384, 0.2);
        _pad_ready = delay < 0;
        if (!_pad_ready) delay -= 1;
    }
    // Keyboard confirmation was immediate; the controller keeps its original
    // opening delay. A queued touch release survives render-only frames.
    if (_choice == 0) {
        if (timing_keyboard_pressed(ord("Y"))) _choice = ord("Y");
        else if (timing_keyboard_pressed(ord("N"))) _choice = ord("N");
        else if (_pad_ready && gamepad_ui_pressed(gp_face1)) _choice = ord("Y");
        else if (_pad_ready && gamepad_ui_pressed(gp_face2)) _choice = ord("N");
    }
    if (_choice != 0) timing_confirmation_dispatch(_choice);
}

function timing_confirmation_dispatch(_choice) {
    if (!timing_is_tick() || (_choice != ord("Y") && _choice != ord("N"))) return;
    platform_clear_input();
    // Native KeyPress events are guarded. Only this tick dispatch can invoke
    // their existing callbacks, including callbacks which destroy the dialog.
    global.timing_confirmation_dispatch_active = true;
    try {
        event_perform(ev_keypress, _choice);
    } catch (_error) {
        global.timing_confirmation_dispatch_active = false;
        throw _error;
    }
    global.timing_confirmation_dispatch_active = false;
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
