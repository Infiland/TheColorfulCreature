controlerx = mouse_x
controlery = mouse_y

sprite_set_offset(s_playerred,0,0)

gamepad_set_vibration(0,0,0)

rousr_dissonance_set_small_image(undefined,undefined)
hidehud()

instance_destroy(o_smoothcamera)

if os_type = os_android {
instance_destroy(o_buttoninteractandroid)
instance_destroy(o_buttonjumpandroid)
instance_destroy(o_buttonpauseandroid)
instance_destroy(o_buttonleftandroid)
instance_destroy(o_buttonrightandroid)
instance_destroy(o_buttonrestartandroid)

}

if steam_initialised()
    {
        global.steam_api = true;
    }
global.appid = steam_get_app_id();

gamebootup = 0
image_speed = 0
image_index = 0
global.skinschange = 0
global.boss1 = 0
global.boss2 = 0
global.boss3 = 0
global.boss4 = 0
global.boss5 = 0
audio_master_gain(global.mastervolume)
global.boss2health = 6
global.hardmode = 0
global.dailylevel = 0
global.pause = 0
global.time = 0
global.LEBuild = 1
global.leveleditormusic = 0
global.endlesslevel	= 0
global.endlessmusicchange = 10
global.endless1upchange = 10
global.level100trap = 0

global.checkpointX = 0
global.checkpointY = 0
global.checkpointCOLOR = -1
global.checkpointGRV = 0

if !instance_exists(o_narrator) { instance_create(x,y,o_narrator) }
scr_loadsettings()
scr_loadskins()
scr_savestats()

global.maxfps = 60
game_set_speed(global.maxfps,gamespeed_fps)

pitch = 1
//Settings
audio_stop_sound(m_goodending)

if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1);
}
audio_stop_sound(m_goodending)

if global.skin012 = 0 {
if global.totalcoins > 249 {global.skin012 = 1}}
if global.skin015 = 0 {
if global.totaldeaths > 999 {global.skin015 = 1}}
if global.skin034 = 0 {
if global.total1ups > 249 {global.skin034 = 1}}
if global.skin035 = 0 {
if global.totaltime > 172800 {global.skin035 = 1}}

if global.totaltime > 50000 {
	if global.hat008 = -1 {
		global.hat008 = 0
	}
}

if global.hat008 = -1 {
if global.calendarcurrentmonth = 12 {
global.hat008 = 0
}}
if global.hat034 = -1 { global.hat034 = 0 }

if gamebootup = 0 {
alarm[0] = 15
}
AdMob_Banner_Hide()
gamebootup = 1
if instance_exists(o_deathcounter) {instance_destroy(o_deathcounter)}
if instance_exists(o_ammocounter) {instance_destroy(o_ammocounter)}
if instance_exists(o_levelcounter) {instance_destroy(o_levelcounter)}
audio_sound_gain(snd_reload,global.soundvolume,1)
audio_sound_gain(snd_gunvoice,global.soundvolume,1)