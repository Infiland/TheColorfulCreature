p1 = 796
p2 = 970
p3 = 27
p4 = 67
credits = 0
creditsborder = 0
creditsx = 962
creditsy = 36
creditsiconx = 800
creditsicony = 32

//Special Rainbow colors!
red = 255
green = 0
blue = 0
change = 0

//Border Color
colorB = make_color_rgb(255,255,255)
redB = 0
depth = -10001

if os_type = os_android || os_type = os_gxgames {
if !instance_exists(o_watchad) {
instance_create(864,78,o_watchad)	
}}

if global.cheats = 0 {
if global.creditscurrency >= 100 { if !steam_get_achievement("A_SMALL_LOAN") { steam_set_achievement("A_SMALL_LOAN") }}
if global.creditscurrency >= 1000 { if !steam_get_achievement("MONEY_SAVER") { steam_set_achievement("MONEY_SAVER") }}
if global.creditscurrency >= 10000 { if !steam_get_achievement("THE_GLITTERING_RICH") { steam_set_achievement("THE_GLITTERING_RICH") }}
}