import ServiceManagement
import SwiftUI

@main
struct ClaudeShineApp: App {
    @State private var monitor = AppearanceMonitor()
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some Scene {
        MenuBarExtra {
            Text("Theme: \(monitor.currentTheme.rawValue.capitalized)")
                .font(.headline)

            Divider()

            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        print("[ClaudeShine] Login item toggle failed: \(error)")
                        // Revert the toggle on failure.
                        launchAtLogin = !newValue
                    }
                }

            Divider()

            Button("Quit Claude Shine") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Image(
                systemName: monitor.currentTheme == .dark
                    ? "moon.fill" : "sun.max.fill"
            )
        }
        .menuBarExtraStyle(.menu)
    }
}
