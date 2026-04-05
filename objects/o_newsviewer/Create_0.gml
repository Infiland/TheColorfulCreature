/// @description Fetch Steam news and initialize viewer

state = "loading" // loading, list, article, error
error_msg = ""

// Scrolling
scroll = 0
scroll_target = 0
scroll_max = 0

// Articles data
articles = []
selected_article = -1

// Image loading via http_get_file (sprite_add with URL doesn't work on Windows)
loaded_images = ds_map_create()       // URL → sprite index
pending_image_reqs = ds_map_create()  // http request ID → { url, filename }
image_queue = []
loading_image = false
needs_recalc = false
img_counter = 0
temp_image_files = []  // track temp files for cleanup

// Thumbnail loading queue (separate from article images)
thumb_queue = []

// Content blocks for current article view
article_blocks = []

// Overlay animation
overlay_alpha = 0

// Layout constants
margin_x = 62
margin_y = 60
content_w = 900
header_h = 40
row_h = 80
thumb_size = 60
view_top = margin_y + header_h + 10
view_bottom = 768 - margin_y
load_more_h = 40

// Loading animation
loading_dots = 0
loading_timer = 0

// Pagination
news_per_page = 20
loading_more = false
load_more_request = -1
can_load_more = true

// Fire the news request
news_request = http_get("https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=1651680&count=" + string(news_per_page) + "&maxlength=0&format=json")

/// @function extract_first_image(content)
/// @description Extract first [img] URL from BBCode content
extract_first_image = function(content) {
    var _c = string_replace_all(content, "{STEAM_CLAN_IMAGE}", "https://clan.akamai.steamstatic.com/images")
    var _s = string_pos("[img]", _c)
    if (_s <= 0) return ""
    var _e = string_pos("[/img]", _c)
    if (_e <= _s) return ""
    return string_copy(_c, _s + 5, _e - _s - 5)
}

