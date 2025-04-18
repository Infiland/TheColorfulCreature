function scr_loadallcustomizables(){

//Load ItemDef
global.itemdef = array_create(5000)

//Load for selectbox
global.skinnameobjectselected = o_normalskinbutton
global.hatnameobjectselected = o_unequipedhatbutton
global.itemnameobjectselected = o_unequipeditembutton

//Load all skins to be locked
var amount = 100
global.skinselected = 0
global.hatselected = 0
global.itemselected = 0

//Total Amount of items
global.totalskinsAM = 50
global.totalhatsAM = 67
global.totalitemsAM = 3

//Set all skins to "locked"
for(var i=1;i<amount;i++) {
	global.skin[i] = 0
	global.hat[i] = 0
	global.item[i] = 0
}

//Exceptions
global.skin[1] = 1 //Default skin is unlocked
global.hat[1] = -1 //Hats are locked because they have to be unlocked in order to purchase them
global.hat[3] = -1
global.hat[8] = -1
global.hat[9] = -1
global.hat[10] = -1
global.hat[35] = -1
global.hat[47] = 1 //Unlocked serbian hat
}