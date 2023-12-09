if page != global.LEbuttonpage { exit }
if instance_exists(o_leveleditorleaveask) { exit }

if instance_exists(o_namelevelLE) { exit }
audio_play_sound(snd_hitboss,0,0)

alpha = 0.5
depth = -700