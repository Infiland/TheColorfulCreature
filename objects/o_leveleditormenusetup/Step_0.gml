if (!timing_instance_step()) exit;
// The editor's existing Step owns its actions; Draw only presents the menu.
if (!timing_is_tick()) exit;
timing_editor_menu_update();
// Page actions (including the -500 reset) precede this old Draw tween.
if (instance_exists(id)) xx = lerp(xx, xxx, 0.2);
