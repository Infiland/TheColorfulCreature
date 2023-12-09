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
if global.skin002 < 1 {
if multiplayerskin = 1 { global.skinMUlocked = true }}
if global.skin003 < 1 {
if multiplayerskin = 2 { global.skinMUlocked = true }}
if global.skin004 < 1 {
if multiplayerskin = 3 { global.skinMUlocked = true }}
if global.skin005 < 1 {
if multiplayerskin = 4 { global.skinMUlocked = true }}
if global.skin006 < 1 {
if multiplayerskin = 5 { global.skinMUlocked = true }}
if global.skin007 < 1 {
if multiplayerskin = 6 { global.skinMUlocked = true }}
if global.skin008 < 1 {
if multiplayerskin = 7 { global.skinMUlocked = true }}
if global.skin009 < 1 {
if multiplayerskin = 8 { global.skinMUlocked = true }}
if global.skin010 < 1 {
if multiplayerskin = 9 { global.skinMUlocked = true }}
if global.skin011 < 1 {
if multiplayerskin = 10 { global.skinMUlocked = true }}
if global.skin012 < 1 {
if multiplayerskin = 11 { global.skinMUlocked = true }}
if global.skin013 < 1 {
if multiplayerskin = 12 { global.skinMUlocked = true }}
if global.skin014 < 1 {
if multiplayerskin = 13 { global.skinMUlocked = true }}
if global.skin015 < 1 {
if multiplayerskin = 14 { global.skinMUlocked = true }}
if global.skin016 < 1 {
if multiplayerskin = 15 { global.skinMUlocked = true }}
if global.skin017 < 1 {
if multiplayerskin = 16 { global.skinMUlocked = true }}
if global.skin018 < 1 {
if multiplayerskin = 17 { global.skinMUlocked = true }}
if global.skin019 < 1 {
if multiplayerskin = 18 { global.skinMUlocked = true }}
if global.skin020 < 1 {
if multiplayerskin = 19 { global.skinMUlocked = true }}
if global.skin021 < 1 {
if multiplayerskin = 20 { global.skinMUlocked = true }}
if global.skin022 < 1 {
if multiplayerskin = 21 { global.skinMUlocked = true }}
if global.skin023 < 1 {
if multiplayerskin = 22 { global.skinMUlocked = true }}
if global.skin024 < 1 {
if multiplayerskin = 23 { global.skinMUlocked = true }}
if global.skin025 < 1 {
if multiplayerskin = 24 { global.skinMUlocked = true }}
if global.skin026 < 1 {
if multiplayerskin = 25 { global.skinMUlocked = true }}
if global.skin027 < 1 {
if multiplayerskin = 26 { global.skinMUlocked = true }}
if global.skin028 < 1 {
if multiplayerskin = 27 { global.skinMUlocked = true }}
if global.skin029 < 1 {
if multiplayerskin = 28 { global.skinMUlocked = true }}
if global.skin030 < 1 {
if multiplayerskin = 29 { global.skinMUlocked = true }}
if global.skin031 < 1 {
if multiplayerskin = 30 { global.skinMUlocked = true }}
if global.skin032 < 1 {
if multiplayerskin = 31 { global.skinMUlocked = true }}
if global.skin033 < 1 {
if multiplayerskin = 32 { global.skinMUlocked = true }}
if global.skin034 < 1 {
if multiplayerskin = 33 { global.skinMUlocked = true }}
if global.skin035 < 1 {
if multiplayerskin = 34 { global.skinMUlocked = true }}
if global.skin036 < 1 {
if multiplayerskin = 35 { global.skinMUlocked = true }}
if global.skin037 < 1 {
if multiplayerskin = 36 { global.skinMUlocked = true }}
if global.skin038 < 1 {
if multiplayerskin = 37 { global.skinMUlocked = true }}
if global.skin039 < 1 {
if multiplayerskin = 38 { global.skinMUlocked = true }}
if global.skin040 < 1 {
if multiplayerskin = 39 { global.skinMUlocked = true }}
if global.skin041 < 1 {
if multiplayerskin = 40 { global.skinMUlocked = true }}
if global.skin042 < 1 {
if multiplayerskin = 41 { global.skinMUlocked = true }}
if global.skin043 < 1 {
if multiplayerskin = 42 { global.skinMUlocked = true }}
if global.skin044 < 1 {
if multiplayerskin = 43 { global.skinMUlocked = true }}
if global.skin045 < 1 {
if multiplayerskin = 44 { global.skinMUlocked = true }}
if global.skin046 < 1 {
if multiplayerskin = 45 { global.skinMUlocked = true }}
if global.skin047 < 1 {
if multiplayerskin = 46 { global.skinMUlocked = true }}

