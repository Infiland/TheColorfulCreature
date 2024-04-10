if global.multiplayerplayers = 1 { x = lerp(x,originalx,0.2 * (60 / global.maxfps)) } else {
	x = lerp(x,460,0.2 * (60 / global.maxfps))
	if global.chooseminigameMU = true { y = lerp(y,900,0.2 * (60 / global.maxfps)) } else { y = lerp(y,originaly,0.2 * (60 / global.maxfps)) }
}
global.skinMUlocked = false
global.hatMUlocked = false
global.itemMUlocked = false
if global.multiplayerplayercontrols[0] = global.multiplayerplayercontrols[1] { global.skinMUlocked = true }
if global.multiplayerplayercontrols[0] = global.multiplayerplayercontrols[2] { global.skinMUlocked = true }
if global.multiplayerplayercontrols[0] = global.multiplayerplayercontrols[3] { global.skinMUlocked = true }
if global.multiplayerplayercontrols[1] = global.multiplayerplayercontrols[2] { global.skinMUlocked = true }
if global.multiplayerplayercontrols[1] = global.multiplayerplayercontrols[3] { global.skinMUlocked = true }
if global.multiplayerplayercontrols[3] = global.multiplayerplayercontrols[2] { global.skinMUlocked = true }

switch(global.multiplayerplayerconfigchoose) {
case(1): multiplayerskin = global.multiplayerplayerskin[0] 
multiplayerhat = global.multiplayerplayerhat[0]
multiplayeritem = global.multiplayerplayeritem[0] break;
case(2): multiplayerskin = global.multiplayerplayerskin[1] 
multiplayerhat = global.multiplayerplayerhat[1]
multiplayeritem = global.multiplayerplayeritem[1] break;
case(3): multiplayerskin = global.multiplayerplayerskin[2]
multiplayerhat = global.multiplayerplayerhat[2]
multiplayeritem = global.multiplayerplayeritem[2] break;
case(4): multiplayerskin = global.multiplayerplayerskin[3]
multiplayerhat = global.multiplayerplayerhat[3]
multiplayeritem = global.multiplayerplayeritem[3] break;
}

