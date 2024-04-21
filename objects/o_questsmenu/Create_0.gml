alphalerp = 0

var dirquests = program_directory + "/Quests/quests.txt"
var num = 0;
//var _path_parts = string_split(dirquests, "|");

//Loading the quest .txt file
/*if file_exists(dirquests) {
var file = file_text_open_read(dirquests);
while (!file_text_eof(file))
{
    str[num++] = file_text_readln(file);
	splashmax += 1
}
if splashmax != 0 { 
splash = irandom(splashmax-1)
splashtext = str[splash]
} else {
splashtext = ""
}
file_text_close(file);
} else {
splashtext = ""
}*/

if file_exists(dirquests) {
var file = file_text_open_read(dirquests);
str[num++] = string_split(file_text_readln(file), "|");
file_text_close(file);

show_debug_message(str[0])
}