if (!platform_steam()) { instance_destroy(); exit; }
maxGames = 3
game = irandom(maxGames)+1
image_xscale = 0.7
image_yscale = 0.7
image_index = game - 1
link = timing_ui_ad_link(game)
timerRotation = 300
timer = timerRotation
gameChanged = 0

if global.noadsinmenusettings = 1 {
	instance_destroy()
}
