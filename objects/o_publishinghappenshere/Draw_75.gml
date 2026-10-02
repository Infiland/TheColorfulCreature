draw_set_alpha(0.7);
draw_rectangle_color(0, 0, 1024, 768, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_set_font(global.gamemodefont);
draw_set_halign(fa_center);
draw_set_color(c_white);
switch (result) {
    case 1:
        draw_text(512, 250, updated ? loc("LEVEL_UPDATED") : loc("LEVEL_PUBLISHED"));
        draw_text(512, 310, "Publish ID: " + string(global.Publish_ID));
        break;
    case 2: draw_text(512, 250, "Accept the Steam Workshop legal agreement, then try again."); break;
    case 3: draw_text(512, 250, loc("YOU_NEED_TO_BE_CONNECTED_ON_STEAM")); break;
    case 4: draw_text(512, 250, loc("UPLOADING_FAILED")); break;
    case 5: draw_text(512, 250, loc("THUMBNAIL_MISSING")); break;
    default: draw_text(512, 250, "Uploading..."); break;
}
if (state == "finished") draw_text(512, 410, "Enter / Escape: return to editor");
draw_set_halign(fa_left);
