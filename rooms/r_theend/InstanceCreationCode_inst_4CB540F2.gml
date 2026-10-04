if global.hardmodeunlock = 0 && net_campaign_reward_allowed() {
	global.hardmodeunlock = 1 
	scr_savehardmode()
}
xscale = 0.75
yscale = 0.75