if instance_exists(o_leveleditorleaveask) { exit }
if instance_exists(o_leveleditormenusetup) || instance_exists(o_chooseleveleditorlevel) { exit }
if global.LEMode != 1 || global.writingmode != 0 { exit }

audio_play_sound(snd_hitboss,0,0)
timing_create_depth(0,0,-20002,o_coopinvitepanel)
