draw_sprite(s_enemyidle,0,x,y)
if hpproj > 1 {
draw_sprite_ext(s_enemyhat,0,x+16,y+16,1+hpproj/15,1+hpproj/15,0,c_white,1)
}