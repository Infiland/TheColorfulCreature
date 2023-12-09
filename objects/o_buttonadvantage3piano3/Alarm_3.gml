sprite_index = s_buttonadvantage
if global.pianobutton4 = 1 {
if button = 1 {
	audio_play_sound(snd_pickup,0,0)
	instance_create(x+12,y-20,o_exclamationmarkpiano)
sprite_index = s_buttonadvantage2	
}}
if global.pianobutton4 = 2 {
if button = 2 {
	audio_play_sound(snd_pickup,0,0)
	instance_create(x+12,y-20,o_exclamationmarkpiano)
sprite_index = s_buttonadvantage2	
}}
if global.pianobutton4 = 3 {
if button = 3 {
	audio_play_sound(snd_pickup,0,0)
	instance_create(x+12,y-20,o_exclamationmarkpiano)
sprite_index = s_buttonadvantage2	
}}
if global.pianobutton4 = 4 {
if button = 4 {
	audio_play_sound(snd_pickup,0,0)
	instance_create(x+12,y-20,o_exclamationmarkpiano)
sprite_index = s_buttonadvantage2	
}}
if global.pianobutton4 = 5 {
if button = 5 {
	audio_play_sound(snd_pickup,0,0)
	instance_create(x+12,y-20,o_exclamationmarkpiano)
sprite_index = s_buttonadvantage2	
}}
if global.pianobutton4 = 6 {
if button = 6 {
	audio_play_sound(snd_pickup,0,0)
	instance_create(x+12,y-20,o_exclamationmarkpiano)
sprite_index = s_buttonadvantage2	
}}
alarm[4] = 30 * (global.maxfps/60)