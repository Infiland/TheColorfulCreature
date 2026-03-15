if !instance_exists(creator) {
	instance_destroy()
	exit
}

// Block interaction when a modal popup is open
if instance_exists(o_popup) {
	mouseon = false
	window_set_cursor(cr_default)
	exit
}

var c = creator

switch (kind) {
case 0: // Filter: subscribed
	if c.filter_mode = 0 {
		dlineC_R = 0; dlineC_G = 255; dlineC_B = 0
	} else {
		dlineC_R = 255; dlineC_G = 255; dlineC_B = 255
	}
	break
case 1: // Filter: my levels
	if c.filter_mode = 1 {
		dlineC_R = 0; dlineC_G = 255; dlineC_B = 0
	} else {
		dlineC_R = 255; dlineC_G = 255; dlineC_B = 255
	}
	break
case 2: // Play
	var can_play = (c.title != "" && c.selected_count > 0)
	if can_play {
		dlineC_R = 0; dlineC_G = 255; dlineC_B = 0
	} else {
		dlineC_R = 120; dlineC_G = 120; dlineC_B = 120
	}
	break
case 3: // Upload
	var can_base = (c.title != "" && c.selected_count > 0 && global.cheats = 0)
	if !can_base {
		dlineC_R = 120; dlineC_G = 120; dlineC_B = 120
		text = "Upload\nChallenge"
	} else {
		if (global.workshopchallenge_beaten_signature == c.signature_current) {
			dlineC_R = 0; dlineC_G = 255; dlineC_B = 0
			text = "Upload\nChallenge"
		} else {
			dlineC_R = 255; dlineC_G = 255; dlineC_B = 0
			text = "Upload\n(Beat First)"
		}
	}
	break
}

