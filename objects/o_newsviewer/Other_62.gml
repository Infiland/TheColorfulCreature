/// @description Handle HTTP async response (news data + image downloads)

var _id = async_load[? "id"]
var _status = async_load[? "status"]

// === Handle image file downloads ===
if (ds_map_exists(pending_image_reqs, _id)) {
    if (_status < 0) {
        ds_map_delete(pending_image_reqs, _id)
        loading_image = false
        exit
    }
    if (_status != 0) exit

    var _info = ds_map_find_value(pending_image_reqs, _id)
    ds_map_delete(pending_image_reqs, _id)

    if (file_exists(_info.filename)) {
        var _spr = sprite_add(_info.filename, 0, false, true, 0, 0)
        if (_spr >= 0) {
            ds_map_add(loaded_images, _info.url, _spr)
            needs_recalc = true
        }
    }

    loading_image = false
    exit
}

// === Handle "load more" request ===
if (_id == load_more_request) {
    if (_status < 0) {
        loading_more = false
        exit
    }
    if (_status != 0) exit

    var _result = async_load[? "result"]
    try {
        var _json = json_parse(_result)
        var _items = _json.appnews.newsitems

        if (array_length(_items) < news_per_page) {
            can_load_more = false
        }

        for (var i = 0; i < array_length(_items); i++) {
            var _item = _items[i]
            var _date_val = _item.date
            var _gm_date = _date_val / 86400 + 25569
            var _date_str = string(date_get_month(_gm_date)) + "/" + string(date_get_day(_gm_date)) + "/" + string(date_get_year(_gm_date))

            var _contents = variable_struct_exists(_item, "contents") ? _item.contents : ""
            var _thumb = extract_first_image(_contents)

            var _article = {
                title: _item.title,
                date_str: _date_str,
                date_unix: _date_val,
                author: variable_struct_exists(_item, "author") ? _item.author : "",
                contents: _contents,
                feedlabel: variable_struct_exists(_item, "feedlabel") ? _item.feedlabel : "",
                thumb_url: _thumb
            }

            array_push(articles, _article)

            // Queue thumbnail
            if (_thumb != "" && !ds_map_exists(loaded_images, _thumb)) {
                array_push(thumb_queue, _thumb)
            }
        }

        // Recalculate scroll max with load more button
        var _total = array_length(articles) * row_h
        if (can_load_more) _total += load_more_h
        scroll_max = max(0, _total - (view_bottom - view_top))

    } catch(e) {
        // Silently fail on load more
    }

    loading_more = false
    load_more_request = -1
    exit
}

// === Handle initial news data request ===
if (_id != news_request) exit

var _result = async_load[? "result"]

if (_status < 0) {
    state = "error"
    error_msg = "Failed to fetch news."
    exit
}

if (_status != 0) exit

try {
    var _json = json_parse(_result)
    var _items = _json.appnews.newsitems

    if (array_length(_items) < news_per_page) {
        can_load_more = false
    }

    articles = []
    for (var i = 0; i < array_length(_items); i++) {
        var _item = _items[i]
        var _date_val = _item.date
        var _gm_date = _date_val / 86400 + 25569
        var _date_str = string(date_get_month(_gm_date)) + "/" + string(date_get_day(_gm_date)) + "/" + string(date_get_year(_gm_date))

        var _contents = variable_struct_exists(_item, "contents") ? _item.contents : ""
        var _thumb = extract_first_image(_contents)

        var _article = {
            title: _item.title,
            date_str: _date_str,
            date_unix: _date_val,
            author: variable_struct_exists(_item, "author") ? _item.author : "",
            contents: _contents,
            feedlabel: variable_struct_exists(_item, "feedlabel") ? _item.feedlabel : "",
            thumb_url: _thumb
        }

        array_push(articles, _article)

        // Queue thumbnail download
        if (_thumb != "" && !ds_map_exists(loaded_images, _thumb)) {
            array_push(thumb_queue, _thumb)
        }
    }

    state = "list"
    scroll = 0
    scroll_target = 0

    // Calculate scroll max with load more button
    var _total = array_length(articles) * row_h
    if (can_load_more) _total += load_more_h
    scroll_max = max(0, _total - (view_bottom - view_top))

} catch(e) {
    state = "error"
    error_msg = "Failed to parse news data."
}
