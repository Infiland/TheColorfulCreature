if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}

if instance_exists(o_leveleditorleaveask) { exit }

if global.LEMode = 1 {
	
if global.autothumbnailsettings = 1 {
if global.levelname != "" {
var directory = working_directory + "/LevelEditor Files/" + "/" + global.levelname + "/"
screen_save(directory + "/thumb.jpg")
}}


if !instance_exists(o_namelevelLE) {
if !instance_exists(o_namelevelwhenloadingLE) {
audio_play_sound(snd_hitboss,0,0)
instance_create(x,y,o_publishlevelLE)
}}

}