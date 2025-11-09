# CrosshairsPlus

**Version:** 1.0.0
**Interface:** 110002 (The War Within)
**Author:** asp1d

A World of Warcraft addon that displays a customizable crosshair overlay on enemy and friendly targets. Perfect for PvP targeting, raid awareness, or general gameplay enhancement.

## What is CrosshairsPlus?

CrosshairsPlus is an enhanced crosshair addon that attaches a visual marker to your current target's nameplate. It provides extensive customization options including multiple visual styles, target filtering, animated arrows, and class-based coloring. The crosshair follows your target's position on screen, making it easier to track enemies in PvP or important targets in PvE content.

---

## For Developers / Debugging

**Quick Start for Development:**
1. Enable error logging: `/console scriptErrors 1`
2. Enable debug mode: `/chp debug`
3. Reload addon: `/reload`

**Debug Commands:**
- `/chp debug` - Toggle verbose logging for crosshair events
- `/chp test` - Show diagnostic info (frame state, target, settings)
- `/chp show` - Force crosshair to screen center (testing)
- `/chp rotate` - Display rotation diagnostics
- `/chp hide` - Hide crosshair

**Useful Console Commands:**
- `/console scriptErrors 1` - Show Lua errors in-game
- `/console taintLog 2` - Enable taint logging
- `/framestack` - Show frame hierarchy under cursor

