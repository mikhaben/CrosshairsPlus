# CrosshairsPlus

## North star

A World of Warcraft addon that draws a customizable crosshair (circle, lines, arrows, range and
target info) on the current target's nameplate, so the player always sees which enemy they are
hitting. It stays light enough to run every frame in combat.

## Commands

- `./check.sh` — must pass before a commit. It runs `luacheck .` (config in `.luacheckrc`: a new
  WoW API the addon reads goes in `read_globals`, a global it writes goes in `globals`), the
  no-comments rule (`ast-grep scan`, rule in `lint-rules/`) and the 1000-line cap per Lua file.
  Needs `brew install luacheck ast-grep`. Vendored `Libs/` are excluded.
- `./build.sh` — versioned zip in `build/` with both addon folders.
- `./deploy-local.sh` — build and install into the local AddOns folder (`WOW_ADDONS_DIR` in the
  gitignored `.env`, template `.env.example`).
- In game: `/chp` opens settings, `/chp preview` shows the crosshair at screen center without a
  target, `/chp debug` toggles debug logging, `/chp test` prints a diagnostics dump. There is no
  automated test suite; changes are checked in game after `/reload`.

## Layout

Two addons ship in one zip. `CrosshairsPlus/` is the main addon; its load order is the file list in
`CrosshairsPlus/CrosshairsPlus.toc`, and each file may call only what earlier files defined at load
time. `CrosshairsPlus_Range/` is a LoadOnDemand sub-addon holding LibRangeCheck-3.0; `.pkgmeta`
uses `move-folders` to put both at the zip's top level.

| Feature | Where |
| --- | --- |
| Defaults, DB merge, events, slash commands | `CrosshairsPlus/Core.lua` |
| The crosshair frame and its textures (`CrosshairsPlusFrame`) | `CrosshairsPlus/Crosshair.xml` |
| Runtime state, `CONST`, library references, font and anchor helpers | `Crosshair/State.lua` |
| Which unit to follow, whether to show, unit color, nameplate CVar warnings | `Crosshair/UnitLogic.lua` |
| Attaching to a nameplate, color application, `RefreshActiveUnit` | `Crosshair/Attach.lua` |
| Per-frame updates | `Crosshair/OnUpdate.lua` |
| Circle, lines, arrows, range text, target info | `Crosshair/Circle.lua`, `Lines.lua`, `Arrows.lua`, `Range.lua`, `TargetInfo.lua` |
| Startup and target/nameplate event handlers | `Crosshair/Init.lua` |
| Debug log and `/chp test` | `Crosshair/Debug.lua` |
| Settings panel (AceConfig tabs) | `CrosshairsPlus/Settings/` |
| Packaging and upload | `.github/workflows/release.yml`, `.pkgmeta` |
| Converting new textures | `CONVERT.md` |

## Namespace

Every file starts with `local _, CPlusNS = ...` (`AddonName` in place of `_` where the file uses
it). Hot modules cache `CPlusNS.state` and `CPlusNS.CONST` in locals.

| Key | Purpose |
| --- | --- |
| `CPlusNS.defaults` | Default settings, used for merge and reset (Core.lua) |
| `CPlusNS.db` | Live settings, `CrosshairsPlusDB` after `PLAYER_LOGIN` |
| `CPlusNS.state` | Runtime state, never persisted |
| `CPlusNS.CONST` | Read-only constants |
| `CPlusNS.LSM` | LibSharedMedia-3.0 |
| `CPlusNS.RC` | LibRangeCheck-3.0, `nil` until Range.lua loads the sub-addon |
| `CPlusNS.EventFrame` | The event frame; handlers are `function CPlusNS:EVENT_NAME(...)` |

Globals: `_G.CrosshairsPlus` (the namespace), `CrosshairsPlusFrame` (from Crosshair.xml) and
`CrosshairsPlusDB`.

## Rules

- A new persisted setting goes in `CPlusNS.defaults`, so `MergeDefaults` adds it to old saves.
  Runtime-only values go in `CPlusNS.state`.
- Every settings widget's `set` calls `CPlusNS.UpdateCrosshairVisuals()`, the one entry point that
  refreshes visuals.
- Debug output goes through `CPlusNS.Debug` / `CPlusNS.Debugf`, gated by `CPlusNS.db.debugMode`;
  no raw `print()`.
- Per-frame code allocates nothing: math functions and scratch variables are file-local, rotation
  settings are cached in `state.cached*` and refreshed on settings change, and color and range
  updates compare against `state.last*` before touching a texture. The four-arrow rotation in
  `UpdateArrowRotation` is unrolled on purpose; keep it unrolled. Color, range and target info
  update every `CONST.UPDATE_INTERVAL`, not every frame.
- OnUpdate only recolors. Showing and hiding the crosshair belongs to the event handlers.
- `Crosshair/Debug.lua` loads before `UnitLogic.lua`, so it checks hostility inline instead of
  calling `UnitLogic`'s helpers.
- A new texture follows `CONVERT.md`, goes in `CrosshairsPlus/Assets/`, and is added to the style
  dropdown's `values` in its Settings tab; README.md and MARKETING.md state the style counts.

## Targeting and nameplate behavior

- The hard target always wins over the soft enemy (action targeting).
- `AttachToNameplate` re-checks that the nameplate belongs to the active unit, and never parents to
  a forbidden nameplate (instances, protected frames); it hides the crosshair instead. Lookups pass
  `includeForbidden` so instance nameplates are found.
- In melee range nameplates are removed and re-added rapidly. An add that follows a removal within
  `RAPID_THRESHOLD` is debounced; otherwise the crosshair attaches at once.
- After attaching, the color is applied after the frame is shown, so a target switch recolors
  immediately.
- Colors: a target tapped by another player is gray. A neutral mob stays reaction 4 after you
  attack it, so threat on it switches the color to hostile red.
- Since 12.1.x, `UnitClass` returns secret values for units whose identity is restricted, and a
  secret value cannot be a table key; class color checks `issecretvalue` first and falls back to
  reaction color.
- Range: `Range.lua` checks `C_AddOns.GetAddOnEnableState`, loads `CrosshairsPlus_Range` on first
  use and caches `CPlusNS.RC`. If the sub-addon is missing or disabled, range display turns off.

## Releasing

The flow is in the header of `.github/workflows/release.yml`. A GitHub ruleset on `main` requires
a pull request (work lands on `develop`, then a `develop` → `main` PR) and restricts `v*` tags to
admins. Pushing a `v*` tag publishes to CurseForge, Wago and GitHub Releases, so never push one
unless asked. Deploy needs both `CF_API_KEY` and `WAGO_API_KEY`.
