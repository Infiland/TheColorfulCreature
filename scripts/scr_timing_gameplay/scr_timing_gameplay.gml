/// Progression formerly performed by Draw, after native collisions at 60 Hz.
/// Rendering may be skipped or repeated without advancing these systems.
function timing_gameplay_render_input() {
    var _render = timing_render_id();
    if (variable_global_exists("timing_gameplay_last_input_render") && global.timing_gameplay_last_input_render == _render) return;
    global.timing_gameplay_last_input_render = _render;
    // Capture input before simulation so render-only frames do not lose a click.
    if (!timing_mouse_pressed(mb_left)) return;
    with (o_questsmenu) {
        timing_quest_click_pending = true;
        timing_quest_click_x = mouse_x;
        timing_quest_click_y = mouse_y;
    }
}

function timing_player_skin_update(_skin) {
    if (customskin == 1 && sprite_exists(customskin_spr)) return;
    switch (_skin) {
        case 25:
            lightbomberframe += 0.1;
            if (lightbomberframe > 4) lightbomberframe = 0;
            break;
        case 32:
            spiraleyerot += walksp;
            if (spiraleyerot > 7200) spiraleyerot = 0;
            break;
        case 33:
            heartbump -= 1;
            if (distance_to_object(o_door) < heartbump) heartbump = distance_to_object(o_door) / 1.5;
            if (heartbump < 0) {
                hearteyeincrease = 1.3;
                heartbump = instance_exists(o_door) ? distance_to_object(o_door) / 1.5 : 120;
            }
            hearteyeincrease = lerp(hearteyeincrease, 1, 0.1);
            break;
    }
}

function timing_player_mu_gun_update() {
    if (!hasgun) return;
    if (timer < 30) {
        if (playermove == 1) {
            gunrotation = 0;
            xcord = lerp(xcord, -2, 0.2);
            ycord = lerp(ycord, 10, 0.2);
            timer = 0;
        }
        if (playermove == -1) {
            gunrotation = 60;
            xcord = lerp(xcord, -5, 0.2);
            ycord = lerp(ycord, 10, 0.2);
            timer = 0;
        }
    }
    timer += 1;
    gunframe = lerp(gunframe, gunrotation, 0.1);
    gunangle = lerp(gunangle, 0, 0.3);
    if (timer > 30) {
        gunrotation = 30;
        xcord = lerp(xcord, 9, 0.2);
        ycord = lerp(ycord, 5, 0.2);
    }
    if (key_interact && inwater == 1 && ammo > 0) {
        timer = 0;
        if (playermove == -1) {
            if (global.playerpar == 1) instance_create(x + 20, y - 10, o_ammoparticle);
            gunangle = -40;
        }
        if (playermove == 1) {
            if (global.playerpar == 1) instance_create(x, y - 10, o_ammoparticle);
            gunangle = 40;
        }
    }
}

function timing_quest_menu_update() {
    alphalerp = lerp(alphalerp, 0.8, 0.1);
    if (maxquests <= 0) return;
    var _seed = (global.calendarcurrentyear * global.calendarcurrentmonth) / global.calendarcurrentday;
    if (!variable_instance_exists(id, "timing_quest_seed") || timing_quest_seed != _seed) {
        timing_quest_seed = _seed;
        seed = _seed;
        // Keep the engine algorithm and daily choices; never seed in Draw.
        random_set_seed(seed);
        timing_quest_indices = array_create(3);
        // Separate statements retain the legacy order of the three RNG calls.
        timing_quest_indices[0] = irandom_range(0, maxquests - 1);
        timing_quest_indices[1] = irandom_range(0, maxquests - 1);
        timing_quest_indices[2] = irandom_range(0, maxquests - 1);
    }
    if (!variable_instance_exists(id, "timing_quest_click_pending")) return;
    if (!timing_quest_click_pending) return;
    timing_quest_click_pending = false;
    if (alphalerp <= 0.5 || timing_quest_click_x <= 150 || timing_quest_click_x >= 924) return;
    for (var _qid = 0; _qid < 3; ++_qid) {
        var _yy = 150 + 160 * _qid;
        if (timing_quest_click_y <= _yy || timing_quest_click_y >= _yy + 150) continue;
        var _quest = timing_quest_indices[_qid];
        var _needed = str[_quest][3];
        var _reward = str[_quest][4];
        if (global.QUEST[_qid] || variable_global_get(str[_quest][2]) < real(_needed)) continue;
        global.QUEST[_qid] = 1;
        global.totalquests += 1;
        audio_play_sound(snd_newhighscore, 10, 0);
        if (_reward > 500 + _needed) global.cheats = 1;
        global.creditscurrency += floor(real(_reward) * global.creditsmultiplier);
        scr_savestats();
    }
}

