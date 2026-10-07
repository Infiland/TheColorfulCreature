if (!timing_instance_step()) exit;
if ingame = true {
if instance_exists(o_settingspausemenu) {
x = lerp(x,vx + 896,0.2)
y = lerp(y,vy + 32,0.2)
xscale = 0.5
yscale = 0.5

text = loc("RETURN");

} else {
x = oldx
y = oldy
text = loc("GO_TO_MAIN_MENU")
xscale = 0.3
yscale = 0.3
}}

if room = r_leveleditor {
x = camera_get_view_x(view_camera[0]) + 15
y = camera_get_view_y(view_camera[0]) + 9
}
// A reachable Return target on landscape phones, including pause settings.
if (platform_mobile() && room != r_leveleditor) {
    image_xscale = 35.2; image_yscale = 21.6;
    xscale = 0.60; yscale = 0.60;
    if (ingame && !instance_exists(o_settingspausemenu)) {
        x = vx + 424; y = vy + 500;
        image_xscale = 46.4;
    } else {
        x = camera_get_view_x(view_camera[0]) + 832;
        y = camera_get_view_y(view_camera[0]) + 16;
    }
}
