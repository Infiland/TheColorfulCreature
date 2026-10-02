if (has_access && !is_undefined(catalog)) {
    commentary_draw_page(catalog, chapter_index, art_sprite, show_sources, source_index);
    if (status_text != "") {
        draw_set_font(fnt_death);
        draw_set_color(c_yellow);
        draw_text(248, 669, status_text);
        draw_set_color(c_white);
    }
} else {
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(12,14,19));
    draw_rectangle(0, 0, 1024, 768, false);
    draw_set_color(c_white);
    draw_set_font(fnt_mainmenu);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_transformed(32, 30, "Commentary", 0.85, 0.85, 0);
    commentary_draw_button(840, 34, 992, 78, "Back  /  Esc, B", true);
    draw_set_font(fnt_death);
    draw_text_ext(192, 300, has_access ? status_text : "Explore the development history of The Colorful Creature.\n\nThis gallery requires ownership of the commentary DLC on Steam.\nOpen the Steam version with the DLC on your account to read it.", 27, 640);
}
