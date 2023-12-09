draw_self()
totaltime = lerp(totaltime,global.totaltime,0.2 * (60 / global.maxfps));
if global.totaltime < 230400 {
goal = 230400
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaltime)/1536,0.7,0,c_blue,1)
}
if global.totaltime < 115200 {
goal = 115200
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaltime)/768,0.7,0,c_blue,1)
}
if global.totaltime < 86400 {
goal = 86400
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaltime)/576,0.7,0,c_blue,1)
}
if global.totaltime < 43200 {
goal = 43200
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaltime)/288,0.7,0,c_blue,1)
}
if global.totaltime < 28800 {
goal = 28800
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaltime)/192,0.7,0,c_blue,1)
}
if global.totaltime < 14400 {
goal = 14400
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaltime)/96,0.7,0,c_blue,1)
}
if global.totaltime < 7200 {
goal = 7200
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaltime)/48,0.7,0,c_blue,1)
}
if global.totaltime < 3600 {
goal = 3600
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaltime)/24,0.7,0,c_blue,1)
}
if global.totaltime < 1800 {
goal = 1800
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaltime)/12,0.7,0,c_blue,1)
}
if global.totaltime < 900 {
goal = 900
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaltime)/6,0.7,0,c_blue,1)
}
if global.totaltime < 300 {
goal = 300
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaltime)/2,0.7,0,c_blue,1)
}

if global.totaltime < 230400 {
draw_set_font(fnt_multiplayerfont)
draw_text(xbar,ybar,string_format(totaltime/3600,0,1)+ "h / " + string(goal/3600) + "h")
}