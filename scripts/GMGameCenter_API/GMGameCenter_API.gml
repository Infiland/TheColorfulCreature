// ##### extgen :: Auto-generated file do not edit!! #####

// #####################################################################
// # Macros
// #####################################################################

// #####################################################################
// # Enums
// #####################################################################

enum GameCenterLeaderboardTimeScope
{
    Today = 0,
    Week = 1,
    AllTime = 2
}

enum GameCenterLeaderboardPlayerScope
{
    Global = 0,
    FriendsOnly = 1
}

enum GameCenterAccessPointLocation
{
    TopLeading = 0,
    TopTrailing = 1,
    BottomLeading = 2,
    BottomTrailing = 3
}

enum GameCenterAccessPointCoordinate
{
    X = 0,
    Y = 1,
    Width = 2,
    Height = 3
}

enum GameCenterViewState
{
    Default = -1,
    Leaderboards = 0,
    Achievements = 1,
    Challenges = 2,
    LocalPlayerProfile = 3,
    Dashboard = 4,
    LocalPlayerFriendsList = 5
}

// #####################################################################
// # Constructors
// #####################################################################

/**
 * @returns {Struct.GameCenterPlayer}
 */
function GameCenterPlayer() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 2277098723;

    self.alias = undefined;
    self.display_name = undefined;
    self.player_id = undefined;
    self.game_player_id = undefined;
    self.team_player_id = undefined;

}

/**
 * @returns {Struct.GameCenterSavedGame}
 */
function GameCenterSavedGame() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 2021007683;

    self.device_name = undefined;
    self.modification_date = undefined;
    self.name = undefined;

}

/**
 * @returns {Struct.GameCenterSavedGamesDeleteResult}
 */
function GameCenterSavedGamesDeleteResult() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 1756637986;

    self.success = undefined;
    self.error_code = undefined;
    self.error_message = undefined;
    self.name = undefined;

}

/**
 * @returns {Struct.GameCenterSavedGamesDataResult}
 */
function GameCenterSavedGamesDataResult() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 529441505;

    self.success = undefined;
    self.error_code = undefined;
    self.error_message = undefined;
    self.name = undefined;
    self.handle_id = undefined;
    self.required_size = undefined;

}

/**
 * @returns {Struct.GameCenterLeaderboardSubmitResult}
 */
function GameCenterLeaderboardSubmitResult() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 3075034796;

    self.success = undefined;
    self.error_code = undefined;
    self.error_message = undefined;
    self.leaderboard_id = undefined;
    self.score = undefined;
    self.context = undefined;

}

/**
 * @returns {Struct.GameCenterAchievementReportResult}
 */
function GameCenterAchievementReportResult() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 1411479750;

    self.success = undefined;
    self.error_code = undefined;
    self.error_message = undefined;
    self.identifier = undefined;
    self.percent_complete = undefined;

}

/**
 * @returns {Struct.GameCenterAchievementResetResult}
 */
function GameCenterAchievementResetResult() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 1729814725;

    self.success = undefined;
    self.error_code = undefined;
    self.error_message = undefined;

}

/**
 * @returns {Struct.GameCenterLeaderboardEntry}
 */
function GameCenterLeaderboardEntry() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 2759294555;

    self.context = undefined;
    self.date = undefined;
    self.rank = undefined;
    self.score = undefined;
    self.formatted_score = undefined;
    self.player = undefined;

}

/**
 * @returns {Struct.GameCenterAchievement}
 */
function GameCenterAchievement() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 1240377713;

    self.identifier = undefined;
    self.percent_complete = undefined;
    self.is_completed = undefined;
    self.shows_completion_banner = undefined;
    self.player = undefined;
    self.last_reported_date = undefined;

}

/**
 * @returns {Struct.GameCenterAuthResult}
 */
function GameCenterAuthResult() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 4154585625;

    self.success = undefined;
    self.error_code = undefined;
    self.error_message = undefined;
    self.authentication_state = undefined;
    self.authenticated = undefined;
    self.player = undefined;

}

/**
 * @returns {Struct.GameCenterSavedGamesFetchResult}
 */
function GameCenterSavedGamesFetchResult() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 1869400769;

    self.success = undefined;
    self.error_code = undefined;
    self.error_message = undefined;
    self.slots = undefined;

}

/**
 * @returns {Struct.GameCenterSavedGamesSaveResult}
 */
function GameCenterSavedGamesSaveResult() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 4292535228;

    self.success = undefined;
    self.error_code = undefined;
    self.error_message = undefined;
    self.name = undefined;
    self.slot = undefined;

}

/**
 * @returns {Struct.GameCenterSavedGamesResolveResult}
 */
function GameCenterSavedGamesResolveResult() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 1799530597;

    self.success = undefined;
    self.error_code = undefined;
    self.error_message = undefined;
    self.conflict_id = undefined;
    self.slots = undefined;

}

/**
 * @returns {Struct.GameCenterSavedGamesEvent}
 */
function GameCenterSavedGamesEvent() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 2444331672;

    self.type = undefined;
    self.conflict_id = undefined;
    self.player = undefined;
    self.slot = undefined;
    self.slots = undefined;

}

/**
 * @returns {Struct.GameCenterLeaderboardLoadResult}
 */
function GameCenterLeaderboardLoadResult() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 4040485904;

    self.success = undefined;
    self.error_code = undefined;
    self.error_message = undefined;
    self.leaderboard_id = undefined;
    self.time_scope = undefined;
    self.range_start = undefined;
    self.range_count = undefined;
    self.player_scope = undefined;
    self.leaderboard_title = undefined;
    self.leaderboard_group = undefined;
    self.leaderboard_type = undefined;
    self.leaderboard_start_date = undefined;
    self.leaderboard_next_start_date = undefined;
    self.leaderboard_duration = undefined;
    self.total_players_count = undefined;
    self.local_entry = undefined;
    self.entries = undefined;

}

/**
 * @returns {Struct.GameCenterAchievementsResult}
 */
function GameCenterAchievementsResult() constructor
{
    /**
     * Internally generated hash for quick validation
     * @ignore
     */
    static __uid = 1074684623;

    self.success = undefined;
    self.error_code = undefined;
    self.error_message = undefined;
    self.achievements = undefined;

}

// #####################################################################
// # Codecs
// #####################################################################

/**
 * @func __GameCenterPlayer_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterPlayer} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterPlayer_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: alias, type: String
        if (!is_string(self.alias)) show_error($"{_where} :: self.alias expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.alias));
        buffer_write(_buffer, buffer_string, self.alias);

        // field: display_name, type: String
        if (!is_string(self.display_name)) show_error($"{_where} :: self.display_name expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.display_name));
        buffer_write(_buffer, buffer_string, self.display_name);

        // field: player_id, type: String
        if (!is_string(self.player_id)) show_error($"{_where} :: self.player_id expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.player_id));
        buffer_write(_buffer, buffer_string, self.player_id);

        // field: game_player_id, type: String
        if (!is_string(self.game_player_id)) show_error($"{_where} :: self.game_player_id expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.game_player_id));
        buffer_write(_buffer, buffer_string, self.game_player_id);

        // field: team_player_id, type: String
        if (!is_string(self.team_player_id)) show_error($"{_where} :: self.team_player_id expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.team_player_id));
        buffer_write(_buffer, buffer_string, self.team_player_id);

    }
}

/**
 * @func __GameCenterPlayer_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterPlayer}
 * @ignore
 */
