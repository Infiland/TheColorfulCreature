if global.choosesettings != 1 { exit }

var next_mode = global.colorblindsettings + 1;
if (next_mode > 4)
{
    next_mode = 0;
}

var was_grayscale = (global.isgrayscale == true);

global.colorblindsettings = next_mode;

if (next_mode == 0)
{
    if (instance_exists(o_ColorBlindnessSimulation))
    {
        with (o_ColorBlindnessSimulation)
        {
            enabled = false;
            mode = 0;
        }
    }
}
else if (!instance_exists(o_ColorBlindnessSimulation))
{
    instance_create(x, y, o_ColorBlindnessSimulation);
}
else
{
    with (o_ColorBlindnessSimulation)
    {
        enabled = true;
        mode = next_mode;
    }
}

global.isgrayscale = (next_mode == 4);

if (was_grayscale && !global.isgrayscale)
{
    if (room != r_settings)
    {
        if (global.endless == 0)
        {
            if (global.challenges == 0)
            {
                scr_saveachievements();
            }
        }
    }
}

scr_savesettings();
