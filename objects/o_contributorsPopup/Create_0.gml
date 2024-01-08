/// @description EDIT NAMES HERE
names = ""
namecnt = 0

var dir = working_directory + "contributors.txt"
var file = file_text_open_read(dir)
var num = 0

if file_exists(file){
	while(!file_text_eof(file)) {
		name[num++] = file_text_readln(file);
		show_debug_message("test")
		namecnt++
	}
file_text_close(file);

for(var i=0; i < namecnt;i++) {
	if namecnt-1 != i {
		names += name[i] + ", "
	} else {
		names += "and " + name[i] + "!!!"
	}
}

} else {
names = loc(561)
}
//name[0] = "[rainbow]Infiland[/]"
//name[1] = "sadzake"