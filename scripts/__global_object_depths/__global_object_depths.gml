function __global_object_depths() {
	// Initialise the global array that allows the lookup of the depth of a given object
	// GM2.0 does not have a depth on objects so on import from 1.x a global array is created
	// NOTE: MacroExpansion is used to insert the array initialisation at import time
	gml_pragma( "global", "__global_object_depths()");

	// insert the generated arrays here
	global.__objectDepths[0] = 1; // o_player
	global.__objectDepths[1] = 1; // o_playerdead
	global.__objectDepths[2] = 20; // o_door
	global.__objectDepths[3] = 0; // o_title
	global.__objectDepths[4] = 0; // o_start
	global.__objectDepths[5] = 0; // o_load
	global.__objectDepths[6] = 0; // o_version
	global.__objectDepths[7] = 0; // o_redblock
	global.__objectDepths[8] = -1; // o_redblockfake
	global.__objectDepths[9] = 0; // o_yellowblock
	global.__objectDepths[10] = 0; // o_yellowblockfake
	global.__objectDepths[11] = 0; // o_greenblock
	global.__objectDepths[12] = 0; // o_blueblock
	global.__objectDepths[13] = 1; // o_specialcoin
	global.__objectDepths[14] = 0; // o_reditem
	global.__objectDepths[15] = 0; // o_yellowitem
	global.__objectDepths[16] = 0; // o_greenitem
	global.__objectDepths[17] = 0; // o_blueitem
	global.__objectDepths[18] = 0; // o_gravity15
	global.__objectDepths[19] = 0; // o_gravity25
	global.__objectDepths[20] = 0; // o_gravity05
	global.__objectDepths[21] = 0; // o_gravity01
	global.__objectDepths[22] = 0; // o_Tutorial1
	global.__objectDepths[23] = 0; // o_Tutorial2
	global.__objectDepths[24] = 0; // o_evilhotdog
	global.__objectDepths[25] = 0; // o_ketchup
	global.__objectDepths[26] = 0; // o_explosion
	global.__objectDepths[27] = 0; // o_mayonese
	global.__objectDepths[28] = 0; // o_shooteradvantage
	global.__objectDepths[29] = 2; // o_buttonadvantage
	global.__objectDepths[30] = 0; // o_spike
	global.__objectDepths[31] = 1; // o_shooter
	global.__objectDepths[32] = 1; // o_shooterright
	global.__objectDepths[33] = 0; // o_bulletleft
	global.__objectDepths[34] = 0; // o_bulletright
	global.__objectDepths[35] = 1000; // o_star
	global.__objectDepths[36] = 0; // o_starsystem
	global.__objectDepths[37] = 0; // o_fullscreensystem
	global.__objectDepths[38] = -100; // o_time
	global.__objectDepths[39] = -100; // o_deathcounter
	global.__objectDepths[40] = -100; // o_timecounter
	global.__objectDepths[41] = -100; // o_coincounter



	global.__objectNames[0] = "o_player";
	global.__objectNames[1] = "o_playerdead";
	global.__objectNames[2] = "o_door";
	global.__objectNames[3] = "o_title";
	global.__objectNames[4] = "o_start";
	global.__objectNames[5] = "o_load";
	global.__objectNames[6] = "o_version";
	global.__objectNames[7] = "o_redblock";
	global.__objectNames[8] = "o_redblockfake";
	global.__objectNames[9] = "o_yellowblock";
	global.__objectNames[10] = "o_yellowblockfake";
	global.__objectNames[11] = "o_greenblock";
	global.__objectNames[12] = "o_blueblock";
	global.__objectNames[13] = "o_specialcoin";
	global.__objectNames[14] = "o_reditem";
	global.__objectNames[15] = "o_yellowitem";
	global.__objectNames[16] = "o_greenitem";
	global.__objectNames[17] = "o_blueitem";
	global.__objectNames[18] = "o_gravity15";
	global.__objectNames[19] = "o_gravity25";
	global.__objectNames[20] = "o_gravity05";
	global.__objectNames[21] = "o_gravity01";
	global.__objectNames[22] = "o_Tutorial1";
	global.__objectNames[23] = "o_Tutorial2";
	global.__objectNames[24] = "o_evilhotdog";
	global.__objectNames[25] = "o_ketchup";
	global.__objectNames[26] = "o_explosion";
	global.__objectNames[27] = "o_mayonese";
	global.__objectNames[28] = "o_shooteradvantage";
	global.__objectNames[29] = "o_buttonadvantage";
	global.__objectNames[30] = "o_spike";
	global.__objectNames[31] = "o_shooter";
	global.__objectNames[32] = "o_shooterright";
	global.__objectNames[33] = "o_bulletleft";
	global.__objectNames[34] = "o_bulletright";
	global.__objectNames[35] = "o_star";
	global.__objectNames[36] = "o_starsystem";
	global.__objectNames[37] = "o_fullscreensystem";
	global.__objectNames[38] = "o_time";
	global.__objectNames[39] = "o_deathcounter";
	global.__objectNames[40] = "o_timecounter";
	global.__objectNames[41] = "o_coincounter";

	global.__objectDepths[42] = -50000; // objPerspective
	global.__objectDepths[43] = 0; // objCube
	global.__objectNames[42] = "objPerspective";
	global.__objectNames[43] = "objCube";


	global.__objectDepths[3] = -50000; // objPerspective
	global.__objectDepths[4] = 0; // objCube


	global.__objectNames[3] = "objPerspective";
	global.__objectNames[4] = "objCube";


	// create another array that has the correct entries
	var len = array_length_1d(global.__objectDepths);
	global.__objectID2Depth = [];
	for( var i=0; i<len; ++i ) {
		var objID = asset_get_index( global.__objectNames[i] );
		if (objID >= 0) {
			global.__objectID2Depth[ objID ] = global.__objectDepths[i];
		} // end if
	} // end for


}
