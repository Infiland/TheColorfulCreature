if room != r_leveleditor {
if global.backround = 0 { instance_destroy() }
}
image_xscale = room_width / 32
depth = 8999
image_alpha = random_range(0.1,0.2)
image_yscale = (4 * (image_alpha)) * 2
x = 0
y = irandom_range(0,room_height-(120 * image_yscale))

switch(global.color) {
case(0): image_blend = c_red break;
case(1): image_blend = c_yellow break;
case(2): image_blend = c_green break;
case(3): image_blend = c_blue break;
case(4): image_blend = c_white break;
}