function __GameCenterPlayer_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterPlayer();
    with (_inst)
    {
        // field: alias, type: String
        buffer_read(_buffer, buffer_u32);
        self.alias = buffer_read(_buffer, buffer_string);

        // field: display_name, type: String
        buffer_read(_buffer, buffer_u32);
        self.display_name = buffer_read(_buffer, buffer_string);

        // field: player_id, type: String
        buffer_read(_buffer, buffer_u32);
        self.player_id = buffer_read(_buffer, buffer_string);

        // field: game_player_id, type: String
        buffer_read(_buffer, buffer_u32);
        self.game_player_id = buffer_read(_buffer, buffer_string);

        // field: team_player_id, type: String
        buffer_read(_buffer, buffer_u32);
        self.team_player_id = buffer_read(_buffer, buffer_string);

    }

    return _inst;
}

/**
 * @func __GameCenterSavedGame_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterSavedGame} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterSavedGame_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: device_name, type: String
        if (!is_string(self.device_name)) show_error($"{_where} :: self.device_name expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.device_name));
        buffer_write(_buffer, buffer_string, self.device_name);

        // field: modification_date, type: Float64
        if (!is_numeric(self.modification_date)) show_error($"{_where} :: self.modification_date expected number", true);
        buffer_write(_buffer, buffer_f64, self.modification_date);

        // field: name, type: String
        if (!is_string(self.name)) show_error($"{_where} :: self.name expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.name));
        buffer_write(_buffer, buffer_string, self.name);

    }
}

/**
 * @func __GameCenterSavedGame_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterSavedGame}
 * @ignore
 */
function __GameCenterSavedGame_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterSavedGame();
    with (_inst)
    {
        // field: device_name, type: String
        buffer_read(_buffer, buffer_u32);
        self.device_name = buffer_read(_buffer, buffer_string);

        // field: modification_date, type: Float64
        self.modification_date = buffer_read(_buffer, buffer_f64);

        // field: name, type: String
        buffer_read(_buffer, buffer_u32);
        self.name = buffer_read(_buffer, buffer_string);

    }

    return _inst;
}

/**
 * @func __GameCenterSavedGamesDeleteResult_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterSavedGamesDeleteResult} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterSavedGamesDeleteResult_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: success, type: Bool
        if (!is_bool(self.success)) show_error($"{_where} :: self.success expected bool", true);
        buffer_write(_buffer, buffer_bool, self.success);

        // field: error_code, type: Int32
        if (!is_numeric(self.error_code)) show_error($"{_where} :: self.error_code expected number", true);
        buffer_write(_buffer, buffer_s32, self.error_code);

        // field: error_message, type: String
        if (!is_string(self.error_message)) show_error($"{_where} :: self.error_message expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.error_message));
        buffer_write(_buffer, buffer_string, self.error_message);

        // field: name, type: String
        if (!is_string(self.name)) show_error($"{_where} :: self.name expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.name));
        buffer_write(_buffer, buffer_string, self.name);

    }
}

/**
 * @func __GameCenterSavedGamesDeleteResult_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterSavedGamesDeleteResult}
 * @ignore
 */
function __GameCenterSavedGamesDeleteResult_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterSavedGamesDeleteResult();
    with (_inst)
    {
        // field: success, type: Bool
        self.success = buffer_read(_buffer, buffer_bool);

        // field: error_code, type: Int32
        self.error_code = buffer_read(_buffer, buffer_s32);

        // field: error_message, type: String
        buffer_read(_buffer, buffer_u32);
        self.error_message = buffer_read(_buffer, buffer_string);

        // field: name, type: String
        buffer_read(_buffer, buffer_u32);
        self.name = buffer_read(_buffer, buffer_string);

    }

    return _inst;
}

/**
 * @func __GameCenterSavedGamesDataResult_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterSavedGamesDataResult} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterSavedGamesDataResult_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: success, type: Bool
        if (!is_bool(self.success)) show_error($"{_where} :: self.success expected bool", true);
        buffer_write(_buffer, buffer_bool, self.success);

        // field: error_code, type: Int32
        if (!is_numeric(self.error_code)) show_error($"{_where} :: self.error_code expected number", true);
        buffer_write(_buffer, buffer_s32, self.error_code);

        // field: error_message, type: String
        if (!is_string(self.error_message)) show_error($"{_where} :: self.error_message expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.error_message));
        buffer_write(_buffer, buffer_string, self.error_message);

        // field: name, type: String
        if (!is_string(self.name)) show_error($"{_where} :: self.name expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.name));
        buffer_write(_buffer, buffer_string, self.name);

        // field: handle_id, type: Int32
        if (!is_numeric(self.handle_id)) show_error($"{_where} :: self.handle_id expected number", true);
        buffer_write(_buffer, buffer_s32, self.handle_id);

        // field: required_size, type: Float64
        if (!is_numeric(self.required_size)) show_error($"{_where} :: self.required_size expected number", true);
        buffer_write(_buffer, buffer_f64, self.required_size);

    }
}

/**
 * @func __GameCenterSavedGamesDataResult_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterSavedGamesDataResult}
 * @ignore
 */
function __GameCenterSavedGamesDataResult_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterSavedGamesDataResult();
    with (_inst)
    {
        // field: success, type: Bool
        self.success = buffer_read(_buffer, buffer_bool);

        // field: error_code, type: Int32
        self.error_code = buffer_read(_buffer, buffer_s32);

        // field: error_message, type: String
        buffer_read(_buffer, buffer_u32);
        self.error_message = buffer_read(_buffer, buffer_string);

        // field: name, type: String
        buffer_read(_buffer, buffer_u32);
        self.name = buffer_read(_buffer, buffer_string);

        // field: handle_id, type: Int32
        self.handle_id = buffer_read(_buffer, buffer_s32);

        // field: required_size, type: Float64
        self.required_size = buffer_read(_buffer, buffer_f64);

    }

    return _inst;
}

/**
 * @func __GameCenterLeaderboardSubmitResult_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterLeaderboardSubmitResult} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterLeaderboardSubmitResult_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: success, type: Bool
        if (!is_bool(self.success)) show_error($"{_where} :: self.success expected bool", true);
        buffer_write(_buffer, buffer_bool, self.success);

        // field: error_code, type: Int32
        if (!is_numeric(self.error_code)) show_error($"{_where} :: self.error_code expected number", true);
        buffer_write(_buffer, buffer_s32, self.error_code);

        // field: error_message, type: String
        if (!is_string(self.error_message)) show_error($"{_where} :: self.error_message expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.error_message));
        buffer_write(_buffer, buffer_string, self.error_message);

        // field: leaderboard_id, type: String
        if (!is_string(self.leaderboard_id)) show_error($"{_where} :: self.leaderboard_id expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.leaderboard_id));
        buffer_write(_buffer, buffer_string, self.leaderboard_id);

        // field: score, type: Int32
        if (!is_numeric(self.score)) show_error($"{_where} :: self.score expected number", true);
        buffer_write(_buffer, buffer_s32, self.score);

        // field: context, type: Int32
        if (!is_numeric(self.context)) show_error($"{_where} :: self.context expected number", true);
        buffer_write(_buffer, buffer_s32, self.context);

    }
}

/**
 * @func __GameCenterLeaderboardSubmitResult_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterLeaderboardSubmitResult}
 * @ignore
 */
