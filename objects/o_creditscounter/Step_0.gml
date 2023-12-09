//RGB System
if credits > 9999999 {
if change = 0 {
blue += 3
if blue > 255 {
blue = 255
change = 1
}}
if change = 1 {
red -= 3
if red < 0 {
red = 0
change = 2
}}
if change = 2 {
green += 3
if green > 255 {
green = 255
change = 3
}}
if change = 3 {
blue -= 3
if blue < 0 {
blue = 0
change = 4
}}
if change = 4 {
red += 3
if red > 255 {
red = 255
change = 5
}}
if change = 5 {
green -= 3
if green < 0 {
green = 0
change = 0
}}
}