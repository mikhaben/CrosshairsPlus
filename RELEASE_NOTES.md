# CrosshairsPlus - Release Notes

## [1.5.0] - 2026-02-20

### Modular Architecture & Circle System

Major refactor into a modular codebase with new circle crosshairs, range display, and target info.

**Architecture**
- Refactored into modular architecture: 11 Crosshair modules, 9 Settings modules
- .git moved to project root (above addon folder) for cleaner repo structure
- Settings panel reorganized into 7 tabbed categories (General, Circle, Lines, Arrows, Range, Target Info, About)

**Added**
- Circle crosshair system with 6 styles (Circle0-Circle5) and glow/shadow effects
- Circle size adjustment (dynamic sizing based on nameplate width + user offset)
- Range display via LoadOnDemand sub-addon (CrosshairsPlus_Range) using LibRangeCheck-3.0
- Target info display (name or name + level) with configurable position
- LibSharedMedia-3.0 font integration for range and target info text
- Frame strata control (rendering layer selection)
- Text anchoring with X/Y offsets for range and target info positioning
- Color-match option for range and target info text (inherits target color)

**Changed**
- New circle textures replace old ring/shadow assets
- Updated build.sh output format: `CrosshairsPlus_VERSION_DATE.zip` (includes CrosshairsPlus_Range)
- Settings tabs: General, Circle, Lines, Arrows, Range, Target Info, About

---

## [1.0.2] - 2025-02-17

### Ready for Midnight

**Now compatible with Midnight (Interface 12.0)**

**Added**
- Action Targeting support — crosshair follows soft enemy targets when you have no hard target
- New addon icon visible in your AddOns list

**Changed**
- Cleaner settings panel with a Reset to Defaults button

**Removed**
- `/cplus rotate` command (use the settings panel to control rotation)

**Fixed**
- Bug fixes & cleanup

---

## [1.0.0] - 2025-02-10

### Initial Release

First public release of CrosshairsPlus!

**Features**
- 73 customizable arrow texture styles
- Class-based automatic coloring
- Target filtering (enemy players, friendly players, hostile NPCs, friendly NPCs)
- Rotating arrow animations with speed control
- Adjustable scale (50%-200%) and opacity (0%-100%)
- Customizable crosshair lines with thickness control
- Modern settings interface with four categories
- Smooth fade animations
- Lightweight and performance optimized
