if mouse_wheel_up() {
scroll -= 150	
}
if mouse_wheel_down() {
scroll += 150	
}

if scroll < 0 { scroll = 0 }
if scroll > scrollcap { scroll = scrollcap }

global.achievementsscroll = lerp(global.achievementsscroll,scroll,0.2*(60/global.maxfps))