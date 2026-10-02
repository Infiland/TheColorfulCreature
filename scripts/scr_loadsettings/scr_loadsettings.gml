function scr_loadsettings(_directory = undefined) {
	if tcc_steam_get_app_id() != 1749610 {

	var directory = is_undefined(_directory) ? directory_set("//Save Files/") : _directory;
	scr_save_recover(directory + "Settings.sav");

	if (file_exists(directory + "Settings.sav")) {
	ini_open(directory + "Settings.sav")
	//Settings
	global.stars = ini_read_real("Settings","Star Settings",2);
	global.whiteblock = ini_read_real("Settings","White Block Settings",1);
	global.itempar = ini_read_real("Settings","Item Particles Settings",1);
	global.playerpar = ini_read_real("Settings","Player Settings",1);
	global.background = ini_read_real("Settings","Background",1);
	global.fpssettings = ini_read_real("Settings","FPS Show",0);
	global.musicvolume = ini_read_real("Settings","Music Volume",0.5);
	global.soundvolume = ini_read_real("Settings","Sound Volume",0.5);
	global.mastervolume = ini_read_real("Settings","Master Volume",0.5);
	global.autopausesettings = ini_read_real("Settings","Auto Pause",0);
	global.musicdistortionsettings = ini_read_real("Settings","Music Distortion",1);
	global.vignettesettings = ini_read_real("Settings","Vignette",1);
	global.decimalsettings = ini_read_real("Settings","Decimal",0);
	global.visual3dsettings = ini_read_real("Settings","3D",0);
	global.colorblindsettings = ini_read_real("Settings","ColorBlind",0);
	global.blockbackgroundsettings = ini_read_real("Settings","Block Background",1);
	global.troopvoicelinesettings = ini_read_real("Settings","Troop Voiceline",1);
	global.watershadersettings = ini_read_real("Settings","Water Shader",1);
	global.gunvisibilitysettings = ini_read_real("Settings","Gun Visibility",1);
	global.fullscreen = ini_read_real("Settings","Fullscreen",0);
	global.noadsinmenusettings = ini_read_real("Settings","No Ads in Menu",0);
	global.renderfps = ini_read_real("Settings","Max FPS",60);
	global.skiplevelholdsettings = ini_read_real("Settings","Skip Level Hold",1);
	global.oldGSsettings = ini_read_real("Settings","Old GS",0);
	global.objcountersettings = ini_read_real("Settings","OBJ Counter",0);

	//Language return on default
	global.language = ini_read_real("Settings","Language",setLanguageDependingOnRegion());


	global.casualmode = ini_read_real("Settings","Casual Mode",1);
	global.autothumbnailsettings = ini_read_real("Settings","Auto-Thumbnail",1);
	global.skipintroscreensettings = ini_read_real("Settings","Skip Intro Screen",1);
	global.antialiasingsettings = ini_read_real("Settings","Antialiasing",0);
	global.vsyncsettings = ini_read_real("Settings","V-Sync",0);
	global.biglevelperfsettings = ini_read_real("Settings","Big Level Perf",0);
	global.customsplashessettings = ini_read_real("Settings","Custom Splashes",0);
	global.customhatautoscale = ini_read_real("Settings","Hats Autoscale",1);
	global.customskinautoscale = ini_read_real("Settings","Skins Autoscale",1);
	global.customitemautoscale = ini_read_real("Settings","Items Autoscale",1);
	global.devcommentarysettings = ini_read_real("Settings","Dev Commentary",0);
	//Controls
	global.controlsrestart = ini_read_string("Controls","Restart","R")
	global.controlsskiplevel = ini_read_string("Controls","Skip Level","C")
	global.controlsinteract = ini_read_string("Controls","Interact","X")
	global.controlsjump = ini_read_string("Controls","Jump","Z")
	global.controlsmoveleft = ini_read_string("Controls","Move Left","37")
	global.controlsmoveright = ini_read_string("Controls","Move Right","39")
	global.controllervibrationsettings = ini_read_real("Controls","Controller Vibration",1);
	//Online Multiplayer
	global.onlinemultiplayersettings = ini_read_real("Settings","Online Multiplayer",1);
	global.netmaxplayers = ini_read_real("Settings","Net Max Players",8);
	//Controller Button Bindings
	gamepad_remap_load();
	ini_close();
	if (!platform_steam()) global.onlinemultiplayersettings = 0;
	}
	else {
	}
	}

    // Keep the demo's existing settings gate, but its shared FPS control must
    // restore the same preference after a title reload or a new launch.
    if (tcc_steam_get_app_id() == 1749610) {
        var _fps_directory = is_undefined(_directory) ? directory_set("//Save Files/") : _directory;
        global.renderfps = settings_fps_read_file(_fps_directory);
    }
    scr_settings_validate();
}

