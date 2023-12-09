if global.hardmode = 1 { instance_destroy() 
exit;	
}

draw_set_font(global.deathfont)
draw_set_halign(fa_right)
draw_set_color(c_white)
for(var i = 0; i < 50; i++;) {
if steam_score[i] = 0 and steam_rank[i] = 0 {
if i = 0 { draw_text(990,200 + (diff*240),loc(665)) }
} else {
if i = 0 { draw_text_scribble(990,180 + (diff*240),"[rainbow]" + string(lbname)) }
if steam_rank[i] <= 10 { draw_set_color($a5d6ff) } else { draw_set_color(c_white) }
if steam_rank[i] = 1 { draw_set_color($00ccff) }
if steam_rank[i] = 2 { draw_set_color($e0e0e0) }
if steam_rank[i] = 3 { draw_set_color($1f82d3) }

if numerical = 0 {
draw_text(990,200+(i*20) + (diff*240),string(steam_rank[i]) + ".   " + string(steam_name[i]) + "   " + string(steam_score[i] / 1000) + "s")
} else { draw_text(990,200+(i*20) + (diff*240),string(steam_rank[i]) + ".   " + string(steam_name[i]) + "   " + string(steam_score[i])) }

}}
draw_set_halign(fa_left)