function scr_moddingskins(_name) {
    customskin = 0;
    customskin_spr = -1;
    skinxscale = 1;
    skinyscale = 1;
    var _asset = cosmetics_bind("skin", _name);
    if (!is_struct(_asset)) return false;
    customskin_spr = _asset.sprite;
    if (global.customskinautoscale == 1) {
        skinxscale = 32 / _asset.width;
        skinyscale = 32 / _asset.height;
    }
    customskin = 1;
    return true;
}
