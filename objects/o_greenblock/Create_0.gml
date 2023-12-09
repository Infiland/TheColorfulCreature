image_speed = 0
image_index = irandom_range(1,3);
max_depth = 16;
obj_to_follow = o_3ddot;
factor = 50
hdepth = 0;
vdepth = 0;
hidesprites = false 	
spawnchance = irandom_range(0,1);
alarm[0] = random_range(1,400);
depth = -y;

if room = r_leveleditor || room = r_customlevelworkshop {
if global.LEBlockStyle = 1 { sprite_index = s_greenblockbricks }
}