function __GameCenterLeaderboardSubmitResult_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterLeaderboardSubmitResult();
    with (_inst)
    {
        // field: success, type: Bool
        self.success = buffer_read(_buffer, buffer_bool);

        // field: error_code, type: Int32
        self.error_code = buffer_read(_buffer, buffer_s32);

        // field: error_message, type: String
        buffer_read(_buffer, buffer_u32);
        self.error_message = buffer_read(_buffer, buffer_string);

        // field: leaderboard_id, type: String
        buffer_read(_buffer, buffer_u32);
        self.leaderboard_id = buffer_read(_buffer, buffer_string);

        // field: score, type: Int32
        self.score = buffer_read(_buffer, buffer_s32);

        // field: context, type: Int32
        self.context = buffer_read(_buffer, buffer_s32);

    }

    return _inst;
}

/**
 * @func __GameCenterAchievementReportResult_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterAchievementReportResult} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterAchievementReportResult_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: success, type: Bool
        if (!is_bool(self.success)) show_error($"{_where} :: self.success expected bool", true);
        buffer_write(_buffer, buffer_bool, self.success);

        // field: error_code, type: Int32
        if (!is_numeric(self.error_code)) show_error($"{_where} :: self.error_code expected number", true);
        buffer_write(_buffer, buffer_s32, self.error_code);

        // field: error_message, type: String
        if (!is_string(self.error_message)) show_error($"{_where} :: self.error_message expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.error_message));
        buffer_write(_buffer, buffer_string, self.error_message);

        // field: identifier, type: String
        if (!is_string(self.identifier)) show_error($"{_where} :: self.identifier expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.identifier));
        buffer_write(_buffer, buffer_string, self.identifier);

        // field: percent_complete, type: Float64
        if (!is_numeric(self.percent_complete)) show_error($"{_where} :: self.percent_complete expected number", true);
        buffer_write(_buffer, buffer_f64, self.percent_complete);

    }
}

/**
 * @func __GameCenterAchievementReportResult_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterAchievementReportResult}
 * @ignore
 */
function __GameCenterAchievementReportResult_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterAchievementReportResult();
    with (_inst)
    {
        // field: success, type: Bool
        self.success = buffer_read(_buffer, buffer_bool);

        // field: error_code, type: Int32
        self.error_code = buffer_read(_buffer, buffer_s32);

        // field: error_message, type: String
        buffer_read(_buffer, buffer_u32);
        self.error_message = buffer_read(_buffer, buffer_string);

        // field: identifier, type: String
        buffer_read(_buffer, buffer_u32);
        self.identifier = buffer_read(_buffer, buffer_string);

        // field: percent_complete, type: Float64
        self.percent_complete = buffer_read(_buffer, buffer_f64);

    }

    return _inst;
}

/**
 * @func __GameCenterAchievementResetResult_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterAchievementResetResult} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterAchievementResetResult_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: success, type: Bool
        if (!is_bool(self.success)) show_error($"{_where} :: self.success expected bool", true);
        buffer_write(_buffer, buffer_bool, self.success);

        // field: error_code, type: Int32
        if (!is_numeric(self.error_code)) show_error($"{_where} :: self.error_code expected number", true);
        buffer_write(_buffer, buffer_s32, self.error_code);

        // field: error_message, type: String
        if (!is_string(self.error_message)) show_error($"{_where} :: self.error_message expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.error_message));
        buffer_write(_buffer, buffer_string, self.error_message);

    }
}

/**
 * @func __GameCenterAchievementResetResult_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterAchievementResetResult}
 * @ignore
 */
function __GameCenterAchievementResetResult_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterAchievementResetResult();
    with (_inst)
    {
        // field: success, type: Bool
        self.success = buffer_read(_buffer, buffer_bool);

        // field: error_code, type: Int32
        self.error_code = buffer_read(_buffer, buffer_s32);

        // field: error_message, type: String
        buffer_read(_buffer, buffer_u32);
        self.error_message = buffer_read(_buffer, buffer_string);

    }

    return _inst;
}

/**
 * @func __GameCenterLeaderboardEntry_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterLeaderboardEntry} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterLeaderboardEntry_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: context, type: Float64
        if (!is_numeric(self.context)) show_error($"{_where} :: self.context expected number", true);
        buffer_write(_buffer, buffer_f64, self.context);

        // field: date, type: Float64
        if (!is_numeric(self.date)) show_error($"{_where} :: self.date expected number", true);
        buffer_write(_buffer, buffer_f64, self.date);

        // field: rank, type: Float64
        if (!is_numeric(self.rank)) show_error($"{_where} :: self.rank expected number", true);
        buffer_write(_buffer, buffer_f64, self.rank);

        // field: score, type: Float64
        if (!is_numeric(self.score)) show_error($"{_where} :: self.score expected number", true);
        buffer_write(_buffer, buffer_f64, self.score);

        // field: formatted_score, type: String
        if (!is_string(self.formatted_score)) show_error($"{_where} :: self.formatted_score expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.formatted_score));
        buffer_write(_buffer, buffer_string, self.formatted_score);

        // field: player, type: struct GameCenterPlayer
        if (self.player.__uid != 2277098723) show_error($"{_where} :: self.player expected GameCenterPlayer", true);
        __GameCenterPlayer_encode(self.player, _buffer, buffer_tell(_buffer), _where);

    }
}

/**
 * @func __GameCenterLeaderboardEntry_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterLeaderboardEntry}
 * @ignore
 */
function __GameCenterLeaderboardEntry_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterLeaderboardEntry();
    with (_inst)
    {
        // field: context, type: Float64
        self.context = buffer_read(_buffer, buffer_f64);

        // field: date, type: Float64
        self.date = buffer_read(_buffer, buffer_f64);

        // field: rank, type: Float64
        self.rank = buffer_read(_buffer, buffer_f64);

        // field: score, type: Float64
        self.score = buffer_read(_buffer, buffer_f64);

        // field: formatted_score, type: String
        buffer_read(_buffer, buffer_u32);
        self.formatted_score = buffer_read(_buffer, buffer_string);

        // field: player, type: struct GameCenterPlayer
        self.player = __GameCenterPlayer_decode(_buffer, buffer_tell(_buffer));

    }

    return _inst;
}

/**
 * @func __GameCenterAchievement_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterAchievement} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterAchievement_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: identifier, type: String
        if (!is_string(self.identifier)) show_error($"{_where} :: self.identifier expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.identifier));
        buffer_write(_buffer, buffer_string, self.identifier);

        // field: percent_complete, type: Float64
        if (!is_numeric(self.percent_complete)) show_error($"{_where} :: self.percent_complete expected number", true);
        buffer_write(_buffer, buffer_f64, self.percent_complete);

        // field: is_completed, type: Bool
        if (!is_bool(self.is_completed)) show_error($"{_where} :: self.is_completed expected bool", true);
        buffer_write(_buffer, buffer_bool, self.is_completed);

        // field: shows_completion_banner, type: Bool
        if (!is_bool(self.shows_completion_banner)) show_error($"{_where} :: self.shows_completion_banner expected bool", true);
        buffer_write(_buffer, buffer_bool, self.shows_completion_banner);

        // field: player, type: struct GameCenterPlayer
        if (self.player.__uid != 2277098723) show_error($"{_where} :: self.player expected GameCenterPlayer", true);
        __GameCenterPlayer_encode(self.player, _buffer, buffer_tell(_buffer), _where);

        // field: last_reported_date, type: Float64
        if (!is_numeric(self.last_reported_date)) show_error($"{_where} :: self.last_reported_date expected number", true);
        buffer_write(_buffer, buffer_f64, self.last_reported_date);

    }
}

/**
 * @func __GameCenterAchievement_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterAchievement}
 * @ignore
 */
