# Online multiplayer sessions

Online play is ghost co-op over Steam lobbies and P2P packets. Each player
controls their own character, and players on the same level see each other.
This change makes joining work from anywhere and in every mode. It also adds a
Friends panel to the main menu and reworks the networking core (protocol 2).

## Sessions

- **Always joinable.** While *Online Multiplayer* is on, every Steam player owns
  a friends-only lobby from the main menu onward. The lobby is no longer
  destroyed on the main menu. `o_networkmanager` is created once at boot and is
  persistent.
- **Joining.** Steam "Join Game" and invites (`lobby_join_requested`) are
  handled in every room. So are cold launches (`+connect_lobby`) and the
  Friends panel. An explicit join turns the setting on. The join reply is
  validated: Steam reports success even for a full or vanished lobby, so the
  game checks the member count, game name and protocol.
- **Following.** A player who joined someone follows that lobby owner. A
  session is one stretch of gameplay entered from a menu. Its id changes
  whenever the host enters gameplay from a menu, so the host starting a mode,
  run or level-select level takes followers along.
  - In gameplay, followers get a 3-second banner first. In menus they move
    at once.
  - Followers are never moved while paused, in the level editor or in local
    multiplayer. They join when they leave.
  - Within one session everyone progresses independently.
- **Host migration.** Ownership passes to the longest-standing member. The new
  owner's current session counts as already seen, so a migration never
  teleports anyone.

## Joining each mode

| Host is playing | A follower gets |
| --- | --- |
| Campaign, level select, hard mode, daily, calendar | Practice play of the host's room: no save or full-run rewards |
| Built-in challenge (rooms or packaged levels such as Lunar Base) | Practice of the same challenge level |
| Endless Run, Old School, Custom (host's custom settings) | A fresh run of their own (own lives and level count), starting on the host's level |
| Workshop Endless Run | Same, downloading the host's current item if needed |
| Workshop level / Workshop challenge | Missing items are subscribed and downloaded, then played |
| Level editor play-test, custom (local) challenge level | The level is sent peer to peer, verified and cached in `Online Levels/<md5>/`, then played; finishing replays it |
| Menus, editor build mode, local multiplayer | Not joinable; followers wait |

**Endless Run picks.** Endless runs share level picks. The first player to
reach level *N* of a run decides it, and everyone else in that run plays the
same level *N*.

**Downloaded items.** Workshop items downloaded only to follow someone are
unsubscribed when the follower moves on to another session.

## Core changes (protocol 2)

- **Packet ids and protocol check.** New packet ids (16–24) are used, so
  protocol 1 builds ignore them and the reverse is also true. The lobby stores
  `proto`; mismatched versions get a clear message.
- **Ghost visibility.** Ghosts are matched by level key, not room name: `ws:<id>`,
  `ch:<id>:<dir>`, `lv:<md5>`, or the room name. Template rooms that show
  different levels no longer show ghosts from other levels.
- **State packets.** They carry a 16-bit sequence number, so late or duplicate
  unreliable packets are dropped.
  - State goes only to peers on the same level.
  - The rate drops in large lobbies and while the player is idle.
  - Brief gaps are bridged by prediction, small corrections are smoothed and
    teleports snap.
  - Ghosts are interpolated between ticks at render caps above 60 FPS.
- **Identity, ping and membership.** HELLO always refreshes a peer's name and
  cosmetics, which fixes an async request id being shown as a name. PING/PONG
  measures round-trip time. Lobby membership is cached and refreshed, with a
  forced refresh when a newcomer's packet beats Steam's callback.
- **Steam friends list.** Group keys (`steam_player_group`) group party members.
  `steam_user_set_played_with` adds peers to "recently played with".

## Limitations

- Steam's server browser ("View > Game Servers") lists dedicated game servers.
  This game uses lobbies, which appear on the friends list and the overlay.
  They do not appear in that browser.
- Custom music (`Music.ogg`) is not transferred with shared levels; the level's
  built-in music choice is used.
- Custom (local) challenges are shared one level at a time.

## Validation

Static checks: GML parse of every changed file, symbol resolution against
scripts, assets, extension functions and the GML spec, object event validation,
port configuration checks and `git diff --check`. `scr_online_cosmetics_selfcheck`
and `scr_online_session_selfcheck` cover packet codecs, sequence handling,
descriptors, room classes and Endless pick merging in the Check build.

Live Steam play still needs manual checks with two or more accounts:

- Overlay join from the main menu and from gameplay.
- Cold launch.
- Each row of the table above.
- A Workshop download.
- An editor play-test transfer.
- Host migration.
- Leaving from the Friends panel.
