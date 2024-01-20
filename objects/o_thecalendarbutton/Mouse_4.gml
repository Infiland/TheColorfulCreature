/// @description Click to start
global.calendaryear = 2022
global.calendarmonth = 1

if locked = 0 {
room_goto(r_calendar)
var directory = directory_set("/Save Files//Calendar//" + string(global.calendaryear) + "/")
if !directory_exists(directory) {
directory_create(directory)
scr_createrewardsavefiles()
}}

if global.calendarcurrentyear > 2021 {
if locked = 1 {
if global.calendar2022unlock = 0 {
if global.creditscurrency >= floor(calendarcost) {	
global.creditscurrency -= floor(calendarcost)
audio_play_sound(snd_cashsound,0,0)
global.calendar2022unlock = 1
locked = 0
text = loc(317)
scr_savestats()
scr_savecalendar()
}}}}