global.cheats = 1
global.creditscurrency += getcredits
audio_play_sound(snd_cashsound,0,0)

if global.creditscurrency > 1000000000000 {
if !steam_get_achievement("TOO_MUCH_CREDITS") { //Low on Credits
 steam_set_achievement("TOO_MUCH_CREDITS") }
}