See **[Development](#development)** section at bottom for full setup details.

---

## Features

### Core Functionality
- **Dynamic Nameplate Attachment** - Crosshair follows target's nameplate position in real-time
- **Target Filtering** - Control which unit types show the crosshair (enemy players, hostile NPCs, friendly units, etc.)
- **Smooth Animations** - Fade in/out transitions and optional rotating arrow effects
- **Class-Based Coloring** - Automatically colors crosshair based on target's class (Warriors = tan, Mages = cyan, etc.)

### Visual Customization
- **Multiple Arrow Styles** - 73+ arrow texture options to choose from
- **Circle Options** - Default solid circle or customize with different styles
- **Crosshair Lines** - Adjustable thickness (1-10px) and configurable start position (from center to edge)
- **Scale Control** - Resize from 0.5x to 2.0x (default: 0.8x)
- **Opacity Control** - Adjust transparency from 0% to 100% (default: 60%)
- **Arrow Distance** - Control how far arrows appear from center (default: 74px)
- **Arrow Size** - Customize arrow dimensions (default: 24px)
- **Rotating Animation** - Optional clockwise/counter-clockwise rotation with speed control

### Target Filtering Options
- Enemy Players (PvP targets)
- Friendly Players
- Hostile NPCs
- Friendly NPCs
- Critters and trivial targets

## Installation

1. Download or clone this repository
2. Copy the entire `CrosshairsPlus` folder to your WoW AddOns directory:
   - **Windows:** `World of Warcraft\_retail_\Interface\AddOns\CrosshairsPlus\`
   - **macOS:** `World of Warcraft/_retail_/Interface/AddOns/CrosshairsPlus/`
3. Restart World of Warcraft or type `/reload` in-game
4. Configure settings with `/crosshairsplus` or `/chp`

### Settings Location
**ESC → Interface → AddOns → CrosshairsPlus**

The settings panel has four sections:
- **General** - Target filters, visual options, scale and opacity
- **Circle Options** - Circle style selection
- **Crosshair Lines** - Line visibility, thickness, and start position
- **Arrow Settings** - Arrow style, distance, size, and rotation options

### Quick Setup Examples

**PvP Configuration:**
```
✅ Enemy Players
✅ Hostile NPCs
✅ Class Coloring
✅ Rotating Arrows
```

**PvE Configuration:**
```
✅ Hostile NPCs
❌ Enemy Players (optional)
✅ Show Lines
```

**Everything Visible:**
```
✅ All target types enabled
```

## Project Structure

```
CrosshairsPlus/
├── CrosshairsPlus.toc       # Addon manifest and file load order
├── Core.lua                 # Namespace initialization, database, event handling
├── Utils.lua                # Helper functions and utilities
├── Crosshair.xml            # Frame structure, texture layers, animations (declarative UI)
├── Crosshair.lua            # Target filtering, rendering logic, nameplate attachment
├── Settings.lua             # Configuration UI using modern Settings API
├── Assets/                  # Texture files
│   ├── Arrow0.tga - Arrow72.tga  # 73 arrow style options
│   ├── ArrowRed.tga         # Red arrow variant
│   ├── circle.blp           # Circle texture
│   ├── core.tga             # Core center texture
│   ├── shadow.tga           # Shadow effect
│   ├── alert.tga            # Alert indicator
│   ├── net5000.tga          # Net pattern texture
│   └── ringSolid_outerGlow.tga  # Glowing ring effect
└── README.md                # This file
```

### File Descriptions

**CrosshairsPlus.toc**
- Defines addon metadata (version, interface version, author)
- Specifies load order for Lua files
- Declares saved variables (CrosshairsPlusDB)

**Core.lua**
- Creates addon namespace (`CrosshairsPlus`)
- Initializes database with default settings
- Handles PLAYER_LOGIN and PLAYER_ENTERING_WORLD events
- Registers slash commands
- Manages addon lifecycle

**Utils.lua**
- Contains reusable helper functions
- Utility functions for common operations
- Shared code used across multiple files

**Crosshair.xml**
- Defines frame hierarchy in XML format
- Declares texture layers (core circle, arrows, lines, shadows)
- Sets up animation groups for smooth transitions
- Establishes frame anchoring and positioning

**Crosshair.lua** (Core Logic)
- Target filtering logic (ShouldShowCrosshair function)
- Nameplate attachment system using C_NamePlate API
- Color management (class colors, hostile/friendly colors)
- Visual updates (UpdateCrosshairVisuals, UpdateArrows, UpdateLines)
- Arrow rotation animation with OnUpdate handler
- Line positioning based on configurable gap from center

**Settings.lua** (UI Configuration)
- Creates settings panels using modern WoW Settings API
- Implements checkbox controls for filters and visual options
- Slider controls for numeric values (scale, opacity, thickness, etc.)
- Dropdown menus for style selection
- Reset buttons for default values
- Nested submenu structure (General/Circle/Lines/Arrows)

**Assets/**
- All texture files (.tga and .blp formats)
- 73 different arrow styles numbered 0-72
- Circle, core, shadow, and effect textures
- Referenced by XML and Lua code via relative paths

## Technical Details

### Architecture
- **Event-Driven Design** - Responds to WoW events (target changes, nameplate updates, zone transitions)
- **Namespace Pattern** - All code contained in `CrosshairsPlus` namespace to avoid conflicts
- **Saved Variables** - Settings persisted in `CrosshairsPlusDB` table
- **XML + Lua Hybrid** - Frame structure in XML, logic in Lua

### WoW API Usage
- `C_NamePlate.GetNamePlateForUnit()` - Attaches crosshair to target's nameplate
- `Settings.RegisterCanvasLayoutCategory()` - Modern settings panel registration
- `Settings.RegisterCanvasLayoutSubcategory()` - Submenu creation
- `UnitIsPlayer()` / `UnitReaction()` - Target classification
- `UnitClass()` - Class detection for coloring
- `RAID_CLASS_COLORS` - Built-in class color table
- `CreateFrame()` - Dynamic UI element creation for settings
- Animation API - Smooth fade in/out effects

### Default Settings

```lua
-- Target Filters
showEnemyPlayers = true
showFriendlyPlayers = false
showHostileNPCs = true
showFriendlyNPCs = false

-- Visual Options
enableClassColors = true
showLines = true

-- Style Settings
arrowStyle = "arrow0"
circleStyle = "default"
lineThickness = 2
lineStartGap = 0         -- Lines start at circle edge
crosshairScale = 0.8     -- 80% size
crosshairAlpha = 0.6     -- 60% opacity

-- Arrow Settings
arrowDistance = 74       -- 74px from center
arrowSize = 24          -- 24px dimensions
arrowsRotate = true
arrowsRotateCounterClockwise = false
arrowRotationSpeed = 5.0
```

### Performance Considerations
- **Event-driven architecture** - No constant OnUpdate polling except for rotation animation
- **Local variable caching** - Frame and config references cached for fast access
- **Efficient texture management** - Textures declared in XML, loaded once
- **Minimal memory footprint** - Lightweight code with no external dependencies
- **Conditional updates** - Only updates when target changes or settings modified

## Customization Guide

### Changing Arrow Styles
1. Open settings → Arrow Settings
2. Select from dropdown (arrow0 through arrow72)
3. Each style has unique visual appearance
4. Preview appears immediately on your current target

### Adjusting Line Position
1. Open settings → Crosshair Lines
2. Use "Line Start Position" slider
3. Negative values: lines move toward center
4. Positive values: lines extend outward from edge
5. Default (0): lines start at circle edge

### Creating Custom Arrow Textures
1. Create a 64x64 TGA file (power-of-2 dimensions recommended)
2. Name it `Arrow73.tga` (next available number)
3. Place in `Assets/` folder
4. Add entry to Settings.lua dropdown options
5. Arrow should point upward in source image (addon handles rotation)

### Color Customization
Currently uses WoW's built-in class colors. To customize:
- Edit `Crosshair.lua` color tables
- Modify `RAID_CLASS_COLORS` references
- Add custom RGB values for specific unit types

## Troubleshooting

### Crosshair Not Appearing
1. ✅ Check target filter settings - at least one must be enabled
2. ✅ Verify target has a visible nameplate (press V to toggle nameplates)
3. ✅ Ensure addon is loaded: `/reload`
4. ✅ Check opacity isn't set to 0%
5. ✅ Try `/chp show` to force display at screen center

### Crosshair Position Incorrect
1. Nameplate position may be affected by other addons
2. Try disabling nameplate addons temporarily
3. Check scale settings (too large may appear off-screen)

### Settings Panel Not Opening
1. `/reload` and try again
2. Check for Lua errors: `/console scriptErrors 1`
3. Verify TOC interface version matches your WoW client

### Arrows Not Rotating
1. Check "Enable Arrow Rotation" is enabled
2. Verify rotation speed is greater than 0
3. Use `/chp rotate` to see diagnostics
4. Some arrow styles may not show rotation clearly

### Performance Issues
1. Disable arrow rotation if experiencing FPS drops
2. Reduce crosshair scale
3. Check for conflicts with other nameplate addons

## Development

### Setting Up Development Environment
1. Clone repository to AddOns folder
2. Enable script errors: `/console scriptErrors 1`
3. Enable taint logging: `/console taintLog 2`
4. Use `/reload` frequently during testing

### Adding New Features
The modular structure makes it easy to extend:
- **New filters:** Add to `ShouldShowCrosshair()` in Crosshair.lua
- **New visuals:** Add textures to Assets/ and reference in Crosshair.xml
- **New settings:** Add controls in Settings.lua, defaults in Core.lua

### Debug Commands
```
/chp debug     # Toggle debug mode for verbose event logging
/chp test      # Show frame state, target info, settings
/chp show      # Force show at screen center (testing)
/chp hide      # Hide crosshair
/chp rotate    # Rotation diagnostics
```

## Credits

**Inspiration & Reference:**
- **weizPVP Crosshair** - Visual style, frame structure, and crosshair concept
- **Semlar's Crosshairs** - Universal target filtering approach

**Author:** asp1d
**License:** All Rights Reserved
**Version:** 1.0.0 (2025-11-08)

## Changelog

### Version 1.0.0 (2025-11-08)
- Initial release
- Complete target filtering system (players, NPCs, critters)
- 73+ arrow style options with rotation animation
- Customizable crosshair lines with adjustable start position
- Circle style options
- Modern Settings API integration with nested submenus
- Class-based automatic coloring
- Scale and opacity controls
- Arrow distance and size customization
- Smooth fade animations
- Nameplate attachment system
- Slash command interface

## Future Enhancements

Potential features for future versions:
- Custom color picker for manual color override
- Multiple saved profiles with quick switching
- Import/export settings strings
- Additional texture packs
- Sound effects on target acquisition
- Account-wide settings synchronization
- Mouseover target support
- Focus target crosshair option
- Range-based opacity (fade at max range)

## Support

For questions, bug reports, or feature requests, please use the appropriate platform for your installation method.

## Contributing

This addon combines elements from weizPVP's Crosshair and Semlar's Crosshairs. If you'd like to contribute improvements or report issues, standard addon development practices apply.
