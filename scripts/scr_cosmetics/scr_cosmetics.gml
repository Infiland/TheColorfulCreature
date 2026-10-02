// Imported PNGs are visual assets only. Never use them as collision masks.
function cosmetics_enabled() {
    return !platform_mobile() && (os_type == os_windows || os_type == os_macosx || os_type == os_linux);
}
function cosmetics_defaults() {
    if (!variable_global_exists("CUSTOMskin")) global.CUSTOMskin = "";
    if (!variable_global_exists("CUSTOMhat")) global.CUSTOMhat = "";
    if (!variable_global_exists("CUSTOMitem")) global.CUSTOMitem = "";
    if (!variable_global_exists("customskinautoscale")) global.customskinautoscale = 1;
    if (!variable_global_exists("customhatautoscale")) global.customhatautoscale = 1;
    if (!variable_global_exists("customitemautoscale")) global.customitemautoscale = 1;
    if (!variable_global_exists("cosmetic_assets")) global.cosmetic_assets = [];
    if (!variable_global_exists("cosmetics_revision")) global.cosmetics_revision = 0;
}
function cosmetics_folder(_kind) {
    var _folder = "Player Skins";
    if (_kind == "hat") _folder = "Player Hats";
    if (_kind == "item") _folder = "Player Items";
    return directory_set("/Custom/" + _folder + "/");
}
function cosmetics_ensure_folders() {
    if (!cosmetics_enabled()) return;
    var _root = directory_set("/Custom/");
    if (!directory_exists(_root)) directory_create(_root);
    var _kinds = ["skin", "hat", "item"];
    for (var _i = 0; _i < 3; ++_i) {
        var _path = cosmetics_folder(_kinds[_i]);
        if (!directory_exists(_path)) directory_create(_path);
    }
}
function cosmetics_valid_name(_name) {
    if (!is_string(_name)) return false;
    var _length = string_length(_name);
    if (_length <= 4 || _length > 240) return false;
    // chr(0) is an empty string on the native VM; searching for it rejects every
    // filename. Check character codes instead, without platform path rewriting.
    for (var _i = 1; _i <= _length; ++_i) {
        var _character = string_char_at(_name,_i);
        if (ord(_character) < 32 || string_pos(_character,"/\\:") > 0) return false;
    }
    return string_lower(string_copy(_name,_length-3,4)) == ".png";
}
function cosmetics_be32(_buffer, _offset) {
    return buffer_peek(_buffer, _offset, buffer_u8) * 16777216
        + buffer_peek(_buffer, _offset + 1, buffer_u8) * 65536
        + buffer_peek(_buffer, _offset + 2, buffer_u8) * 256
        + buffer_peek(_buffer, _offset + 3, buffer_u8);
}
function cosmetics_png_header(_buffer, _frames) {
    var _result = {ok:false, reason:"Invalid PNG image.", width:0, height:0};
    if (_buffer < 0 || buffer_get_size(_buffer) < 33) return _result;
    var _signature = [137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82];
    for (var _i = 0; _i < 16; ++_i) if (buffer_peek(_buffer, _i, buffer_u8) != _signature[_i]) return _result;
    var _width = cosmetics_be32(_buffer,16), _height = cosmetics_be32(_buffer,20);
    if (_width < 1 || _height < 1 || _width mod _frames != 0) {
        _result.reason = _frames == 9 ? "Skin width must divide into 9 equal frames." : "Image dimensions must be positive.";
        return _result;
    }
    if (_width / _frames > 1024 || _height > 1024 || _width * _height > 4194304) {
        _result.reason = "Image too large: maximum 1024 pixels per frame side and 4 million pixels total.";
        return _result;
    }
    _result.ok = true;
    _result.width = _width / _frames;
    _result.height = _height;
    _result.reason = "";
    return _result;
}
function cosmetics_validate(_kind, _name, _folder = undefined) {
    var _invalid = {ok:false, reason:"Choose a PNG file in the custom folder.", width:0, height:0};
    if (!cosmetics_enabled() || !cosmetics_valid_name(_name)) return _invalid;
    var _path = (is_undefined(_folder) ? cosmetics_folder(_kind) : _folder) + _name;
    if (!file_exists(_path) || directory_exists(_path)) { _invalid.reason = "Image file is missing."; return _invalid; }
    var _file = file_bin_open(_path, 0);
    if (_file < 0) { _invalid.reason = "Image could not be opened."; return _invalid; }
    var _bytes = file_bin_size(_file);
    file_bin_close(_file);
    if (_bytes < 33 || _bytes > 16777216) { _invalid.reason = "PNG must be smaller than 16 MB."; return _invalid; }
    var _buffer = buffer_load(_path);
    var _result = cosmetics_png_header(_buffer, _kind == "skin" ? 9 : 1);
    if (_result.ok && !cosmetics_png_complete(_buffer)) {
        _result.ok = false;
        _result.reason = "PNG is incomplete or damaged. Export it again.";
    }
    if (_buffer >= 0) buffer_delete(_buffer);
    return _result;
}
// At most three unused assets are retained between player deaths/menu previews.
// Live references are never evicted, including when another multiplayer player dies.
function cosmetics_prune(_keep_unused = 3) {
    cosmetics_defaults();
    var _unused = 0;
    for (var _i = array_length(global.cosmetic_assets) - 1; _i >= 0; --_i) {
        var _entry = global.cosmetic_assets[_i];
        if (_entry.refs > 0) continue;
        _unused += 1;
        if (_unused > _keep_unused) {
            if (sprite_exists(_entry.sprite)) sprite_delete(_entry.sprite);
            array_delete(global.cosmetic_assets, _i, 1);
        }
    }
}
function cosmetics_acquire(_kind, _name, _folder = undefined) {
    cosmetics_defaults();
    if (!cosmetics_enabled() || !cosmetics_valid_name(_name)) return undefined;
    var _path = (is_undefined(_folder) ? cosmetics_folder(_kind) : _folder) + _name;
    var _key = _kind + "|" + _path + "|" + string(global.cosmetics_revision);
    for (var _i = 0; _i < array_length(global.cosmetic_assets); ++_i) {
        var _existing = global.cosmetic_assets[_i];
        if (_existing.key == _key && sprite_exists(_existing.sprite)) {
            if (!file_exists(_path)) return undefined;
            _existing.refs += 1;
            return _existing;
        }
    }
    var _info = cosmetics_validate(_kind, _name, _folder);
    if (!_info.ok) return undefined;
    var _sprite = -1;
    try {
        _sprite = sprite_add(_path, _kind == "skin" ? 9 : 1, false, false, 0, 0);
    } catch (_error) { _sprite = -1; }
    if (!sprite_exists(_sprite)) return undefined;
    if (sprite_get_width(_sprite) != _info.width || sprite_get_height(_sprite) != _info.height
        || sprite_get_number(_sprite) != (_kind == "skin" ? 9 : 1)) {
        sprite_delete(_sprite);
        return undefined;
    }
    if (_kind == "hat") sprite_set_offset(_sprite, _info.width / 2, _info.height);
    if (_kind == "item") sprite_set_offset(_sprite, 0, _info.height / 2);
    var _entry = {key:_key, name:_name, sprite:_sprite, width:_info.width, height:_info.height, refs:1};
    array_push(global.cosmetic_assets, _entry);
    cosmetics_prune();
    return _entry;
}
function cosmetics_release(_entry) {
    if (!is_struct(_entry)) return;
    _entry.refs = max(0, _entry.refs - 1);
    cosmetics_prune();
}
// This is called in Create/Step, never Draw. A failed request is retried only
// after a selection change or browser Refresh, not on every rendered frame.
function cosmetics_bind(_kind, _name) {
    cosmetics_defaults();
    var _field = "cosmetic_" + _kind + "_ref";
    var _request_field = "cosmetic_" + _kind + "_request";
    var _request = cosmetics_folder(_kind) + string(_name) + "|" + string(global.cosmetics_revision);
    var _old = variable_instance_exists(id, _field) ? variable_instance_get(id, _field) : undefined;
    if (variable_instance_exists(id, _request_field) && variable_instance_get(id, _request_field) == _request) return _old;
    cosmetics_release(_old);
    var _asset = cosmetics_acquire(_kind, _name);
    variable_instance_set(id, _field, _asset);
    variable_instance_set(id, _request_field, _request);
    return _asset;
}
function cosmetics_player_init(_allow_skin = true, _allow_hat = true, _allow_item = true) {
    cosmetics_defaults();
    scr_moddingskins(_allow_skin ? global.CUSTOMskin : "");
    scr_moddinghats(_allow_hat ? global.CUSTOMhat : "");
    cosmetics_item_init(_allow_item ? global.CUSTOMitem : "");
}
function cosmetics_item_init(_name) {
    customitem = 0;
    customitem_spr = -1;
    customitemxscale = 1;
    customitemyscale = 1;
    var _asset = cosmetics_bind("item", _name);
    if (!is_struct(_asset)) return false;
    customitem = 1;
    customitem_spr = _asset.sprite;
    if (global.customitemautoscale == 1) {
        var _scale = min(24 / _asset.width, 16 / _asset.height);
        customitemxscale = _scale;
        customitemyscale = _scale;
    }
    return true;
}
function cosmetics_player_cleanup() {
    var _kinds = ["skin", "hat", "item"];
    for (var _i = 0; _i < 3; ++_i) {
        var _field = "cosmetic_" + _kinds[_i] + "_ref";
        if (variable_instance_exists(id, _field)) cosmetics_release(variable_instance_get(id, _field));
        variable_instance_set(id, _field, undefined);
        variable_instance_set(id, "cosmetic_" + _kinds[_i] + "_request", "");
    }
}
// Cached skin sprites keep their top-left origin. Zero gravity rotates around
// the normal player's 16-pixel pivot without changing a shared sprite resource.
function cosmetics_draw_skin() {
    var _draw_x = x, _draw_y = y;
    if (zerogrv == 1) {
        _draw_x -= lengthdir_x(16 * image_xscale, image_angle)
            + lengthdir_x(16 * image_yscale, image_angle - 90);
        _draw_y -= lengthdir_y(16 * image_xscale, image_angle)
            + lengthdir_y(16 * image_yscale, image_angle - 90);
    }
    draw_sprite_ext(customskin_spr, image_index, _draw_x, _draw_y,
        skinxscale * image_xscale, skinyscale * image_yscale,
        image_angle, image_blend, image_alpha);
}
function cosmetics_selected(_kind) { return variable_global_get("CUSTOM" + _kind); }
function cosmetics_select(_kind, _name) {
    variable_global_set("CUSTOM" + _kind, _name);
    switch (_kind) { case "skin": scr_saveskins(); break; case "hat": scr_savehats(); break; case "item": scr_saveitems(); break; }
}
function cosmetics_browser_open() {
    return instance_exists(o_choosecustomskins) || instance_exists(o_choosecustomhats) || instance_exists(o_choosecustomitems);
}
function cosmetics_browser_refresh() {
    cosmetics_release(preview_asset);
    preview_asset = undefined;
    preview_name = "";
    global.cosmetics_revision += 1;
    files = [];
    var _folder = cosmetics_folder(cosmetic_kind);
    var _name = file_find_first(_folder + "*", fa_directory);
    while (_name != "") {
        if (cosmetics_valid_name(_name) && !directory_exists(_folder + _name)) array_push(files, _name);
        _name = file_find_next();
    }
    file_find_close();
    array_sort(files, true);
    maxpage = max(1, ceil(array_length(files) / 15));
    page = clamp(page, 1, maxpage);
    browser_status = "";
    cosmetics_prune(0);
}
function cosmetics_browser_create(_kind) {
    cosmetics_defaults();
    cosmetic_kind = _kind;
    files = [];
    page = 1;
    maxpage = 1;
    preview_asset = undefined;
    preview_name = "";
    browser_status = "";
    browser_hover = -1;
    if (!cosmetics_enabled()) { instance_destroy(); exit; }
    cosmetics_ensure_folders();
    instance_deactivate_object(o_allskinbuttons);
    instance_deactivate_object(o_allhatbuttons);
    instance_deactivate_object(o_allitembuttons);
    cosmetics_browser_refresh();
}
function cosmetics_browser_step() {
    if (timing_keyboard_pressed(vk_escape)) { instance_destroy(); exit; }
    var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
    var _cx = display_get_gui_width() / 2;
    var _rx = display_get_gui_width() - 174;
    var _press = timing_mouse_pressed(mb_left);
    if (timing_keyboard_pressed(vk_right) || (_press && point_in_rectangle(_mx,_my,_cx+100,695,_cx+190,730))) page = min(maxpage, page + 1);
    if (timing_keyboard_pressed(vk_left) || (_press && point_in_rectangle(_mx,_my,_cx-190,695,_cx-100,730))) page = max(1, page - 1);
    if (timing_keyboard_pressed(ord("R")) || (_press && point_in_rectangle(_mx,_my,_rx,300,_rx+150,340))) cosmetics_browser_refresh();
    if (_press && point_in_rectangle(_mx,_my,_rx,30,_rx+150,80)) { cosmetics_select(cosmetic_kind, ""); browser_status = ""; }
    if (_press && point_in_rectangle(_mx,_my,_rx,100,_rx+150,150)) {
        var _autoscale = "custom" + cosmetic_kind + "autoscale";
        variable_global_set(_autoscale, 1 - variable_global_get(_autoscale));
        scr_savesettings();
    }
    if (_press && point_in_rectangle(_mx,_my,_rx,355,_rx+150,395)) {
        clipboard_set_text(cosmetics_folder(cosmetic_kind));
        browser_status = "Folder path copied.";
    }
    browser_hover = -1;
    var _start = (page - 1) * 15;
    var _count = min(15, array_length(files) - _start);
    for (var _row = 0; _row < _count; ++_row) {
        if (point_in_rectangle(_mx,_my,_cx-300,85+_row*40,_cx+300,115+_row*40)) {
            browser_hover = _start + _row;
            if (_press) {
                var _chosen = cosmetics_acquire(cosmetic_kind, files[browser_hover]);
                if (is_struct(_chosen)) {
                    cosmetics_select(cosmetic_kind, files[browser_hover]);
                    browser_status = "";
                    cosmetics_release(_chosen);
                } else {
                    var _info = cosmetics_validate(cosmetic_kind, files[browser_hover]);
                    browser_status = _info.ok ? "PNG could not be decoded. Try exporting it again." : _info.reason;
                }
            }
            break;
        }
    }
    var _preview = browser_hover >= 0 ? files[browser_hover] : cosmetics_selected(cosmetic_kind);
    if (_preview != preview_name) {
        cosmetics_release(preview_asset);
        preview_asset = cosmetics_acquire(cosmetic_kind, _preview);
        preview_name = _preview;
    }
}
function cosmetics_draw_preview(_asset, _x, _y, _size = 100, _frame = 0) {
    if (!is_struct(_asset) || !sprite_exists(_asset.sprite)) return;
    var _scale = min(_size / _asset.width, _size / _asset.height);
    var _ox = sprite_get_xoffset(_asset.sprite), _oy = sprite_get_yoffset(_asset.sprite);
    draw_sprite_ext(_asset.sprite, _frame, _x + (_ox - _asset.width / 2) * _scale,
        _y + (_oy - _asset.height / 2) * _scale, _scale, _scale, 0, c_white, 1);
}
function cosmetics_browser_draw() {
    var _width = display_get_gui_width(), _height = display_get_gui_height();
    var _cx = _width / 2, _rx = _width - 174;
    var _selected = cosmetics_selected(cosmetic_kind);
    draw_set_alpha(0.9); draw_set_color(c_black); draw_rectangle(0,0,_width,_height,false);
    draw_set_alpha(1); draw_set_font(global.deathfont); draw_set_halign(fa_center); draw_set_valign(fa_top);
    draw_set_color(c_white); draw_text(_cx,30,settings_text("Custom " + cosmetic_kind + "s"));
    var _start = (page - 1) * 15, _count = min(15,array_length(files)-_start);
    for (var _row = 0; _row < _count; ++_row) {
        var _i = _start + _row, _top = 85 + _row * 40;
        var _color = files[_i] == _selected ? c_lime : (_i == browser_hover ? c_yellow : c_white);
        draw_set_color(c_black); draw_rectangle(_cx-300,_top,_cx+300,_top+30,false);
        draw_set_color(_color); draw_rectangle(_cx-300,_top,_cx+300,_top+30,true);
        var _scale = min(1,580/max(1,string_width(files[_i])));
        draw_text_transformed(_cx,_top+2,files[_i],_scale,1,0);
    }
    var _labels = ["Deselect", "Autoscale", "Refresh", "Copy folder path"];
    var _tops = [30,100,300,355], _bottoms = [80,150,340,395];
    for (var _b = 0; _b < 4; ++_b) {
        draw_set_color(c_black); draw_rectangle(_rx,_tops[_b],_rx+150,_bottoms[_b],false);
        var _on = (_b == 0 && _selected == "") || (_b == 1 && variable_global_get("custom"+cosmetic_kind+"autoscale") == 1);
        draw_set_color(_on ? c_lime : c_white); draw_rectangle(_rx,_tops[_b],_rx+150,_bottoms[_b],true);
        draw_text(_rx+75,_tops[_b]+10,settings_text(_labels[_b]));
    }
    cosmetics_draw_preview(preview_asset,_rx+75,215,90,cosmetic_kind == "skin" ? floor(current_time/350) mod 9 : 0);
    draw_set_color(c_white);
    if (array_length(files) == 0) {
        draw_text(_cx,310,settings_text("No custom PNG files yet."));
        draw_text(_cx,345,cosmetic_kind == "skin" ? "Use 9 equal frames in a horizontal strip (288 x 32 recommended)." : "Use one PNG image with a transparent background.");
        draw_text(_cx,385,settings_text("Copy the folder path, add files, then press Refresh."));
    }
    draw_text(_cx-145,700,"< " + settings_text("Previous"));
    draw_text(_cx+145,700,settings_text("Next") + " >");
    draw_text(_cx,700,string(page)+" / "+string(maxpage));
    draw_set_color(browser_status == "" ? c_white : c_yellow);
    draw_text(_cx,735,browser_status == "" ? settings_text("Arrow keys change pages. Esc closes. R refreshes.") : browser_status);
    draw_set_color(c_white); draw_set_halign(fa_left); draw_set_valign(fa_top);
}
function cosmetics_browser_cleanup() {
    global.cosmetic_browser_closed_at = current_time;
    cosmetics_release(preview_asset);
    if (room == r_skinmenu) {
        switch (global.customizeselect) {
            case 1: timing_activate_object(o_allskinbuttons); break;
            case 2: timing_activate_object(o_allhatbuttons); break;
            case 3: timing_activate_object(o_allitembuttons); break;
        }
    }
}
function scr_cosmetics_selfcheck() {
    scr_port_assert(cosmetics_valid_name("example.PNG"), "ordinary mixed-case PNG filename accepted");
    scr_port_assert(!cosmetics_valid_name("../outside.png") && !cosmetics_valid_name("folder\\outside.png"), "cosmetic filenames stay within PNG folder");
    scr_port_assert(!cosmetics_valid_name("readme.txt") && !cosmetics_valid_name(".png") && !cosmetics_valid_name("line"+chr(10)+"break.png"), "invalid filename extension and control characters rejected");
    var _buffer = buffer_create(33, buffer_fixed, 1);
    var _header = [137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,1,32,0,0,0,32];
    for (var _i = 0; _i < array_length(_header); ++_i) buffer_poke(_buffer,_i,buffer_u8,_header[_i]);
    var _valid = cosmetics_png_header(_buffer,9);
    scr_port_assert(_valid.ok && _valid.width == 32 && _valid.height == 32, "nine-frame 288x32 skin accepted");
    buffer_poke(_buffer,19,buffer_u8,33);
    var _invalid = cosmetics_png_header(_buffer,9);
    scr_port_assert(!_invalid.ok, "uneven frame strip rejected");
    buffer_poke(_buffer,16,buffer_u8,127);
    _invalid = cosmetics_png_header(_buffer,1);
    scr_port_assert(!_invalid.ok, "oversized image rejected before decode");
    buffer_poke(_buffer,0,buffer_u8,0);
    _invalid = cosmetics_png_header(_buffer,1);
    scr_port_assert(!_invalid.ok, "fake PNG rejected");
    buffer_delete(_buffer);
    show_debug_message("TCC_COSMETICS_PASS");
}

