result = 0;
state = "initializing";
timer = 180;
wait_seconds = 0;
new_item = -1;
requestId = -1;
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
    if (_handle <= 0) { result = 4; state = "finished"; return; }
    var _ok = tcc_steam_ugc_set_item_title(_handle, publish_document.metadata.name);
    _ok = tcc_steam_ugc_set_item_description(_handle, publish_document.metadata.text) && _ok;
    _ok = tcc_steam_ugc_set_item_visibility(_handle, ugc_visibility_public) && _ok;
    _ok = tcc_steam_ugc_set_item_tags(_handle, level_publish_tags(publish_document)) && _ok;
    _ok = tcc_steam_ugc_set_item_preview(_handle, image) && _ok;
    _ok = tcc_steam_ugc_set_item_content(_handle, content_directory) && _ok;
    if (!_ok) { result = 4; state = "finished"; return; }
    state = "submitting";
    wait_seconds = 0;
    requestId = tcc_steam_ugc_submit_item_update(_handle, "Version 1." + string(publish_document.metadata.workshopVersion + 1));
    if (requestId < 0) { result = 4; state = "finished"; }
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
    new_item = tcc_steam_ugc_create_item(global.appid, ugc_filetype_community);
    if (new_item < 0) { result = 4; state = "finished"; }
}
