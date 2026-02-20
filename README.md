# CrosshairsPlus

**Version:** 1.0.2 | **Interface:** 120000 (The War Within) | **Author:** asp1d

A World of Warcraft addon that displays a customizable crosshair overlay on your target's nameplate. Great for PvP targeting and raid awareness.

## Features

- Attaches to target's nameplate in real-time
- 73+ arrow styles with optional rotation animation
- Target filtering (enemy/friendly players, hostile/friendly NPCs, critters)
- Class-based automatic coloring
- Customizable lines, circle styles, scale, opacity, arrow distance and size
- Smooth fade animations

## Installation

1. Download the latest release ZIP
2. Extract `CrosshairsPlus` into your WoW AddOns directory:
   - **Windows:** `World of Warcraft\_retail_\Interface\AddOns\`
   - **macOS:** `World of Warcraft/_retail_/Interface/AddOns/`
3. `/reload` in-game

**Settings:** ESC > Interface > AddOns > CrosshairsPlus

## Commands

| Command | Description |
|---------|-------------|
| `/chp` or `/crosshairsplus` | Open settings |
| `/chp debug` | Toggle debug logging |
| `/chp test` | Show diagnostic info |
| `/chp show` | Force crosshair to screen center |
| `/chp hide` | Hide crosshair |

## Development

```bash
git clone <repo>
./build.sh  # creates build/CrosshairsPlus-1.0.2.zip
```

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

### 1.0.2 (2025-11-08)
- Initial release with full target filtering, 73+ arrow styles, rotation animation, crosshair lines, circle styles, class coloring, and modern Settings API integration
