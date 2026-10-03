if (global.LEBuild == 1 && item >= 96 && item <= 100) {
    scr_slope_draw(item - 96, global.LEBlockSlopeRotation, x, y,
        image_xscale, image_yscale, image_alpha);
} else {
    draw_self();
}
