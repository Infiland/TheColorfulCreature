depth = -999
if grid = 1 {
var ix, iy
for(ix = 32; ix < global.LELevelWidthBlocks*32; ix += 32) {
draw_line_color(ix,64,ix,room_height,c_white,c_white)	
}
for(iy = 96; iy < global.LELevelHeightBlocks*32; iy += 32) {
draw_line_color(0,iy,room_width,iy,c_white,c_white)	
}
}