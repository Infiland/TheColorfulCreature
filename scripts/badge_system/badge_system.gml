/// @function badge_init()
/// @description Initialize the badge system
function badge_init() {
    global.badges = ds_map_create();
    global.badge_order = ds_list_create();
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
    ds_list_add(global.badge_order, id);
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
    ds_list_destroy(global.badge_order);
    ds_map_destroy(global.badge_positions);
}

/// @function badge_draw_row(x, y, spacing)
/// @param {real} x X position to start drawing
/// @param {real} y Y position to draw at
/// @param {real} spacing Spacing between badges
/// @returns {real} Width of all drawn badges
function badge_draw_row(x, y, spacing) {
    var total_width = 0;

    for (var i = 0; i < ds_list_size(global.badge_order); i++) {
        var key = global.badge_order[| i];
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

/// @function badge_check_dlc_ownership()
/// @description Check Steam DLC ownership and return results
/// @returns {struct} Struct with game1, dlc1, dlc1_1, dlc2, dlc3, moni, actualmoni
function badge_check_dlc_ownership() {
    var result = { game1: 0, dlc1: 0, dlc1_1: 0, dlc2: 0, dlc3: 0, moni: 0, actualmoni: 0 };
    if (!global.steam_is_available) return result;

    if (steam_user_owns_dlc(1651680)) { result.game1 = 1; } // Game
    if (steam_user_owns_dlc(1749590)) { result.dlc1 = 1; } // TCC OST
    if (steam_user_owns_dlc(1749600)) { result.dlc1 = 1; result.dlc1_1 = 1; } // TCC Super OST
    if (steam_user_owns_dlc(1995510)) { result.dlc2 = 1; } // Commentary DLC
    if (steam_user_owns_dlc(2407300)) { result.dlc3 = 1; } // Asteroids

    if (steam_user_owns_dlc(2411810)) { result.moni = 1; result.actualmoni += 2; } // $2 Donation
    if (steam_user_owns_dlc(2411811)) { result.moni = 1; result.actualmoni += 3; } // $3 Donation
    if (steam_user_owns_dlc(2411812)) { result.moni = 1; result.actualmoni += 5; } // $5 Donation

    return result;
}

/// @function badge_load_seasonal_rankings()
/// @description Load seasonal endless run rankings from JSON for the current Steam user
/// @returns {struct} Struct with e1, e2, e3, e4, hats (all default 0)
function badge_load_seasonal_rankings() {
    var result = { e1: 0, e2: 0, e3: 0, e4: 0, hats: 0 };
    if (!global.steam_is_available) return result;

    var _file = program_directory + "/Other/seasonal_rankings.json";
    if (!file_exists(_file)) return result;

    var _data = LoadJSONFromFile(_file);
    if (is_undefined(_data)) return result;

    var userid = steam_get_user_steam_id();
    if (ds_map_exists(_data, "rankings")) {
        var _rankings = _data[? "rankings"];
        if (ds_map_exists(_rankings, userid)) {
            var _entry = _rankings[? userid];
            if (ds_map_exists(_entry, "e1")) result.e1 = _entry[? "e1"];
            if (ds_map_exists(_entry, "e2")) result.e2 = _entry[? "e2"];
            if (ds_map_exists(_entry, "e3")) result.e3 = _entry[? "e3"];
            if (ds_map_exists(_entry, "e4")) result.e4 = _entry[? "e4"];
            if (ds_map_exists(_entry, "hats")) result.hats = _entry[? "hats"];
        }
    }
    ds_map_destroy(_data);
    return result;
}

/// @function badge_update_all(game1, dlc1, dlc1_1, dlc2, dlc3, actualmoni, e1, e2, e3, e4, hats)
/// @description Update all badge counts based on ownership and ranking data
function badge_update_all(game1, dlc1, dlc1_1, dlc2, dlc3, actualmoni, e1, e2, e3, e4, hats) {
    // Game badge
    badge_set_count("game", game1);

    // DLC badges - super OST takes precedence over regular OST
    if (dlc1_1 > 0) {
        badge_set_count("super_ost", 1);
        badge_set_count("ost", 0);
    } else if (dlc1 > 0) {
        badge_set_count("ost", 1);
        badge_set_count("super_ost", 0);
    } else {
        badge_set_count("ost", 0);
        badge_set_count("super_ost", 0);
    }

    badge_set_count("commentary", dlc2);
    badge_set_count("asteroids", dlc3);

    // Donation badges - only show the highest tier
    badge_set_count("donation_2", 0);
    badge_set_count("donation_3", 0);
    badge_set_count("donation_5", 0);
    badge_set_count("donation_7", 0);
    badge_set_count("donation_8", 0);
    badge_set_count("donation_10", 0);

    switch(actualmoni) {
        case 2: badge_set_count("donation_2", 1); break;
        case 3: badge_set_count("donation_3", 1); break;
        case 5: badge_set_count("donation_5", 1); break;
        case 7: badge_set_count("donation_7", 1); break;
        case 8: badge_set_count("donation_8", 1); break;
        case 10: badge_set_count("donation_10", 1); break;
    }

    // Achievement badges
    badge_set_count("gold", e1);
    badge_set_count("silver", e2);
    badge_set_count("bronze", e3);
    badge_set_count("top10", e4);
    badge_set_count("community_hat", hats);
}