if (!platform_mobile()) { instance_destroy(); exit; }
image_speed = 0;
image_alpha = 0;
depth = -10000;
my_touch = -1;
drag_offset_x = 0; drag_offset_y = 0;
press = 0;
pressed = 0;
touch_mask = 0;
touch_previous = 0;
alpha = 0.7;
gui_x = -300; gui_y = -300;
x = -300; y = -300;
touch_name = "";
switch (object_index) {
    case o_buttonleftandroid: touch_name = "left"; break;
    case o_buttonrightandroid: touch_name = "right"; break;
    case o_buttonjumpandroid: touch_name = "jump"; image_xscale = 1.1; break;
    case o_buttoninteractandroid: touch_name = "interact"; break;
    case o_buttonrestartandroid: touch_name = "restart"; image_xscale = 0.75; break;
    case o_buttonskipandroid: touch_name = "skip"; image_xscale = 0.75; break;
}
image_yscale = image_xscale;
touch_base_scale = image_xscale;
