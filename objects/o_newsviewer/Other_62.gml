/// @description Handle HTTP async response

var _id = async_load[? "id"]
if (_id != news_request) exit

var _status = async_load[? "status"]
var _result = async_load[? "result"]

if (_status < 0) {
    state = "error"
    error_msg = "Failed to fetch news."
    exit
}

// Wait until all data is received (status 0 = complete)
if (_status != 0) exit

// Parse the JSON response
try {
    var _json = json_parse(_result)
    var _items = _json.appnews.newsitems

    articles = []
    for (var i = 0; i < array_length(_items); i++) {
        var _item = _items[i]

        // Convert unix timestamp to readable date
        var _date_val = _item.date
        // GameMaker dates: base is Dec 30, 1899. Unix epoch is Jan 1, 1970 = 25569 days
        var _gm_date = _date_val / 86400 + 25569
        var _date_str = string(date_get_month(_gm_date)) + "/" + string(date_get_day(_gm_date)) + "/" + string(date_get_year(_gm_date))

        var _article = {
            title: _item.title,
            date_str: _date_str,
            author: variable_struct_exists(_item, "author") ? _item.author : "",
            contents: variable_struct_exists(_item, "contents") ? _item.contents : "",
            feedlabel: variable_struct_exists(_item, "feedlabel") ? _item.feedlabel : ""
        }

        array_push(articles, _article)
    }

    state = "list"
    scroll = 0
    scroll_target = 0

    // Calculate list scroll max
    scroll_max = max(0, array_length(articles) * row_h - (768 - margin_y * 2 - header_h - 20))

} catch(e) {
    state = "error"
    error_msg = "Failed to parse news data."
}
