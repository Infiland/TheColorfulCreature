switch(global.customizeselect) {
default: object = global.skinnameobjectselected break;
case(2): object = global.hatnameobjectselected break;
case(3): object = global.itemnameobjectselected break;
}

/*switch(global.customizeselect) {
case(1):
switch(global.skinselected) {
default: object = o_normalskinbutton break; //Normal
case(1): object = o_kaizoskinbutton break; //Kaizo
case(2): object = o_madskinbutton break; //Mad
case(3): object = o_blindskinbutton break; //Blind
case(4): object = o_sadskinbutton break; //Sad
case(5): object = o_blockskinbutton break; //Block
case(6): object = o_hdskinbutton break; //HD
case(7): object = o_rewardedskinbutton break; //Rewarded
case(8): object = o_angryskinbutton break; //Angry
case(9): object = o_coolskinbutton break; //Cool
case(10): object = o_darkknightskinbutton break; //Dark Knight
case(11): object = o_richskinbutton break; //Rich
case(12): object = o_goldskinbutton break; //Gold
case(13): object = o_frozenskinbutton break; //Frozen
case(14): object = o_kindadeadskinbutton break; //Kinda Dead
case(15): object = o_coronaskinbutton break; //Corona
case(16): object = o_canadianskinbutton break; //Canadian
case(17): object = o_hazardousskinbutton break; //Hazardous
case(18): object = o_babyskinbutton break; //Baby
case(19): object = o_hexagonskinbutton break; //Hexagon
case(20): object = o_tuxedoskinbutton break; //Tuxedo
case(21): object = o_animatedskinbutton break; //Animated
case(22): object = o_waterskinbutton break; //Water
case(23): object = o_forseneskinbutton break; //ForsenE
case(24): object = o_redballskinbutton break; //Red Ball
case(25): object = o_bomberskinbutton break; //Bomber
case(26): object = o_hitboxskinbutton break; //Hitbox
case(27): object = o_metallicskinbutton break; //Metallic
case(28): object = o_monocleskinbutton break; //Monocle
case(29): object = o_japaneseskinbutton break; //Japanese
case(30): object = o_googlyskinbutton break; //Googly
case(31): object = o_upsidedownskinbutton break; //Upside Down
case(32): object = o_spiralskinbutton break; //Spiral
case(33): object = o_heartskinbutton break; //Heart
case(34): object = o_clockskinbutton break; //Clock
case(35): object = o_invisibleskinbutton break; //Invisible
case(36): object = o_arrowskinbutton break; //Arrow
case(37): object = o_spikeskinbutton break; //Spike
case(38): object = o_splitskinbutton break; //Split
case(39): object = o_pirateskinbutton break; //Pirate
case(40): object = o_scifiskinbutton break; //Sci-Fi
case(41): object = o_gordonskinbutton break; //Gordon
case(42): object = o_fancyskinbutton break; //Fancy
case(43): object = o_steamskinbutton break; //Steam
case(44): object = o_breakableskinbutton break; //Breakable
case(45): object = o_smileyskinbutton break; //Smiley
case(46): object = o_maidskinbutton break; //Maid
case(47): object = o_burningskinbutton break; //Burning
case(48): object = o_toiletskinbutton break; //toilet
case(49): object = o_kratosskinbutton break; //Kratos
}
break;
case(2):
sprite_index = s_skinselect
switch(global.hatselected) {
default: object = o_unequipedhatbutton break; //Unequiped
case(1): object = o_graduationhatbutton break; //Graduation
case(2): object = o_conehatbutton break; //Cone
case(3): object = o_partyhatbutton break; //Party
case(4): object = o_paperhatbutton break; //Paper
case(5): object = o_tophatbutton break; //Top Hat
case(6): object = o_yellowtophatbutton break; //Yellow Top Hat
case(7): object = o_reddiehatbutton break; //Reddie
case(8): object = o_christmashatbutton break; //Christmas
case(9): object = o_witchhatbutton break; //Witch
case(10): object = o_pumpkinhatbutton break; //Pumpkin
case(11): object = o_brownhatbutton break; //Brown
case(12): object = o_grayhatbutton break; //Gray
case(13): object = o_whitehatbutton break; //White
case(14): object = o_sunhatbutton break; //Sun Hat
case(15): object = o_redblockhatbutton break; //Red Block
case(16): object = o_yellowblockhatbutton break; //Yellow Block
case(17): object = o_greenblockhatbutton break; //Green Block
case(18): object = o_blueblockhatbutton break; //Blue Block
case(19): object = o_whiteblockhatbutton break; //White Block
case(20): object = o_spikehatbutton break; //Spike Hat
case(21): object = o_invisiblespikehatbutton break; //Invisible Spike Hat
case(22): object = o_Vspikehatbutton break; //Vertical Spike Hat
case(23): object = o_Hspikehatbutton break; //Horizontal Spike Hat
case(24): object = o_hexagonhatbutton break; //Hexagon Hat
case(25): object = o_breadhatbutton break; //Bread Hat
case(26): object = o_soldierhatbutton break; //Soldier Hat
case(27): object = o_samuraihatbutton break; //Samurai Hat
case(28): object = o_redbeaniehatbutton break; //Red Beanie Hat
case(29): object = o_yellowbeaniehatbutton break; //Yellow Beanie Hat
case(30): object = o_greenbeaniehatbutton break; //Green Beanie Hat
case(31): object = o_bluebeaniehatbutton break; //Blue Beanie Hat
case(32): object = o_whitebeaniehatbutton break; //White Beanie Hat
case(33): object = o_piratehatbutton break; //Pirate Hat
case(34): object = o_pinkbowtiehatbutton break; //Pink Bowtie Hat
case(35): object = o_kingshatbutton break; //King's Crown
case(36): object = o_hairhatbutton break; //Hair
case(37): object = o_comradehatbutton break; //Comrade
case(38): object = o_vikinghatbutton break; //Viking
case(39): object = o_cowboyhatbutton break; //Cowboy
case(40): object = o_redsushatbutton break; //Red Sus
case(41): object = o_yellowsushatbutton break; //Yellow Sus
case(42): object = o_greensushatbutton break; //Green Sus
case(43): object = o_bluesushatbutton break; //Blue Sus
case(44): object = o_whitesushatbutton break; //White Sus
case(45): object = o_flowerhatbutton break; //Flower
case(46): object = o_propellerhatbutton break; //Propeller
case(47): object = o_serbianhatbutton break; //Serbian
case(48): object = o_rathatbutton break; //Maus
case(49): object = o_germanhatbutton break; //German
case(50): object = o_frenchhatbutton break; //French
case(51): object = o_italianhatbutton break; //Italian
case(52): object = o_spanishhatbutton break; //Spanish
case(53): object = o_magyarhatbutton break; //Magyar
case(54): object = o_bosnianhatbutton break; //Bosnian
case(55): object = o_chinesehatbutton break; //Chinese
case(56): object = o_ukrainianhatbutton break; //Ukranian
case(57): object = o_macedonianhatbutton break; //Macedonian
case(58): object = o_chickenhatbutton break; //Chicken
case(59): object = o_czechhatbutton break; //Czech
case(60): object = o_russianhatbutton break; //Russian
case(61): object = o_devilhatbutton break; //Devil
case(62): object = o_turkishhatbutton break; //Turkish
case(63): object = o_palestinianhatbutton break; //Palestinian
case(64): object = o_slovenianhatbutton break; //Slovenian
case(65): object = o_japanesehatbutton break; //Japanese
case(66): object = o_romanianhatbutton break; //Romanian
}
break;
case(3):
switch(global.itemselected) {
case(0): object = o_unequipeditembutton break; //Unequiped
case(1): object = o_paintbrushitembutton break; //Paintbrush
case(2): object = o_floweritembutton break; //Flower
case(3): object = o_shielditembutton break; //Shield
}
break;
}*/
if instance_exists(object) {
	x = lerp(x,object.x,0.2  * (60 / global.maxfps))
	y = lerp(y,object.y,0.2  * (60 / global.maxfps))
}