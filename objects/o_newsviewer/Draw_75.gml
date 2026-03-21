/// @description Draw news viewer overlay (Draw GUI End)

// Dark overlay background
draw_set_alpha(0.85 * overlay_alpha)
draw_rectangle_color(0, 0, 1024, 768, c_black, c_black, c_black, c_black, false)
draw_set_alpha(overlay_alpha)

// Content panel background
draw_set_color($1a1a1a)
draw_rectangle(margin_x - 10, margin_y - 10, margin_x + content_w + 10, 768 - margin_y + 10, false)
draw_set_color($444444)
draw_rectangle(margin_x - 10, margin_y - 10, margin_x + content_w + 10, 768 - margin_y + 10, true)

draw_set_font(global.deathfont)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)

// ===== LOADING STATE =====
if (state == "loading") {
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    var _dots = ""
    repeat(loading_dots) _dots += "."
    draw_text(512, 384, "LOADING" + _dots)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
}

// ===== ERROR STATE =====
else if (state == "error") {
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    draw_set_color(c_red)
    draw_text(512, 370, error_msg)
    draw_set_color($aaaaaa)
    draw_text(512, 400, "Press ESC to close")
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
}

// ===== LIST VIEW =====
else if (state == "list") {
    // Title bar
    draw_set_color($2a2a2a)
    draw_rectangle(margin_x - 10, margin_y - 10, margin_x + content_w + 10, margin_y + header_h, false)
    draw_set_color($00aaff)
    draw_rectangle(margin_x - 10, margin_y + header_h, margin_x + content_w + 10, margin_y + header_h + 2, false)

    draw_set_color(c_white)
    draw_set_halign(fa_center)
    draw_text(512, margin_y + 4, "NEWS")
    draw_set_halign(fa_left)

    // Clip region for list items
    gpu_set_scissor(margin_x - 10, view_top, content_w + 20, view_bottom - view_top)

    var _mx = device_mouse_x_to_gui(0)
    var _my = device_mouse_y_to_gui(0)

    for (var i = 0; i < array_length(articles); i++) {
        var _ry = view_top + (i * row_h) - scroll

        // Skip if completely off screen
        if (_ry + row_h < view_top || _ry > view_bottom) continue

        var _article = articles[i]

        // Hover highlight
        var _hovered = (_mx >= margin_x && _mx <= margin_x + content_w && _my >= _ry && _my < _ry + row_h && _my >= view_top && _my < view_bottom)
        if (_hovered) {
            draw_set_color($2a2a3a)
            draw_rectangle(margin_x, _ry, margin_x + content_w, _ry + row_h - 2, false)
        }

        // Article title
        draw_set_color(_hovered ? $55bbff : c_white)
        draw_text_ext(margin_x + 8, _ry + 6, _article.title, -1, content_w - 16)

        // Date + feedlabel
        draw_set_color($888888)
        var _meta = _article.date_str
        if (_article.feedlabel != "") _meta += "  |  " + _article.feedlabel
        draw_text(margin_x + 8, _ry + 32, _meta)

        // Author
        if (_article.author != "") {
            draw_set_color($666666)
            draw_text(margin_x + 8, _ry + 50, "by " + _article.author)
        }

        // Separator line
        draw_set_color($333333)
        draw_line(margin_x + 8, _ry + row_h - 2, margin_x + content_w - 8, _ry + row_h - 2)
    }

    gpu_set_scissor(-1, -1, -1, -1)

    // Scroll bar
    if (scroll_max > 0) {
        var _bar_area_h = view_bottom - view_top
        var _bar_h = max(30, _bar_area_h * (_bar_area_h / (_bar_area_h + scroll_max)))
        var _bar_y = view_top + (scroll / scroll_max) * (_bar_area_h - _bar_h)

        draw_set_color($333333)
        draw_rectangle(margin_x + content_w + 2, view_top, margin_x + content_w + 6, view_bottom, false)
        draw_set_color($888888)
        draw_rectangle(margin_x + content_w + 2, _bar_y, margin_x + content_w + 6, _bar_y + _bar_h, false)
    }
}

