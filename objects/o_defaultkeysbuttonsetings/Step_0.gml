if (!timing_instance_step()) exit;
if global.choosesettings != 3 { x = lerp(x,camera_get_view_x(view_camera[0])-256,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 3 { x = lerp(x,camera_get_view_x(view_camera[0])+32,0.2 * (60 / global.maxfps)) }

y = camera_get_view_y(view_camera[0]) + ((platform_touch() && gamepad_remap_active_device() < 0) ? 160 : 640);
text = settings_text("DEFAULT_CONTROLS")
xscale = 0.35
yscale = 0.35
if (global.choosesettings == 3 && mouseon && !settings_fps_input_blocked()
    && !gamepad_remap_capture_active() && !gamepad_remap_input_blocked()) {
    var _device = gamepad_remap_active_device(true);
    if (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face1)) event_perform(ev_mouse, ev_left_press);
}
