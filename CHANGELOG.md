# Changelog

## v1.10.1

### Fixes
- **Fixed cooldown timers becoming invalid after relog/reload** - Cooldowns are now stored as epoch timestamps (`time()`) instead of session-relative values (`GetTime()`), so they persist correctly across client restarts and UI reloads

---

## v1.10.0

### New Features
- **Automatic cooldown detection via polling** - Cooldowns are now detected on login by polling `GetSpellCooldown()` for all tracked spells, without needing to open the profession window
  - Catches cooldowns started before the addon was installed or that the event system missed
  - Listens to `SPELL_UPDATE_COOLDOWN` event for real-time updates
  - Filters out GCDs and spell locks (ignores durations under 60 seconds)
  - Includes WoW client overflow fix for start time values
- **Show seconds setting** - New toggle in Settings to display seconds remaining on cooldown timers (e.g., `2h 15m 30s` instead of `2h 15m`)

---

## v1.9.0

### New Features
- **Resizable tracker window** - Drag the bottom-right grip to resize; size is saved between sessions
  - Content width follows the window width; minimum width matches the content's natural size
  - Hidden when the tracker is locked
- **Alchemy & leatherworking sources** - Sources tab now includes vendor/trainer info and TomTom waypoints for all vendor-sold alchemy transmute recipes (Primal Might, Air to Fire, Earth to Water, Water to Air, Earthstorm Diamond, Skyfire Diamond)
- **New tracked cooldown** - Transmute: Primal Water to Air
- **Credits section** - Guild and contributor credits added to Settings

### Fixes
- **Tracker transparency** - Opacity slider now only affects the background; text remains fully readable at all transparency levels
- **Combat + group visibility** - "Show in combat" now correctly hides the tracker in combat even when "Show in party/raid" is checked
- **Default tracker position** - New installs center the tracker on screen instead of near the minimap
- **Last row separator removed** - No more stray horizontal line below the last cooldown entry

---

## v1.8.0

### New Features
- **Tracker table layout** - Cooldown tracker window redesigned with aligned columns (Character, Craft, Cooldown)
  - Bold separator lines between different characters
  - Striped/faint separator lines between rows of the same character
- **Tracker transparency slider** - Adjust the tracker window opacity from 10% to 100% in Settings
- **Lock/Unlock button** - Hover over the tracker window to reveal a Lock/Unlock button (bottom-right)
  - Locked: window cannot be dragged, close button hidden
  - Unlocked: window is draggable, close button visible
- **Tracker visibility checkboxes** - Replaced the display mode dropdown with granular checkboxes:
  - Show in combat
  - Show in party/raid

### Removed
- **Display mode dropdown** - Replaced by individual visibility checkboxes
- **Tooltip help button** - No longer needed with self-explanatory checkboxes

---

## v1.7.0

### New Features
- **Cooldown Tracker Window** - Persistent, semi-transparent overlay showing live countdowns for all tracked cooldowns across all characters
  - Displays "Available" in green when a cooldown is ready
  - Draggable with saved position (remembers where you put it between sessions)
  - Close button to dismiss without changing settings
- **Tracker Display Mode** - Dropdown in Settings to control tracker visibility:
  - **Static** - Show tracker at all times (default)
  - **Conditional** - Automatically hide tracker when in a party, raid, or combat
- **Salt Shaker tracking** - Track the Salt Shaker item cooldown (2d 23h) for Leatherworkers
  - Automatically detected via bag scanning when the item is in your inventory

### Removed
- **Login notification window** - Replaced by the always-visible tracker window
- **Mooncloth** cooldown (no cooldown in TBC Anniversary)
- **Old-world transmutes** - Removed Transmute: Arcanite, Mithril to Truesilver, and Iron to Gold

### Tracked Cooldowns
**Tailoring:** Shadowcloth, Spellcloth, Primal Mooncloth

**Leatherworking:** Salt Shaker

**Alchemy:** Transmute Primal Might, Transmute Undeath to Water, Transmute Primal Mana to Fire, Transmute Primal Shadow to Water, Transmute Primal Air to Fire, Transmute Primal Water to Shadow, Transmute Earthstorm Diamond, Transmute Skyfire Diamond

