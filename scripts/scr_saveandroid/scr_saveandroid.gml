function scr_saveandroid() {
	
	var directory = directory_set("//Save Files/")
	
	scr_save_begin(directory + "Android.sav");
	ini_write_real("Android", "Layout", 2);
	ini_write_real("Android", "Button Size", global.androidbuttonsize);
	//Android
	ini_write_real("Android","Left X",global.androidleftx);
	ini_write_real("Android","Left Y",global.androidlefty);
	ini_write_real("Android","Right X",global.androidrightx);
	ini_write_real("Android","Right Y",global.androidrighty);
	ini_write_real("Android","Jump X",global.androidjumpx);
	ini_write_real("Android","Jump Y",global.androidjumpy);
	ini_write_real("Android","Interact X",global.androidinteractx);
	ini_write_real("Android","Interact Y",global.androidinteracty);
	ini_write_real("Android","Skip X",global.androidskipx);
	ini_write_real("Android","Skip Y",global.androidskipy);
	ini_write_real("Android","Restart X",global.androidrestartx);
	ini_write_real("Android","Restart Y",global.androidrestarty);
	scr_save_finish(directory + "Android.sav");
}
