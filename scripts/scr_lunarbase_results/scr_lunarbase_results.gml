function scr_lunarbase_time(_seconds) {
    if (_seconds >= 9999) return "--";
    return string_format(_seconds, 0, 2) + " s";
}

function scr_lunarbase_medal(_seconds, _deaths, _target = 130) {
    if (_seconds < _target * 0.9 && _deaths == 0) return 4;
    if (_seconds < _target) return 3;
    if (_seconds < _target * 1.1) return 2;
    if (_seconds < _target * 1.1 * 1.2) return 1;
    if (_seconds < _target * 1.1 * 1.2 * 1.3) return 0;
    return -1;
}

function scr_lunarbase_action_at(_x, _y) {
    if (_y < 622 || _y > 690) return -1;
    if (_x >= 192 && _x <= 482) return 0;
    if (_x >= 542 && _x <= 832) return 1;
    return -1;
}

function scr_lunarbase_return() {
    level_music_release();
    audio_stop_all();
    hidehud();
    global.pause = 0;
    global.challenges = 0;
    global.challenge_run_id = -1;
    global.challenge_custom = false;
    global.challenge_level_dir = "";
    global.challenge_level_index = 0;
    global.challenge_room_index = 0;
    global.levelselect = 0;
    global.workshop = 0;
    room_goto(r_challenges);
    audio_play_sound(m_mainmenu, 0, true);
    audio_sound_gain(m_mainmenu, global.musicvolume, 0);
}

// Called only at initial live input, death, and first live input after a retry.
// This observes authored gameplay instances without activating, moving or
// otherwise changing them. Backgrounds, particles and cosmetic RNG are omitted.
function qa_lunar_world_snapshot(_native_phase = undefined) {
    if (!qa_active() || !variable_global_exists("currentchallenge")
        || global.currentchallenge != 19 || !global.challenges) return undefined;
    // The player spawner may run after these LE wrappers in the first Step.
    // Observe the next live input once their real actors exist; never advance,
    // activate or pause the world merely to make the diagnostic look complete.
    var _pairs = [[o_HspikemovingupLE, "spawn"],
        [o_enemyplayerLE, "canspawn"], [o_redblockmoveLE, "spawn"],
        [o_yellowblockmoveLE, "spawn"], [o_spikemovingdownupLE, "spawn"],
        [o_spikemovingrightleftLE, "spawn"], [o_spikemovingupdownLE, "spawn"]];
    var _pending = 0;
    for (var _pair_index = 0; _pair_index < array_length(_pairs); ++_pair_index) {
        var _pair = _pairs[_pair_index];
        var _wrapper_type = _pair[0], _spawn_field = _pair[1];
        with (_wrapper_type) {
            if (variable_instance_exists(id, _spawn_field) && variable_instance_get(id, _spawn_field) != 0) _pending += 1;
        }
    }
    if (_pending > 0) return undefined;
    var _types = [o_Hspikemovingup, o_ammo, o_blueblock, o_blueitem, o_bluepassblock,
        o_box, o_deathblock, o_door, o_enemyplayer, o_gravity05, o_gravity15,
        o_greenblock, o_greenitem, o_greenpassblock, o_gun, o_iceblock, o_key,
        o_ladder, o_lava, o_lockeddoor, o_redblock, o_redblockmove, o_reditem,
        o_redpassblock, o_rocketlauncher, o_rocketlauncherright, o_shooter,
        o_shooterright, o_speed5, o_speed7, o_spike, o_spikeleft,
        o_spikemovingdownup, o_spikemovingrightleft, o_spikemovingupdown,
        o_spiketop, o_unlockedblock, o_whiteblock, o_whiteblockbreakable,
        o_yellowblock, o_yellowblockmove, o_yellowitem, o_yellowpassblock];
    var _fields = ["hp", "hpbreakable", "hpbreakablemax", "containsammo", "hasammo",
        "state", "move", "vsp", "hsp", "dir", "movespeed", "change", "originaly",
        "originalx", "cooldown", "originalcooldown", "spikespeed", "canmove",
        "lockmove", "timer", "originaltimer"];
    var _rows = [], _counts = {};
    with (all) {
        // Exact object type avoids counting breakables twice through their
        // white-block parent, and excludes persistent LE placement wrappers.
        var _kind = -1;
        for (var _i = 0; _i < array_length(_types); ++_i) {
            if (object_index == _types[_i]) { _kind = _i; break; }
        }
        if (_kind >= 0) {
            var _name = object_get_name(object_index);
            var _state = {};
            for (var _f = 0; _f < array_length(_fields); ++_f) {
                var _field = _fields[_f];
                // Ice's timer controls decorative tear particles only. Its
                // randomized value is unrelated to collision or level reset.
                if (object_index == o_iceblock && _field == "timer") continue;
                if (variable_instance_exists(id, _field)) {
                    variable_struct_set(_state, _field, variable_instance_get(id, _field));
                }
            }
            if (object_index == o_unlockedblock) _state.locked = sprite_index == s_lockedblock;
            var _row = {kindOrder:_kind, type:_name, startX:xstart, startY:ystart,
                x:x, y:y, scaleX:image_xscale, scaleY:image_yscale, state:_state};
            array_push(_rows, _row);
            var _count = variable_struct_exists(_counts, _name)
                ? variable_struct_get(_counts, _name) : 0;
            variable_struct_set(_counts, _name, _count + 1);
        }
    }
    // Source positions remain stable when platforms, spikes and troops move.
    // No runtime instance IDs or ID-derived navigation timers enter evidence.
    array_sort(_rows, function(_a, _b) {
        if (_a.kindOrder != _b.kindOrder) return _a.kindOrder - _b.kindOrder;
        if (_a.startX != _b.startX) return _a.startX - _b.startX;
        if (_a.startY != _b.startY) return _a.startY - _b.startY;
        if (_a.x != _b.x) return _a.x - _b.x;
        return _a.y - _b.y;
    });
    var _native_clock = undefined;
    if (variable_global_exists("tcc_timing") && is_struct(global.tcc_timing)) {
        var _q = global.tcc_qa, _t = global.tcc_timing;
        _native_clock = {schemaVersion:1, inputClock:TCC_INPUT_CLOCK, simulationHz:TCC_SIM_HZ,
            simulationFrame:_q.frame, tickId:_t.tick_id, outerId:_t.render_id,
            roomGeneration:_t.room_generation, isSimulationTick:_t.tick,
            renderCap:global.renderfps, gameplaySeconds:global.time, challengeDeaths:global.deaths,
            nativeElapsedUs:_q.started ? get_timer() - _q.start_us : undefined};
    }
    var _culling = variable_global_exists("biglevelperfsettings") ? global.biglevelperfsettings : -1;
    return {schemaVersion:2, room:room_get_name(room), fps:global.maxfps,
        frame:global.tcc_qa.frame, seed:global.tcc_qa.seed, cullingSetting:_culling,
        snapshotPhase:"complete-world-at-live-input", initializationReady:true,
        observationPhase:_native_phase, nativeClock:_native_clock,
        readyFrame:global.tcc_qa.frame, pendingStepActors:_pending,
        completeGameplayScope:_culling >= 0 && _culling <= 1,
        scope:_culling > 1 ? "active-instances-only" : "all-gameplay-instances",
        players:instance_number(o_player), localPlayers:instance_number(o_playerMU),
        deadPlayers:instance_number(o_playerdead), counts:_counts, instances:_rows,
        projectiles:{playerBullets:instance_number(o_playerbullet),
            leftBullets:instance_number(o_bulletleft), rightBullets:instance_number(o_bulletright),
            rockets:instance_number(o_rocket), rightRockets:instance_number(o_rocket2),
            rocketGroup:instance_number(o_rocketgroup)}};
}

