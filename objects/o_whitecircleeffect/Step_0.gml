if global.pause = 1{ exit }
y -= rise * (60 / global.maxfps)
rise -= grvwhite * (60 / global.maxfps)
timerwhitestart += 1 * (60 / global.maxfps)
if timerwhitefinish < timerwhitestart {
	image_alpha -= 0.025 * (60 / global.maxfps)
if image_alpha < 0 {
instance_destroy();	
}
}