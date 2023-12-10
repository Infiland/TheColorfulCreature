if instance_exists(o_namelevelLE) { exit }
if instance_exists(o_leveleditorleaveask) { exit }
image_index = 1

if global.autothumbnailsettings = 1 {
if global.levelname != "" {
if timer = 60 {
var directory = game_save_id + "/LevelEditor Files/" + "/" + global.levelname + "/"
screen_save(directory + "/thumb.png")
timer = 0
} else {
timer += 1	
}}}