// === Early exit ===
if global.pause == 1 { exit }
if dontxrayfix == 1 { exit }

// === Timers ===
if amountofjumps > 0 { amountofjumps -= 1 * (60/global.maxfps) }
if noreaction == 1 { reactiontime = 0 }

// === Horizontal wall collision ===
if place_meeting(x + hsp * move, y, o_anyblock) {
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

// === Gravity + vertical collision ===
vsp = (vsp + (grv / inwater))
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
y = y + vsp * (60 / global.maxfps)

// === Main AI (active states only) ===
if state != 2 {
	// Terminal velocity
	if vsp > 30 * (60/global.maxfps) { vsp = 30 * (60/global.maxfps) }

	// === Player detection ===
	if bored == 0 {
		if instance_exists(o_player) {
			if cansee == 0 {
				if distance_to_object(o_player) < 100 {
					state = 1
					if reactiontime >= 0 {
						reactiontime -= 1 * (60 / global.maxfps)
					}
					if troopsound < 2 { scr_troopvoiceline() }
				}
			}
			if distance_to_object(o_player) > 150 {
				state = 0
				if reactiontime <= 30 {
					reactiontime += 0.05 * (60 / global.maxfps)
				}
				reactiontime += 1 * (60 / global.maxfps)
				if troopsound < 2 { scr_troopvoiceline() }
			}
		}
	}

	// === Horizontal movement ===
	x += ((hsp * move) * (60/global.maxfps)) / inwater

	// === Chase behavior ===
	if bored == 0 {
		if state == 1 {
			if instance_exists(o_player) {
				// Move toward player
				if x < o_player.x { move = 1 }
				if x > o_player.x { move = -1 }

				// Jump over obstacles when on ground and player is nearby above
				if scr_troop_on_ground() {
					if o_player.y < y + 20 {
						if scr_troop_ledge_ahead(20) { scr_troop_jump() }
						if scr_troop_ledge_ahead(-20) { scr_troop_jump() }
					}
				}

				// Jump up to reach player significantly above
				if o_player.y < y - 60 {
					if scr_troop_on_ground() {
						if scr_troop_head_clear() {
							if reactiontime < 0 {
								scr_troop_jump()
							}
						}
					}
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
									randomize()
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
		boredchasing += 1 * (60 / global.maxfps)
	}
	if boredchasing > 500 * (60/global.maxfps) {
		state = 0
		if troopsound < 2 { scr_troopvoiceline() }
		bored = 1
	}
	if bored == 1 {
		boredchasing -= 1 * (60/global.maxfps)
		if cansee == 0 {
			if instance_exists(o_player) {
				if y == o_player.y { boredchasing -= 4 * (60/global.maxfps) }
			}
		}
	}
	if boredchasing < 0 {
		if cansee == 0 { state = 1 }
		if troopsound < 2 { scr_troopvoiceline() }
		bored = 0
	}
}

// === Cleanup / death checks ===
if y > room_height { instance_destroy() }
if instance_exists(o_playerdeadLE) { instance_destroy() }
if place_meeting(x, y, o_deathblock) { instance_destroy() }

// === Full idle -> chase transition ===
if state == 2 {
	if cansee == 0 {
		if instance_exists(o_player) {
			if distance_to_object(o_player) < 100 {
				state = 1
			}
		}
	}
}

// === Bullet dodge + deaf system ===
if preparedforbullet > 0 { preparedforbullet -= 1 * (60/global.maxfps) }
if state != 1 {
	if bored == 0 {
		if onground == 1 {
			if preparedforbullet < 50 {
				if place_meeting(x + 70, y + 1, o_playerbullet) or place_meeting(x - 70, y + 1, o_playerbullet) {
					scr_troop_jump()
					preparedforbullet += irandom_range(10 * (60 / global.maxfps), 50 * (60 / global.maxfps))
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
if troopsound > 0 { troopsound -= 1 * (60/global.maxfps) }

// === Performance culling ===
if global.biglevelperfsettings < 1 { exit }
instance_activate_region(x - 50, y - 50 + vsp, x + 50, y + 50, true)
