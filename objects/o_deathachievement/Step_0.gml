if global.totaldeaths > 10000 {
image_index = 11
}
if global.totaldeaths < 10000 {
image_index = 10
}
if global.totaldeaths < 3000 {
image_index = 9
}
if global.totaldeaths < 1000 {
image_index = 8
}
if global.totaldeaths < 500 {
image_index = 7
}
if global.totaldeaths < 300 {
image_index = 6
}
if global.totaldeaths < 175 {
image_index = 5
}
if global.totaldeaths < 100 {
image_index = 4
}
if global.totaldeaths < 50 {
image_index = 3
}
if global.totaldeaths < 25 {
image_index = 2
}
if global.totaldeaths < 10 {
image_index = 1
}
if global.totaldeaths < 1 {
image_index = 0
}