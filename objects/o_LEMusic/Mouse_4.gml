if page != global.LEbuttonpage { exit }
if instance_exists(o_leveleditorleaveask) { exit }

if global.LEMode = 1 {

if instance_exists(o_namelevelLE) { exit }
audio_stop_all()
audio_play_sound(snd_hitboss,0,0)
lol += 1
global.leveleditormusic = lol
if steam_get_app_id() != 1749610 {
if lol > 29 { lol = -1}
} else {
if lol > 4 { lol = -1}
}
scr_leveleditormusic()

//Remember to go to o_LELoad

}