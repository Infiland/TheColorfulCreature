function SaveStringToFile(argument0, argument1) {
	//@arg filename
	//@arg string
	var _filename = argument0
	var _string = argument1

	var _buffer = buffer_create(string_byte_length(_string)+1,buffer_fixed,1);
	buffer_write(_buffer, buffer_string,_string);
	buffer_save(_buffer,_filename);
	buffer_delete(_buffer);
}