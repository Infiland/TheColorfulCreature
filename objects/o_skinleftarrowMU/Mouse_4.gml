if global.chooseminigameMU = false {
if image_alpha != 0.5 {
if global.multiplayerplayerconfigchoose != 5 {
switch(global.customizeselectMU) {
case(1): global.multiplayerplayerskin[global.multiplayerplayerconfigchoose-1] -= 1 break;
case(2): global.multiplayerplayerhat[global.multiplayerplayerconfigchoose-1] -= 1 break;
case(3): global.multiplayerplayeritem[global.multiplayerplayerconfigchoose-1] -= 1 break;
}
}}}