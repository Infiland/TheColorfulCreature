if global.workshop = 0 {
image_alpha = 1
image_speed = 0
mask_index = s_leveleditorhitbox
leveleditorrespawncooldown = 2

switch(global.defaultcolorLE) {
case(0): sprite_index = s_playerred break;
case(1): sprite_index = s_playeryellow break;
case(2): sprite_index = s_playergreen break;
case(3): sprite_index = s_playerblue break;
case(4): sprite_index = s_playerwhite break;
}} else {
alarm[0] = 1	
}