//lang = "english";
var filename = lang + ".lang";
var lang_path = "Languages\\" + string(filename);

if !file_exists(lang_path){
	filename = "english.lang"; //english is the default
	lang = "english";
	lang_path = "Languages\\" + string(filename);
}


if (ds_exists(translator, ds_type_map)) ds_map_destroy(translator);
translator = ds_map_create();
loc_load_lang_file("Languages\\english.lang", "english", translator);
if (lang_path != "Languages\\english.lang") {
	loc_load_lang_file(lang_path, lang, translator);
}

//Change font to cyrillic
if lang == "macedonian" || lang == "serbian_cyrillic" {
global.deathfont = fnt_deathcyrillic
}
