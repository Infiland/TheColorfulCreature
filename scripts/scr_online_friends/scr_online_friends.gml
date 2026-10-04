// =============================================================================
// FRIENDS - Steam friends playing The Colorful Creature, for the main menu
// Friends panel (o_friendspanel). Steam keeps friends' game, lobby and rich
// presence locally, so refreshing the list costs no network request.
// =============================================================================

/// Friends currently running this game: [{id, name, lobby, status}], joinable first.
function net_friends_list() {
    var _result = [];
    if (!platform_steam() || !tcc_steam_initialised()) return _result;
    var _app = tcc_steam_get_app_id();
    var _info = tcc_steam_get_friends_game_info();
    if (!is_array(_info)) return _result;
    var _joinable = [];
    var _other = [];
    for (var _i = 0; _i < array_length(_info); ++_i) {
        var _friend = _info[_i];
        if (!is_struct(_friend)) continue;
        var _game = net_field(_friend, "gameId", 0);
        if (!net_finite(_game) || _game == 0 || _game != _app) continue;
        var _id = net_field(_friend, "friendId", int64(0));
        if (!is_numeric(_id) || _id == 0) continue;
        var _lobby = net_field(_friend, "lobbyId", int64(0));
        if (!is_numeric(_lobby)) _lobby = int64(0);
        var _entry = {id:_id, name:net_clean_name(net_field(_friend, "name", "")), lobby:_lobby, status:net_presence_text(_id)};
        if (_lobby != 0) array_push(_joinable, _entry); else array_push(_other, _entry);
    }
    for (var _i = 0; _i < array_length(_joinable); ++_i) array_push(_result, _joinable[_i]);
    for (var _i = 0; _i < array_length(_other); ++_i) array_push(_result, _other[_i]);
    return _result;
}

/// A friend's rich presence ("Endless Run - Level 12") in the player's language.
function net_presence_text(_id) {
    var _display = tcc_steam_get_friend_rich_presence(_id, "steam_display");
    if (!is_string(_display) || string_length(_display) < 2 || string_char_at(_display, 1) != "#") return "";
    var _key = "RP_" + string_delete(_display, 1, 1);
    var _text = loc(_key);
    if (_text == _key) return "";
    var _fields = ["level", "boss", "challengename", "levelname"];
    for (var _i = 0; _i < array_length(_fields); ++_i) {
        var _token = "%" + _fields[_i] + "%";
        if (string_pos(_token, _text) > 0) _text = string_replace_all(_text, _token, net_clean_name(tcc_steam_get_friend_rich_presence(_id, _fields[_i])));
    }
    return _text;
}

// -----------------------------------------------------------------------------
// Avatars: sprite >= 0, -2 while Steam is still loading it, -1 when there is none
// -----------------------------------------------------------------------------
function net_avatar_from_image(_image) {
    var _size = tcc_steam_image_get_size(_image);
    if (!is_array(_size) || array_length(_size) < 2 || _size[0] <= 0 || _size[1] <= 0 || _size[0] > 512 || _size[1] > 512) return -1;
    var _bytes = _size[0] * _size[1] * 4;
    var _buffer = buffer_create(_bytes, buffer_fixed, 1);
    var _sprite = -1;
    if (tcc_steam_image_get_rgba(_image, _buffer, _bytes)) {
        var _surface = surface_create(_size[0], _size[1]);
        buffer_set_surface(_buffer, _surface, 0);
        _sprite = sprite_create_from_surface(_surface, 0, 0, _size[0], _size[1], false, false, 0, 0);
        surface_free(_surface);
    }
    buffer_delete(_buffer);
    return _sprite;
}

function net_avatar_sprite(_id) {
    if (!variable_global_exists("net_avatars")) global.net_avatars = ds_map_create();
    var _key = string(_id);
    if (ds_map_exists(global.net_avatars, _key)) return global.net_avatars[? _key];
    var _image = tcc_steam_get_user_avatar(_id, steam_user_avatar_size_medium);
    var _sprite = -1;
    if (net_finite(_image) && _image > 0) _sprite = net_avatar_from_image(_image);
    else if (_image == -1) _sprite = -2;	// arrives with "avatar_image_loaded"
    global.net_avatars[? _key] = _sprite;
    return _sprite;
}

