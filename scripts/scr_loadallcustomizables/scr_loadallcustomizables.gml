function scr_loadallcustomizables(){
//Load all skins to be locked
var amount = 100
global.skinselected = 0
global.hatselected = 0
global.itemselected = 0
for(var i=1;i<amount;i++) {
	if i < 10 {
		variable_global_set("skin00" + string(i),0)
		variable_global_set("hat00" + string(i),0)
		variable_global_set("item00" + string(i),0)
	}

	if i < 100 {
		if i > 9 {	
			variable_global_set("skin0" + string(i),0)
			variable_global_set("hat0" + string(i),0)
			variable_global_set("item0" + string(i),0)
		}
	}

	if i > 99 {	
		variable_global_set("skin" + string(i),0)
		variable_global_set("hat" + string(i),0)
		variable_global_set("item" + string(i),0)
	}
}

//Exceptions
global.skin001 = 1
global.hat001 = -1
global.hat003 = -1
global.hat008 = -1
global.hat009 = -1
global.hat010 = -1
global.hat035 = -1
}