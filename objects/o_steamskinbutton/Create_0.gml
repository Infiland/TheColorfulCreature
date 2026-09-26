page = 3
event_inherited()

if global.skin[44] = 0 {
if global.customlevelcompleted > 49 {
	global.skin[44] = 1
	if !achievement_earned("WORKSHOP_MASTER") { achievement_award("WORKSHOP_MASTER") }
}}
