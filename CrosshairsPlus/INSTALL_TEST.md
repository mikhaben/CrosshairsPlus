# CrosshairsPlus Installation & Testing Guide

## Installation Steps

### 1. Copy Addon to WoW Directory

**For macOS:**
```bash
cp -r CrosshairsPlus "/Applications/World of Warcraft/_retail_/Interface/AddOns/"
```

**For Windows:**
```
Copy the CrosshairsPlus folder to:
C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\
```

### 2. Verify File Structure

After copying, your AddOns folder should have:
```
World of Warcraft/
└── _retail_/
    └── Interface/
        └── AddOns/
            └── CrosshairsPlus/
                ├── CrosshairsPlus.toc
                ├── Core.lua
                ├── Crosshair.xml
                ├── Crosshair.lua
                ├── Settings.lua
                ├── Utils.lua
                ├── Libs/
                │   ├── LibStub/
                │   └── LibRangeCheck-3.0/
                └── Assets/
                    ├── 4Arrows.tga
                    ├── core.tga
                    ├── shadow.tga
                    └── ringSolid_outerGlow.tga
```

## In-Game Testing

### Step 1: Enable Script Errors
```
/console scriptErrors 1
```
This will show any Lua errors immediately.

### Step 2: Reload UI
```
/reload
```

### Step 3: Check Chat Output

You should see these messages in chat after `/reload`:

```
✅ CrosshairsPlus: PLAYER_LOGIN event fired
✅ CrosshairsPlus: Database initialized
✅ CrosshairsPlus: LibRangeCheck-3.0 loaded successfully
✅ CrosshairsPlus: CrosshairsPlusFrame found
✅ CrosshairsPlus: Frame reference acquired: [frame object]
✅ CrosshairsPlus: Events registered
✅ CrosshairsPlus: Crosshair visuals configured
✅ CrosshairsPlus: Crosshair system initialized
✅ CrosshairsPlus: Settings panel initialized
✅ CrosshairsPlus v1.0.0 loaded. Type /crosshairsplus for options.
```

### Step 4: Test Addon List

1. Press `ESC`
2. Click `AddOns`
3. Look for **CrosshairsPlus** in the list
4. Make sure it's checked (enabled)

### Step 5: Open Settings

Type in chat:
```
/crosshairsplus
```
or
```
/chp
```

**Alternative:**
1. Press `ESC`
2. Click `Interface`
3. Click `AddOns` (left sidebar)
4. Click `CrosshairsPlus`

You should see the settings panel with:
- Target Filters section (checkboxes)
- Visual Options section (checkboxes)
- Style Settings section (dropdowns and sliders)

### Step 6: Test Crosshair Display

1. Enable nameplates: Press `V` key
2. Target an enemy NPC
3. You should see the crosshair appear on the target

**If crosshair doesn't show:**
- Check "Show on Hostile NPCs" is enabled in settings
- Verify the target has a nameplate visible
- Type `/dump CrosshairsPlusFrame` - should return a table/frame object, not nil

### Step 7: Test Target Filtering

**Test Enemy Players (if in PvP zone):**
1. Enable "Show on Enemy Players" in settings
2. Target an enemy player
3. Crosshair should appear with class color

**Test Friendly NPCs:**
1. Enable "Show on Friendly NPCs" in settings
2. Target a friendly NPC (quest giver, vendor, etc.)
3. Crosshair should appear in green

**Test Critters:**
1. Enable "Show on Critters" in settings
2. Target a critter (rabbit, squirrel, etc.)
3. Crosshair should appear

### Step 8: Test Visual Options

**Range Display:**
- Enable "Show Range Display"
- Target something
- You should see distance in yards below the crosshair

**Target Name:**
- Enable "Show Target Name"
- Target something
- You should see the target's name above the crosshair

**Line Thickness:**
- Adjust the slider
- The crosshair lines should change thickness in real-time

**Scale:**
- Adjust the scale slider
- The entire crosshair should grow/shrink

**Opacity:**
- Adjust the opacity slider
- The crosshair should become more/less transparent

## Troubleshooting

### Problem: Addon not in addon list

**Solution:**
1. Check file path is correct
2. Verify `CrosshairsPlus.toc` exists
3. Make sure folder name is exactly `CrosshairsPlus` (case-sensitive on some systems)
4. Try deleting `Cache` folder in WoW directory and restart WoW

### Problem: Addon shows in list but doesn't load

