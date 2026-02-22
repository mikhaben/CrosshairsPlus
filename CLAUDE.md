# CLAUDE.md - CrosshairsPlus Project Reference

## Project Overview

- **Type:** World of Warcraft addon
- **Language:** Lua + XML
- **Version:** 1.5.1
- **Interface:** 120000 (Midnight / The War Within)
- **Author:** asp1d (TOC author: justLuther)
- **SavedVariables:** `CrosshairsPlusDB`
- **License:** All Rights Reserved

CrosshairsPlus displays a customizable crosshair overlay on your target's nameplate. Features 73 arrow styles, 6 circle styles with glow/shadow effects, range display via LibRangeCheck-3.0, target info display, LibSharedMedia font integration, and target filtering.

## Directory Structure

```
CrosshairsPlus/                  # Project root (.git here)
├── CLAUDE.md                    # This file
├── README.md                    # User-facing documentation
├── RELEASE_NOTES.md             # Version changelog
├── MARKETING.md                 # CurseForge marketing copy
├── CONVERT.md                   # SVG-to-TGA asset conversion guide
├── build.sh                     # Build script
├── .gitignore
│
├── CrosshairsPlus/              # Main addon folder
│   ├── CrosshairsPlus.toc       # Table of Contents (load order)
│   ├── Core.lua                 # Namespace init, defaults, lifecycle, slash commands
│   ├── Crosshair.xml            # Frame definition (CrosshairsPlusFrame)
│   │
│   ├── Crosshair/               # Crosshair modules (11 files)
│   │   ├── State.lua            # Runtime state, constants, library refs, shared helpers
│   │   ├── Debug.lua            # Debug logging, diagnostics (/chp test)
│   │   ├── UnitLogic.lua        # Target filtering, color logic, nameplate CVar checks
│   │   ├── Lines.lua            # Line thickness, gap, visibility
│   │   ├── Arrows.lua           # Arrow style, positioning, rotation animation
│   │   ├── Circle.lua           # Circle style switching (6 styles + glow/shadow)
│   │   ├── Range.lua            # Range display (lazy-loads LibRangeCheck-3.0)
│   │   ├── TargetInfo.lua       # Target info text (name/level display)
│   │   ├── Attach.lua           # Color application, nameplate attachment, active unit mgmt
│   │   ├── OnUpdate.lua         # Per-frame update handler (rotation, color, range, info)
│   │   └── Init.lua             # Initialization, event registration, master visual update
│   │
│   ├── Settings/                # Settings modules (9 files)
│   │   ├── Widgets.lua          # Reusable AceConfig widget builders (font selector)
│   │   ├── GeneralTab.lua       # Target filters, action targeting, visual options, reset
│   │   ├── CircleTab.lua        # Circle style, effect, size
│   │   ├── LinesTab.lua         # Line toggle, thickness, gap
│   │   ├── ArrowsTab.lua        # Arrow style, size, distance, rotation
│   │   ├── RangeTab.lua         # Range display settings (shown only when sub-addon available)
│   │   ├── TargetInfoTab.lua    # Target info mode, position, font
│   │   ├── AboutTab.lua         # Version info, credits
│   │   └── Init.lua             # AceConfig registration, tab assembly, OpenSettings
│   │
│   ├── Libs/                    # Bundled libraries
│   │   ├── LibStub/
│   │   ├── CallbackHandler-1.0/
│   │   ├── AceGUI-3.0/
│   │   ├── AceConfig-3.0/
│   │   ├── LibSharedMedia-3.0/
│   │   └── AceGUI-3.0-SharedMediaWidgets/
│   │
│   └── Assets/                  # Textures (.tga/.blp)
│       ├── Logo.tga             # Addon icon
│       ├── Arrow0-Arrow72.tga   # 73 arrow textures
│       ├── Circle0-Circle5.tga  # 6 circle textures
│       ├── CircleGlow.tga       # Circle glow effect
│       └── CircleShadow.tga     # Circle shadow effect
│
├── CrosshairsPlus_Range/        # LoadOnDemand sub-addon
│   ├── CrosshairsPlus_Range.toc
│   └── Libs/
│       └── LibRangeCheck-3.0/
│
└── build/                       # Build output (gitignored)
```

