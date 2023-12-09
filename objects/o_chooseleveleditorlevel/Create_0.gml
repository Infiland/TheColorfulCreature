files = [];
depth = -20001
//var dir = working_directory + "\\Custom\\Player Hats\\*"
var dir = working_directory + "\\LevelEditor Files\\*"

var file_name = file_find_first(dir, fa_directory);

while (file_name != "")
{
    array_push(files, file_name);

    file_name = file_find_next();
}
show_debug_message(files)

file_find_close()

len = array_length(files)
page = 1
if len = 0 { maxpage = 1 } else {
maxpage = 1 + floor((len-1)/15)
}
col = c_white

lastlevels = len - (maxpage-1)*15