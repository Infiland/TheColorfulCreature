nav_path = [];
// Destroy also runs during resets, editor teardown and room changes. Only an
// explicit defeat may create corpses, sound or ammunition.
if (!variable_instance_exists(id, "troop_defeated") || !troop_defeated) exit;
if (variable_global_exists("level_cleanup_active") && global.level_cleanup_active) exit;
if (global.berserk != 0) exit;
if (room == r_leveleditor && global.LEMode == 1) exit;
instance_create(x, y, o_enemydead);
if (instance_exists(o_player)) audio_play_sound(snd_troopdead, 1, 0);
if (hasammo == 1) {
    var _ammo = instance_create(x, y, o_ammo);
    _ammo.containsammo = 12;
}
