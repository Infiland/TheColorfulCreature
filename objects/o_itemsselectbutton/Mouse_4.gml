if (cosmetics_browser_open()) exit;
if image_alpha = 1 {
	instance_deactivate_object(o_allskinbuttons)
	instance_deactivate_object(o_allhatbuttons)
	timing_activate_object(o_allitembuttons)
global.customizeselect = 3
}