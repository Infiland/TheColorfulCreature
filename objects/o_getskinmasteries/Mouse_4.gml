var link = "https://store.steampowered.com/itemstore/1651680/browse/?filter=all"
switch(global.customizeselect) {
default: link = "https://store.steampowered.com/itemstore/1651680/browse/?filter=Skins" break; //Skins
case(2): link = "https://store.steampowered.com/itemstore/1651680/browse/?filter=Hats" break; //Hats
case(3): link = "https://store.steampowered.com/itemstore/1651680/browse/?filter=Items" break; //Items
}

steam_activate_overlay_browser(link)