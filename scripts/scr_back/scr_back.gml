function scr_back(){
if !instance_exists(o_settingspausemenu) {
if global.endless = 1 {
audio_stop_all()
room_goto(r_endlessrunmenu)
instance_destroy(o_levelcounter)
if global.infinitelivessettings = 0 {
	
if global.endlessrunmode = 1 {
if global.newendlesslevelhighscore < global.endlesslevel {
global.newendlesslevelhighscore = global.endlesslevel
}}
if global.endlessrunmode = 2 {
if global.endlesslevelhighscore < global.endlesslevel {
global.endlesslevelhighscore = global.endlesslevel
}}

if global.endlessrunmode != 3 {
if global.skin[22] = 0 {
if global.endlesslevelhighscore > 49 || global.newendlesslevelhighscore > 49 {
global.skin[22] = 1
}}}

scr_saveendless()
if global.endlessrunmode != 3 {
global.creditscurrency += floor((global.endlesslevel / 2) * global.creditsmultiplier)
} else { global.creditscurrency += floor((global.endlesslevel / 5) * global.creditsmultiplier) }
scr_savestats()
global.endlesslevel = 0

}
hidehud()
global.endless = 0
}}
if room = r_support {room_goto(r_mainmenu)	}
if room = r_stats {room_goto(r_mainmenu)	}
if room = r_achievements {room_goto(r_mainmenu)	}
if room = r_onlineleaderboard {room_goto(r_funmodemenu)}
if room = r_calendar {room_goto(r_funmodemenu)}
if room = r_localmultiplayermenu {
if global.multiplayerplayers = 1 {
audio_sound_gain(m_mainmenu,global.musicvolume,1000)
audio_sound_gain(m_justonline,0,1000)
room_goto(r_funmodemenu)
}
if global.chooseminigameMU = false {
if global.multiplayerplayerconfigchoose != 1 {
	global.multiplayerplayerconfigchoose -= 1 
if global.multiplayerplayerconfigchoose = 1 {global.multiplayerplayercontrols[1] = -1}
if global.multiplayerplayerconfigchoose = 2 {global.multiplayerplayercontrols[2] = -2}
if global.multiplayerplayerconfigchoose = 3 {global.multiplayerplayercontrols[3] = -3}
	} else {
global.multiplayerplayers = 1
instance_destroy(o_playerskinselectionMU)
instance_destroy(o_playerhatselectionMU)
instance_destroy(o_playeritemselectionMU)
instance_destroy(o_skinsselectbuttonMU)
instance_destroy(o_hatsselectbuttonMU)
instance_destroy(o_itemsselectbuttonMU)
}}
if global.chooseminigameMU = true { 
global.multiplayerplayerconfigchoose -= 1
global.chooseminigameMU = false
if !instance_exists(o_playerskinselectionMU) {instance_create(x,y,o_playerskinselectionMU)}
if !instance_exists(o_playerhatselectionMU) {instance_create(x,y,o_playerhatselectionMU)}
if !instance_exists(o_playeritemselectionMU) {instance_create(x,y,o_playeritemselectionMU)}
if !instance_exists(o_skinsselectbuttonMU) {instance_create(176,320,o_skinsselectbuttonMU)}
if !instance_exists(o_hatsselectbuttonMU) {instance_create(256,320,o_hatsselectbuttonMU)}
if !instance_exists(o_itemsselectbuttonMU) {instance_create(336,320,o_itemsselectbuttonMU)}
}
}
if room = r_settings {
global.infosettings = 0
if global.choosesettings = 0 {
scr_savesettings()
room_goto(r_mainmenu)	
}
if global.choosesettings > 0 {
global.choosesettings = 0
instance_destroy(o_buttonleftandroid)
instance_destroy(o_buttonrightandroid)
instance_destroy(o_buttoninteractandroid)
instance_destroy(o_buttonjumpandroid)
instance_destroy(o_buttonskipandroid)
instance_destroy(o_buttonrestartandroid)
if os_type = os_android || os_type = os_gxgames { scr_saveandroid() }
scr_TRadjustoptions()
scr_savesettings()
}
}
if room = r_dailylevelwin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_kaizowin {
room_goto(r_mainmenu)
audio_play_sound(m_mainmenu,0,1)
}
if room = r_blindwin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_bigroomwin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_troopwin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_slipperywin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_speedwin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_world6win {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_ladderwin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_tutorialwin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_spikewin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_waterwin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_movingwin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_communitywin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_djwin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_cswin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_world7win {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_invisiblewin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_breakablewin {
room_goto(r_mainmenu)	
audio_play_sound(m_mainmenu,0,1)
}
if room = r_hardmodediff {
global.hardmode = 0
room_goto(r_gamemode)
}
if room = r_levelselectmenu {
room_goto(r_gamemode)
}
if room = r_demofinishedscreen {
room_goto(r_mainmenu)
}
if room = r_gameoverscreen {
	audio_stop_all()
if global.hardmode = 1 {room_goto(r_hardmodediff)
	if !audio_is_playing(m_mainmenu) {
	audio_play_sound(m_mainmenu,0,1)	
	}
	global.hardmode = 0
	}
if global.endless = 1 {room_goto(r_endlessrunmenu)
		if !audio_is_playing(m_mainmenu) {
	audio_play_sound(m_mainmenu,0,1)	
	}
	global.endless = 0
	}
}
if room = r_skinmenu {
if !instance_exists(o_choosecustomhats) {
room_goto(r_gamemode)	
}}
if room = r_challenges {
room_goto(r_funmodemenu)
}
if room = r_customlevelmenu {
room_goto(r_funmodemenu)
}
if room = r_workshoplevelwin {
global.workshop = 0
room_goto(r_customlevelmenu)
audio_stop_all()
audio_play_sound(m_mainmenu,0,1)
}
if room = r_endlessrunmenu {
if global.CESConfigure = 0 {room_goto(r_funmodemenu)}
else if global.CESConfigure > 1 {global.CESConfigure = 1
instance_destroy(o_CERscroll) }
else if global.CESConfigure = 1 {
	global.CESConfigure = 0
	if instance_exists(o_animatedtext) {
	o_animatedtext.text = loc(37)
	}
	instance_deactivate_object(o_CERSettings)
	instance_activate_object(o_endlessbutton)
	instance_activate_object(o_oldendlessbutton)
	instance_activate_object(o_customendlessbutton)
	instance_activate_object(o_onlineleaderboardsbutton)
	}
}
if room = r_leveleditor {
if !instance_exists(o_leveleditorleaveask) {
instance_create(x,y,o_leveleditorleaveask)
}}

if instance_exists(o_settingspausemenu) {
if global.choosesettings = 0 {
instance_activate_object(o_settings)
instance_activate_object(o_pausescreen)
instance_activate_object(o_givefeedback)
if !instance_exists(o_buttonpauseandroid) {
instance_create(x,y,o_buttonpauseandroid)
}
instance_destroy(o_allsettings)
instance_destroy(o_info)
instance_destroy(o_settingspausemenu)
instance_destroy(o_animatedtext)
} else {
	scr_TRadjustoptions()
	instance_destroy(o_buttonleftandroid)
instance_destroy(o_buttonrightandroid)
instance_destroy(o_buttoninteractandroid)
instance_destroy(o_buttonjumpandroid)
instance_destroy(o_buttonskipandroid)
instance_destroy(o_buttonrestartandroid)
if os_type = os_android || os_type = os_gxgames { scr_saveandroid() }
	global.choosesettings = 0 }
} else {
	if global.pause = 1 {
audio_stop_all()
global.boss1 = 0
global.boss2 = 0
global.boss2health = 6
global.hardmode = 0
global.hardmodedifficulty = 0
global.pause = 0
global.time = 0
global.deaths = 0
global.gunammo = 0
hidehud()
instance_destroy(o_smoothcamera)

if os_type = os_android || os_type = os_gxgames {hideandroidbuttons()}

audio_group_set_gain(Music,global.musicvolume,1000)
if global.chooseminigameMU = false {
if global.challenges = 0 {
if global.endless = 0 {
	audio_sound_gain(m_mainmenu,global.musicvolume,1000)
	if global.levelselect = 0 {
	room_goto(r_mainmenu)
	scr_resetcheckpointdata()
	} else {
	room_goto(r_levelselectmenu)
	scr_resetcheckpointdata()
	}
	}}
if global.calendar = 1 {
room_goto(r_calendar)
if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1)
}
audio_sound_gain(m_mainmenu,global.musicvolume,1000)
}
if global.challenges = 1 {
room_goto(r_challenges)
}
if global.workshop = 1 {
room_goto(r_customlevelmenu)
audio_play_sound(m_mainmenu,0,1)
global.workshop = 0
}
}
if global.chooseminigameMU = true { 
	audio_stop_sound(m_justonline)
	audio_play_sound(m_justonline,0,1)
	global.MinigameMU = 0
	room_goto(r_localmultiplayermenu) }
	global.challenges = 0
}
}

if room = r_mainmenu {
if !instance_exists(o_quitask) {
instance_create(x,y,o_quitask)
}
}
if room = r_iapjoke {
audio_stop_all();
room_goto(r_mainmenu)
}
if !instance_exists(o_progressask)  {
if room = r_gamemode {
audio_stop_sound(m_justonline)
room_goto(r_mainmenu)
}} else { 

if instance_exists(o_bigwheel) || instance_exists(o_hatshopmenu) {
if instance_exists(o_bigwheel) {
if o_bigwheel.spinned = 0 {
instance_destroy(o_progressask)
instance_destroy(o_hatshopmenu)
instance_destroy(o_wheelpaycooldown)
}} else {
instance_destroy(o_progressask)
instance_destroy(o_hatshopmenu)
instance_destroy(o_wheelpaycooldown)
}
} else {
instance_destroy(o_progressask)
instance_destroy(o_hatshopmenu)
instance_destroy(o_wheelpaycooldown)	
}

	}
if room = r_credits {
room_goto(r_mainmenu)
sprite_flush(s_creditsbackround)
}
if room = r_funmodemenu {room_goto(r_gamemode)}
}