function timing_calendar_menu_update() {
    var _key = string(global.calendarcurrentyear) + "/" + string(global.calendarcurrentmonth)
        + "/" + string(global.calendarcurrentweek) + "/" + string(global.calendardifficulty);
    if (!variable_instance_exists(id, "timing_calendar_key") || timing_calendar_key != _key) {
        timing_calendar_key = _key;
        // Prepare the stable days before choosing the reward belonging to them.
        var _calendar_seed = global.calendarcurrentmonth + global.calendarcurrentweek * global.calendarcurrentyear;
        random_set_seed(_calendar_seed);
        choosedifficultycalendar();
        random_set_seed(global.newcalendarseed);
        timing_calendar_reward_kind = irandom_range(1, global.calendardifficulty);
        switch (timing_calendar_reward_kind) {
            case 1: global.newcalendarreward = irandom_range(1, global.totalhatsAM); break;
            case 2: global.newcalendarreward = irandom_range(1, global.totalskinsAM); break;
            case 3: global.newcalendarreward = irandom_range(1, global.totalitemsAM); break;
        }
        // Stable legacy Draw ends with this day selection and resulting RNG state.
        // Preserve that once on menu setup rather than once per rendered frame.
        random_set_seed(_calendar_seed);
        choosedifficultycalendar();
    }
    if (global.newcalendarrewarded == 1) {
        if (!achievement_earned("CALENDAR_EASY")) achievement_award("CALENDAR_EASY");
        if (global.calendardifficulty == 2 && !achievement_earned("CALENDAR_MEDIUM")) achievement_award("CALENDAR_MEDIUM");
        if (global.calendardifficulty == 3 && !achievement_earned("CALENDAR_HARD")) achievement_award("CALENDAR_HARD");
    }
}

function timing_gameplay_end_step() {
    if (!timing_is_tick()) return;
    var _tick = timing_tick_id();
    if (variable_global_exists("timing_gameplay_last_tick") && global.timing_gameplay_last_tick == _tick) return;
    global.timing_gameplay_last_tick = _tick;
    var _dialogs = [o_demoask, o_progressask, o_quitask, o_statsresetconfirm,
        o_leveleditorleaveask, o_leveleditorresetask, o_leveleditorsaveask, o_webask];
    for (var _dialog = 0; _dialog < array_length(_dialogs); ++_dialog) {
        with (_dialogs[_dialog]) confirmation_tick_update();
    }
    with (o_kingboss) {
        // Draw formerly changed the native collision mask for the next tick.
        // Keep its 60 Hz post-collision order even when rendering is skipped.
        if (visible) image_yscale = lerp(image_yscale, timerjump < 20 ? 0.8 : 1, 0.2);
    }
    with (o_newcalendarbutton) {
        if (visible && os_is_network_connected()) {
            if (global.calendarcurrentweek < 5) {
                if (global.gotcalendartime == 1) { locked = 0; text = "Calendar"; }
            } else { lockedtext = "Wait a few days"; locksprite = 0; }
        }
    }
    with (o_player) {
        if (visible) {
            timing_player_skin_update(global.skinselected);
            timing_items_update();
        }
    }
    with (o_playerMU) {
        if (visible) {
            timing_player_skin_update(multiplayerplayerskin);
            timing_player_mu_gun_update();
            timing_items_update();
        }
    }
    with (o_skinselection) {
        if (visible) timing_items_update();
    }
    with (o_hatmerchant) {
        if (visible) {
            // This also normalizes bindings/creates mobile controls: do it once
            // after simulation, not during every rendered merchant frame.
            scr_playercontrolsconfig();
            if (interacted != 0 && !instance_exists(o_creditscounter)) {
                instance_create(x, y, o_creditscounter);
                if (global.creditscurrency >= 50) instance_create(x, y, o_hatshopmenu);
            }
        }
    }
    with (o_dailylevel) {
        if (visible) {
            if (global.dailylevelhighstreak > diff2 || global.dailylevelstreak > diff2) {
                global.cheats = 1;
                if (!variable_instance_exists(id, "timing_daily_invalid_reported")) {
                    timing_daily_invalid_reported = true;
                    platform_submit_score_ext("Current Daily Level Streak", 0, true);
                }
            }
            if (global.dailylevelhighstreak >= 10 && !achievement_earned("DAILIES")) achievement_award("DAILIES");
        }
    }
    with (o_newcalendarreward) {
        if (visible) timing_calendar_menu_update();
    }
    with (o_questsmenu) {
        if (visible) timing_quest_menu_update();
    }
    // Pause can change after a block's Step. Publish animation speed only
    // after all ordinary input callbacks, alongside the HUD's tick ownership.
    with (o_onewayupblock) image_speed = global.pause == 1 ? 0 : 1;
    with (o_onewaydownblock) image_speed = global.pause == 1 ? 0 : 1;
    with (o_onewayleftblock) image_speed = global.pause == 1 ? 0 : 1;
    with (o_onewayrightblock) image_speed = global.pause == 1 ? 0 : 1;
    with (o_timecounter) {
        image_speed = global.pause == 1 ? 0 : 0.4;
        if (!instance_exists(o_settingspausemenu)) {
            if (room != r_tale && global.hardmodedifficulty > 5)
                dynamictimeindex = lerp(dynamictimeindex, global.timeleftHM - global.time, 0.05);
        }
    }
    with (o_ammocounter) {
        image_speed = global.pause == 1 || !instance_exists(o_gunequipped) ? 0 : 0.2;
    }
    if (!instance_exists(o_settingspausemenu) && room != r_tale) {
        if (instance_exists(o_timecounter) && o_timecounter.visible && global.hardmodedifficulty > 5 && global.time > global.timeleftHM) {
            if (instance_exists(o_player)) {
                global.gameoverplayerX = o_player.x;
                global.gameoverplayerY = o_player.y;
            }
            room_goto(r_hardmodedeathroom);
        }
        if (instance_exists(o_deathcounter) && o_deathcounter.visible
            && (room != r_leveleditor || global.LEMode == 2)
            && global.hardmode == 1 && global.endless == 0 && global.infinitelivessettings == 0
            && global.deaths > global.hardmodelives - 1) room_goto(r_hardmodedeathroom);
    }
    with (o_raceHUD) {
        if (visible && global.pause == 0) {
            if (global.playersleft <= 1) {
                timing_restarttimer_draw = restarttimer;
                restarttimer -= 1;
                if (restarttimer < 0) randomlevelMU();
            } else {
                racetimer -= 1;
                if (racetimer < 0) randomlevelMU();
            }
        }
    }
    with (o_survivalHUD) {
        if (visible && global.pause == 0 && global.playersleft <= 1) {
            timing_restarttimer_draw = restarttimer;
            restarttimer -= 1;
            if (restarttimer < 0) randomlevelMU();
        }
    }
    if (instance_exists(o_networkmanager) && o_networkmanager.visible) {
        if (global.net_connect_state == 1 || global.net_connect_state == 2) global.net_connect_timer += 1;
        if (global.net_connect_state == 3 || global.net_connect_state == 4) {
            global.net_connect_flash -= 1;
            if (global.net_connect_flash <= 0) global.net_connect_state = 0;
        }
    }
}

