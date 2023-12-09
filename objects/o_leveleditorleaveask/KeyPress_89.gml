audio_stop_all()
/*var directory = working_directory + "/LevelEditor Files/" + global.levelname + "/Music.ogg"
audio_destroy_stream(directory)*/
instance_destroy(o_ammocounter)
instance_destroy(o_deathcounter)
instance_destroy(o_musicdistortion)
instance_destroy(o_smoothcamera)
room_goto(r_mainmenu)
room_set_width(r_leveleditor,1024)
room_set_height(r_leveleditor,768)
global.LES = 0