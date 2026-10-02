if (!timing_instance_step()) exit;
scr_playercontrolsconfig()

if global.pickup = 0 {
shake = 0
}
if global.pickup = 1 {
shake = 1.5
}

controls_key_display(global.controlsskiplevel)

key_skip = player_skip_input(global.skiplevelholdsettings == 0);

if (global.pause == 0) {
    if (global.special >= reqcoin) {
        if (skip != "You can't skip\nthis level") {
            if (global.skiplevelholdsettings == 0) timer = -0.1;
            else if (key_skip) timer -= 1 / TCC_SIM_HZ;
            else timer = 0.7;
        }
    } else if (key_skip && !achievement_earned("UH_OH")) {
        achievement_award("UH_OH");
    }
}

if room != r_boss1 {
if room != r_boss1prepare {
if room != r_boss2 {
if room != r_boss2prepare {
if room != r_boss3 {
if room != r_boss3prepare {
if room != r_boss4prepare {
if room != r_boss4 {
if room != r_easteregg1 {
if room != r_easteregg2 {
if room != r_easteregg3 {
if room != r_truelvl100_p1 {
if room != r_truelvl100_p2 {
if room != r_boss5 {
if room != r_tale {
if global.pause = 0 {
if timer < 0 {
if key_skip {
if global.special >= reqcoin {
increase_stat("totalskips","QUESTskip",1)
if !achievement_earned("BYE_BYE_LEVEL") { achievement_award("BYE_BYE_LEVEL") }

if room = asset_get_index("r_lvl" + string(global.worldProgression)) {
global.worldProgression += 1
}

scr_savestats()
scr_resetcheckpointdata()
if global.endless = 0 { room_goto_next() }
timer = 0.5
o_narrator.l = 0
global.pickup = 0
global.special -= reqcoin
}}}}}}}}}}}}}}}}}}}
