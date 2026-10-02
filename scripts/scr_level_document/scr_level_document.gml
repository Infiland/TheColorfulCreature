/// One level codec for the editor, packaged challenges and Workshop.
/// Reads are side-effect free. Only an explicit level_write migrates a legacy file.
// GameMaker exporters lowercase included-file paths on some targets. Limit
// fallback to our known relative bundle roots; never alter user/Workshop paths.
function level_bundled_path(_path) {
    if (!is_string(_path) || _path == "") return _path;
    if (file_exists(_path)) return _path;
    var _normalized = string_replace_all(_path, "\\", "/");
    var _slash = string_pos("/", _normalized);
    if (_slash < 2) return _path;
    var _root = string_lower(string_copy(_normalized, 1, _slash - 1));
    if (_root != "challenges" && _root != "calendar" && _root != "commentary") return _path;
    if (string_pos("../", _normalized) > 0 || string_pos("/..", _normalized) > 0) return _path;
    var _lower = string_lower(_normalized);
    var _bundled_names = [_lower, string_replace_all(_lower, " ", "_")];
    // The virtual included-file table may normalize spaces even where a native
    // export's physical resource copy retains them. Logical level IDs stay intact.
    for (var _name = 0; _name < array_length(_bundled_names); ++_name) if (file_exists(_bundled_names[_name])) return _bundled_names[_name];
    // Only the relative bundled roots above may fall back to their exported
    // resource directory. Absolute user/Workshop paths never reach this branch.
    var _roots = [program_directory, working_directory];
    for (var _i = 0; _i < array_length(_roots); ++_i) {
        var _base = string_replace_all(_roots[_i], "\\", "/");
        if (string_char_at(_base, string_length(_base)) != "/") _base += "/";
        for (var _name = 0; _name < array_length(_bundled_names); ++_name) {
            var _candidate = _base + _bundled_names[_name];
            if (file_exists(_candidate)) return _candidate;
        }
    }
    return _path;
}

function level_directory(_directory) {
    if (!is_string(_directory) || _directory == "") return "";
    var _path = string_replace_all(_directory, "\\", "/");
    if (string_char_at(_path, string_length(_path)) != "/") _path += "/";
    return _path;
}

function level_error(_message) {
    global.level_last_error = _message;
    show_debug_message("Level document: " + _message);
    return undefined;
}

function level_field(_value, _key, _fallback) {
    if (is_struct(_value) && variable_struct_exists(_value, _key)) return variable_struct_get(_value, _key);
    return _fallback;
}

function level_finite(_value) {
    return is_numeric(_value) && !is_nan(_value) && !is_infinity(_value);
}

function level_metadata_defaults() {
    return {
        name: "", text: "", music: "0", editorVersion: 2, startingColor: 0,
        background: 0, starRotation: 0, diamondTime: 35, widthBlocks: 32,
        heightBlocks: 22, blockStyle: 0, starStyle: 0, fog: 0,
        publishId: "0", workshopVersion: 0
    };
}

function level_document_defaults() {
    return {format: "tcc.level", schemaVersion: 1, metadata: level_metadata_defaults(), instances: []};
}

function level_is_slope(_name) {
    return is_string(_name) && string_pos("slope", _name) > 0;
}

/// Concrete palette entries only: never load an arbitrary project object by name.
function level_registry() {
    static _registry = undefined;
    if (!is_undefined(_registry)) return _registry;
    _registry = {};
    var _names = [
        "o_HspikemovingdownLE",
        "o_HspikemovingleftLE",
        "o_HspikemovingrightLE",
        "o_HspikemovingupLE",
        "o_ammoLE",
        "o_ammoinfiniteLE",
        "o_blueblock",
        "o_blueblockbackground",
        "o_blueblockbackgroundslope",
        "o_blueblockbreakableLE",
        "o_blueblockbrickbackground",
        "o_blueblockmoveLE",
        "o_blueblockslope",
        "o_blueitemLE",
        "o_bluepassblock",
        "o_bluespiralLE",
        "o_boxLE",
        "o_boxbackground",
        "o_boxblockbackgroundslope",
        "o_boxwithammoLE",
        "o_boxwithinfiniteammoLE",
        "o_deathblock",
        "o_deathblockbackground",
        "o_deathblockbackgroundslope",
        "o_door",
        "o_doublejumpitemLE",
        "o_enemyplayerLE",
        "o_gravity01LE",
        "o_gravity05LE",
        "o_gravity15LE",
        "o_gravity25LE",
        "o_gravitylimit01",
        "o_gravitylimit05",
        "o_gravitylimit15",
        "o_gravitylimit25",
        "o_greenblock",
        "o_greenblockbackground",
        "o_greenblockbackgroundslope",
        "o_greenblockbreakableLE",
        "o_greenblockbrickbackground",
        "o_greenblockmoveLE",
        "o_greenblockslope",
        "o_greenitemLE",
        "o_greenpassblock",
        "o_greenspiralLE",
        "o_gunLE",
        "o_iceblock",
        "o_iceblockbackground",
        "o_iceblockbackgroundslope",
        "o_invisibleblueblock",
        "o_invisiblegreenblock",
        "o_invisibleredblock",
        "o_invisiblewhiteblock",
        "o_invisibleyellowblock",
        "o_invspike",
        "o_invspikeleft",
        "o_invspikeright",
        "o_invspiketop",
        "o_keyLE",
        "o_ladder",
        "o_lava",
        "o_lockedblock",
        "o_lockeddoor",
        "o_onewaydownblock",
        "o_onewayleftblock",
        "o_onewayrightblock",
        "o_onewayupblock",
        "o_oxygenitemLE",
        "o_playerspawner",
        "o_portalpurpleclosed",
        "o_portalpurpleopen",
        "o_redblock",
        "o_redblockbackground",
        "o_redblockbackgroundslope",
        "o_redblockbreakableLE",
        "o_redblockbrickbackground",
        "o_redblockmoveLE",
        "o_redblockslope",
        "o_reditemLE",
        "o_redpassblock",
        "o_redspiralLE",
        "o_rocketlauncher",
        "o_rocketlauncherright",
        "o_shooter",
        "o_shooterright",
        "o_specialcoinLE",
        "o_speed10LE",
        "o_speed15LE",
        "o_speed5LE",
        "o_speed7LE",
        "o_speedlimit10",
        "o_speedlimit15",
        "o_speedlimit5",
        "o_speedlimit7",
        "o_spike",
        "o_spikebackground",
        "o_spikebackgroundhorizontal",
        "o_spikebackgroundvertical",
        "o_spikeleft",
        "o_spikemovingdownupLE",
        "o_spikemovingleftrightLE",
        "o_spikemovingrightleftLE",
        "o_spikemovingupdownLE",
        "o_spikeright",
        "o_spiketop",
        "o_torchLE",
        "o_unlockedblock",
        "o_water",
        "o_whiteblock",
        "o_whiteblockbackground",
        "o_whiteblockbackgroundslope",
        "o_whiteblockbreakableLE",
        "o_whiteblockbrickbackground",
        "o_whiteblockmoveLE",
        "o_whiteblockslope",
        "o_whiteitemLE",
        "o_whitepassblock",
        "o_whitespiralLE",
        "o_yellowblock",
        "o_yellowblockbackground",
        "o_yellowblockbackgroundslope",
        "o_yellowblockbreakableLE",
        "o_yellowblockbrickbackground",
        "o_yellowblockmoveLE",
        "o_yellowblockslope",
        "o_yellowitemLE",
        "o_yellowpassblock",
        "o_yellowspiralLE",
        "o_zerogravityLE",
        "o_zerogravitylimit"
    ];
    for (var _i = 0; _i < array_length(_names); ++_i) {
        var _asset = asset_get_index(_names[_i]);
        if (_asset != -1 && asset_get_type(_asset) == asset_object) variable_struct_set(_registry, _names[_i], _asset);
    }
    return _registry;
}

