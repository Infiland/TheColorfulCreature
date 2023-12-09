if ingame = true {
if instance_exists(o_settingspausemenu) {
x = lerp(x,vx + 896,0.2)
y = lerp(y,vy + 32,0.2)
xscale = 0.5
yscale = 0.5

text = loc(7);

} else {
x = oldx
y = oldy
text = loc(62)
xscale = 0.3
yscale = 0.3
}}

if room = r_leveleditor {
x = camera_get_view_x(view_camera[0]) + 15
y = camera_get_view_y(view_camera[0]) + 9
}