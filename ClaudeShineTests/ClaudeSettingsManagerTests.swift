import XCTest

@testable import ClaudeShine

final class ClaudeSettingsManagerTests: XCTestCase {
    private var tempDirectory: URL!
    private var manager: ClaudeSettingsManager!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ClaudeShineTests-\(UUID().uuidString)")
        manager = ClaudeSettingsManager(settingsDirectoryURL: tempDirectory)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    // MARK: - Helpers

    private func readSettings() throws -> [String: Any] {
        let data = try Data(contentsOf: manager.settingsFileURL)
        return try JSONSerialization.jsonObject(with: data) as! [String: Any]
    }

    private func writeSettings(_ settings: [String: Any]) throws {
        try FileManager.default.createDirectory(
            at: tempDirectory, withIntermediateDirectories: true)
        let data = try JSONSerialization.data(
            withJSONObject: settings, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: manager.settingsFileURL)
    }

    private func writeRawData(_ string: String) throws {
        try FileManager.default.createDirectory(
            at: tempDirectory, withIntermediateDirectories: true)
        try string.write(
            to: manager.settingsFileURL, atomically: true, encoding: .utf8)
    }

    // MARK: - Use Case: First launch (clean slate)

    func test_firstLaunch_createsDirectoryAndSettingsFile() {
        manager.applyTheme(.light)

        XCTAssertTrue(
            FileManager.default.fileExists(atPath: tempDirectory.path))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: manager.settingsFileURL.path))
    }

    func test_firstLaunch_setsLightTheme_whenSystemIsLight() throws {
        manager.applyTheme(.light)

        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "light")
    }

    func test_firstLaunch_setsDarkTheme_whenSystemIsDark() throws {
        manager.applyTheme(.dark)

        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "dark")
    }

    // MARK: - Use Case: Launch with existing settings

    func test_existingSettings_preservesOtherKeys_whenAddingTheme() throws {
        try writeSettings(["customKey": "customValue", "number": 42])

        manager.applyTheme(.dark)

        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "dark")
        XCTAssertEqual(settings["customKey"] as? String, "customValue")
        XCTAssertEqual(settings["number"] as? Int, 42)
    }

    func test_existingSettings_updatesTheme_whenDifferentValuePresent()
        throws
    {
        try writeSettings(["theme": "light"])

        manager.applyTheme(.dark)

        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "dark")
    }

    func test_existingSettings_createsFile_whenDirectoryExistsButFileDoesNot()
        throws
    {
        try FileManager.default.createDirectory(
            at: tempDirectory, withIntermediateDirectories: true)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: manager.settingsFileURL.path))

        manager.applyTheme(.light)

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: manager.settingsFileURL.path))
        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "light")
    }

    // MARK: - Use Case: Theme switching

    func test_themeSwitch_lightToDark_updatesFile() throws {
        manager.applyTheme(.light)
        manager.applyTheme(.dark)

        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "dark")
    }

    func test_themeSwitch_darkToLight_updatesFile() throws {
        manager.applyTheme(.dark)
        manager.applyTheme(.light)

        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "light")
    }

    func test_themeSwitch_rapidToggles_finalStateIsCorrect() throws {
        for _ in 0..<10 {
            manager.applyTheme(.light)
            manager.applyTheme(.dark)
        }
        manager.applyTheme(.light)

        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "light")
    }

    // MARK: - Use Case: Idempotent apply (no unnecessary writes)

    func test_idempotent_skipsWrite_whenThemeAlreadyMatches() throws {
        manager.applyTheme(.dark)

        let attrs1 = try FileManager.default.attributesOfItem(
            atPath: manager.settingsFileURL.path)
        let modDate1 = attrs1[.modificationDate] as! Date

        // Small delay to ensure file system timestamp would differ.
        Thread.sleep(forTimeInterval: 1.0)

        manager.applyTheme(.dark)

        let attrs2 = try FileManager.default.attributesOfItem(
            atPath: manager.settingsFileURL.path)
        let modDate2 = attrs2[.modificationDate] as! Date

        XCTAssertEqual(
            modDate1, modDate2,
            "File should not be rewritten when theme already matches")
    }

    // MARK: - Use Case: Recovery from corruption

    func test_recovery_overwritesMalformedJSON_withValidTheme() throws {
        try writeRawData("{not valid json!!!")

        manager.applyTheme(.light)

        let settings = try readSettings()
        XCTAssertEqual(settings["theme"] as? String, "light")
    }

    // MARK: - Use Case: Output format correctness

    func test_outputFormat_writesPrettyPrintedSortedJSON() throws {
        try writeSettings(["beta": "b", "alpha": "a"])

        manager.applyTheme(.dark)

        let data = try Data(contentsOf: manager.settingsFileURL)
        let jsonString = String(data: data, encoding: .utf8)!

        // Verify pretty-printed (contains newlines and indentation).
        XCTAssertTrue(
            jsonString.contains("\n"), "JSON should be pretty-printed")

        // Verify sorted keys: "alpha" before "beta" before "theme".
        let alphaRange = jsonString.range(of: "\"alpha\"")!
        let betaRange = jsonString.range(of: "\"beta\"")!
        let themeRange = jsonString.range(of: "\"theme\"")!
        XCTAssertTrue(
            alphaRange.lowerBound < betaRange.lowerBound,
            "Keys should be sorted: alpha before beta")
        XCTAssertTrue(
            betaRange.lowerBound < themeRange.lowerBound,
            "Keys should be sorted: beta before theme")
    }
}