function level_object(_name) {
    return level_field(level_registry(), _name, -1);
}

// Keep the wire ID canonical and within the positive signed-int64 range used
// by the installed Steam extension. Never round a decimal ID through a double.
function level_publish_id_valid(_value) {
    if (!is_string(_value)) return false;
    var _length = string_length(_value);
    if (_length < 1 || _length > 19 || (_length > 1 && string_char_at(_value, 1) == "0")) return false;
    var _maximum = "9223372036854775807";
    var _comparison = 0;
    for (var _i = 1; _i <= _length; ++_i) {
        var _digit = ord(string_char_at(_value, _i));
        if (_digit < 48 || _digit > 57) return false;
        if (_length == 19 && _comparison == 0) _comparison = sign(_digit - ord(string_char_at(_maximum, _i)));
    }
    return _comparison <= 0;
}

// JSON object member order and the numeric spelling chosen by json_stringify
// may change after parsing. Arrays are ordered; object fields are compared by key.
function level_json_equal(_left, _right, _depth = 0) {
    if (_depth > 64) return false;
    if (is_struct(_left)) {
        if (!is_struct(_right)) return false;
        var _keys = variable_struct_get_names(_left);
        if (array_length(_keys) != array_length(variable_struct_get_names(_right))) return false;
        for (var _i = 0; _i < array_length(_keys); ++_i) {
            var _key = _keys[_i];
            if (!variable_struct_exists(_right, _key)
                || !level_json_equal(variable_struct_get(_left, _key), variable_struct_get(_right, _key), _depth + 1)) return false;
        }
        return true;
    }
    if (is_array(_left)) {
        if (!is_array(_right) || array_length(_left) != array_length(_right)) return false;
        for (var _i = 0; _i < array_length(_left); ++_i) if (!level_json_equal(_left[_i], _right[_i], _depth + 1)) return false;
        return true;
    }
    if (is_struct(_right) || is_array(_right)) return false;
    if (is_undefined(_left)) return is_undefined(_right);
    if (is_string(_left)) return is_string(_right) && _left == _right;
    if (is_numeric(_left)) return is_numeric(_right) && _left == _right;
    return _left == _right;
}

function level_validate(_document) {
    var _bad = function(_why) { return {valid: false, error: _why}; };
    if (!is_struct(_document)) return _bad("The level must be a JSON object.");
    if (level_field(_document, "format", "") != "tcc.level") return _bad("Unknown level format.");
    if (level_field(_document, "schemaVersion", -1) != 1) return _bad("Unsupported level schema version.");
    var _metadata = level_field(_document, "metadata", undefined);
    if (!is_struct(_metadata)) return _bad("Missing level metadata.");
    var _text_fields = ["name", "text", "music", "publishId"];
    for (var _i = 0; _i < array_length(_text_fields); ++_i) {
        if (!is_string(level_field(_metadata, _text_fields[_i], undefined))) return _bad("Invalid metadata: " + _text_fields[_i]);
    }
    if (string_length(_metadata.name) > 256 || string_length(_metadata.text) > 65536 || string_length(_metadata.music) > 256) return _bad("Level text is too long.");
    // Steam identifiers remain strings on disk to avoid a JSON double losing precision.
    if (!level_publish_id_valid(_metadata.publishId)) return _bad("Invalid Workshop identifier; expected a canonical non-negative signed 64-bit decimal string.");
    var _number_fields = ["editorVersion", "startingColor", "background", "starRotation", "diamondTime", "widthBlocks", "heightBlocks", "blockStyle", "starStyle", "fog", "workshopVersion"];
    for (var _i = 0; _i < array_length(_number_fields); ++_i) {
        if (!level_finite(level_field(_metadata, _number_fields[_i], undefined))) return _bad("Invalid metadata: " + _number_fields[_i]);
    }
    if (_metadata.widthBlocks < 1 || _metadata.widthBlocks > 1000 || floor(_metadata.widthBlocks) != _metadata.widthBlocks
        || _metadata.heightBlocks < 1 || _metadata.heightBlocks > 1000 || floor(_metadata.heightBlocks) != _metadata.heightBlocks) return _bad("Invalid level dimensions.");
    if (_metadata.startingColor < 0 || _metadata.startingColor > 4 || floor(_metadata.startingColor) != _metadata.startingColor) return _bad("Invalid starting color.");
    if (_metadata.diamondTime < 0 || _metadata.workshopVersion < 0 || _metadata.editorVersion < 1) return _bad("Invalid level version or medal time.");
    if (_metadata.background < 0 || _metadata.background > 2 || _metadata.fog < 0 || _metadata.fog > 1) return _bad("Invalid scenery setting.");
    var _instances = level_field(_document, "instances", undefined);
    if (!is_array(_instances) || array_length(_instances) > 50000) return _bad("Missing or oversized instance list.");
    var _fields = ["x", "y", "imageindex", "xscale", "yscale", "orientation"];
    for (var _i = 0; _i < array_length(_instances); ++_i) {
        var _entry = _instances[_i];
        if (!is_struct(_entry)) return _bad("Invalid instance " + string(_i) + ".");
        var _name = level_field(_entry, "obj", "");
        if (!is_string(_name) || level_object(_name) == -1) return _bad("Unsupported editor object: " + string(_name));
        for (var _j = 0; _j < array_length(_fields); ++_j) {
            if (!level_finite(level_field(_entry, _fields[_j], undefined))) return _bad("Invalid " + _fields[_j] + " on instance " + string(_i) + ".");
        }
        // Keep the saved coordinates, including the existing 64px editor HUD offset.
        // Test zero explicitly: the runner's comparison epsilon can make
        // (abs(0) < 0.00001) false when the threshold equals its default epsilon.
        if (abs(_entry.x) > 1048576 || abs(_entry.y) > 1048576 || abs(_entry.imageindex) > 1000000
            || _entry.xscale == 0 || _entry.yscale == 0
            || abs(_entry.xscale) < 0.00001 || abs(_entry.yscale) < 0.00001
            || abs(_entry.xscale) > 1024 || abs(_entry.yscale) > 1024) return _bad("Unsafe instance transform at " + string(_i) + ".");
        if (_entry.orientation < 0 || _entry.orientation > 3 || floor(_entry.orientation) != _entry.orientation) return _bad("Invalid slope orientation.");
    }
    return {valid: true, error: ""};
}

