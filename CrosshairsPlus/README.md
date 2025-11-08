# CrosshairsPlus

**Version:** 1.0.0
**Interface:** 110002 (The War Within)

Enhanced crosshair addon for World of Warcraft with extensive customization options and target filtering.

## Features

### Target Filtering
- ✅ Enemy Players - Show crosshair on hostile players (PvP)
- ✅ Friendly Players - Show crosshair on friendly players
- ✅ Hostile NPCs - Show crosshair on hostile creatures
- ✅ Friendly NPCs - Show crosshair on friendly creatures
- ✅ Critters - Show crosshair on trivial targets

### Visual Customization
- **Range Display** - Shows accurate distance to target using LibRangeCheck
- **Target Name** - Displays the target's name above the crosshair
- **Class Coloring** - Automatically colors player targets by class
- **Directional Lines** - Customizable crosshair lines with adjustable thickness (1-10px)
- **Multiple Styles** - Choose from rotating arrows, static cross, circle only, or minimal
- **Scale & Opacity** - Adjust size (0.5-2.0x) and transparency (0-100%)

### Visual Effects
- Smooth fade in/out animations
- Rotating arrow animation
- Scale pulse on target acquisition
- Dynamic nameplate attachment
- Additive blending for enhanced visibility

## Installation

1. Extract the `CrosshairsPlus` folder to your WoW AddOns directory:
   - Windows: `World of Warcraft\_retail_\Interface\AddOns\`
   - macOS: `World of Warcraft/_retail_/Interface/AddOns/`

2. Restart WoW or type `/reload` if already in-game

3. Open settings with `/crosshairsplus` or `/chp`

## Usage

### Commands
- `/crosshairsplus` or `/chp` - Open settings panel

### Settings Location
**ESC → Interface → AddOns → CrosshairsPlus**

### Quick Setup

**For PvP Players:**
- ✅ Enable "Enemy Players"
- ✅ Enable "Hostile NPCs"
- ✅ Enable "Range Display"
- ✅ Enable "Class Coloring"

**For PvE Players:**
- ✅ Enable "Hostile NPCs"
- ✅ Enable "Range Display"
- ✅ Disable "Enemy Players" (optional)

**For Everything:**
- ✅ Enable all target types

## Technical Details

### Architecture
- **Core.lua** - Namespace initialization, event handling, database management
- **Crosshair.xml** - Frame structure, textures, layers, and animations (declarative UI)
- **Crosshair.lua** - Target filtering, rendering logic, attachment system
- **Settings.lua** - Configuration panel using modern Settings API
- **Utils.lua** - Helper functions and utilities

### Dependencies
- **LibRangeCheck-3.0** (embedded) - Accurate range calculation

### API Usage
- Modern WoW Retail API (11.0.2+)
- `C_NamePlate.GetNamePlateForUnit()` - Nameplate attachment
- `Settings.RegisterCanvasLayoutCategory()` - Settings integration
- `LibRangeCheck` - Range detection
- `RAID_CLASS_COLORS` - Class-based coloring
- Animation system - Smooth transitions

### Performance
- Event-driven architecture (no constant polling except for range updates)
- Efficient texture management with XML declaration
- Local variable caching
- 0.1s update interval for range display
- Minimal memory footprint

## Customization

### Line Thickness
Adjust from 1-10 pixels for visibility preferences. Uses `PixelUtil.SetWidth()` for pixel-perfect rendering.

### Scale
Change crosshair size from 0.5x (small) to 2.0x (large).

### Alpha
Set transparency from 0% (invisible) to 100% (opaque).

### Arrow Styles
- **Rotating Arrows** (default) - Animated spinning arrows
- **Static Cross** - Fixed crosshair lines
- **Circle Only** - Just the core circle
- **Minimal** - Bare minimum visual

## Color System

### Players
- **Class Colors** - Warrior (tan), Mage (cyan), Rogue (yellow), etc.
- **Tapped Units** - Gray for units tagged by others
- **Friendly** - Green (if class coloring disabled)

### NPCs
- **Hostile** - Red
- **Friendly** - Green
- **Tapped** - Gray

## Troubleshooting

### Crosshair not showing
1. Check target filter settings - at least one must be enabled
2. Verify target has a nameplate visible (enable nameplates: V key)
3. Ensure addon is loaded: `/reload`

### Range not displaying
1. Check "Show Range Display" is enabled
2. LibRangeCheck requires valid range-checking spells/items
3. Some targets may not return accurate range

### Settings panel not opening
1. Try: `/reload` and then `/crosshairsplus`
2. Check for addon conflicts
3. Verify TOC file is correct for your WoW version

## Credits

**Inspiration:**
- **weizPVP** - Visual style, frame structure, LibRangeCheck integration
- **Crosshairs (Semlar)** - Universal target filtering approach

**Libraries:**
- LibRangeCheck-3.0 - By the WoW addon community

**Author:** asp1d
**Version:** 1.0.0
**License:** All Rights Reserved

## Changelog

### Version 1.0.0 (2025-11-08)
- Initial release
- Full target filtering system
- LibRangeCheck integration
- Modern Settings API integration
- XML-based frame structure
- Customizable visual options
- Class-based coloring
- Range and name display
- Multiple animation styles

## Future Enhancements

Planned for future versions:
- Custom color picker for crosshair tinting
- Animation speed controls
- Multiple saved profiles
- Import/export settings strings
- Additional arrow texture packs
- Sound effects on target acquisition
- Account-wide settings option
- Minimap button (optional)

## Support

For bugs, feature requests, or questions:
- GitHub: [Your Repository URL]
- Discord: [Your Discord]
- CurseForge: [Your CurseForge Page]

## Contributing

This addon combines the best features of weizPVP's Crosshair and Semlar's Crosshairs. Contributions and suggestions are welcome!
