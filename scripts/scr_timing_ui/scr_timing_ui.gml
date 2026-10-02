/// UI input and interactive positions advance at 60 Hz, independently of Draw.
#macro TCC_UI_PUBLISH_READY 0
#macro TCC_UI_PUBLISH_UNVERIFIED 1
#macro TCC_UI_PUBLISH_CHEATS 2
#macro TCC_UI_PUBLISH_NO_STEAM 3
#macro TCC_UI_PUBLISH_LOGGED_OUT 4
#macro TCC_UI_PUBLISH_NO_NAME 5
#macro TCC_UI_PUBLISH_DIAMOND_TIME 6
#macro TCC_UI_PUBLISH_MISSING_ACTORS 7

function timing_ui_register_target(_kind) {
    if (!variable_global_exists("timing_ui_targets")) global.timing_ui_targets = [];
    timing_ui_kind = _kind;
    if (variable_instance_exists(id, "timing_ui_registered") && timing_ui_registered) return;
    timing_ui_registered = true;
    // A restart can retain globals; an instance ID already in the live cache
    // must not be added twice when its new instance registers.
    var _targets = global.timing_ui_targets;
    for (var _i = 0; _i < array_length(_targets); ++_i) {
        if (_targets[_i] == id) return;
    }
    array_push(global.timing_ui_targets, id);
}

// Both tick-time control creation and the actual Publish click use this fresh
// check. No save, upload, or scene transition is performed by these helpers.
function timing_ui_publish_status() {
    var _actors = instance_exists(o_playerspawner) && instance_exists(o_door);
    if (global.LEVerified != 1) return _actors ? TCC_UI_PUBLISH_UNVERIFIED : TCC_UI_PUBLISH_MISSING_ACTORS;
    if (global.cheats != 0) return TCC_UI_PUBLISH_CHEATS;
    if (global.steam_api != true) return TCC_UI_PUBLISH_NO_STEAM;
    if (!tcc_steam_is_user_logged_on()) return TCC_UI_PUBLISH_LOGGED_OUT;
    if (global.levelname == "") return TCC_UI_PUBLISH_NO_NAME;
    if (!(global.LEDiamondMedalTime >= global.LESavedWinTime)) return TCC_UI_PUBLISH_DIAMOND_TIME;
    if (!_actors) return TCC_UI_PUBLISH_MISSING_ACTORS;
    return TCC_UI_PUBLISH_READY;
}

function timing_ui_publish_eligible() {
    return timing_ui_publish_status() == TCC_UI_PUBLISH_READY;
}

function timing_ui_language_text(_language) {
    switch (_language) {
        case -1: return "Custom";
        case 1: return "German";
        case 2: return "French";
        case 3: return "Italian";
        case 4: return "Spanish";
        case 5: return "Hungarian";
        case 6: return "Turkish";
        case 7: return "Cro/Bos";
        case 8: return "Portuguese";
        case 9: return "Czech";
        case 10: return "Chinese";
        case 11: return "Slovenian";
        case 12: return "Ukrainian";
        case 13: return "Japanese";
        case 14: return "Romanian";
        case 15: return "Macedonian";
        case 16: return "Serbian(L)";
        case 17: return "Serbian(Ć)";
        default: return "English";
    }
}

// Hit testing uses the current GUI pointer and tick-time scroll/context. The
// caller bounds _count by the actual active array before any item is accessed.
function timing_ui_browser_tile_at(_mx, _my, _left, _top, _bottom, _columns,
    _width, _height, _gap, _scroll, _count) {
    if (_columns <= 0 || _count <= 0 || _my < _top || _my > _bottom) return -1;
    var _hit = -1;
    for (var _i = 0; _i < _count; ++_i) {
        var _x = _left + (_i mod _columns) * (_width + _gap);
        var _y = _top + floor(_i / _columns) * (_height + _gap) - _scroll;
        if (_y + _height < _top || _y > _bottom) continue;
        if (_mx >= _x && _mx <= _x + _width
            && _my >= max(_top, _y) && _my <= min(_bottom, _y + _height)) _hit = _i;
    }
    return _hit;
}

function timing_ui_ad_link(_game) {
    switch (_game) {
        case 2: return "https://infiland.itch.io/monophobia-echoes";
        case 3: return "https://play.google.com/store/apps/details?id=com.infiland.brikbrik";
        default: return "https://store.steampowered.com/app/2407300/Asteroids/";
    }
}

