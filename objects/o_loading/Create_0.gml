//Create nessesary components

instance_create(x,y,o_loadingbar)
instance_create(x,y,o_musicvolumecreator)
instance_create(x,y,o_3ddot)
instance_create(x,y,o_deltatime)
instance_create(x,y,obj_controller_wave)
instance_create(x,y,o_getcalendartime)
instance_create(x,y,o_checkplayercount)
instance_create(x,y,o_fullscreensystem)
instance_create(x,y,Obj_AdMob)
instance_create(x,y,o_localization)
instance_create(x,y,o_getallinventoryitems) //Load all items from steam inventory

//Fix sound volume
musicandsoundvolumefix()

// Note: Google Play Services sign-in moved to main menu or dedicated handler
// to avoid initialization issues during loading


//Actually load the game
alarm[0] = 15