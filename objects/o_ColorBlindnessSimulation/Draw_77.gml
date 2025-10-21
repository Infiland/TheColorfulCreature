/// @description  Enable Simulation Shader
if (!enabled)
{
    if (manual_draw_active)
    {
        application_surface_draw_enable(true);
        manual_draw_active = false;
    }
    exit;
}

var _shader = modeShad[mode];

if (_shader == undefined || _shader == -1) exit;

if (!shader_is_compiled(_shader)) exit;

shader_set(_shader);

if (manual_draw_active)
{
    var _surface = application_surface;
    if (!surface_exists(_surface))
    {
        application_surface_draw_enable(true);
        manual_draw_active = false;
        exit;
    }

    draw_surface(_surface, 0, 0);
}