function level_parse_json_file(_filename) {
    if (!is_string(_filename) || _filename == "") return level_error("Missing JSON filename.");
    _filename = level_bundled_path(_filename);
    if (!file_exists(_filename)) return undefined;
    var _buffer = buffer_load(_filename);
    if (_buffer < 0) return level_error("Could not open " + _filename);
    var _size = buffer_get_size(_buffer);
    if (_size > 16777216) {
        buffer_delete(_buffer);
        return level_error("Level file exceeds 16 MiB: " + _filename);
    }
    // buffer_string requires a terminator. Standard UTF-8 JSON has no NUL,
    // whereas legacy SaveStringToFile did include one. Read both safely by
    // appending our own terminator in a separate buffer without editing the file.
    var _terminated = buffer_create(_size + 1, buffer_fixed, 1);
    if (_size > 0) buffer_copy(_buffer, 0, _size, _terminated, 0);
    buffer_poke(_terminated, _size, buffer_u8, 0);
    buffer_delete(_buffer);
    var _document = undefined;
    try {
        buffer_seek(_terminated, buffer_seek_start, 0);
        var _text = buffer_read(_terminated, buffer_string);
        _document = json_parse(_text);
    } catch (_exception) {
        level_error("Could not parse " + _filename + ": " + string(_exception));
    }
    buffer_delete(_terminated);
    return _document;
}

// Historical INI writers sometimes emitted Publish ID=0.000000. Remove only
// a zero fractional suffix and leading zeroes as text, preserving all ID digits.
function level_legacy_publish_id(_value) {
    if (!is_string(_value)) return _value;
    var _normalized = _value;
    var _dot = string_pos(".", _normalized);
    if (_dot > 0) {
        if (_dot == 1 || _dot == string_length(_normalized)) return _value;
        for (var _i = _dot + 1; _i <= string_length(_normalized); ++_i) if (string_char_at(_normalized, _i) != "0") return _value;
        _normalized = string_copy(_normalized, 1, _dot - 1);
    }
    while (string_length(_normalized) > 1 && string_char_at(_normalized, 1) == "0") _normalized = string_delete(_normalized, 1, 1);
    return level_publish_id_valid(_normalized) ? _normalized : _value;
}

function level_legacy_metadata(_directory) {
    var _metadata = level_metadata_defaults();
    var _filename = level_bundled_path(level_directory(_directory) + "OtherLevelEditor.sav");
    if (!file_exists(_filename)) return _metadata;
    ini_open(_filename);
    _metadata.name = ini_read_string("Other LE", "Name", "");
    _metadata.text = ini_read_string("Other LE", "Text", "");
    _metadata.music = ini_read_string("Other LE", "Music", "0");
    _metadata.editorVersion = ini_read_real("Other LE", "Version", 1);
    _metadata.startingColor = ini_read_real("Other LE", "Default Starting Color", 0);
    _metadata.background = ini_read_real("Other LE", "Background", 0);
    _metadata.starRotation = ini_read_real("Other LE", "Star Rotation", 0);
    _metadata.diamondTime = ini_read_real("Other LE", "Diamond Medal Time", 35);
    _metadata.widthBlocks = ini_read_real("Other LE", "Level Width Blocks", 32);
    _metadata.heightBlocks = ini_read_real("Other LE", "Level Height Blocks", 22);
    _metadata.blockStyle = ini_read_real("Other LE", "Level Block Style", 0);
    _metadata.starStyle = ini_read_real("Other LE", "Level Star Style", 0);
    _metadata.fog = ini_read_real("Other LE", "Level Fog", 0);
    _metadata.publishId = level_legacy_publish_id(ini_read_string("Other LE", "Publish ID", "0"));
    _metadata.workshopVersion = ini_read_real("Other LE", "Workshop Level Version", 0);
    ini_close();
    // Preserve the historical value in migrated metadata; use the normal initial
    // red color for the unmatched legacy spawner branch instead of inventing white.
    if (_metadata.startingColor == 5) {
        _metadata.legacyStartingColor = 5;
        _metadata.startingColor = 0;
        show_debug_message("Level document: legacy starting color 5 is unsupported; retaining legacyStartingColor=5 and using red (0).");
    }
    return _metadata;
}

function level_legacy_document(_legacy, _metadata) {
    var _root = level_field(_legacy, "ROOT", undefined);
    if (!is_array(_root)) return level_error("Legacy level has no ROOT array.");
    var _document = level_document_defaults();
    _document.metadata = _metadata;
    _document.instances = array_create(array_length(_root));
    for (var _i = 0; _i < array_length(_root); ++_i) {
        var _old = _root[_i];
        if (!is_struct(_old)) return level_error("Malformed legacy instance " + string(_i));
        var _frame = (_metadata.editorVersion > 1) ? level_field(_old, "imageindex", 0) : 0;
        var _obj = level_field(_old, "obj", "");
        var _orientation = 0;
        if (level_is_slope(_obj) && level_finite(_frame)) _orientation = ((floor(_frame) mod 4) + 4) mod 4;
        _document.instances[_i] = {
            obj: _obj, x: level_field(_old, "x", undefined), y: level_field(_old, "y", undefined),
            imageindex: _frame, xscale: (_metadata.editorVersion > 1) ? level_field(_old, "xscale", 1) : 1,
            yscale: (_metadata.editorVersion > 1) ? level_field(_old, "yscale", 1) : 1, orientation: _orientation
        };
    }
    return _document;
}

function level_exists(_directory) {
    var _dir = level_directory(_directory);
    if (_dir == "") return false;
    return file_exists(level_bundled_path(_dir + "level.json")) || file_exists(level_bundled_path(_dir + "level.json.bak")) || file_exists(level_bundled_path(_dir + "LevelEditor.sav"));
}

function level_read(_directory) {
    global.level_last_error = "";
    var _dir = level_directory(_directory);
    if (_dir == "") return level_error("Missing level directory.");
    var _document = undefined;
    if (file_exists(level_bundled_path(_dir + "level.json"))) {
        _document = level_parse_json_file(_dir + "level.json");
    } else if (file_exists(level_bundled_path(_dir + "level.json.bak"))) {
        // Recover an interrupted replacement in memory; a read never modifies disk.
        _document = level_parse_json_file(_dir + "level.json.bak");
    } else if (file_exists(level_bundled_path(_dir + "LevelEditor.sav"))) {
        var _legacy = level_parse_json_file(_dir + "LevelEditor.sav");
        if (is_undefined(_legacy)) return undefined;
        _document = level_legacy_document(_legacy, level_legacy_metadata(_dir));
    } else {
        return level_error("No level file in " + _dir);
    }
    if (is_undefined(_document)) return undefined;
    var _validation = level_validate(_document);
    if (!_validation.valid) return level_error(_validation.error);
    return _document;
}

function level_metadata(_directory) {
    var _document = level_read(_directory);
    if (is_undefined(_document)) return undefined;
    return _document.metadata;
}

