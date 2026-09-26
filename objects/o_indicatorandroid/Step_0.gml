x = device_mouse_x(my_touch)
y = device_mouse_y(my_touch)

if (global.touch_blocked || !device_mouse_check_button(my_touch,mb_left)) {
instance_destroy()
}
