/// @description Keep shader selection in sync with the global setting
mode = clamp(global.colorblindsettings, 0, modes);
enabled = (mode > 0);

var should_manual_draw = enabled;

if (should_manual_draw != manual_draw_active)
{
    application_surface_draw_enable(!should_manual_draw);
    manual_draw_active = should_manual_draw;
}
