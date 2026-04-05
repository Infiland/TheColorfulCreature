if global.multiplayerplayers = 1 { x = lerp(x,originalx,0.2 * (60 / global.maxfps)) } else {
	x = lerp(x,460,0.2 * (60 / global.maxfps))
	if global.chooseminigameMU = true { y = lerp(y,900,0.2 * (60 / global.maxfps)) } else { y = lerp(y,originaly,0.2 * (60 / global.maxfps)) }
}
global.skinMUlocked = false
global.hatMUlocked = false
global.itemMUlocked = false

//Controls conflict detection
for (var i = 0; i < global.multiplayerplayers; i++) {
	for (var j = i + 1; j < global.multiplayerplayers; j++) {
		if (global.multiplayerplayercontrols[i] = global.multiplayerplayercontrols[j]) { global.skinMUlocked = true }
	}
}

var _pi = global.multiplayerplayerconfigchoose - 1
var multiplayerskin = global.multiplayerplayerskin[_pi]
var multiplayerhat = global.multiplayerplayerhat[_pi]
var multiplayeritem = global.multiplayerplayeritem[_pi]

//Skins Locked?
if (multiplayerskin > 0 && multiplayerskin < global.MU_skin_count) {
	if (global.skin[multiplayerskin + 1] < 1) {
		global.skinMUlocked = true
	}
}

//Hats Locked?
if (multiplayerhat > 0 && multiplayerhat < global.MU_hat_count) {
	if (global.hat[multiplayerhat] < 1) {
		global.hatMUlocked = true
	}
}

//Items Locked?
if (multiplayeritem > 0 && multiplayeritem < global.MU_item_count) {
	if (global.item[multiplayeritem] < 1) {
		global.itemMUlocked = true
	}
}

if global.skinMUlocked = true || global.hatMUlocked = true || global.itemMUlocked = true {
	image_index = 0
	image_alpha = 0.5
	} else { image_alpha = 1 }