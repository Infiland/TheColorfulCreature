if (!timing_is_tick()) exit;
if (!instance_exists(o_player)) {
    global.color = global.defaultcolorLE;
    instance_create(x, y, o_player);
}
if (room != r_leveleditor) instance_destroy();
