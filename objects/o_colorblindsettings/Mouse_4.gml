if global.choosesettings != 1 { exit }


global.colorblindsettings += 1
if global.colorblindsettings > 4 {
global.colorblindsettings = 0

//instance_destroy(o_ColorBlindnessSimulation)
}
if global.colorblindsettings > 0 {
if !instance_exists(o_ColorBlindnessSimulation){
instance_create(x,y,o_ColorBlindnessSimulation)
}}

shader_set(xot_cbs_shGrayscale)

	if global.isgrayscale = true {
	if room != r_settings {
	if global.endless = 0 {
	if global.challenges = 0 {
	global.isgrayscale = false
	scr_saveachievements()
	}}}}
	
scr_savesettings()