/// @description Init

lang			= "english";
translator		= ds_list_create();
max_word		= 1000;	//just to stay safe

//set the starting language based on the operative system
/* switch (os_get_language()){
   //case "zh":
   //    var region = os_get_region();
   //    if (region == "HK" || region == "MO" || region == "TW"){
	//	   global.language = game_language.chinese;           
   //    }else{
   //        global.language = game_language.chinese;
   //    }
   //    break;
   
   //case "fr":global.language = game_language.french;break;
   
   //case "de":global.language = game_language.german;break;
	//case "pt":global.language = game_language.portoguese;break;
	//case "ru":global.language = game_language.russian;break;
	//case "pl":global.language = game_language.polish;break;
   //case "mx":
   //case "es":global.language = game_language.spanish;break;
   case "it":	global.lang = g_language.italian;break;
   default:		global.lang = g_language.english;break;
} */

//call the load translation
event_user(0);
