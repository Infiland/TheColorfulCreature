originalx = x
originaly = y
x = 1164
y = 416
page = 3

if global.skin044 = 0 {
if global.customlevelcompleted > 49 {
	global.skin044 = 1
	if !steam_get_achievement("WORKSHOP_MASTER") { steam_set_achievement("WORKSHOP_MASTER") }
}}