// Validate both older INIs and runtime changes before persisting. Defaults keep the
// historical keys and units; unknown or non-finite values never reach rendering/input.
function settings_number(_value, _default, _minimum, _maximum, _integer = true) {
    if (!is_real(_value) || is_nan(_value) || is_infinity(_value)) return _default;
    _value = clamp(_value, _minimum, _maximum);
    return _integer ? round(_value) : _value;
}

function settings_choice(_value, _default, _choices) {
    for (var _i = 0; _i < array_length(_choices); ++_i) {
        if (_value == _choices[_i]) return _value;
    }
    return _default;
}

function settings_keyboard_names() {
    return ["controlsmoveright", "controlsmoveleft", "controlsjump", "controlsinteract", "controlsskiplevel", "controlsrestart"];
}

function settings_keyboard_defaults() { return ["39", "37", "Z", "X", "C", "R"]; }

// Printable OEM keys use virtual key codes, not their ASCII character codes.
// Normalize the characters written by older capture code, including Shift forms.
function settings_keyboard_oem_pairs() {
    return [[";:",186],["=+",187],[",<",188],["-_",189],[".>",190],["/?",191],
        ["`~",192],["[{",219],["\\|",220],["]}",221],["'\"",222]];
}

function settings_keyboard_value(_value, _default) {
    if (is_real(_value)) {
        if (is_nan(_value) || is_infinity(_value)) return _default;
        _value = string(round(_value));
    }
    if (!is_string(_value)) return _default;
    _value = string_upper(_value);
    if (string_length(_value) == 1) {
        var _oem = settings_keyboard_oem_pairs();
        for (var _i = 0; _i < array_length(_oem); ++_i) {
            if (string_pos(_value, _oem[_i][0]) > 0) return string(_oem[_i][1]);
        }
        var _shift_digit = string_pos(_value, ")!@#$%^&*(") - 1;
        if (_shift_digit >= 0) return _shift_digit >= 8 ? string(48 + _shift_digit) : string(_shift_digit);
        var _code = ord(_value);
        if (_code >= 32 && _code <= 126) return _value;
    }
    var _special = ["40", "39", "38", "37", "32", "17", "13", "16", "9", "18", "8", "56", "57",
        "186", "187", "188", "189", "190", "191", "192", "219", "220", "221", "222", "226"];
    for (var _i = 0; _i < array_length(_special); ++_i) if (_value == _special[_i]) return _value;
    return _default;
}

function settings_keyboard_capture(_code, _text) {
    switch (_code) {
        case vk_down: case vk_right: case vk_up: case vk_left: case vk_space:
        case vk_control: case vk_enter: case vk_shift: case vk_tab: case vk_alt:
        case vk_backspace: return string(_code);
    }
    if (_code >= ord("A") && _code <= ord("Z")) return chr(_code);
    if (_code >= ord("0") && _code <= ord("9")) return _code >= ord("8") ? string(_code) : chr(_code);
    var _oem = settings_keyboard_oem_pairs();
    for (var _i = 0; _i < array_length(_oem); ++_i) if (_code == _oem[_i][1]) return string(_code);
    if (_code == 226) return "226"; // ISO extra printable key.
    return string_length(_text) == 1 ? settings_keyboard_value(_text, "") : "";
}

function settings_keyboard_code(_value) {
    _value = settings_keyboard_value(_value, "Z");
    if (_value == "8" || _value == "9") return real(_value);
    return string_length(_value) == 1 ? ord(_value) : real(_value);
}

function settings_keyboard_display(_value) {
    _value = string(_value);
    switch (_value) {
        case "40": return "Down"; case "39": return "Right";
        case "38": return "Up"; case "37": return "Left";
        case "32": return "Space"; case "17": return "Ctrl";
        case "13": return "Enter"; case "16": return "Shift";
        case "9": return "Tab"; case "18": return "Alt";
        case "188": return ","; case "190": return ".";
        case "191": return "/"; case "8": return "Backspace";
        case "56": return "8"; case "57": return "9";
        case "186": return ";"; case "187": return "="; case "189": return "-";
        case "192": return "`"; case "219": return "["; case "220": return "\\";
        case "221": return "]"; case "222": return "'"; case "226": return "<>";
    }
    return _value;
}

function settings_text(_label) {
    var _key = string_upper(string_replace_all(string_replace_all(_label, " ", "_"), "-", "_"));
    var _localized = loc(_key);
    if (_localized != "" && _localized != _key) return _localized;
    // Existing translations overlay English; new/missing labels stay readable.
    return string_replace_all(_label, "_", " ");
}

