var _response = level_publish_callback(async_load, state, new_item, requestId);
if (!_response.matched) exit;
if (!_response.ok) { result = 4; state = "finished"; exit; }
if (state == "creating") {
    global.Publish_ID = _response.publishedId;
    publish_document.metadata.publishId = string(int64(global.Publish_ID));
    if (!level_write(content_directory, publish_document)) { result = 4; state = "finished"; exit; }
}
if (_response.legal) { result = 2; state = "finished"; exit; }
if (state == "creating") {
    begin_update();
    exit;
}
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
