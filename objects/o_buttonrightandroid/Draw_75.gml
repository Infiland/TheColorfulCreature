draw_sprite_ext(sprite_index,image_index,x-camera_get_view_x(view_camera[0]),y-camera_get_view_y(view_camera[0]),1,1,0,c_white,alpha)

x = global.androidrightx+camera_get_view_x(view_camera[0])
y = global.androidrighty+camera_get_view_y(view_camera[0])
//x = (-(o_fullscreensystem.xx))  + (280 *((o_fullscreensystem.ww) / 1024));