**Solution:**
1. Check for Lua errors: `/console scriptErrors 1` then `/reload`
2. Look for RED error messages in chat
3. Check that all files from the file structure above exist
4. Verify LibStub and LibRangeCheck folders are present in `Libs/`

### Problem: No chat messages on load

**Solution:**
1. The addon might not be executing `PLAYER_LOGIN`
2. Type: `/dump CrosshairsPlus` - should return a table, not nil
3. Type: `/dump CrosshairsPlusDB` - should return a table with settings
4. Check TOC file has correct format (no BOM, correct line endings)

### Problem: Crosshair doesn't show on target

**Check these in order:**

1. **Is frame created?**
   ```
   /dump CrosshairsPlusFrame
   ```
   Should return: `table: 0x...` (a frame object)
   If nil: XML file didn't load

2. **Are events registered?**
   ```
   /dump CrosshairsPlus.EventFrame:IsEventRegistered("PLAYER_TARGET_CHANGED")
   ```
   Should return: `true`

3. **Is target valid?**
   ```
   /dump CrosshairsPlus.ShouldShowCrosshair("target")
   ```
   Should return: `true` if your settings allow this target type

4. **Does target have nameplate?**
   ```
   /dump C_NamePlate.GetNamePlateForUnit("target")
   ```
   Should return: `table: 0x...` (a nameplate frame)
   If nil: Target doesn't have nameplate visible (press `V`)

5. **Check settings:**
   ```
   /dump CrosshairsPlusDB.showHostileNPCs
   ```
   Should return: `true` (or whichever filter you're testing)

### Problem: Settings panel doesn't open

**Solution:**

If `/crosshairsplus` doesn't work:

1. Try opening manually:
   ```lua
   /run Settings.OpenToCategory("CrosshairsPlus")
   ```

2. Check if settings frame exists:
   ```
   /dump CrosshairsPlusSettingsFrame
   ```

3. For older WoW versions, try:
   ```lua
   /run InterfaceOptionsFrame_OpenToCategory("CrosshairsPlus")
   ```

### Problem: Range display not working

**Solution:**
1. LibRangeCheck requires certain items/spells to be available
2. Check: `/dump CrosshairsPlus.RangeCheck` - should return a table
3. If nil, LibRangeCheck didn't load - check LibStub loaded correctly
4. Some targets may not return accurate range (phased, far away, etc.)

## Debug Commands

### Dump Current Settings
```lua
/dump CrosshairsPlusDB
```

### Check if Addon Loaded
```lua
/dump CrosshairsPlus
```

### Check Frame Reference
```lua
/dump CrosshairsPlusFrame
```

### Test Target Filtering
```lua
/dump CrosshairsPlus.ShouldShowCrosshair("target")
```

### Check Target's Nameplate
```lua
/dump C_NamePlate.GetNamePlateForUnit("target")
```

### Get Target Color
```lua
/dump CrosshairsPlus.GetUnitColor("target")
```

### Force Refresh
```lua
/run CrosshairsPlus.RefreshCrosshair()
```

## Expected Behavior

### On Enemy NPC Target:
- ✅ Crosshair appears centered on nameplate
- ✅ Crosshair is RED colored
- ✅ Rotating arrows animation plays
- ✅ Range displays (if enabled)
- ✅ Name displays (if enabled)
- ✅ Lines extend from crosshair (if enabled)

### On Friendly NPC Target:
- ✅ Crosshair appears (if "Show on Friendly NPCs" enabled)
- ✅ Crosshair is GREEN colored
- ✅ Same visual behavior as hostile

### On Enemy Player Target (PvP):
- ✅ Crosshair appears (if "Show on Enemy Players" enabled)
- ✅ Crosshair is CLASS COLOR (if class coloring enabled)
- ✅ Same visual behavior

### On Target Lost:
- ✅ Crosshair fades out smoothly
- ✅ Frame hidden after fade

## Success Criteria

✅ Addon appears in addon list
✅ No Lua errors on load
✅ Chat messages confirm successful initialization
✅ Settings panel opens with `/crosshairsplus`
✅ Crosshair appears on valid targets
✅ Crosshair colors correctly based on target type
✅ Range and name display work (if enabled)
✅ Settings changes apply immediately
✅ Settings persist after `/reload`

## If All Else Fails

1. Copy the entire output of `/reload` from chat
2. Run all Debug Commands above and copy output
3. Check for any RED error messages
4. Provide this information for debugging

## Contact

If you encounter issues not covered here, provide:
- WoW version (type `/run print(select(4, GetBuildInfo()))`)
- Full addon list
- Any error messages
- Debug command outputs
- Description of what's not working
