if (!timing_instance_step()) exit;
x = device_mouse_x(my_touch)
y = device_mouse_y(my_touch)

if (global.touch_blocked || !timing_device_mouse_down(my_touch,mb_left)) {
instance_destroy()
}
