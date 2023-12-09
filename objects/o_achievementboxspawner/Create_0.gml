scrollcap = -426
scroll = global.achievementsscroll
var i = 0
var a = 40
var row,b;
for(row=0;row<=a;row++) {
for(b=0;b<3;b++) {
var spawn = instance_create(42+b*320,128+row*142,o_achievementbox)
i += 1
with(spawn) {
achievement = i	
}}
scrollcap += 142
}