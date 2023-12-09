draw_self()
totalcoins = lerp(totalcoins,global.totalcoins,0.2 * (60 / global.maxfps));
if global.totalcoins < 2500 {
goal = 2500
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totalcoins)*150/goal,0.7,0,c_blue,1)
}
if global.totalcoins < 750 {
goal = 750
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totalcoins)*150/goal,0.7,0,c_blue,1)
}
if global.totalcoins < 250 {
goal = 250
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totalcoins)*150/goal,0.7,0,c_blue,1)
}
if global.totalcoins < 150 {
goal = 150
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totalcoins)*150/goal,0.7,0,c_blue,1)
}
if global.totalcoins < 100 {
goal = 100
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totalcoins)*150/goal,0.7,0,c_blue,1)
}
if global.totalcoins < 75 {
goal = 75
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totalcoins)*150/goal,0.7,0,c_blue,1)
}
if global.totalcoins < 50 {
goal = 50
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totalcoins)*150/goal,0.7,0,c_blue,1)
}
if global.totalcoins < 30 {
goal = 30
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totalcoins)*150/goal,0.7,0,c_blue,1)
}
if global.totalcoins < 15 {
goal = 15
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totalcoins)*150/goal,0.7,0,c_blue,1)
}
if global.totalcoins < 5 {
goal = 5
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totalcoins)*150/goal,0.7,0,c_blue,1)
}

if global.totalcoins < 2500 {
draw_set_font(fnt_multiplayerfont)
draw_text(xbar,ybar,string_format(totalcoins,0,0)+ " / " + string(goal))
}