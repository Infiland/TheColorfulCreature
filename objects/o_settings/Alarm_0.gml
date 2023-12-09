if steam_name[0] = name { image_index = 4 foundrank = 1 global.foundcog = 4 }
if steam_name[1] = name { image_index = 3 foundrank = 1 global.foundcog = 3 }
if steam_name[2] = name { image_index = 2 foundrank = 1 global.foundcog = 2 }
for(var i=3;i<=10;i++) {
if steam_name[i] = name { image_index = 1 foundrank = 1 global.foundcog = 1 }
}
if foundrank = 0 {
alarm[0] = 10
}