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
default: text = loc("JANUARY") break;
case(2): text = loc("FEBRUARY")
xscale = 0.73
yscale = 0.73
break;
case(3): text = loc("MARCH") break;
case(4): text = loc("APRIL") break;
case(5): text = loc("MAY") break;
case(6): text = loc("JUNE") break;
case(7): text = loc("JULY") break
case(8): text = loc("AUGUST") break;
case(9): text = loc("SEPTEMBER")
xscale = 0.63
yscale = 0.63
break;
case(10): text = loc("OCTOBER")
xscale = 0.75
yscale = 0.75
break;
case(11): text = loc("NOVEMBER")
xscale = 0.65
yscale = 0.65
break;
case(12): text = loc("DECEMBER")
xscale = 0.65
yscale = 0.65
break;
}