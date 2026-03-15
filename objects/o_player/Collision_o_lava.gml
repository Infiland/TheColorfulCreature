if global.easy = 0 {
	increase_stat("totallavadeaths","QUESTlavadeaths",1)
	instance_create(x,y,o_fire)
	death()
}
