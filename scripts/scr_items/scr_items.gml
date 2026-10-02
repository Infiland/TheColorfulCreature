// Presentation swing advances after actor Step, once per logical tick.
function timing_items_update() {
//Items Moving
itemtimer -= (walksp / 4)
if itemtimer < 0 { itemtimer = 80 }
if itemtimer < 40 { itemrot = lerp(itemrot,rot1,0.1) }
if itemtimer > 40 {
if itemtimer < 80 { itemrot = lerp(itemrot,rot2,0.1) }}

var item = global.itemselected
if variable_instance_exists(id,"multiplayerplayeritem") {
	item = multiplayerplayeritem
}
rot1 = 0
rot2 = -180
if (!(variable_instance_exists(id,"customitem") && customitem == 1 && sprite_exists(customitem_spr)) && item == 3) {
    rot1 = -10;
    rot2 = 10;
}
}

function scr_items(){

var item = variable_instance_exists(id,"multiplayerplayeritem") ? multiplayerplayeritem : global.itemselected;
// Custom items share the existing swing and never modify collision or abilities.
if (variable_instance_exists(id,"customitem") && customitem == 1 && sprite_exists(customitem_spr)) {
    draw_sprite_ext(customitem_spr,0,x-(zerogrv*16),y+((20-(zerogrv*16))*itemscale),
        itemscale*customitemxscale,itemscale*customitemyscale,itemrot,c_white,1);
    return;
}
//Items
switch(item) {
case(1): draw_sprite_ext(s_paintbrushitem,0,x-(zerogrv*16),y+((20- (zerogrv*16))*itemscale),itemscale,itemscale,itemrot,c_white,1)
break;
case(2): draw_sprite_ext(s_floweritem,0,x-(zerogrv*16),y+((20- (zerogrv*16))*itemscale),itemscale,itemscale,itemrot,c_white,1) break;
case(3): 
draw_sprite_ext(s_shielditem,0,x-(zerogrv*16),y+((20- (zerogrv*16))*itemscale),itemscale,itemscale,itemrot,c_white,1) break;
}
}

//rot1 = -130
//rot2 = 130