draw_sprite_ext(sprite_index,image_index,x-camera_get_view_x(view_camera[0]),y-camera_get_view_y(view_camera[0]),1,1,0,c_white,0.5)

//x = ((o_fullscreensystem.ww) - (300 *((o_fullscreensystem.ww) / 1024))) - 256;
x = 1200 + camera_get_view_x(view_camera[0]) - ((o_fullscreensystem.xx) / 1.5);
y = camera_get_view_y(view_camera[0]) + banner