function net_friends_avatar_loaded(_map) {
    if (!variable_global_exists("net_avatars")) return;
    var _key = string(_map[? "user_id"]);
    if (!ds_map_exists(global.net_avatars, _key) || global.net_avatars[? _key] != -2) return;
    var _image = _map[? "image"];
    global.net_avatars[? _key] = (net_finite(_image) && _image > 0) ? net_avatar_from_image(_image) : -1;
}

function net_avatars_free() {
    if (!variable_global_exists("net_avatars")) return;
    var _key = ds_map_find_first(global.net_avatars);
    while (!is_undefined(_key)) {
        var _sprite = global.net_avatars[? _key];
        if (_sprite >= 0 && sprite_exists(_sprite)) sprite_delete(_sprite);
        _key = ds_map_find_next(global.net_avatars, _key);
    }
    ds_map_destroy(global.net_avatars);
}

function net_draw_avatar(_id, _x, _y, _size, _alpha) {
    var _sprite = net_avatar_sprite(_id);
    if (_sprite >= 0 && sprite_exists(_sprite)) {
        draw_sprite_stretched_ext(_sprite, 0, _x, _y, _size, _size, c_white, _alpha);
    } else {
        draw_set_color($333333);
        draw_rectangle(_x, _y, _x + _size, _y + _size, false);
    }
}

// -----------------------------------------------------------------------------
// Friends panel (runs in o_friendspanel's scope)
// -----------------------------------------------------------------------------
function net_friends_button(_x0, _y0, _x1, _y1, _label, _action, _arg = undefined, _enabled = true) {
    return {x0:_x0, y0:_y0, x1:_x1, y1:_y1, label:_label, action:_action, arg:_arg, enabled:_enabled, clip:false};
}

/// Status line describing this player's own online session.
function net_friends_session_text() {
    if (!platform_steam() || !tcc_steam_initialised()) return loc("NET_STEAM_REQUIRED");
    if (global.onlinemultiplayersettings != 1) return loc("NET_ONLINE_DISABLED");
    if (global.net_connect_state == 2 || global.net_pending_join != -1 || global.net_join_pending_id != -1) return loc("NET_CONNECTING");
    if (!global.net_active) return loc("NET_SESSION_STARTING");
    if (global.net_is_host) return string_replace(loc("NET_SESSION_HOSTING"), "{COUNT}", string(net_member_count()));
    return string_replace(string_replace(loc("NET_SESSION_JOINED"), "{NAME}", net_clean_name(tcc_steam_lobby_get_data("host_name"))),
        "{COUNT}", string(net_member_count()));
}

function net_friends_panel_layout() {
    buttons = [];
    var _x = px0 + 20;
    var _y = py0 + 56;
    array_push(buttons, net_friends_button(px1 - 44, py0 + 6, px1 - 8, py0 + 38, "X", "close"));
    session_y = _y;
    var _steam = platform_steam() && tcc_steam_initialised();
    var _by = _y + 30;
    if (_steam && global.onlinemultiplayersettings != 1) {
        array_push(buttons, net_friends_button(_x, _by, _x + 200, _by + 30, loc("NET_ENABLE_ONLINE"), "enable"));
    } else if (_steam) {
        array_push(buttons, net_friends_button(_x, _by, _x + 170, _by + 30, loc("NET_INVITE"), "invite", undefined, global.net_active));
        _x += 182;
        array_push(buttons, net_friends_button(_x, _by, _x + 170, _by + 30, loc("NET_STEAM_FRIENDS"), "overlay", undefined, tcc_steam_is_overlay_enabled()));
        _x += 182;
        if (global.net_active && !global.net_is_host) {
            array_push(buttons, net_friends_button(_x, _by, _x + 170, _by + 30, loc("NET_GO_TO_HOST"), "gotohost"));
            _x += 182;
        }
        if (global.net_active && (!global.net_is_host || net_member_count() > 1)) {
            array_push(buttons, net_friends_button(_x, _by, _x + 170, _by + 30, loc("NET_LEAVE_SESSION"), "leave"));
        }
    }
    // Members of our session (up to four lines).
    members_y = _by + 42;
    var _shown = min(4, global.net_active ? array_length(global.net_member_list) : 0);
    friends_y = members_y + max(1, _shown) * 20 + (global.net_active && array_length(global.net_member_list) > 4 ? 20 : 0) + 10;
    list_top = friends_y + 30;
    list_bottom = py1 - 36;
    var _rows = array_length(friends);
    scroll_max = max(0, _rows * row_h - (list_bottom - list_top));
    for (var _i = 0; _i < _rows; ++_i) {
        var _friend = friends[_i];
        var _ry = list_top + _i * row_h - scroll;
        if (_ry + row_h < list_top || _ry > list_bottom) continue;
        var _mine = global.net_active && _friend.lobby != 0 && _friend.lobby == global.net_lobby_id;
        if (_friend.lobby != 0 && !_mine) {
            var _button = net_friends_button(px1 - 150, _ry + 12, px1 - 20, _ry + 44, loc("NET_JOIN"), "join", _friend.lobby, _steam);
            _button.clip = true;
            array_push(buttons, _button);
        }
        var _profile = net_friends_button(px0 + 16, _ry + 4, px1 - 160, _ry + row_h - 4, "", "profile", _friend.id);
        _profile.clip = true;
        array_push(buttons, _profile);
    }
}

