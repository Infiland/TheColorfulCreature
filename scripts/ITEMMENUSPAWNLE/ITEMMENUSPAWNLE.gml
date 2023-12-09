// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function ITEMMENUSPAWNLE(){
instance_destroy(o_itemmenuselectLE)
var i = 0, r = 0;
for(i = 0;i<13;i++) {
for(r = 0;r<8;r++) {
var itemnum = i  + (r*13)

var spawnitem = instance_create(96+(i*64),180+(r*64),o_itemmenuselectLE)
with spawnitem {
item = itemnum
scr_leveleditorsprites(itemnum)
}
}}
}