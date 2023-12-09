x = mouse_x
y = mouse_y
sprite_index = s_eraser
depth = -1000

if device_mouse_check_button_released(0,mb_right) {
instance_create(x,y,o_placeblock)
instance_destroy()
}