draw_set_alpha(0.5)
var camx = camera_get_view_x(view_camera[0])
var camy = camera_get_view_y(view_camera[0])

draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_font(global.gamemodefont)
draw_set_alpha(1)
draw_set_color(c_white)
draw_set_halign(fa_center)
draw_text(camx+512,camy+100,"Publish your level!")
draw_set_font(global.deathfont)
var _status = variable_instance_exists(id, "ui_publish_status") ? ui_publish_status : TCC_UI_PUBLISH_UNVERIFIED;
switch (_status) {
case TCC_UI_PUBLISH_READY:
    draw_set_color(c_lime)
    draw_text(camx+512,camy+200,"You can publish your level on Steam Workshop!")
    draw_set_color(c_yellow)
    draw_text(camx+512,camy+230,loc("READ_RULES_BEFORE_YOU_DO_SO_OTHERWISE_MODS_WILL_BE_VERY_ANGR"))
    break;
case TCC_UI_PUBLISH_MISSING_ACTORS:
    draw_text(camx+512,camy+200,loc("THE_LEVEL_MUST_HAVE_A_PLAYER_AND_A_DOOR_PLACED_IN_ORDER_TO_B"))
    break;
case TCC_UI_PUBLISH_DIAMOND_TIME:
    draw_text(camx+512,camy+200,loc("DIAMOND_MEDAL_TIME_MUST_BE_THE_SAME_OR_HIGHER_THAN_YOUR_LEVE"))
    break;
case TCC_UI_PUBLISH_NO_NAME:
    draw_text(camx+512,camy+200,loc("THE_LEVEL_MUST_HAVE_A_NAME_IN_ORDER_TO_BE_ABLE_TO_PUBLISH_IT"))
    break;
case TCC_UI_PUBLISH_LOGGED_OUT:
    draw_text(camx+512,camy+200,"You must be logged on Steam to publish a level!")
    break;
case TCC_UI_PUBLISH_NO_STEAM:
    draw_text(camx+512,camy+200,"Steam API must be enabled!")
    break;
case TCC_UI_PUBLISH_CHEATS:
    draw_text(camx+512,camy+200,"Cheats must be disabled. Disable them by restarting the game.")
    break;
default:
    draw_text(camx+512,camy+200,loc("COMPLETE_THE_LEVEL_IN_ORDER_TO_BE_ABLE_TO_PUBLISH_IT_ON_STEA"))
    break;
}

draw_set_color(c_white)
draw_text(camx+512,camy+600,"You can press ENTER to leave!")
draw_set_halign(fa_left)
