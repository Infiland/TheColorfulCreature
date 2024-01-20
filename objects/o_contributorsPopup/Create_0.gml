/// @description EDIT NAMES HERE
names = ""
namecnt = 0

name[0] = "[rainbow]Infiland[/]"
name[1] = "sadzake"
name[2] = "crimsonnnnn"

var dir = "Other//contributors.txt" //Reading text files doesn't work for some reason
var file = file_text_open_read(dir)
var num = 0

if file_exists(file){
	while(!file_text_eof(file)) {
		name[num++] = file_text_readln(file);
		show_debug_message("test")
		namecnt++
	}
file_text_close(file);

} else {
namecnt = 3
}

for(var i=0; i < namecnt;i++) {
	if namecnt-1 != i {
		names += name[i] + ", "
	} else {
		names += "and " + name[i] + "!!!"
	}
}	

if names == "" {
	names = loc(561)
}