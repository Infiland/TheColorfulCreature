function skincustomizelogic(skin,skin_id,type="hat"){

var zero = "0"
if skin_id < 10 {
	zero = "00"
}

if variable_global_get(type + zero + string(skin_id)) = 1 {
	sprite_index = skin
} else { sprite_index = asset_get_index("s_locked" + type + "icon") }

if variable_global_get(type + "page") = page {
	x = lerp(x,originalx,0.2 * (60 / global.maxfps))
	y = lerp(y,originaly,0.2 * (60 / global.maxfps))
}
if variable_global_get(type + "page") < page {
	x = lerp(x,1164,0.2 * (60 / global.maxfps))
	y = lerp(y,416,0.2 * (60 / global.maxfps))	
}
if variable_global_get(type + "page") > page {
	x = lerp(x,-140,0.2 * (60 / global.maxfps))
	y = lerp(y,416,0.2 * (60 / global.maxfps))	
}

}