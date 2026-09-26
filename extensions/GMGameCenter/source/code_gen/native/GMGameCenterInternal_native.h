// ##### extgen :: Auto-generated file do not edit!! #####

#pragma once
#include <cstdint>
#include <string_view>
#include <vector>
#include <array>
#include <optional>
#include "core/GMExtWire.h"

namespace gm_consts
{
}


namespace gm_enums
{
    enum class GameCenterLeaderboardTimeScope : std::int32_t
    {
        Today = 0,
        Week = 1,
        AllTime = 2
    };

    enum class GameCenterLeaderboardPlayerScope : std::int32_t
    {
        Global = 0,
        FriendsOnly = 1
    };

    enum class GameCenterAccessPointLocation : std::int32_t
    {
        TopLeading = 0,
        TopTrailing = 1,
        BottomLeading = 2,
        BottomTrailing = 3
    };

    enum class GameCenterAccessPointCoordinate : std::int32_t
    {
        X = 0,
        Y = 1,
        Width = 2,
        Height = 3
    };

    enum class GameCenterViewState : std::int32_t
    {
        Default = -1,
        Leaderboards = 0,
        Achievements = 1,
        Challenges = 2,
        LocalPlayerProfile = 3,
        Dashboard = 4,
        LocalPlayerFriendsList = 5
    };

}


namespace gm_structs
{
    struct GameCenterPlayer;
    struct GameCenterSavedGame;
    struct GameCenterSavedGamesDeleteResult;
    struct GameCenterSavedGamesDataResult;
    struct GameCenterLeaderboardSubmitResult;
    struct GameCenterAchievementReportResult;
    struct GameCenterAchievementResetResult;
    struct GameCenterLeaderboardEntry;
    struct GameCenterAchievement;
    struct GameCenterAuthResult;
    struct GameCenterSavedGamesFetchResult;
    struct GameCenterSavedGamesSaveResult;
    struct GameCenterSavedGamesResolveResult;
    struct GameCenterSavedGamesEvent;
    struct GameCenterLeaderboardLoadResult;
    struct GameCenterAchievementsResult;

    struct GameCenterPlayer
    {
        std::string alias;
        std::string display_name;
        std::string player_id;
        std::string game_player_id;
        std::string team_player_id;
    };

    struct GameCenterSavedGame
    {
        std::string device_name;
        double modification_date;
        std::string name;
    };

    struct GameCenterSavedGamesDeleteResult
    {
        bool success;
        std::int32_t error_code;
        std::string error_message;
        std::string name;
    };

    struct GameCenterSavedGamesDataResult
    {
        bool success;
        std::int32_t error_code;
        std::string error_message;
        std::string name;
        std::int32_t handle_id;
        double required_size;
    };

    struct GameCenterLeaderboardSubmitResult
    {
        bool success;
        std::int32_t error_code;
        std::string error_message;
        std::string leaderboard_id;
        std::int32_t score;
        std::int32_t context;
    };

    struct GameCenterAchievementReportResult
    {
        bool success;
        std::int32_t error_code;
        std::string error_message;
        std::string identifier;
        double percent_complete;
    };

    struct GameCenterAchievementResetResult
    {
        bool success;
        std::int32_t error_code;
        std::string error_message;
    };

    struct GameCenterLeaderboardEntry
    {
        double context;
        double date;
        double rank;
        double score;
        std::string formatted_score;
        gm_structs::GameCenterPlayer player;
    };

    struct GameCenterAchievement
    {
        std::string identifier;
        double percent_complete;
        bool is_completed;
        bool shows_completion_banner;
        gm_structs::GameCenterPlayer player;
        double last_reported_date;
    };

    struct GameCenterAuthResult
    {
        bool success;
        std::int32_t error_code;
        std::string error_message;
        std::string authentication_state;
        bool authenticated;
        gm_structs::GameCenterPlayer player;
    };

    struct GameCenterSavedGamesFetchResult
    {
        bool success;
        std::int32_t error_code;
        std::string error_message;
        std::vector<gm_structs::GameCenterSavedGame> slots;
    };

    struct GameCenterSavedGamesSaveResult
    {
        bool success;
        std::int32_t error_code;
        std::string error_message;
        std::string name;
        gm_structs::GameCenterSavedGame slot;
    };

