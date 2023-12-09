var i,w;

for(w = 0;w<=3;w++) {
for(i = 0;i<=6;i++) {
var level = instance_create(40+i*117,225+w*128,o_calendarlevel)
with level {
text = "Day\n" + string((i + 1)+7*w)
day = 1+(i+(7*w))
week = w+1
locked = 1
lockedtext = "???"

if global.calendaryear < global.calendarcurrentyear {
locked = 0	
}

if global.calendarmonth < global.calendarcurrentmonth {
locked = 0	
} else {

if global.calendarcurrentday >= 1 {
if week = 1 {
	locked = 0
}}
if global.calendarcurrentday >= 8 {
if week = 2 {
	locked = 0
}}
if global.calendarcurrentday >= 15 {
if week = 3 {
	locked = 0
}}
if global.calendarcurrentday >= 22 {
if week = 4 {
	locked = 0
}}

}


}

}}

instance_destroy()