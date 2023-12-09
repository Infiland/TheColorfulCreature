if global.CERyscroll > maxscr {
global.CERyscroll -= 30 * (144 / global.maxfps)
} else { global.CERyscroll = maxscr }