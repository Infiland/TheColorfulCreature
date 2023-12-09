draw_self()
totallevel = lerp(totallevel,global.totallevelcompleted,0.2 * (60 / global.maxfps));
if global.totallevelcompleted < 2500 {
goal = 2500
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totallevel)*150/goal,0.7,0,c_blue,1)
}
if global.totallevelcompleted < 750 {
goal = 750
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totallevel)*150/goal,0.7,0,c_blue,1)
}
if global.totallevelcompleted < 250 {
goal = 250
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totallevel)*150/goal,0.7,0,c_blue,1)
}
if global.totallevelcompleted < 150 {
goal = 150
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totallevel)*150/goal,0.7,0,c_blue,1)
}
if global.totallevelcompleted < 100 {
goal = 100
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totallevel)*150/goal,0.7,0,c_blue,1)
}
if global.totallevelcompleted < 75 {
goal = 75
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totallevel)*150/goal,0.7,0,c_blue,1)
}
if global.totallevelcompleted < 50 {
goal = 50
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totallevel)*150/goal,0.7,0,c_blue,1)
}
if global.totallevelcompleted < 30 {
goal = 30
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totallevel)*150/goal,0.7,0,c_blue,1)
}
if global.totallevelcompleted < 15 {
goal = 15
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totallevel)*150/goal,0.7,0,c_blue,1)
}
if global.totallevelcompleted < 5 {
goal = 5
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totallevel)*150/goal,0.7,0,c_blue,1)
}

if global.totallevelcompleted < 2500 {
draw_set_font(fnt_multiplayerfont)
draw_text(xbar,ybar,string_format(totallevel,0,0)+ " / " + string(goal))
}