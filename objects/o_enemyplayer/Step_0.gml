if (!timing_instance_step()) exit;
// === Early exit ===
if global.pause == 1 { exit }
if dontxrayfix == 1 { exit }

// Activate the neighborhood before collision, not after movement. Visibility
// belongs to simulation so minimized/headless/no-Draw runs use the same AI.
if (global.biglevelperfsettings > 1) {
    timing_activate_region(x - 64, y - 64 - abs(vsp), 160, 160 + 2 * abs(vsp), true);
}
cansee = 1;
if (instance_exists(o_player)) {
    var _sight_dx = o_player.x - x, _sight_dy = o_player.y - y;
    if (point_distance(x, y, o_player.x, o_player.y) <= 400) {
        if (global.biglevelperfsettings > 1) {
            timing_activate_region(min(x, o_player.x) - 32, min(y, o_player.y) - 32,
                abs(_sight_dx) + 96, abs(_sight_dy) + 96, true);
        }
        cansee = collision_line(x + 16, y + 16, o_player.x + 16, o_player.y + 16, o_anyblock, false, false) != noone;
        if (!cansee && instance_exists(o_slope)) {
            var _samples = max(1, ceil(point_distance(x, y, o_player.x, o_player.y) / 4));
            for (var _sample = 0; _sample <= _samples; ++_sample) {
                var _rayx = x + 16 + _sight_dx * _sample / _samples;
                var _rayy = y + 16 + _sight_dy * _sample / _samples;
                if (scr_slope_rect(_rayx, _rayy, _rayx, _rayy) != noone) { cansee = 1; break; }
            }
        }
    }
}

// === Timers ===
if amountofjumps > 0 { amountofjumps -= 1 * (60/TCC_SIM_HZ) }
if noreaction == 1 { reactiontime = 0 }
if state != 1 || bored != 0 || reactiontime > 0 { high_jump_ticks = 0; }
// An alerted troop must finish its reaction delay before it can pursue or
// climb. Keep falling/collision active during the delay.
if state == 1 && reactiontime > 0 { move = 0; climbing = 0; }

// === Horizontal wall collision ===
// Nearby triangle movement owns the slope-to-flat seam as well as its wall test.
if !scr_slope_near_actor(hsp * move, 0, 3) && place_meeting(x + hsp * move, y, o_anyblock) {
	horizontal = 1
} else {
	horizontal = 0
}
if horizontal == 1 {
	move = 0
	x -= move
}

// === Water check ===
if place_meeting(x, y, o_water) { inwater = 2 } else { inwater = 1 }

// === Ladder climbing ===
if climbing == 1 {
	if place_meeting(x, y, o_ladder) {
		vsp = -3
		if y <= climb_target_y { climbing = 0; vsp = 0 }
		if !place_meeting(x, y - 4, o_ladder) { climbing = 0; vsp = 0 }
		if !audio_is_playing(snd_ladder) { audio_play_sound(snd_ladder, 0, 0) }
	} else {
		climbing = 0
	}
}

// === Gravity + vertical collision ===
if climbing == 0 { vsp = (vsp + (grv / inwater)) }
var _vertical_start_y = y;
var _vertical_direction = sign(vsp);
var _slope_vertical = scr_slope_resolve_vertical(vsp * max(1, 60 / TCC_SIM_HZ));
var solid_collision = place_meeting(x, y + vsp, o_anyblock)

var oneway_collision = false
if vsp > 0 {
	if place_meeting(x, y + vsp, o_onewayupblock) {
		var platform = instance_place(x, y + vsp, o_onewayupblock)
		if platform != noone {
			if bbox_bottom <= platform.bbox_top {
				oneway_collision = true
			}
		}
	}
}

if solid_collision or oneway_collision {
	vsp = 0
	onground = 1
}
var _vertical_move = vsp * (60 / TCC_SIM_HZ);
if (_slope_vertical.blocked && _vertical_direction * (y - _vertical_start_y + _vertical_move)
    >= _vertical_direction * _slope_vertical.dy) {
    y = _vertical_start_y + _slope_vertical.dy;
    if (_vertical_direction > 0) onground = 1;
    vsp = 0;
} else {
    y += _vertical_move;
    if (!solid_collision && !oneway_collision) onground = 0;
}

