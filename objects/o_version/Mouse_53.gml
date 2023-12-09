switch(splash) {
case(375):
if mouse_x < 180 {
if mouse_y < 32 {
if !steam_get_achievement("JEBAITED") { steam_set_achievement("JEBAITED") }
clicked = true	
}}
break;
case(399):
global.cookies += 1
if !steam_get_achievement("COOKIE_CLICKER") { steam_set_achievement("COOKIE_CLICKER") }
break;
}