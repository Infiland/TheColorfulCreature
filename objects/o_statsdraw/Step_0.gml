//Color
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

key_down = keyboard_check(vk_up) || keyboard_check(ord("W"))
key_up = keyboard_check(vk_down) || keyboard_check(ord("S"))
if mouse_wheel_up() { yscrollreal -= 4000 * (delta_time / 1000000) }
if mouse_wheel_down() { yscrollreal +=4000 * (delta_time / 1000000) }

if os_type = os_android {
if mouse_check_button(mb_left) {
if mouse_y < 512 {key_down = true} else { key_up = true }
} else {
	key_up = false
	key_down = false
}}

if key_down { yscrollreal -= 500 * (delta_time / 1000000) }
if key_up { yscrollreal += 500 * (delta_time / 1000000) }

if yscrollreal < 0 { yscrollreal = 0 }
if yscrollreal > 770 { yscrollreal = 770 }

yscroll = lerp(yscroll,yscrollreal,0.2)