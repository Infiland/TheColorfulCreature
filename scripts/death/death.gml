function death() {
	global.deaths += 1
	increase_stat("totaldeaths","QUESTdeaths",1)
	
	global.androidadtimer -= 20
	
	if instance_place(x,y,o_allspikes)  { //Spike Deaths
		increase_stat("totalspikedeaths","QUESTspikedeaths",1)
		}
	if instance_place(x,y,o_goldenspike)  { //Golden Spike Deaths
		increase_stat("totalgoldspikedeaths","QUESTgoldspikedeaths",1)
if !steam_get_achievement("GOLDEN_SPIKE_DEATH") { steam_set_achievement("GOLDEN_SPIKE_DEATH") } //GOLDEN SPIKE ACHIEVEMENT
		}
		if instance_place(x,y,o_weirdspike)  { //Weird Spike Deaths
			increase_stat("totalweirdspikedeaths","QUESTweirdspikedeaths",1)
if !steam_get_achievement("WEIRD_SPIKE_DEATH") { steam_set_achievement("WEIRD_SPIKE_DEATH") } //WEIRD SPIKE ACHIEVEMENT
		}
	if instance_place(x,y,o_allinvspikes) { //Invisible Spike Deaths
		increase_stat("totalinvisiblespikedeaths","QUESTinvisiblespikedeaths",1)
		}
	if instance_place(x,y,o_allvertspikes) { //Vertical Spike Deaths
		increase_stat("totalverticalspikedeaths","QUESTverticalspikedeaths",1)
		}
	if instance_place(x,y,o_allhorispikes) { //Horizontal Spike Deaths
		increase_stat("totalhorizontalspikedeaths","QUESThorizontalspikedeaths",1)
	}
	//Enemy Player
	if instance_place(x,y,o_enemyplayer) {
		increase_stat("totaltroopdeaths","QUESTtroopdeaths",1)
		}
	//Bullet Deaths
	if instance_place(x,y,o_bulletleft) || instance_place(x,y,o_bulletright) {
	increase_stat("totalbulletdeaths","QUESTbulletdeaths",1)
	}
	//Rocket Deaths
	if instance_place(x,y,o_rocket) || instance_place(x,y,o_rocket2) {
	increase_stat("totalrocketdeaths","QUESTrocketdeaths",1)
	}
	
	if room = r_boss2 {
		if global.boss2 = 0 {
		global.boss2health = 6	
		}}
	if global.skin[15] = 0 {
	if global.totaldeaths > 999 {global.skin[15] = 1}
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
