function draw_text_outline(argument0, argument1, argument2, argument3, argument4) {
	var xx=argument0;
	var yy=argument1;
	var text=argument2;
	var tcolor=argument3;
	var ocolor=argument4;

	draw_set_color(ocolor)
	draw_text(xx-1,yy,text)
	draw_text(xx+1,yy,text)
	draw_text(xx,yy-1,text)
	draw_text(xx,yy+1,text)

	draw_set_color(tcolor)
	draw_text(xx,yy,text)


}
