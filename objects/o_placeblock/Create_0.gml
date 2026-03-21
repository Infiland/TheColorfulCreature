image_alpha = 0
epicfx = 0
realx = 0
realy = 0
depth = -10001
global.canchange = false
prev_grid_x = -1
prev_grid_y = -1

// Check if placement is blocked at current x,y
check_blocked = function() {
	if (global.LEBuild == 1) {
		if (place_meeting(x,y,o_player) || place_meeting(x,y,o_redblockslope) || place_meeting(x,y,o_editoritems) || place_meeting(x,y,o_anyblock) || place_meeting(x,y,o_allspikes) || place_meeting(x,y,o_allinvspikes) || place_meeting(x,y,o_door) || place_meeting(x,y,o_portalpurpleclosed) || place_meeting(x,y,o_portalpurpleopen) || place_meeting(x,y,o_redpassblock) || place_meeting(x,y,o_yellowpassblock) || place_meeting(x,y,o_greenpassblock) || place_meeting(x,y,o_bluepassblock) || place_meeting(x,y,o_whitepassblock) || place_meeting(x,y,o_torchLE) || place_meeting(x,y,o_enemyplayerLE) || place_meeting(x,y,o_enemyplayer) || place_meeting(x,y,o_ladder) || place_meeting(x,y,o_deathblock) || place_meeting(x,y,o_blockcheck2) || place_meeting(x,y,o_gravitylimit01) || place_meeting(x,y,o_gravitylimit05) || place_meeting(x,y,o_gravitylimit15) || place_meeting(x,y,o_gravitylimit25) || place_meeting(x,y,o_speedlimit5) || place_meeting(x,y,o_speedlimit7) || place_meeting(x,y,o_speedlimit10) || place_meeting(x,y,o_speedlimit15) || place_meeting(x,y,o_lockedblock) || place_meeting(x,y,o_unlockedblock) || place_meeting(x,y,o_zerogravitylimit)) {
			return true;
		}
	}
	if (global.LEBuild == 2) {
		if (instance_position(x,y,o_anyblock) || instance_position(x,y,o_deathblock) || instance_position(x,y,o_boxLE) || instance_position(x,y,o_anybackgroundblock) || instance_position(x,y,o_onewaydownblock) || instance_position(x,y,o_onewayupblock) || instance_position(x,y,o_onewayleftblock) || instance_position(x,y,o_onewayrightblock)) {
			return true;
		}
	}
	return false;
}

// Check canchange conditions at current x,y
check_canchange = function() {
	if (global.LEBuild == 1) {
		if ((global.LES == 6 || global.LES == 7 || global.LES == 8 || global.LES == 9 || global.LES == 10) && (place_meeting(x,y,o_playerspawner) || place_meeting(x,y,o_redblock) || place_meeting(x,y,o_yellowblock) || place_meeting(x,y,o_greenblock) || place_meeting(x,y,o_blueblock) || place_meeting(x,y,o_whiteblock))) {
			return true;
		}
		if ((global.LES == 6 || global.LES == 7 || global.LES == 8 || global.LES == 9) && (place_meeting(x,y,o_yellowpassblock) || place_meeting(x,y,o_redpassblock) || place_meeting(x,y,o_greenpassblock) || place_meeting(x,y,o_bluepassblock))) {
			return true;
		}
		if ((global.LES == 57 || global.LES == 58) && place_meeting(x,y,o_box)) { return true; }
		if ((global.LES == 60 || global.LES == 58) && place_meeting(x,y,o_boxwithammo)) { return true; }
		if ((global.LES == 60 || global.LES == 57) && place_meeting(x,y,o_boxwithinfiniteammo)) { return true; }
	}
	if (global.LEBuild == 2) {
		if (place_meeting(x,y,o_redblockbackgroundslope) || place_meeting(x,y,o_yellowblockbackgroundslope) || place_meeting(x,y,o_greenblockbackgroundslope) || place_meeting(x,y,o_blueblockbackgroundslope) || place_meeting(x,y,o_whiteblockbackgroundslope) || place_meeting(x,y,o_iceblockbackgroundslope) || place_meeting(x,y,o_deathblockbackgroundslope) || place_meeting(x,y,o_boxblockbackgroundslope)) {
			return true;
		}
	}
	return false;
}

// Destroy the existing block for canchange replacement at current x,y
do_canchange_destroy = function() {
	var _inst;
	if (global.LEBuild == 1) {
		if (global.LES >= 6 && global.LES <= 10) {
			_inst = instance_place(x,y,o_redblock); if (_inst != noone) { with(_inst) { instance_destroy(); } }
			_inst = instance_place(x,y,o_yellowblock); if (_inst != noone) { with(_inst) { instance_destroy(); } }
			_inst = instance_place(x,y,o_greenblock); if (_inst != noone) { with(_inst) { instance_destroy(); } }
			_inst = instance_place(x,y,o_blueblock); if (_inst != noone) { with(_inst) { instance_destroy(); } }
			_inst = instance_place(x,y,o_whiteblock); if (_inst != noone) { with(_inst) { instance_destroy(); } }
			_inst = instance_place(x,y,o_playerspawner); if (_inst != noone) { with(_inst) { instance_destroy(); } }
		}
		if (global.LES >= 6 && global.LES <= 9) {
			_inst = instance_place(x,y,o_redpassblock); if (_inst != noone) { with(_inst) { instance_destroy(); } }
			_inst = instance_place(x,y,o_yellowpassblock); if (_inst != noone) { with(_inst) { instance_destroy(); } }
			_inst = instance_place(x,y,o_greenpassblock); if (_inst != noone) { with(_inst) { instance_destroy(); } }
			_inst = instance_place(x,y,o_bluepassblock); if (_inst != noone) { with(_inst) { instance_destroy(); } }
		}
		if (global.LES == 57 || global.LES == 58) { _inst = instance_place(x,y,o_box); if (_inst != noone) { with(_inst) { instance_destroy(); } } }
		if (global.LES == 60 || global.LES == 58) { _inst = instance_place(x,y,o_boxwithammo); if (_inst != noone) { with(_inst) { instance_destroy(); } } }
		if (global.LES == 60 || global.LES == 57) { _inst = instance_place(x,y,o_boxwithinfiniteammo); if (_inst != noone) { with(_inst) { instance_destroy(); } } }
	} else if (global.LEBuild == 2) {
		_inst = instance_place(x,y,o_anybackgroundblock); if (_inst != noone) { with(_inst) { instance_destroy(); } }
	}
}