//Hats Locked?
if global.hat002 < 1 {
if multiplayerhat = 2 { global.hatMUlocked = true }}
if global.hat003 < 1 {
if multiplayerhat = 3 { global.hatMUlocked = true }}
if global.hat004 < 1 {
if multiplayerhat = 4 { global.hatMUlocked = true }}
if global.hat005 < 1 {
if multiplayerhat = 5 { global.hatMUlocked = true }}
if global.hat006 < 1 {
if multiplayerhat = 6 { global.hatMUlocked = true }}
if global.hat007 < 1 {
if multiplayerhat = 7 { global.hatMUlocked = true }}
if global.hat008 < 1 {
if multiplayerhat = 8 { global.hatMUlocked = true }}
if global.hat009 < 1 {
if multiplayerhat = 9 { global.hatMUlocked = true }}
if global.hat010 < 1 {
if multiplayerhat = 10 { global.hatMUlocked = true }}
if global.hat011 < 1 {
if multiplayerhat = 11 { global.hatMUlocked = true }}
if global.hat012 < 1 {
if multiplayerhat = 12 { global.hatMUlocked = true }}
if global.hat013 < 1 {
if multiplayerhat = 13 { global.hatMUlocked = true }}
if global.hat014 < 1 {
if multiplayerhat = 14 { global.hatMUlocked = true }}
if global.hat015 < 1 {
if multiplayerhat = 15 { global.hatMUlocked = true }}
if global.hat016 < 1 {
if multiplayerhat = 16 { global.hatMUlocked = true }}
if global.hat017 < 1 {
if multiplayerhat = 17 { global.hatMUlocked = true }}
if global.hat018 < 1 {
if multiplayerhat = 18 { global.hatMUlocked = true }}
if global.hat019 < 1 {
if multiplayerhat = 19 { global.hatMUlocked = true }}
if global.hat020 < 1 {
if multiplayerhat = 20 { global.hatMUlocked = true }}
if global.hat021 < 1 {
if multiplayerhat = 21 { global.hatMUlocked = true }}
if global.hat022 < 1 {
if multiplayerhat = 22 { global.hatMUlocked = true }}
if global.hat023 < 1 {
if multiplayerhat = 23 { global.hatMUlocked = true }}
if global.hat024 < 1 {
if multiplayerhat = 24 { global.hatMUlocked = true }}
if global.hat025 < 1 {
if multiplayerhat = 25 { global.hatMUlocked = true }}
if global.hat026 < 1 {
if multiplayerhat = 26 { global.hatMUlocked = true }}
if global.hat027 < 1 {
if multiplayerhat = 27 { global.hatMUlocked = true }}
if global.hat028 < 1 {
if multiplayerhat = 28 { global.hatMUlocked = true }}
if global.hat029 < 1 {
if multiplayerhat = 29 { global.hatMUlocked = true }}
if global.hat030 < 1 {
if multiplayerhat = 30 { global.hatMUlocked = true }}
if global.hat031 < 1 {
if multiplayerhat = 31 { global.hatMUlocked = true }}
if global.hat032 < 1 {
if multiplayerhat = 32 { global.hatMUlocked = true }}
if global.hat033 < 1 {
if multiplayerhat = 33 { global.hatMUlocked = true }}
if global.hat034 < 1 {
if multiplayerhat = 34 { global.hatMUlocked = true }}
if global.hat035 < 1 {
if multiplayerhat = 35 { global.hatMUlocked = true }}
if global.hat036 < 1 {
if multiplayerhat = 36 { global.hatMUlocked = true }}
if global.hat037 < 1 {
if multiplayerhat = 37 { global.hatMUlocked = true }}
if global.hat038 < 1 {
if multiplayerhat = 38 { global.hatMUlocked = true }}
if global.hat039 < 1 {
if multiplayerhat = 39 { global.hatMUlocked = true }}
if global.hat040 < 1 {
if multiplayerhat = 40 { global.hatMUlocked = true }}
if global.hat041 < 1 {
if multiplayerhat = 41 { global.hatMUlocked = true }}
if global.hat042 < 1 {
if multiplayerhat = 42 { global.hatMUlocked = true }}
if global.hat043 < 1 {
if multiplayerhat = 43 { global.hatMUlocked = true }}
if global.hat044 < 1 {
if multiplayerhat = 44 { global.hatMUlocked = true }}
if global.hat045 < 1 {
if multiplayerhat = 45 { global.hatMUlocked = true }}
if global.hat046 < 1 {
if multiplayerhat = 46 { global.hatMUlocked = true }}


//Items Locked
if global.item001 < 1 {
if multiplayeritem = 1 { global.itemMUlocked = true }}
if global.item002 < 1 {
if multiplayeritem = 2 { global.itemMUlocked = true }}



if global.skinMUlocked = true || global.hatMUlocked = true || global.itemMUlocked = true { 
	image_index = 0
	image_alpha = 0.5 
	} else { image_alpha = 1 }