draw_sprite_ext(s_LELiquids,0,x,y,1,1,0,c_white,ui_draw_alpha);
if (!instance_exists(o_waterleveleditorline) && global.LEBuild == 3 && global.LEMode == 1) {
    draw_sprite_ext(s_liquidarrow,0,771,68,1,ui_arrow_yscale,0,c_white,1);
}