// Only these existing declared controls need a logical position update.
// Registration does not read or change fields that their caller sets later.
function timing_ui_register_declared_button() {
    switch (object_index) {
        case o_publishlevelbuttonLE:
        case o_readworkshoprulesLE:
        case o_settimertodiamondtimeLE: timing_ui_register_target("editor-modal"); break;
        case o_CERToggleLevels: timing_ui_register_target("cer-levels"); break;
        case o_CERToggleMusic: timing_ui_register_target("cer-music"); break;
    }
}

function timing_ui_editor_modal_layout() {
    var _camx = camera_get_view_x(view_camera[0]);
    var _camy = camera_get_view_y(view_camera[0]);
    switch (object_index) {
        case o_publishlevelbuttonLE: x = _camx + 400; y = _camy + 460; break;
        case o_readworkshoprulesLE: x = _camx + 400; y = _camy + 340; break;
        case o_settimertodiamondtimeLE: x = _camx + 398; y = _camy + 570; break;
    }
}

function timing_ui_editor_toolbar_update() {
    var _camx = camera_get_view_x(view_camera[0]);
    var _camy = camera_get_view_y(view_camera[0]);
    var _page_x = -1;
    var _clipped_alpha = 0;
    // Old Draw displayed alpha before updating it. Preserve that presentation
    // while all persistent layout/tween state now advances on logical ticks.
    ui_draw_alpha = alpha;
    switch (object_index) {
        case o_LEBackground:
            x = _camx + 149; y = _camy + 110;
            alpha = global.LEBuild == 2 ? 1 : 0.5;
            if (global.LEMode == 2) alpha = 0;
            break;
        case o_LEBuild:
            x = _camx + 96; y = _camy + 110;
            if (global.LEMode == 2) ui_draw_alpha = 0;
            alpha = global.LEBuild == 1 ? 1 : 0.5;
            break;
        case o_LEbuttonpage:
            x = _camx + (isleft == 0 ? 533 : 152); y = _camy + 35;
            break;
        case o_LELiquid:
            x = _camx + 202; y = _camy + 110;
            ui_arrow_yscale = arrowyscale;
            if (instance_exists(o_waterleveleditorline)) {
                image_index = 1;
            } else {
                image_index = 0;
                if (global.LEBuild == 3 && global.LEMode == 1) {
                    if (arrowyscale > 1) change = 0;
                    if (arrowyscale < 0.9) change = 1;
                    arrowyscale = lerp(arrowyscale, change == 0 ? 0.89 : 1.01, 0.1);
                }
            }
            alpha = global.LEBuild == 3 ? 1 : 0.5;
            if (global.LEMode == 2) alpha = 0;
            break;
        case o_LEMode:
            x = _camx + 603; y = _camy + 34;
            alpha = global.writingmode == 1 ? 0.5 : 1;
            break;
        case o_LEPublish:
            x = _camx + 424; y = _camy + 9;
            alpha = global.LEMode == 1 ? 1 : 0.5;
            break;
        case o_LEThumbnail:
            x = _camx + 371; y = _camy + 9;
            alpha = global.LEMode == 1 ? 1 : 0.5;
            break;
        case o_LEDiamondMedal: _page_x = 265; break;
        case o_LEFog: _page_x = 265; break;
        case o_LEHelp: _page_x = 371; _clipped_alpha = 0.5; break;
        case o_LEItemMenu: _page_x = 318; _clipped_alpha = 0.5; break;
        case o_LELevelExpand: _page_x = 371; break;
        case o_LELoad: _page_x = 212; break;
        case o_LEMusic: _page_x = 318; break;
        case o_LEName: _page_x = 477; break;
        case o_LESave: _page_x = 159; break;
        case o_LESceneryChange: _page_x = 159; break;
        case o_LESettings: _page_x = 265; _clipped_alpha = 0.5; break;
        case o_LEStarBackground: _page_x = 212; break;
        case o_LEText: _page_x = 424; break;
    }
    if (_page_x >= 0) {
        // Pose is calculated from the old tween value, as in the 60 FPS Draw.
        x = _camx + _page_x;
        y = _camy + 9 - notselected * 64;
        notselected = lerp(notselected, page == global.LEbuttonpage ? 0 : 1, 0.2);
        alpha = y < _camy - 51 ? _clipped_alpha : (global.LEMode == 1 ? 1 : 0.5);
    }
}

