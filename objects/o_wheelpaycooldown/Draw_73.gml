draw_set_halign(fa_center)
var cost = floor((global.wheeltimeleft/30) * (0.5 + (multi / 2)))
var maxcost = floor(120 * (0.5 + (multi / 2)))
draw_set_font(fnt_secret1)

if cost <= maxcost {
if cost > maxcost / 2 {
draw_text_scribble(x+90,y-40,"[wave][c_red][shake][scale,0.8]EXTREMELY RISKY")	}} 
if cost <= maxcost / 2 {
if cost > maxcost / 4 {
draw_text_scribble(x+90,y-40,"[wave][$ff7f00]RISKY")	}}
if cost <= maxcost / 4 {
if cost > maxcost / 10 {
draw_text_scribble(x+90,y-40,"[wave][c_yellow]MODERATE") }}
if cost <= maxcost / 10 {
draw_text_scribble(x+90,y-40,"[wave][c_lime]SAFE")	
}

draw_set_halign(fa_left)
scr_custombutton()