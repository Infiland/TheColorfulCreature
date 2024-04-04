var cost = floor((global.wheeltimeleft/30) * (0.5 + (multi / 2)))
if global.creditscurrency > cost {
	global.creditscurrency -= cost
	global.wheeltimeleft = 0
	if instance_exists(o_bigwheel) {
	o_bigwheel.wheelspeed = 0
	o_bigwheel.spinned = 0
	o_bigwheel.rewarded = 0
	}
	instance_destroy()
}