function level_metadata_apply(_metadata, _keep_publish_id = false) {
    global.leveleditorstring = _metadata.text;
    var _music_index = 0;
    try { _music_index = real(_metadata.music); } catch (_error) { _music_index = 0; }
    global.leveleditormusic = level_finite(_music_index) ? clamp(floor(_music_index), 0, 31) : 0;
    global.leveleditorversion = _metadata.editorVersion;
    global.levelname = _metadata.name;
    global.defaultcolorLE = _metadata.startingColor;
    global.LEBackground = _metadata.background;
    global.LEStarRotation = _metadata.starRotation;
    global.LEDiamondMedalTime = _metadata.diamondTime;
    global.LELevelWidthBlocks = _metadata.widthBlocks;
    global.LELevelHeightBlocks = _metadata.heightBlocks;
    global.LEBlockStyle = _metadata.blockStyle;
    global.LEStarStyle = _metadata.starStyle;
    global.LEFog = _metadata.fog;
    if (!_keep_publish_id) global.Publish_ID = int64(_metadata.publishId);
    global.workshoplevelversion = _metadata.workshopVersion;
    global.level_legacy_starting_color = level_field(_metadata, "legacyStartingColor", undefined);
}

function level_prepare_room(_directory, _room, _keep_publish_id = false) {
    var _document = level_read(_directory);
    if (is_undefined(_document)) return false;
    level_metadata_apply(_document.metadata, _keep_publish_id);
    room_set_width(_room, _document.metadata.widthBlocks * 32);
    room_set_height(_room, 64 + _document.metadata.heightBlocks * 32);
    return true;
}

function level_apply(_document, _context = "editor") {
    var _validation = level_validate(_document);
    if (!_validation.valid) { level_error(_validation.error); return false; }
    // Validate every entry before changing the current room or editor contents.
    global.level_cleanup_active = true;
    timing_activate_object(o_leveleditorloadplacement);
    with (o_leveleditorloadplacement) instance_destroy();
    with (o_enemyplayer) instance_destroy();
    with (o_player) instance_destroy();
    with (o_blockcheck2) instance_destroy();
    with (o_customstarbackground) instance_destroy();
    with (o_fog) instance_destroy();
    global.level_cleanup_active = false;
    level_metadata_apply(_document.metadata, _context == "workshop");
    global.level_document_context = _context;

    global.color = _document.metadata.startingColor;
    var _layer = layer_get_id("TCC_LevelDocument");
    if (_layer == -1) _layer = layer_create(-100, "TCC_LevelDocument");
    var _previous_rotation = variable_global_exists("LEBlockBackgroundRotation") ? global.LEBlockBackgroundRotation : 0;
    for (var _i = 0; _i < array_length(_document.instances); ++_i) {
        var _entry = _document.instances[_i];
        if (level_is_slope(_entry.obj)) global.LEBlockBackgroundRotation = _entry.orientation;
        var _properties = {
            image_index: _entry.imageindex, image_xscale: _entry.xscale, image_yscale: _entry.yscale,
            orientation: _entry.orientation, level_document_order: _i, level_document_context: _context
        };
        // Coordinates and transforms exist before Create, including child spawn effects.
        var _instance = timing_create_layer(_entry.x, _entry.y, _layer, level_object(_entry.obj), _properties);
        if (instance_exists(_instance)) {
            // Older palette Create events reset the animation frame; preserve the authored one.
            _instance.image_index = level_is_slope(_entry.obj) ? _entry.orientation : _entry.imageindex;
        }
    }
    global.LEBlockBackgroundRotation = _previous_rotation;
    scr_troop_nav_mark_dirty();
    if (_context != "editor") {
        scr_LEChangeScenery();
        if (global.LEStarRotation != 0) timing_create_depth(0, 0, 0, o_customstarbackground, {customdirection: global.LEStarRotation});
        if (global.LEFog != 0 && !instance_exists(o_fog)) instance_create(0, 0, o_fog);
        if (global.LELevelHeightBlocks > 22 || global.LELevelWidthBlocks > 32) {
            if (!instance_exists(o_smoothcamera)) instance_create(0, 0, o_smoothcamera);
        }
    }
    return true;
}

// The selected folder is editor identity; imported display metadata must never
// redirect a subsequent save, thumbnail or Workshop upload into another folder.
function level_editor_name_valid(_name) {
    if (!is_string(_name) || string_length(_name) < 1 || string_length(_name) > 256 || _name == "." || _name == "..") return false;
    if (string_char_at(_name, string_length(_name)) == ".") return false;
    var _visible = false;
    for (var _i = 1; _i <= string_length(_name); ++_i) {
        var _character = string_char_at(_name, _i);
        if (ord(_character) < 32 || string_pos(_character, "/\\:*?\"<>|") > 0) return false;
        if (_character != " ") _visible = true;
    }
    return _visible;
}

function level_editor_choose_name(_name) {
    if (!level_editor_name_valid(_name)) { level_error("Choose a level name without path separators or reserved filename characters."); return false; }
    global.level_editor_folder = _name;
    global.level_editor_root = level_directory(directory_set("/LevelEditor Files/"));
    return true;
}

function level_editor_directory() {
    var _root = level_directory(directory_set("/LevelEditor Files/"));
    if (variable_global_exists("level_editor_root") && global.level_editor_root == _root
        && variable_global_exists("level_editor_folder") && level_editor_name_valid(global.level_editor_folder)) {
        return _root + global.level_editor_folder + "/";
    }
    if (!variable_global_exists("levelname") || !level_editor_choose_name(global.levelname)) return "";
    return _root + global.level_editor_folder + "/";
}

function level_editor_open(_name) {
    if (!level_editor_name_valid(_name)) return false;
    var _directory = level_directory(directory_set("/LevelEditor Files/")) + _name + "/";
    if (is_undefined(level_read(_directory))) return false;
    if (!level_editor_choose_name(_name)) return false;
    global.levelname = _name;
    global.naminglevel = false;
    instance_destroy(o_leveleditormenusetup);
    instance_destroy(o_allbackgrounds);
    instance_destroy(o_chooseleveleditorlevel);
    instance_create(0, 0, o_levelreloadagain);
    return true;
}

function level_metadata_capture() {
    var _metadata = {
        name: string(global.levelname), text: string(global.leveleditorstring), music: string(global.leveleditormusic),
        editorVersion: max(2, real(global.leveleditorversion)), startingColor: global.defaultcolorLE,
        background: global.LEBackground, starRotation: global.LEStarRotation, diamondTime: global.LEDiamondMedalTime,
        widthBlocks: global.LELevelWidthBlocks, heightBlocks: global.LELevelHeightBlocks,
        blockStyle: global.LEBlockStyle, starStyle: global.LEStarStyle, fog: global.LEFog,
        publishId: string(int64(global.Publish_ID)), workshopVersion: global.workshoplevelversion
    };
    if (variable_global_exists("level_legacy_starting_color") && !is_undefined(global.level_legacy_starting_color)) {
        _metadata.legacyStartingColor = global.level_legacy_starting_color;
    }
    return _metadata;
}

