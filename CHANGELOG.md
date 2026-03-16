# Changelog

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