// ===== ARTICLE VIEW =====
else if (state == "article") {
    var _article = articles[selected_article]

    // Header bar with back button
    draw_set_color($2a2a2a)
    draw_rectangle(margin_x - 10, margin_y - 10, margin_x + content_w + 10, margin_y + header_h, false)
    draw_set_color($00aaff)
    draw_rectangle(margin_x - 10, margin_y + header_h, margin_x + content_w + 10, margin_y + header_h + 2, false)

    // Back button
    var _bmx = device_mouse_x_to_gui(0)
    var _bmy = device_mouse_y_to_gui(0)
    var _back_hover = (_bmx >= margin_x && _bmx <= margin_x + 120 && _bmy >= margin_y + 4 && _bmy <= margin_y + header_h)
    draw_set_color(_back_hover ? $55bbff : $aaaaaa)
    draw_text(margin_x + 4, margin_y + 4, "< BACK")

    // Article title in header
    draw_set_color(c_white)
    var _title_x = margin_x + 120
    var _title_w = content_w - 120
    draw_text_ext(_title_x, margin_y + 4, _article.title, -1, _title_w)

    // Clip region for article content
    var _content_top = view_top + 10
    var _content_bottom = view_bottom
    gpu_set_scissor(margin_x - 10, _content_top, content_w + 20, _content_bottom - _content_top)

    // Article metadata
    var _draw_y = _content_top - scroll

    draw_set_color($00aaff)
    draw_text_ext(margin_x + 8, _draw_y, _article.title, -1, content_w - 16)
    _draw_y += string_height_ext(_article.title, -1, content_w - 16) + 8

    draw_set_color($888888)
    var _meta = _article.date_str
    if (_article.author != "") _meta += "  |  " + _article.author
    if (_article.feedlabel != "") _meta += "  |  " + _article.feedlabel
    draw_text(margin_x + 8, _draw_y, _meta)
    _draw_y += 24

    // Separator after metadata
    draw_set_color($00aaff)
    draw_line(margin_x + 8, _draw_y, margin_x + content_w - 8, _draw_y)
    _draw_y += 12

    // Content blocks
    for (var i = 0; i < array_length(article_blocks); i++) {
        var _block = article_blocks[i]

        // Skip blocks that are completely off screen
        if (_draw_y + _block.height < _content_top && _block.height > 0) {
            _draw_y += _block.height
            continue
        }
        if (_draw_y > _content_bottom) break

        switch (_block.type) {
            case "text":
                draw_set_color($dddddd)
                draw_text_ext(margin_x + 8, _draw_y, _block.text, -1, content_w - 16)
                _draw_y += _block.height
                break

            case "header":
                draw_set_color($55bbff)
                draw_text_ext(margin_x + 8, _draw_y + 4, _block.text, -1, content_w - 16)
                _draw_y += _block.height
                break

            case "image":
                if (ds_map_exists(loaded_images, _block.url)) {
                    var _spr = ds_map_find_value(loaded_images, _block.url)
                    if (sprite_exists(_spr)) {
                        var _sw = sprite_get_width(_spr)
                        var _sh = sprite_get_height(_spr)
                        var _scale = min(1, (content_w - 16) / _sw)
                        draw_sprite_ext(_spr, 0, margin_x + 8, _draw_y + 4, _scale, _scale, 0, c_white, 1)
                        _draw_y += floor(_sh * _scale) + 10
                    } else {
                        _draw_y += _block.height
                    }
                } else {
                    // Placeholder
                    draw_set_color($222222)
                    draw_rectangle(margin_x + 8, _draw_y + 4, margin_x + content_w - 8, _draw_y + _block.height - 6, false)
                    draw_set_color($555555)
                    draw_rectangle(margin_x + 8, _draw_y + 4, margin_x + content_w - 8, _draw_y + _block.height - 6, true)
                    draw_set_halign(fa_center)
                    draw_set_valign(fa_middle)
                    draw_set_color($666666)
                    draw_text(512, _draw_y + _block.height / 2, "Loading image...")
                    draw_set_halign(fa_left)
                    draw_set_valign(fa_top)
                    _draw_y += _block.height
                }
                break

            case "separator":
                draw_set_color($444444)
                draw_line(margin_x + 40, _draw_y + 10, margin_x + content_w - 40, _draw_y + 10)
                _draw_y += _block.height
                break
        }
    }

    gpu_set_scissor(-1, -1, -1, -1)

    // Scroll bar
    if (scroll_max > 0) {
        var _bar_area_h = _content_bottom - _content_top
        var _bar_h = max(30, _bar_area_h * (_bar_area_h / (_bar_area_h + scroll_max)))
        var _bar_y = _content_top + (scroll / scroll_max) * (_bar_area_h - _bar_h)

        draw_set_color($333333)
        draw_rectangle(margin_x + content_w + 2, _content_top, margin_x + content_w + 6, _content_bottom, false)
        draw_set_color($888888)
        draw_rectangle(margin_x + content_w + 2, _bar_y, margin_x + content_w + 6, _bar_y + _bar_h, false)
    }
}

// Reset draw state
draw_set_alpha(1)
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
