/// scr_gamepad_remap
/// Core controller remapping system for all 6 player actions

// ============================================================
// GAMEPAD BUTTON DISPLAY NAME
// Returns a human-readable string for any gp_ constant
// ============================================================
function gamepad_button_display_name(_btn) {
	switch(_btn) {
		case gp_face1: return "A";
		case gp_face2: return "B";
		case gp_face3: return "X";
		case gp_face4: return "Y";
		case gp_shoulderl: return "LB";
		case gp_shoulderlb: return "LT";
		case gp_shoulderr: return "RB";
		case gp_shoulderrb: return "RT";
		case gp_select: return "Back";
		case gp_start: return "Start";
		case gp_stickl: return "L3";
		case gp_stickr: return "R3";
		case gp_padu: return "D-Up";
		case gp_padd: return "D-Down";
		case gp_padl: return "D-Left";
		case gp_padr: return "D-Right";
		default: return "???";
	}
}

// ============================================================
// INITIALIZE CONTROLLER BINDINGS
// Sets up default controller mappings.
// Called from scr_loading() after keyboard defaults are set.
// ============================================================
function gamepad_remap_init() {
	// Default controller bindings (mirror the original hardcoded values)
	global.gp_bind_moveright = gp_padr;
	global.gp_bind_moveleft  = gp_padl;
	global.gp_bind_jump      = gp_face1;      // A button
	global.gp_bind_interact  = gp_shoulderrb;  // RT
	global.gp_bind_skip      = gp_face4;      // Y button
	global.gp_bind_restart   = gp_shoulderlb;  // LB
	
	// Listening state for remapping UI (-1 = not listening, 0-5 = which action)
	global.gp_remap_listening = -1;
}

// ============================================================
// RESET CONTROLLER BINDINGS TO DEFAULTS
// Called when "Default Controls" button is pressed
// ============================================================
function gamepad_remap_defaults() {
	global.gp_bind_moveright = gp_padr;
	global.gp_bind_moveleft  = gp_padl;
	global.gp_bind_jump      = gp_face1;
	global.gp_bind_interact  = gp_shoulderrb;
	global.gp_bind_skip      = gp_face4;
	global.gp_bind_restart   = gp_shoulderlb;
}

// ============================================================
// GET BINDING BY INDEX (0-5)
// Matches the controls index used by o_controlsbuttonsettings
// 0=MoveRight, 1=MoveLeft, 2=Jump, 3=Interact, 4=Skip, 5=Restart
// ============================================================
function gamepad_remap_get(_index) {
	switch(_index) {
		case 0: return global.gp_bind_moveright;
		case 1: return global.gp_bind_moveleft;
		case 2: return global.gp_bind_jump;
		case 3: return global.gp_bind_interact;
		case 4: return global.gp_bind_skip;
		case 5: return global.gp_bind_restart;
	}
	return gp_face1;
}

// ============================================================
// SET BINDING BY INDEX (0-5)
// ============================================================
function gamepad_remap_set(_index, _btn) {
	switch(_index) {
		case 0: global.gp_bind_moveright = _btn; break;
		case 1: global.gp_bind_moveleft  = _btn; break;
		case 2: global.gp_bind_jump      = _btn; break;
		case 3: global.gp_bind_interact  = _btn; break;
		case 4: global.gp_bind_skip      = _btn; break;
		case 5: global.gp_bind_restart   = _btn; break;
	}
}

// ============================================================
// LISTEN FOR GAMEPAD BUTTON PRESS
// Call every step while in listening mode.
// Returns the gp_ constant of the pressed button, or -1 if none.
// Scans all 16 standard buttons on gamepad slot 0.
// ============================================================
function gamepad_remap_listen() {
	var _buttons = [
		gp_face1, gp_face2, gp_face3, gp_face4,
		gp_shoulderl, gp_shoulderlb, gp_shoulderr, gp_shoulderrb,
		gp_select, gp_start, gp_stickl, gp_stickr,
		gp_padu, gp_padd, gp_padl, gp_padr
	];
	for (var _i = 0; _i < array_length(_buttons); _i++) {
		if (gamepad_button_check_pressed(0, _buttons[_i])) {
			return _buttons[_i];
		}
	}
	return -1;
}

// ============================================================
// SAVE CONTROLLER BINDINGS
// Writes to the existing Settings.sav INI file.
// Must be called between ini_open() and ini_close().
// Called from scr_savesettings.
// ============================================================
function gamepad_remap_save() {
	ini_write_real("ControllerBindings", "MoveRight", global.gp_bind_moveright);
	ini_write_real("ControllerBindings", "MoveLeft",  global.gp_bind_moveleft);
	ini_write_real("ControllerBindings", "Jump",      global.gp_bind_jump);
	ini_write_real("ControllerBindings", "Interact",  global.gp_bind_interact);
	ini_write_real("ControllerBindings", "Skip",      global.gp_bind_skip);
	ini_write_real("ControllerBindings", "Restart",   global.gp_bind_restart);
}

// ============================================================
// LOAD CONTROLLER BINDINGS
// Reads from the existing Settings.sav INI file.
// Must be called between ini_open() and ini_close().
// Called from scr_loadsettings.
// ============================================================
function gamepad_remap_load() {
	global.gp_bind_moveright = ini_read_real("ControllerBindings", "MoveRight", gp_padr);
	global.gp_bind_moveleft  = ini_read_real("ControllerBindings", "MoveLeft",  gp_padl);
	global.gp_bind_jump      = ini_read_real("ControllerBindings", "Jump",      gp_face1);
	global.gp_bind_interact  = ini_read_real("ControllerBindings", "Interact",  gp_shoulderrb);
	global.gp_bind_skip      = ini_read_real("ControllerBindings", "Skip",      gp_face4);
	global.gp_bind_restart   = ini_read_real("ControllerBindings", "Restart",   gp_shoulderlb);
}
