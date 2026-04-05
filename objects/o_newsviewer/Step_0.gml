/// @description Handle scrolling, clicks, image queue

// Overlay fade in
overlay_alpha = lerp(overlay_alpha, 1, 0.15 * (60 / global.maxfps))

// Loading dots animation
loading_timer += 60 / global.maxfps
if (loading_timer >= 20) {
    loading_timer = 0
    loading_dots = (loading_dots + 1) % 4
}

// Smooth scrolling
scroll = lerp(scroll, scroll_target, 0.2 * (60 / global.maxfps))
scroll = clamp(scroll, 0, max(0, scroll_max))

// Mouse wheel scrolling
if (mouse_wheel_down()) scroll_target += 60
if (mouse_wheel_up()) scroll_target -= 60
scroll_target = clamp(scroll_target, 0, max(0, scroll_max))

// Gamepad back
if (gamepad_button_check_pressed(0, gp_face2)) {
    event_perform(ev_keypress, vk_escape)
}

// Image/thumbnail queue processing — download via http_get_file
if (!loading_image) {
    // Prioritize thumbnails when in list view, article images when in article view
    var _next_url = ""
    if (state == "list" && array_length(thumb_queue) > 0) {
        _next_url = thumb_queue[0]
        array_delete(thumb_queue, 0, 1)
    } else if (array_length(image_queue) > 0) {
        _next_url = image_queue[0]
        array_delete(image_queue, 0, 1)
    } else if (array_length(thumb_queue) > 0) {
        _next_url = thumb_queue[0]
        array_delete(thumb_queue, 0, 1)
    }

    if (_next_url != "" && !ds_map_exists(loaded_images, _next_url)) {
        img_counter++
        var _filename = "news_img_" + string(img_counter) + ".png"
        var _req = http_get_file(_next_url, _filename)
        ds_map_add(pending_image_reqs, _req, { url: _next_url, filename: _filename })
        array_push(temp_image_files, _filename)
        loading_image = true
    }
}

// Recalculate block heights when images finish loading (dimensions change)
if (state == "article" && needs_recalc && !loading_image && array_length(image_queue) == 0) {
    recalc_block_heights()
    var _total_h = calculate_blocks_height()
    scroll_max = max(0, _total_h - (view_bottom - view_top - 60))
    scroll_target = clamp(scroll_target, 0, max(0, scroll_max))
    needs_recalc = false
}

// GUI mouse position
var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)

// X button click (top-right corner) — close viewer from any state
if (mouse_check_button_pressed(mb_left)) {
    if (_mx >= margin_x + content_w - 30 && _mx <= margin_x + content_w + 10
     && _my >= margin_y - 10 && _my <= margin_y + header_h) {
        instance_destroy()
        exit
    }
}

// List view - click detection
if (state == "list" && mouse_check_button_pressed(mb_left)) {
    // Check "Load More" button
    if (can_load_more && !loading_more) {
        var _load_more_y = view_top + array_length(articles) * row_h - scroll
        if (_mx >= margin_x && _mx <= margin_x + content_w
         && _my >= _load_more_y && _my < _load_more_y + load_more_h
         && _my >= view_top && _my < view_bottom) {
            loading_more = true
            // Use the last article's unix date as enddate for pagination
            var _last_date = articles[array_length(articles) - 1].date_unix - 1
            load_more_request = http_get("https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=1651680&count=" + string(news_per_page) + "&maxlength=0&format=json&enddate=" + string(_last_date))
        }
    }

    // Check article rows
    for (var i = 0; i < array_length(articles); i++) {
        var _ry = view_top + (i * row_h) - scroll

        if (_mx >= margin_x && _mx <= margin_x + content_w
         && _my >= max(view_top, _ry) && _my < min(view_bottom, _ry + row_h)
         && _ry + row_h > view_top && _ry < view_bottom) {
            selected_article = i
            state = "article"
            scroll = 0
            scroll_target = 0

            // Parse content
            article_blocks = parse_article_content(articles[i].contents)
            draw_set_font(global.deathfont)
            recalc_block_heights()
            needs_recalc = false

            var _total_h = calculate_blocks_height()
            scroll_max = max(0, _total_h - (view_bottom - view_top - 60))

            // Queue images
            for (var j = 0; j < array_length(article_blocks); j++) {
                if (article_blocks[j].type == "image") {
                    var _img_url = article_blocks[j].url
                    if (!ds_map_exists(loaded_images, _img_url)) {
                        array_push(image_queue, _img_url)
                    }
                }
            }
            break
        }
    }
}

// Article view - back button click + link clicks
if (state == "article" && mouse_check_button_pressed(mb_left)) {
    if (_mx >= margin_x && _mx <= margin_x + 120 && _my >= margin_y + 4 && _my <= margin_y + header_h) {
        event_perform(ev_keypress, vk_escape)
    } else {
        // Check link clicks
        var _content_top = view_top + 10
        var _content_bottom = view_bottom
        if (_my >= _content_top && _my < _content_bottom) {
            // Walk through blocks to find the link y positions
            draw_set_font(global.deathfont)
            var _dy = _content_top - scroll
            // Skip past article title + metadata
            var _article = articles[selected_article]
            _dy += string_height_ext(_article.title, -1, content_w - 16) + 8 + 24 + 12

            for (var i = 0; i < array_length(article_blocks); i++) {
                var _block = article_blocks[i]
                if (_block.type == "link") {
                    var _lw = string_width_ext(_block.text, -1, content_w - 16)
                    if (_mx >= margin_x + 8 && _mx <= margin_x + 8 + _lw
                     && _my >= _dy && _my < _dy + _block.height) {
                        url_open(_block.url)
                        break
                    }
                }
                _dy += _block.height
            }
        }
    }
}
