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

// Image queue processing
if (!loading_image && array_length(image_queue) > 0) {
    var _url = image_queue[0]
    array_delete(image_queue, 0, 1)

    if (!ds_map_exists(loaded_images, _url)) {
        var _spr = sprite_add(_url, 0, false, true, 0, 0)
        if (_spr < 0) {
            // Failed immediately, skip to next
            loading_image = false
        } else {
            ds_map_add(pending_images, _spr, _url)
            loading_image = true
        }
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

// List view - click detection
if (state == "list" && mouse_check_button_pressed(mb_left)) {
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

// Article view - back button click
if (state == "article" && mouse_check_button_pressed(mb_left)) {
    if (_mx >= margin_x && _mx <= margin_x + 120 && _my >= margin_y + 4 && _my <= margin_y + header_h) {
        event_perform(ev_keypress, vk_escape)
    }
}
