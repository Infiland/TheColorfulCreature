if global.levelname = "" {
room_set_width(r_leveleditor,1024)
room_set_height(r_leveleditor,768)
room_restart()
keyboard_string = ""
global.LEBuild = 1
global.levelname = ""
global.previoustext = ""
global.leveleditorstring = ""
global.naminglevel = false
global.defaultcolorLE = 0
global.LEMode = 1
global.color = 0
global.LEBackground = 0
global.LEStarRotation = 0
global.LEbuttonpage = 1
global.LEVerified = 0
} else {
instance_create(x,y,o_leveleditorsaveask)
}

instance_destroy()