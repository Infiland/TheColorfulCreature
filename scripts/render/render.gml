function render() {
	instance_deactivate_object(o_redblockbackground)
	instance_activate_region(camera_get_view_x(view_camera[0]) - 50, camera_get_view_y(view_camera[0]) - 50, camera_get_view_width(view_camera[0]) + 100, camera_get_view_height(view_camera[0]) + 100, true);


}
