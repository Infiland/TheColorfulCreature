/// @description  Enable Simulation Shader
//{
    if (enabled)
    {
        if (shader_is_compiled(modeShad[mode])) 
        {
            shader_set(modeShad[mode]);
        }
    }
//}