//Skins Locked?
if global.skin[2] < 1 {
if multiplayerskin = 1 { global.skinMUlocked = true }}
if global.skin[3] < 1 {
if multiplayerskin = 2 { global.skinMUlocked = true }}
if global.skin[4] < 1 {
if multiplayerskin = 3 { global.skinMUlocked = true }}
if global.skin[5] < 1 {
if multiplayerskin = 4 { global.skinMUlocked = true }}
if global.skin[6] < 1 {
if multiplayerskin = 5 { global.skinMUlocked = true }}
if global.skin[7] < 1 {
if multiplayerskin = 6 { global.skinMUlocked = true }}
if global.skin[8] < 1 {
if multiplayerskin = 7 { global.skinMUlocked = true }}
if global.skin[9] < 1 {
if multiplayerskin = 8 { global.skinMUlocked = true }}
if global.skin[10] < 1 {
if multiplayerskin = 9 { global.skinMUlocked = true }}
if global.skin[11] < 1 {
if multiplayerskin = 10 { global.skinMUlocked = true }}
if global.skin[12] < 1 {
if multiplayerskin = 11 { global.skinMUlocked = true }}
if global.skin[13] < 1 {
if multiplayerskin = 12 { global.skinMUlocked = true }}
if global.skin[14] < 1 {
if multiplayerskin = 13 { global.skinMUlocked = true }}
if global.skin[15] < 1 {
if multiplayerskin = 14 { global.skinMUlocked = true }}
if global.skin[16] < 1 {
if multiplayerskin = 15 { global.skinMUlocked = true }}
if global.skin[17] < 1 {
if multiplayerskin = 16 { global.skinMUlocked = true }}
if global.skin[18] < 1 {
if multiplayerskin = 17 { global.skinMUlocked = true }}
if global.skin[19] < 1 {
if multiplayerskin = 18 { global.skinMUlocked = true }}
if global.skin[20] < 1 {
if multiplayerskin = 19 { global.skinMUlocked = true }}
if global.skin[21] < 1 {
if multiplayerskin = 20 { global.skinMUlocked = true }}
if global.skin[22] < 1 {
if multiplayerskin = 21 { global.skinMUlocked = true }}
if global.skin[23] < 1 {
if multiplayerskin = 22 { global.skinMUlocked = true }}
if global.skin[24] < 1 {
if multiplayerskin = 23 { global.skinMUlocked = true }}
if global.skin[25] < 1 {
if multiplayerskin = 24 { global.skinMUlocked = true }}
if global.skin[26] < 1 {
if multiplayerskin = 25 { global.skinMUlocked = true }}
if global.skin[27] < 1 {
if multiplayerskin = 26 { global.skinMUlocked = true }}
if global.skin[28] < 1 {
if multiplayerskin = 27 { global.skinMUlocked = true }}
if global.skin[29] < 1 {
if multiplayerskin = 28 { global.skinMUlocked = true }}
if global.skin[30] < 1 {
if multiplayerskin = 29 { global.skinMUlocked = true }}
if global.skin[31] < 1 {
if multiplayerskin = 30 { global.skinMUlocked = true }}
if global.skin[32] < 1 {
if multiplayerskin = 31 { global.skinMUlocked = true }}
if global.skin[33] < 1 {
if multiplayerskin = 32 { global.skinMUlocked = true }}
if global.skin[34] < 1 {
if multiplayerskin = 33 { global.skinMUlocked = true }}
if global.skin[35] < 1 {
if multiplayerskin = 34 { global.skinMUlocked = true }}
if global.skin[36] < 1 {
if multiplayerskin = 35 { global.skinMUlocked = true }}
if global.skin[37] < 1 {
if multiplayerskin = 36 { global.skinMUlocked = true }}
if global.skin[38] < 1 {
if multiplayerskin = 37 { global.skinMUlocked = true }}
if global.skin[39] < 1 {
if multiplayerskin = 38 { global.skinMUlocked = true }}
if global.skin[40] < 1 {
if multiplayerskin = 39 { global.skinMUlocked = true }}
if global.skin[41] < 1 {
if multiplayerskin = 40 { global.skinMUlocked = true }}
if global.skin[42] < 1 {
if multiplayerskin = 41 { global.skinMUlocked = true }}
if global.skin[43] < 1 {
if multiplayerskin = 42 { global.skinMUlocked = true }}
if global.skin[44] < 1 {
if multiplayerskin = 43 { global.skinMUlocked = true }}
if global.skin[45] < 1 {
if multiplayerskin = 44 { global.skinMUlocked = true }}
if global.skin[46] < 1 {
if multiplayerskin = 45 { global.skinMUlocked = true }}
if global.skin[47] < 1 {
if multiplayerskin = 46 { global.skinMUlocked = true }}

