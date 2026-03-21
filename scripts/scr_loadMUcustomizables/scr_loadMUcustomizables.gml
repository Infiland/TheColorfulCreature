function scr_loadMUcustomizables(){

// --- SKINS (sequential order matching global.skin[] indices) ---
// Position 0 = Normal (skin[1], always unlocked)
// Position 1 = Kaizo (skin[2]), Position 2 = Mad (skin[3]), etc.
// To add a new skin: append its button sprite here
global.MU_skin_sprite = [
	s_normalskinbutton,       // skin[1]  Normal
	s_kaizoskinbutton,        // skin[2]  Kaizo
	s_madskinbutton,          // skin[3]  Mad
	s_blindskinbutton,        // skin[4]  Blind
	s_sadskinbutton,          // skin[5]  Sad
	s_blockskinbutton,        // skin[6]  Block
	s_hdskinbutton,           // skin[7]  HD
	s_rewardedskinbutton,     // skin[8]  Rewarded
	s_angryskinbutton,        // skin[9]  Angry
	s_coolskinbutton,         // skin[10] Cool
	s_darkknightskinbutton,   // skin[11] Dark Knight
	s_richskinbutton,         // skin[12] Rich
	s_goldplayerskinbutton,   // skin[13] Gold
	s_frozenskinbutton,       // skin[14] Frozen
	s_kindadeadskinbutton,    // skin[15] Kinda Dead
	s_coronaskinbutton,       // skin[16] Corona
	s_canadianskinbutton,     // skin[17] Canadian
	s_hazardousskinbutton,    // skin[18] Hazardous
	s_babyskinbutton,         // skin[19] Baby
	s_hexagonskinbutton,      // skin[20] Hexagon
	s_tuxedoskinbutton,       // skin[21] Tuxedo
	s_normalskinbutton,       // skin[22] (placeholder sprite)
	s_waterskinbutton,        // skin[23] Water
	s_forsenEskinbutton,      // skin[24] ForsenE
	s_redballskinbutton,      // skin[25] Red Ball
	s_bomberskinbutton,       // skin[26] Bomber
	s_hitboxskinbutton,       // skin[27] Hitbox
	s_metallicskinbutton,     // skin[28] Metallic
	s_monocleskinbutton,      // skin[29] Monocle
	s_japaneseskinbutton,     // skin[30] Japanese
	s_googlyskinbutton,       // skin[31] Googly
	s_upsidedownskinbutton,   // skin[32] Upside Down
	s_spiralskinbutton,       // skin[33] Spiral
	s_heartskinbutton,        // skin[34] Heart
	s_clockskinbutton,        // skin[35] Clock
	s_invisibleskinbutton,    // skin[36] Invisible
	s_arrowskinbutton,        // skin[37] Arrow
	s_spikeskinbutton,        // skin[38] Spike
	s_splitskinbutton,        // skin[39] Split
	s_pirateskinbutton,       // skin[40] Pirate
	s_scifiskinbutton,        // skin[41] Sci-Fi
	s_gordonskinbutton,       // skin[42] Gordon
	s_fancyskinbutton,        // skin[43] Fancy
	s_steamskinbutton,        // skin[44] Steam
	s_breakableskinbutton,    // skin[45] Breakable
	s_smileyskinbutton,       // skin[46] Smiley
	s_maidskinbutton,         // skin[47] Maid
]
global.MU_skin_count = array_length(global.MU_skin_sprite)

// --- HATS (sequential order matching global.hat[] indices) ---
// Position 0 = No Hat (always available)
// Position 1 = Graduation (hat[1]), Position 2 = Cone (hat[2]), etc.
// To add a new hat: append its icon sprite here
global.MU_hat_sprite = [
	s_nohaticon,              // No hat
	s_graduationhaticon,      // hat[1]
	s_conehaticon,            // hat[2]
	s_partyhaticon,           // hat[3]
	s_paperhaticon,           // hat[4]
	s_tophaticon,             // hat[5]
	s_yellowtophaticon,       // hat[6]
	s_reddiehaticon,          // hat[7]
	s_christmashaticon,       // hat[8]
	s_witchhaticon,           // hat[9]
	s_pumpkinhaticon,         // hat[10]
	s_brownhaticon,           // hat[11]
	s_grayhaticon,            // hat[12]
	s_whitehaticon,           // hat[13]
	s_sunhaticon,             // hat[14]
	s_redblockhaticon,        // hat[15]
	s_yellowblockhaticon,     // hat[16]
	s_greenblockhaticon,      // hat[17]
	s_blueblockhaticon,       // hat[18]
	s_whiteblockhaticon,      // hat[19]
	s_spikehaticon,           // hat[20]
	s_invisiblespikehaticon,  // hat[21]
	s_Vspikehaticon,          // hat[22]
	s_Hspikehaticon,          // hat[23]
	s_hexagonhaticon,         // hat[24]
	s_breadhaticon,           // hat[25]
	s_soldierhaticon,         // hat[26]
	s_samuraihaticon,         // hat[27]
	s_redbeaniehaticon,       // hat[28]
	s_yellowbeaniehaticon,    // hat[29]
	s_greenbeaniehaticon,     // hat[30]
	s_bluebeaniehaticon,      // hat[31]
	s_whitebeaniehaticon,     // hat[32]
	s_piratehaticon,          // hat[33]
	s_pinkbowtiehaticon,      // hat[34]
	s_kinghaticon,            // hat[35]
	s_hairhaticon,            // hat[36]
	s_comradehaticon,         // hat[37]
	s_vikinghaticon,          // hat[38]
	s_cowboyhaticon,          // hat[39]
	s_cowboyhaticon,          // hat[40]
	s_redsushaticon,          // hat[41]
	s_yellowsushaticon,       // hat[42]
	s_greensushaticon,        // hat[43]
	s_bluesushaticon,         // hat[44]
	s_whitesushaticon,        // hat[45]
	s_flowerhaticon,          // hat[46]
]
global.MU_hat_count = array_length(global.MU_hat_sprite)

// --- ITEMS (sequential order matching global.item[] indices) ---
// Position 0 = No Item (always available)
// To add a new item: append its button sprite here
global.MU_item_sprite = [
	s_nohaticon,              // No item
	s_paintbrushitembutton,   // item[1]
	s_floweritembutton,       // item[2]
	s_shielditembutton,       // item[3]
]
global.MU_item_count = array_length(global.MU_item_sprite)

}
