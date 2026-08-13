import Foundation
import os

enum NetworkError: Error, LocalizedError {
    case invalidData
    case parseError
    case requestFailed
    case notConfigured
    case authExpired

    var errorDescription: String? {
        switch self {
        case .invalidData: return "Invalid data received"
        case .parseError: return "Failed to parse server response"
        case .requestFailed: return "Request failed"
        case .notConfigured: return "Not configured. Please open Settings and paste your API key."
        case .authExpired: return "Authentication expired. Please update your API key in Settings."
        }
    }
}

final class NetworkManager: @unchecked Sendable {
    private let logger = Logger(subsystem: "com.wiscaksono.opencode-usage", category: "Network")
    private let endpoint = URL(string: "https://opencode.ai/zen/go/v1/usage")!

    func fetchUsage() async throws -> UsageStats {
        guard let apiKey = Config.apiKey else {
            logger.error("API key not configured")
            throw NetworkError.notConfigured
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        logger.info("Fetching usage from API...")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            logger.error("API request failed with status: \(statusCode)")
            if statusCode == 401 || statusCode == 403 {
                throw NetworkError.authExpired
            }
            throw NetworkError.requestFailed
        }

        logger.info("Parsing response...")
        do {
            let decoded = try Self.decoder.decode(UsageResponse.self, from: data)
            logger.info("Parsed usage stats successfully")
            return decoded.usage
        } catch {
            logger.error("Failed to decode response: \(error.localizedDescription)")
            throw NetworkError.parseError
        }
    }

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = formatter.date(from: dateString) {
                return date
            }
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(dateString)")
        }
        return decoder
    }()
}
