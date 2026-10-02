image_speed = 0;
mask_index = s_leveleditorhitbox;
leveleditorrespawncooldown = 2;
image_alpha = 1;
var _sprites = [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite];
sprite_index = _sprites[clamp(global.defaultcolorLE, 0, 4)];
// Packaged levels spawn once. The death object restarts the whole room so keys,
// breakable blocks, enemies and pickups reset together, preserving run counters.
if (room != r_leveleditor) {
    image_alpha = 0;
    alarm[0] = 1;
}
