import Foundation

enum Config {
    private enum Keys {
        static let apiURL = "opencode_api_url"
        static let headers = "opencode_headers"
        static let cookie = "opencode_cookie"
    }

    /// Whether the user has saved curl credentials.
    static var isConfigured: Bool {
        UserDefaults.standard.string(forKey: Keys.apiURL) != nil
    }

    static var apiURL: URL? {
        guard let urlString = UserDefaults.standard.string(forKey: Keys.apiURL) else { return nil }
        return URL(string: urlString)
    }

    static var headers: [String: String] {
        UserDefaults.standard.dictionary(forKey: Keys.headers) as? [String: String] ?? [:]
    }

    static var authCookie: String? {
        UserDefaults.standard.string(forKey: Keys.cookie)
    }

    static func save(curlCommand: String) throws {
        let result = try CurlParser.parse(curlCommand)
        UserDefaults.standard.set(result.url.absoluteString, forKey: Keys.apiURL)
        UserDefaults.standard.set(result.headers, forKey: Keys.headers)
        UserDefaults.standard.set(result.cookie, forKey: Keys.cookie)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: Keys.apiURL)
        UserDefaults.standard.removeObject(forKey: Keys.headers)
        UserDefaults.standard.removeObject(forKey: Keys.cookie)
    }
}
