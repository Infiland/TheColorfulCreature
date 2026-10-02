// Receipt ownership survives a closed/reopened viewer. No async_load map is retained.
function news_images_boot() {
    if (!variable_global_exists("news_image_receipts")) {
        global.news_image_receipts = ds_map_create();
        global.news_image_view_serial = 0;
    }
    if (!instance_exists(o_newsimagereceipts))
        instance_create_depth(0, 0, 0, o_newsimagereceipts);
}

function news_images_open() {
    news_images_boot();
    global.news_image_view_serial += 1;
    return global.news_image_view_serial;
}

function news_images_track(_request, _owner, _view, _filename) {
    ds_map_add(global.news_image_receipts, _request,
        {owner:_owner, view:_view, filename:_filename});
}

function news_images_settle(_request) {
    if (variable_global_exists("news_image_receipts"))
        ds_map_delete(global.news_image_receipts, _request);
}

function news_images_release(_owner, _view) {
    if (!variable_global_exists("news_image_receipts")) return;
    var _key = ds_map_find_first(global.news_image_receipts);
    while (!is_undefined(_key)) {
        var _record = ds_map_find_value(global.news_image_receipts, _key);
        if (_record.owner == _owner && _record.view == _view) _record.owner = noone;
        _key = ds_map_find_next(global.news_image_receipts, _key);
    }
}

function news_images_http_orphan(_request, _status) {
    if (!variable_global_exists("news_image_receipts")) return;
    if (!ds_map_exists(global.news_image_receipts, _request)) return;
    var _record = ds_map_find_value(global.news_image_receipts, _request);
    // A live matching viewer alone creates its sprite, regardless of event dispatch order.
    if (instance_exists(_record.owner)
        && variable_instance_exists(_record.owner, "news_image_view")
        && variable_instance_get(_record.owner, "news_image_view") == _record.view) return;
    if (_status != 0 && _status >= 0) return;
    news_images_settle(_request);
    if (file_exists(_record.filename)) file_delete(_record.filename);
}
