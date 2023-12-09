function scr_getrewardcalendar(month,week){
switch(global.calendaryear) {
case(2022):	
	switch(month) {
	case(1):
	if week = 1 { if global.skin046 = 0 {global.skin046 = 1}}
	if week = 2 { if room != r_calendar {global.creditscurrency += floor(25 * global.creditsmultiplier)}}
    if week = 3 { if global.item001 = 0 {global.item001 = 1}}
	if week = 4 { if global.hat039 = 0 {global.hat039 = 1}}
	break;
	case(2):
	if week = 1 { if global.skin047 = 0 {global.skin047 = 1}}
	if week = 2 { if room != r_calendar {global.creditscurrency += floor(50 * global.creditsmultiplier)}}
    if week = 3 { if global.item002 = 0 {global.item002 = 1}}
	if week = 4 { if global.hat045 = 0 {global.hat045 = 1}}
	break;
	case(3):
	if week = 1 { if global.skin048 = 0 {global.skin048 = 1}}
	if week = 2 { if room != r_calendar {global.creditscurrency += floor(75 * global.creditsmultiplier)}}
    if week = 3 { if global.item003 = 0 {global.item003 = 1}}
	if week = 4 { if global.hat046 = 0 {global.hat046 = 1}}
	break;
	}
break;
}
}