# Steamworks extension 3.0.0 migration (work in progress)

Moves the project from the GameMaker Steamworks extension 2.1.6 (SDK 1.61) to 3.0.0 (SDK 1.65) and rewrites the
online multiplayer transport from the legacy `steam_net_packet_*` P2P API to Steam Networking Messages.

3.0.0 is a full rewrite of the extension with a different API: functions are grouped per Steamworks interface,
results arrive in GML callbacks instead of the Steam Async Event, and the legacy P2P API is gone. Release notes:
<https://github.com/YoYoGames/GMEXT-Steamworks/releases/tag/3.0.0>.

## Status

This is a snapshot of work in progress. The `Check` configuration compiles through the GameMaker compiler (Igor), and an
independent review of the port has been done and its confirmed findings fixed. Nothing has been run yet: not the self-checks,
and not against Steam.

Done in this branch:

- `extensions/Steamworks` replaced with the 3.0.0 tag of the official repository. Local patches re-applied: the
  Apple/Mobile `copyToTargets = 0` exclusions in `Steamworks.yy`, and the `TCC_STEAM_SDK` override and quoting fixes in
  `post_build_step.sh`. 3.0 handles the macOS Hardened Runtime entitlements itself.
- `scripts/Steamworks_Definitions` replaced by `scripts/Steamworks_API` (the 3.0 GML API, generated, do not edit).
- `tools/check_port.py` expects extension version 3.0.0; the README asks for SDK 1.65.
- The wrapper layer `scripts/scr_steam_safe` rewritten, all call sites ported, the 2.x Steam async handlers
  (`Other_69.gml` plus their `.yy` event entries) removed, and the multiplayer rewritten on Networking Messages.
  See `wrapper-contract.md` and `netcode-design-final.md` for the design these follow.

Also in the branch: Steam-free transport tests (`scripts/scr_net_mock`, `scripts/scr_online_transport_selfcheck`, wired into
`scr_port_selfcheck` for the `Check` configuration) and new gates in `tools/check_port.py`. The new scripts are registered
in the `.yyp`. Static checks pass: `python3 -I tools/check_port.py` and
`python3 -I implementation/steamworks-3.0/tools/check_steam_names.py` (0 errors).

Still to do:

1. Put **Steamworks SDK 1.65** at `../../sdk` (or set `TCC_STEAM_SDK`). The 3.0 build step fails the build when the SDK
   hash does not match 1.65. The download needs a Steamworks partner login.
2. Run the `Check` configuration with the self-checks (`tools/build.py Check --output DIR --native-diagnostic --runtime VM
   --self-check --headless --snapshot`). It already compiles; the launch step is what is still untested. The self-checks print
   `TCC_STEAM_WRAPPER_SELF_CHECK_PASS`, `TCC_ONLINE_TRANSPORT_SELF_CHECK_PASS` and then `TCC_PORT_SELF_CHECK_PASS`.
3. Decide the extension's **Debug** option per configuration. 2.x treated an IDE launch as debug; 3.0 only does with
   `Enabled`, otherwise a game started outside Steam is relaunched through Steam. Never ship with `Enabled`
   (`check_port.py` allows it only for the Check, QA and iOSCheck configurations).
4. Runtime tests that need Steam: one account on one machine, then two accounts on two machines for the multiplayer
   (section 10 of `netcode-design-final.md`).
5. Windows only, blocking before a release: Steam must accept the raw Workshop content/preview paths used when publishing
   levels and challenges (2.x passed them through GameMaker's SaveFileName first). The fallback hook is
   `tcc_steam_ugc_path()` in `scr_steam_safe.gml`.
6. Update `docs/` (a submodule): `docs/release/STATUS.md`, `docs/docs/getting-started.md` and `README` still mention
   extension 2.1.6 and SDK 1.61.

Assumptions that only a real run can confirm (each has a log line or self-check assertion that trips first):

- Typed result structs reach the relay (`instanceof` returns the constructor name); otherwise `unrouted` counts up.
- `buffer_read(buffer_u64)` and `int64(string)` keep all 64 bits of a Steam id.
- `game_restart()` does not run the extension's shutdown (otherwise the lobby is lost after the ending sequence).
- The overlay dialog strings `"friends"` / `"achievements"` (`TCC_OVERLAY_*`) open the overlay; if not, use TitleCase.
- Leaderboard results that arrive while their owner (for example `o_settings`) is deactivated are dropped, because
  `instance_exists` is false for deactivated instances.
- The extension writes every result into one shared return buffer (8192 bytes by default) and aborts the game when a result
  does not fit. `__tcc_steam_grow_return_buffer()` grows it to 256 KB once Steam is ready; if a crash shows up in
  `steam_inventory_get_result_items`, `steam_ugc_get_query_ugc_result` or `steam_ugc_get_subscribed_items`, look there first.

Known limitation (rare, no fix): a leaderboard answer that arrives more than 20 s late, after the wrapper's watchdog gave up on
its job, can be applied to the next queued job, because Steam's answers carry no request id.

## Files

| File | What it is |
|---|---|
| `wrapper-contract.md` | The interface every call site follows (`tcc_steam_*` wrappers), the implementer notes for `scr_steam_safe.gml`, handler replacements, constants, gates, and old-to-new tables with all callers. |
| `netcode-design-final.md` | The multiplayer design: minimal-change swap to Networking Messages, message catalog, accept policy, test plan, risks. Wins over the contract where it lists its own contract additions. |
| `netcode-spec.md` | How the 2.x multiplayer worked (message layouts, session lifecycle, implicit guarantees of the legacy API). |
| `async-handlers-*.md` | What each removed Steam async handler did. |
| `maps/map-*.final.md` | Verified 2.x to 3.0 function maps per area (core, social, lobby, stats, ugc, inventory, net). |
| `identifiers-2x.json` | Every `steam_*` identifier the project used before the port, with files. |
| `tools/check_steam_names.py` | Checks every `steam_*` call, `Steam*` enum member and `STEAM_*` macro in project GML against the installed 3.0 API (name, argument count). `python3 -I implementation/steamworks-3.0/tools/check_steam_names.py` |
| `tools/gml_balance.py` | Bracket balance check for edited GML files. It is not a compiler. |
| `tools/remove_other69.py` | Deletes an object's Steam async handler and its `.yy` event entry. |

Paths such as `<scratchpad>` inside the documents refer to the session that produced them; the referenced files are the
ones in this folder, the 3.0 sources (<https://github.com/YoYoGames/GMEXT-Steamworks>, tag `3.0.0`), and the 2.x docs in git
history (`extensions/Steamworks/docs` at the commit before this branch).
