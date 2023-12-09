function death() {
	rousr_dissonance_set_small_image("dead","Just Died")
	global.deaths += 1
	global.totaldeaths += 1;
	
	global.androidadtimer -= 20
	
	//Spikes
	if instance_place(x,y,o_allspikes)  {global.totalspikedeaths += 1}
	if instance_place(x,y,o_goldenspike)  {global.totalgoldspikedeaths += 1
if !steam_get_achievement("GOLDEN_SPIKE_DEATH") { steam_set_achievement("GOLDEN_SPIKE_DEATH") } //GOLDEN SPIKE ACHIEVEMENT
		}
		if instance_place(x,y,o_weirdspike)  {global.totalweirdspikedeaths += 1
if !steam_get_achievement("WEIRD_SPIKE_DEATH") { steam_set_achievement("WEIRD_SPIKE_DEATH") } //WEIRD SPIKE ACHIEVEMENT
		}
	if instance_place(x,y,o_allinvspikes) {global.totalinvisiblespikedeaths += 1}
	if instance_place(x,y,o_allvertspikes) {global.totalverticalspikedeaths += 1}
	if instance_place(x,y,o_allhorispikes) {global.totalhorizontalspikedeaths += 1}
	//Enemy Player
	if instance_place(x,y,o_enemyplayer) {global.totaltroopdeaths += 1}
	
	if instance_place(x,y,o_bulletleft) || instance_place(x,y,o_bulletright) {
	global.totalbulletdeaths += 1	
	}
	if instance_place(x,y,o_rocket) || instance_place(x,y,o_rocket2) {
	global.totalrocketdeaths += 1	
	}
	
	if room = r_boss2 {
		if global.boss2 = 0 {
		global.boss2health = 6	
		}}
	if global.skin015 = 0 {
	if global.totaldeaths > 999 {global.skin015 = 1}
	}
	
if global.endless = 1 {
if global.endlessrunmode = 1 {
global.difficultyincreaseER += 1
var difficultydrop = choose(1,2,2,2)
if difficultydrop = 1 {
if global.difficultyER != 1 {
instance_create(x,y,o_difficultydownER)
global.difficultyER -= 1
}}}}
	
	scr_savestats()
	var offset = 0
	if instance_exists(o_player) {
	if o_player.zerogrv = 1 { offset = -16 }
	}
	instance_create(x+offset,y+offset,o_playerdead)
	instance_destroy()
	if global.skinselected = 24 {
	with(o_playerdead) {
	x -= 16
	y -= 16	
	}
	}
	if global.pickup = 1 {
	global.special -= 1
	}
	global.pickup = 0
	audio_sound_gain(snd_dead,global.soundvolume,1)
	audio_play_sound(snd_dead,5,0);
	if global.hardmode = 0 {
	if global.challenges = 0 {
	if room != r_leveleditor {
	scr_savegame()
	}}}
	if room = r_leveleditor {
	if instance_exists(o_enemyplayer) {
	instance_destroy(o_enemyplayer)
	instance_destroy(o_boredomblock)
	}}


}
