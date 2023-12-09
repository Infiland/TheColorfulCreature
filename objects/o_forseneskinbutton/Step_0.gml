if global.skin024 = 0 {
sprite_index = s_lockedskinbutton	
}
if global.skin024 = 1 {
sprite_index = s_forsenEskinbutton
if global.easy = 1 {image_index = 1}
if global.infinitelivessettings = 1 {image_index = 1}
}

if global.skinschange = 0 {
if global.skinpage = page {
x = lerp(x,originalx,0.2 * (60 / global.maxfps))
y = lerp(y,originaly,0.2 * (60 / global.maxfps))
}
if global.skinpage < page {
x = lerp(x,1164,0.2 * (60 / global.maxfps))
y = lerp(y,416,0.2 * (60 / global.maxfps))	
}
if global.skinpage > page {
x = lerp(x,-140,0.2 * (60 / global.maxfps))
y = lerp(y,416,0.2 * (60 / global.maxfps))	
}}

if global.skinschange = 1 {
x = lerp(x,480,0.2 * (60 / global.maxfps))
y = lerp(y,800,0.2 * (60 / global.maxfps))
}

if global.skinpage = 2 {
if global.skin024 = 0 {
if string_length(keyboard_string) > 7 { keyboard_string = "" }
if keyboard_string = "Forsene" or keyboard_string = "ForsenE" or keyboard_string = "forsenE" or keyboard_string = "forsene" or keyboard_string = "FORSENE" {
global.skin024 = 1
}}} else { if string_length(keyboard_string) > 0 { keyboard_string = "" } }