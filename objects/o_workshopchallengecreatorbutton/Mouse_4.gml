if instance_exists(o_popup) { exit }
if !instance_exists(creator) { exit }

var c = creator

switch (kind) {
case 0:
	c.filter_mode = 0
	global.workshopchallenge_scroll = 0
	break
case 1:
	c.filter_mode = 1
	global.workshopchallenge_scroll = 0
	break
case 2:
	if (c.title == "") {
		if !instance_exists(o_popup) {
			global.popup_config = { title: "Workshop Challenge", message: "Provide a title first.", mode: 0 }
			instance_create(0, 0, o_popup)
		}
		exit
	}

	var title = string(c.title)
	var draft = {}
	draft.title = title
	draft.levels = []

	var ids = []
	var out_i = 0
	var idx = 0
	var diamond_sum = 0
	var diff_sum = 0

	for (var i = 0; i < array_length(c.level_buttons); i++) {
		var btn = c.level_buttons[i]
		if instance_exists(btn) && btn.selected = 1 {
			draft.levels[out_i] = { id: btn.level, title: btn.mTitle, diamond_time: btn.diamond_time, difficulty: btn.difficulty }
			ids[idx] = btn.level
			out_i += 1
			idx += 1
			diamond_sum += btn.diamond_time
			diff_sum += btn.difficulty
		}
	}

	if (out_i <= 0) {
		if !instance_exists(o_popup) {
			global.popup_config = { title: "Workshop Challenge", message: "Select at least one level first.", mode: 0 }
			instance_create(0, 0, o_popup)
		}
		exit
	}

	draft.diamond_time = diamond_sum
	draft.difficulty = diff_sum / out_i
	draft.is_draft = 1

	global.workshopchallenge_draft = draft
	global.workshopchallenge_draft_title = title
	global.workshopchallenge_draft_level_ids = ids

	scr_workshopchallenge_start(draft)
	break
case 3:
	if global.cheats != 0 {
		if !instance_exists(o_popup) {
			global.popup_config = { title: "Workshop Challenge", message: "Cheats must be disabled to upload.", mode: 0 }
			instance_create(0, 0, o_popup)
		}
		exit
	}
	if (c.title == "") {
		if !instance_exists(o_popup) {
			global.popup_config = { title: "Workshop Challenge", message: "Select levels and provide a title first.", mode: 0 }
			instance_create(0, 0, o_popup)
		}
		exit
	}

	var title2 = string(c.title)
	var draft2 = {}
	draft2.title = title2
	draft2.levels = []

	var ids2 = []
	var out_i2 = 0
	var idx2 = 0
	var diamond_sum2 = 0
	var diff_sum2 = 0

	for (var j = 0; j < array_length(c.level_buttons); j++) {
		var btn2 = c.level_buttons[j]
		if instance_exists(btn2) && btn2.selected = 1 {
			draft2.levels[out_i2] = { id: btn2.level, title: btn2.mTitle, diamond_time: btn2.diamond_time, difficulty: btn2.difficulty }
			ids2[idx2] = btn2.level
			out_i2 += 1
			idx2 += 1
			diamond_sum2 += btn2.diamond_time
			diff_sum2 += btn2.difficulty
		}
	}

	if (out_i2 <= 0) {
		if !instance_exists(o_popup) {
			global.popup_config = { title: "Workshop Challenge", message: "Select levels and provide a title first.", mode: 0 }
			instance_create(0, 0, o_popup)
		}
		exit
	}

	draft2.diamond_time = diamond_sum2
	draft2.difficulty = diff_sum2 / out_i2
	draft2.is_draft = 1

	var sig = scr_workshopchallenge_signature(title2, ids2)
	if (global.workshopchallenge_beaten_signature == sig) {
		global.workshopchallenge_draft = draft2
		global.workshopchallenge_draft_title = title2
		global.workshopchallenge_draft_level_ids = ids2

		if !instance_exists(o_publishworkshopchallenge) {
			instance_create(0, 0, o_publishworkshopchallenge)
		}
	} else {
		if !instance_exists(o_popup) {
			global.workshopchallenge_pending_draft = draft2
			global.workshopchallenge_pending_title = title2
			global.workshopchallenge_pending_level_ids = ids2

			global.popup_config = {
				title: "Workshop Challenge",
				message: "Beat your challenge first to upload it.\nTry to beat it now?",
				mode: 1,
				yes_text: "Play",
				no_text: "Cancel",
				cb_yes: function() {
					global.workshopchallenge_draft = global.workshopchallenge_pending_draft
					global.workshopchallenge_draft_title = global.workshopchallenge_pending_title
					global.workshopchallenge_draft_level_ids = global.workshopchallenge_pending_level_ids
					scr_workshopchallenge_start(global.workshopchallenge_pending_draft)

					global.workshopchallenge_pending_draft = undefined
					global.workshopchallenge_pending_title = undefined
					global.workshopchallenge_pending_level_ids = undefined
				},
				cb_no: function() {
					global.workshopchallenge_pending_draft = undefined
					global.workshopchallenge_pending_title = undefined
					global.workshopchallenge_pending_level_ids = undefined
				}
			}
			instance_create(0, 0, o_popup)
		}
	}
	break
}
