//Endless Run Badges
var userid = steam_get_user_steam_id();
switch(userid) {
case("76561198255534811"): e1 = 1 e2 = 2 e4 = 4 break; //INFILAND
case("76561199047890471"): e1 = 3 break; //YGAMINGDUDE
case("76561198891908717"): e4 = 2 e3 = 1 e2 = 2 break; //BUMBLEBEEPRODUCTIONS
case("76561198166125817"): e4 = 3 break; //VENOM
case("76561198843067036"): e4 = 1 break; //GRANADINE MAPPING
case("76561198218167355"): e4 = 3 e1 = 2 break; //DHA
case("76561199025306908"): e4 = 7 break; //MOSTER
case("76561198799071488"): e1 = 3 e2 = 2 e3 = 1 e4 = 2  break; //BOOFNY / SLEUTH MOUSE
case("76561199006618686"): e4 = 1 break; //LOVAN7177
case("76561199001929713"): e4 = 1 break; //ZAMP_J2
case("76561198994679653"): e2 = 1 break; //KD_10
case("76561198828521511"): e1 = 1 e2 = 1 e3 = 1 e4 = 1 break; //FRSIK
case("76561199094730346"): e4 = 3 break; //CANADIANBALTIC
case("76561199099435685"): e4 = 2 break; //VRETTOSLEONIDAS2007
case("76561198418152902"): e3 = 2 e1 = 2 break; //NOVEX
case("76561198153021998"): e4 = 2 break; //MASTERX/bobinsky
case("76561199224078990"): e1 = 1 e2 = 1 e3 = 3 e4 = 3 hats = 1 break; //DEVCEY
case("76561198972886714"): e2 = 1 break; //ODREE
case("76561199193991586"): e4 = 1 break; //VADERBOYHALO
case("76561199073816172"): e4 = 3 break; //johoshwe123
case("76561199226707903"): e4 = 1 break; //chrisriter
case("76561198805775868"): e2 = 1 e4 = 2 break; //Kamepin UA
case("76561199074198675"): e4 = 2 hats = 1 break; //HANZ
case("76561199199564502"): e4 = 1 break; //alma.hamzaj
case("76561198114064117"): e3 = 1 e4 = 1 break; //GUYWHOLIKESCATS
case("76561198008591625"): e4 = 1 break; //TOILETBREAD
case("76561199075607138"): e4 = 1 break; //TECHY
case("76561199020189801"): e4 = 1 break; //TALIK
case("76561199011312826"): e2 = 1 e3 = 1 e4 = 1 break; //HIMENOSDIRTYSOCK
case("76561199128216664"): e3 = 1 break; //SINIY
case("76561199122513541"): e4 = 2 break; //ZOISITE
case("76561199119784806"): e4 = 1 break; //by bsk
case("76561198891947658"): e2 = 1 break; //Taukingur
case("76561198434566417"): e4 = 1 break; //actuallythere
case("76561198844800608"): e4 = 1 break; //Fastdreadlord22
case("76561198981201000"): e3 = 1 break; //bradleypoeller
case("76561199092392452"): e4 = 1 break; //sharkbus
case("76561198323521525"): e1 = 1 break; //Dawunek
case("76561198337175537"): e3 = 1 break; //Cheeseontoast
case("76561198275853960"): e1 = 1 break; //Kebarvu
case("76561198354700702"): e3 = 1 break; //A Bite of Bread
case("76561199082363325"): e4 = 1 break; //Spoofered
case("76561198824736019"): e4 = 1 break; //Julimera
case("76561198820308200"): e4 = 1 break; //Jaysoy
}
/*e1 = 2
e4 = 2
e3 = 2
e2 = 2*/

/*if mouse_wheel_up() {
e3rd += 1
}
if mouse_wheel_down() {
e3rd -= 1
}*/

//RGB System
if change = 0 {
blue += 3
if blue > 255 {
blue = 255
change = 1
}}
if change = 1 {
red -= 3
if red < 0 {
red = 0
change = 2
}}
if change = 2 {
green += 3
if green > 255 {
green = 255
change = 3
}}
if change = 3 {
blue -= 3
if blue < 0 {
blue = 0
change = 4
}}
if change = 4 {
red += 3
if red > 255 {
red = 255
change = 5
}}
if change = 5 {
green -= 3
if green < 0 {
green = 0
change = 0
}}