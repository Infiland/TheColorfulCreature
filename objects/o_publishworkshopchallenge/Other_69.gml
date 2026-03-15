var event_id = async_load[? "id"];
var type = async_load[? "event_type"];

if type == "ugc_create_item" && event_id == create_request {
	var agreement = async_load[? "legal_agreement_required"];
	if agreement == true {
		result = 2
		timer = 600
		exit
	}
	var res = async_load[? "result"];
	if res != ugc_result_success {
		result = 4
		timer = 600
		exit
	}
	published_file_id = async_load[? "published_file_id"];

	update_handle = steam_ugc_start_item_update(global.appid, published_file_id);
	steam_ugc_set_item_title(update_handle, challenge_title);
	steam_ugc_set_item_description(update_handle, challenge_desc);
	steam_ugc_set_item_visibility(update_handle, ugc_visibility_public);
	var tags;
	tags[0] = "Challenges";
	steam_ugc_set_item_tags(update_handle, tags);
	if file_exists(preview_path) {
		steam_ugc_set_item_preview(update_handle, preview_path);
	}
	steam_ugc_set_item_content(update_handle, content_dir);

	submit_request = steam_ugc_submit_item_update(update_handle, "Initial upload");
	result = 0.5
	exit
}

if type == "ugc_update_item" && event_id == submit_request {
	var agreement2 = async_load[? "legal_agreement_required"];
	if agreement2 == true {
		result = 2
		timer = 600
		exit
	}
	var res2 = async_load[? "result"];
	if res2 == ugc_result_success {
		result = 1
		timer = 900
		// Clear beat gate after successful upload
		global.workshopchallenge_beaten_signature = ""
		scr_workshopchallenge_save_progress()
	} else {
		result = 4
		timer = 600
	}
}
