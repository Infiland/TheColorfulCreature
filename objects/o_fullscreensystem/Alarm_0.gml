if global.pause = 0 {
if global.stars > 0 {instance_create(x,y,o_star)}
}
if os_type = os_android || os_type = os_gxgames {
global.windowsresizemain = application_get_position();
xx = global.windowsresizemain[0];
yy = global.windowsresizemain[1];
ww = global.windowsresizemain[2] - global.windowsresizemain[0];
hh = global.windowsresizemain[3] - global.windowsresizemain[1];
}

if room = r_leveleditor || room = r_customlevelworkshop {
if global.LEStarStyle = 1 {
global.LEStarRotation += 1	
}
if global.LEStarStyle = 2 {
global.LEStarRotation -= 1	
}
}

alarm[0] = 10