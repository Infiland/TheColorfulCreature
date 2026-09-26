if (!tcc_steam_initialised()) { instance_destroy(); exit; }
handle = tcc_steam_inventory_get_all_items();