    struct GameCenterSavedGamesResolveResult
    {
        bool success;
        std::int32_t error_code;
        std::string error_message;
        std::int32_t conflict_id;
        std::vector<gm_structs::GameCenterSavedGame> slots;
    };

    struct GameCenterSavedGamesEvent
    {
        std::string type;
        std::int32_t conflict_id;
        gm_structs::GameCenterPlayer player;
        gm_structs::GameCenterSavedGame slot;
        std::vector<gm_structs::GameCenterSavedGame> slots;
    };

    struct GameCenterLeaderboardLoadResult
    {
        bool success;
        std::int32_t error_code;
        std::string error_message;
        std::string leaderboard_id;
        std::int32_t time_scope;
        double range_start;
        double range_count;
        std::int32_t player_scope;
        std::string leaderboard_title;
        std::string leaderboard_group;
        std::int32_t leaderboard_type;
        double leaderboard_start_date;
        double leaderboard_next_start_date;
        double leaderboard_duration;
        double total_players_count;
        gm_structs::GameCenterLeaderboardEntry local_entry;
        std::vector<gm_structs::GameCenterLeaderboardEntry> entries;
    };

    struct GameCenterAchievementsResult
    {
        bool success;
        std::int32_t error_code;
        std::string error_message;
        std::vector<gm_structs::GameCenterAchievement> achievements;
    };

}

