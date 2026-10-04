/// @description Variables
// Friends lists and online sessions are Steam features.
if (TCC_GAMEPLAY_QA || TCC_STEAM_ANDROID || !platform_steam()) { instance_destroy(); exit; }
declarecustombutton()
label = loc("NET_FRIENDS")
text = label
friends_playing = 0
refresh_timer = 0

xscale = 0.4
yscale = 0.4
width = 2
oy = 0.8
