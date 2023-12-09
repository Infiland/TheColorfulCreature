if global.totaltime > 230400 {
image_index = 11
}
if global.totaltime < 230400 {
image_index = 10
}
if global.totaltime < 115200 {
image_index = 9
}
if global.totaltime < 86400 {
image_index = 8
}
if global.totaltime < 43200 {
image_index = 7
}
if global.totaltime < 28800 {
image_index = 6
}
if global.totaltime < 14400 {
image_index = 5
}
if global.totaltime < 7200 {
image_index = 4
}
if global.totaltime < 3600 {
image_index = 3
}
if global.totaltime < 1800 {
image_index = 2
}
if global.totaltime < 900 {
image_index = 1
}
if global.totaltime < 300 {
image_index = 0
}