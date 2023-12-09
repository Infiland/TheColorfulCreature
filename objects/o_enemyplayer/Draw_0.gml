draw_self()
if hp > 1 { draw_sprite_ext(s_enemyhat,0,x+16,y+16,1+hp/15,1+hp/15,0,c_white,1) }

var col = c_lime
	if state = 2 {  col = c_lime }
	if state = 1 {col = c_red }	
	if state = 0 {col = c_yellow }	
cansee = 0
if instance_exists(o_player) {
if collision_line(x+16,y+16,o_player.x+16,o_player.y+16,o_anyblock,false,false) {
	cansee = 1
	}
/*draw_line_width_color(x+16,y+16,o_player.x+16,o_player.y+16,5,col,col)*/
}