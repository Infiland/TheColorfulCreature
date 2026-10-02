if (!timing_instance_step()) exit;
if room = r_leveleditor {
if !instance_exists(o_player) {
instance_destroy()
	}
}
if global.pause = 1 { exit }

if originaly < 32 {
if change = 1 {
x += spikespeed * (60 / TCC_SIM_HZ)
} else { x -= spikespeed * (60 / TCC_SIM_HZ) }
originaly += spikespeed * (60 / TCC_SIM_HZ)
}

if originaly >= 32 {
if change = 0 { 
	cooldown -= 1 * (60 / TCC_SIM_HZ)
	if cooldown <= 0 {
	change = 1
	x = xstart - originaly
	originaly = 0
	cooldown = originalcooldown
	}
} else {
	cooldown -= 1 * (60 / TCC_SIM_HZ)
	if cooldown <= 0 {
	change = 0
		originaly = 0
	x = xstart
	cooldown = originalcooldown
		}}}