//Hats Locked?
if global.hat[2] < 1 {
if multiplayerhat = 2 { global.hatMUlocked = true }}
if global.hat[3] < 1 {
if multiplayerhat = 3 { global.hatMUlocked = true }}
if global.hat[4] < 1 {
if multiplayerhat = 4 { global.hatMUlocked = true }}
if global.hat[5] < 1 {
if multiplayerhat = 5 { global.hatMUlocked = true }}
if global.hat[6] < 1 {
if multiplayerhat = 6 { global.hatMUlocked = true }}
if global.hat[7] < 1 {
if multiplayerhat = 7 { global.hatMUlocked = true }}
if global.hat[8] < 1 {
if multiplayerhat = 8 { global.hatMUlocked = true }}
if global.hat[9] < 1 {
if multiplayerhat = 9 { global.hatMUlocked = true }}
if global.hat[10] < 1 {
if multiplayerhat = 10 { global.hatMUlocked = true }}
if global.hat[11] < 1 {
if multiplayerhat = 11 { global.hatMUlocked = true }}
if global.hat[12] < 1 {
if multiplayerhat = 12 { global.hatMUlocked = true }}
if global.hat[13] < 1 {
if multiplayerhat = 13 { global.hatMUlocked = true }}
if global.hat[14] < 1 {
if multiplayerhat = 14 { global.hatMUlocked = true }}
if global.hat[15] < 1 {
if multiplayerhat = 15 { global.hatMUlocked = true }}
if global.hat[16] < 1 {
if multiplayerhat = 16 { global.hatMUlocked = true }}
if global.hat[17] < 1 {
if multiplayerhat = 17 { global.hatMUlocked = true }}
if global.hat[18] < 1 {
if multiplayerhat = 18 { global.hatMUlocked = true }}
if global.hat[19] < 1 {
if multiplayerhat = 19 { global.hatMUlocked = true }}
if global.hat[20] < 1 {
if multiplayerhat = 20 { global.hatMUlocked = true }}
if global.hat[21] < 1 {
if multiplayerhat = 21 { global.hatMUlocked = true }}
if global.hat[22] < 1 {
if multiplayerhat = 22 { global.hatMUlocked = true }}
if global.hat[23] < 1 {
if multiplayerhat = 23 { global.hatMUlocked = true }}
if global.hat[24] < 1 {
if multiplayerhat = 24 { global.hatMUlocked = true }}
if global.hat[25] < 1 {
if multiplayerhat = 25 { global.hatMUlocked = true }}
if global.hat[26] < 1 {
if multiplayerhat = 26 { global.hatMUlocked = true }}
if global.hat[27] < 1 {
if multiplayerhat = 27 { global.hatMUlocked = true }}
if global.hat[28] < 1 {
if multiplayerhat = 28 { global.hatMUlocked = true }}
if global.hat[29] < 1 {
if multiplayerhat = 29 { global.hatMUlocked = true }}
if global.hat[30] < 1 {
if multiplayerhat = 30 { global.hatMUlocked = true }}
if global.hat[31] < 1 {
if multiplayerhat = 31 { global.hatMUlocked = true }}
if global.hat[32] < 1 {
if multiplayerhat = 32 { global.hatMUlocked = true }}
if global.hat[33] < 1 {
if multiplayerhat = 33 { global.hatMUlocked = true }}
if global.hat[34] < 1 {
if multiplayerhat = 34 { global.hatMUlocked = true }}
if global.hat[35] < 1 {
if multiplayerhat = 35 { global.hatMUlocked = true }}
if global.hat[36] < 1 {
if multiplayerhat = 36 { global.hatMUlocked = true }}
if global.hat[37] < 1 {
if multiplayerhat = 37 { global.hatMUlocked = true }}
if global.hat[38] < 1 {
if multiplayerhat = 38 { global.hatMUlocked = true }}
if global.hat[39] < 1 {
if multiplayerhat = 39 { global.hatMUlocked = true }}
if global.hat[40] < 1 {
if multiplayerhat = 40 { global.hatMUlocked = true }}
if global.hat[41] < 1 {
if multiplayerhat = 41 { global.hatMUlocked = true }}
if global.hat[42] < 1 {
if multiplayerhat = 42 { global.hatMUlocked = true }}
if global.hat[43] < 1 {
if multiplayerhat = 43 { global.hatMUlocked = true }}
if global.hat[44] < 1 {
if multiplayerhat = 44 { global.hatMUlocked = true }}
if global.hat[45] < 1 {
if multiplayerhat = 45 { global.hatMUlocked = true }}
if global.hat[46] < 1 {
if multiplayerhat = 46 { global.hatMUlocked = true }}


//Items Locked
if global.item[1] < 1 {
if multiplayeritem = 1 { global.itemMUlocked = true }}
if global.item[2] < 1 {
if multiplayeritem = 2 { global.itemMUlocked = true }}



if global.skinMUlocked = true || global.hatMUlocked = true || global.itemMUlocked = true { 
	image_index = 0
	image_alpha = 0.5 
	} else { image_alpha = 1 }