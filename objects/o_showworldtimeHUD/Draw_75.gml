draw_set_font(global.deathfont)
draw_set_color(c_yellow)

var _draw_clock = variable_global_exists("tcc_timing");
var _new_draw = true;
if (_draw_clock) _new_draw = hud_last_draw_frame != global.tcc_timing.drawn_frames;
var _seconds = _draw_clock ? global.tcc_timing.draw_seconds : 1 / TCC_SIM_HZ;
if (_new_draw) {
    if (_draw_clock) hud_last_draw_frame = global.tcc_timing.drawn_frames;
    y = lerp(y,696,timing_ui_draw_lerp_weight(0.1));
    hud_draw_alpha = image_alpha;
}
draw_text_color(room_width-room_width+80+string_width(global.time),y,string_hash_to_newline(string_format(text,1,2 - global.decimalsettings)),c_yellow,c_orange,c_yellow,c_orange,hud_draw_alpha)
draw_set_color(c_white)

// Fade follows the displayed sample, retaining the old 60 Hz order.
if (_new_draw) {
    if y < 697 {
        image_alpha -= 0.01 * TCC_SIM_HZ * _seconds;
    }
    if image_alpha < 0 { instance_destroy() }
}