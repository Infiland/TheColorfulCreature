if room = r_leveleditor {
if global.LEBuild = 1 {
switch(global.LES) {
case(6): 
global.defaultcolorLE = 0
sprite_index = s_playerred
break;
case(7):
sprite_index = s_playeryellow
global.defaultcolorLE = 1 
break;
case(8): 
sprite_index = s_playergreen
global.defaultcolorLE = 2 
break;
case(9): 
sprite_index = s_playerblue
global.defaultcolorLE = 3 
break;
case(10): 
sprite_index = s_playerwhite
global.defaultcolorLE = 4 
break;
}
}}