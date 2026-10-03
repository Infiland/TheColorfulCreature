# TCC 1.3.0 implementation and validation

This change prepares version 1.3.0 on `1.2.1`. The user deferred special levels
(#31); their drafts, catalog, menus and runtime hooks are excluded. Original
donation rooms and existing Endless categories remain available.

## Retained scope

| Area / issues | Result | Evidence |
| --- | --- | --- |
| Shared level format #14 | Versioned `level.json`, validation before replacement, ordered initialization, legacy JSON/INI adapters, editor/challenge/Workshop integration | Native integration self-check; Lunar's 4,636-instance import |
| Slopes #13 | Five colors, four orientations, block-style drawing, triangle collisions, player/troop/projectile behavior, editor rotation and persistence | Slope geometry self-check; retained single-player and multiplayer/actor matrices |
| Troops #51 | Cached and invalidated room navigation, staggered bounded searches, cleanup separated from defeat rewards, activation repairs and W5-L4 balance fixes | Navigation benchmark; retained cache comparisons and 18 W5-L4 input recordings |
| Lunar Base | Challenge 19, existing large map, local records, complete results/replay/return flow, death/retry restoration, skin 49 | Native integration self-check; retained full-exit, retry and seed-variation recordings |
| Commentary #25 | Sourced chronological gallery, artwork captions, navigation and saved reading position; DLC 1995510 ownership gate | Commentary self-check |
| Cosmetics #34 and items | File-based skins/hats/items, shared discovery/preview/selection, correct persistence, sprite cleanup and ghost fallbacks | Cosmetic runtime/resource and online-cosmetic self-checks |
| Controllers/settings #32/#33 | Six-action remapping, capture/reset/cancel, selected-device/hot-plug handling, repaired controls and save keys | Controller/settings self-checks |
| Timing, pause and FPS | Fixed 60 Hz gameplay with configurable 30–1000 render cap and default 60; presentation, input and pause integration | Retained movement/draw/engine-clock comparisons; final cleaned-source build |
| Level select #38/#122 | Numeric entries and unlock coverage, full-run/practice separation, correct campaign save destination through merchant transitions | Level-select/save transaction self-checks; retained actual level 30 → merchant → 31 recording |
| Platforms #77/#93/#121 | Apple/Android configuration repairs; separate SteamAndroid APK with controllers and local services, ads/Google auth disabled | Configuration checks; retained iOS simulator and signed-APK smoke evidence |
| Existing features #58/#98 | Trade-ups and online ghost cosmetic interactions hardened within their existing scope | Trade-up and online-cosmetic self-checks |

## Validation scope

Final checks on the cleaned source are recorded separately in
`evidence/release-check-130-03.json`. Static configuration/resource/event checks,
Python tool compilation and `git diff --check` also run before the PR is created.
Native diagnostics use a muted, hidden host and a separate Check application.
No special-level tests or new special content are part of this change.

The other JSON packets in `evidence/` are preserved historical results. Their
original source, artifact, clock and content bindings have not been rewritten
to imply validation of the final cleaned tree. They cover actual movement,
slopes, W5-L4, Lunar completion/recovery, save transitions and mobile smoke
tests. Raw logs, inputs, outputs and frozen builds remain outside the checkout.

## Animation regression follow-up

The follow-up fixes player left/right poses being cleared by the native No Key
callback between simulation ticks. One-way blocks and the clock/ammo icons now
participate in the fixed-clock animation holds despite using custom Draw events
without an assigned sprite. Ammo speed is set by the simulation rather than Draw;
paused settings also freeze the clock. Editor slope menu and toolbar icons use the
selected color and rotation through the existing block-material renderer.

`evidence/animation-regressions-2026-10-03.json` records the current-source native
Draw observations, rendered player poses, animation rates, pause checks and any
render-only coverage gaps. Configured render caps are recorded separately from
actual observed frame rates. All eight runs pass: single player at all six caps
and local multiplayer at 60/150. The single-player traces match exactly across
28,560 position, motion and pose comparisons. These runs do not prove sustained
high-FPS rendering
on the hidden test host. The earlier cleaned-source packet retains its original
binding and scope.

## Release gates

- Final signed release exports, physical devices/controllers and live Steam,
  Workshop, Google Play and Game Center services still require release checks.
- iPhone/iPad iOS 18.5 simulator smoke checks passed on their recorded builds.
  iOS 26.5 hit an Apple OpenGL shader compiler crash before GML startup; physical
  iOS compatibility remains a gate.
- SteamAndroid has a local signed APK/emulator smoke result. The installed
  Steam extension has no Android implementation. Native Steam services and
  Steam Frame hardware compatibility are not established by that APK result.
- Lunar's retained normal-rules completion took 181.18 seconds with zero
  deaths. The existing 130-second medal target is preserved; achieving it has
  not been proven.

## Cleanup and preservation

The cleanup removed draft special resources, special-only tools, preview
images, generated reports and redundant planning files. Shared diagnostic
code and the small Lunar route fixture remain because they exercise the timing,
collision and save changes.

Every pre-cleanup file was archived and rehashed before removal. Recovery:
`/Users/infi/Library/Caches/TCC130/release-pr-130-cleanup01/pre-cleanup-source.tar.gz`
(SHA-256 `a703bd629c8ed218d3599c96ebc910e39e6b2d7fc62a27e77133b11e83ec1d62`).
`cleanup.json` records the preserved evidence and scope. The user's original
level 42 edit is retained. The dirty `docs` submodule is unchanged and excluded
from the parent commit.
