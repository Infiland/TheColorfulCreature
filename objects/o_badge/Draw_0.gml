/// @description Draw badges

// Reset badge positions before drawing
badge_reset_positions();

// Count visible badges to right-align the row
var right_edge = 1000;
var y_pos = 446;
var spacing = 34;

var visible_count = 0;
for (var i = 0; i < ds_list_size(global.badge_order); i++) {
    var _b = global.badges[? global.badge_order[| i]];
    if (_b.visible && _b.count > 0) visible_count++;
}

var start_x = right_edge - (visible_count * spacing);
badge_draw_row(start_x, y_pos, spacing);

// Draw info box for hovered badge
if (hovered_badge != undefined) {
    badge_draw_infobox(700, 260, hovered_badge);
}