function timing_ui_editor_preview_update() {
    // Run after selection Step even when a modal made that Step exit early.
    // The helper's mask/speed carryover is deliberately unchanged.
    scr_leveleditorsprites(global.LES);
    x = camera_get_view_x(view_camera[0]) + 950;
    y = camera_get_view_y(view_camera[0]) + 17;
    image_blend = c_white;
}

// Derive a render-time weight only for the real-FPS readout, whose measured
// width is fresh in Draw. The existing central draw clock is clamped to 0.1s.
function timing_ui_draw_lerp_weight(_old60weight) {
    if (!variable_global_exists("tcc_timing")) return _old60weight;
    var _seconds = global.tcc_timing.draw_seconds;
    if (_seconds == 1 / TCC_SIM_HZ) return _old60weight;
    return 1 - power(1 - _old60weight, _seconds * TCC_SIM_HZ);
}

function timing_ui_header_update() {
    timer -= 1;
    if (timer < 0) {
        textchange += 1;
        if (textchange > 3) textchange = 0;
        timer = 150;
    }
    switch (textchange) {
        case 0: changex = lerp(changex, 1, textspeed); changey = lerp(changey, -1, textspeed); break;
        case 1: changex = lerp(changex, -1, textspeed); changey = lerp(changey, -1, textspeed); break;
        case 2: changex = lerp(changex, -1, textspeed); changey = lerp(changey, 1, textspeed); break;
        case 3: changex = lerp(changex, 1, textspeed); changey = lerp(changey, 1, textspeed); break;
    }
}

function timing_ui_result_update(_kind) {
    timing_ui_header_update();
    if (timer2 > 0) {
        timer2 -= 1;
    } else {
        nexttext += 1;
        if (_kind == "challenge-result" || _kind == "end-result") {
            if (nexttext == 3 && global.deaths == 0) audio_play_sound(snd_newhighscore, 0, 0);
            if (nexttext == 4 && (_kind == "end-result" || showhighscore == 1))
                audio_play_sound(snd_newhighscore, 0, 0);
        } else if (nexttext == 4) {
            switch (global.endlessrunmode) {
                case 1:
                    if (global.newendlesslevelhighscore < global.endlesslevel) audio_play_sound(snd_newhighscore, 0, 0);
                    break;
                case 2:
                    if (global.endlesslevelhighscore < global.endlesslevel) audio_play_sound(snd_newhighscore, 0, 0);
                    break;
            }
        }
        timer2 = 100;
    }
    if (nexttext == 1) deaths = 0;
    if (nexttext > 0) x1 = lerp(x1, 0, 0.05);
    if (nexttext > 1) {
        x2 = lerp(x2, 0, 0.05);
        deaths = lerp(deaths, global.deaths, 0.04);
    }
    if (nexttext > 2) {
        if (_kind == "gameover-result" && global.hardmode != 0) {
            // This direct jump never emitted the at-four transition sound.
            nexttext = 4;
        } else {
            x3 = lerp(x3, 0, 0.05);
            if (_kind == "daily-result" || _kind == "gameover-result")
                levels = lerp(levels, global.endlesslevel, 0.04);
        }
    }
    if (nexttext > 3 && (_kind == "end-result" || _kind == "gameover-result"
        || (_kind == "challenge-result" && showhighscore == 1))) {
        x4 = lerp(x4, 0, 0.05);
        // Independent tests preserve the same-tick upper turning point.
        if (colorchange == 0) {
            colorthingy = lerp(colorthingy, 100, 0.03);
            if (colorthingy > 99) colorchange = 1;
        }
        if (colorchange == 1) {
            colorthingy = lerp(colorthingy, 20, 0.03);
            if (colorthingy < 21) colorchange = 0;
        }
    }
}

function timing_ui_arrow_update() {
    ui_arrow_yscale = arrowyscale;
    if (arrowyscale > 1) change = 0;
    if (arrowyscale < 0.9) change = 1;
    arrowyscale = lerp(arrowyscale, change == 0 ? 0.89 : 1.01, 0.1);
}

