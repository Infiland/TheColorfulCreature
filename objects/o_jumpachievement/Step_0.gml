if global.totaljumps > 500000 {
image_index = 11
}
if global.totaljumps < 500000 {
image_index = 10
}
if global.totaljumps < 200000 {
image_index = 9
}
if global.totaljumps < 60000 {
image_index = 8
}
if global.totaljumps < 15000 {
image_index = 7
}
if global.totaljumps < 5000 {
image_index = 6
}
if global.totaljumps < 2000 {
image_index = 5
}
if global.totaljumps < 1000 {
image_index = 4
}
if global.totaljumps < 250 {
image_index = 3
}
if global.totaljumps < 100 {
image_index = 2
}
if global.totaljumps < 20 {
image_index = 1
}
if global.totaljumps < 1 {
image_index = 0
}