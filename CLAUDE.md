# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Build & Development Commands

This project uses **Tuist** (managed by **mise**) for Xcode project generation.
The `.xcodeproj` is not checked in — it's generated on demand.

```bash
mise install          # Install Tuist, prettier, and swiftformat (first time only)
mise run generate     # Generate Xcode project from Project.swift
mise run build        # Release build (depends on generate)
mise run test         # Run all tests (depends on generate)
mise run fmt          # Format all source files (Swift, Markdown, JSON)
mise run install      # Build + copy to /Applications + launch
mise run uninstall    # Quit + remove from /Applications
mise run clean        # Remove build artifacts + Tuist cache
```

To run a single test, generate the project then use xcodebuild directly:

```bash
mise run generate
xcodebuild -project ClaudeShine.xcodeproj -scheme ClaudeShine -configuration Debug -derivedDataPath build test -only-testing:ClaudeShineTests/ClaudeSettingsManagerTests/test_firstLaunch_createsDirectoryAndSettingsFile
```

## Architecture

Claude Shine is a macOS menu bar utility (~200 lines) that syncs system
appearance with Claude Code's theme in `~/.claude/settings.json`.

**Data flow:**

```
DistributedNotificationCenter (AppleInterfaceThemeChangedNotification)
  → AppearanceMonitor.refreshTheme()
    → ClaudeSettingsManager.applyTheme()
      → atomic write to ~/.claude/settings.json
```

**Key components:**

- **`AppearanceMonitor`** — `@Observable` class that subscribes to system
  appearance notifications and coordinates theme updates. Has a 100ms delay
  after notification because macOS fires the notification _before_ the effective
  appearance actually updates.
- **`ClaudeSettingsManager`** — Stateless struct handling atomic JSON
  read/write. Preserves existing settings keys, skips writes when theme already
  matches, and recovers from corrupted JSON by overwriting.
- **`ClaudeShineApp`** — SwiftUI `@main` entry point. Menu bar UI with sun/moon
  icon, theme label, and Launch at Login toggle via `SMAppService`.

**Testability:** Both `AppearanceMonitor` and `ClaudeSettingsManager` accept
injected dependencies (settings directory URL, theme detection closure) with
defaults for production. Tests use UUID-based temp directories — no mocking
frameworks needed.

## Non-Obvious Details

- `LSUIElement: true` in the Info.plist (set via `Project.swift`) makes this a
  menu bar-only app with no Dock icon.
- `NSMainStoryboardFile` is set to empty string in `Project.swift` because
  Tuist's `.extendingDefault` adds `"Main"` by default, which crashes since this
  SwiftUI app has no storyboard.
- `refreshTheme()` always writes to the settings file even when `currentTheme`
  hasn't changed — this is intentional recovery behavior in case the file was
  externally modified.
- The app icon uses Apple's exact squircle bezier curves (12 cubic beziers, 3
  per corner), with masks rendered independently at each icon size to avoid
  resize artifacts.
