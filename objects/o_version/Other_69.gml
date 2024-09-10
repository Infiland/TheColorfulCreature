if (async_load[? "event_type"] == "number_of_current_players") {
    busy = false; // no longer waiting for the request
    if (async_load[? "success"]) {
        success = true; // we do have a number
        global.playercount = async_load[? "players"];
    }
}