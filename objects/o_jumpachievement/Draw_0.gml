draw_self()
totaljumps = lerp(totaljumps,global.totaljumps,0.2 * (60 / global.maxfps));
if global.totaljumps < 500000 {
goal = 500000
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaljumps)*0.0003,0.7,0,c_blue,1)
}
if global.totaljumps < 200000 {
goal = 200000
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaljumps)*0.00075,0.7,0,c_blue,1)
}
if global.totaljumps < 60000 {
goal = 60000
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaljumps)*0.0025,0.7,0,c_blue,1)
}
if global.totaljumps < 15000 {
goal = 15000
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaljumps),0.01,0,c_blue,1)
}
if global.totaljumps < 5000 {
goal = 5000
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaljumps)*0.03,0.7,0,c_blue,1)
}
if global.totaljumps < 2000 {
goal = 2000
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaljumps)*0.075,0.7,0,c_blue,1)
}
if global.totaljumps < 1000 {
goal = 1000
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaljumps)*0.15,0.7,0,c_blue,1)
}
if global.totaljumps < 250 {
goal = 250
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaljumps)*0.6,0.7,0,c_blue,1)
}
if global.totaljumps < 100 {
goal = 100
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaljumps)*1.5,0.7,0,c_blue,1)
}
if global.totaljumps < 20 {
goal = 20
draw_sprite_ext(s_xpbar,0,xbar,ybar,(totaljumps)*7.5,0.7,0,c_blue,1)
}

if global.totaljumps < 500000 {
draw_set_font(fnt_multiplayerfont)
draw_text(xbar,ybar,string_format(totaljumps,0,0)+ " / " + string(goal))
}