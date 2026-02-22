# CrosshairsPlus

**Version:** 1.5.0 | **Interface:** 120000 (The War Within / Midnight) | **Author:** asp1d

A World of Warcraft addon that displays a customizable crosshair overlay on your target's nameplate. Great for PvP targeting and raid awareness.

## Features

- Attaches to target's nameplate in real-time
- 73 arrow styles with optional rotation animation
- 6 circle crosshair styles with glow and shadow effects
- Range display using LibRangeCheck-3.0 (LoadOnDemand sub-addon)
- Target info display (name or name + level)
- LibSharedMedia font integration for text elements
- Target filtering (enemy/friendly players, hostile/friendly NPCs, critters)
- Class-based automatic coloring with color-match text options
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
./build.sh  # creates build/CrosshairsPlus_1.5.0_YYYY-MM-DD.zip
```

The build includes both `CrosshairsPlus/` and `CrosshairsPlus_Range/` in the ZIP.

**Project structure:** Crosshair modules live in `CrosshairsPlus/Crosshair/` (11 files) and settings tabs in `CrosshairsPlus/Settings/` (9 files). See `CLAUDE.md` for full architecture reference.

**Useful Console Commands:**

| Command | Description |
|---------|-------------|
| `/console scriptErrors 1` | Show Lua errors in-game |
| `/console taintLog 2` | Enable taint logging |
| `/framestack` | Show frame hierarchy under cursor |

## Credits

**Author:** asp1d | **License:** All Rights Reserved

**Special Thanks:**
- **ElvUI** - Arrow icon textures
- **Mesostealthy** - weizPvP inspiration
- **semlar** - Crosshairs addon inspiration

## Changelog

### 1.5.0 (2026-02-20)
- Modular architecture refactor (11 Crosshair modules, 9 Settings modules, 7 settings tabs)
- Circle crosshair system: 6 styles with glow/shadow effects and size adjustment
- Range display via LoadOnDemand sub-addon (LibRangeCheck-3.0)
- Target info display (name or name + level)
- LibSharedMedia-3.0 font integration, frame strata control, text anchoring with offsets

### 1.0.2 (2025-02-17)
- Midnight compatibility (Interface 12.0), Action Targeting support, addon icon, settings cleanup

### 1.0.0 (2025-02-10)
- Initial release with 73 arrow styles, class coloring, target filtering, rotation animation, crosshair lines
