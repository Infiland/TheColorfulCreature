if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}

if instance_exists(o_leveleditorleaveask) { exit }

if global.levelname != "" {
if !instance_exists(o_namelevelLE) {
if !instance_exists(o_namelevelwhenloadingLE) {
audio_play_sound(snd_hitboss,0,0)
var directory = game_save_id + "/LevelEditor Files/" + "/" + global.levelname + "/"
screen_save(directory + "/thumb.jpg")
}}

}