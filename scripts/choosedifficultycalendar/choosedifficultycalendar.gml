function choosedifficultycalendar(){

switch(global.calendardifficulty) {
case(1): //EASY
global.calendarday1 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
global.calendarday2 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
global.calendarday3 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
global.calendarday4 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
global.calendarday5 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
global.calendarday6 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
global.calendarday7 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)

while global.calendarday2 = global.calendarday1 {
global.calendarday2 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
}
while global.calendarday3 = global.calendarday1 || global.calendarday3 = global.calendarday2 {
global.calendarday3 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
}
while global.calendarday4 = global.calendarday1 || global.calendarday4 = global.calendarday2 || global.calendarday4 = global.calendarday3 {
global.calendarday4 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
}
while global.calendarday5 = global.calendarday1 || global.calendarday5 = global.calendarday2 || global.calendarday5 = global.calendarday3 || global.calendarday5 = global.calendarday4 {
global.calendarday5 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
}
while global.calendarday6 = global.calendarday1 || global.calendarday6 = global.calendarday2 || global.calendarday6 = global.calendarday3 || global.calendarday6 = global.calendarday4 || global.calendarday6 = global.calendarday5 {
global.calendarday6 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
}
while global.calendarday7 = global.calendarday1 || global.calendarday7 = global.calendarday2 || global.calendarday7 = global.calendarday3 || global.calendarday7 = global.calendarday4 || global.calendarday7 = global.calendarday5 || global.calendarday7 = global.calendarday6 {
global.calendarday7 = choose(1,5,6,22,23,24,26,29,40,42,45,48,50,52,53,54,56,57,58,60,65,67,68,71)
}
break;
case(2): //MEDIUM
global.calendarday1 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
global.calendarday2 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
global.calendarday3 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
global.calendarday4 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
global.calendarday5 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
global.calendarday6 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
global.calendarday7 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)

while global.calendarday2 = global.calendarday1 {
global.calendarday2 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
}
while global.calendarday3 = global.calendarday1 || global.calendarday3 = global.calendarday2 {
global.calendarday3 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
}
while global.calendarday4 = global.calendarday1 || global.calendarday4 = global.calendarday2 || global.calendarday4 = global.calendarday3 {
global.calendarday4 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
}
while global.calendarday5 = global.calendarday1 || global.calendarday5 = global.calendarday2 || global.calendarday5 = global.calendarday3 || global.calendarday5 = global.calendarday4 {
global.calendarday5 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
}
while global.calendarday6 = global.calendarday1 || global.calendarday6 = global.calendarday2 || global.calendarday6 = global.calendarday3 || global.calendarday6 = global.calendarday4 || global.calendarday6 = global.calendarday5 {
global.calendarday6 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
}
while global.calendarday7 = global.calendarday1 || global.calendarday7 = global.calendarday2 || global.calendarday7 = global.calendarday3 || global.calendarday7 = global.calendarday4 || global.calendarday7 = global.calendarday5 || global.calendarday7 = global.calendarday6 {
global.calendarday7 = choose(2,3,7,8,11,12,15,16,18,19,20,21,25,27,28,30,31,32,33,34,35,36,39,41,43,44,46,47,49,51,55,59,61,62,63,64,66,69,72,73)
}
break;
case(3): //HARD
global.calendarday1 = choose(14,335,336,13,10,9,37,38,334,70)
global.calendarday2 = choose(14,335,336,13,10,9,37,38,334,70)
global.calendarday3 = choose(14,335,336,13,10,9,37,38,334,70)
global.calendarday4 = choose(14,335,336,13,10,9,37,38,334,70)
global.calendarday5 = choose(14,335,336,13,10,9,37,38,334,70)
global.calendarday6 = choose(14,335,336,13,10,9,37,38,334,70)
global.calendarday7 = choose(14,335,336,13,10,9,37,38,334,70)

while global.calendarday2 = global.calendarday1 {
global.calendarday2 = choose(14,335,336,13,10,9,37,38,334,70)
}
while global.calendarday3 = global.calendarday1 || global.calendarday3 = global.calendarday2 {
global.calendarday3 = choose(14,335,336,13,10,9,37,38,334,70)
}
while global.calendarday4 = global.calendarday1 || global.calendarday4 = global.calendarday2 || global.calendarday4 = global.calendarday3 {
global.calendarday4 = choose(14,335,336,13,10,9,37,38,334,70)
}
while global.calendarday5 = global.calendarday1 || global.calendarday5 = global.calendarday2 || global.calendarday5 = global.calendarday3 || global.calendarday5 = global.calendarday4 {
global.calendarday5 = choose(14,335,336,13,10,9,37,38,334,70)
}
while global.calendarday6 = global.calendarday1 || global.calendarday6 = global.calendarday2 || global.calendarday6 = global.calendarday3 || global.calendarday6 = global.calendarday4 || global.calendarday6 = global.calendarday5 {
global.calendarday6 = choose(14,335,336,13,10,9,37,38,334,70)
}
while global.calendarday7 = global.calendarday1 || global.calendarday7 = global.calendarday2 || global.calendarday7 = global.calendarday3 || global.calendarday7 = global.calendarday4 || global.calendarday7 = global.calendarday5 || global.calendarday7 = global.calendarday6 {
global.calendarday7 = choose(14,335,336,13,10,9,37,38,334,70)
}
break;
}

global.newcalendarseed = string(global.calendarday1)+string(global.calendarday2)+string(global.calendarday3)+string(global.calendarday4)+string(global.calendarday5)+string(global.calendarday6)+string(global.calendarday7)

draw_text(1020,740,"Seed: " + string(global.newcalendarseed))

/*draw_text(mouse_x,mouse_y,global.calendarday1)
draw_text(mouse_x,mouse_y+20,global.calendarday2)
draw_text(mouse_x,mouse_y+40,global.calendarday3)
draw_text(mouse_x,mouse_y+60,global.calendarday4)
draw_text(mouse_x,mouse_y+80,global.calendarday5)
draw_text(mouse_x,mouse_y+100,global.calendarday6)
draw_text(mouse_x,mouse_y+120,global.calendarday7)*/

}