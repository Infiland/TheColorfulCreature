depth = -999

if grid = 1 {
	draw_set_alpha(0.3)
	var camx = camera_get_view_x(view_camera[0]);
	var camy = camera_get_view_y(view_camera[0]);
	var ix, iy;
	for(ix = 32; ix < global.LELevelWidthBlocks * 32; ix += 32) {
		draw_line_color(ix - camx, 64 - camy, ix - camx, (64 + global.LELevelHeightBlocks * 32) - camy, c_white, c_white)
	}
	for(iy = 96; iy < 64 + (global.LELevelHeightBlocks * 32); iy += 32) {
		draw_line_color(-camx, iy - camy, (global.LELevelWidthBlocks * 32) - camx, iy - camy, c_white, c_white)
	}
	draw_set_alpha(1)
}