function cosmetics_browser_consume_back() {
    if (cosmetics_browser_open()) {
        with (o_choosecustomskins) instance_destroy();
        with (o_choosecustomhats) instance_destroy();
        with (o_choosecustomitems) instance_destroy();
        return true;
    }
    return variable_global_exists("cosmetic_browser_closed_at") && global.cosmetic_browser_closed_at == current_time;
}

// Reject incomplete chunk streams before calling the native image decoder.
function cosmetics_png_complete(_buffer) {
    var _size = buffer_get_size(_buffer), _offset = 8;
    var _has_pixels = false;
    while (_offset + 12 <= _size) {
        var _length = cosmetics_be32(_buffer, _offset);
        if (_length > _size - _offset - 12) return false;
        var _type = cosmetics_be32(_buffer, _offset + 4);
        if (_type == $49484452 && (_offset != 8 || _length != 13)) return false; // IHDR
        if (_type == $49444154 && _length > 0) _has_pixels = true; // IDAT
        if (_type == $49454E44) return _has_pixels && _length == 0 && _offset + 12 == _size; // IEND
        _offset += _length + 12;
    }
    return false;
}

// Check configuration only: decode real PNGs and exercise legacy INIs using an
// explicit scratch directory. This also works before scr_loading has run.
function scr_cosmetics_runtime_selfcheck() {
    if (!TCC_SELF_CHECK) return;
    var _rules = settings_validation_rules();
    var _names = [], _values = [];
    for (var _i = 0; _i < array_length(_rules); ++_i) array_push(_names,_rules[_i][0]);
    var _keyboard_names = settings_keyboard_names(), _gp_names = gamepad_remap_names();
    for (var _j = 0; _j < 6; ++_j) { array_push(_names,_keyboard_names[_j]); array_push(_names,_gp_names[_j]); }
    var _extra = ["CUSTOMskin","CUSTOMhat","CUSTOMitem","cheats","itemselected","itemnameobjectselected","gp_remap_listening","gp_remap_device","gp_active_device","gp_remap_cancelled_at","gp_remap_releasing","gp_remap_release_device","editcontrols"];
    for (var _k = 0; _k < array_length(_extra); ++_k) array_push(_names,_extra[_k]);
    for (var _n = 0; _n < array_length(_names); ++_n) {
        array_push(_values,variable_global_exists(_names[_n]) ? variable_global_get(_names[_n]) : undefined);
    }
    var _old_items = variable_global_exists("item") ? global.item : undefined;
    var _savedir = game_save_id + "/PortSelfCheck/CosmeticsSettings_" + string(current_time) + "/";
    var _suffix = 0;
    while (directory_exists(_savedir)) { ++_suffix; _savedir = game_save_id + "/PortSelfCheck/CosmeticsSettings_" + string(current_time) + "_" + string(_suffix) + "/"; }
    directory_create(game_save_id + "/PortSelfCheck/");
    directory_create(_savedir);
    cosmetics_defaults();
    scr_settings_validate();
    global.cheats = 0;
    global.item = [0,1,1,1];
    global.itemselected = 0;
    global.itemnameobjectselected = o_unequipeditembutton;
    global.CUSTOMitem = "fixture.png";

    global.customsplashessettings = 1;
    global.customhatautoscale = 0;
    global.customskinautoscale = 0;
    global.customitemautoscale = 0;
    global.devcommentarysettings = 1;
    global.musicvolume = 0.37;
    global.mastervolume = 2;
    global.soundvolume = -1;
    global.netmaxplayers = 999;
    global.renderfps = 75;
    global.controlsmoveleft = "37";
    gamepad_remap_set(0,gp_face3);
    gamepad_remap_set(2,gp_start);
    gamepad_remap_set(4,gp_select);
    scr_port_assert(scr_savesettings(_savedir), "settings transaction creates an isolated INI");
    ini_open(_savedir + "Settings.sav");
    scr_port_assert(ini_read_real("ControllerBindings","Jump",-1) == gp_start, "Start binding is actually written to the settings file");
    ini_close();
    global.customhatautoscale = 1;
    global.musicvolume = 0;
    gamepad_remap_set(0,gp_padr);
    gamepad_remap_set(2,gp_face1);
    gamepad_remap_set(4,gp_face4);
    scr_loadsettings(_savedir);
    scr_port_assert(global.customhatautoscale == 0 && global.customsplashessettings == 1, "Hats Autoscale loads independently of Custom Splashes");
    scr_port_assert(global.customskinautoscale == 0 && global.customitemautoscale == 0 && global.devcommentarysettings == 1, "cosmetic scale and commentary preferences round trip");
    // GameMaker applies a comparison epsilon. A strict '< 0.00001' can be false
    // even for zero error; use a tolerance above it and the INI's six decimals.
    scr_port_assert(abs(global.musicvolume-0.37) <= 0.0001, "saved music volume round trip: " + string(global.musicvolume));
    scr_port_assert(global.mastervolume == 1 && global.soundvolume == 0 && global.netmaxplayers == 256,
        "saved numeric ranges round trip: " + json_stringify([global.mastervolume,global.soundvolume,global.netmaxplayers]));
    scr_port_assert(global.renderfps == 75 && global.maxfps == TCC_SIM_HZ, "render cap persists while gameplay retains fixed 60 Hz on every platform");
    scr_port_assert(gamepad_remap_get(0) == gp_face3 && gamepad_remap_get(2) == gp_start && gamepad_remap_get(4) == gp_select,
        "custom bindings, including Start and Back, survive the actual save/load round trip");
    scr_port_assert(gamepad_remap_pause_button() == gp_stickr, "Pause moves to an unused button after loading Start and Back bindings");
    scr_port_assert(settings_keyboard_code(global.controlsmoveleft) == vk_left, "legacy keyboard arrow survives INI round trip");
    global.musicvolume = 0.61;
    scr_port_assert(scr_savesettings(_savedir), "settings replacement creates backup");
    file_delete(_savedir + "Settings.sav");
    scr_loadsettings(_savedir);
    scr_port_assert(abs(global.musicvolume-0.37) <= 0.0001, "interrupted settings save restores prior backup");
    settings_fps_runtime_selfcheck(_savedir);

    ini_open(_savedir + "Items.sav");
    ini_write_real("Items","Selected Item",2);
    ini_write_real("Skins","Item Name Object Selected",o_floweritembutton);
    ini_write_string("CustomItem","Custom Item","fixture.png");
    ini_close();
    scr_loaditems(_savedir);
    scr_port_assert(global.itemselected == 2 && global.itemnameobjectselected == o_floweritembutton && global.CUSTOMitem == "fixture.png", "legacy wrong-section item selection migrates");
    scr_port_assert(scr_saveitems(_savedir), "item transaction succeeds");
    ini_open(_savedir + "Items.sav");
    var _stored_item = ini_read_real("Items","Item Name Object Selected",-1);
    var _stored_custom = ini_read_string("CustomItem","Custom Item","");
    ini_close();
    scr_port_assert(_stored_item == o_floweritembutton && _stored_custom == "fixture.png", "new item save uses Items section and retains custom filename");

    if (cosmetics_enabled()) {
        var _skin_data = "iVBORw0KGgoAAAANSUhEUgAAASAAAAAgCAYAAACy9KU0AAABnElEQVR4nMXOMYEDQAgAMKQgBSkoeA1IQQpCOpyTb11kyJ6Iz1/8/CuJFdbYYIsd9rDQdCCxwhobbLHDHhaaDiRWWGODLXbYw0LTgcQKa2ywxQ57WGg6kFhhjQ222GEPC00HEiusscEWO+xhoelAYoU1Nthihz0sNB1IrLDGBlvssIeFpgOJFdbYYIsd9rDQdCCxwhobbLHDHhaaDiRWWGODLXbYw0LTgcQKa2ywxQ57WGg6kFhhjQ222GEPC00HEiusscEWO+xhoelAYoU1Nthihz0sNB1IrLDGBlvssIeFpgOJFdbYYIsd9rDQdCCxwhobbLHDHhaaDiRWWGODLXbYw0LTgcQKa2ywxQ57WGg6kFhhjQ222GEPC00HEiusscEWO+xhoelAYoU1Nthihz0sNB1IrLDGBlvssIeFpgOJFdbYYIsd9rDQdCCxwhobbLHDHhaaDiRWWGODLXbYw0LTgcQKa2ywxQ57WGg6kFhhjQ222GEPC00HEiusscEWO+xhoelAYoU1Nthihz0sNB1IrLDGBlvssIcF9gVUSkiiGQgo4wAAAABJRU5ErkJggg==";
        var _hat_data = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAMCAYAAABr5z2BAAAAG0lEQVR4nGNguJPHAMT/ycYUaR41YNSAQWMAAJfctdHdOFdVAAAAAElFTkSuQmCC";
        var _item_data = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAICAYAAADjoT9jAAAAG0lEQVR4nGNguJPHAMT/aYZpavioBaMWUAUDAC4ntdGWx05qAAAAAElFTkSuQmCC";
        var _data = [_skin_data,_hat_data,_item_data];
        var _files = ["skin.png","hat.png","item.png"];
        for (var _p = 0; _p < 3; ++_p) {
            var _buffer = buffer_base64_decode(_data[_p]);
            buffer_save(_buffer,_savedir+_files[_p]);
            buffer_delete(_buffer);
        }
        var _skin_a = cosmetics_acquire("skin","skin.png",_savedir);
        var _skin_b = cosmetics_acquire("skin","skin.png",_savedir);
        scr_port_assert(is_struct(_skin_a) && is_struct(_skin_b), "actual PNG skin decodes");
        scr_port_assert(_skin_a.sprite == _skin_b.sprite && _skin_a.refs == 2 && sprite_get_number(_skin_a.sprite) == 9, "players share one nine-frame sprite");
        var _skin_sprite = _skin_a.sprite;
        cosmetics_release(_skin_a);
        scr_port_assert(_skin_b.refs == 1 && sprite_exists(_skin_b.sprite), "one player's cleanup preserves another player's sprite");
        cosmetics_release(_skin_b);
        cosmetics_prune(0);
        scr_port_assert(!sprite_exists(_skin_sprite), "final reference permits native sprite deletion");
        var _respawn = cosmetics_acquire("skin","skin.png",_savedir);
        scr_port_assert(is_struct(_respawn) && _respawn.refs == 1 && sprite_exists(_respawn.sprite)
            && sprite_get_number(_respawn.sprite) == 9, "respawn reacquires a valid sprite after the prior cache entry was deleted");
        var _revision = global.cosmetics_revision;
        global.cosmetics_revision += 1;
        var _refreshed = cosmetics_acquire("skin","skin.png",_savedir);
        scr_port_assert(is_struct(_refreshed) && _refreshed.sprite != _respawn.sprite && sprite_exists(_respawn.sprite),
            "refresh creates a new sprite while the prior player still owns its original");
        cosmetics_release(_respawn); cosmetics_prune(0);
        scr_port_assert(sprite_exists(_refreshed.sprite), "old revision cleanup cannot delete the new player's sprite");
        cosmetics_release(_refreshed); cosmetics_prune(0);
        global.cosmetics_revision = _revision;
        var _hat = cosmetics_acquire("hat","hat.png",_savedir);
        var _item = cosmetics_acquire("item","item.png",_savedir);
        scr_port_assert(is_struct(_hat) && is_struct(_item) && _hat.sprite != _item.sprite, "hat and item PNGs decode independently");
        scr_port_assert(sprite_get_number(_hat.sprite) == 1 && sprite_get_xoffset(_hat.sprite) == 8 && sprite_get_yoffset(_hat.sprite) == 12, "hat uses fixed center-bottom attachment origin");
        scr_port_assert(sprite_get_number(_item.sprite) == 1 && sprite_get_xoffset(_item.sprite) == 0 && sprite_get_yoffset(_item.sprite) == 4, "item uses fixed held-item attachment origin");
        cosmetics_release(_hat); cosmetics_release(_item); cosmetics_prune(0);
        scr_port_assert(is_undefined(cosmetics_acquire("skin","missing.png",_savedir)), "missing image falls back without creating a sprite");
        var _truncated = buffer_base64_decode(_skin_data);
        buffer_save_ext(_truncated,_savedir+"truncated.png",0,33);
        buffer_delete(_truncated);
        var _invalid = cosmetics_validate("skin","truncated.png",_savedir);
        scr_port_assert(!_invalid.ok && is_undefined(cosmetics_acquire("skin","truncated.png",_savedir)), "truncated PNG rejected before native decode");
        for (var _f = 0; _f < 3; ++_f) file_delete(_savedir+_files[_f]);
        file_delete(_savedir+"truncated.png");
        show_debug_message("TCC_COSMETICS_DECODE_CACHE_PASS");
    }
    for (var _r = 0; _r < array_length(_names); ++_r) variable_global_set(_names[_r],_values[_r]);
    settings_fps_apply_rate();
    global.item = _old_items;
    var _saves = ["Settings.sav","Settings.sav.bak","Settings.sav.pending","Items.sav","Items.sav.bak","Items.sav.pending"];
    for (var _s = 0; _s < array_length(_saves); ++_s) if (file_exists(_savedir+_saves[_s])) file_delete(_savedir+_saves[_s]);
    directory_destroy(_savedir);
    show_debug_message("TCC_SETTINGS_PERSISTENCE_PASS");
}
