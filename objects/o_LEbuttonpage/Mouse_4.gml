if isleft = 0 {
global.LEbuttonpage += 1	
} else { global.LEbuttonpage -= 1 }

if global.LEbuttonpage > maxpage {
global.LEbuttonpage = minpage	
}
if global.LEbuttonpage < minpage {
global.LEbuttonpage = maxpage	
}