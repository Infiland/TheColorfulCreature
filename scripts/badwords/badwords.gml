function badwords(){
var count = 0
count += string_count("Nigger", keyboard_string);
count += string_count("nigger", keyboard_string);
count += string_count("NIGGER", keyboard_string);
count += string_count("fatih", keyboard_string);
count += string_count("Fatih", keyboard_string);
count += string_count("FATIH", keyboard_string);
count += string_count("nigga", keyboard_string);
count += string_count("Nigga", keyboard_string);
count += string_count("NIGGA", keyboard_string);
count += string_count("fuck", keyboard_string);
count += string_count("shit", keyboard_string);
count += string_count("cunt", keyboard_string);
count += string_count("Shit", keyboard_string);
if count > 0 { keyboard_string = "" }
}