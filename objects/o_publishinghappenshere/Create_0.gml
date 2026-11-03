result = 0;
state = "initializing";
timer = 180;
wait_seconds = 0;
updated = (global.Publish_ID != 0);
completion_saved = false;
content_directory = level_directory(level_editor_directory());
image = content_directory + "thumb.jpg";
publish_document = level_read(content_directory);

begin_update = function() {
    if (state == "submitting" || state == "finished") return;
    // Retain a newly assigned id even if the following upload fails; retry updates it.
    publish_document.metadata.publishId = string(int64(global.Publish_ID));
    if (!level_write(content_directory, publish_document)) {
        result = 4; state = "finished"; return;
    }
    var _handle = tcc_steam_ugc_start_item_update(global.appid, global.Publish_ID);
    if (!tcc_steam_ugc_handle_valid(_handle)) { result = 4; state = "finished"; return; }
    var _ok = tcc_steam_ugc_set_item_title(_handle, publish_document.metadata.name);
    _ok = tcc_steam_ugc_set_item_description(_handle, publish_document.metadata.text) && _ok;
    _ok = tcc_steam_ugc_set_item_visibility(_handle, SteamRemoteStoragePublishedFileVisibility.Public) && _ok;
    _ok = tcc_steam_ugc_set_item_tags(_handle, level_publish_tags(publish_document)) && _ok;
    _ok = tcc_steam_ugc_set_item_preview(_handle, image) && _ok;
    _ok = tcc_steam_ugc_set_item_content(_handle, content_directory) && _ok;
    if (!_ok) { result = 4; state = "finished"; return; }
    state = "submitting";
    wait_seconds = 0;
    // The reply arrives later from the Steam pump; "finished" gates a late or duplicate one.
    var _note = "Version 1." + string(publish_document.metadata.workshopVersion + 1);
    if (!tcc_steam_ugc_submit_item_update(_handle, _note, on_submit_result, id)) { result = 4; state = "finished"; }
};

on_create_result = function(_r) {
    var _response = level_publish_callback(_r, state);
    if (!_response.matched) return;
    if (!_response.ok) { result = 4; state = "finished"; return; }
    global.Publish_ID = _response.publishedId;
    publish_document.metadata.publishId = string(int64(global.Publish_ID));
    if (!level_write(content_directory, publish_document)) { result = 4; state = "finished"; return; }
    if (_response.legal) { result = 2; state = "finished"; return; }
    begin_update();
};

on_submit_result = function(_r) {
    var _response = level_publish_callback(_r, state);
    if (!_response.matched) return;
    if (!_response.ok) { result = 4; state = "finished"; return; }
    if (_response.legal) { result = 2; state = "finished"; return; }
    // Only the matching successful submit callback reaches this branch, once.
    state = "finished";
    result = 1;
    if (!completion_saved) {
        completion_saved = true;
        global.workshoplevelversion = publish_document.metadata.workshopVersion + 1;
        publish_document.metadata.workshopVersion = global.workshoplevelversion;
        if (!level_write(content_directory, publish_document)) {
            show_debug_message("Workshop upload succeeded but local metadata could not be saved.");
        }
        if (!achievement_earned("PUBLISHER")) achievement_award("PUBLISHER");
        if (global.skin[42] == 0) {
            global.skin[42] = 1;
            scr_saveskins();
        }
    }
};

if (!tcc_steam_initialised() || !tcc_steam_is_user_logged_on()) {
    result = 3; state = "finished";
} else if (is_undefined(publish_document)) {
    result = 4; state = "finished";
} else if (!file_exists(image)) {
    result = 5; state = "finished";
} else if (updated) {
    begin_update();
} else {
    state = "creating";
    if (!tcc_steam_ugc_create_item(global.appid, SteamRemoteStorageWorkshopFileType.Community, on_create_result, id)) { result = 4; state = "finished"; }
}
