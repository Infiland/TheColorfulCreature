if global.choosesettings != 5 { x = lerp(x,camera_get_view_x(view_camera[0])-256,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 5 { 
	if language != -1 {
	x = lerp(x,camera_get_view_x(view_camera[0])+32 + (floor(language/8) * 212),0.2 * (60 / global.maxfps)) } else { x = lerp(x,camera_get_view_x(view_camera[0])+800,0.2 * (60 / global.maxfps)) }
}

scr_custombutton()

switch(language) {
case(-1): text = "Custom" break;
default: text = "English" break;
case(1): text = "German" break;
case(2): text = "French" break;
case(3): text = "Italian" break;
case(4): text = "Spanish" break;
case(5): text = "Hungarian" break;
case(6): text = "Turkish" break;
case(7): text = "Serb/Cro/Bos" break;
case(8): text = "Portuguese" break;
case(9): text = "Czech" break;
case(10): text = "Chinese" break;
case(11): text = "Slovenian" break;
case(12): text = "Ukrainian" break;
case(13): text = "Japanese" break;
case(14): text = "Romanian" break;
case(15): text = "Macedonian" break;
}