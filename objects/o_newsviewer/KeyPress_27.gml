/// @description ESC - back or close

if (state == "article") {
    // Go back to list view
    state = "list"
    scroll = 0
    scroll_target = 0
    selected_article = -1
    article_blocks = []
    // Recalculate list scroll max
    scroll_max = max(0, array_length(articles) * row_h - (768 - margin_y * 2 - header_h - 20))
} else {
    instance_destroy()
}
