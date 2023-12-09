image_speed = 0
max_depth = 16;
obj_to_follow = o_3ddot;
factor = 50
hdepth = 0;
vdepth = 0;
spawnchance = irandom_range(0,1);
hidesprites = false
if global.whiteblock > 1 {
alarm[0] = random_range(1,400*(global.maxfps/60));
}
depth = -y;