import AppKit
import Combine

@Observable
final class AppearanceMonitor {
    private(set) var currentTheme: Theme

    private var cancellable: AnyCancellable?

    init() {
        // Read initial appearance.
        currentTheme = Self.detectTheme()

        // Apply on launch.
        ClaudeSettingsManager.applyTheme(currentTheme)

        // Listen for system appearance changes.
        cancellable = DistributedNotificationCenter.default()
            .publisher(for: Notification.Name("AppleInterfaceThemeChangedNotification"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Small delay — the notification fires slightly before the
                // system finishes updating the effective appearance.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.refreshTheme()
                }
            }
    }

    private func refreshTheme() {
        let newTheme = Self.detectTheme()
        if newTheme != currentTheme {
            currentTheme = newTheme
        }
        ClaudeSettingsManager.applyTheme(newTheme)
    }

    private static func detectTheme() -> Theme {
        let appearance = NSApplication.shared.effectiveAppearance
        let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        return isDark ? .dark : .light
    }
}
