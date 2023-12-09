function CERrandomlevel(){
var chooselvl = choose(1*global.CERL1,2*global.CERL2,3*global.CERL3,4*global.CERL4,5*global.CERL5,6*global.CERL6,7*global.CERL7,8*global.CERL8,9*global.CERL9,10*global.CERL10,11*global.CERL11,12*global.CERL12,13*global.CERL13,14*global.CERL14,15*global.CERL15,16*global.CERL16,17*global.CERL17,18*global.CERL18,19*global.CERL19,20*global.CERL20,21*global.CERL21,22*global.CERL22,23*global.CERL23,24*global.CERL24,25*global.CERL25,26*global.CERL26)
switch(chooselvl) {
case(0): CERrandomlevel()
/*if instance_exists(o_CERStartButton) {
o_CERStartButton.repeatend -= 1
if o_CERStartButton.repeatend < 0 {
room_restart()
}
}*/ break;
default: global.chooserandomlevel = chooselvl break;
}
}