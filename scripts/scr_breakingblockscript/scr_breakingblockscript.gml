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