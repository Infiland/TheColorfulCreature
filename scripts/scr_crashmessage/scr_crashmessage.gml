if os_type != os_android {
exception_unhandled_handler(function(exception) {	
	
	if !steam_get_achievement("OOPS") { //OOPS
	 steam_set_achievement("OOPS") }
	
	var randommessage = irandom_range(1,14)
	var cutemessage = ""
	switch(randommessage) {
	case(1): cutemessage = "BSOD!" break;
	case(2): cutemessage = "JUST WHY!" break;
	case(3): cutemessage = "Sorry!" break;
	case(4): cutemessage = "Crash!" break;
	case(5): cutemessage = "Error!" break;
	case(6): cutemessage = "Stupid Error..." break;
	case(7): cutemessage = ":(" break;
	case(8): cutemessage = "Hello :)" break;
	case(9): cutemessage = "Sad." break;
	case(10): cutemessage = "404!" break;
	case(11): cutemessage = "Bruh Moment." break;
	case(12): cutemessage = "Damn it!" break;
	case(13): cutemessage = "F***!" break;
	case(14): cutemessage = "OMEGALUL" break;
}
	
	show_message("=============================\n" + cutemessage + " The game has crashed, please report this crash in the support section of the game and fill out other details...\n" + "=============================\n" +  exception.message + "\n\n" + exception.longMessage + "\n\n" + exception.script + "\n\n" + "Crash.txt has been created in local files, inside the 'Other' folder, Sorry BTW!")
	
	
	var directory = working_directory + "/Other/"
	if !directory_exists(directory) {directory_create(directory)}
	
    if file_exists(directory + "crash.txt") file_delete(directory + "crash.txt");
    var _f = file_text_open_write(directory + "crash.txt");
    file_text_write_string(_f, string(exception));
    file_text_close(_f);
	return 0;
	
})
}