## Architecture & Namespace

### Namespace: `CPlusNS`

All modules share the addon namespace via `local AddonName, CPlusNS = ...` at the top of every file.

| Key | Purpose |
|-----|---------|
| `CPlusNS.defaults` | Default settings table (defined in Core.lua, used for merge and reset) |
| `CPlusNS.db` | Live settings reference (`= CrosshairsPlusDB` after PLAYER_LOGIN) |
| `CPlusNS.state` | Runtime state (not persisted) — frame ref, timers, cached values |
| `CPlusNS.CONST` | Read-only constants — intervals, padding, arrow/line key tables |
| `CPlusNS.LSM` | LibSharedMedia-3.0 reference (loaded at State.lua parse time) |
| `CPlusNS.RC` | LibRangeCheck-3.0 reference (lazy-loaded by Range.lua, initially nil) |
| `CPlusNS.EventFrame` | Event handler frame (created in Core.lua) |

### Global References

- `_G.CrosshairsPlus = CPlusNS` — set in Core.lua for slash command access
- `CrosshairsPlusFrame` — XML-defined frame (global, created by Crosshair.xml)
- `CrosshairsPlusDB` — SavedVariables table

## Module Load Order

Defined by the TOC file. Order matters — each module depends on prior modules.

```
1.  Libs (LibStub, CallbackHandler, AceGUI, AceConfig, LSM, SMWidgets)
2.  Core.lua              — CPlusNS.defaults, DeepCopy, InitializeDatabase, event frame, PLAYER_LOGIN, slash commands
3.  Crosshair.xml         — Creates CrosshairsPlusFrame with child textures/fontstrings
4.  Crosshair/State.lua   — CPlusNS.state, CPlusNS.CONST, CPlusNS.LSM, CPlusNS.RC, ResolveFont, SetTextAnchor
5.  Crosshair/Debug.lua   — Debug, Debugf, DebugUnitInfo, ToggleDebug, RunDiagnostics
6.  Crosshair/UnitLogic.lua — ShouldShowCrosshair, CheckNameplateCVars, GetActiveUnit, GetUnitColor
7.  Crosshair/Lines.lua   — UpdateLineThickness, UpdateLineGap, UpdateLineVisibility
8.  Crosshair/Arrows.lua  — RefreshRotationCache, UpdateArrowRotation, UpdateArrowStyle
9.  Crosshair/Circle.lua  — UpdateCircleStyle
10. Crosshair/Range.lua   — UpdateRangeDisplay, UpdateRangePosition
11. Crosshair/TargetInfo.lua — RefreshTargetInfoText, UpdateTargetInfoColor, UpdateTargetInfoPosition
12. Crosshair/Attach.lua  — ApplyColorToTextures, ApplyFrameSettings, AttachToNameplate, HideCrosshair, RefreshActiveUnit
13. Crosshair/OnUpdate.lua — OnUpdate handler (local), SetupOnUpdate
14. Crosshair/Init.lua    — UpdateCrosshairVisuals, InitializeCrosshair, event handlers (PLAYER_TARGET_CHANGED, etc.)
15. Settings/Widgets.lua   — BuildFontSelect
16. Settings/GeneralTab.lua — BuildGeneralTab
17. Settings/CircleTab.lua  — BuildCircleTab
18. Settings/LinesTab.lua   — BuildLinesTab
19. Settings/ArrowsTab.lua  — BuildArrowsTab
20. Settings/RangeTab.lua   — BuildRangeTab
21. Settings/TargetInfoTab.lua — BuildTargetInfoTab
22. Settings/AboutTab.lua   — BuildAboutTab
23. Settings/Init.lua       — InitializeSettings, OpenSettings
```

## Coding Conventions

### Namespace Access Pattern

Every `.lua` file starts with:
```lua
local AddonName, CPlusNS = ...
```
Then accesses shared state via `CPlusNS.state`, `CPlusNS.db`, `CPlusNS.CONST`, etc. Performance-critical modules cache these to locals:
```lua
local state = CPlusNS.state
local CONST = CPlusNS.CONST
```

### State Management

- **Persisted settings** go in `CPlusNS.defaults` (Core.lua) and are accessed via `CPlusNS.db.*`
- **Runtime state** goes in `CPlusNS.state` (State.lua) — never persisted
- New settings must be added to `CPlusNS.defaults` so `MergeDefaults` handles upgrades

