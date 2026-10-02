if (global.LEBuild == 1 && global.LES >= 96 && global.LES <= 100 && sprite_index != s_cannotplace) {
    scr_slope_draw(global.LES - 96, global.LEBlockSlopeRotation, x, y, 1, 1, image_alpha);
} else {
    draw_self();
}
