draw_set_color(c_white);

uni_time = shader_get_uniform(shd_wave,"time");
var_time_var = 0;

uni_mouse_pos = shader_get_uniform(shd_wave,"mouse_pos");
var_mouse_pos_x = mouse_x - camera_get_view_x(0);
var_mouse_pos_y = mouse_y - camera_get_view_y(0);

uni_resolution = shader_get_uniform(shd_wave,"resolution");
var_resolution_x = camera_get_view_width(0);
var_resolution_y = camera_get_view_height(0);

uni_wave_amount = shader_get_uniform(shd_wave,"wave_amount");
var_wave_amount = 10; //higher = more waves

uni_wave_distortion = shader_get_uniform(shd_wave,"wave_distortion");
var_wave_distortion = 100; //higher = less distortion

uni_wave_speed = shader_get_uniform(shd_wave,"wave_speed");
var_wave_speed = 1.5 * (60 / global.maxfps); //higher = faster

shader_enabled = true;
full_screen_effect = false;

surf = surface_create(camera_get_view_width(1), camera_get_view_height(1));
view_set_surface_id(0, surf);