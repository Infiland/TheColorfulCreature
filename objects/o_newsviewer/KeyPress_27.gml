/// @description ESC - back or close

if (state == "article") {
    // Go back to list view
    state = "list"
    scroll = 0
    scroll_target = 0
    selected_article = -1
    article_blocks = []
    // Recalculate list scroll max
    var _total = array_length(articles) * row_h
    if (can_load_more) _total += load_more_h
    scroll_max = max(0, _total - (view_bottom - view_top))
} else {
    instance_destroy()
}
