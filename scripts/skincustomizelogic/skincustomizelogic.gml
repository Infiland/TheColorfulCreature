function skincustomizelogic(skin,skin_id,type="hat",item_def=0){
mastery = 0
//Prob there's a better way to do this
switch(type) {
//SKINS
case("skin"):
var thething = global.skin[skin_id]
if item_def = 0 { item_def = skin_id*5 + 95 }
	if global.itemdef[item_def] > 0 { //LEGENDARY
		mastery = 5 
	}
else if global.itemdef[item_def+1] > 0 { //EPIC
	mastery = 4
	}
else if global.itemdef[item_def+2] > 0 { //RARE
	mastery = 3
	}
else if global.itemdef[item_def+3] > 0 { //UNCOMMON
	mastery = 2
	}
else if global.itemdef[item_def+4] > 0 { //COMMON
	mastery = 1
	}
	if mastery > 0 {
		if thething = 0 { global.skin[skin_id] = 1 }	
	}
break;
//HATS
case("hat"): var thething = global.hat[skin_id]
if item_def = 0 { item_def = skin_id + 1999 }
//Depending on item quantity, mastery is better
if global.itemdef[item_def] > 0 { mastery = 1 }
if global.itemdef[item_def] >= 2 { mastery = 2 }
if global.itemdef[item_def] >= 4 { mastery = 3 }
if global.itemdef[item_def] >= 8 { mastery = 4 }
if global.itemdef[item_def] >= 16 { mastery = 5 }
	if mastery > 0 {
		if thething = 0 { global.hat[skin_id] = 1 }	
	}
break;
//ITEMS
case("item"): var thething = global.item[skin_id]
if item_def = 0 { item_def = skin_id + 3999 }
//Depending on item quantity, mastery is better
if global.itemdef[item_def] > 0 { mastery = 1 }
if global.itemdef[item_def] >= 2 { mastery = 2 }
if global.itemdef[item_def] >= 4 { mastery = 3 }
if global.itemdef[item_def] >= 8 { mastery = 4 }
if global.itemdef[item_def] >= 16 { mastery = 5 }
	if mastery > 0 {
		if thething = 0 { global.hat[skin_id] = 1 }	
	}
break;	
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