if (!timing_instance_step()) exit;
/// @description Keep shader selection in sync with the global setting
mode = clamp(global.colorblindsettings, 0, modes);
enabled = (mode > 0);

// Touch play also draws the application surface itself, into the solved playfield.
var should_manual_draw = enabled || platform_touch_composite_wanted();

if (should_manual_draw != manual_draw_active)
{
    application_surface_draw_enable(!should_manual_draw);
    manual_draw_active = should_manual_draw;
    // GUI follows the composite in this same frame.
    platform_mobile_gui();
}
