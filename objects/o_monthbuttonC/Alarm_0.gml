if month > global.calendarcurrentmonth {
locked = 1
}

/*if global.calendarcurrentyear < global.calendaryear {
if global.calendarcurrentyear > global.calendaryear { exit }
if global.calendarcurrentmonth - 4 < month {
locked = 1
}}*/

/*if month > 1 {
locked = 1
}*/

switch(month) {
default: text = loc(318) break;
case(2): text = loc(319)
xscale = 0.73
yscale = 0.73
break;
case(3): text = loc(320) break;
case(4): text = loc(321) break;
case(5): text = loc(322) break;
case(6): text = loc(323) break;
case(7): text = loc(324) break
case(8): text = loc(325) break;
case(9): text = loc(326)
xscale = 0.63
yscale = 0.63
break;
case(10): text = loc(327)
xscale = 0.75
yscale = 0.75
break;
case(11): text = loc(328)
xscale = 0.65
yscale = 0.65
break;
case(12): text = loc(329)
xscale = 0.65
yscale = 0.65
break;
}