function scr_lunarbase_selfcheck() {
    var _def = scr_challenge_get_def(19);
    if (is_undefined(_def)) throw "Lunar Base definition missing";
    if (_def.unlock_type != "world" || _def.unlock_value != 4) throw "Lunar Base unlock changed";
    if (_def.diamond_time != 130 || _def.win_room != "r_lunarbasewin") throw "Lunar Base target/results changed";
    if (array_length(_def.reward_skins) != 1 || _def.reward_skins[0] != 49) throw "Lunar Base reward changed";
    if (_def.save_key != "Lunar Base Challenge") throw "Lunar Base records moved";
    if (_def.achievement != "" || _def.leaderboard != "" || _def.leaderboard_mobile != "") throw "Lunar Base must not use a Kaizo service";
    if (array_length(_def.level_dirs) != 1 || _def.level_dirs[0] != "Lunar Base Challenge/1") throw "Lunar Base map changed";
    if (scr_lunarbase_medal(130, 0) != 2 || scr_lunarbase_medal(129.99, 1) != 3
        || scr_lunarbase_medal(116.99, 0) != 4 || scr_lunarbase_medal(116.99, 1) != 3) throw "Lunar Base medal boundaries";
    if (scr_lunarbase_action_at(337, 656) != 0 || scr_lunarbase_action_at(687, 656) != 1
        || scr_lunarbase_action_at(512, 656) != -1 || scr_lunarbase_action_at(337, 600) != -1) throw "Lunar Base action hit targets";
    return true;
}
