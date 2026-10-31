if (owns_inventory) {
    tradeup_inventory_cleanup();
    // Only the owner clears the shared listener; the room-placed duplicate must never touch it.
    tcc_steam_inventory_clear_callback_result_ready();
}
