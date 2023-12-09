draw_set_alpha(1)
draw_set_font(c_white)
if global.LEMode = 2 {
image_alpha = 0
draw_set_font(global.deathfont)
draw_text_ext(790,10,CANTBUILD,25,200)	
draw_set_alpha(0)
} else {
	x = 950 
y = 17
image_blend = c_white
if global.LEMode = 1 {
//scr_leveleditorsprites(global.LES)
}
}
draw_set_font(global.cool2font)
if global.LEBuild = 1 {
draw_text(835,15,string(global.LES + 1) + " / 96")
switch(global.LES) {
case(0): draw_text_ext(xtext,ytext,CNT_PLAYER,20,194) break;
case(1): draw_text_ext(xtext,ytext,CNT_REDBLOCK,20,194) break;
case(2): draw_text_ext(xtext,ytext,CNT_YELLOWBLOCK,20,194) break;
case(3): draw_text_ext(xtext,ytext,CNT_GREENBLOCK,20,194) break;
case(4): draw_text_ext(xtext,ytext,CNT_BLUEBLOCK,20,194) break;
case(5): draw_text_ext(xtext,ytext,CNT_WHITEBLOCK,20,194) break;
case(6): draw_text_ext(xtext,ytext,CNT_REDPICKUP,20,194) break;
case(7): draw_text_ext(xtext,ytext,CNT_YELLOWPICKUP,20,194) break;
case(8): draw_text_ext(xtext,ytext,CNT_GREENPICKUP,20,194) break;
case(9): draw_text_ext(xtext,ytext,CNT_BLUEPICKUP,20,194) break;
case(10): draw_text_ext(xtext,ytext,CNT_WHITEPICKUP,20,194) break;
case(11): draw_text_ext(xtext,ytext,CNT_DOOR,20,194) break;
case(12): draw_text_ext(xtext,ytext,CNT_KEY,20,194) break;
case(13): draw_text_ext(xtext,ytext,CNT_SPIKE,20,194) break;
case(14): draw_text_ext(xtext,ytext,CNT_SPIKERIGHT,20,194) break;
case(15): draw_text_ext(xtext,ytext,CNT_SPIKELEFT,20,194) break;
case(16): draw_text_ext(xtext,ytext,CNT_SPIKETOP,20,194) break;
case(17): draw_text_ext(xtext,ytext,CNT_INVSPIKE,20,194) break;
case(18): draw_text_ext(xtext,ytext,CNT_INVSPIKERIGHT,20,194) break;
case(19): draw_text_ext(xtext,ytext,CNT_INVSPIKELEFT,20,194) break;
case(20): draw_text_ext(xtext,ytext,CNT_INVSPIKETOP,20,194) break;
case(21): draw_text_ext(xtext,ytext,CNT_CANNONL,20,194) break;
case(22): draw_text_ext(xtext,ytext,CNT_CANNONR,20,194) break;
case(23): draw_text_ext(xtext,ytext,CNT_ULTRALOWG,20,194) break;
case(24): draw_text_ext(xtext,ytext,CNT_LOWG,20,194) break;
case(25): draw_text_ext(xtext,ytext,CNT_NORMALG,20,194) break;
case(26): draw_text_ext(xtext,ytext,CNT_HIGHG,20,194) break;
case(27): draw_text_ext(xtext,ytext,CNT_SLOWS,20,194) break;
case(28): draw_text_ext(xtext,ytext,CNT_NORMALS,20,194) break;
case(29): draw_text_ext(xtext,ytext,CNT_FASTS,20,194) break;
case(30): draw_text_ext(xtext,ytext,CNT_LIGHTNINGS,20,194) break;
case(31): draw_text_ext(xtext,ytext,CNT_REDSPIRAL,20,194) break;
case(32): draw_text_ext(xtext,ytext,CNT_YELLOWSPIRAL,20,194) break;
case(33): draw_text_ext(xtext,ytext,CNT_GREENSPIRAL,20,194) break;
case(34): draw_text_ext(xtext,ytext,CNT_BLUESPIRAL,20,194) break;
case(35): draw_text_ext(xtext,ytext,CNT_WHITESPIRAL,20,194) break;
case(36): draw_text_ext(xtext,ytext,CNT_COIN,20,194) break;
case(37): draw_text_ext(xtext,ytext,CNT_REDMOVINGPLATFORM,20,194) break;
case(38): draw_text_ext(xtext,ytext,CNT_YELLOWMOVINGPLATFORM,20,194) break;
case(39): draw_text_ext(xtext,ytext,CNT_GREENMOVINGPLATFORM,20,194) break;
case(40): draw_text_ext(xtext,ytext,CNT_BLUEMOVINGPLATFORM,20,194) break;
case(41): draw_text_ext(xtext,ytext,CNT_WHITEMOVINGPLATFORM,20,194) break;
case(42): draw_text_ext(xtext,ytext,CNT_PORTALENTER,20,194) break;
case(43): draw_text_ext(xtext,ytext,CNT_PORTALEXIT,20,194) break;
case(44): draw_text_ext(xtext,ytext,CNT_REDPASSBLOCK,20,194) break;
case(45): draw_text_ext(xtext,ytext,CNT_YELLOWPASSBLOCK,20,194) break;
case(46): draw_text_ext(xtext,ytext,CNT_GREENPASSBLOCK,20,194) break;
case(47): draw_text_ext(xtext,ytext,CNT_BLUEPASSBLOCK,20,194) break;
case(48): draw_text_ext(xtext,ytext,CNT_WHITEPASSBLOCK,20,194) break;
case(49): draw_text_ext(xtext,ytext,CNT_TORCH,20,194) break;
case(50): draw_text_ext(xtext,ytext,CNT_TROOP,20,194) break;
case(51): draw_text_ext(xtext,ytext,CNT_ONEWAYUPBLOCK,20,194) break;
case(52): draw_text_ext(xtext,ytext,CNT_ONEWAYRIGHTBLOCK,20,194) break;
case(53): draw_text_ext(xtext,ytext,CNT_ONEWAYDOWNBLOCK,20,194) break;
case(54): draw_text_ext(xtext,ytext,CNT_ONEWAYDOWNBLOCK,20,194) break;
case(55): draw_text_ext(xtext,ytext,CNT_LADDER,20,194) break;
case(56): draw_text_ext(xtext,ytext,CNT_ROCKETCANNONL,20,194) break;
case(57): draw_text_ext(xtext,ytext,CNT_ROCKETCANNONR,20,194) break;
case(58): draw_text_ext(xtext,ytext,CNT_GUN,20,194) break;
case(59): draw_text_ext(xtext,ytext,CNT_ICEBLOCK,20,194) break;
case(60): draw_text_ext(xtext,ytext,CNT_AMMO,20,194) break;
case(61): draw_text_ext(xtext,ytext,CNT_INFINITEAMMO,20,194) break;
case(62): draw_text_ext(xtext,ytext,CNT_DEATHBLOCK,20,194) break;
case(63): draw_text_ext(xtext,ytext,CNT_BOX,20,194) break;
case(64): draw_text_ext(xtext,ytext,CNT_ULTRALOWGLIMITER,20,194) break;
case(65): draw_text_ext(xtext,ytext,CNT_LOWGLIMITER,20,194) break;
case(66): draw_text_ext(xtext,ytext,CNT_NORMALGLIMITER,20,194) break;
case(67): draw_text_ext(xtext,ytext,CNT_HIGHGLIMITER,20,194) break;
case(68): draw_text_ext(xtext,ytext,CNT_SLOWSLIMITER,20,194) break;
case(69): draw_text_ext(xtext,ytext,CNT_NORMALSLIMITER,20,194) break;
case(70): draw_text_ext(xtext,ytext,CNT_FASTSLIMITER,20,194) break;
case(71): draw_text_ext(xtext,ytext,CNT_LIGHTNINGSLIMITER,20,194) break;
case(72): draw_text_ext(xtext,ytext,CNT_LOCKEDBLOCK,20,194) break;
case(73): draw_text_ext(xtext,ytext,CNT_UNLOCKEDBLOCK,20,194) break;
case(74): draw_text_ext(xtext,ytext,CNT_OXYGENREPLENISHER,20,194) break;
case(75): draw_text_ext(xtext,ytext,CNT_VSPIKE,20,194) break;
case(76): draw_text_ext(xtext,ytext,CNT_VSPIKERIGHT,20,194) break;
case(77): draw_text_ext(xtext,ytext,CNT_VSPIKELEFT,20,194) break;
case(78): draw_text_ext(xtext,ytext,CNT_VSPIKETOP,20,194) break;
case(79): draw_text_ext(xtext,ytext,CNT_HSPIKE,20,194) break;
case(80): draw_text_ext(xtext,ytext,CNT_HSPIKERIGHT,20,194) break;
case(81): draw_text_ext(xtext,ytext,CNT_HSPIKELEFT,20,194) break;
case(82): draw_text_ext(xtext,ytext,CNT_HSPIKETOP,20,194) break;
case(83): draw_text_ext(xtext,ytext,CNT_DOUBLEJUMP,20,194) break;
case(84): draw_text_ext(xtext,ytext,CNT_INVREDBLOCK,20,194) break;
case(85): draw_text_ext(xtext,ytext,CNT_INVYELLOWBLOCK,20,194) break;
case(86): draw_text_ext(xtext,ytext,CNT_INVGREENBLOCK,20,194) break;
case(87): draw_text_ext(xtext,ytext,CNT_INVBLUEBLOCK,20,194) break;
case(88): draw_text_ext(xtext,ytext,CNT_INVWHITEBLOCK,20,194) break;
case(89): draw_text_ext(xtext,ytext,CNT_BRKREDBLOCK,20,194) break;
case(90): draw_text_ext(xtext,ytext,CNT_BRKYELLOWBLOCK,20,194) break;
case(91): draw_text_ext(xtext,ytext,CNT_BRKGREENBLOCK,20,194) break;
case(92): draw_text_ext(xtext,ytext,CNT_BRKBLUEBLOCK,20,194) break;
case(93): draw_text_ext(xtext,ytext,CNT_BRKWHITEBLOCK,20,194) break;
case(94): draw_text_ext(xtext,ytext,CNT_ZEROG,20,194) break;
case(95): draw_text_ext(xtext,ytext,CNT_ZEROGLIMITER,20,194) break;
case(96): draw_text_ext(xtext,ytext,CNT_REDBLOCKSLOPE,20,194) break;
case(97): draw_text_ext(xtext,ytext,CNT_YELLOWBLOCKSLOPE,20,194) break;
case(98): draw_text_ext(xtext,ytext,CNT_GREENBLOCKSLOPE,20,194) break;
case(99): draw_text_ext(xtext,ytext,CNT_BLUEBLOCKSLOPE,20,194) break;
case(100): draw_text_ext(xtext,ytext,CNT_WHITEBLOCKSLOPE,20,194) break;
}
}
if global.LEBuild = 2 {
draw_text(835,15,string(global.LES + 1) + " / 24")
switch(global.LES) {
case(0): draw_text_ext(xtext,ytext,CNT_REDBLOCK,20,194) break;
case(1): draw_text_ext(xtext,ytext,CNT_YELLOWBLOCK,20,194) break;
case(2): draw_text_ext(xtext,ytext,CNT_GREENBLOCK,20,194) break;
case(3): draw_text_ext(xtext,ytext,CNT_BLUEBLOCK,20,194) break;
case(4): draw_text_ext(xtext,ytext,CNT_WHITEBLOCK,20,194) break;
case(5): draw_text_ext(xtext,ytext,CNT_ICEBLOCK,20,194) break;
case(6): draw_text_ext(xtext,ytext,CNT_DEATHBLOCK,20,194) break;
case(7): draw_text_ext(xtext,ytext,CNT_BOX,20,194) break;
case(8): draw_text_ext(xtext,ytext,CNT_REDBLOCKSLOPE,20,194) break;
case(9): draw_text_ext(xtext,ytext,CNT_YELLOWBLOCKSLOPE,20,194) break;
case(10): draw_text_ext(xtext,ytext,CNT_GREENBLOCKSLOPE,20,194) break;
case(11): draw_text_ext(xtext,ytext,CNT_BLUEBLOCKSLOPE,20,194) break;
case(12): draw_text_ext(xtext,ytext,CNT_WHITEBLOCKSLOPE,20,194) break;
case(13): draw_text_ext(xtext,ytext,CNT_ICEBLOCKSLOPE,20,194) break;
case(14): draw_text_ext(xtext,ytext,CNT_DEATHBLOCKSLOPE,20,194) break;
case(15): draw_text_ext(xtext,ytext,CNT_BOXSLOPE,20,194) break;
case(16): draw_text_ext(xtext,ytext,CNT_SPIKE,20,194) break;
case(17): draw_text_ext(xtext,ytext,CNT_VSPIKE,20,194) break;
case(18): draw_text_ext(xtext,ytext,CNT_HSPIKE,20,194) break;
case(19): draw_text_ext(xtext,ytext,CNT_REDBLOCK,20,194) break;
case(20): draw_text_ext(xtext,ytext,CNT_YELLOWBLOCK,20,194) break;
case(21): draw_text_ext(xtext,ytext,CNT_GREENBLOCK,20,194) break;
case(22): draw_text_ext(xtext,ytext,CNT_BLUEBLOCK,20,194) break;
case(23): draw_text_ext(xtext,ytext,CNT_WHITEBLOCK,20,194) break;
}
}

if global.LEBuild = 3 {
draw_text(835,15,string(global.LES + 1) + " / 2")
switch(global.LES) {
case(0): draw_text_ext(xtext,ytext,CNT_WATER,20,194) break;
case(1): draw_text_ext(xtext,ytext,CNT_LAVA,20,194) break;
}
}