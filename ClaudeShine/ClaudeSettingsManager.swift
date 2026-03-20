import Foundation

struct ClaudeSettingsManager {
    private static var settingsDirectoryURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude")
    }

    private static var settingsFileURL: URL {
        settingsDirectoryURL.appendingPathComponent("settings.json")
    }

    static func applyTheme(_ theme: Theme) {
        let fileManager = FileManager.default
        let dirURL = settingsDirectoryURL
        let fileURL = settingsFileURL

        // Ensure ~/.claude/ exists.
        if !fileManager.fileExists(atPath: dirURL.path) {
            do {
                try fileManager.createDirectory(
                    at: dirURL, withIntermediateDirectories: true)
            } catch {
                print(
                    "[ClaudeShine] Failed to create \(dirURL.path): \(error)")
                return
            }
        }

        // Read existing settings or start fresh.
        var settings: [String: Any] = [:]
        if let data = try? Data(contentsOf: fileURL),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        {
            settings = json
        }

        // Skip write if theme already matches.
        if let current = settings["theme"] as? String, current == theme.rawValue {
            return
        }

        settings["theme"] = theme.rawValue

        // Write atomically: temp file then rename.
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: settings,
                options: [.prettyPrinted, .sortedKeys]
            )
            let tmpURL = fileURL.appendingPathExtension("tmp")
            try jsonData.write(to: tmpURL, options: .atomic)
            _ = try fileManager.replaceItemAt(fileURL, withItemAt: tmpURL)
            print("[ClaudeShine] Set theme to \(theme.rawValue)")
        } catch {
            print("[ClaudeShine] Failed to write settings: \(error)")
        }
    }
}
