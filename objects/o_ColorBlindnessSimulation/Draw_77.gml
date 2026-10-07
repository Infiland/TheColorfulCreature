/// @description  Draw the application surface: simulation shader and touch playfield
// Pause, settings and button size can change after input capture in Begin Step.
// Apply their final mapping before the GUI is drawn in this same frame.
platform_mobile_gui();
if (!manual_draw_active) exit;

var _surface = application_surface;
if (!surface_exists(_surface))
{
    application_surface_draw_enable(true);
    manual_draw_active = false;
    exit;
}

// The touch playfield leaves bars beside and below it for the controls.
if (platform_touch_composited()) draw_clear(c_black);

var _shader = enabled ? modeShad[mode] : -1;
var _shaded = _shader != undefined && _shader != -1 && shader_is_compiled(_shader);
if (_shaded) shader_set(_shader);
var _rect = platform_app_surface_rect();
draw_surface_stretched(_surface, _rect[0], _rect[1], _rect[2], _rect[3]);
// Keep the accessibility filter on GUI colours too; Draw GUI End resets it.