// === Main AI (active states only) ===
if state != 2 {
	// Terminal velocity
	if vsp > 30 * (60/TCC_SIM_HZ) { vsp = 30 * (60/TCC_SIM_HZ) }

	// === Player detection ===
	if bored == 0 {
		if instance_exists(o_player) {
			var _dist = distance_to_object(o_player);
			// Detect by sight (long range) or proximity/hearing (short range, through walls)
			if (cansee == 0 && _dist < 250) || _dist < 100 {
				state = 1
				if troopsound < 2 { scr_troopvoiceline() }
			}
			if _dist > 350 {
				state = 0
				chase_direction = 0
				reactiontime = min(25, reactiontime + 1.05 * (60 / TCC_SIM_HZ))
				if troopsound < 2 { scr_troopvoiceline() }
			}
		}
	}
	if state == 1 && instance_exists(o_player) {
		var _target_dx = o_player.x - x;
		// A player jumping past a troop gets a brief opportunity to escape.
		// The dead zone avoids repeated turns when their centers are nearly equal.
		if abs(_target_dx) > 16 {
			var _target_direction = sign(_target_dx);
			if chase_direction != 0 && chase_direction != _target_direction {
				if noreaction != 1 { reactiontime = max(reactiontime, 12); }
				high_jump_ticks = 0;
				nav_path = [];
				nav_path_index = 0;
				nav_recalc_timer = min(nav_recalc_timer, 1);
			}
			chase_direction = _target_direction;
		}
	}
	// Count once per simulation step, even after the player ducks behind a wall.
	// This is the existing 25/60-second reaction delay at every configured FPS.
	if state == 1 && reactiontime > 0 {
		reactiontime = max(0, reactiontime - (60 / TCC_SIM_HZ));
		move = 0;
		climbing = 0;
	}

	// === Horizontal movement ===
	var _horizontal_move = ((hsp * move) * (60/TCC_SIM_HZ)) / inwater;
    if (scr_slope_near_actor(_horizontal_move, 0, 3)) {
        var _slope_horizontal = scr_slope_resolve_horizontal(_horizontal_move, vsp >= 0);
        x += _slope_horizontal.dx;
        y += _slope_horizontal.dy;
        if (_slope_horizontal.blocked) horizontal = 1;
    } else {
        if (place_meeting(x + _horizontal_move, y, o_anyblock)) {
            horizontal = 1;
            move = 0;
        } else {
            x += _horizontal_move;
        }
    }

	// === Chase behavior ===
	if bored == 0 {
		if state == 1 && reactiontime <= 0 {
			if instance_exists(o_player) {
				var _px = o_player.x
				var _py = o_player.y

				// Recalculate path periodically
				var _navigation = scr_troop_nav_cache();
				if (nav_generation != _navigation.generation) {
					nav_path = [];
					nav_recalc_timer = min(nav_recalc_timer, 1 + (((nav_stagger mod 8) + 8) mod 8));
				}
				nav_recalc_timer -= 1 * (60 / TCC_SIM_HZ)
				if nav_recalc_timer <= 0 && scr_troop_nav_request_ready() {
					nav_path = scr_troop_build_nav_path(_px, _py)
					nav_path_index = 0
					nav_generation = _navigation.generation
					nav_recalc_timer = 45
				}

				// Follow path if we have one
				if array_length(nav_path) > 0 {
					high_jump_ticks = 0;
					scr_troop_follow_path()
				} else {
					// Use the same center dead zone as the turn reaction above. An
					// immediate close-range reversal would bypass that delay and
					// track directly underneath a player jumping past the troop.
					move = abs(_px - x) > 16 ? sign(_px - x) : 0;

					if scr_troop_on_ground() {
						if _py < y + 20 {
							// A ledge behind the troop is not an obstacle to its chase.
							if move != 0 && scr_troop_ledge_ahead(move * 20) { scr_troop_jump() }
						}
					}
					// React to an airborne target instead of immediately jumping into
					// its escape arc. Terrain/path jumps remain available after alert.
					if cansee == 0 && _py < y - 60 && scr_troop_on_ground() && scr_troop_head_clear() {
						high_jump_ticks += (60 / TCC_SIM_HZ);
						if noreaction == 1 || high_jump_ticks >= 12 {
							scr_troop_jump();
							high_jump_ticks = 0;
						}
					} else { high_jump_ticks = 0; }
				}
			}
		}
	}

	// === One-way block deflection ===
	if place_meeting(x + 16, y, o_onewayleftblock) { move = -1 }
	if place_meeting(x - 16, y, o_onewayrightblock) { move = 1 }
	if place_meeting(x + 16, y, o_movingplatforms) { move = -1 }
	if place_meeting(x - 16, y, o_movingplatforms) { move = 1 }
	if place_meeting(x - 16, y, o_movingplatforms) and place_meeting(x + 16, y, o_movingplatforms) { move = 0 }

	// === Boredom system ===
	if instance_exists(o_boredomblock) {
		// Idle wander (state 0)
		if state == 0 {
			if move == 0 {
				if place_meeting(x, y, o_boredomblock) {
					if o_boredomblock.image_index == 2 {
						if distance_to_object(o_boredomblock) < 50 {
							if !scr_troop_wall_ahead(hsp * move + 4) {
								move = irandom_range(-1, 1)

								// Check left side open
								if !scr_troop_wall_ahead(-40) {
									move = -1
									tcc_randomize()
									rngjump = irandom_range(0, 2)
									if rngjump == 2 {
										if scr_troop_head_clear() {
											if scr_troop_on_ground() { scr_troop_jump() }
										}
									}
								}

								// Jump toward player when on ground
								if scr_troop_on_ground() {
									if scr_troop_head_clear() {
										if instance_exists(o_player) {
											if o_player.y < y {
												if scr_troop_ledge_ahead(20) { scr_troop_jump() }
												if scr_troop_ledge_ahead(-20) { scr_troop_jump() }
											}
										}
									}
								}

								// Check right side open
								if !scr_troop_wall_ahead(40) {
									rngjump = irandom_range(0, 2)
									if rngjump == 2 {
										if scr_troop_head_clear() {
											if scr_troop_on_ground() { scr_troop_jump() }
										}
										move = 1
									}
								}
							}
						}
					}
				}
			}
			if move == 1 {
				if distance_to_object(o_boredomblock) > 50 {
					move = 0
				}
			}
		}

		// Chase wander (state 1)
		if state == 1 {
			if place_meeting(x, y, o_boredomblock) {
				if o_boredomblock.image_index == 2 {
					if distance_to_object(o_boredomblock) < 50 {
						if !scr_troop_wall_ahead(hsp * move + 4) {
							rngjump = irandom_range(1, 2)
							if rngjump == 2 {
								if scr_troop_on_ground() { scr_troop_jump() }
							}
						}
					}
				}
			}
		}
	}

	// === Boredom timer ===
	if state == 1 {
		boredchasing += 1 * (60 / TCC_SIM_HZ)
	}
	if boredchasing > 500 * (60/TCC_SIM_HZ) {
		state = 0
		if troopsound < 2 { scr_troopvoiceline() }
		bored = 1
	}
	if bored == 1 {
		boredchasing -= 1 * (60/TCC_SIM_HZ)
		if cansee == 0 {
			if instance_exists(o_player) {
				if y == o_player.y { boredchasing -= 4 * (60/TCC_SIM_HZ) }
			}
		}
	}
	if boredchasing < 0 {
		if cansee == 0 { state = 1 }
		if troopsound < 2 { scr_troopvoiceline() }
		bored = 0
	}
}

