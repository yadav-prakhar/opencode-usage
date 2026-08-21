import Foundation
import Security

enum KeychainError: Error, LocalizedError {
    case unhandled(OSStatus)

    var errorDescription: String? {
        switch self {
        case let .unhandled(status):
            "Keychain operation failed with OSStatus \(status)"
        }
    }
}

struct KeychainStore {
    let service: String

    /// Fixed account name so queries always resolve to exactly one item, regardless
    /// of unrelated items that older app versions may have stored under the service.
    private static let account = "api-key"

    init(service: String = Bundle.main.bundleIdentifier ?? "opencode-usage") {
        self.service = service
    }

    /// Data-protection keychain requires code signing entitlements; ad-hoc builds may
    /// lack them, so probe once per launch and fall back to the legacy keychain.
    private static let usesDataProtectionKeychain: Bool = {
        let probeService = "\(Bundle.main.bundleIdentifier ?? "opencode-usage").probe"
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: probeService,
            kSecUseDataProtectionKeychain as String: true,
        ]
        SecItemDelete(query as CFDictionary)
        query[kSecValueData as String] = Data("probe".utf8)
        let status = SecItemAdd(query as CFDictionary, nil)
        SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }()

    private var baseQuery: [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: Self.account,
        ]
        if Self.usesDataProtectionKeychain {
            query[kSecUseDataProtectionKeychain as String] = true
        }
        return query
    }

    func save(_ secret: String) throws {
        let data = Data(secret.utf8)
        let update: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(baseQuery as CFDictionary, update as CFDictionary)

        switch updateStatus {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            var addQuery = baseQuery
            addQuery[kSecValueData as String] = data
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw KeychainError.unhandled(addStatus) }
        default:
            throw KeychainError.unhandled(updateStatus)
        }
    }

    func read() -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(decoding: data, as: UTF8.self)
    }

    func delete() {
        SecItemDelete(baseQuery as CFDictionary)
    }
}
