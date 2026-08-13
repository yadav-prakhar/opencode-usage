import Foundation

enum Config {
    private enum Keys {
        static let apiKey = "opencode_api_key"
        static let progressAccent = "opencode_progress_accent"
    }

    /// Whether the user has saved an API key.
    static var isConfigured: Bool {
        UserDefaults.standard.string(forKey: Keys.apiKey) != nil
    }

    static var apiKey: String? {
        UserDefaults.standard.string(forKey: Keys.apiKey)
    }

    static var progressAccent: Bool {
        UserDefaults.standard.bool(forKey: Keys.progressAccent)
    }

    static func setProgressAccent(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Keys.progressAccent)
    }

    static func save(apiKey: String) {
        UserDefaults.standard.set(apiKey, forKey: Keys.apiKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: Keys.apiKey)
    }
}
