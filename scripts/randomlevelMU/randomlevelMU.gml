function randomlevelMU() {
	switch(global.MinigameMU) {
	case(1): var randomroom = choose(r_MUSurvival,r_MUSurvival2,r_MUSurvival3,r_MUSurvival4,r_MUSurvival5,r_MUSurvival6,r_MUSurvival7,r_MUSurvival8,r_MUSurvival9,r_MUSurvival10,r_MUSurvival11,r_MUSurvival12,r_MUSurvival13,r_MUSurvival14,r_MUSurvival15,r_MUSurvival16,r_MUSurvival17,r_MUSurvival18,r_MUSurvival19,r_MUSurvival20,r_MUSurvival21,r_MUSurvival22,r_MUSurvival23,r_MUSurvival24,r_MUSurvival25) break;
	case(2): var randomroom = choose(r_MUrace,r_MUrace2,r_MUrace3,r_MUrace4,r_MUrace5,r_MUrace6,r_MUrace7,r_MUrace8,r_MUrace9,r_MUrace10,r_MUrace11,r_MUrace12,r_MUrace13,r_MUrace14,r_MUrace15,r_MUrace16,r_MUrace17,r_MUrace18,r_MUrace19,r_MUrace20) break;
	}
	room_goto(randomroom)
}