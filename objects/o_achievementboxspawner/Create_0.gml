scrollcap = -426
scroll = global.achievementsscroll

totalunlocked = 0
var i = 0
var a = 41 //a*3
var unl = 0
var row,b;
for(row=0;row<=a;row++) {
for(b=0;b<3;b++) {
var spawn = instance_create(42+b*320,128+row*142,o_achievementbox)
i += 1
with(spawn) {
achievement = i	
	//if unlock = 1 {
	//	unl += 1
	//}
}

}
scrollcap += 142
}

totalunlocked = unl