/*if room = r_leveleditor {
if !instance_exists(o_player) {
instance_destroy()
	}
}*/
if global.pause = 1 { exit }
if lockmove = true { exit }

if canmove = true {
if change = 0 {
y -= spikespeed * (60 / global.maxfps)
} else { y += spikespeed * (60 / global.maxfps) }
}

if !place_meeting(x-32,y-32+dist,o_anyblock) || place_meeting(x,y-9+dist,o_anyblock) {
if change = 0 { 
	canmove = false
	cooldown -= 1 * (60 / global.maxfps)
	if cooldown <= 0 {
	change = 1
	cooldown = originalcooldown
	canmove = true
	}
}}

if !place_meeting(x-32,y+32-dist,o_anyblock) || place_meeting(x,y+9-dist,o_anyblock) {
if change = 1 { 
	canmove = false
	cooldown -= 1 * (60 / global.maxfps)
	if cooldown <= 0 {
	change = 0
	cooldown = originalcooldown
	canmove = true
	}
}}