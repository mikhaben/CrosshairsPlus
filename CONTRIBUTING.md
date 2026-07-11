# Contributing to CrosshairsPlus

Thanks for your interest! Bug reports, feature requests, and pull requests are all welcome. This repo is maintained by a single maintainer — contributions land via fork-and-PR, and releases are cut by the maintainer only.

## Building locally

No toolchain needed beyond bash and zip.

```bash
./build.sh
```

creates a versioned zip in `build/` containing both `CrosshairsPlus/` and `CrosshairsPlus_Range/` (same layout the release pipeline ships).

To install straight into your WoW folder while developing:

```bash
cp .env.example .env   # then set WOW_ADDONS_DIR to your AddOns path
./deploy-local.sh
```

`.env` is gitignored — never commit your local path.

## Testing

There is no automated test suite; testing is in-game:

1. `./deploy-local.sh`, then `/reload` in WoW (or restart the client).
2. `/chp` opens the settings panel — exercise the flow your change touches.
3. `/chp preview` shows the crosshair at screen center without needing a target — useful for visual changes.
4. `/chp debug` toggles debug logging (events, color changes, attach/detach).
5. `/chp test` prints a full diagnostics dump (runtime state, settings, CVars, warnings) — include relevant output in your PR if it helps demonstrate the fix.

## Coding style

Match the surrounding code. In particular:

- 4-space indentation, Lua, every file starts with `local AddonName, CPlusNS = ...` and reads/writes shared state via `CPlusNS.state`, `CPlusNS.db`, `CPlusNS.CONST`.
- Persisted settings go in `CPlusNS.defaults` (Core.lua); new settings must be added there so `MergeDefaults` handles upgrades. Runtime-only state goes in `CPlusNS.state` and is never persisted.
- Settings widgets are built with AceConfig/AceGUI (see `Settings/*.lua`); every widget's `set` function should call `CPlusNS.UpdateCrosshairVisuals()` to refresh visuals.
- Avoid per-frame allocations in `Crosshair/OnUpdate.lua` — cache math functions and reused variables to locals, and follow the existing change-detection pattern (e.g. `state.lastUnit*`, `state.lastRangeVal`) instead of recomputing every frame.
- Use `CPlusNS.Debug(msg)` / `CPlusNS.Debugf(fmt, ...)` for debug output, gated by `CPlusNS.db.debugMode` — don't add raw `print()` calls.

## Pull requests

- Keep PRs small and focused — one fix or feature per PR.
- For anything non-trivial, open an issue first to discuss the approach before writing code.
- Describe what you changed, why, and how you tested it in-game.

Releases (version bumps, tags, CurseForge/Wago uploads) are handled by the maintainer — PRs should not touch `## Version` in the TOC or add `release-notes/` files.
