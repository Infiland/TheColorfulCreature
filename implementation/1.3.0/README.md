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

## Large-level performance follow-up

The timing registry now reuses successful registration checks within each
engine frame and room generation. Drawing restores only the instances actually
interpolated, and empty pending queues avoid allocation. Input handling skips
clearing unused keyboard latches and repeatedly absent controller slots. Native
motion, alarm ownership, simulation frequency and gameplay rules are unchanged.

The opt-in QA profiler measures native event wall-work spans and bookkeeping
counts. `tools/performance_qa.py` binds the build, source, inputs and native output,
then compares exact recorded gameplay states with only declared run/clock fields
excluded. It also accepts explicitly unprofiled gameplay comparisons.

Four profiled workloads (Lunar Base, dense level 54, troop level 94 and level 1)
match across all 2,100 recorded ticks per build. Lunar's registration checks fell
from 5,828 to 3,114 per frame; median Draw restoration fell from 3.32 ms to 0.26 ms.
The host was heavily loaded, so observed FPS changes do not establish sustained
high-FPS performance on players' devices. Full inputs, logs and frozen builds
remain outside the checkout.

The two unprofiled before/after pairs and the profiler-on/off comparison retain
identical gameplay states. Alternating Lunar repeats do not establish a reliable
overall FPS gain. Four camera checks and their cross-cap comparison pass; all
three player/HUD/one-way animation checks pass with render-only coverage. Five
native timing trials pass individual state checks. Their combined lifecycle
acceptance remains unmet because reactivation never landed on a render-only
frame; the original failed comparisons are retained, not relabeled as passes.
`evidence/performance-2026-10-03.json` binds these observations and their scope.

The camera verifier accepts the exact QA-only profiling marker before its existing
60 Hz early return. Independent mutation checks still reject changes to the guard,
threshold, camera interpolation and restoration contracts.

## Mobile layout follow-up — 2026-10-07

Larger mobile menus, paginated settings and wider audio controls address Apple's
Guideline 4 feedback. Adjustable touch controls leave gameplay space clear, HUD
and Return labels no longer overlap, and touch/background pause restores controls
consistently. Existing button-size preferences survive save migration.

iOS 1.3.0 (7) is **Waiting for Review** for both App Store production and the
existing external TestFlight group, with automatic release/notification after
approval. Signed archive, profile, privacy configuration and matching symbols
passed validation. Final-source diagnostic runs on iPhone SE and iPad Pro 13-inch
(iOS 18.5) each passed all 26 stages. These are simulator checks, not physical-device
or live-service validation.

Android 1.3.0 (1003002) passed signed-bundle, three-ABI, 64-bit 16 KB and embedded
native-symbol checks. Its diagnostic derivative passed 26 stages; one main-menu
capture obscured by a System UI dialog is excluded. An APK derived from the exact
production bundle passed a separate 120-second offline startup check with an
unobstructed main menu. Google Play upload is awaiting manual file-picker
assistance; 1003002 has not been submitted and existing 1003001 remains live.

`evidence/mobile-release-2026-10-07.json` records exact source/artifact identities,
store states and limitations. Raw builds, captures and the reviewed eight-page
PDF remain outside Git. The optional PDF was not attached to Apple because the
browser picker did not accept it; detailed review notes were submitted.

## Release gates

- Signed mobile exports and store submissions are recorded in the dated release
  evidence. Physical devices/controllers and live Steam, Workshop, Google Play
  and Game Center services still require release checks.
- iPhone/iPad iOS 18.5 simulator smoke checks passed on their recorded builds.
  The iOS 26.5 simulator aborted in allocator/LLVM/OpenGL runtime frames before
  GML startup; its cause and physical-device compatibility remain unverified.
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
