if (!timing_instance_step()) exit;
if global.pause = 1{ exit }
y -= rise * (60 / TCC_SIM_HZ)
rise -= grvwhite * (60 / TCC_SIM_HZ)
timerwhitestart += 1 * (60 / TCC_SIM_HZ)
if timerwhitefinish < timerwhitestart {
	image_alpha -= 0.025 * (60 / TCC_SIM_HZ)
if image_alpha < 0 {
instance_destroy();	
}
}