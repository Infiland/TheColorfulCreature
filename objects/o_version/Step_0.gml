if (!timing_instance_step()) exit;
/// @description Handle version-related updates

// Check for changes in badge-related data
var badge_data_changed = false;

// Handle other periodic updates here

// If badge data changed, update badge statuses
if (badge_data_changed) {
    event_user(0);
}

// Seasonal rankings are now loaded once in Create_0 from seasonal_rankings.json
