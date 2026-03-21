// Store previous position for interpolation
var _prev_x = prev_mx;
var _prev_y = prev_my;

x = mouse_x
y = mouse_y
sprite_index = s_eraser
depth = -1000

// Interpolation: erase blocks along the path from previous to current position
var _gx1 = _prev_x div 32;
var _gy1 = _prev_y div 32;
var _gx2 = mouse_x div 32;
var _gy2 = mouse_y div 32;

if (_gx1 != _gx2 || _gy1 != _gy2) {
	// Bresenham line algorithm to check all intermediate grid cells
	var _dx = abs(_gx2 - _gx1);
	var _dy = abs(_gy2 - _gy1);
	var _sx = sign(_gx2 - _gx1);
	var _sy = sign(_gy2 - _gy1);
	var _err = _dx - _dy;
	var _cx = _gx1;
	var _cy = _gy1;
	
	while (true) {
		// Skip end position (handled by normal collision at current position)
		if !(_cx == _gx2 && _cy == _gy2) {
			var _px = _cx * 32 + 16;
			var _py = _cy * 32 + 16;
			var _deleted = false;
			var _inst;
			
			// Always check blockcheck2 (no LEBuild restriction)
			_inst = instance_position(_px, _py, o_blockcheck2);
			if (_inst != noone) { with(_inst) { instance_destroy(); } }
			
			if (global.LEBuild == 1) {
				// Check foreground object parents and individual types
				var _types = [o_anyblock, o_hazard, o_editoritems,
				              o_door, o_lockeddoor, o_ladder,
				              o_redpassblock, o_yellowpassblock, o_greenpassblock, o_bluepassblock, o_whitepassblock,
				              o_torchLE, o_enemyplayerLE,
				              o_lockedblock, o_unlockedblock,
				              o_portalpurpleopen, o_portalpurpleclosed,
				              o_onewayupblock, o_onewaydownblock, o_onewayrightblock, o_onewayleftblock,
				              o_speedlimit5, o_speedlimit7, o_speedlimit10, o_speedlimit15,
				              o_gravitylimit01, o_gravitylimit05, o_gravitylimit15, o_gravitylimit25,
				              o_zerogravitylimit, o_redblockslope];
				for (var _i = 0; _i < array_length(_types); _i++) {
					_inst = instance_position(_px, _py, _types[_i]);
					if (_inst != noone) {
						with (_inst) { instance_destroy(); }
						_deleted = true;
					}
				}
			}
			else if (global.LEBuild == 2) {
				_inst = instance_position(_px, _py, o_anybackgroundblock);
				if (_inst != noone) {
					with (_inst) { instance_destroy(); }
					_deleted = true;
				}
			}
			
			if (_deleted) {
				audio_play_sound(snd_shooter, 10, 0);
			}
		}
		
		if (_cx == _gx2 && _cy == _gy2) break;
		
		var _e2 = 2 * _err;
		if (_e2 > -_dy) { _err -= _dy; _cx += _sx; }
		if (_e2 < _dx) { _err += _dx; _cy += _sy; }
	}
}

prev_mx = mouse_x;
prev_my = mouse_y;

if device_mouse_check_button_released(0,mb_right) {
instance_create(x,y,o_placeblock)
instance_destroy()
}