function __GameCenterAchievement_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterAchievement();
    with (_inst)
    {
        // field: identifier, type: String
        buffer_read(_buffer, buffer_u32);
        self.identifier = buffer_read(_buffer, buffer_string);

        // field: percent_complete, type: Float64
        self.percent_complete = buffer_read(_buffer, buffer_f64);

        // field: is_completed, type: Bool
        self.is_completed = buffer_read(_buffer, buffer_bool);

        // field: shows_completion_banner, type: Bool
        self.shows_completion_banner = buffer_read(_buffer, buffer_bool);

        // field: player, type: struct GameCenterPlayer
        self.player = __GameCenterPlayer_decode(_buffer, buffer_tell(_buffer));

        // field: last_reported_date, type: Float64
        self.last_reported_date = buffer_read(_buffer, buffer_f64);

    }

    return _inst;
}

/**
 * @func __GameCenterAuthResult_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterAuthResult} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterAuthResult_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: success, type: Bool
        if (!is_bool(self.success)) show_error($"{_where} :: self.success expected bool", true);
        buffer_write(_buffer, buffer_bool, self.success);

        // field: error_code, type: Int32
        if (!is_numeric(self.error_code)) show_error($"{_where} :: self.error_code expected number", true);
        buffer_write(_buffer, buffer_s32, self.error_code);

        // field: error_message, type: String
        if (!is_string(self.error_message)) show_error($"{_where} :: self.error_message expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.error_message));
        buffer_write(_buffer, buffer_string, self.error_message);

        // field: authentication_state, type: String
        if (!is_string(self.authentication_state)) show_error($"{_where} :: self.authentication_state expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.authentication_state));
        buffer_write(_buffer, buffer_string, self.authentication_state);

        // field: authenticated, type: Bool
        if (!is_bool(self.authenticated)) show_error($"{_where} :: self.authenticated expected bool", true);
        buffer_write(_buffer, buffer_bool, self.authenticated);

        // field: player, type: struct GameCenterPlayer
        if (self.player.__uid != 2277098723) show_error($"{_where} :: self.player expected GameCenterPlayer", true);
        __GameCenterPlayer_encode(self.player, _buffer, buffer_tell(_buffer), _where);

    }
}

/**
 * @func __GameCenterAuthResult_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterAuthResult}
 * @ignore
 */
function __GameCenterAuthResult_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterAuthResult();
    with (_inst)
    {
        // field: success, type: Bool
        self.success = buffer_read(_buffer, buffer_bool);

        // field: error_code, type: Int32
        self.error_code = buffer_read(_buffer, buffer_s32);

        // field: error_message, type: String
        buffer_read(_buffer, buffer_u32);
        self.error_message = buffer_read(_buffer, buffer_string);

        // field: authentication_state, type: String
        buffer_read(_buffer, buffer_u32);
        self.authentication_state = buffer_read(_buffer, buffer_string);

        // field: authenticated, type: Bool
        self.authenticated = buffer_read(_buffer, buffer_bool);

        // field: player, type: struct GameCenterPlayer
        self.player = __GameCenterPlayer_decode(_buffer, buffer_tell(_buffer));

    }

    return _inst;
}

/**
 * @func __GameCenterSavedGamesFetchResult_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterSavedGamesFetchResult} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterSavedGamesFetchResult_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: success, type: Bool
        if (!is_bool(self.success)) show_error($"{_where} :: self.success expected bool", true);
        buffer_write(_buffer, buffer_bool, self.success);

        // field: error_code, type: Int32
        if (!is_numeric(self.error_code)) show_error($"{_where} :: self.error_code expected number", true);
        buffer_write(_buffer, buffer_s32, self.error_code);

        // field: error_message, type: String
        if (!is_string(self.error_message)) show_error($"{_where} :: self.error_message expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.error_message));
        buffer_write(_buffer, buffer_string, self.error_message);

        // field: slots, type: struct GameCenterSavedGame[]
        if (!is_array(self.slots)) show_error($"{_where} :: self.slots expected array", true);
        var _length = array_length(self.slots);
        buffer_write(_buffer, buffer_u32, _length);
        for (var _i = 0; _i < _length; ++_i)
        {
            if (self.slots[_i].__uid != 2021007683) show_error($"{_where} :: self.slots[_i] expected GameCenterSavedGame", true);
            __GameCenterSavedGame_encode(self.slots[_i], _buffer, buffer_tell(_buffer), _where);
        }

    }
}

/**
 * @func __GameCenterSavedGamesFetchResult_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterSavedGamesFetchResult}
 * @ignore
 */
function __GameCenterSavedGamesFetchResult_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterSavedGamesFetchResult();
    with (_inst)
    {
        // field: success, type: Bool
        self.success = buffer_read(_buffer, buffer_bool);

        // field: error_code, type: Int32
        self.error_code = buffer_read(_buffer, buffer_s32);

        // field: error_message, type: String
        buffer_read(_buffer, buffer_u32);
        self.error_message = buffer_read(_buffer, buffer_string);

        // field: slots, type: struct GameCenterSavedGame[]
        var _length = buffer_read(_buffer, buffer_u32);
        self.slots = array_create(_length);
        for (var _i = 0; _i < _length; ++_i)
        {
            self.slots[_i] = __GameCenterSavedGame_decode(_buffer, buffer_tell(_buffer));
        }

    }

    return _inst;
}

/**
 * @func __GameCenterSavedGamesSaveResult_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterSavedGamesSaveResult} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterSavedGamesSaveResult_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: success, type: Bool
        if (!is_bool(self.success)) show_error($"{_where} :: self.success expected bool", true);
        buffer_write(_buffer, buffer_bool, self.success);

        // field: error_code, type: Int32
        if (!is_numeric(self.error_code)) show_error($"{_where} :: self.error_code expected number", true);
        buffer_write(_buffer, buffer_s32, self.error_code);

        // field: error_message, type: String
        if (!is_string(self.error_message)) show_error($"{_where} :: self.error_message expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.error_message));
        buffer_write(_buffer, buffer_string, self.error_message);

        // field: name, type: String
        if (!is_string(self.name)) show_error($"{_where} :: self.name expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.name));
        buffer_write(_buffer, buffer_string, self.name);

        // field: slot, type: struct GameCenterSavedGame
        if (self.slot.__uid != 2021007683) show_error($"{_where} :: self.slot expected GameCenterSavedGame", true);
        __GameCenterSavedGame_encode(self.slot, _buffer, buffer_tell(_buffer), _where);

    }
}

/**
 * @func __GameCenterSavedGamesSaveResult_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterSavedGamesSaveResult}
 * @ignore
 */
