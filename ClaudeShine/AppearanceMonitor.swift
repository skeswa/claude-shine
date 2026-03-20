import AppKit
import Combine

@Observable
final class AppearanceMonitor {
    private(set) var currentTheme: Theme
    private let settingsManager: ClaudeSettingsManager
    private let detectTheme: () -> Theme
    private var cancellable: AnyCancellable?

    init(
        settingsManager: ClaudeSettingsManager = ClaudeSettingsManager(),
        detectTheme: @escaping () -> Theme = AppearanceMonitor.systemTheme
    ) {
        self.settingsManager = settingsManager
        self.detectTheme = detectTheme
        currentTheme = detectTheme()
        settingsManager.applyTheme(currentTheme)

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

    func refreshTheme() {
        let newTheme = detectTheme()
        if newTheme != currentTheme {
            currentTheme = newTheme
        }
        settingsManager.applyTheme(newTheme)
    }

    static func systemTheme() -> Theme {
        let appearance = NSApplication.shared.effectiveAppearance
        let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        return isDark ? .dark : .light
    }
}
