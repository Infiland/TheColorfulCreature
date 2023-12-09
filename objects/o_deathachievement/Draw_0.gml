draw_self()
totaldeaths = lerp(totaldeaths,global.totaldeaths,0.2 * (60 / global.maxfps));
if global.totaldeaths < 10000 {
goal = 10000
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaldeaths)*150/goal,0.7,0,c_blue,1)
}
if global.totaldeaths < 3000 {
goal = 3000
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaldeaths)*150/goal,0.7,0,c_blue,1)
}
if global.totaldeaths < 1000 {
goal = 1000
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaldeaths)*150/goal,0.7,0,c_blue,1)
}
if global.totaldeaths < 500 {
goal = 500
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaldeaths)*150/goal,0.7,0,c_blue,1)
}
if global.totaldeaths < 300 {
goal = 300
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaldeaths)*150/goal,0.7,0,c_blue,1)
}
if global.totaldeaths < 175 {
goal = 175
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaldeaths)*150/goal,0.7,0,c_blue,1)
}
if global.totaldeaths < 100 {
goal = 100
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaldeaths)*150/goal,0.7,0,c_blue,1)
}
if global.totaldeaths < 50 {
goal = 50
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaldeaths)*150/goal,0.7,0,c_blue,1)
}
if global.totaldeaths < 25 {
goal = 25
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaldeaths)*150/goal,0.7,0,c_blue,1)
}
if global.totaldeaths < 10 {
goal = 10
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaldeaths)*150/goal,0.7,0,c_blue,1)
}

if global.totaldeaths < 10000 {
draw_set_font(fnt_multiplayerfont)
draw_text(xbar,ybar,string_format(totaldeaths,0,0)+ " / " + string(goal))
}