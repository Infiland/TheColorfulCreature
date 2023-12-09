if global.CERyscroll < minscr {
global.CERyscroll += 30 * (144 / global.maxfps)
} else { global.CERyscroll = minscr }