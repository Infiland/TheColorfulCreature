if gpu_get_texfilter()
    {
    gpu_set_texfilter(false);
	global.texturefilter = 0
    }
else
    {
    gpu_set_texfilter(true);
	global.texturefilter = 1
    }