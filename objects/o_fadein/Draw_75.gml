draw_set_alpha(1)
depth = -2000
draw_set_colour(c_black);
draw_rectangle(0,384 + yUp,1024,768,false)
draw_rectangle(0,384 - yUp,1024,0,false)
draw_set_colour(c_white);
draw_line_width(0,384 - yUp,1024,384 - yUp,5)
draw_line_width(0,384 + yUp,1024,384 + yUp,5)