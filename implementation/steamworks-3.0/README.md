# Steamworks extension 3.0.0 migration (work in progress)

Moves the project from the GameMaker Steamworks extension 2.1.6 (SDK 1.61) to 3.0.0 (SDK 1.65) and rewrites the
online multiplayer transport from the legacy `steam_net_packet_*` P2P API to Steam Networking Messages.

3.0.0 is a full rewrite of the extension with a different API: functions are grouped per Steamworks interface,
results arrive in GML callbacks instead of the Steam Async Event, and the legacy P2P API is gone. Release notes:
<https://github.com/YoYoGames/GMEXT-Steamworks/releases/tag/3.0.0>.

## Status

This is a snapshot of work in progress. It has not been compiled, run in GameMaker, or tested against Steam.

Done in this branch:

- `extensions/Steamworks` replaced with the 3.0.0 tag of the official repository. Local patches re-applied: the
  Apple/Mobile `copyToTargets = 0` exclusions in `Steamworks.yy`, and the `TCC_STEAM_SDK` override and quoting fixes in
  `post_build_step.sh`. 3.0 handles the macOS Hardened Runtime entitlements itself.
- `scripts/Steamworks_Definitions` replaced by `scripts/Steamworks_API` (the 3.0 GML API, generated, do not edit).
- `tools/check_port.py` expects extension version 3.0.0; the README asks for SDK 1.65.
- The wrapper layer `scripts/scr_steam_safe` rewritten, all call sites ported, the 2.x Steam async handlers
  (`Other_69.gml` plus their `.yy` event entries) removed, and the multiplayer rewritten on Networking Messages.
  See `wrapper-contract.md` and `netcode-design-final.md` for the design these follow.

Still to do (check the PR description for the latest state):

1. New scripts created by the port (for example the transport mock and transport self-check) must be listed in
   `The Colorful Creature.yyp` and the `.resource_order` file, otherwise GameMaker ignores them.
2. Put **Steamworks SDK 1.65** at `../../sdk` (or set `TCC_STEAM_SDK`). The 3.0 build step fails the build when the SDK
   hash does not match 1.65. The download needs a Steamworks partner login.
3. Compile and run the `Check` configuration with the self-checks (`tools/build.py`).
4. Decide the extension's **Debug** option per configuration. 2.x treated an IDE launch as debug; 3.0 only does with
   `Enabled`, otherwise a game started outside Steam is relaunched through Steam. Never ship with `Enabled`.
5. Runtime tests that need Steam: one account on one machine, then two accounts on two machines for the multiplayer
   (section 10 of `netcode-design-final.md`).
6. Update `docs/` (a submodule): `docs/release/STATUS.md`, `docs/docs/getting-started.md` and `README` still mention
   extension 2.1.6 and SDK 1.61.

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
