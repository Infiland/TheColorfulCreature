draw_set_alpha(0.5)
draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_font(global.gamemodefont)
draw_set_alpha(1)
draw_set_color(c_white)
draw_set_halign(fa_center)
draw_text(512,100,loc("CHANGE_DIAMOND_TIME"))
draw_text(512,300,loc("PRESS_ENTER_WHEN_YOU_ARE_DONE")+".\n"+ loc("HOLD_LEFT_RIGHT_ARROW_KEYS_TO_CHANGE"))
draw_set_font(global.deathfont)
if global.LESavedWinTime != 0 {
draw_text(512,500,"Your Level Time: " + string(global.LESavedWinTime) + "\n(If you want this reset, just return to playmode again)")
if !instance_exists(o_settimertodiamondtimeLE) {
var button = instance_create(398,570,o_settimertodiamondtimeLE) 
with button {
image_xscale = 45.8
image_yscale = 13.8
}}
} else {
draw_text(512,500,loc("BEAT_THE_LEVEL_LEGITIMATELY_TO_KNOW_YOUR_LEVEL_TIME") + "\n"+loc("WHICH_MIGHT_HELP_YOU_WITH_YOUR_DIAMOND_MEDAL_TIME"))
}
draw_text(512,650,loc("HOLD_SHIFT_TO_BE_MORE_PRECISE"))
draw_set_halign(fa_left)
draw_sprite_ext(s_medals,3,240,220,0.07,0.07,0,c_white,1)
draw_set_color(c_yellow)
draw_text(265,215,string(global.LEDiamondMedalTime) + "s")
var bmd,smd,gmd
gmd = global.LEDiamondMedalTime * 1.1
smd = gmd * 1.2
bmd = smd * 1.3
draw_set_color(c_white)
draw_sprite_ext(s_medals,2,390,220,0.07,0.07,0,c_white,1)
draw_text(415,215,string(gmd) + "s")
draw_sprite_ext(s_medals,1,540,220,0.07,0.07,0,c_white,1)
draw_text(565,215,string(smd) + "s")
draw_sprite_ext(s_medals,0,690,220,0.07,0.07,0,c_white,1)
draw_text(715,215,string(bmd) + "s")