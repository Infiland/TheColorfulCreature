if mPubFileId != 0 {
if mBanned = false {
global.deaths = 0
global.time = 0
global.Publish_ID = level
global.levelname = mTitle
global.workshopfolder = mPath


global.workshopfolder = string_replace_all(global.workshopfolder,"\\","/")

var directory = directory_set(global.workshopfolder + "/",1)
directory = string_replace_all(directory,"\\","/")

if (!level_prepare_room(directory, r_customlevelworkshop, true)) exit;

alarm[1] = 1
}}