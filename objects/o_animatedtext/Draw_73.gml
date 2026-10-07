if (platform_mobile() && (room == r_settings || instance_exists(o_settingspausemenu))) {
    draw_set_font(global.completefont); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_set_alpha(1); draw_set_color(c_white);
    var _fit = min(1, 744 / max(1, string_width(text)));
    draw_text_transformed(camera_get_view_x(view_camera[0]) + 416, camera_get_view_y(view_camera[0]) + 68, text, _fit, _fit, 0);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    exit;
}
draw_set_font(global.completefont)
//draw_set_font(global.langfont)

draw_set_halign(fa_center)
draw_set_alpha(1)
var textlayer = 0

for(textlayer = 0;textlayer < 5;textlayer++) {
draw_set_color(make_color_rgb(100 + 32 * textlayer,100 + 32 * textlayer,100 + 32 * textlayer))
draw_text((camera_get_view_x(view_camera[0])) + 512 + ((changex*dist) * textlayer),(90 - ui_draw_texty) + ((changey*dist) * textlayer),text)
}
draw_set_halign(fa_left)
