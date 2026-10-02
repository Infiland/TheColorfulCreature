function scr_moddinghats(_name) {
    customhat = 0;
    hatxscale = 1;
    hatyscale = 1;
    var _asset = cosmetics_bind("hat", _name);
    if (!is_struct(_asset)) return false;
    curhat = _asset.sprite;
    if (global.customhatautoscale == 1) {
        hatxscale = 32 / _asset.width;
        hatyscale = 32 / _asset.height;
    }
    customhat = 1;
    return true;
}
