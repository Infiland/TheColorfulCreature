depth = -40000

// Build the list of eligible trade-up entries
entries = scr_build_tradeup_list()

// Navigation state
selected = 0
dis = 0 // Smooth scroll offset
press = 0
holdcooldown = 40
arrowyscale = 1
change = 0

// Trade state
trade_handle = undefined
trade_in_progress = false