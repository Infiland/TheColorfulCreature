event_inherited()
switch(global.antialiasingsettings) {
case(0): image_index = 0 break;
case(2): image_index = 1 break;
case(4): image_index = 2 break;
case(8): image_index = 3 break;
}
if global.choosesettings != 0 { x = lerp(x,camera_get_view_x(view_camera[0])-256,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 0 { x = lerp(x,camera_get_view_x(view_camera[0])+288,0.2 * (60 / global.maxfps)) }