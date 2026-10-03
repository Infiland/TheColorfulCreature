if (global.LEMode == 2) {
    draw_set_alpha(0);
}
if (global.LEBuild == 1 && global.LES >= 96 && global.LES <= 100) {
    scr_slope_draw(global.LES - 96, global.LEBlockSlopeRotation, x, y,
        1, 1, draw_get_alpha());
} else {
    draw_sprite(sprite_index,-1,x,y);
}
