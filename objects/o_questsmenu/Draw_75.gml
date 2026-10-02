//Logic for the quests menu to appear
draw_set_alpha(alphalerp)
draw_set_color(c_white)
draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_set_font(global.deathfont)
draw_rectangle_color(0,0,1024,768,c_black,c_black,c_black,c_black,false)

draw_set_alpha(alphalerp*3)
draw_text_transformed(room_width/2,70,loc("QUESTS"),2,2,0)

var d = date_hour_span(date_create_datetime(global.calendarcurrentyear, global.calendarcurrentmonth, global.calendarcurrentday, 24, 0, 0), date_current_datetime())

draw_text(room_width/2,120,loc("QUESTS_RESET_IN") + ": " + string_format(d,0,1) + "h")

// Daily choices are initialized by the fixed simulation, never by rendering.
if variable_instance_exists(id,"timing_quest_indices") {
    drawquest(150,timing_quest_indices[0],0)
    drawquest(310,timing_quest_indices[1],1)
    drawquest(470,timing_quest_indices[2],2)
}
draw_set_halign(fa_left)
draw_sprite_ext(s_cannotplace,0,64,80,3,3,0,c_white,1)