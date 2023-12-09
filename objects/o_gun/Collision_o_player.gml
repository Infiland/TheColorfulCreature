instance_destroy()
global.gunammo += 16
if room != r_leveleditor { global.totalgunpickups += 1}
audio_play_sound(snd_reload,0,0)
if !instance_exists(o_gunequipped) {
instance_create(x,y,o_gunlogo)
instance_create(x,y,o_gunequipped)
}