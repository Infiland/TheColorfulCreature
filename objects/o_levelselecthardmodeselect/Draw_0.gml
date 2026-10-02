var _available = levelselect_hardmode_available();
draw_set_font(fnt_mainmenu);
draw_set_color(_available ? c_white : c_gray);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _label = _available ? "Hard mode: " + (global.hardmode == 1 ? "On" : "Off") + "   [H / Y / tap]" : "Hard mode: beat the campaign once to unlock";
draw_text_transformed(257, 148, _label, 0.5, 0.5, 0);
draw_set_color(c_white);
