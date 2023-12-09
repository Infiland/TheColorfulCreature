/*//var directory = working_directory + "/LevelEditor Files//"
draw_set_font(global.coolfont)

//var files = file_find_first(working_directory + "*", 0)



var files = []
var file_name = file_find_first(working_directory + "//Save Files//*.sav", fa_directory);
while (file_name != "")
{
    array_push(files, file_name);
    file_name = file_find_next();
}

draw_text_ext(100,120,files,20,700)
draw_text(100,180,"No work")

file_find_close()