/// @function parse_article_content(raw)
/// @description Parse BBCode content into renderable blocks
parse_article_content = function(raw) {
    var _blocks = []
    var _content = raw

    // Replace Steam CDN placeholder
    _content = string_replace_all(_content, "{STEAM_CLAN_IMAGE}", "https://clan.akamai.steamstatic.com/images")

    // Extract [img]...[/img] → markers
    var _iter = 0
    while (string_pos("[img]", _content) > 0 && _iter < 50) {
        _iter++
        var _s = string_pos("[img]", _content)
        var _e = string_pos("[/img]", _content)
        if (_e <= _s) break

        var _url = string_copy(_content, _s + 5, _e - _s - 5)
        var _before = string_copy(_content, 1, _s - 1)
        var _after = string_copy(_content, _e + 6, string_length(_content) - _e - 5)
        _content = _before + "\n<<IMG:" + _url + ">>\n" + _after
    }

    // Extract headers [h1]..[/h1], [h2]..[/h2], [h3]..[/h3]
    var _htags = ["h1", "h2", "h3"]
    for (var _h = 0; _h < 3; _h++) {
        var _tag = _htags[_h]
        var _open = "[" + _tag + "]"
        var _close = "[/" + _tag + "]"
        _iter = 0
        while (string_pos(_open, _content) > 0 && _iter < 50) {
            _iter++
            var _s = string_pos(_open, _content)
            var _e = string_pos(_close, _content)
            if (_e <= _s) break

            var _text = string_copy(_content, _s + string_length(_open), _e - _s - string_length(_open))
            var _before = string_copy(_content, 1, _s - 1)
            var _after = string_copy(_content, _e + string_length(_close), string_length(_content) - _e - string_length(_close) + 1)
            _content = _before + "\n<<H:" + _text + ">>\n" + _after
        }
    }

    // Handle [url=...]text[/url] → link markers
    _iter = 0
    while (string_pos("[url=", _content) > 0 && _iter < 50) {
        _iter++
        var _s = string_pos("[url=", _content)
        var _rest = string_copy(_content, _s, string_length(_content) - _s + 1)
        var _close_bracket = string_pos("]", _rest)
        if (_close_bracket <= 0) break

        // Extract the URL between [url= and ]
        var _link_url = string_copy(_rest, 6, _close_bracket - 6)

        var _end_tag = string_pos("[/url]", _content)
        if (_end_tag <= 0) break

        var _text_start = _s + _close_bracket
        var _link_text = string_copy(_content, _text_start, _end_tag - _text_start)
        // If link text is empty, use the URL as display text
        if (_link_text == "") _link_text = _link_url

        var _before = string_copy(_content, 1, _s - 1)
        var _after = string_copy(_content, _end_tag + 6, string_length(_content) - _end_tag - 5)
        _content = _before + "\n<<LINK:" + _link_url + "|" + _link_text + ">>\n" + _after
    }

    // Handle [dynamiclink href="..."]text[/dynamiclink] → link markers
    _iter = 0
    while (string_pos("[dynamiclink", _content) > 0 && _iter < 50) {
        _iter++
        var _s = string_pos("[dynamiclink", _content)
        var _rest = string_copy(_content, _s, string_length(_content) - _s + 1)
        var _close_bracket = string_pos("]", _rest)
        if (_close_bracket <= 0) break

        // Extract href from [dynamiclink href="URL"]
        var _tag_inner = string_copy(_rest, 1, _close_bracket)
        var _href_start = string_pos("href=\"", _tag_inner)
        var _link_url = ""
        if (_href_start > 0) {
            var _from = _href_start + 6
            var _href_rest = string_copy(_tag_inner, _from, string_length(_tag_inner) - _from + 1)
            var _quote_end = string_pos("\"", _href_rest)
            if (_quote_end > 0) {
                _link_url = string_copy(_href_rest, 1, _quote_end - 1)
            }
        }

        var _end_tag = string_pos("[/dynamiclink]", _content)
        if (_end_tag <= 0) break

        var _text_start = _s + _close_bracket
        var _link_text = string_copy(_content, _text_start, _end_tag - _text_start)

        var _before = string_copy(_content, 1, _s - 1)
        var _after = string_copy(_content, _end_tag + 14, string_length(_content) - _end_tag - 13)

        if (_link_url != "" && _link_text != "") {
            _content = _before + "\n<<LINK:" + _link_url + "|" + _link_text + ">>\n" + _after
        } else if (_link_url != "") {
            _content = _before + "\n<<LINK:" + _link_url + "|" + _link_url + ">>\n" + _after
        } else {
            // No URL found, just strip
            _content = _before + _link_text + _after
        }
    }

    // Handle [previewyoutube=...][/previewyoutube] → "[Video]"
    _iter = 0
    while (string_pos("[previewyoutube", _content) > 0 && _iter < 20) {
        _iter++
        var _s = string_pos("[previewyoutube", _content)
        var _e = string_pos("[/previewyoutube]", _content)
        if (_e <= 0) break

        var _before = string_copy(_content, 1, _s - 1)
        var _after = string_copy(_content, _e + 17, string_length(_content) - _e - 16)
        _content = _before + "\n[Video]\n" + _after
    }

    // Replace separators
    _content = string_replace_all(_content, "[hr][/hr]", "\n<<HR>>\n")
    _content = string_replace_all(_content, "[hr]", "\n<<HR>>\n")

    // Convert paragraph breaks to newlines (must come before stripping)
    _content = string_replace_all(_content, "[/p][p]", "\n\n")
    _content = string_replace_all(_content, "[/p]\n[p]", "\n\n")

    // Replace list bullets
    _content = string_replace_all(_content, "[*]", "\n  - ")

    // Strip all remaining BBCode tags
    var _strip = ["b", "/b", "i", "/i", "u", "/u", "strike", "/strike",
                  "spoiler", "/spoiler", "code", "/code", "noparse", "/noparse",
                  "list", "/list", "olist", "/olist", "table", "/table",
                  "tr", "/tr", "td", "/td", "th", "/th", "url", "/url",
                  "expand", "/expand", "p", "/p"]
    for (var _t = 0; _t < array_length(_strip); _t++) {
        _content = string_replace_all(_content, "[" + _strip[_t] + "]", "")
    }

    // Split by newlines and build blocks
    var _lines = string_split(_content, "\n")

    for (var _i = 0; _i < array_length(_lines); _i++) {
        var _line = _lines[_i]
        // Trim leading/trailing spaces
        while (string_char_at(_line, 1) == " " && string_length(_line) > 0) {
            _line = string_copy(_line, 2, string_length(_line) - 1)
        }
        while (string_char_at(_line, string_length(_line)) == " " && string_length(_line) > 0) {
            _line = string_copy(_line, 1, string_length(_line) - 1)
        }

        if (_line == "") continue

        if (string_pos("<<IMG:", _line) == 1) {
            var _url = string_copy(_line, 7, string_length(_line) - 8)
            array_push(_blocks, { type: "image", url: _url, height: 250 })
        } else if (string_pos("<<H:", _line) == 1) {
            var _text = string_copy(_line, 5, string_length(_line) - 6)
            array_push(_blocks, { type: "header", text: _text, height: 36 })
        } else if (string_pos("<<LINK:", _line) == 1) {
            var _inner = string_copy(_line, 8, string_length(_line) - 9) // strip <<LINK: and >>
            var _pipe = string_pos("|", _inner)
            if (_pipe > 0) {
                var _url = string_copy(_inner, 1, _pipe - 1)
                var _text = string_copy(_inner, _pipe + 1, string_length(_inner) - _pipe)
                array_push(_blocks, { type: "link", url: _url, text: _text, height: 0 })
            }
        } else if (_line == "<<HR>>") {
            array_push(_blocks, { type: "separator", height: 20 })
        } else {
            array_push(_blocks, { type: "text", text: _line, height: 0 })
        }
    }

    return _blocks
}

/// @function recalc_block_heights()
/// @description Recalculate text block heights (call after font is set)
recalc_block_heights = function() {
    draw_set_font(global.deathfont)
    for (var _i = 0; _i < array_length(article_blocks); _i++) {
        var _b = article_blocks[_i]
        if (_b.type == "text") {
            _b.height = string_height_ext(_b.text, -1, content_w - 16) + 6
        } else if (_b.type == "header") {
            _b.height = string_height_ext(_b.text, -1, content_w - 16) + 12
        } else if (_b.type == "link") {
            _b.height = string_height_ext(_b.text, -1, content_w - 16) + 6
        } else if (_b.type == "image") {
            // Check if image is loaded to get actual dimensions
            if (ds_map_exists(loaded_images, _b.url)) {
                var _spr = ds_map_find_value(loaded_images, _b.url)
                if (sprite_exists(_spr)) {
                    var _sw = sprite_get_width(_spr)
                    var _sh = sprite_get_height(_spr)
                    var _scale = min(1, (content_w - 16) / _sw)
                    _b.height = floor(_sh * _scale) + 10
                }
            }
        }
    }
}

/// @function calculate_blocks_height()
/// @description Get total height of all article blocks
calculate_blocks_height = function() {
    var _total = 0
    for (var _i = 0; _i < array_length(article_blocks); _i++) {
        _total += article_blocks[_i].height
    }
    return _total
}
