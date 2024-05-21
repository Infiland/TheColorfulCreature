sprite_set_offset(s_playerred,0,0)

//Drop random item
steam_inventory_trigger_item_drop(99)
steam_inventory_request_prices();

//Rich presence
steam_set_rich_presence("steam_display", "In Main Menu")

gamepad_set_vibration(0,0,0)

hidehud()

instance_destroy(o_smoothcamera)

instance_create(930,352,o_profilepicture)

//Hide Android control on main menu
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
global.boss1 = 0
global.boss2 = 0
global.boss3 = 0
global.boss4 = 0
global.boss5 = 0
audio_master_gain(global.mastervolume)
global.boss2health = 6
global.hardmode = 0
global.dailylevel = 0
global.endless = 0
global.workshop = 0
global.challenges = 0
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

//Set FPS to 60
global.maxfps = 60
game_set_speed(global.maxfps,gamespeed_fps)

//Skin unlocks
if global.skin[12] = 0 {
if global.totalcoins > 249 {global.skin[12] = 1}}
if global.skin[15] = 0 {
if global.totaldeaths > 999 {global.skin[15] = 1}}
if global.skin[34] = 0 {
if global.total1ups > 249 {global.skin[34] = 1}}
if global.skin[35] = 0 {
if global.totaltime > 172800 {global.skin[35] = 1}}

if global.totaltime > 50000 {
	if global.hat[8] = -1 {
		global.hat[8] = 0
	}
}

if global.hat[8] = -1 {
if global.calendarcurrentmonth = 12 {
global.hat[8] = 0
}}
if global.hat[34] = -1 { global.hat[34] = 0 }

//Android banner hide
AdMob_Banner_Hide()
//Fix sound pitch
audio_sound_gain(snd_reload,global.soundvolume,1)
audio_sound_gain(snd_gunvoice,global.soundvolume,1)
audio_stop_sound(m_goodending)
audio_sound_gain(m_credits,0,1)
audio_stop_sound(m_credits)

//World progression is autoloaded here if someone ran the older version of the game for Level Select
if global.world1 = 1 && global.worldProgression < 20 {
	global.worldProgression = 20
}
if global.world2 = 1 && global.worldProgression < 40 {
	global.worldProgression = 40
}
if global.world3 = 1 && global.worldProgression < 60 {
	global.worldProgression = 60
}
if global.world4 = 1 && global.worldProgression < 80 {
	global.worldProgression = 80
}
if global.world5 = 1 && global.worldProgression < 100 {
	global.worldProgression = 100
}

audio_sound_pitch(m_mainmenu,1)
audio_sound_gain(m_mainmenu,global.musicvolume,1)
if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1);
}