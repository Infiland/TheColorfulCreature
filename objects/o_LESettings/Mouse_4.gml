if instance_exists(o_leveleditorleaveask) { exit }

if instance_exists(o_namelevelLE) { exit }
audio_play_sound(snd_hitboss,0,0)

if !instance_exists(o_leveleditormenusetup) {
var btn = instance_create(x,y,o_leveleditormenusetup)
with btn {
page = 2
}
}

depth = -700