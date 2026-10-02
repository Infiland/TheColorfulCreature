if (cosmetics_browser_open()) exit;
if image_alpha = 1 {
	instance_deactivate_object(o_allskinbuttons)
	instance_deactivate_object(o_allitembuttons)
	timing_activate_object(o_allhatbuttons)
global.customizeselect = 2
}