namespace gm::wire::codec
{
    template<>
    inline void writeValue<gm_structs::GameCenterPlayer>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterPlayer& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.alias);
        gm::wire::codec::writeValue(_buf, obj.display_name);
        gm::wire::codec::writeValue(_buf, obj.player_id);
        gm::wire::codec::writeValue(_buf, obj.game_player_id);
        gm::wire::codec::writeValue(_buf, obj.team_player_id);
    }

    template<>
    inline gm_structs::GameCenterPlayer readValue<gm_structs::GameCenterPlayer>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterPlayer obj;
        obj.alias = gm::wire::codec::readValue<std::string>(_buf);
        obj.display_name = gm::wire::codec::readValue<std::string>(_buf);
        obj.player_id = gm::wire::codec::readValue<std::string>(_buf);
        obj.game_player_id = gm::wire::codec::readValue<std::string>(_buf);
        obj.team_player_id = gm::wire::codec::readValue<std::string>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterSavedGame>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterSavedGame& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.device_name);
        gm::wire::codec::writeValue(_buf, obj.modification_date);
        gm::wire::codec::writeValue(_buf, obj.name);
    }

    template<>
    inline gm_structs::GameCenterSavedGame readValue<gm_structs::GameCenterSavedGame>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterSavedGame obj;
        obj.device_name = gm::wire::codec::readValue<std::string>(_buf);
        obj.modification_date = gm::wire::codec::readValue<double>(_buf);
        obj.name = gm::wire::codec::readValue<std::string>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterSavedGamesDeleteResult>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterSavedGamesDeleteResult& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.success);
        gm::wire::codec::writeValue(_buf, obj.error_code);
        gm::wire::codec::writeValue(_buf, obj.error_message);
        gm::wire::codec::writeValue(_buf, obj.name);
    }

    template<>
    inline gm_structs::GameCenterSavedGamesDeleteResult readValue<gm_structs::GameCenterSavedGamesDeleteResult>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterSavedGamesDeleteResult obj;
        obj.success = gm::wire::codec::readValue<bool>(_buf);
        obj.error_code = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.error_message = gm::wire::codec::readValue<std::string>(_buf);
        obj.name = gm::wire::codec::readValue<std::string>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterSavedGamesDataResult>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterSavedGamesDataResult& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.success);
        gm::wire::codec::writeValue(_buf, obj.error_code);
        gm::wire::codec::writeValue(_buf, obj.error_message);
        gm::wire::codec::writeValue(_buf, obj.name);
        gm::wire::codec::writeValue(_buf, obj.handle_id);
        gm::wire::codec::writeValue(_buf, obj.required_size);
    }

    template<>
    inline gm_structs::GameCenterSavedGamesDataResult readValue<gm_structs::GameCenterSavedGamesDataResult>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterSavedGamesDataResult obj;
        obj.success = gm::wire::codec::readValue<bool>(_buf);
        obj.error_code = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.error_message = gm::wire::codec::readValue<std::string>(_buf);
        obj.name = gm::wire::codec::readValue<std::string>(_buf);
        obj.handle_id = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.required_size = gm::wire::codec::readValue<double>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterLeaderboardSubmitResult>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterLeaderboardSubmitResult& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.success);
        gm::wire::codec::writeValue(_buf, obj.error_code);
        gm::wire::codec::writeValue(_buf, obj.error_message);
        gm::wire::codec::writeValue(_buf, obj.leaderboard_id);
        gm::wire::codec::writeValue(_buf, obj.score);
        gm::wire::codec::writeValue(_buf, obj.context);
    }

    template<>
    inline gm_structs::GameCenterLeaderboardSubmitResult readValue<gm_structs::GameCenterLeaderboardSubmitResult>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterLeaderboardSubmitResult obj;
        obj.success = gm::wire::codec::readValue<bool>(_buf);
        obj.error_code = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.error_message = gm::wire::codec::readValue<std::string>(_buf);
        obj.leaderboard_id = gm::wire::codec::readValue<std::string>(_buf);
        obj.score = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.context = gm::wire::codec::readValue<std::int32_t>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterAchievementReportResult>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterAchievementReportResult& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.success);
        gm::wire::codec::writeValue(_buf, obj.error_code);
        gm::wire::codec::writeValue(_buf, obj.error_message);
        gm::wire::codec::writeValue(_buf, obj.identifier);
        gm::wire::codec::writeValue(_buf, obj.percent_complete);
    }

    template<>
    inline gm_structs::GameCenterAchievementReportResult readValue<gm_structs::GameCenterAchievementReportResult>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterAchievementReportResult obj;
        obj.success = gm::wire::codec::readValue<bool>(_buf);
        obj.error_code = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.error_message = gm::wire::codec::readValue<std::string>(_buf);
        obj.identifier = gm::wire::codec::readValue<std::string>(_buf);
        obj.percent_complete = gm::wire::codec::readValue<double>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterAchievementResetResult>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterAchievementResetResult& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.success);
        gm::wire::codec::writeValue(_buf, obj.error_code);
        gm::wire::codec::writeValue(_buf, obj.error_message);
    }

    template<>
    inline gm_structs::GameCenterAchievementResetResult readValue<gm_structs::GameCenterAchievementResetResult>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterAchievementResetResult obj;
        obj.success = gm::wire::codec::readValue<bool>(_buf);
        obj.error_code = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.error_message = gm::wire::codec::readValue<std::string>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterLeaderboardEntry>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterLeaderboardEntry& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.context);
        gm::wire::codec::writeValue(_buf, obj.date);
        gm::wire::codec::writeValue(_buf, obj.rank);
        gm::wire::codec::writeValue(_buf, obj.score);
        gm::wire::codec::writeValue(_buf, obj.formatted_score);
        gm::wire::codec::writeValue(_buf, obj.player);
    }

    template<>
    inline gm_structs::GameCenterLeaderboardEntry readValue<gm_structs::GameCenterLeaderboardEntry>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterLeaderboardEntry obj;
        obj.context = gm::wire::codec::readValue<double>(_buf);
        obj.date = gm::wire::codec::readValue<double>(_buf);
        obj.rank = gm::wire::codec::readValue<double>(_buf);
        obj.score = gm::wire::codec::readValue<double>(_buf);
        obj.formatted_score = gm::wire::codec::readValue<std::string>(_buf);
        obj.player = gm::wire::codec::readValue<gm_structs::GameCenterPlayer>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterAchievement>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterAchievement& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.identifier);
        gm::wire::codec::writeValue(_buf, obj.percent_complete);
        gm::wire::codec::writeValue(_buf, obj.is_completed);
        gm::wire::codec::writeValue(_buf, obj.shows_completion_banner);
        gm::wire::codec::writeValue(_buf, obj.player);
        gm::wire::codec::writeValue(_buf, obj.last_reported_date);
    }

    template<>
    inline gm_structs::GameCenterAchievement readValue<gm_structs::GameCenterAchievement>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterAchievement obj;
        obj.identifier = gm::wire::codec::readValue<std::string>(_buf);
        obj.percent_complete = gm::wire::codec::readValue<double>(_buf);
        obj.is_completed = gm::wire::codec::readValue<bool>(_buf);
        obj.shows_completion_banner = gm::wire::codec::readValue<bool>(_buf);
        obj.player = gm::wire::codec::readValue<gm_structs::GameCenterPlayer>(_buf);
        obj.last_reported_date = gm::wire::codec::readValue<double>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterAuthResult>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterAuthResult& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.success);
        gm::wire::codec::writeValue(_buf, obj.error_code);
        gm::wire::codec::writeValue(_buf, obj.error_message);
        gm::wire::codec::writeValue(_buf, obj.authentication_state);
        gm::wire::codec::writeValue(_buf, obj.authenticated);
        gm::wire::codec::writeValue(_buf, obj.player);
    }

    template<>
    inline gm_structs::GameCenterAuthResult readValue<gm_structs::GameCenterAuthResult>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterAuthResult obj;
        obj.success = gm::wire::codec::readValue<bool>(_buf);
        obj.error_code = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.error_message = gm::wire::codec::readValue<std::string>(_buf);
        obj.authentication_state = gm::wire::codec::readValue<std::string>(_buf);
        obj.authenticated = gm::wire::codec::readValue<bool>(_buf);
        obj.player = gm::wire::codec::readValue<gm_structs::GameCenterPlayer>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterSavedGamesFetchResult>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterSavedGamesFetchResult& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.success);
        gm::wire::codec::writeValue(_buf, obj.error_code);
        gm::wire::codec::writeValue(_buf, obj.error_message);
        gm::wire::codec::writeValue(_buf, obj.slots);
    }

    template<>
    inline gm_structs::GameCenterSavedGamesFetchResult readValue<gm_structs::GameCenterSavedGamesFetchResult>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterSavedGamesFetchResult obj;
        obj.success = gm::wire::codec::readValue<bool>(_buf);
        obj.error_code = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.error_message = gm::wire::codec::readValue<std::string>(_buf);
        obj.slots = gm::wire::codec::readVector<gm_structs::GameCenterSavedGame>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterSavedGamesSaveResult>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterSavedGamesSaveResult& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.success);
        gm::wire::codec::writeValue(_buf, obj.error_code);
        gm::wire::codec::writeValue(_buf, obj.error_message);
        gm::wire::codec::writeValue(_buf, obj.name);
        gm::wire::codec::writeValue(_buf, obj.slot);
    }

    template<>
    inline gm_structs::GameCenterSavedGamesSaveResult readValue<gm_structs::GameCenterSavedGamesSaveResult>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterSavedGamesSaveResult obj;
        obj.success = gm::wire::codec::readValue<bool>(_buf);
        obj.error_code = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.error_message = gm::wire::codec::readValue<std::string>(_buf);
        obj.name = gm::wire::codec::readValue<std::string>(_buf);
        obj.slot = gm::wire::codec::readValue<gm_structs::GameCenterSavedGame>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterSavedGamesResolveResult>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterSavedGamesResolveResult& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.success);
        gm::wire::codec::writeValue(_buf, obj.error_code);
        gm::wire::codec::writeValue(_buf, obj.error_message);
        gm::wire::codec::writeValue(_buf, obj.conflict_id);
        gm::wire::codec::writeValue(_buf, obj.slots);
    }

    template<>
    inline gm_structs::GameCenterSavedGamesResolveResult readValue<gm_structs::GameCenterSavedGamesResolveResult>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterSavedGamesResolveResult obj;
        obj.success = gm::wire::codec::readValue<bool>(_buf);
        obj.error_code = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.error_message = gm::wire::codec::readValue<std::string>(_buf);
        obj.conflict_id = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.slots = gm::wire::codec::readVector<gm_structs::GameCenterSavedGame>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterSavedGamesEvent>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterSavedGamesEvent& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.type);
        gm::wire::codec::writeValue(_buf, obj.conflict_id);
        gm::wire::codec::writeValue(_buf, obj.player);
        gm::wire::codec::writeValue(_buf, obj.slot);
        gm::wire::codec::writeValue(_buf, obj.slots);
    }

    template<>
    inline gm_structs::GameCenterSavedGamesEvent readValue<gm_structs::GameCenterSavedGamesEvent>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterSavedGamesEvent obj;
        obj.type = gm::wire::codec::readValue<std::string>(_buf);
        obj.conflict_id = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.player = gm::wire::codec::readValue<gm_structs::GameCenterPlayer>(_buf);
        obj.slot = gm::wire::codec::readValue<gm_structs::GameCenterSavedGame>(_buf);
        obj.slots = gm::wire::codec::readVector<gm_structs::GameCenterSavedGame>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterLeaderboardLoadResult>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterLeaderboardLoadResult& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.success);
        gm::wire::codec::writeValue(_buf, obj.error_code);
        gm::wire::codec::writeValue(_buf, obj.error_message);
        gm::wire::codec::writeValue(_buf, obj.leaderboard_id);
        gm::wire::codec::writeValue(_buf, obj.time_scope);
        gm::wire::codec::writeValue(_buf, obj.range_start);
        gm::wire::codec::writeValue(_buf, obj.range_count);
        gm::wire::codec::writeValue(_buf, obj.player_scope);
        gm::wire::codec::writeValue(_buf, obj.leaderboard_title);
        gm::wire::codec::writeValue(_buf, obj.leaderboard_group);
        gm::wire::codec::writeValue(_buf, obj.leaderboard_type);
        gm::wire::codec::writeValue(_buf, obj.leaderboard_start_date);
        gm::wire::codec::writeValue(_buf, obj.leaderboard_next_start_date);
        gm::wire::codec::writeValue(_buf, obj.leaderboard_duration);
        gm::wire::codec::writeValue(_buf, obj.total_players_count);
        gm::wire::codec::writeValue(_buf, obj.local_entry);
        gm::wire::codec::writeValue(_buf, obj.entries);
    }

    template<>
    inline gm_structs::GameCenterLeaderboardLoadResult readValue<gm_structs::GameCenterLeaderboardLoadResult>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterLeaderboardLoadResult obj;
        obj.success = gm::wire::codec::readValue<bool>(_buf);
        obj.error_code = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.error_message = gm::wire::codec::readValue<std::string>(_buf);
        obj.leaderboard_id = gm::wire::codec::readValue<std::string>(_buf);
        obj.time_scope = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.range_start = gm::wire::codec::readValue<double>(_buf);
        obj.range_count = gm::wire::codec::readValue<double>(_buf);
        obj.player_scope = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.leaderboard_title = gm::wire::codec::readValue<std::string>(_buf);
        obj.leaderboard_group = gm::wire::codec::readValue<std::string>(_buf);
        obj.leaderboard_type = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.leaderboard_start_date = gm::wire::codec::readValue<double>(_buf);
        obj.leaderboard_next_start_date = gm::wire::codec::readValue<double>(_buf);
        obj.leaderboard_duration = gm::wire::codec::readValue<double>(_buf);
        obj.total_players_count = gm::wire::codec::readValue<double>(_buf);
        obj.local_entry = gm::wire::codec::readValue<gm_structs::GameCenterLeaderboardEntry>(_buf);
        obj.entries = gm::wire::codec::readVector<gm_structs::GameCenterLeaderboardEntry>(_buf);
        return obj;
    }

    template<>
    inline void writeValue<gm_structs::GameCenterAchievementsResult>(gm::byteio::IByteWriter& _buf, const gm_structs::GameCenterAchievementsResult& obj)
    {
        gm::wire::codec::writeValue(_buf, obj.success);
        gm::wire::codec::writeValue(_buf, obj.error_code);
        gm::wire::codec::writeValue(_buf, obj.error_message);
        gm::wire::codec::writeValue(_buf, obj.achievements);
    }

    template<>
    inline gm_structs::GameCenterAchievementsResult readValue<gm_structs::GameCenterAchievementsResult>(gm::byteio::BufferReader& _buf)
    {
        gm_structs::GameCenterAchievementsResult obj;
        obj.success = gm::wire::codec::readValue<bool>(_buf);
        obj.error_code = gm::wire::codec::readValue<std::int32_t>(_buf);
        obj.error_message = gm::wire::codec::readValue<std::string>(_buf);
        obj.achievements = gm::wire::codec::readVector<gm_structs::GameCenterAchievement>(_buf);
        return obj;
    }

}