function __GameCenterSavedGamesSaveResult_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterSavedGamesSaveResult();
    with (_inst)
    {
        // field: success, type: Bool
        self.success = buffer_read(_buffer, buffer_bool);

        // field: error_code, type: Int32
        self.error_code = buffer_read(_buffer, buffer_s32);

        // field: error_message, type: String
        buffer_read(_buffer, buffer_u32);
        self.error_message = buffer_read(_buffer, buffer_string);

        // field: name, type: String
        buffer_read(_buffer, buffer_u32);
        self.name = buffer_read(_buffer, buffer_string);

        // field: slot, type: struct GameCenterSavedGame
        self.slot = __GameCenterSavedGame_decode(_buffer, buffer_tell(_buffer));

    }

    return _inst;
}

/**
 * @func __GameCenterSavedGamesResolveResult_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterSavedGamesResolveResult} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterSavedGamesResolveResult_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: success, type: Bool
        if (!is_bool(self.success)) show_error($"{_where} :: self.success expected bool", true);
        buffer_write(_buffer, buffer_bool, self.success);

        // field: error_code, type: Int32
        if (!is_numeric(self.error_code)) show_error($"{_where} :: self.error_code expected number", true);
        buffer_write(_buffer, buffer_s32, self.error_code);

        // field: error_message, type: String
        if (!is_string(self.error_message)) show_error($"{_where} :: self.error_message expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.error_message));
        buffer_write(_buffer, buffer_string, self.error_message);

        // field: conflict_id, type: Int32
        if (!is_numeric(self.conflict_id)) show_error($"{_where} :: self.conflict_id expected number", true);
        buffer_write(_buffer, buffer_s32, self.conflict_id);

        // field: slots, type: struct GameCenterSavedGame[]
        if (!is_array(self.slots)) show_error($"{_where} :: self.slots expected array", true);
        var _length = array_length(self.slots);
        buffer_write(_buffer, buffer_u32, _length);
        for (var _i = 0; _i < _length; ++_i)
        {
            if (self.slots[_i].__uid != 2021007683) show_error($"{_where} :: self.slots[_i] expected GameCenterSavedGame", true);
            __GameCenterSavedGame_encode(self.slots[_i], _buffer, buffer_tell(_buffer), _where);
        }

    }
}

/**
 * @func __GameCenterSavedGamesResolveResult_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterSavedGamesResolveResult}
 * @ignore
 */
function __GameCenterSavedGamesResolveResult_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterSavedGamesResolveResult();
    with (_inst)
    {
        // field: success, type: Bool
        self.success = buffer_read(_buffer, buffer_bool);

        // field: error_code, type: Int32
        self.error_code = buffer_read(_buffer, buffer_s32);

        // field: error_message, type: String
        buffer_read(_buffer, buffer_u32);
        self.error_message = buffer_read(_buffer, buffer_string);

        // field: conflict_id, type: Int32
        self.conflict_id = buffer_read(_buffer, buffer_s32);

        // field: slots, type: struct GameCenterSavedGame[]
        var _length = buffer_read(_buffer, buffer_u32);
        self.slots = array_create(_length);
        for (var _i = 0; _i < _length; ++_i)
        {
            self.slots[_i] = __GameCenterSavedGame_decode(_buffer, buffer_tell(_buffer));
        }

    }

    return _inst;
}

/**
 * @func __GameCenterSavedGamesEvent_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterSavedGamesEvent} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterSavedGamesEvent_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: type, type: String
        if (!is_string(self.type)) show_error($"{_where} :: self.type expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.type));
        buffer_write(_buffer, buffer_string, self.type);

        // field: conflict_id, type: Int32
        if (!is_numeric(self.conflict_id)) show_error($"{_where} :: self.conflict_id expected number", true);
        buffer_write(_buffer, buffer_s32, self.conflict_id);

        // field: player, type: struct GameCenterPlayer
        if (self.player.__uid != 2277098723) show_error($"{_where} :: self.player expected GameCenterPlayer", true);
        __GameCenterPlayer_encode(self.player, _buffer, buffer_tell(_buffer), _where);

        // field: slot, type: struct GameCenterSavedGame
        if (self.slot.__uid != 2021007683) show_error($"{_where} :: self.slot expected GameCenterSavedGame", true);
        __GameCenterSavedGame_encode(self.slot, _buffer, buffer_tell(_buffer), _where);

        // field: slots, type: struct GameCenterSavedGame[]
        if (!is_array(self.slots)) show_error($"{_where} :: self.slots expected array", true);
        var _length = array_length(self.slots);
        buffer_write(_buffer, buffer_u32, _length);
        for (var _i = 0; _i < _length; ++_i)
        {
            if (self.slots[_i].__uid != 2021007683) show_error($"{_where} :: self.slots[_i] expected GameCenterSavedGame", true);
            __GameCenterSavedGame_encode(self.slots[_i], _buffer, buffer_tell(_buffer), _where);
        }

    }
}

/**
 * @func __GameCenterSavedGamesEvent_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterSavedGamesEvent}
 * @ignore
 */
function __GameCenterSavedGamesEvent_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterSavedGamesEvent();
    with (_inst)
    {
        // field: type, type: String
        buffer_read(_buffer, buffer_u32);
        self.type = buffer_read(_buffer, buffer_string);

        // field: conflict_id, type: Int32
        self.conflict_id = buffer_read(_buffer, buffer_s32);

        // field: player, type: struct GameCenterPlayer
        self.player = __GameCenterPlayer_decode(_buffer, buffer_tell(_buffer));

        // field: slot, type: struct GameCenterSavedGame
        self.slot = __GameCenterSavedGame_decode(_buffer, buffer_tell(_buffer));

        // field: slots, type: struct GameCenterSavedGame[]
        var _length = buffer_read(_buffer, buffer_u32);
        self.slots = array_create(_length);
        for (var _i = 0; _i < _length; ++_i)
        {
            self.slots[_i] = __GameCenterSavedGame_decode(_buffer, buffer_tell(_buffer));
        }

    }

    return _inst;
}

