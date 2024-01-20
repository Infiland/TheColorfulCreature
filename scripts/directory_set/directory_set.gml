function directory_set(dir){
var directory = game_save_id
if global.moddedGameDir != "" { directory += "MODS//" + string(global.moddedGameDir) }
directory += dir
return directory;
}