owns_inventory = false;
if (!tcc_steam_initialised()) { instance_destroy(); exit; }
tradeup_defaults();
if (instance_number(o_getallinventoryitems) > 1) {
    tradeup_request_inventory();
    instance_destroy();
    exit;
}
owns_inventory = true;
// One owner only: results of the inventory request reach this single listener (cleared in CleanUp).
tcc_steam_inventory_set_callback_result_ready(tradeup_inventory_event);
tradeup_request_inventory();
