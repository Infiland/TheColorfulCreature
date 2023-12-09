image_speed = 0
max_depth = 16;
obj_to_follow = o_3ddot;
factor = 50
hdepth = 0;
vdepth = 0;
depth = -y;
hidesprites = false
spawnchance = irandom_range(0,10);
alarm[0] = random_range(20* (global.maxfps / 60),80* (global.maxfps / 60));

if room = r_leveleditor || room = r_customlevelworkshop {
if global.LEBlockStyle = 1 { sprite_index = s_whiteblockbricks }
}