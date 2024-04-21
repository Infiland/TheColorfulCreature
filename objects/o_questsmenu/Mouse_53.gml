//Remove Quests Menu when clicking off screen
if (mouse_x < 100 || mouse_x > 924) && alphalerp > 0.6 {
	instance_destroy()
}