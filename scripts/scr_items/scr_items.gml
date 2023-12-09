function scr_items(){
	
//Items Moving
itemtimer -= (walksp / 4) * (60 / global.maxfps)
if itemtimer < 0 { itemtimer = 80 }
if itemtimer < 40 { itemrot = lerp(itemrot,rot1,0.1 * (60 / global.maxfps)) }
if itemtimer > 40 {
if itemtimer < 80 { itemrot = lerp(itemrot,rot2,0.1 * (60 / global.maxfps)) }}

var item = global.itemselected
if instance_exists(o_playerMU) {
	item = multiplayerplayeritem
}

//Items
switch(item) {
case(1): draw_sprite_ext(s_paintbrushitem,0,x-(zerogrv*16),y+((20- (zerogrv*16))*itemscale),itemscale,itemscale,itemrot,c_white,1)
break;
case(2): draw_sprite_ext(s_floweritem,0,x-(zerogrv*16),y+((20- (zerogrv*16))*itemscale),itemscale,itemscale,itemrot,c_white,1) break;
case(3): 
rot1 = -10
rot2 = 10
draw_sprite_ext(s_shielditem,0,x-(zerogrv*16),y+((20- (zerogrv*16))*itemscale),itemscale,itemscale,itemrot,c_white,1) break;
}
}

rot1 = -130
rot2 = 130