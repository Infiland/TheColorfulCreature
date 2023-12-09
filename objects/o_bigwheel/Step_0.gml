y = lerp(y,384,0.1 * (60 / global.maxfps))

direction += wheelspeed * (60 / global.maxfps)
if rewarded = 0 {
if spinned = 1 {
if wheelspeed > 0 {
wheelspeed -= 0.12 * (60 / global.maxfps)
} else {
wheelspeed = 0
rewarded = 1
spinned = 0
global.wheeltimeleft = 3600	

if direction > 0 { //Reward 1
if direction < 36 {
global.creditscurrency += floor(250 * multi)
}}
if direction > 36 { //Reward 2
if direction < 72 {
global.creditscurrency += floor(25 * multi)	
}}
if direction > 72 { //Reward 3
if direction < 108 {
global.creditscurrency += floor(75 * multi)
}}
if direction > 108 { //Reward 4
if direction < 144 {
global.creditscurrency += floor(10 * multi)
global.wheeltimeleft = 0
spinned = 0
rewarded = 0
}}
if direction > 144 { //Reward 5
if direction < 180 {
global.creditscurrency += floor(25 * multi)
}}
if direction > 180 { //Reward 6
if direction < 216 {
global.creditscurrency += floor(10 * multi)
}}
if direction > 216 { //Reward 7
if direction < 252 {
global.creditscurrency += floor(50 * multi)
}}
if direction > 252 { //Reward 8
if direction < 288 {
global.creditscurrency += floor(100 * multi)
}}
if direction > 288 { //Reward 9
if direction < 324 {
global.creditscurrency += floor(10 * multi)
}}
if direction > 324 { //Reward 10
if direction < 360 {
global.creditscurrency += floor(50 * multi)
}}
if global.wheeltimeleft > 0 {
if !instance_exists(o_wheelpaycooldown) {
instance_create(x,y,o_wheelpaycooldown)
}}
scr_savestats()
}}}
image_angle = direction
depth = -1000