/**
 * @func __GameCenterLeaderboardLoadResult_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterLeaderboardLoadResult} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterLeaderboardLoadResult_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: success, type: Bool
        if (!is_bool(self.success)) show_error($"{_where} :: self.success expected bool", true);
        buffer_write(_buffer, buffer_bool, self.success);

        // field: error_code, type: Int32
        if (!is_numeric(self.error_code)) show_error($"{_where} :: self.error_code expected number", true);
        buffer_write(_buffer, buffer_s32, self.error_code);

        // field: error_message, type: String
        if (!is_string(self.error_message)) show_error($"{_where} :: self.error_message expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.error_message));
        buffer_write(_buffer, buffer_string, self.error_message);

        // field: leaderboard_id, type: String
        if (!is_string(self.leaderboard_id)) show_error($"{_where} :: self.leaderboard_id expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.leaderboard_id));
        buffer_write(_buffer, buffer_string, self.leaderboard_id);

        // field: time_scope, type: Int32
        if (!is_numeric(self.time_scope)) show_error($"{_where} :: self.time_scope expected number", true);
        buffer_write(_buffer, buffer_s32, self.time_scope);

        // field: range_start, type: Float64
        if (!is_numeric(self.range_start)) show_error($"{_where} :: self.range_start expected number", true);
        buffer_write(_buffer, buffer_f64, self.range_start);

        // field: range_count, type: Float64
        if (!is_numeric(self.range_count)) show_error($"{_where} :: self.range_count expected number", true);
        buffer_write(_buffer, buffer_f64, self.range_count);

        // field: player_scope, type: Int32
        if (!is_numeric(self.player_scope)) show_error($"{_where} :: self.player_scope expected number", true);
        buffer_write(_buffer, buffer_s32, self.player_scope);

        // field: leaderboard_title, type: String
        if (!is_string(self.leaderboard_title)) show_error($"{_where} :: self.leaderboard_title expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.leaderboard_title));
        buffer_write(_buffer, buffer_string, self.leaderboard_title);

        // field: leaderboard_group, type: String
        if (!is_string(self.leaderboard_group)) show_error($"{_where} :: self.leaderboard_group expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.leaderboard_group));
        buffer_write(_buffer, buffer_string, self.leaderboard_group);

        // field: leaderboard_type, type: Int32
        if (!is_numeric(self.leaderboard_type)) show_error($"{_where} :: self.leaderboard_type expected number", true);
        buffer_write(_buffer, buffer_s32, self.leaderboard_type);

        // field: leaderboard_start_date, type: Float64
        if (!is_numeric(self.leaderboard_start_date)) show_error($"{_where} :: self.leaderboard_start_date expected number", true);
        buffer_write(_buffer, buffer_f64, self.leaderboard_start_date);

        // field: leaderboard_next_start_date, type: Float64
        if (!is_numeric(self.leaderboard_next_start_date)) show_error($"{_where} :: self.leaderboard_next_start_date expected number", true);
        buffer_write(_buffer, buffer_f64, self.leaderboard_next_start_date);

        // field: leaderboard_duration, type: Float64
        if (!is_numeric(self.leaderboard_duration)) show_error($"{_where} :: self.leaderboard_duration expected number", true);
        buffer_write(_buffer, buffer_f64, self.leaderboard_duration);

        // field: total_players_count, type: Float64
        if (!is_numeric(self.total_players_count)) show_error($"{_where} :: self.total_players_count expected number", true);
        buffer_write(_buffer, buffer_f64, self.total_players_count);

        // field: local_entry, type: struct GameCenterLeaderboardEntry
        if (self.local_entry.__uid != 2759294555) show_error($"{_where} :: self.local_entry expected GameCenterLeaderboardEntry", true);
        __GameCenterLeaderboardEntry_encode(self.local_entry, _buffer, buffer_tell(_buffer), _where);

        // field: entries, type: struct GameCenterLeaderboardEntry[]
        if (!is_array(self.entries)) show_error($"{_where} :: self.entries expected array", true);
        var _length = array_length(self.entries);
        buffer_write(_buffer, buffer_u32, _length);
        for (var _i = 0; _i < _length; ++_i)
        {
            if (self.entries[_i].__uid != 2759294555) show_error($"{_where} :: self.entries[_i] expected GameCenterLeaderboardEntry", true);
            __GameCenterLeaderboardEntry_encode(self.entries[_i], _buffer, buffer_tell(_buffer), _where);
        }

    }
}

/**
 * @func __GameCenterLeaderboardLoadResult_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterLeaderboardLoadResult}
 * @ignore
 */
function __GameCenterLeaderboardLoadResult_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterLeaderboardLoadResult();
    with (_inst)
    {
        // field: success, type: Bool
        self.success = buffer_read(_buffer, buffer_bool);

        // field: error_code, type: Int32
        self.error_code = buffer_read(_buffer, buffer_s32);

        // field: error_message, type: String
        buffer_read(_buffer, buffer_u32);
        self.error_message = buffer_read(_buffer, buffer_string);

        // field: leaderboard_id, type: String
        buffer_read(_buffer, buffer_u32);
        self.leaderboard_id = buffer_read(_buffer, buffer_string);

        // field: time_scope, type: Int32
        self.time_scope = buffer_read(_buffer, buffer_s32);

        // field: range_start, type: Float64
        self.range_start = buffer_read(_buffer, buffer_f64);

        // field: range_count, type: Float64
        self.range_count = buffer_read(_buffer, buffer_f64);

        // field: player_scope, type: Int32
        self.player_scope = buffer_read(_buffer, buffer_s32);

        // field: leaderboard_title, type: String
        buffer_read(_buffer, buffer_u32);
        self.leaderboard_title = buffer_read(_buffer, buffer_string);

        // field: leaderboard_group, type: String
        buffer_read(_buffer, buffer_u32);
        self.leaderboard_group = buffer_read(_buffer, buffer_string);

        // field: leaderboard_type, type: Int32
        self.leaderboard_type = buffer_read(_buffer, buffer_s32);

        // field: leaderboard_start_date, type: Float64
        self.leaderboard_start_date = buffer_read(_buffer, buffer_f64);

        // field: leaderboard_next_start_date, type: Float64
        self.leaderboard_next_start_date = buffer_read(_buffer, buffer_f64);

        // field: leaderboard_duration, type: Float64
        self.leaderboard_duration = buffer_read(_buffer, buffer_f64);

        // field: total_players_count, type: Float64
        self.total_players_count = buffer_read(_buffer, buffer_f64);

        // field: local_entry, type: struct GameCenterLeaderboardEntry
        self.local_entry = __GameCenterLeaderboardEntry_decode(_buffer, buffer_tell(_buffer));

        // field: entries, type: struct GameCenterLeaderboardEntry[]
        var _length = buffer_read(_buffer, buffer_u32);
        self.entries = array_create(_length);
        for (var _i = 0; _i < _length; ++_i)
        {
            self.entries[_i] = __GameCenterLeaderboardEntry_decode(_buffer, buffer_tell(_buffer));
        }

    }

    return _inst;
}

/**
 * @func __GameCenterAchievementsResult_encode(_inst, _buffer, _offset, _where)
 * @param {Struct.GameCenterAchievementsResult} _inst
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @param {String} _where
 * @ignore
 */
function __GameCenterAchievementsResult_encode(_inst, _buffer, _offset, _where = _GMFUNCTION_)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);
    with (_inst)
    {
        // field: success, type: Bool
        if (!is_bool(self.success)) show_error($"{_where} :: self.success expected bool", true);
        buffer_write(_buffer, buffer_bool, self.success);

        // field: error_code, type: Int32
        if (!is_numeric(self.error_code)) show_error($"{_where} :: self.error_code expected number", true);
        buffer_write(_buffer, buffer_s32, self.error_code);

        // field: error_message, type: String
        if (!is_string(self.error_message)) show_error($"{_where} :: self.error_message expected string", true);
        buffer_write(_buffer, buffer_u32, string_byte_length(self.error_message));
        buffer_write(_buffer, buffer_string, self.error_message);

        // field: achievements, type: struct GameCenterAchievement[]
        if (!is_array(self.achievements)) show_error($"{_where} :: self.achievements expected array", true);
        var _length = array_length(self.achievements);
        buffer_write(_buffer, buffer_u32, _length);
        for (var _i = 0; _i < _length; ++_i)
        {
            if (self.achievements[_i].__uid != 1240377713) show_error($"{_where} :: self.achievements[_i] expected GameCenterAchievement", true);
            __GameCenterAchievement_encode(self.achievements[_i], _buffer, buffer_tell(_buffer), _where);
        }

    }
}

