global.LES = 0;
global.canchange = false

maxblocks = 100
global.LEBlockSlopeRotation = 0
maxback = 23
maxliquid = 1
depth = -10001
image_speed = 1 * (60 / global.maxfps)
image_alpha = 0

// Initialize the real sprite/mask before the first native timing registration.
scr_leveleditorsprites(global.LES);
timing_ui_register_target("editor-preview");