function level_capture() {
    var _document = level_document_defaults();
    _document.metadata = level_metadata_capture();
    timing_activate_object(o_leveleditorloadplacement);
    var _ordered = [];
    with (o_leveleditorloadplacement) {
        var _name = object_get_name(object_index);
        if (level_object(_name) != -1) {
            var _order = variable_instance_exists(id, "level_document_order") ? level_document_order : 1000000000 + array_length(_ordered);
            var _orientation = 0;
            if (level_is_slope(_name)) _orientation = variable_instance_exists(id, "orientation") ? orientation : ((floor(image_index) mod 4) + 4) mod 4;
            array_push(_ordered, {order: _order, entry: {
                obj: _name, x: x, y: y, imageindex: image_index,
                xscale: image_xscale, yscale: image_yscale, orientation: _orientation
            }});
        }
    }
    array_sort(_ordered, function(_a, _b) { return _a.order - _b.order; });
    for (var _i = 0; _i < array_length(_ordered); ++_i) array_push(_document.instances, _ordered[_i].entry);
    return _document;
}

function level_write(_directory, _document) {
    var _validation = level_validate(_document);
    if (!_validation.valid) { level_error(_validation.error); return false; }
    var _dir = level_directory(_directory);
    if (_dir == "") { level_error("Cannot save without a level directory."); return false; }
    if (!directory_exists(_dir)) directory_create(_dir);
    if (!directory_exists(_dir)) { level_error("Could not create level directory: " + _dir); return false; }
    var _target = _dir + "level.json";
    var _pending = _target + ".pending";
    var _backup = _target + ".bak";
    var _buffer = -1;
    try {
        var _text = json_stringify(_document);
        _buffer = buffer_create(string_byte_length(_text) + 1, buffer_fixed, 1);
        buffer_write(_buffer, buffer_string, _text);
        // New documents are ordinary UTF-8 JSON without a trailing NUL.
        buffer_save_ext(_buffer, _pending, 0, string_byte_length(_text));
        buffer_delete(_buffer);
        _buffer = -1;
        if (!file_exists(_pending)) { level_error("Pending level file was not created: " + _pending); return false; }
        var _check = level_parse_json_file(_pending);
        var _checked = level_validate(_check);
        if (!_checked.valid) { level_error("Saved level failed validation: " + _checked.error); return false; }
        if (!level_json_equal(_check, _document)) { level_error("Saved level differs from the source document: " + _pending); return false; }
        if (file_exists(_target)) {
            if (file_exists(_backup)) file_delete(_backup);
            file_copy(_target, _backup);
            if (!scr_files_equal(_target, _backup)) { level_error("Could not verify the level backup: " + _backup); return false; }
            file_delete(_target);
        }
        file_rename(_pending, _target);
        if (!file_exists(_target)) {
            if (file_exists(_backup)) file_copy(_backup, _target);
            level_error("Could not replace the level file: " + _target);
            return false;
        }
        // Legacy JSON/INI files are untouched and serve as the migration originals.
        return true;
    } catch (_exception) {
        if (_buffer >= 0) buffer_delete(_buffer);
        level_error("Could not save level: " + string(_exception));
        return false;
    }
}

function level_update_metadata(_directory, _metadata) {
    var _document = level_read(_directory);
    if (is_undefined(_document)) return false;
    _document.metadata = _metadata;
    return level_write(_directory, _document);
}

/// Reset a failed run and return its safe menu. No navigation or service calls
/// occur here, so the same state transition is covered by the native self-check.
/// Workshop Endless owns its skip/retry recovery and retains all run state.
function level_load_failure_reset(_failed_room) {
    if (variable_global_exists("endlessrunmode") && global.endlessrunmode == 4
        && variable_global_exists("endless") && global.endless == 1) return -1;
    var _challenge = variable_global_exists("workshopchallenge") && global.workshopchallenge == 1;
    var _workshop = (variable_global_exists("workshop") && global.workshop == 1) || _failed_room == r_customlevelworkshop;
    var _target = _challenge ? r_workshopchallengemenu : (_workshop ? r_customlevelmenu : r_challenges);
    if (_challenge) scr_workshopchallenge_abort();
    global.workshopchallenge = 0;
    global.workshopfolder = "";
    global.workshop = 0;
    global.challenges = 0;
    global.challenge_run_id = -1;
    global.level_document_context = "";
    global.LEMode = 0;
    global.Publish_ID = int64(0);
    global.level_music_directory = "";
    global.pause = 0;
    return _target;
}

function level_load_failure() {
    var _message = variable_global_exists("level_last_error") ? global.level_last_error : "The level could not be loaded.";
    var _target = level_load_failure_reset(room);
    if (_target == -1) {
        workshopER_skip_level();
        return;
    }
    hidehud();
    level_music_release();
    audio_stop_all();
    audio_play_sound(m_mainmenu, 0, 1);
    audio_sound_gain(m_mainmenu, global.musicvolume, 1);
    show_debug_message(_message);
    room_goto(_target);
}

