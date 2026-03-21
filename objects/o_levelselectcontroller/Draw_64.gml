/// @description Draw page title and navigation indicators
if (current_page < 0 || current_page >= total_pages) exit;

var _page = pages[current_page];

draw_set_font(fnt_mainmenu);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);

// Page title (below the warning text and hardmode toggle)
draw_text(512, 210, _page.title);

// Page indicator
draw_text(512, 745, string(current_page + 1) + " / " + string(total_pages));

// Left arrow
if (current_page > 0) {
	draw_text(80, 745, "<");
}

// Right arrow
if (current_page < total_pages - 1) {
	draw_text(944, 745, ">");
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
