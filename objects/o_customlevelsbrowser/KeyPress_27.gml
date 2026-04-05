/// @description ESC - close browser

// If editing search, just stop editing (don't close)
if editing_search {
	editing_search = false
	exit
}

instance_destroy()
