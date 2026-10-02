if (customhat == 1 && sprite_exists(curhat)) {
    draw_sprite_ext(curhat, 0, x, y, 5 * hatxscale, 5 * hatyscale, 0, c_white, 1);
} else {
    draw_self();
}
