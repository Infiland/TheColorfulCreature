/// @description Draw badges

// Reset badge positions before drawing
badge_reset_positions();

// Draw badges in a row
var start_x = 970;
var y_pos = 446;
var spacing = 32;

badge_draw_row(start_x, y_pos, spacing);

// Draw info box for hovered badge
if (hovered_badge != undefined) {
    badge_draw_infobox(700, 340, hovered_badge);
}
