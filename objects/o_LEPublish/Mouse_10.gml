// Only the level's creator saves, loads and publishes a level built together.
if (net_coop_is_guest()) exit;
if instance_exists(o_namelevelLE) { exit }
if instance_exists(o_leveleditorleaveask) { exit }
image_index = 1

if global.autothumbnailsettings = 1 {
if global.levelname != "" {
if timer = 60 {
var directory = level_editor_directory()
screen_save(directory + "/thumb.png")
timer = 0
} else {
timer += 1	
}}}