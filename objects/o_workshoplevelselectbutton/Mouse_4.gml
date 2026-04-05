if instance_exists(o_popup) { exit }
if filtered_out = 1 { exit }
// Check click is within the drawn tile area
var _tile_w = 390
var _tile_h = 130
if (mouse_x >= x && mouse_x <= x + _tile_w && mouse_y >= y && mouse_y <= y + _tile_h) {
	selected = 1 - selected
}
