var_time_var+=0.04;

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