/**
 * @func __GameCenterAchievementsResult_decode(_buffer, _offset)
 * @param {Id.Buffer} _buffer
 * @param {Real} _offset
 * @returns {Struct.GameCenterAchievementsResult}
 * @ignore
 */
function __GameCenterAchievementsResult_decode(_buffer, _offset)
{
    buffer_seek(_buffer, buffer_seek_start, _offset);

    _inst = new GameCenterAchievementsResult();
    with (_inst)
    {
        // field: success, type: Bool
        self.success = buffer_read(_buffer, buffer_bool);

        // field: error_code, type: Int32
        self.error_code = buffer_read(_buffer, buffer_s32);

        // field: error_message, type: String
        buffer_read(_buffer, buffer_u32);
        self.error_message = buffer_read(_buffer, buffer_string);

        // field: achievements, type: struct GameCenterAchievement[]
        var _length = buffer_read(_buffer, buffer_u32);
        self.achievements = array_create(_length);
        for (var _i = 0; _i < _length; ++_i)
        {
            self.achievements[_i] = __GameCenterAchievement_decode(_buffer, buffer_tell(_buffer));
        }

    }

    return _inst;
}

// #####################################################################
// # Functions
// #####################################################################

/**
 * @param {Function} _callback
 */
function gamecenter_view_callback_subscribe(_callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_view_callback_subscribe(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

// Skipping function gamecenter_present_view_achievement (no wrapper is required)


/**
 * @param {String} _leaderboard_id
 * @param {Enum.GameCenterLeaderboardTimeScope} _time_scope
 * @param {Enum.GameCenterLeaderboardPlayerScope} _player_scope
 * @returns {Bool}
 */
function gamecenter_present_view_leaderboard(_leaderboard_id, _time_scope, _player_scope)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _leaderboard_id, type: String
    if (!is_string(_leaderboard_id)) show_error($"{_GMFUNCTION_} :: _leaderboard_id expected string", true);
    buffer_write(__args_buffer, buffer_u32, string_byte_length(_leaderboard_id));
    buffer_write(__args_buffer, buffer_string, _leaderboard_id);

    // param: _time_scope, type: enum GameCenterLeaderboardTimeScope

    if (!is_numeric(_time_scope)) show_error($"{_GMFUNCTION_} :: _time_scope expected number", true);
    buffer_write(__args_buffer, buffer_s32, _time_scope);

    // param: _player_scope, type: enum GameCenterLeaderboardPlayerScope

    if (!is_numeric(_player_scope)) show_error($"{_GMFUNCTION_} :: _player_scope expected number", true);
    buffer_write(__args_buffer, buffer_s32, _player_scope);

    var _return_value = __gamecenter_present_view_leaderboard(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {Function} _callback
 */
function gamecenter_local_player_authenticate(_callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_local_player_authenticate(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

// Skipping function gamecenter_local_player_is_authenticated (no wrapper is required)


// Skipping function gamecenter_local_player_is_underage (no wrapper is required)


// Skipping function gamecenter_local_player_is_multiplayer_gaming_restricted (no wrapper is required)


// Skipping function gamecenter_local_player_is_personalized_communication_restricted (no wrapper is required)


/**
 * @returns {Struct.GameCenterPlayer}
 */
function gamecenter_local_player_get_info()
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __ret_buffer = __ext_core_get_ret_buffer();

    var _return_value = __gamecenter_local_player_get_info(buffer_get_address(__ret_buffer), buffer_get_size(__ret_buffer));

    var _result = undefined;
    _result = __GameCenterPlayer_decode(__ret_buffer, buffer_tell(__ret_buffer));
    return _result;
}

/**
 * @param {Function} _callback
 */
function gamecenter_saved_games_callback_subscribe(_callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_saved_games_callback_subscribe(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {Function} _callback
 */
function gamecenter_saved_games_fetch(_callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_saved_games_fetch(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {String} _name
 * @param {Id.Buffer} _data
 * @param {Function} _callback
 */
function gamecenter_saved_games_save(_name, _data, _callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _name, type: String
    if (!is_string(_name)) show_error($"{_GMFUNCTION_} :: _name expected string", true);
    buffer_write(__args_buffer, buffer_u32, string_byte_length(_name));
    buffer_write(__args_buffer, buffer_string, _name);

    // param: _data, type: Buffer
    if (!buffer_exists(_data)) show_error($"{_GMFUNCTION_} :: _data expected Id.Buffer", true);
    __GMGameCenter_queue_buffer(buffer_get_address(_data), buffer_get_size(_data));

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_saved_games_save(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {String} _name
 * @param {Function} _callback
 */
function gamecenter_saved_games_delete(_name, _callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _name, type: String
    if (!is_string(_name)) show_error($"{_GMFUNCTION_} :: _name expected string", true);
    buffer_write(__args_buffer, buffer_u32, string_byte_length(_name));
    buffer_write(__args_buffer, buffer_string, _name);

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_saved_games_delete(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {String} _name
 * @param {Function} _callback
 */
function gamecenter_saved_games_data_request(_name, _callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _name, type: String
    if (!is_string(_name)) show_error($"{_GMFUNCTION_} :: _name expected string", true);
    buffer_write(__args_buffer, buffer_u32, string_byte_length(_name));
    buffer_write(__args_buffer, buffer_string, _name);

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_saved_games_data_request(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {Real} _handle_id
 * @param {Id.Buffer} _data
 * @returns {Bool}
 */
function gamecenter_saved_games_data_fetch(_handle_id, _data)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _handle_id, type: Float64
    if (!is_numeric(_handle_id)) show_error($"{_GMFUNCTION_} :: _handle_id expected number", true);
    buffer_write(__args_buffer, buffer_f64, _handle_id);

    // param: _data, type: Buffer
    if (!buffer_exists(_data)) show_error($"{_GMFUNCTION_} :: _data expected Id.Buffer", true);
    __GMGameCenter_queue_buffer(buffer_get_address(_data), buffer_get_size(_data));

    var _return_value = __gamecenter_saved_games_data_fetch(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

// Skipping function gamecenter_saved_games_data_release (no wrapper is required)


/**
 * @param {Real} _conflict_id
 * @param {Id.Buffer} _data
 * @param {Function} _callback
 */
function gamecenter_saved_games_resolve_conflict(_conflict_id, _data, _callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _conflict_id, type: Float64
    if (!is_numeric(_conflict_id)) show_error($"{_GMFUNCTION_} :: _conflict_id expected number", true);
    buffer_write(__args_buffer, buffer_f64, _conflict_id);

    // param: _data, type: Buffer
    if (!buffer_exists(_data)) show_error($"{_GMFUNCTION_} :: _data expected Id.Buffer", true);
    __GMGameCenter_queue_buffer(buffer_get_address(_data), buffer_get_size(_data));

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_saved_games_resolve_conflict(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {String} _leaderboard_id
 * @param {Real} _score
 * @param {Real} _context
 * @param {Function} _callback
 */
function gamecenter_leaderboard_submit(_leaderboard_id, _score, _context, _callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _leaderboard_id, type: String
    if (!is_string(_leaderboard_id)) show_error($"{_GMFUNCTION_} :: _leaderboard_id expected string", true);
    buffer_write(__args_buffer, buffer_u32, string_byte_length(_leaderboard_id));
    buffer_write(__args_buffer, buffer_string, _leaderboard_id);

    // param: _score, type: Int32
    if (!is_numeric(_score)) show_error($"{_GMFUNCTION_} :: _score expected number", true);
    buffer_write(__args_buffer, buffer_s32, _score);

    // param: _context, type: Int32
    if (!is_numeric(_context)) show_error($"{_GMFUNCTION_} :: _context expected number", true);
    buffer_write(__args_buffer, buffer_s32, _context);

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_leaderboard_submit(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {String} _leaderboard_id
 * @param {Enum.GameCenterLeaderboardTimeScope} _time_scope
 * @param {Real} _range_start
 * @param {Real} _range_count
 * @param {Enum.GameCenterLeaderboardPlayerScope} _player_scope
 * @param {Function} _callback
 */
function gamecenter_leaderboard_load(_leaderboard_id, _time_scope, _range_start, _range_count, _player_scope, _callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _leaderboard_id, type: String
    if (!is_string(_leaderboard_id)) show_error($"{_GMFUNCTION_} :: _leaderboard_id expected string", true);
    buffer_write(__args_buffer, buffer_u32, string_byte_length(_leaderboard_id));
    buffer_write(__args_buffer, buffer_string, _leaderboard_id);

    // param: _time_scope, type: enum GameCenterLeaderboardTimeScope

    if (!is_numeric(_time_scope)) show_error($"{_GMFUNCTION_} :: _time_scope expected number", true);
    buffer_write(__args_buffer, buffer_s32, _time_scope);

    // param: _range_start, type: Float64
    if (!is_numeric(_range_start)) show_error($"{_GMFUNCTION_} :: _range_start expected number", true);
    buffer_write(__args_buffer, buffer_f64, _range_start);

    // param: _range_count, type: Float64
    if (!is_numeric(_range_count)) show_error($"{_GMFUNCTION_} :: _range_count expected number", true);
    buffer_write(__args_buffer, buffer_f64, _range_count);

    // param: _player_scope, type: enum GameCenterLeaderboardPlayerScope

    if (!is_numeric(_player_scope)) show_error($"{_GMFUNCTION_} :: _player_scope expected number", true);
    buffer_write(__args_buffer, buffer_s32, _player_scope);

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_leaderboard_load(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {String} _identifier
 * @param {Real} _percent_complete
 * @param {Bool} _show_completion_banner
 * @param {Function} _callback
 */
function gamecenter_achievement_report(_identifier, _percent_complete, _show_completion_banner, _callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _identifier, type: String
    if (!is_string(_identifier)) show_error($"{_GMFUNCTION_} :: _identifier expected string", true);
    buffer_write(__args_buffer, buffer_u32, string_byte_length(_identifier));
    buffer_write(__args_buffer, buffer_string, _identifier);

    // param: _percent_complete, type: Float64
    if (!is_numeric(_percent_complete)) show_error($"{_GMFUNCTION_} :: _percent_complete expected number", true);
    buffer_write(__args_buffer, buffer_f64, _percent_complete);

    // param: _show_completion_banner, type: Bool
    if (!is_bool(_show_completion_banner)) show_error($"{_GMFUNCTION_} :: _show_completion_banner expected bool", true);
    buffer_write(__args_buffer, buffer_bool, _show_completion_banner);

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_achievement_report(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {Function} _callback
 */
function gamecenter_achievement_reset_all(_callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_achievement_reset_all(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {Function} _callback
 */
function gamecenter_achievement_load(_callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_achievement_load(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

// Skipping function gamecenter_access_point_set_active (no wrapper is required)


// Skipping function gamecenter_access_point_get_active (no wrapper is required)


/**
 * @param {Enum.GameCenterAccessPointLocation} _location
 * @returns {Bool}
 */
function gamecenter_access_point_set_location(_location)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _location, type: enum GameCenterAccessPointLocation

    if (!is_numeric(_location)) show_error($"{_GMFUNCTION_} :: _location expected number", true);
    buffer_write(__args_buffer, buffer_s32, _location);

    var _return_value = __gamecenter_access_point_set_location(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

// Skipping function gamecenter_access_point_get_location (no wrapper is required)


// Skipping function gamecenter_access_point_is_presenting_game_center (no wrapper is required)


// Skipping function gamecenter_access_point_is_visible (no wrapper is required)


// Skipping function gamecenter_access_point_set_show_highlights (no wrapper is required)


// Skipping function gamecenter_access_point_get_show_highlights (no wrapper is required)


/**
 * @param {Enum.GameCenterAccessPointCoordinate} _coordinate
 * @returns {Real}
 */
function gamecenter_access_point_get_coordinate(_coordinate)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _coordinate, type: enum GameCenterAccessPointCoordinate

    if (!is_numeric(_coordinate)) show_error($"{_GMFUNCTION_} :: _coordinate expected number", true);
    buffer_write(__args_buffer, buffer_s32, _coordinate);

    var _return_value = __gamecenter_access_point_get_coordinate(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {Enum.GameCenterViewState} _state
 * @param {Function} _callback
 * @returns {Bool}
 */
function gamecenter_access_point_present_with_state(_state, _callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _state, type: enum GameCenterViewState

    if (!is_numeric(_state)) show_error($"{_GMFUNCTION_} :: _state expected number", true);
    buffer_write(__args_buffer, buffer_s32, _state);

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_access_point_present_with_state(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/**
 * @param {Function} _callback
 * @returns {Bool}
 */
function gamecenter_access_point_present(_callback)
{
    var __available = __GMGameCenter_is_available();
    if (!__available) return;

    var __dispatcher = __GMGameCenter_get_dispatcher();

    var __args_buffer = __ext_core_get_args_buffer();

    // param: _callback, type: Function
    if (!is_callable(_callback)) show_error($"{_GMFUNCTION_} :: _callback expected callable type", true);
    var _callback_handle = __ext_core_function_register(_callback, __dispatcher);
    buffer_write(__args_buffer, buffer_u64, _callback_handle);

    var _return_value = __gamecenter_access_point_present(buffer_get_address(__args_buffer), buffer_tell(__args_buffer));

    return _return_value;
}

/// @ignore
function __GMGameCenter_get_decoders()
{
    static __decoders = [
        __GameCenterPlayer_decode,
        __GameCenterSavedGame_decode,
        __GameCenterSavedGamesDeleteResult_decode,
        __GameCenterSavedGamesDataResult_decode,
        __GameCenterLeaderboardSubmitResult_decode,
        __GameCenterAchievementReportResult_decode,
        __GameCenterAchievementResetResult_decode,
        __GameCenterLeaderboardEntry_decode,
        __GameCenterAchievement_decode,
        __GameCenterAuthResult_decode,
        __GameCenterSavedGamesFetchResult_decode,
        __GameCenterSavedGamesSaveResult_decode,
        __GameCenterSavedGamesResolveResult_decode,
        __GameCenterSavedGamesEvent_decode,
        __GameCenterLeaderboardLoadResult_decode,
        __GameCenterAchievementsResult_decode
    ];
    return __decoders;
}
/// @ignore
function __GMGameCenter_get_dispatcher()
{
    static __dispatcher = new __GMNativeFunctionDispatcher(__GMGameCenter_invocation_handler, __GMGameCenter_get_decoders());
    return __dispatcher;
}
/// @ignore
function __GMGameCenter_is_available()
{
    static __available = extension_exists("GMGameCenter");
    return __available;
}