---

## v1.6.1

### Removed
- **Keybinding support** - Removed custom keybind feature (use the minimap button or `/pl` to toggle the window)

### Fixed
- Fixed Bindings.xml causing "Unrecognized XML: Binding" errors on load

---

## v1.6.0

### New Features
- **Header image** - Custom Outland-themed header banner at the top of the main window
- **Outland color theme** - Full UI restyled with a dark bronze/fiery color scheme matching the header art
- **CD Tracking window** - Moved from its own tab to a standalone window, accessible via a button in Settings
- **Improved craft export** - Two-step export flow:
  - Selection window shows all crafts with checkboxes (all checked by default)
  - Uncheck crafts you don't want, then click Export
  - Text window shows only the selected crafts, formatted for Discord

### Improvements
- Reduced tab count from 5 to 4 (Overview, Cooldowns, Sources, Settings)
- All UI elements (borders, separators, tabs, buttons, text) use a consistent warm color palette
- Notification window restyled to match the Outland theme

---

## v1.5.0

### New Features
- **Settings Tab** - New tab with addon configuration options
  - Toggle login notification popup on/off
  - Reset Data button with confirmation dialog to wipe all tracked data
- **CD Tracking Tab** - Control which cooldown crafts are tracked
  - Per-cooldown checkboxes grouped by profession (Tailoring / Alchemy)
  - Disabled cooldowns are hidden from the Cooldowns tab and login notifications
  - Settings persist across all characters and sessions
- **Craft Export** - Export button on profession windows for sharing crafts to Discord
  - Appears in the top-right of the TradeSkill and Craft (Enchanting) windows
  - Generates Discord-formatted text with all recipes grouped by category
  - Copyable text box with select-all support

---

## v1.4.0

### New Features
- **Settings Tab** - Initial settings tab with notification toggle and data reset
- **CD Tracking Tab** - Initial cooldown tracking filter

---

## v1.3.0

### New Features
- **Login Notifications** - On login, a notification popup shows all ready cooldowns across all your characters
- **TBC Alchemy Transmutes** - Added 7 new transmutes:
  - Transmute: Primal Mana to Fire
  - Transmute: Primal Shadow to Water
  - Transmute: Primal Air to Fire
  - Transmute: Primal Water to Shadow
  - Transmute: Primal Earth to Water
  - Transmute: Earthstorm Diamond
  - Transmute: Skyfire Diamond

---

## v1.2.0

### New Features
- **Sources Tab** - New tab showing where to obtain patterns for tailoring cooldown crafts
  - Clickable item links for patterns (hover to preview, shift-click to link in chat)
  - Clickable vendor names to target NPCs
  - TomTom waypoint integration (click to set waypoint)

### Improvements
- Updated tailoring cooldown durations to 92 hours (was incorrectly set to 96 hours)

### Data Added
- Pattern source information for Primal Mooncloth, Shadowcloth, and Spellcloth
- Vendor NPC data with TomTom coordinates for Shattrath City

---

## v1.1.0

### New Features
- **ESC to Close** - Press Escape to close the Primal Ledger window

### Improvements
- Expanded profession detection for future cooldown support

---

## v1.0.1

### Improvements
- UI no longer wipes data when opened - shows saved data immediately
- Opening a profession window now only refreshes data for that specific profession

---

## v1.0.0

### Initial Release
- Account-wide cooldown tracking for Alchemy and Tailoring
- Auto-detection of professions and known crafts
- Minimap button to toggle the cooldown window
- Click-to-craft: Left-click "Ready!" to open profession, right-click to select recipe
- Current character always appears at the top of the list
- Slash commands: `/pl`, `/pl reset`, `/pl remove`

### Tracked Cooldowns
**Tailoring:** Shadowcloth, Spellcloth, Primal Mooncloth, Mooncloth

**Alchemy:** Transmute Primal Might, Transmute Arcanite, Transmute Undeath to Water, Transmute Mithril to Truesilver, Transmute Iron to Gold
