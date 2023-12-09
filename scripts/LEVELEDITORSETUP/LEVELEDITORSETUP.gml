function LEVELEDITORSETUP(restart=0){
	
if restart = 1 {
	
scr_saveleveleditor()
room_set_height(r_leveleditor,64+ (32*global.LELevelHeightBlocks))
room_set_width(r_leveleditor,32*global.LELevelWidthBlocks)
room_restart()
LEVELEDITORSETUP(0)
show_debug_message("Level Editor Setup Restart")
} else {
show_debug_message("Level Editor Setup Ready")
instance_create(x,y,o_spawnthing)
instance_destroy()
}

}