/// Check failure state separately from navigation/audio. Draft data and earned
/// progress survive an aborted run; a stale inactive caller changes no run.
function level_workshop_failure_selfcheck() {
    var _assert = function(_ok, _why) { if (!_ok) throw "Workshop recovery self-check failed: " + _why; };
    var _names = ["endless", "endlessrunmode", "workshop", "workshopfolder", "workshopchallenge",
        "workshopchallenge_title", "workshopchallenge_levels", "workshopchallenge_index",
        "workshopchallenge_diamond_time", "workshopchallenge_difficulty", "workshopchallenge_signature",
        "workshopchallenge_is_draft", "workshopchallenge_return_to_creator", "workshopchallenge_draft",
        "workshopchallenge_beaten_signature", "challenges", "challenge_run_id", "level_document_context",
        "LEMode", "Publish_ID", "level_music_directory", "pause", "time", "deaths", "level_last_error"];
    var _saved = [];
    for (var _i = 0; _i < array_length(_names); ++_i) {
        _saved[_i] = variable_global_exists(_names[_i]) ? variable_global_get(_names[_i]) : undefined;
    }
    global.endless = 0; global.endlessrunmode = 0;
    global.workshop = 1; global.workshopfolder = "/missing/workshop/";
    global.workshopchallenge = 1; global.workshopchallenge_title = "Interrupted sequence";
    global.workshopchallenge_levels = [{id:int64(100)}, {id:int64(200)}];
    global.workshopchallenge_index = 1; global.workshopchallenge_diamond_time = 30;
    global.workshopchallenge_difficulty = 2; global.workshopchallenge_signature = "unfinished";
    global.workshopchallenge_is_draft = 1; global.workshopchallenge_return_to_creator = 1;
    global.workshopchallenge_draft = {title:"Preserved draft"};
    global.workshopchallenge_beaten_signature = "previously earned";
    global.challenges = 1; global.challenge_run_id = 7; global.level_document_context = "workshop";
    global.LEMode = 2; global.Publish_ID = int64(200); global.level_music_directory = global.workshopfolder;
    global.pause = 1; global.time = 12; global.deaths = 3;
    _assert(level_load_failure_reset(r_customlevelworkshop) == r_workshopchallengemenu, "failed sequence leaves completed Workshop room for its menu");
    _assert(global.workshopchallenge == 0 && global.workshop == 0 && global.challenges == 0
        && global.challenge_run_id == -1 && global.level_document_context == "", "all completion eligibility cleared");
    _assert(global.workshopchallenge_title == "" && array_length(global.workshopchallenge_levels) == 0
        && global.workshopchallenge_index == 0 && global.workshopchallenge_diamond_time == 0
        && global.workshopchallenge_difficulty == 0 && global.workshopchallenge_signature == ""
        && global.workshopchallenge_is_draft == 0 && global.workshopchallenge_return_to_creator == 0, "active sequence metadata cleared");
    _assert(global.workshopfolder == "" && global.LEMode == 0 && global.Publish_ID == 0
        && global.level_music_directory == "" && global.pause == 0, "delayed load cannot retain Workshop playback state");
    _assert(global.workshopchallenge_draft.title == "Preserved draft" && global.workshopchallenge_beaten_signature == "previously earned"
        && global.time == 12 && global.deaths == 3, "failure neither destroys authoring/progress nor grants completion");

    global.endless = 1; global.endlessrunmode = 4;
    global.workshop = 1; global.workshopfolder = "/endless/current/"; global.LEMode = 2;
    global.level_document_context = "workshop"; global.Publish_ID = int64(300);
    _assert(level_load_failure_reset(r_customlevelworkshop) == -1 && global.endless == 1 && global.workshop == 1
        && global.workshopfolder == "/endless/current/" && global.LEMode == 2 && global.Publish_ID == 300
        && global.level_document_context == "workshop", "Workshop Endless retains skip-owned state");

    global.endless = 0; global.endlessrunmode = 0; global.workshop = 0; global.workshopchallenge = 0;
    global.challenges = 1; global.challenge_run_id = 7; global.level_document_context = "challenge";
    global.level_last_error = "unchanged";
    _assert(!scr_workshopchallenge_abort() && !scr_workshopchallenge_load_failure("stale")
        && global.challenges == 1 && global.challenge_run_id == 7 && global.level_document_context == "challenge"
        && global.level_last_error == "unchanged", "inactive recovery cannot abort a valid packaged challenge");
    scr_workshopchallenge_goto_level(0);
    scr_workshopchallenge_restart();
    scr_workshopchallenge_advance();
    _assert(global.challenges == 1 && global.challenge_run_id == 7 && global.time == 12 && global.deaths == 3, "inactive sequence callers remain no-ops");
    if (room != r_customlevelworkshop) {
        _assert(!scr_loadcustomlevelworkshop() && global.challenges == 1 && global.challenge_run_id == 7
            && global.level_document_context == "challenge", "wrong-room delayed loader cannot mutate valid run");
    }
    _assert(level_load_failure_reset(r_customlevelworkshop) == r_customlevelmenu
        && global.workshopchallenge == 0 && global.workshopfolder == "", "standalone delayed load returns to Workshop menu even before mode flag is set");
    global.challenges = 1; global.challenge_run_id = 7;
    _assert(level_load_failure_reset(r_challenges) == r_challenges && global.challenge_run_id == -1, "ordinary failed packaged load uses challenge menu");
    for (var _i = 0; _i < array_length(_names); ++_i) variable_global_set(_names[_i], _saved[_i]);
    return true;
}

/// Filter by both event type and request id. Other Steam callbacks cannot submit
/// another update or grant a publish reward.
function level_publish_callback(_event, _state, _create_request, _update_request) {
    var _response = {matched: false, ok: false, legal: false, publishedId: int64(0)};
    if (!(is_real(_event) || is_handle(_event)) || !ds_exists(_event, ds_type_map)) return _response;
    if (!ds_map_exists(_event, "id") || !ds_map_exists(_event, "event_type")) return _response;
    var _type = _event[? "event_type"];
    var _request = _event[? "id"];
    if (_state == "creating" && _type == "ugc_create_item" && _request == _create_request) {
        _response.matched = true;
        if (ds_map_exists(_event, "published_file_id")) _response.publishedId = _event[? "published_file_id"];
    } else if (_state == "submitting" && _type == "ugc_update_item" && _request == _update_request) {
        _response.matched = true;
    }
    if (!_response.matched) return _response;
    _response.legal = ds_map_exists(_event, "legal_agreement_required") && _event[? "legal_agreement_required"] == 1;
    _response.ok = ds_map_exists(_event, "result") && _event[? "result"] == ugc_result_success;
    if (_state == "creating" && _response.publishedId <= 0) _response.ok = false;
    return _response;
}

function level_publish_tags(_document) {
    var _tags = ["Levels"];
    var _joined = "|";
    for (var _i = 0; _i < array_length(_document.instances); ++_i) _joined += _document.instances[_i].obj + "|";
    if (string_pos("o_spike|", _joined) || string_pos("o_spikeleft|", _joined) || string_pos("o_spikeright|", _joined) || string_pos("o_spiketop|", _joined)) array_push(_tags, "Spikes");
    if (string_pos("o_invspike", _joined)) array_push(_tags, "Invisible Spikes");
    if (string_pos("o_shooter", _joined)) array_push(_tags, "Cannons");
    if (string_pos("gravity", _joined)) array_push(_tags, "Gravity");
    if (string_pos("o_speed", _joined)) array_push(_tags, "Speed");
    if (string_pos("o_portal", _joined)) array_push(_tags, "Portals");
    if (_document.metadata.fog != 0) array_push(_tags, "Fog");
    if (string_pos("o_enemyplayerLE", _joined)) array_push(_tags, "Troops");
    if (string_pos("o_oneway", _joined)) array_push(_tags, "One Way Blocks");
    if (string_pos("o_rocketlauncher", _joined)) array_push(_tags, "Rocket Cannons");
    if (string_pos("o_water|", _joined) || string_pos("o_lava|", _joined)) array_push(_tags, "Liquids");
    if (string_pos("o_spikemoving", _joined)) array_push(_tags, "Vertical Spikes");
    if (string_pos("o_Hspikemoving", _joined)) array_push(_tags, "Horizontal Spikes");
    if (_document.metadata.widthBlocks > 40 || _document.metadata.heightBlocks > 40) array_push(_tags, "Big Level");
    return _tags;
}

