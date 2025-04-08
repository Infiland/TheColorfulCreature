/// @function badge_init()
/// @description Initialize the badge system
function badge_init() {
    global.badges = ds_map_create();
    global.badge_positions = ds_map_create();
}

/// @function badge_create(id, sprite, sprite_index, name, description, colors)
/// @param {string} id Unique identifier for the badge
/// @param {sprite} sprite Sprite resource to use
/// @param {real} sprite_index Index of the sprite to use
/// @param {string} name Display name of the badge
/// @param {string} description Description of the badge
/// @param {array} colors Array of two colors [primary, secondary]
function badge_create(id, sprite, sprite_index, name, description, colors) {
    var badge = {
        id: id,
        sprite: sprite,
        sprite_index: sprite_index,
        name: name,
        description: description,
        colors: colors,
        count: 0,
        visible: true
    };
    
    ds_map_add(global.badges, id, badge);
    return badge;
}

/// @function badge_set_count(id, count)
/// @param {string} id Badge identifier
/// @param {real} count Badge count (0 = not owned, 1+ = owned with count)
function badge_set_count(id, count) {
    var badge = ds_map_find_value(global.badges, id);
    if (badge != undefined) {
        badge.count = count;
    }
}

/// @function badge_set_visible(id, visible)
/// @param {string} id Badge identifier
/// @param {bool} visible Whether the badge should be visible
function badge_set_visible(id, visible) {
    var badge = ds_map_find_value(global.badges, id);
    if (badge != undefined) {
        badge.visible = visible;
    }
}

/// @function badge_get_count(id)
/// @param {string} id Badge identifier
/// @returns {real} Count of the badge (0 if not owned)
function badge_get_count(id) {
    var badge = ds_map_find_value(global.badges, id);
    if (badge != undefined) {
        return badge.count;
    }
    return 0;
}

/// @function badge_is_owned(id)
/// @param {string} id Badge identifier
/// @returns {bool} True if badge is owned
function badge_is_owned(id) {
    return badge_get_count(id) > 0;
}

/// @function badge_cleanup()
/// @description Clean up badge system resources
function badge_cleanup() {
    ds_map_destroy(global.badges);
    ds_map_destroy(global.badge_positions);
}

/// @function badge_draw_row(x, y, spacing)
/// @param {real} x X position to start drawing
/// @param {real} y Y position to draw at
/// @param {real} spacing Spacing between badges
/// @returns {real} Width of all drawn badges
function badge_draw_row(x, y, spacing) {
    var orig_x = x;
    var total_width = 0;
    var key = ds_map_find_first(global.badges);
    
    while (!is_undefined(key)) {
        var badge = global.badges[? key];
        
        if (badge.visible && badge.count > 0) {
            draw_sprite(badge.sprite, badge.sprite_index, x, y);
            
            // Store position for mouse hover detection
            var pos = {
                x1: x,
                y1: y,
                x2: x + sprite_get_width(badge.sprite),
                y2: y + sprite_get_height(badge.sprite),
                badge_id: key
            };
            ds_map_add(global.badge_positions, key, pos);
            
            // Draw count if more than 1
            if (badge.count > 1) {
                draw_text(x + 30, y + 14, string(badge.count));
            }
            
            x += spacing;
            total_width += spacing;
        }
        
        key = ds_map_find_next(global.badges, key);
    }
    
    return total_width;
}

/// @function badge_draw_infobox(x, y, badge_id)
/// @param {real} x X position to draw
/// @param {real} y Y position to draw
/// @param {string} badge_id Badge identifier
function badge_draw_infobox(x, y, badge_id) {
    var badge = global.badges[? badge_id];
    
    if (badge != undefined) {
        draw_set_font(global.deathfont);
        draw_set_alpha(0.2);
        draw_rectangle_color(
            x + 320, y - 110, 
            x, y, 
            badge.colors[0], badge.colors[1], 
            badge.colors[0], badge.colors[1], 
            false
        );
        draw_set_alpha(1);
        draw_text_ext(x + 300, y - 100, badge.description, 30, 300);
        draw_set_font(global.coolfont);
    }
}

/// @function badge_check_hover(mouse_x, mouse_y)
/// @param {real} mouse_x Mouse X position
/// @param {real} mouse_y Mouse Y position
/// @returns {string} Badge ID that is being hovered, or undefined if none
function badge_check_hover(mouse_x, mouse_y) {
    var key = ds_map_find_first(global.badge_positions);
    
    while (!is_undefined(key)) {
        var pos = global.badge_positions[? key];
        
        if (point_in_rectangle(mouse_x, mouse_y, pos.x1, pos.y1, pos.x2, pos.y2)) {
            return key;
        }
        
        key = ds_map_find_next(global.badge_positions, key);
    }
    
    return undefined;
}

/// @function badge_reset_positions()
/// @description Reset badge positions (call before drawing badges each frame)
function badge_reset_positions() {
    ds_map_clear(global.badge_positions);
} 