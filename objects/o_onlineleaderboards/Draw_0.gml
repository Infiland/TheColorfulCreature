draw_set_halign(fa_center)
draw_text_ext(820,550,loc(666),20,400)
draw_set_halign(fa_left)
draw_set_font(fnt_deathcyrillic)
draw_text_scribble(60,120-scroll,"[rainbow]" + string(lbname) +"[/]")
for(var i = 0; i < 100; i++;)
        {
if steam_score[i] = 0 and steam_rank[i] = 0 {
if i = 0 { draw_text(60,160,loc(665)) }
} else {
draw_set_color(c_white)
if steam_rank[i] <= 10 { draw_set_color($a5d6ff) }
if steam_rank[i] = 1 { draw_set_color($00ccff) }
if steam_rank[i] = 2 { draw_set_color($e0e0e0) }
if steam_rank[i] = 3 { draw_set_color($1f82d3) }
if global.leaderboardselect >= 0 {
draw_text(60,160+(i*20)-scroll,string(steam_rank[i]) + ".   " + string(steam_name[i]) + "   " + string(steam_score[i] / 1000) + "s")
} else {
draw_text(60,160+(i*20)-scroll,string(steam_rank[i]) + ".   " + string(steam_name[i]) + "   " + string(steam_score[i]))
}
}
}