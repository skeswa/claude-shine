<div align="center">

<img src="logo.png" width="200" alt="Claude Shine app icon" />

# Claude Shine

**Automatic dark mode for
[Claude Code](https://docs.anthropic.com/en/docs/claude-code).**

[![macOS 14+](https://img.shields.io/badge/macOS-14%2B-black?style=flat-square&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Built with Tuist](https://img.shields.io/badge/built_with-Tuist-blueviolet?style=flat-square)](https://tuist.dev)

</div>

---

Claude Code doesn't follow your system appearance. Every time you toggle dark
mode on macOS, you have to manually type `/theme light` or `/theme dark`. Claude
Shine fixes that.

It sits in your menu bar, watches for appearance changes, and updates
`~/.claude/settings.json` instantly. No polling, no CPU usage when idle, no
config — just install and forget.

<div align="center">
<img src="screenshot.png" width="400" alt="Claude Shine in the macOS menu bar" />
</div>

## Features

- **Instant sync** — theme updates the moment macOS appearance changes
- **Zero overhead** — notification-driven, not polled; uses no CPU when idle
- **Menu bar native** — sun/moon icon reflects current theme; no Dock icon
- **Launch at Login** — one-click toggle in the menu bar dropdown
- **Non-destructive** — preserves all existing settings in `settings.json`
- **Atomic writes** — temp file + rename prevents corruption, even on crash

## Install

### Download

Grab `ClaudeShine.app` from
[Releases](https://github.com/skeswa/claude-shine/releases) and drop it in
`/Applications`.

### Build from source

Requires [mise](https://mise.jdx.dev/) (`brew install mise`).

```bash
git clone https://github.com/skeswa/claude-shine.git
cd claude-shine
mise install   # installs Tuist
mise run install
```

This builds a Release binary and copies `ClaudeShine.app` to `/Applications`.

## How it works

```mermaid
flowchart TD
    A["macOS appearance changes"] --> B["DistributedNotificationCenter"]
    B --> C["Detect new theme"]
    C --> D["Read ~/.claude/settings.json"]
    D --> E["Update theme key"]
    E --> F["Write atomically (tmp + rename)"]
```

The entire app is ~200 lines of Swift. Four files, no dependencies, no
frameworks beyond AppKit and SwiftUI.

| Component               | Responsibility                                    |
| ----------------------- | ------------------------------------------------- |
| `AppearanceMonitor`     | Subscribes to system notifications, detects theme |
| `ClaudeSettingsManager` | Reads/writes `settings.json` atomically           |
| `Theme`                 | `light` / `dark` enum                             |
| `ClaudeShineApp`        | Menu bar UI, Launch at Login toggle               |

## Development

```bash
mise run generate    # Generate Xcode project
mise run build       # Release build
mise run test        # Run 19 unit tests
mise run clean       # Remove build artifacts
```

The project uses [Tuist](https://tuist.dev) for declarative Xcode project
generation — no `.xcodeproj` checked into the repo. All dependencies are
injected, so the full test suite runs without touching the real filesystem or
system APIs.

## Uninstall

```bash
mise run uninstall
```

Or quit the app and delete it from `/Applications`.

## License

[MIT](LICENSE)
