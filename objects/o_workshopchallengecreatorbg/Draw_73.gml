// Opaque backdrop: this is a full-screen editor, so the menu behind it stays out of the way.
draw_set_alpha(1)
draw_set_color(WC_UI_BG)
draw_rectangle(0,0,1024,768,false)

if instance_exists(o_workshopchallengecreator) {
	// Well behind the level cards
	var L = o_workshopchallengecreator.L
	scr_workshopchallenge_ui_box(L.list, WC_UI_WELL, -1, 8)
}
draw_set_color(c_white)
