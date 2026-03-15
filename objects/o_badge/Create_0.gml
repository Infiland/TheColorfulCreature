/// @description Initialize badge object
badge_init();

// Define all available badges with their properties
// Game badges
badge_create("game", s_badgesmenu, 7, "The Colorful Creature", loc("HAVE_A_LEGIT_COPY_OF_THE_COLORFUL_CREATURE"), [c_lime, c_green]);

// DLC badges
badge_create("commentary", s_badgesmenu, 5, "Commentary DLC", loc("OWN_DEVELOPER_COMMENTARY_DLC_YOU_CAN_ENABLE_IT_IN_SETTINGS"), [c_yellow, c_orange]);
badge_create("ost", s_badgesmenu, 6, "OST DLC", loc("OWN_THE_SOUNDTRACK_OF_THE_GAME"), [c_blue, c_aqua]);
badge_create("super_ost", s_badgesmenu, 15, "Super OST DLC", loc("OWN_THE_SUPER_SOUNDTRACK_OF_THE_GAME_THANK_YOU_VERY_MUCH"), [c_blue, c_aqua]);
badge_create("asteroids", s_badgesmenu, 4, "Asteroids++ DLC", loc("YOU_CAN_NEVER_END_ASTEROID_GENOCIDE"), [c_gray, c_lime]);

// Donation badges
badge_create("donation_2", s_badgesmenu, 8, "Donation - $2", loc("WOW_THANKS_FOR_THE_DONATION_KEEP_DONATING_FOR_A_BETTER_BADGE"), [c_green, c_lime]);
badge_create("donation_3", s_badgesmenu, 9, "Donation - $3", loc("WOW_THANKS_FOR_THE_DONATION_KEEP_DONATING_FOR_A_BETTER_BADGE"), [c_green, c_lime]);
badge_create("donation_5", s_badgesmenu, 10, "Donation - $5", loc("WOW_THANKS_FOR_THE_DONATION_KEEP_DONATING_FOR_A_BETTER_BADGE"), [c_green, c_lime]);
badge_create("donation_7", s_badgesmenu, 11, "Donation - $7", loc("WOW_THANKS_FOR_THE_DONATION_KEEP_DONATING_FOR_A_BETTER_BADGE"), [c_green, c_lime]);
badge_create("donation_8", s_badgesmenu, 12, "Donation - $8", loc("WOW_THANKS_FOR_THE_DONATION_KEEP_DONATING_FOR_A_BETTER_BADGE"), [c_green, c_lime]);
badge_create("donation_10", s_badgesmenu, 13, "Donation - $10", loc("YOU_GAVE_A_FULL_DONATION_THANK_YOU_SO_MUCH_FOR_YOUR_SUPPORT"), [c_yellow, c_orange]);

// Achievement badges
badge_create("gold", s_badgesmenu, 0, "1st Place", loc("WIN_1ST_PLACE_IN_SEASONAL_ENDLESS_RUN_CONGRATS"), [c_olive, c_yellow]);
badge_create("silver", s_badgesmenu, 1, "2nd Place", loc("WIN_2ND_PLACE_IN_SEASONAL_ENDLESS_RUN_WELL_DONE"), [c_gray, c_ltgray]);
badge_create("bronze", s_badgesmenu, 2, "3rd Place", loc("WIN_3RD_PLACE_IN_SEASONAL_ENDLESS_RUN_NOT_BAD"), [c_blue, c_lime]);
badge_create("top10", s_badgesmenu, 3, "Top 10", loc("WIN_TOP_10_PLACE_AS_A_PARTICIPANT_OF_SEASONAL_ENDLESS_RUN"), [c_gray, c_dkgrey]);
badge_create("community_hat", s_badgesmenu, 14, "Community Hat", "Made a community hat!", [c_green, c_purple]);

// Track the badge being hovered
hovered_badge = undefined;
