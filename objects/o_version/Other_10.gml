/// @description Update badge statuses

if (instance_exists(o_badge)) {
    // Game badge
    badge_set_count("game", game1);
    
    // DLC badges
    if (dlc1_1 > 0) {
        // Super OST takes precedence over regular OST
        badge_set_count("super_ost", 1);
        badge_set_count("ost", 0);  // Hide regular OST when super is owned
    } else if (dlc1 > 0) {
        badge_set_count("ost", 1);
        badge_set_count("super_ost", 0);
    } else {
        badge_set_count("ost", 0);
        badge_set_count("super_ost", 0);
    }
    
    badge_set_count("commentary", dlc2);
    badge_set_count("asteroids", dlc3);
    
    // Donation badges - only show the highest value badge
    badge_set_count("donation_2", 0);
    badge_set_count("donation_3", 0);
    badge_set_count("donation_5", 0);
    badge_set_count("donation_7", 0);
    badge_set_count("donation_8", 0);
    badge_set_count("donation_10", 0);
    
    switch(actualmoni) {
        case 2: badge_set_count("donation_2", 1); break;
        case 3: badge_set_count("donation_3", 1); break;
        case 5: badge_set_count("donation_5", 1); break;
        case 7: badge_set_count("donation_7", 1); break;
        case 8: badge_set_count("donation_8", 1); break;
        case 10: badge_set_count("donation_10", 1); break;
    }
    
    // Achievement badges
    badge_set_count("gold", e1);
    badge_set_count("silver", e2);
    badge_set_count("bronze", e3);
    badge_set_count("top10", e4);
    badge_set_count("community_hat", hats);
} 