function medalcheck(challenge,dmedal,deaths){
var rmedal = dmedal * 0.9
var gmedal = dmedal * 1.1
var smedal = gmedal * 1.2
var bmedal = smedal * 1.3

if challenge > bmedal {image_alpha = 0}
if challenge < bmedal {
	medalsprite = 0
	if !achievement_earned("BRONZE_MEDAL") { achievement_award("BRONZE_MEDAL") }
	}
if challenge < smedal {
	medalsprite = 1
	if !achievement_earned("SILVER_MEDAL") { achievement_award("SILVER_MEDAL") }
	}
if challenge < gmedal {
	medalsprite = 2
	if !achievement_earned("GOLD_MEDAL") { achievement_award("GOLD_MEDAL") }
	}
if challenge < dmedal {
	medalsprite = 3
	global.diamondmedalcount += 1
	if !achievement_earned("DIAMOND_MEDAL") { achievement_award("DIAMOND_MEDAL") }
	if global.diamondmedalcount > 4 {
	if !achievement_earned("DIAMOND_LOVER") { achievement_award("DIAMOND_LOVER") }
	}
	}
if challenge < rmedal {
if deaths = 0 {
	medalsprite = 4
	}}
}