// Called only by o_leveleditormenusetup Step, never by the end-tick loop.
function timing_editor_menu_update() {
    if (!timing_is_tick()) return;
    var _tick = timing_tick_id();
    if (variable_instance_exists(id, "timing_editor_last_tick") && timing_editor_last_tick == _tick) return;
    timing_editor_last_tick = _tick;
    var _my = mouse_y - camera_get_view_y(view_camera[0]);
    var _left_pressed = timing_mouse_pressed(mb_left);
    var _right_pressed = timing_mouse_pressed(mb_right);
    var _left_down = timing_mouse_down(mb_left);
    var _right_down = timing_mouse_down(mb_right);

    // These name/Finish commits already ran in Step before the old Draw input.
    if (page == 2 && _left_pressed) {
        if (_my > 180 && _my < 220) {
            if (select != 1) {
                select = 1;
                keyboard_string = global.levelname;
            } else if (level_editor_choose_name(keyboard_string)) {
                global.levelname = keyboard_string;
                keyboard_string = "";
                select = 0;
                global.LEsetup_error = "";
            } else global.LEsetup_error = global.level_last_error;
        }
        if (_my > 660 && _my < 700) {
            if (select == 1) {
                if (!level_editor_choose_name(keyboard_string)) {
                    global.LEsetup_error = global.level_last_error;
                    return;
                }
                global.levelname = keyboard_string;
                keyboard_string = "";
                select = 0;
            }
            // Successful setup destroys this menu and schedules a room restart.
            if (global.levelname != "" && LEVELEDITORSETUP(1)) return;
        }
    }
    if (timing_keyboard_pressed(vk_escape)) {
        if (page == 1) {
            if (!instance_exists(o_LESettings)) {
                audio_stop_all();
                room_goto(r_mainmenu);
            }
            instance_destroy();
            return;
        }
        if (!instance_exists(o_placeblock)) {
            page = 1;
            title = "Please choose an option:";
            instance_destroy(o_namelevelwhenloadingLE);
        } else {
            instance_destroy();
            return;
        }
    }
    switch (page) {
        case 1:
            if (!timing_mouse_released(mb_left)) break;
            if (_my > 180 && _my < 230) {
                page = 2; title = "Basic Level Info:"; xx = -500;
            } else if (_my > 230 && _my < 280) {
                page = 3; keyboard_string = ""; title = "";
                timing_create_depth(x, y, -10, o_chooseleveleditorlevel);
            } else if (_my > 280 && _my < 330) {
                page = 4; title = "Level Editor Tutorial:";
            } else if (_my > 330 && _my < 380) {
                tcc_steam_activate_overlay_browser("https://steamcommunity.com/app/1651680/workshop/");
            } else if (_my > 380 && _my < 430) {
                page = 5; title = "Advanced Narrator Colors: ";
            } else if (_my > 480 && _my < 530) {
                audio_stop_all(); room_goto(r_mainmenu); instance_destroy();
                return;
            }
            break;
        case 2:
            // Filtering is stateful, so keep it in its original input order.
            if (select == 1 && string_length(keyboard_string) < 40) badwords();
            if (_my > 220 && _my < 260 && _left_pressed) {
                if (select == 0) {
                    select = 2; keyboard_string = global.leveleditorstring;
                } else {
                    select = 0; global.leveleditorstring = keyboard_string; keyboard_string = "";
                }
            }
            if (select == 2) badwords();
            if (_my > 260 && _my < 300) {
                if (_left_pressed) {
                    global.leveleditormusic += string_digits(real(1));
                    scr_leveleditormusic();
                }
                if (_right_pressed) {
                    global.leveleditormusic -= string_digits(real(1));
                    scr_leveleditormusic();
                }
            }
            if (_my > 300 && _my < 340) {
                if (global.LELevelWidthBlocks < 100 && _left_down) global.LELevelWidthBlocks += 1;
                if (global.LELevelWidthBlocks > 32 && _right_down) global.LELevelWidthBlocks -= 1;
            }
            if (_my > 340 && _my < 380) {
                if (global.LELevelHeightBlocks < 100 && _left_down) global.LELevelHeightBlocks += 1;
                if (global.LELevelHeightBlocks > 22 && _right_down) global.LELevelHeightBlocks -= 1;
            }
            if (_my > 380 && _my < 420) {
                if (global.defaultcolorLE < 4 && _left_pressed) global.defaultcolorLE += 1;
                if (global.defaultcolorLE > 0 && _right_pressed) global.defaultcolorLE -= 1;
            }
            if (_my > 420 && _my < 460) {
                if (_left_pressed) global.LEBackground += 1;
                if (_right_pressed) global.LEBackground -= 1;
                if (global.LEBackground < 0) global.LEBackground = 2;
                if (global.LEBackground > 2) global.LEBackground = 0;
            }
            if (_my > 460 && _my < 500) {
                if (timing_keyboard_pressed(vk_control)) {
                    global.LEStarStyle += 1;
                    if (global.LEStarStyle > 2) global.LEStarStyle = 0;
                }
                if (_left_down) global.LEStarRotation += 1;
                if (_right_down) global.LEStarRotation -= 1;
                if (global.LEStarRotation < 0) global.LEStarRotation = 360;
                if (global.LEStarRotation > 360) global.LEStarRotation = 0;
            }
            if (_my > 500 && _my < 540) {
                var _mul = 10;
                if (timing_keyboard_down(vk_control)) _mul = 1;
                if (timing_keyboard_down(vk_shift)) _mul = 100;
                if (global.LEDiamondMedalTime < 1000) {
                    if (_left_down) global.LEDiamondMedalTime += 0.01 * _mul;
                } else global.LEDiamondMedalTime = 1000;
                if (global.LEDiamondMedalTime > 0) {
                    if (_right_down) global.LEDiamondMedalTime -= 0.01 * _mul;
                } else global.LEDiamondMedalTime = 0;
            }
            if (_my > 540 && _my < 580) {
                if (_left_pressed) global.LEBlockStyle += 1;
                if (_right_pressed) global.LEBlockStyle -= 1;
                if (global.LEBlockStyle < 0) global.LEBlockStyle = 1;
                if (global.LEBlockStyle > 1) global.LEBlockStyle = 0;
            }
            if (_my > 580 && _my < 620) {
                if (_left_pressed) global.LEFog += 1;
                if (_right_pressed) global.LEFog -= 1;
                if (global.LEFog < 0) global.LEFog = 1;
                if (global.LEFog > 1) global.LEFog = 0;
            }
            break;
    }
}
