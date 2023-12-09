function scr_LEChangeScenery(){
switch(global.LEBackground) {
case(0): instance_destroy(o_allbackgrounds) break;
case(1): instance_destroy(o_allbackgrounds)
var beam = instance_create(x,y,o_lightbeamspawner)
with beam {
	timer = 1
}
break;
case(2): instance_destroy(o_allbackgrounds)
instance_create(-230,y,o_towerbackground) break;
}
}