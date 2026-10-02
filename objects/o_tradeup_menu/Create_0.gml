depth = -40000
tradeup_defaults();
if (!instance_exists(o_getallinventoryitems)) instance_create(0,0,o_getallinventoryitems);
else tradeup_request_inventory();

// Build the list of eligible trade-up entries
entries = scr_build_tradeup_list()

// Navigation state
selected = 0
dis = 0 // Smooth scroll offset
press = 0
holdcooldown = 40
arrowyscale = 1
change = 0

// Trade state
trade_in_progress = global.tradeup_state.phase != "idle";
inventory_revision = -1;
