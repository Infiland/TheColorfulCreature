if (!timing_instance_step()) exit;
// Only the editor uses an in-place retry. Other contexts reload the entire room.
if (room != r_leveleditor) exit;
if (global.LEMode == 2) {
    image_alpha = 0;
    if (!instance_exists(o_player) && !instance_exists(o_playerdeadLE) && !instance_exists(o_playerdead)) {
        leveleditorrespawncooldown -= 1;
        if (leveleditorrespawncooldown <= 0) {
            leveleditorrespawncooldown = 3;
            global.color = global.defaultcolorLE;
            instance_create(x, y, o_player);
        }
    }
} else {
    image_alpha = 1;
    with (o_player) instance_destroy();
}
