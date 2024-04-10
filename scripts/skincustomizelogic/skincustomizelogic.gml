function skincustomizelogic(skin,skin_id,type="hat"){

//Prob there's a better way to do this
switch(type) {
case("skin"): var thething = global.skin[skin_id] break;	
case("hat"): var thething = global.hat[skin_id] break;
case("item"): var thething = global.item[skin_id] break;	
}

if thething = 1 {
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