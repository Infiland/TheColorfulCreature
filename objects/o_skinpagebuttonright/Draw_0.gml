draw_self()
draw_set_font(global.deathfont)
switch(global.customizeselect) {
case(1): //Skins
	draw_text(464,585,string(loc(46)) + " " + string(global.skinpage) + " / " + string(skinpage))
break;
case(2): //Hats
	draw_text(464,585,string(loc(46)) + " " + string(global.hatpage) + " / " + string(hatpage))
break;
case(3): //Items
	draw_text(464,585,string(loc(46)) + " " + string(global.itempage) + " / " + string(itempage))
break;
	}	