### Settings Callbacks

All settings widgets call `CPlusNS.UpdateCrosshairVisuals()` in their `set` function. This is the single entry point for refreshing all visual state after a settings change.

### Debug Output

Use `CPlusNS.Debug(msg)` or `CPlusNS.Debugf(fmt, ...)` — output is gated by `CPlusNS.db.debugMode`.
Green prefix: `|cff00ff00[CHP]|r`

### Event Handler Pattern

Events are dispatched by the shared event frame in Core.lua:
```lua
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if CPlusNS[event] then
        CPlusNS[event](CPlusNS, ...)
    end
end)
```
Define handlers as `function CPlusNS:EVENT_NAME(...)` and register with `CPlusNS.EventFrame:RegisterEvent("EVENT_NAME")`.

### Texture Paths

Assets use the WoW interface path format:
```lua
"Interface\\AddOns\\CrosshairsPlus\\Assets\\" .. textureName
```

### Performance Patterns

- OnUpdate rotation is unrolled (4 arrows inline, not looped) for per-frame performance
- Math functions cached to locals: `local sin, cos = math.sin, math.cos`
- File-local reusable variables to avoid garbage: `local angle, radians, x, y`
- Rotation settings cached to `state.cached*` — refreshed only on settings change
- Color updates use change detection (compare against `state.lastUnit*`)
- Range update uses change detection (`state.lastRangeVal`, `state.lastMaxRange`)
- Slow updates (color, range, target info) throttled to 0.3s via `state.updateTimer`

### Lazy-Loading (Range)

LibRangeCheck-3.0 lives in the `CrosshairsPlus_Range` LoadOnDemand sub-addon. `Range.lua` checks `C_AddOns.GetAddOnEnableState`, calls `C_AddOns.LoadAddOn` on first use, then caches `CPlusNS.RC`. If the sub-addon is missing or disabled, range is silently disabled at runtime.

### Font Resolution

`CPlusNS.ResolveFont(fontName)` handles `"Default"` (returns game font path) and LSM font lookup. Used by Range.lua and TargetInfo.lua.

## Events

| Event | Registered In | Handler |
|-------|---------------|---------|
| `PLAYER_LOGIN` | Core.lua | Initializes DB, crosshair system, and settings |
| `PLAYER_ENTERING_WORLD` | Core.lua | Refreshes active unit on zone change |
| `PLAYER_TARGET_CHANGED` | Crosshair/Init.lua | Calls `RefreshActiveUnit()` |
| `NAME_PLATE_UNIT_ADDED` | Crosshair/Init.lua | Attaches crosshair if nameplate is for active unit |
| `NAME_PLATE_UNIT_REMOVED` | Crosshair/Init.lua | Hides crosshair if nameplate was for active unit |
| `PLAYER_SOFT_ENEMY_CHANGED` | Crosshair/Init.lua | Refreshes active unit (if action targeting enabled) |

## Build & Release

```bash
./build.sh
```

- Reads version from TOC: `## Version: 1.5.1`
- Output: `build/CrosshairsPlus_1.5.1_YYYY-MM-DD.zip`
- ZIP contains both `CrosshairsPlus/` and `CrosshairsPlus_Range/` folders
- Upload to CurseForge

## Adding New Assets

1. See `CONVERT.md` for SVG-to-TGA conversion (512x512, 32-bit RGBA, uncompressed)
2. Place `.tga` files in `CrosshairsPlus/Assets/`
3. Arrow textures: `Arrow0.tga` through `Arrow72.tga` (73 total)
4. Circle textures: `Circle0.tga` through `Circle5.tga` (6 total)
5. Update the relevant style dropdown `values` table in the Settings tab
6. Update arrow/circle counts in README.md and MARKETING.md if adding new styles

## Testing

| Command | Purpose |
|---------|---------|
| `/chp test` | Full diagnostics dump — runtime state, settings, CVars, warnings |
| `/chp debug` | Toggle debug mode — logs events, color changes, attach/detach |
| `/chp preview` | Toggle crosshair at screen center (no unit attached — visual test only) |
| `/chp` | Open settings panel |
