if (room != r_leveleditor || global.LEMode != 1 || global.LEBuild != 1) exit;
if (global.LES < 96 || global.LES > 100) exit;
orientation = scr_slope_orientation(orientation + 1);
image_index = orientation;
global.LEBlockSlopeRotation = orientation;
global.LEVerified = 0;
scr_troop_nav_mark_dirty();
