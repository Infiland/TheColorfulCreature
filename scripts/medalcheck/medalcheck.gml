function medalcheck(challenge,dmedal,deaths){
var rmedal = dmedal * 0.9
var gmedal = dmedal * 1.1
var smedal = gmedal * 1.2
var bmedal = smedal * 1.3

if challenge > bmedal {image_alpha = 0}
if challenge < bmedal {
	medalsprite = 0
	if !steam_get_achievement("BRONZE_MEDAL") { steam_set_achievement("BRONZE_MEDAL") }
	}
if challenge < smedal {
	medalsprite = 1
	if !steam_get_achievement("SILVER_MEDAL") { steam_set_achievement("SILVER_MEDAL") }
	}
if challenge < gmedal {
	medalsprite = 2
	if !steam_get_achievement("GOLD_MEDAL") { steam_set_achievement("GOLD_MEDAL") }
	}
if challenge < dmedal {
	medalsprite = 3
	global.diamondmedalcount += 1
	if !steam_get_achievement("DIAMOND_MEDAL") { steam_set_achievement("DIAMOND_MEDAL") }
	if global.diamondmedalcount > 4 {
	if !steam_get_achievement("DIAMOND_LOVER") { steam_set_achievement("DIAMOND_LOVER") }	
	}
	}
if challenge < rmedal {
if deaths = 0 {
	medalsprite = 4
	}}
}