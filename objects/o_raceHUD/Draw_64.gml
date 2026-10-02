draw_set_font(global.coolfont)
draw_text(128,20,"Player 1 "+loc("SCORE")+": " + string(global.racescore[0]))
draw_text(128,45,"Player 2 "+loc("SCORE")+": " + string(global.racescore[1]))
if global.multiplayerplayers > 2 { draw_text(128,70,"Player 3 "+loc("SCORE")+": " + string(global.racescore[2])) }
if global.multiplayerplayers > 3 { draw_text(128,95,"Player 4 "+loc("SCORE")+": " + string(global.racescore[3])) }
if global.pause = 1 { exit }
if global.playersleft <= 1 { 
	if global.decimalsettings = 0 {draw_text(615,96,"Restarting round in: " + string_format((variable_instance_exists(id,"timing_restarttimer_draw") ? timing_restarttimer_draw : restarttimer)/60,1,2))}
	if global.decimalsettings = 1 {draw_text(615,96,"Restarting round in: " + string_format((variable_instance_exists(id,"timing_restarttimer_draw") ? timing_restarttimer_draw : restarttimer)/60,1,1))}
} else {
	if global.decimalsettings = 0 {draw_text(615,96,loc("RACE_ENDS_IN") + string_format(racetimer/60,1,2))}
	if global.decimalsettings = 1 {draw_text(615,96,loc("RACE_ENDS_IN") + string_format(racetimer/60,1,1))}
}