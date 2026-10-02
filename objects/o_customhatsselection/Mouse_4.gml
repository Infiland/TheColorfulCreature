if (!cosmetics_enabled() || cosmetics_browser_open()) exit;
switch (global.customizeselect) {
    case 1: instance_create(x,y,o_choosecustomskins); break;
    case 2: instance_create(x,y,o_choosecustomhats); break;
    case 3: instance_create(x,y,o_choosecustomitems); break;
}
