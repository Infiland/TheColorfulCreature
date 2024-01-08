if room = r_dailylevelwin {
numerical = 1	
}
if room = r_gameoverscreen {
	
if diff = 0 {
if global.endlessrunmode = 1  {
lbname = "Endless Run"
} else { lbname = "Old School Endless Run" }
} else {
lbname = "Seasonal Endless Run"	
} numerical = 1
reloadleaderboardsmini()
}

if room = r_dailylevelwin {
if diff = 0 {
lbname = "Daily Level Streak"
} else {
lbname = "Current Daily Level Streak"	
} numerical = 1
reloadleaderboardsmini()
}

if room = r_endlessrunmenu {
if diff = 0 {
lbname = "Endless Run 20L"
} else {
lbname = "Endless Run 50L"	
} numerical = 0
reloadleaderboardsmini()
}