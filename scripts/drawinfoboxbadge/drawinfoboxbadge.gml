function draw_tooltip_box(text, col1, col2) {
    draw_set_font(global.deathfont);
    draw_set_alpha(0.2);
    draw_rectangle_color(1020, 230, 700, 340, col1, col2, col1, col2, false);
    draw_set_alpha(1);
    draw_text_ext(1000, 240, text, 30, 300);
    draw_set_font(global.coolfont);
}

// Legacy wrapper kept for backward compatibility with mods
function drawinfoboxbadge(text, col1, col2) {
    draw_tooltip_box(text, col1, col2);
}