function scr_breakingblockscript(){
if global.pause = 1 { exit }
	
if hpbreakable < hpbreakablemax - (hpbreakablemax/3) * 2{
	if image_index != 2 {
	scr_blockbreaksound()
	image_index = 2}} else {
if hpbreakable < hpbreakablemax - (hpbreakablemax/3) {
if image_index != 1 {
	image_index = 1
	scr_blockbreaksound()
}}}

if hpbreakable < 0 {
if room != r_leveleditor {
if instance_exists(o_player) {
if place_meeting(x,(y-(o_player.vsp)-1),o_player) {
global.totalblocksbroken += 1
o_player.vsp = 0
}}}
instance_destroy()
}

scr_breakableby(o_player)
scr_breakableby(o_playerMU)
scr_breakableby(o_enemyplayer)

if instance_exists(o_rocket) {
if instance_place(x,y,o_rocket) {
	hpbreakable -= 10
}}
if instance_exists(o_rocket2) {
if instance_place(x,y,o_rocket2) {
	hpbreakable -= 10
}}
}