function net_friends_panel_hover(_mx, _my) {
    for (var _i = 0; _i < array_length(buttons); ++_i) {
        var _b = buttons[_i];
        if (_b.clip && (_my < list_top || _my >= list_bottom)) continue;
        if (point_in_rectangle(_mx, _my, _b.x0, _b.y0, _b.x1, _b.y1)) return _i;
    }
    return -1;
}

function net_friends_panel_action(_button) {
    if (!_button.enabled) return;
    switch (_button.action) {
        case "close": close_requested = true; break;
        case "enable":
            global.onlinemultiplayersettings = 1;
            scr_savesettings();
            break;
        case "invite": tcc_steam_lobby_activate_invite_overlay(); break;
        case "overlay": tcc_steam_activate_overlay(ov_friends); break;
        case "profile": tcc_steam_activate_overlay_user("steamid", _button.arg); break;
        case "gotohost":
            if (net_follow_now()) close_requested = true;
            break;
        case "leave":
            net_leave_lobby(true);
            break;
        case "join":
            if (net_request_join(_button.arg)) close_requested = true;
            break;
    }
}

function net_friends_draw_button(_b, _hovered) {
    if (_b.action == "profile") {
        if (_hovered) {
            draw_set_color($2a2a3a);
            draw_rectangle(_b.x0, _b.y0, _b.x1, _b.y1, false);
        }
        return;
    }
    draw_set_color(_hovered && _b.enabled ? $3a3a5a : $2a2a2a);
    draw_rectangle(_b.x0, _b.y0, _b.x1, _b.y1, false);
    draw_set_color(_hovered && _b.enabled ? $00aaff : $555555);
    draw_rectangle(_b.x0, _b.y0, _b.x1, _b.y1, true);
    draw_set_color(_b.enabled ? c_white : $666666);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _scale = _b.action == "close" ? 1 : 0.8;
    draw_text_transformed((_b.x0 + _b.x1) / 2, (_b.y0 + _b.y1) / 2, _b.label, _scale, _scale, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function net_friends_panel_draw() {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    draw_set_alpha(0.85 * overlay_alpha);
    draw_rectangle_color(0, 0, 1024, 768, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(overlay_alpha);
    draw_set_color($1a1a1a);
    draw_rectangle(px0, py0, px1, py1, false);
    draw_set_color($444444);
    draw_rectangle(px0, py0, px1, py1, true);
    draw_set_color($2a2a2a);
    draw_rectangle(px0, py0, px1, py0 + 44, false);
    draw_set_color($00aaff);
    draw_rectangle(px0, py0 + 44, px1, py0 + 46, false);

    draw_set_font(global.deathfont);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text((px0 + px1) / 2, py0 + 10, loc("NET_FRIENDS_TITLE"));
    draw_set_halign(fa_left);

    // Our session
    draw_set_color($00aaff);
    draw_text_transformed(px0 + 20, session_y, loc("NET_YOUR_SESSION"), 0.8, 0.8, 0);
    draw_set_color($cccccc);
    draw_text_transformed(px0 + 220, session_y, net_friends_session_text(), 0.8, 0.8, 0);
    var _line = members_y;
    if (global.net_active) {
        var _members = global.net_member_list;
        if (array_length(_members) == 0) {
            draw_set_color($888888);
            draw_text_transformed(px0 + 20, _line, loc("NET_SESSION_EMPTY"), 0.7, 0.7, 0);
        }
        for (var _i = 0; _i < min(4, array_length(_members)); ++_i) {
            var _peer = global.net_players[? string(_members[_i])];
            var _name = is_struct(_peer) ? _peer.username : net_clean_name(tcc_steam_get_user_persona_name_sync(_members[_i]));
            var _where = loc("NET_MEMBER_MENU");
            if (is_struct(_peer) && _peer.level_key != "") _where = (_peer.level_key == global.net_level_key) ? loc("NET_MEMBER_HERE") : loc("NET_MEMBER_PLAYING");
            var _text = _name + ((_members[_i] == global.net_owner_id) ? " (" + loc("NET_HOST") + ")" : "") + "  -  " + _where;
            if (is_struct(_peer) && _peer.rtt >= 0) _text += "  -  " + string(round(_peer.rtt)) + " ms";
            net_draw_avatar(_members[_i], px0 + 20, _line, 16, overlay_alpha);
            draw_set_color(c_white);
            draw_text_transformed(px0 + 44, _line, _text, 0.7, 0.7, 0);
            _line += 20;
        }
        if (array_length(_members) > 4) {
            draw_set_color($888888);
            draw_text_transformed(px0 + 44, _line, string_replace(loc("NET_MORE_MEMBERS"), "{COUNT}", string(array_length(_members) - 4)), 0.7, 0.7, 0);
        }
    }

    // Friends playing The Colorful Creature
    draw_set_color($00aaff);
    draw_text_transformed(px0 + 20, friends_y, loc("NET_FRIENDS_PLAYING"), 0.8, 0.8, 0);
    draw_rectangle(px0 + 16, friends_y + 24, px1 - 16, friends_y + 25, false);
    var _hover = net_friends_panel_hover(_mx, _my);
    gpu_set_scissor(px0 + 1, list_top, px1 - px0 - 2, list_bottom - list_top);
    for (var _i = 0; _i < array_length(buttons); ++_i) if (buttons[_i].action == "profile") net_friends_draw_button(buttons[_i], _hover == _i);
    if (array_length(friends) == 0) {
        draw_set_color($888888);
        draw_set_halign(fa_center);
        draw_text_transformed((px0 + px1) / 2, list_top + 40,
            (platform_steam() && tcc_steam_initialised()) ? loc("NET_NO_FRIENDS_PLAYING") : loc("NET_STEAM_REQUIRED"), 0.8, 0.8, 0);
        draw_set_halign(fa_left);
    }
    for (var _i = 0; _i < array_length(friends); ++_i) {
        var _friend = friends[_i];
        var _ry = list_top + _i * row_h - scroll;
        if (_ry + row_h < list_top || _ry > list_bottom) continue;
        net_draw_avatar(_friend.id, px0 + 24, _ry + 8, 40, overlay_alpha);
        draw_set_color(c_white);
        draw_text_transformed(px0 + 76, _ry + 8, _friend.name, 0.9, 0.9, 0);
        var _status = _friend.status;
        if (global.net_active && _friend.lobby != 0 && _friend.lobby == global.net_lobby_id) _status = loc("NET_IN_YOUR_SESSION");
        else if (_status == "") _status = loc("NET_PLAYING_TCC");
        draw_set_color($aaaaaa);
        draw_text_transformed(px0 + 76, _ry + 30, _status, 0.7, 0.7, 0);
        if (_friend.lobby == 0) {
            draw_set_color($666666);
            draw_set_halign(fa_right);
            draw_text_transformed(px1 - 24, _ry + 20, loc("NET_NOT_JOINABLE"), 0.7, 0.7, 0);
            draw_set_halign(fa_left);
        }
    }
    for (var _i = 0; _i < array_length(buttons); ++_i) if (buttons[_i].clip && buttons[_i].action != "profile") net_friends_draw_button(buttons[_i], _hover == _i);
    gpu_set_scissor(-1, -1, -1, -1);
    if (scroll_max > 0) {
        var _track = list_bottom - list_top;
        var _bar = max(24, _track * _track / (_track + scroll_max));
        var _bar_y = list_top + (_track - _bar) * (scroll / scroll_max);
        draw_set_color($555555);
        draw_rectangle(px1 - 8, _bar_y, px1 - 4, _bar_y + _bar, false);
    }
    for (var _i = 0; _i < array_length(buttons); ++_i) if (!buttons[_i].clip) net_friends_draw_button(buttons[_i], _hover == _i);

    draw_set_color($888888);
    draw_set_halign(fa_center);
    draw_text_transformed((px0 + px1) / 2, py1 - 28, loc("NET_OVERLAY_HINT"), 0.65, 0.65, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_alpha(1);
}
