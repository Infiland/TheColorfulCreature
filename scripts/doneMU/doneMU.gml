function doneMU(){
if global.chooseminigameMU = false {
if global.skinMUlocked = false {
if global.hatMUlocked = false {
if global.itemMUlocked = false {
global.multiplayerplayerconfigchoose += 1
if global.multiplayerplayerconfigchoose = 2 {
if global.multiplayerplayercontrols[1] = -1 {
global.multiplayerplayercontrols[1] = 0
}}
if global.multiplayerplayerconfigchoose = 3 {
if global.multiplayerplayercontrols[2] = -2 {
global.multiplayerplayercontrols[2] = 0
}}
if global.multiplayerplayerconfigchoose = 4 {
if global.multiplayerplayercontrols[3] = -3 {
global.multiplayerplayercontrols[3] = 0
}}
}}}}

switch(global.multiplayerplayers) {
case(2):
if global.multiplayerplayerconfigchoose = 3 {
global.chooseminigameMU = true
global.multiplayerplayercontrols[2] = -2
global.multiplayerplayercontrols[3] = -3
} break;
case(3):
if global.multiplayerplayerconfigchoose = 4 {
global.chooseminigameMU = true
global.multiplayerplayercontrols[3] = -3
} break;
case(4):
if global.multiplayerplayerconfigchoose = 5 {
global.chooseminigameMU = true
} break;
}
}