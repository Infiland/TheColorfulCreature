event_inherited()
skincustomizelogic(s_forsenEskinbutton,24,"skin")

if global.easy = 1 {image_index = 1}
if global.infinitelivessettings = 1 {image_index = 1}
if global.skinpage = 2 {
if global.skin024 = 0 {
if string_length(keyboard_string) > 7 { keyboard_string = "" }
if keyboard_string = "Forsene" or keyboard_string = "ForsenE" or keyboard_string = "forsenE" or keyboard_string = "forsene" or keyboard_string = "FORSENE" {
global.skin024 = 1
}}} else { if string_length(keyboard_string) > 0 { keyboard_string = "" } }