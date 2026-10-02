owns_inventory = false;
if (!tcc_steam_initialised()) { instance_destroy(); exit; }
tradeup_defaults();
if (instance_number(o_getallinventoryitems) > 1) {
    tradeup_request_inventory();
    instance_destroy();
    exit;
}
owns_inventory = true;
tradeup_request_inventory();
