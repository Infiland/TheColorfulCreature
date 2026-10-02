function scr_playercontrolsconfig(){
// Every caller receives initialized flags, including mobile tutorial objects.
leftcontrols = 0
rightcontrols = 0
jumpcontrols = 0
interactcontrols = 0
skipcontrols = 0
restartcontrols = 0
	if !platform_mobile() {
        // Legacy tutorial/shop consumers still distinguish character values
        // from virtual key codes. Classify all accepted bindings through the
        // same validator as gameplay, including already-numeric values.
        var _names = settings_keyboard_names(), _defaults = settings_keyboard_defaults();
        var _flags = ["rightcontrols", "leftcontrols", "jumpcontrols", "interactcontrols", "skipcontrols", "restartcontrols"];
        for (var _i = 0; _i < 6; ++_i) {
            var _value = settings_keyboard_value(variable_global_get(_names[_i]), _defaults[_i]);
            var _numeric = string_length(_value) > 1 || _value == "8" || _value == "9";
            variable_instance_set(id, _flags[_i], _numeric ? 1 : 0);
            variable_global_set(_names[_i], _numeric ? settings_keyboard_code(_value) : _value);
        }
	} else {
	if room != r_mainmenu {
	if global.pause = 0 {
	if !instance_exists(o_buttonleftandroid) { instance_create(x,y,o_buttonleftandroid) }
	if !instance_exists(o_buttonrightandroid) { instance_create(x,y,o_buttonrightandroid) }
	if !instance_exists(o_buttonjumpandroid) { instance_create(x,y,o_buttonjumpandroid) }
	if !instance_exists(o_buttoninteractandroid) { instance_create(x,y,o_buttoninteractandroid) }
	if !instance_exists(o_buttonrestartandroid) { instance_create(x,y,o_buttonrestartandroid) }
	if !instance_exists(o_buttonpauseandroid) { instance_create(x,y,o_buttonpauseandroid) }
	if global.challenges = 0 {
	if global.endless = 0 {
	if global.dailylevel = 0 {
	if global.calendar = 0 {
	if !instance_exists(o_buttonskipandroid) { instance_create(x,y,o_buttonskipandroid) }
	}}}}}}
	}
}
