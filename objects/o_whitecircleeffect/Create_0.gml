if place_meeting(x,y-32,o_anyblock) {instance_destroy()}
randomize();
positionwhite = random_range(0,16)
x += positionwhite;
image_alpha = random_range(0.3,0.8);
size = random_range(0.1,0.5);
rise = random_range(1* (global.maxfps / 60),1.2* (global.maxfps / 60));
grvwhite = random_range(0.05 * (global.maxfps / 60),0.1 * (global.maxfps / 60));
timerwhitefinish = random_range(10,30);
timerwhitestart = 0
image_xscale = size;
image_yscale = size;
depth = 2