namespace gm::wire::details
{
    template<>
    struct gm_struct_traits<gm_structs::GameCenterPlayer>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 0;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterSavedGame>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 1;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterSavedGamesDeleteResult>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 2;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterSavedGamesDataResult>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 3;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterLeaderboardSubmitResult>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 4;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterAchievementReportResult>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 5;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterAchievementResetResult>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 6;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterLeaderboardEntry>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 7;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterAchievement>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 8;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterAuthResult>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 9;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterSavedGamesFetchResult>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 10;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterSavedGamesSaveResult>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 11;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterSavedGamesResolveResult>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 12;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterSavedGamesEvent>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 13;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterLeaderboardLoadResult>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 14;
    };

    template<>
    struct gm_struct_traits<gm_structs::GameCenterAchievementsResult>
    {
        static constexpr bool is_gm_struct = true;
        static constexpr std::uint32_t codec_id = 15;
    };

}

void gamecenter_view_callback_subscribe(const gm::wire::GMFunction& callback);
bool gamecenter_present_view_achievement(std::string_view achievement_id);
bool gamecenter_present_view_leaderboard(std::string_view leaderboard_id, gm_enums::GameCenterLeaderboardTimeScope time_scope, gm_enums::GameCenterLeaderboardPlayerScope player_scope);
void gamecenter_local_player_authenticate(const gm::wire::GMFunction& callback);
bool gamecenter_local_player_is_authenticated();
bool gamecenter_local_player_is_underage();
bool gamecenter_local_player_is_multiplayer_gaming_restricted();
bool gamecenter_local_player_is_personalized_communication_restricted();
gm_structs::GameCenterPlayer gamecenter_local_player_get_info();
void gamecenter_saved_games_callback_subscribe(const gm::wire::GMFunction& callback);
void gamecenter_saved_games_fetch(const gm::wire::GMFunction& callback);
void gamecenter_saved_games_save(std::string_view name, gm::wire::GMBuffer data, const gm::wire::GMFunction& callback);
void gamecenter_saved_games_delete(std::string_view name, const gm::wire::GMFunction& callback);
void gamecenter_saved_games_data_request(std::string_view name, const gm::wire::GMFunction& callback);
bool gamecenter_saved_games_data_fetch(double handle_id, gm::wire::GMBuffer data);
bool gamecenter_saved_games_data_release(double handle_id);
void gamecenter_saved_games_resolve_conflict(double conflict_id, gm::wire::GMBuffer data, const gm::wire::GMFunction& callback);
void gamecenter_leaderboard_submit(std::string_view leaderboard_id, std::int32_t score, std::int32_t context, const gm::wire::GMFunction& callback);
void gamecenter_leaderboard_load(std::string_view leaderboard_id, gm_enums::GameCenterLeaderboardTimeScope time_scope, double range_start, double range_count, gm_enums::GameCenterLeaderboardPlayerScope player_scope, const gm::wire::GMFunction& callback);
void gamecenter_achievement_report(std::string_view identifier, double percent_complete, bool show_completion_banner, const gm::wire::GMFunction& callback);
void gamecenter_achievement_reset_all(const gm::wire::GMFunction& callback);
void gamecenter_achievement_load(const gm::wire::GMFunction& callback);
bool gamecenter_access_point_set_active(bool active);
bool gamecenter_access_point_get_active();
bool gamecenter_access_point_set_location(gm_enums::GameCenterAccessPointLocation location);
double gamecenter_access_point_get_location();
bool gamecenter_access_point_is_presenting_game_center();
bool gamecenter_access_point_is_visible();
bool gamecenter_access_point_set_show_highlights(bool show);
bool gamecenter_access_point_get_show_highlights();
double gamecenter_access_point_get_coordinate(gm_enums::GameCenterAccessPointCoordinate coordinate);
bool gamecenter_access_point_present_with_state(gm_enums::GameCenterViewState state, const gm::wire::GMFunction& callback);
bool gamecenter_access_point_present(const gm::wire::GMFunction& callback);
