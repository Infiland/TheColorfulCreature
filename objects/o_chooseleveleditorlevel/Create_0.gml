files = [];
depth = -20001;
var _root = level_directory(directory_set("/LevelEditor Files/"));
var _name = file_find_first(_root + "*", fa_directory);
while (_name != "") {
    if (level_editor_name_valid(_name) && level_exists(_root + _name)) array_push(files, _name);
    _name = file_find_next();
}
file_find_close();
array_sort(files, true);
len = array_length(files);
page = 1;
maxpage = max(1, ceil(len / 15));
selection = 0;
error_text = "";
