alphalerp = 0

var dirquests = program_directory + "/Quests/quests.txt"
var num = 0;
maxquests = 0
//var _path_parts = string_split(dirquests, "|");

//Loading the quest .txt file
if file_exists(dirquests) {
var file = file_text_open_read(dirquests);
while (!file_text_eof(file))
{
    str[num++] = string_split(file_text_readln(file), "|");
}
maxquests = num
show_debug_message(maxquests)
file_text_close(file);
} else {
	instance_destroy()	
}


/*
if file_exists(dirquests) {
var file = file_text_open_read(dirquests);
str[num++] = string_split(file_text_readln(file), "|");
show_debug_message(dirquests)
file_text_close(file);

show_debug_message(str[0])
}*/