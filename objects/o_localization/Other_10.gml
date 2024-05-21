//lang = "english";
var filename = lang + ".lang";

if !file_exists("Languages\\" + string(filename)){
	filename = "english.lang"; //english is the default
	lang = "english";
}


if file_exists("Languages\\" + string(filename)){
	ini_open("Languages\\" + string(filename));
	ds_list_destroy(translator);
	translator = ds_list_create();
	for(var i=max_word;i > 0;i--){
		if (ini_key_exists(lang,i)){
			var translated = ini_read_string(lang,i,i);
			translator[| i] = translated;
		}		
	}
}
ini_close();

//Change font to cyrillic
if lang == "macedonian" {
global.deathfont = fnt_deathcyrillic
}