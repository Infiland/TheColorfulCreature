scr_custombutton()

draw_set_font(global.cool2font)
draw_set_color(c_white)


random_set_seed(seed)
var d = date_hour_span(date_create_datetime(global.calendarcurrentyear, global.calendarcurrentmonth, global.calendarcurrentday, 24, 0, 0), date_current_datetime())

if diff != 0 {
draw_text(x,y+120,"Current Streak: " + string(global.dailylevelstreak))
draw_text(x,y+140,"Highest Streak: " + string(global.dailylevelhighstreak))
} else {
draw_text(x,y+120,"New level in: " + string_format(d,0,1) + "h");
draw_text(x,y+140,"Current Streak: " + string(global.dailylevelstreak))
}
//draw_text(x,y+160,"Seed: " + string(seed));
//draw_text(x,y+160,"Diff: " + string(diff2));

if global.dailylevelhighstreak > diff2 { global.cheats = 1
	steam_upload_score_ext("Current Daily Level Streak", 0,true);
	}
if global.dailylevelstreak > diff2 { global.cheats = 1
	steam_upload_score_ext("Current Daily Level Streak", 0,true);
	}

if global.dailylevelhighstreak >= 10 {
if !steam_get_achievement("DAILIES") { steam_set_achievement("DAILIES") }		
}