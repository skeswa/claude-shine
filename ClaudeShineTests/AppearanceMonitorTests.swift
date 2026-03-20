@testable import ClaudeShine
import XCTest

final class AppearanceMonitorTests: XCTestCase {
    private var tempDirectory: URL!
    private var settingsManager: ClaudeSettingsManager!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ClaudeShineTests-\(UUID().uuidString)")
        settingsManager = ClaudeSettingsManager(
            settingsDirectoryURL: tempDirectory
        )
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    // MARK: - Helpers

    private func readSettings() throws -> [String: Any] {
        let data = try Data(contentsOf: settingsManager.settingsFileURL)
        return try JSONSerialization.jsonObject(with: data) as! [String: Any]
    }

    // MARK: - Use Case: App launch detects and applies current theme

    func test_init_detectsCurrentTheme_andWritesSettingsFile() {
        let monitor = AppearanceMonitor(
            settingsManager: settingsManager,
            detectTheme: { .light }
        )

        XCTAssertEqual(monitor.currentTheme, .light)
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: settingsManager.settingsFileURL.path
            )
        )
    }

    func test_init_appliesDarkTheme_whenDetectorReturnsDark() throws {
        let monitor = AppearanceMonitor(
            settingsManager: settingsManager,
            detectTheme: { .dark }
        )

        XCTAssertEqual(monitor.currentTheme, .dark)
        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "dark")
    }

    func test_init_appliesLightTheme_whenDetectorReturnsLight() throws {
        let monitor = AppearanceMonitor(
            settingsManager: settingsManager,
            detectTheme: { .light }
        )

        XCTAssertEqual(monitor.currentTheme, .light)
        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "light")
    }

    // MARK: - Use Case: System appearance changes

    func test_refreshTheme_updatesProperty_whenThemeChanges() {
        var currentTheme: Theme = .light
        let monitor = AppearanceMonitor(
            settingsManager: settingsManager,
            detectTheme: { currentTheme }
        )

        XCTAssertEqual(monitor.currentTheme, .light)

        currentTheme = .dark
        monitor.refreshTheme()

        XCTAssertEqual(monitor.currentTheme, .dark)
    }

    func test_refreshTheme_writesNewTheme_toSettingsFile() throws {
        var currentTheme: Theme = .light
        let monitor = AppearanceMonitor(
            settingsManager: settingsManager,
            detectTheme: { currentTheme }
        )

        currentTheme = .dark
        monitor.refreshTheme()

        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "dark")
    }

    func test_refreshTheme_doesNotUpdateProperty_whenThemeUnchanged() {
        let monitor = AppearanceMonitor(
            settingsManager: settingsManager,
            detectTheme: { .light }
        )

        XCTAssertEqual(monitor.currentTheme, .light)

        monitor.refreshTheme()

        XCTAssertEqual(monitor.currentTheme, .light)
    }

    func test_refreshTheme_stillWritesToFile_evenWhenPropertyUnchanged()
        throws
    {
        let monitor = AppearanceMonitor(
            settingsManager: settingsManager,
            detectTheme: { .light }
        )

        // Tamper with the file to set a different theme value.
        let data = try JSONSerialization.data(
            withJSONObject: ["theme": "dark"],
            options: [.prettyPrinted, .sortedKeys]
        )
        try data.write(to: settingsManager.settingsFileURL, options: .atomic)

        let before = try readSettings()
        XCTAssertEqual(before["theme"] as? String, "dark")

        // refreshTheme — currentTheme stays .light (detector returns .light),
        // but applyTheme should overwrite the file back to "light".
        monitor.refreshTheme()

        XCTAssertEqual(monitor.currentTheme, .light)
        let after = try readSettings()
        XCTAssertEqual(after["theme"] as? String, "light")
    }
}
