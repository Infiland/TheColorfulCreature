// Rebuild trade-up list after inventory refresh
entries = scr_build_tradeup_list()
selected = clamp(selected, 0, max(array_length(entries) - 1, 0))