function settings_indicator_frame(_value, _maximum) {
    if (_value <= 0) return 0;
    return _value >= _maximum ? 2 : 1;
}

function settings_validation_rules() {
    return [
        ["stars", 2, 0, 2, true],
        ["whiteblock", 1, 0, 2, true],
        ["itempar", 1, 0, 1, true],
        ["playerpar", 1, 0, 2, true],
        ["background", 1, 0, 1, true],
        ["fpssettings", 0, 0, 2, true],
        ["musicvolume", 0.5, 0, 1, false],
        ["soundvolume", 0.5, 0, 1, false],
        ["mastervolume", 0.5, 0, 1, false],
        ["autopausesettings", 0, 0, 1, true],
        ["musicdistortionsettings", 1, 0, 1, true],
        ["vignettesettings", 1, 0, 1, true],
        ["decimalsettings", 0, 0, 1, true],
        ["visual3dsettings", 0, 0, 1, true],
        ["colorblindsettings", 0, 0, 4, true],
        ["blockbackgroundsettings", 1, 0, 1, true],
        ["troopvoicelinesettings", 1, 0, 1, true],
        ["watershadersettings", 1, 0, 1, true],
        ["gunvisibilitysettings", 1, 0, 1, true],
        ["fullscreen", 0, 0, 1, true],
        ["noadsinmenusettings", 0, 0, 1, true],
        ["renderfps", 60, 30, 1000, true],
        ["skiplevelholdsettings", 1, 0, 1, true],
        ["oldGSsettings", 0, 0, 1, true],
        ["objcountersettings", 0, 0, 1, true],
        ["language", 0, 0, 17, true],
        ["casualmode", 1, 0, 1, true],
        ["autothumbnailsettings", 1, 0, 1, true],
        ["skipintroscreensettings", 1, 0, 1, true],
        ["antialiasingsettings", 0, 0, 8, true],
        ["vsyncsettings", 0, 0, 1, true],
        ["biglevelperfsettings", 0, 0, 2, true],
        ["customsplashessettings", 0, 0, 1, true],
        ["customhatautoscale", 1, 0, 1, true],
        ["customskinautoscale", 1, 0, 1, true],
        ["customitemautoscale", 1, 0, 1, true],
        ["devcommentarysettings", 0, 0, 1, true],
        ["controllervibrationsettings", 1, 0, 1, true],
        ["onlinemultiplayersettings", 1, 0, 1, true],
        ["netmaxplayers", 8, 2, 256, true]
    ];
}
function scr_settings_validate() {
    global.maxfps = TCC_SIM_HZ;
    var _rules = settings_validation_rules();
    for (var _i = 0; _i < array_length(_rules); ++_i) {
        var _r = _rules[_i];
        var _value = variable_global_exists(_r[0]) ? variable_global_get(_r[0]) : _r[1];
        variable_global_set(_r[0], _r[0] == "renderfps" ? settings_fps_value(_value)
            : settings_number(_value, _r[1], _r[2], _r[3], _r[4]));
    }
    global.antialiasingsettings = settings_choice(global.antialiasingsettings, 0, [0, 2, 4, 8]);
    if (!platform_steam()) global.onlinemultiplayersettings = 0;
    var _names = settings_keyboard_names(), _defaults = settings_keyboard_defaults();
    for (var _j = 0; _j < 6; ++_j) {
        var _key = variable_global_exists(_names[_j]) ? variable_global_get(_names[_j]) : _defaults[_j];
        variable_global_set(_names[_j], settings_keyboard_value(_key, _defaults[_j]));
        gamepad_remap_set(_j, gamepad_remap_get(_j));
    }
}

