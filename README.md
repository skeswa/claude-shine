# Claude Shine

A lightweight macOS menu bar utility that automatically syncs [Claude Code](https://claude.ai/)'s theme with your system appearance.

When you toggle between light and dark mode on macOS, Claude Shine updates `~/.claude/settings.json` so Claude Code follows along — no manual `/theme light` or `/theme dark` needed.

## Installation

### From source

```bash
git clone https://github.com/skeswa/claude-shine.git
cd claude-shine
make install
```

This builds a Release binary and copies `ClaudeShine.app` to `/Applications/`.

### Manual

Download `ClaudeShine.app` from [Releases](https://github.com/skeswa/claude-shine/releases) and drag it to `/Applications/`.

## How it works

1. On launch, reads the current macOS appearance (light or dark)
2. Listens for `AppleInterfaceThemeChangedNotification` via `DistributedNotificationCenter`
3. Updates the `"theme"` key in `~/.claude/settings.json` whenever the appearance changes
4. Writes atomically (temp file + rename) to avoid corrupting the settings file

The app runs as a menu bar utility with no Dock icon. It uses zero CPU when idle — theme changes are notification-driven, not polled.

## Menu bar

- **Icon:** Sun (light mode) or Moon (dark mode)
- **Current theme** label
- **Launch at Login** toggle
- **Quit**

## Uninstall

```bash
make uninstall
```

Or just quit the app and delete `ClaudeShine.app` from `/Applications/`.

## Requirements

- macOS 14+

## License

[MIT](LICENSE)