// Deflection and idle-wander decisions above may set a direction. Do not let
// that direction bypass the alert delay on the next step.
if state == 1 && reactiontime > 0 { move = 0; climbing = 0; }

// === Cleanup / death checks ===
if y > room_height { scr_troop_defeat(); exit; }
if instance_exists(o_playerdeadLE) { instance_destroy(); exit; }
if place_meeting(x, y, o_deathblock) { scr_troop_defeat(); exit; }

// === Full idle -> chase transition ===
if state == 2 {
	if instance_exists(o_player) {
		var _dist = distance_to_object(o_player);
		if (cansee == 0 && _dist < 250) || _dist < 100 {
			state = 1
		}
	}
}

// === Bullet dodge + deaf system ===
if preparedforbullet > 0 { preparedforbullet -= 1 * (60/TCC_SIM_HZ) }
if state != 1 {
	if bored == 0 {
		if onground == 1 {
			if preparedforbullet < 50 {
				if place_meeting(x + 70, y + 1, o_playerbullet) or place_meeting(x - 70, y + 1, o_playerbullet) {
					scr_troop_jump()
					preparedforbullet += irandom_range(10 * (60 / TCC_SIM_HZ), 50 * (60 / TCC_SIM_HZ))
					state = 1
				}

				if deaf == 0 {
					if distance_to_object(o_lastshotplayer) < 128 {
						state = 1
						if troopsound < 2 { scr_troopvoiceline() }
					}
				}
			}
		}
	}
}

// === Voice line cooldown ===
if troopsound > 0 { troopsound -= 1 * (60/TCC_SIM_HZ) }

// === Performance culling ===
if global.biglevelperfsettings < 1 { exit }
timing_activate_region(x - 50, y - 50 + min(0, vsp), 132, 132 + abs(vsp), true)
