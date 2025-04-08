/// @description Initialize badge object
badge_init();

// Define all available badges with their properties
// Game badges
badge_create("game", s_badgesmenu, 7, "The Colorful Creature", loc(637), [c_lime, c_green]);

// DLC badges
badge_create("commentary", s_badgesmenu, 5, "Commentary DLC", loc(638), [c_yellow, c_orange]);
badge_create("ost", s_badgesmenu, 6, "OST DLC", loc(639), [c_blue, c_aqua]);
badge_create("super_ost", s_badgesmenu, 15, "Super OST DLC", loc(694), [c_blue, c_aqua]);
badge_create("asteroids", s_badgesmenu, 4, "Asteroids++ DLC", loc(667), [c_gray, c_lime]);

// Donation badges
badge_create("donation_2", s_badgesmenu, 8, "Donation - $2", loc(668), [c_green, c_lime]);
badge_create("donation_3", s_badgesmenu, 9, "Donation - $3", loc(668), [c_green, c_lime]);
badge_create("donation_5", s_badgesmenu, 10, "Donation - $5", loc(668), [c_green, c_lime]);
badge_create("donation_7", s_badgesmenu, 11, "Donation - $7", loc(668), [c_green, c_lime]);
badge_create("donation_8", s_badgesmenu, 12, "Donation - $8", loc(668), [c_green, c_lime]);
badge_create("donation_10", s_badgesmenu, 13, "Donation - $10", loc(670), [c_yellow, c_orange]);

// Achievement badges
badge_create("gold", s_badgesmenu, 0, "1st Place", loc(640), [c_olive, c_yellow]);
badge_create("silver", s_badgesmenu, 1, "2nd Place", loc(641), [c_gray, c_ltgray]);
badge_create("bronze", s_badgesmenu, 2, "3rd Place", loc(642), [c_blue, c_lime]);
badge_create("top10", s_badgesmenu, 3, "Top 10", loc(643), [c_gray, c_dkgrey]);
badge_create("community_hat", s_badgesmenu, 14, "Community Hat", "Made a community hat!", [c_green, c_purple]);

// Track the badge being hovered
hovered_badge = undefined;
