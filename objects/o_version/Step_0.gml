/// @description Handle version-related updates

// Check for changes in badge-related data
var badge_data_changed = false;

// Handle Steam player count updates
if (busy) {
    var result = steam_get_number_of_current_players();
    if (result != 0) {
        busy = false; // no longer busy
        if (result < 0) {
            // There was an error
            success = false;
        } else {
            // We got a result!
            success = true;
            players = result;
            global.playercount = players;
        }
    }
}

// Handle other periodic updates here

// If badge data changed, update badge statuses
if (badge_data_changed) {
    event_user(0);
}

// Seasonal rankings are now loaded once in Create_0 from seasonal_rankings.json