function level_selfcheck(_directory = "") {
    var _assert = function(_condition, _message) {
        if (!_condition) throw "Level document self-check failed: " + _message;
    };
    if (_directory == "") _directory = game_save_id + "/LevelDocumentSelfCheck/";
    _directory = level_directory(_directory);
    if (!directory_exists(_directory)) directory_create(_directory);
    var _document = level_document_defaults();
    _document.metadata.name = "Codec round trip";
    _document.metadata.text = "Quotes: \"color\"\nUnicode: žuta / 月";
    _document.metadata.music = "6";
    _document.metadata.fog = 1;
    _document.metadata.starStyle = 2;
    _document.metadata.blockStyle = 3;
    _document.metadata.publishId = "76561198012345678";
    _document.instances = [
        {obj:"o_playerspawner", x:96, y:160, imageindex:0, xscale:1, yscale:1, orientation:0},
        {obj:"o_redblock", x:64, y:192, imageindex:0, xscale:1, yscale:1, orientation:0},
        {obj:"o_door", x:224, y:128, imageindex:0, xscale:1, yscale:1, orientation:0}
    ];
    _assert(level_validate(_document).valid, "minimal palette document validates");
    _assert(level_write(_directory, _document), "new document writes; last diagnostic: " + (variable_global_exists("level_last_error") ? global.level_last_error : "none"));
    var _plain_buffer = buffer_load(_directory + "level.json");
    _assert(buffer_get_size(_plain_buffer) > 0 && buffer_peek(_plain_buffer, buffer_get_size(_plain_buffer) - 1, buffer_u8) != 0, "new JSON fixture is ordinary UTF-8 without trailing NUL");
    buffer_delete(_plain_buffer);
    _assert(level_parse_json_file(_directory + "level.json").format == "tcc.level", "ordinary non-NUL JSON parses");
    _assert(level_exists(_directory), "new-format discovery");
    _assert(level_bundled_path(_directory + "MyCase.json") == _directory + "MyCase.json", "absolute user paths retain exact case");
    _assert(level_bundled_path("LevelEditor Files/MyCase/LevelEditor.sav") == "LevelEditor Files/MyCase/LevelEditor.sav", "relative user folders retain exact case");
    var _read = level_read(_directory);
    _assert(!is_undefined(_read) && _read.metadata.text == _document.metadata.text, "Unicode and newline metadata round trip");
    _assert(_read.metadata.publishId == "76561198012345678", "64-bit Workshop identifier retains precision");
    _assert(_read.metadata.fog == 1 && _read.metadata.starStyle == 2 && _read.metadata.blockStyle == 3, "all scenery metadata round trips");
    _assert(array_length(_read.instances) == 3 && _read.instances[0].y == 160 && _read.instances[2].obj == "o_door", "HUD coordinates and creation order preserved");
    _document.metadata.text = "Second save";
    _assert(level_write(_directory, _document), "replacement save writes");
    _assert(level_parse_json_file(_directory + "level.json.bak").metadata.text != "Second save", "previous document backup retained");
    var _before_bad = level_read(_directory);
    var _invalid = json_parse(json_stringify(_document));
    _invalid.instances[1].obj = "o_player";
    _assert(!level_validate(_invalid).valid, "arbitrary project object is rejected");
    var _before_instances = instance_number(o_leveleditorloadplacement);
    _assert(!level_apply(_invalid) && instance_number(o_leveleditorloadplacement) == _before_instances, "invalid apply preserves current editor contents");
    _assert(!level_write(_directory, _invalid) && level_json_equal(level_read(_directory), _before_bad), "invalid write preserves saved document");
    _invalid = json_parse(json_stringify(_document));
    _invalid.instances[1].xscale = 0;
    _assert(_invalid.instances[1].xscale == 0, "zero-scale fixture assignment is preserved");
    _assert(!level_validate(_invalid).valid, "zero collision scale rejected; xscale=" + string(_invalid.instances[1].xscale));
    _invalid.instances[1].xscale = 1;
    _invalid.instances[1].y = 70500000727040;
    _assert(!level_validate(_invalid).valid, "unsafe coordinates rejected");
    _invalid = json_parse(json_stringify(_document));
    _invalid.metadata.widthBlocks = -1;
    _assert(!level_validate(_invalid).valid, "negative dimensions rejected");
    _invalid = json_parse(json_stringify(_document));
    _invalid.schemaVersion = 999;
    _assert(!level_validate(_invalid).valid, "future schema rejected without guessing");
    _assert(!level_validate({}).valid && !level_validate([]).valid, "malformed root rejected");
    _assert(level_publish_id_valid("0") && level_publish_id_valid("9223372036854775807"), "Workshop ID boundaries accepted");
    _assert(level_legacy_publish_id("0.000000") == "0" && level_legacy_publish_id("76561198012345678.000000") == "76561198012345678", "legacy INI decimal IDs normalize without floating-point precision loss");
    var _bad_ids = ["", "00", "-1", "1.0", "1e5", "9223372036854775808", "99999999999999999999"];
    for (var _id_index = 0; _id_index < array_length(_bad_ids); ++_id_index) {
        _invalid = json_parse(json_stringify(_document));
        _invalid.metadata.publishId = _bad_ids[_id_index];
        _assert(!level_validate(_invalid).valid, "malformed or out-of-range Workshop ID rejected");
    }
    _assert(level_editor_name_valid("My level 月") && !level_editor_name_valid("../Other") && !level_editor_name_valid("Folder/Other")
        && !level_editor_name_valid("Folder\\Other") && !level_editor_name_valid(".."), "editor names cannot escape their selected folder");
    _assert(level_json_equal({a:1,b:[2,3]}, {b:[2,3],a:1}), "JSON member order is immaterial");
    _assert(!level_json_equal({a:[2,3]}, {a:[3,2]}), "JSON array order remains significant");
    file_delete(_directory + "level.json");
    _assert(!is_undefined(level_read(_directory)) && !file_exists(_directory + "level.json"), "backup read recovers without modifying disk");
    _assert(level_write(_directory, _document), "explicit save restores missing primary");

    var _legacy_dir = _directory + "Legacy/";
    directory_create(_legacy_dir);
    if (file_exists(_legacy_dir + "level.json")) file_delete(_legacy_dir + "level.json");
    if (file_exists(_legacy_dir + "level.json.bak")) file_delete(_legacy_dir + "level.json.bak");
    var _old = {ROOT:[{obj:"o_redblock", x:32, y:96, imageindex:2, xscale:2, yscale:3}]};
    SaveStringToFile(_legacy_dir + "LevelEditor.sav", json_stringify(_old));
    ini_open(_legacy_dir + "OtherLevelEditor.sav");
    ini_write_string("Other LE", "Version", "1");
    ini_write_string("Other LE", "Name", "Legacy one");
    ini_close();
    var _legacy = level_read(_legacy_dir);
    _assert(!is_undefined(_legacy) && _legacy.instances[0].imageindex == 0 && _legacy.instances[0].xscale == 1, "legacy version 1 uses original default transforms");
    ini_open(_legacy_dir + "OtherLevelEditor.sav");
    ini_write_string("Other LE", "Version", "2");
    ini_close();
    _legacy = level_read(_legacy_dir);
    _assert(_legacy.instances[0].imageindex == 2 && _legacy.instances[0].xscale == 2 && _legacy.instances[0].yscale == 3, "legacy version 2 retains transforms");
    ini_open(_legacy_dir + "OtherLevelEditor.sav");
    ini_write_string("Other LE", "Version", "8");
    ini_write_real("Other LE", "Default Starting Color", 5);
    ini_close();
    _legacy = level_read(_legacy_dir);
    _assert(_legacy.metadata.editorVersion == 8 && _legacy.instances[0].yscale == 3, "legacy version 8 retains transforms");
    _assert(_legacy.metadata.startingColor == 0 && _legacy.metadata.legacyStartingColor == 5, "unmatched legacy color retains raw value and normal red initialization");
    var _legacy_buffer = buffer_load(_legacy_dir + "LevelEditor.sav");
    var _legacy_hash = buffer_sha1(_legacy_buffer, 0, buffer_get_size(_legacy_buffer));
    buffer_delete(_legacy_buffer);
    _assert(level_write(_legacy_dir, _legacy), "legacy migration writes new format");
    _legacy_buffer = buffer_load(_legacy_dir + "LevelEditor.sav");
    _assert(buffer_sha1(_legacy_buffer, 0, buffer_get_size(_legacy_buffer)) == _legacy_hash, "migration preserves legacy JSON original");
    buffer_delete(_legacy_buffer);
    _assert(level_read(_legacy_dir).metadata.legacyStartingColor == 5, "migration preserves raw legacy metadata");
    var _file = file_text_open_write(_legacy_dir + "level.json");
    file_text_write_string(_file, "{broken JSON");
    file_text_close(_file);
    _assert(is_undefined(level_read(_legacy_dir)), "invalid new document cannot silently load stale legacy data");
    // Make repeated test runs independent of their previous migration output.
    file_delete(_legacy_dir + "level.json");
    if (file_exists(_legacy_dir + "level.json.bak")) file_delete(_legacy_dir + "level.json.bak");

    var _slope_names = ["o_redblockslope", "o_yellowblockslope", "o_greenblockslope", "o_blueblockslope", "o_whiteblockslope"];
    for (var _color = 0; _color < array_length(_slope_names); ++_color) {
        for (var _orientation = 0; _orientation < 4; ++_orientation) {
            var _slope_legacy = {ROOT:[{obj:_slope_names[_color], x:64, y:128, imageindex:_orientation, xscale:1, yscale:1}]};
            var _slope = level_legacy_document(_slope_legacy, level_metadata_defaults());
            _assert(level_validate(_slope).valid && _slope.instances[0].orientation == _orientation, "slope palette orientation " + string(_color) + "/" + string(_orientation));
        }
    }
    var _event = ds_map_create();
    _event[? "id"] = 7; _event[? "event_type"] = "ugc_create_item";
    _event[? "result"] = ugc_result_success; _event[? "published_file_id"] = int64(100);
    _assert(!level_publish_callback(_event, "creating", 8, 9).matched, "unrelated Steam request ignored");
    _assert(level_publish_callback(_event, "creating", 7, 9).ok, "matching create callback accepted");
    _assert(!level_publish_callback(_event, "submitting", 7, 9).matched, "create callback cannot complete upload");
    _event[? "id"] = 9; _event[? "event_type"] = "ugc_update_item";
    _assert(level_publish_callback(_event, "submitting", 7, 9).ok, "matching update completes upload");
    _assert(!level_publish_callback(_event, "finished", 7, 9).matched, "duplicate completion callback ignored");
    _event[? "legal_agreement_required"] = 1;
    _assert(level_publish_callback(_event, "submitting", 7, 9).legal, "Workshop legal requirement preserved");
    _event[? "result"] = 0;
    _assert(!level_publish_callback(_event, "submitting", 7, 9).ok, "failed upload cannot grant reward");
    ds_map_destroy(_event);
    _assert(workshopER_catalog_selfcheck(), "Workshop catalog callback fixtures");
    _assert(level_workshop_failure_selfcheck(), "Workshop failure recovery fixtures");

    var _bundle_probe = level_directory(scr_challenge_get_base_dir()) + "Lunar Base Challenge/1/LevelEditor.sav";
    var _bundle_lower = string_lower(_bundle_probe);
    var _bundle_normalized = string_replace_all(_bundle_lower, " ", "_");
    show_debug_message("TCC_BUNDLE_PATH_PROBE " + json_stringify({original:_bundle_probe,
        originalFile:file_exists(_bundle_probe), originalDirectory:directory_exists(_bundle_probe),
        lower:_bundle_lower, lowerFile:file_exists(_bundle_lower), normalized:_bundle_normalized, normalizedFile:file_exists(_bundle_normalized), resolved:level_bundled_path(_bundle_probe),
        programDirectory:program_directory, workingDirectory:working_directory,
        programAbsoluteFile:file_exists(program_directory + "/" + _bundle_lower),
        workingAbsoluteFile:file_exists(working_directory + "/" + _bundle_lower),
        programNormalizedFile:file_exists(program_directory + "/" + _bundle_normalized),
        workingNormalizedFile:file_exists(working_directory + "/" + _bundle_normalized)}));
    var _started = get_timer();
    var _lunar = level_read(level_directory(scr_challenge_get_base_dir()) + "Lunar Base Challenge/1/");
    _assert(!is_undefined(_lunar), "bundled Lunar document loads");
    _assert(array_length(_lunar.instances) == 4636 && _lunar.metadata.widthBlocks == 100 && _lunar.metadata.heightBlocks == 100, "complete Lunar fixture preserved");
    _assert(_lunar.metadata.diamondTime == 130, "Lunar target remains 130 seconds");
    var _lunar_load_us = get_timer() - _started;
    var _calendar_tested = false;
    var _calendar_roots = ["Calendar/Levels/r_c2022lvl73/", "calendar/levels/r_c2022lvl73/", "datafiles/Calendar/Levels/r_c2022lvl73/"];
    for (var _i = 0; _i < array_length(_calendar_roots); ++_i) {
        if (level_exists(_calendar_roots[_i])) {
            var _calendar_raw = level_parse_json_file(_calendar_roots[_i] + "LevelEditor.sav");
            _assert(array_length(_calendar_raw.ROOT) == 57, "real calendar fixture recognized");
            _assert(is_undefined(level_read(_calendar_roots[_i])), "unsafe real legacy version 8 fixture rejected before creation");
            _calendar_tested = true;
            break;
        }
    }
    var _result = {passed:true, lunarInstances:array_length(_lunar.instances), lunarReadMicroseconds:_lunar_load_us, calendarMalformedFixture:_calendar_tested, slopeOrientations:20,
        workshopCatalogCallbacks:true, workshopFailureRecovery:true};
    show_debug_message("TCC_LEVEL_DOCUMENT_SELF_CHECK_PASS " + json_stringify(_result));
    return _result;
}

/// A single owned custom stream is shared by editor, Workshop and challenges.
/// Replacing it releases the previous resource, rather than accumulating handles.
function level_music_release() {
    if (variable_global_exists("level_music_stream") && global.level_music_stream != -1) {
        audio_stop_sound(global.level_music_stream);
        audio_destroy_stream(global.level_music_stream);
    }
    global.level_music_stream = -1;
}

function level_music_play(_filename) {
    _filename = level_bundled_path(_filename);
    if (!file_exists(_filename)) return false;
    level_music_release();
    var _stream = audio_create_stream(_filename);
    if (_stream == -1) return false;
    global.level_music_stream = _stream;
    audio_play_sound(_stream, 0, 1);
    audio_sound_gain(_stream, global.musicvolume, 1);
    return true;
}
