draw_set_font(global.coolfont)
draw_text(128,20,"Player 1 "+loc(58)+": " + string(global.racescore[0]))
draw_text(128,45,"Player 2 "+loc(58)+": " + string(global.racescore[1]))
if global.multiplayerplayers > 2 { draw_text(128,70,"Player 3 "+loc(58)+": " + string(global.racescore[2])) }
if global.multiplayerplayers > 3 { draw_text(128,95,"Player 4 "+loc(58)+": " + string(global.racescore[3])) }
if global.pause = 1 { exit }
if global.playersleft <= 1 { 
	if global.decimalsettings = 0 {draw_text(615,96,"Restarting round in: " + string_format(restarttimer/60,1,2))}
	if global.decimalsettings = 1 {draw_text(615,96,"Restarting round in: " + string_format(restarttimer/60,1,1))}
	restarttimer -= 1 * (60 / global.maxfps)
	if restarttimer < 0 { randomlevelMU() }
} else {
racetimer -= 1 * (60 / global.maxfps)
	if global.decimalsettings = 0 {draw_text(615,96,loc(63) + string_format(racetimer/60,1,2))}
	if global.decimalsettings = 1 {draw_text(615,96,loc(63) + string_format(racetimer/60,1,1))}
if racetimer < 0 { randomlevelMU() }
}