function timing_ui_mu_carousel_update(_kind) {
    switch (_kind) {
        case "item": spritedistance = -global.multiplayerplayeritem[global.multiplayerplayerconfigchoose - 1] * 120; break;
        case "hat": spritedistance = -global.multiplayerplayerhat[global.multiplayerplayerconfigchoose - 1] * 120; break;
        case "skin": spritedistance = -global.multiplayerplayerskin[global.multiplayerplayerconfigchoose - 1] * 120; break;
    }
    realspritedistance = lerp(realspritedistance, spritedistance, 0.2);
    timing_ui_arrow_update();
}

function timing_ui_credits_update() {
    if (global.pause == 1) return;
    creditsborder = lerp(creditsborder, credits, 0.5);
    // Border Draw compared against the old displayed amount before the
    // number itself advanced. Preserve that comparison, not only the fields.
    ui_credits_border_color = c_white;
    if (creditsborder > credits) ui_credits_border_color = c_red;
    if (creditsborder < credits) ui_credits_border_color = c_lime;
    credits = lerp(credits, global.creditscurrency, 0.12);
}

function timing_ui_end_step() {
    if (!timing_is_tick()) return;
    var _tick = timing_tick_id();
    if (variable_global_exists("timing_ui_last_tick") && global.timing_ui_last_tick == _tick) return;
    global.timing_ui_last_tick = _tick;

    var _ending_open = false;
    with (o_endingreq) {
        if (visible) _ending_open = true;
    }
    if (_ending_open && timing_keyboard_pressed(vk_escape)) {
        game_restart();
        return;
    }

    var _targets = variable_global_exists("timing_ui_targets") ? global.timing_ui_targets : [];
    var _live = [];
    var _challenge_open = false;
    for (var _i = 0; _i < array_length(_targets); ++_i) {
        var _target = _targets[_i];
        if (!instance_exists(_target)) continue;
        if (!variable_instance_exists(_target, "timing_ui_kind")) continue;
        array_push(_live, _target);
        if (_target.visible && _target.timing_ui_kind == "challenge") _challenge_open = true;
    }
    global.timing_ui_targets = _live;

    // Shared scroll input is consumed once, not once per visible challenge.
    if (_challenge_open) {
        var _axis = gamepad_ui_axis(gp_axisrv);
        if (abs(_axis) > 0.2) global.challengescroll += 2.5 * _axis;
        if (timing_mouse_wheel_down()) global.challengescroll += 12;
        if (timing_mouse_wheel_up()) global.challengescroll -= 12;
        if (platform_touch() && timing_mouse_down(mb_left)) {
            global.challengescroll += mouse_y > 512 ? 1 : -1;
        }
        global.challengescroll = max(0, global.challengescroll);
        var _scroll_max = variable_global_exists("challenge_scroll_max") ? global.challenge_scroll_max : 500;
        if (global.challengescroll > _scroll_max + 100) global.challengescroll = _scroll_max;
    }

    var _levels_open = false;
    with (o_showsubscribedlevels) {
        if (visible) _levels_open = true;
    }
    if (_levels_open) {
        if (timing_mouse_wheel_up()) global.customlevelsscroll -= 60;
        if (timing_mouse_wheel_down()) global.customlevelsscroll += 60;
        global.customlevelsscroll = clamp(global.customlevelsscroll, 0, global.customlevelsscrollmax);
        var _subscribed = tcc_steam_ugc_num_subscribed_items();
        with (o_showsubscribedlevels) {
            if (visible) numSub = _subscribed;
        }
    }

    var _workshop_open = false;
    with (o_showsubscribedchallenges) {
        if (visible) _workshop_open = true;
    }
    if (_workshop_open) {
        if (timing_mouse_wheel_up()) global.workshopchallenges_scroll -= 60;
        if (timing_mouse_wheel_down()) global.workshopchallenges_scroll += 60;
        global.workshopchallenges_scroll = clamp(global.workshopchallenges_scroll, 0, global.workshopchallenges_scrollmax);
        if (timing_keyboard_pressed(vk_escape)) {
            with (o_workshopchallengeitembutton) { instance_destroy(); }
            with (o_showsubscribedchallenges) {
                if (visible) instance_destroy();
            }
        }
    }

    // y is also the mouse hitbox position, so the tween must follow logical
    // ticks. Draw only reads the completed position, even at 30 or 237 FPS.
    for (var _i = 0; _i < array_length(_live); ++_i) {
        var _target = _live[_i];
        if (!instance_exists(_target) || !_target.visible) continue;
        with (_target) {
            switch (timing_ui_kind) {
                case "main-header":
                    timing_ui_header_update();
                    ui_draw_texty = texty;
                    if (room == r_achievements) texty = global.achievementsscroll > 49 ? 255 : 55;
                    break;
                case "daily-result":
                case "challenge-result":
                case "end-result":
                case "gameover-result": timing_ui_result_update(timing_ui_kind); break;
                case "hat-carousel":
                    // The legacy 60 FPS coefficient is 0.1 * (144 / 60).
                    dis = lerp(dis, selectedhat, 0.24);
                    timing_ui_arrow_update();
                    break;
                case "news-banner": banner_y = lerp(banner_y, 150, 0.15); break;
                case "credits-display": timing_ui_credits_update(); break;
                case "challenge": y = lerp(y, ystart - global.challengescroll, 0.1); break;
                case "workshop-level":
                    y = lerp(y, ystart - global.customlevelsscroll, 0.1);
                    image_blend = mPubFileId == 0 ? c_red : c_white;
                    break;
                case "workshop-challenge": y = lerp(y, ystart - global.workshopchallenges_scroll, 0.1); break;
                case "editor-toolbar": timing_ui_editor_toolbar_update(); break;
                case "editor-modal": timing_ui_editor_modal_layout(); break;
                case "editor-preview": timing_ui_editor_preview_update(); break;
                case "cer-levels": x = lerp(x, global.CESConfigure == 2 ? xstart : newx, 0.1); break;
                case "cer-music": x = lerp(x, global.CESConfigure == 3 ? xstart : newx, 0.1); break;
                case "workshop-sequence-tile":
                    if (filtered_out != 1) {
                        x = lerp(x, base_x, 0.1);
                        y = lerp(y, base_y - global.workshopchallenge_scroll, 0.1);
                    }
                    break;
                case "language":
                    var _language_x = camera_get_view_x(view_camera[0]) - 256;
                    if (global.choosesettings == 5) {
                        _language_x = camera_get_view_x(view_camera[0])
                            + (language == -1 ? 800 : 32 + floor(language / 8) * 212);
                    }
                    x = lerp(x, _language_x, 0.2);
                    text = timing_ui_language_text(language);
                    break;
            }
        }
    }

    // These tabs really deactivate/reactivate their selectors. Iterating
    // active objects resumes the saved tween even after target-cache pruning.
    with (o_playeritemselectionMU) { if (visible && !global.chooseminigameMU) timing_ui_mu_carousel_update("item"); }
    with (o_playerhatselectionMU) { if (visible && !global.chooseminigameMU) timing_ui_mu_carousel_update("hat"); }
    with (o_playerskinselectionMU) { if (visible && !global.chooseminigameMU) timing_ui_mu_carousel_update("skin"); }

    // This hook runs after custom-button dispatch. Newly created controls
    // therefore cannot consume the A edge that opened their owner modal.
    with (o_publishlevelLE) {
        if (visible) {
            ui_publish_status = timing_ui_publish_status();
            if (ui_publish_status == TCC_UI_PUBLISH_READY) {
                if (!instance_exists(o_readworkshoprulesLE)) {
                    var _rules = instance_create(400, 340, o_readworkshoprulesLE);
                    _rules.image_xscale = 45.8;
                    _rules.image_yscale = 20.2;
                    with (_rules) timing_ui_editor_modal_layout();
                }
                if (!instance_exists(o_publishlevelbuttonLE)) {
                    var _publish = instance_create(400, 460, o_publishlevelbuttonLE);
                    _publish.image_xscale = 45.8;
                    _publish.image_yscale = 20.2;
                    with (_publish) timing_ui_editor_modal_layout();
                }
            } else {
                instance_destroy(o_readworkshoprulesLE);
                instance_destroy(o_publishlevelbuttonLE);
            }
        }
    }
    with (o_diamondmedalchangingLE) {
        if (visible && global.LESavedWinTime != 0 && !instance_exists(o_settimertodiamondtimeLE)) {
            var _timer = instance_create(398, 570, o_settimertodiamondtimeLE);
            _timer.image_xscale = 45.8;
            _timer.image_yscale = 13.8;
            with (_timer) timing_ui_editor_modal_layout();
        }
    }
}
