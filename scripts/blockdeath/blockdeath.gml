function blockdeath(){
if room != r_leveleditor {
	global.totalblockdeaths += 1
	increase_stat("totalblockdeaths","QUESTblockdeaths",1)
	}
death();
}