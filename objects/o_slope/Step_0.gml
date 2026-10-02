if (!timing_instance_step()) exit;
image_speed = 0;
image_index = orientation;
// Editing uses a full-tile selection mask. Gameplay always uses the shared
// triangle helpers, so editing cannot change the physical triangle.
if (room == r_leveleditor && global.LEMode == 1) mask_index = s_block;
else mask_index = s_redblockslope;
