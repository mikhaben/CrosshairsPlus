# CrosshairsPlus

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CurseForge](https://img.shields.io/badge/CurseForge-Download-F16436?logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/crosshairsplus)
[![Wago](https://img.shields.io/badge/Wago-Download-A34FE0)](https://addons.wago.io/addons/crosshairsplus)

**Interface:** 120007 (The War Within / Midnight) | **Author:** justLuther

A World of Warcraft addon that displays a customizable crosshair overlay on your target's nameplate. Great for PvP targeting and raid awareness.

## Features

- Attaches to target's nameplate in real-time
- 73 arrow styles with optional rotation animation
- 6 circle crosshair styles with glow and shadow effects
- Range display using LibRangeCheck-3.0 (LoadOnDemand sub-addon)
- Target info display (name or name + level)
- LibSharedMedia font integration for text elements
- Target filtering (enemy/friendly players, hostile/friendly NPCs, critters)
- Color mode selection: Reaction, Class, or Custom colors for enemy/friendly targets
- Action Targeting support (soft enemy targets)
- Frame strata control (rendering layer selection)
- Customizable lines, scale, opacity, arrow distance and size
- Smooth fade animations
- Modular architecture (11 Crosshair modules, 9 Settings modules)

## Installation

1. Download the latest release ZIP
2. Extract **both** `CrosshairsPlus` and `CrosshairsPlus_Range` into your WoW AddOns directory:
   - **Windows:** `World of Warcraft\_retail_\Interface\AddOns\`
   - **macOS:** `World of Warcraft/_retail_/Interface/AddOns/`
3. `/reload` in-game

> **Note:** `CrosshairsPlus_Range` is an optional LoadOnDemand sub-addon that provides range display via LibRangeCheck-3.0. The main addon works without it, but the Range tab and range numbers will not be available.

**Settings:** ESC > Interface > AddOns > CrosshairsPlus

## Commands

| Command | Description |
|---------|-------------|
| `/chp` or `/crosshairsplus` | Open settings |
| `/chp debug` | Toggle debug logging |
| `/chp test` | Show diagnostic info |
| `/chp preview` | Toggle crosshair at screen center |

## Development

```bash
git clone <repo>
./build.sh  # creates build/CrosshairsPlus_VERSION_YYYY-MM-DD.zip
```

The build includes both `CrosshairsPlus/` and `CrosshairsPlus_Range/` in the ZIP.

**Project structure:** Crosshair modules live in `CrosshairsPlus/Crosshair/` (11 files) and settings tabs in `CrosshairsPlus/Settings/` (9 files). See `CLAUDE.md` for full architecture reference.

**Useful Console Commands:**

| Command | Description |
|---------|-------------|
| `/console scriptErrors 1` | Show Lua errors in-game |
| `/console taintLog 2` | Enable taint logging |
| `/framestack` | Show frame hierarchy under cursor |

## Releasing

Releases are published automatically by GitHub Actions (`.github/workflows/release.yml`)
when you push a version tag, using the [BigWigsMods packager](https://github.com/BigWigsMods/packager).

1. Bump `## Version` in `CrosshairsPlus/CrosshairsPlus.toc` and add `release-notes/<version>.md`
   (this becomes the changelog shown on CurseForge/Wago).
2. Land the bump on `main` via pull request (direct pushes to `main` are blocked),
   then `git tag vX.Y.Z && git push origin vX.Y.Z` — only tags on `main` are published.
3. The workflow packages both `CrosshairsPlus/` and `CrosshairsPlus_Range/` and uploads to
   CurseForge, Wago, and GitHub Releases.

Requires the `CF_API_KEY` and `WAGO_API_KEY` repo secrets (both, or the upload is skipped).
`build.sh` remains for manual local packaging.

## Credits

**Author:** justLuther

**Special Thanks:**
- **ElvUI** - Arrow icon textures
- **Mesostealthy** - weizPvP inspiration
- **semlar** - Crosshairs addon inspiration

See the [`release-notes/`](release-notes/) folder for per-version changelogs.

## Contributing

Found a bug or have a feature request? Open an issue or submit a pull request — see [CONTRIBUTING.md](CONTRIBUTING.md) for how to build, test, and what to expect in review.

## License

CrosshairsPlus is released under the [MIT License](LICENSE).
