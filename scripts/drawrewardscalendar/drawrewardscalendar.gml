function drawrewardscalendar(firstreward,secondreward,thirdreward,fourthreward){
draw_set_halign(fa_right)
draw_set_color(c_white)
draw_set_font(global.deathfont)
draw_sprite(firstreward,0,860,222)
if rewarded1 = 1 {
	draw_sprite(s_levelhud,0,862,224)
}
if firstreward = s_creditshatbutton {
draw_text(960,301,global.calendarmonth*25)
}
draw_sprite(secondreward,0,860,350)
if rewarded2 = 1 {
	draw_sprite(s_levelhud,0,862,352)
}
if secondreward = s_creditshatbutton {
draw_text(960,429,global.calendarmonth*25)
}
draw_sprite(thirdreward,0,860,478)
if rewarded3 = 1 {
	draw_sprite(s_levelhud,0,862,480)
}
if thirdreward = s_creditshatbutton {
draw_text(960,557,global.calendarmonth*25)
}
draw_sprite(fourthreward,0,860,606)
if rewarded4 = 1 {
	draw_sprite(s_levelhud,0,862,608)
}
if fourthreward = s_creditshatbutton {
draw_text(960,685,global.calendarmonth*25)
}
draw_set_halign(fa_left)
}