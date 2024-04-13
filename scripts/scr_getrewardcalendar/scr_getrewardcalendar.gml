function scr_getrewardcalendar(month,week){
switch(global.calendaryear) {
case(2022):	
	switch(month) {
	case(1):
	if week = 1 { if global.skin[46] = 0 {global.skin[46] = 1}}
	if week = 2 { if room != r_calendar {global.creditscurrency += floor(25 * global.creditsmultiplier)}}
    if week = 3 { if global.item[1] = 0 {global.item[1] = 1}}
	if week = 4 { if global.hat[39] = 0 {global.hat[39] = 1}}
	break;
	case(2):
	if week = 1 { if global.skin[47] = 0 {global.skin[47] = 1}}
	if week = 2 { if room != r_calendar {global.creditscurrency += floor(50 * global.creditsmultiplier)}}
    if week = 3 { if global.item[2] = 0 {global.item[2] = 1}}
	if week = 4 { if global.hat[45] = 0 {global.hat[45] = 1}}
	break;
	case(3):
	if week = 1 { if global.skin[48] = 0 {global.skin[48] = 1}}
	if week = 2 { if room != r_calendar {global.creditscurrency += floor(75 * global.creditsmultiplier)}}
    if week = 3 { if global.item[3] = 0 {global.item[3] = 1}}
	if week = 4 { if global.hat[46] = 0 {global.hat[46] = 1}}
	break;
	}
break;
}
}