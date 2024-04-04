/// @description EDIT NAMES HERE
names = ""
namecnt = 0


//name[0] = "[rainbow]If you see this, this doesn't work[/]"
//var directory = program_directory + "//Challenges//Lunar Base Challenge//1/"

var dir = program_directory + "Other\\contributors.txt" //Reading text files doesn't work for some reason
var file = file_text_open_read(dir)
var num = 0

show_debug_message(string(file))

	while(!file_text_eof(file)) {
		name[num++] = file_text_read_string(file);
		//show_debug_message("test")
		namecnt++
		file_text_readln(file);
	}
file_text_close(file);

for(var i=0; i < namecnt;i++) {
	if namecnt-1 != i {	
		//names = string_insert(names,name[i] + ", ",string_length(names)-1)
		names += name[i] + ", "
	} else {
		//names = string_insert(names,"and " + name[i] + "!!!",string_length(names)-1)
		names += "and " + name[i] + "!!!"
	}
}	

if names == "" {
	names = loc(561)
}