// Exercise the legacy consumers' actual classifier without saving or reading input.
// Mobile retains its existing touch branch; these fixtures use the desktop branch.
function settings_keyboard_classifier_selfcheck() {
    if (platform_mobile()) return;
    var _names = settings_keyboard_names();
    var _flags = ["rightcontrols", "leftcontrols", "jumpcontrols", "interactcontrols", "skipcontrols", "restartcontrols"];
    var _old_values = [], _old_flags = [];
    for (var _i = 0; _i < 6; ++_i) {
        array_push(_old_values, variable_global_exists(_names[_i]) ? variable_global_get(_names[_i]) : undefined);
        array_push(_old_flags, variable_instance_exists(id, _flags[_i]) ? variable_instance_get(id, _flags[_i]) : undefined);
    }
    // Each action receives every case; rotate them so the six actions differ
    // in each call and a swapped flag/action index cannot pass accidentally.
    var _cases = [["a",0,65],["Z",0,90],["0",0,48],["7",0,55],
        ["56",1,56],["57",1,57],["37",1,37],[37,1,37],
        ["8",1,8],[8,1,8],["9",1,9],[9,1,9],["32",1,32],["226",1,226]];
    var _oem = settings_keyboard_oem_pairs();
    for (var _p = 0; _p < array_length(_oem); ++_p) {
        for (var _c = 1; _c <= string_length(_oem[_p][0]); ++_c) {
            array_push(_cases, [string_char_at(_oem[_p][0],_c),1,_oem[_p][1]]);
        }
        array_push(_cases, [_oem[_p][1],1,_oem[_p][1]]);
    }
    for (var _case_index = 0; _case_index < array_length(_cases); ++_case_index) {
        for (var _action = 0; _action < 6; ++_action) {
            variable_global_set(_names[_action], _cases[(_case_index + _action) mod array_length(_cases)][0]);
        }
        for (var _pass = 0; _pass < 2; ++_pass) {
            scr_playercontrolsconfig();
            for (var _a = 0; _a < 6; ++_a) {
                var _expected = _cases[(_case_index + _a) mod array_length(_cases)];
                var _flag = variable_instance_get(id,_flags[_a]), _value = variable_global_get(_names[_a]);
                var _effective = _flag == 1 ? _value : ord(_value);
                scr_port_assert(_flag == _expected[1] && _effective == _expected[2]
                    && settings_keyboard_code(_value) == _expected[2],
                    "legacy classifier retains action " + string(_a) + " key " + string(_expected[0]) + " after call " + string(_pass + 1));
            }
        }
    }
    for (var _restore = 0; _restore < 6; ++_restore) {
        variable_global_set(_names[_restore],_old_values[_restore]);
        variable_instance_set(id,_flags[_restore],_old_flags[_restore]);
    }
    show_debug_message("TCC_KEYBOARD_CLASSIFIER_PASS cases=" + string(array_length(_cases)) + " actions=6 calls=2");
}

function scr_settings_selfcheck() {
    scr_port_assert(settings_number(-1, 0.5, 0, 1, false) == 0, "volume is clamped at zero");
    scr_port_assert(settings_number(9, 0.5, 0, 1, false) == 1, "volume is clamped at one");
    scr_port_assert(settings_number("bad", 0.5, 0, 1, false) == 0.5, "invalid volume falls back");
    settings_fps_selfcheck();
    scr_port_assert(settings_keyboard_value("", "Z") == "Z", "empty key cannot disable jump");
    scr_port_assert(settings_keyboard_value(37, "Z") == "37" && settings_keyboard_code("37") == vk_left, "legacy numeric arrow key survives serialization");
    var _oem = settings_keyboard_oem_pairs();
    for (var _p = 0; _p < array_length(_oem); ++_p) {
        for (var _c = 1; _c <= string_length(_oem[_p][0]); ++_c) {
            var _character = string_char_at(_oem[_p][0], _c), _expected = _oem[_p][1];
            var _captured = settings_keyboard_capture(_expected, _character);
            scr_port_assert(settings_keyboard_value(_character, "Z") == string(_expected)
                && settings_keyboard_code(_character) == _expected
                && settings_keyboard_code(settings_keyboard_value(_captured, "Z")) == _expected,
                "saved/captured OEM punctuation uses its virtual key: " + _character);
        }
    }
    scr_port_assert(settings_keyboard_capture(226, "<") == "226" && settings_keyboard_code("226") == 226, "ISO extra key retains captured virtual code");
    for (var _d = 0; _d < 10; ++_d) {
        scr_port_assert(settings_keyboard_code(settings_keyboard_capture(48 + _d, string(_d))) == 48 + _d,
            "captured digit keeps its own key: " + string(_d));
    }
    scr_port_assert(settings_keyboard_code("8") == vk_backspace && settings_keyboard_code("9") == vk_tab
        && settings_keyboard_code("Z") == ord("Z") && settings_keyboard_code("*") == 56,
        "legacy special keys and letters remain distinct from printable shifted digits");
    scr_port_assert(settings_indicator_frame(1, 2) == 1 && settings_indicator_frame(2, 2) == 2, "partial and full indicators are distinct");
    var _buttons = gamepad_remap_buttons();
    for (var _i = 0; _i < array_length(_buttons); ++_i) scr_port_assert(gamepad_remap_valid_button(_buttons[_i]), "all standard controller buttons are assignable");
    scr_port_assert(!gamepad_remap_valid_button(-1) && !gamepad_remap_valid_button(0), "invalid controller codes rejected");
    scr_port_assert(gamepad_remap_valid_button(gp_start), "Start can be a gameplay binding");
    gamepad_remap_selfcheck();
    settings_keyboard_classifier_selfcheck();
    show_debug_message("TCC_SETTINGS_PASS");
}
