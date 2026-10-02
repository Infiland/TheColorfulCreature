image_speed = 0
max_depth = 16;
obj_to_follow = o_3ddot;
factor = 50
hdepth = 0;
vdepth = 0;
spawnchance = irandom_range(0,1);
hidesprites = false
if global.whiteblock > 1 {
alarm[0] = random_range(1,400*(TCC_SIM_HZ/60));
}
depth = -y;

if room = r_leveleditor || room = r_customlevelworkshop {
if global.LEBlockStyle = 1 { sprite_index = s_redblockbricks }
}
// Navigation geometry changed; culling alone never invalidates the cache.
scr_troop_nav_mark_dirty();
