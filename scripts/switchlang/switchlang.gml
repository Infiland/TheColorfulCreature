function switchlang(){
switch(global.language) {
default: //ENGLISH
with (o_localization) { lang = "english" event_user(0); } break;
case(1): //GERMAN
with (o_localization) { lang = "german" event_user(0); } break;
case(2): //FRENCH
with (o_localization) { lang = "french" event_user(0); } break;
case(3): //ITALIAN
with (o_localization) { lang = "italian" event_user(0); } break;
case(4): //SPANISH
with (o_localization) { lang = "spanish" event_user(0); } break;
case(5): //HUNGARIAN
with (o_localization) { lang = "hungarian" event_user(0); } break;
case(6): //TURKISH
with (o_localization) { lang = "turkish" event_user(0); } break;
case(7): //SERB
with (o_localization) { lang = "srb_cro_bos" event_user(0); } break;
case(8): //PORTUGUESE
with (o_localization) { lang = "portuguese" event_user(0); } break;
case(9): //CZECH
with (o_localization) { lang = "czech" event_user(0); } break;
case(10): //CHINESE
with (o_localization) { lang = "chinese" event_user(0); } break;
case(11): //SLOVENIAN
with (o_localization) { lang = "slovenian" event_user(0); } break;
case(12): //UKRAINIAN
with (o_localization) { lang = "ukrainian" event_user(0); } break;
case(15): //MACEDONIAN
with (o_localization) { lang = "macedonian" event_user(0); } break;
case(-1): //CUSTOM
with (o_localization) { lang = "custom" event_user(0); } break;
}
}