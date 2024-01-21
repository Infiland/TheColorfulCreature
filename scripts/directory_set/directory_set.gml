function directory_set(dir,save=0){
var directory = ""
global.moddedGameDir = ""
//if global.moddedGameDir = undefined { global.moddedGameDir = "" }
if save = 0 { directory += game_save_id }
if (global.moddedGameDir != "") { directory += "MODS//" + string(global.moddedGameDir) }
directory += dir
return directory;
}