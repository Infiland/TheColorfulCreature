/// @description Handle Steam Async events (catalog query results)

var _async_load = async_load
// A private or removed item can never download: skip it instead of waiting 30 s.
if (state == "waiting" && _async_load[? "event_type"] == "ugc_subscribe_item"
	&& _async_load[? "published_file_id"] == target_file_id && _async_load[? "result"] != ugc_result_success) {
	state = "idle"
	global.workshopER_loading = false
	workshopER_skip_level()
	exit
}
workshopER_handle_async_catalog(_async_load)
