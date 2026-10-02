// Repeated view callbacks share this generated Draw's visual phase.
var _draw_clock = variable_global_exists("tcc_timing");
var _new_draw = true;
if (_draw_clock) _new_draw = wave_last_draw_frame != global.tcc_timing.drawn_frames;
if (_new_draw) {
    if (_draw_clock) wave_last_draw_frame = global.tcc_timing.drawn_frames;
    var _seconds = _draw_clock ? global.tcc_timing.draw_seconds : 1 / TCC_SIM_HZ;
    var_time_var += 0.04 * TCC_SIM_HZ * _seconds;
}

var_mouse_pos_x = mouse_x - camera_get_view_x(0);
var_mouse_pos_y = mouse_y - camera_get_view_y(0);
if global.watershadersettings = 1 {
if shader_enabled shader_set(shd_wave);
    shader_set_uniform_f(uni_time, var_time_var);
    shader_set_uniform_f(uni_mouse_pos, var_mouse_pos_x, var_mouse_pos_y);
    shader_set_uniform_f(uni_resolution, var_resolution_x, var_resolution_y);
    shader_set_uniform_f(uni_wave_amount, var_wave_amount);
    shader_set_uniform_f(uni_wave_distortion, var_wave_distortion );
    shader_set_uniform_f(uni_wave_speed, var_wave_speed);
    if full_screen_effect draw_surface(surf,0,0);
shader_reset();
}