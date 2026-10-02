/// A dated, source-linked history. The entry gate always uses current Steam DLC
/// ownership; reading position is an independent local preference, not an unlock.
function commentary_access_policy(_steam, _owns) {
    return _steam && _owns;
}
function commentary_has_access() {
    return platform_steam() && commentary_access_policy(true, tcc_steam_user_owns_dlc(1995510));
}
function commentary_source_url_valid(_url) {
    if (!is_string(_url)) return false;
    var _allowed = ["https://github.com/Infiland/TheColorfulCreature/", "https://infiland.itch.io/the-colorful-creature", "https://store.steampowered.com/app/1651680/"];
    for (var _i = 0; _i < array_length(_allowed); ++_i) if (string_pos(_allowed[_i], _url) == 1) return true;
    return false;
}
function commentary_validate(_catalog) {
    if (!is_struct(_catalog) || level_field(_catalog, "format", "") != "tcc.commentary"
        || level_field(_catalog, "schemaVersion", -1) != 1) return false;
    var _chapters = level_field(_catalog, "chapters", undefined);
    if (!is_array(_chapters) || array_length(_chapters) < 1 || array_length(_chapters) > 200) return false;
    var _seen = {}, _last_date = "";
    for (var _i = 0; _i < array_length(_chapters); ++_i) {
        var _chapter = _chapters[_i];
        var _strings = ["id", "date", "displayDate", "title", "body"];
        for (var _j = 0; _j < array_length(_strings); ++_j) {
            var _text = level_field(_chapter, _strings[_j], undefined);
            if (!is_string(_text) || _text == "") return false;
        }
        if (variable_struct_exists(_seen, _chapter.id) || _chapter.date < _last_date) return false;
        variable_struct_set(_seen, _chapter.id, true);
        _last_date = _chapter.date;
        var _sources = level_field(_chapter, "sources", undefined);
        if (!is_array(_sources) || array_length(_sources) < 1 || array_length(_sources) > 3) return false;
        for (var _j = 0; _j < array_length(_sources); ++_j) {
            var _source = _sources[_j];
            if (!is_string(level_field(_source, "title", undefined)) || !is_string(level_field(_source, "note", undefined))
                || !commentary_source_url_valid(level_field(_source, "url", ""))) return false;
        }
        var _art = level_field(_chapter, "art", undefined);
        if (!is_struct(_art) || !is_string(level_field(_art, "caption", undefined))) return false;
        var _kind = level_field(_art, "kind", "");
        if (_kind == "file") {
            var _path = level_field(_art, "path", "");
            if (_path != "Commentary/archive-2023-title.png" && _path != "Commentary/archive-2024-freedom.png") return false;
            if (!file_exists(level_bundled_path(_path))) return false;
        } else if (_kind == "sprites") {
            if (!is_array(level_field(_art, "sprites", undefined)) || array_length(_art.sprites) < 1 || array_length(_art.sprites) > 3) return false;
            for (var _j = 0; _j < array_length(_art.sprites); ++_j) {
                var _name = level_field(_art.sprites[_j], "name", "");
                var _asset = is_string(_name) ? asset_get_index(_name) : -1;
                if (_asset == -1 || asset_get_type(_asset) != asset_sprite) return false;
                var _frame = level_field(_art.sprites[_j], "frame", -1);
                if (!level_finite(_frame) || _frame < 0 || _frame >= sprite_get_number(_asset) || floor(_frame) != _frame) return false;
            }
        } else return false;
    }
    return true;
}
function commentary_read() {
    var _catalog = level_parse_json_file("Commentary/chapters.json");
    if (!commentary_validate(_catalog)) {
        show_debug_message("Commentary: the bundled catalog or artwork failed validation.");
        return undefined;
    }
    return _catalog;
}
function commentary_index(_catalog, _id) {
    for (var _i = 0; _i < array_length(_catalog.chapters); ++_i) if (_catalog.chapters[_i].id == _id) return _i;
    return 0;
}
function commentary_save_path() {
    var _directory = directory_set("/Save Files/");
    if (!directory_exists(_directory)) directory_create(_directory);
    return _directory + "Commentary.sav";
}
function commentary_position_read(_catalog, _file = "") {
    if (_file == "") _file = commentary_save_path();
    scr_save_recover(_file);
    if (!file_exists(_file)) return 0;
    ini_open(_file);
    var _id = ini_read_string("Gallery", "Chapter", "");
    ini_close();
    return commentary_index(_catalog, _id);
}
function commentary_position_write(_catalog, _index, _file = "") {
    if (_file == "") _file = commentary_save_path();
    _index = clamp(floor(_index), 0, array_length(_catalog.chapters) - 1);
    scr_save_begin(_file);
    ini_write_real("Gallery", "Version", 1);
    ini_write_string("Gallery", "Chapter", _catalog.chapters[_index].id);
    return scr_save_finish(_file);
}
function commentary_open() {
    // The gallery itself rechecks ownership. A locked entry remains discoverable.
    window_set_cursor(cr_default);
    room_goto(r_commentary);
}
function commentary_sprite_fit(_sprite, _frame, _left, _top, _width, _height) {
    if (_sprite < 0 || !sprite_exists(_sprite)) return;
    var _scale = min(_width / sprite_get_width(_sprite), _height / sprite_get_height(_sprite));
    var _x = _left + (_width - sprite_get_width(_sprite) * _scale) / 2 + sprite_get_xoffset(_sprite) * _scale;
    var _y = _top + (_height - sprite_get_height(_sprite) * _scale) / 2 + sprite_get_yoffset(_sprite) * _scale;
    draw_sprite_ext(_sprite, _frame, _x, _y, _scale, _scale, 0, c_white, 1);
}
function commentary_draw_button(_left, _top, _right, _bottom, _text, _enabled, _focused = false) {
    var _hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _left, _top, _right, _bottom);
    draw_set_color((_hover || _focused) && _enabled ? make_color_rgb(44, 48, 57) : make_color_rgb(22, 24, 30));
    draw_rectangle(_left, _top, _right, _bottom, false);
    draw_set_color(_enabled ? c_white : make_color_rgb(105, 109, 120));
    draw_rectangle(_left, _top, _right, _bottom, true);
    draw_set_font(fnt_death);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _scale = min(1, (_right - _left - 16) / max(1, string_width(_text)),
        (_bottom - _top - 12) / max(1, string_height(_text)));
    draw_text_transformed((_left + _right) / 2, (_top + _bottom) / 2, _text, _scale, _scale, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
/// Pure drawing helper, also usable by a test room without changing entitlement.
function commentary_draw_page(_catalog, _index, _art_sprite, _show_sources, _source_index) {
    var _chapter = _catalog.chapters[_index];
    var _count = array_length(_catalog.chapters);
    var _colors = [make_color_rgb(255,87,104), make_color_rgb(255,210,91), make_color_rgb(105,211,156), make_color_rgb(98,166,255), c_white];
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(12,14,19));
    draw_rectangle(0, 0, 1024, 768, false);
    draw_set_font(fnt_mainmenu);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_transformed(32, 30, "Commentary", 0.85, 0.85, 0);
    draw_set_font(fnt_death);
    draw_set_color(make_color_rgb(173,179,191));
    draw_text(32, 78, "The making of The Colorful Creature  /  2018 - 2026");
    commentary_draw_button(840, 34, 992, 78, "Back  /  Esc, B", true);
    for (var _i = 0; _i < _count; ++_i) {
        var _x = 32 + _i * (960 / _count);
        draw_set_color(_i == _index ? _colors[_index mod 5] : make_color_rgb(53,58,69));
        draw_rectangle(_x, 118, _x + 960 / _count - 6, _i == _index ? 128 : 123, false);
    }
    draw_set_font(fnt_death);
    draw_set_color(_colors[_index mod 5]);
    draw_text(32, 151, _chapter.displayDate);
    draw_set_color(c_white);
    draw_set_font(fnt_mainmenu);
    draw_text_transformed(32, 179, _chapter.title, 0.75, 0.75, 0);
    draw_set_color(make_color_rgb(23,26,34));
    draw_rectangle(32, 244, 352, 542, false);
    if (_chapter.art.kind == "file") {
        commentary_sprite_fit(_art_sprite, 0, 44, 256, 296, 274);
    } else {
        var _sprites = _chapter.art.sprites;
        var _first = asset_get_index(_sprites[0].name);
        commentary_sprite_fit(_first, _sprites[0].frame, 124, 266, 136, 136);
        if (array_length(_sprites) > 1) commentary_sprite_fit(asset_get_index(_sprites[1].name), _sprites[1].frame, 65, 416, 102, 102);
        if (array_length(_sprites) > 2) commentary_sprite_fit(asset_get_index(_sprites[2].name), _sprites[2].frame, 217, 416, 102, 102);
    }
    draw_set_font(fnt_death);
    draw_set_color(make_color_rgb(173,179,191));
    draw_text_ext(32, 559, _chapter.art.caption, 19, 320);
    if (!_show_sources) {
        draw_set_color(make_color_rgb(229,232,238));
        draw_text_ext(384, 244, _chapter.body, 24, 608);
        draw_set_color(make_color_rgb(173,179,191));
        draw_text_ext(384, 610, "Source: " + _chapter.sources[0].title, 19, 608);
    } else {
        draw_set_color(c_white);
        draw_text(384, 244, "Chapter sources");
        for (var _i = 0; _i < array_length(_chapter.sources); ++_i) {
            var _source = _chapter.sources[_i];
            var _y = 284 + _i * 99;
            draw_set_color(_source_index == _i ? _colors[_index mod 5] : c_white);
            draw_text_ext(384, _y, string(_i + 1) + ". " + _source.title, 20, 608);
            draw_set_color(make_color_rgb(173,179,191));
            draw_text_ext(404, _y + 30, _source.note, 19, 588);
        }
        commentary_draw_button(384, 603, 992, 649, "Open selected source  /  Enter, A", true);
    }
    commentary_draw_button(32, 687, 217, 734, "Previous  /  Left, LB", _index > 0);
    commentary_draw_button(625, 687, 803, 734, _show_sources ? "Read chapter / X" : "Sources  /  S, X", true);
    commentary_draw_button(823, 687, 992, 734, "Next  /  Right, RB", _index < _count - 1);
    draw_set_font(fnt_death);
    draw_set_color(c_white);
    draw_text(248, 701, "Chapter " + string(_index + 1) + " / " + string(_count));
    draw_set_color(make_color_rgb(140,146,159));
    draw_text_transformed(32, 743, _show_sources ? "Up / Down: select source     Esc / B: return to chapter" : "Choose any mark on the timeline to jump to a chapter. Reading position is saved automatically.", 0.8, 0.8, 0);
    draw_set_color(c_white);
}
function commentary_selfcheck(_directory = "") {
    var _assert = function(_ok, _why) { if (!_ok) throw "Commentary self-check: " + _why; };
    var _catalog = commentary_read();
    _assert(!is_undefined(_catalog) && array_length(_catalog.chapters) == 22, "all 22 sourced chapters and artwork are present");
    _assert(!commentary_access_policy(false, false) && !commentary_access_policy(false, true)
        && !commentary_access_policy(true, false) && commentary_access_policy(true, true), "only owned Steam DLC grants access");
    _assert(commentary_index(_catalog, "missing-chapter") == 0, "unknown saved chapter falls back to the beginning");
    if (_directory == "") _directory = game_save_id + "/CommentarySelfCheck/";
    _directory = level_directory(_directory);
    if (!directory_exists(_directory)) directory_create(_directory);
    var _file = _directory + "Commentary.sav";
    _assert(commentary_position_write(_catalog, 13, _file), "reading position writes through safe-save helpers");
    _assert(commentary_position_read(_catalog, _file) == 13, "reading position restored by stable chapter ID");
    _assert(commentary_position_write(_catalog, 21, _file), "position updates");
    _assert(commentary_position_read(_catalog, _file + ".bak") == 13, "previous reading position backup retained");
    var _bad = json_parse(json_stringify(_catalog));
    _bad.chapters[0].sources[0].url = "file:///tmp/not-a-source";
    _assert(!commentary_validate(_bad), "source actions cannot open an unapproved scheme");
    _bad = json_parse(json_stringify(_catalog));
    _bad.chapters[1].id = _bad.chapters[0].id;
    _assert(!commentary_validate(_bad), "chapter identities are unique");
    show_debug_message("TCC_COMMENTARY_SELF_CHECK_PASS chapters=22 archives=2");
    return true;
}
