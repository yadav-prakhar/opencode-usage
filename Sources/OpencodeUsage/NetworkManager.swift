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
        case .notConfigured: return "Not configured. Please open Settings and paste your curl command."
        case .authExpired: return "Authentication expired. Please update your credentials in Settings."
        }
    }
}

final class NetworkManager: @unchecked Sendable {
    private let logger = Logger(subsystem: "com.wiscaksono.opencode-usage", category: "Network")

    func fetchUsage() async throws -> UsageStats {
        guard let apiURL = Config.apiURL else {
            logger.error("API URL not configured")
            throw NetworkError.notConfigured
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 15

        for (key, value) in Config.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let cookie = Config.authCookie {
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
        } else {
            logger.error("Auth cookie not configured")
            throw NetworkError.notConfigured
        }

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

        guard let rawString = String(data: data, encoding: .utf8) else {
            logger.error("Failed to decode response data to string")
            throw NetworkError.invalidData
        }

        logger.info("Parsing response...")
        return try parseResponse(rawString)
    }

    private func parseResponse(_ raw: String) throws -> UsageStats {
        let rolling = try extractItem(from: raw, label: "rollingUsage")
        let weekly = try extractItem(from: raw, label: "weeklyUsage")
        let monthly = try extractItem(from: raw, label: "monthlyUsage")
        logger.info("Parsed usage stats successfully")
        return UsageStats(rolling: rolling, weekly: weekly, monthly: monthly)
    }

    private static let regexCache: [String: NSRegularExpression] = {
        let labels = ["rollingUsage", "weeklyUsage", "monthlyUsage"]
        var cache: [String: NSRegularExpression] = [:]
        for label in labels {
            let pattern = "\(label):\\s*\\$R\\[\\d+\\]\\s*=\\s*\\{\\s*status:\\s*\"([^\"]+)\",\\s*resetInSec:\\s*(\\d+),\\s*usagePercent:\\s*(\\d+)\\s*\\}"
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
                cache[label] = regex
            }
        }
        return cache
    }()

    private func extractItem(from raw: String, label: String) throws -> UsageItem {
        guard let regex = Self.regexCache[label] else {
            throw NetworkError.parseError
        }

        let nsRange = NSRange(location: 0, length: raw.utf16.count)
        guard let match = regex.firstMatch(in: raw, options: [], range: nsRange) else {
            logger.error("Regex failed to match label: \(label)")
            throw NetworkError.parseError
        }

        guard let statusRange = Range(match.range(at: 1), in: raw),
              let resetRange = Range(match.range(at: 2), in: raw),
              let percentRange = Range(match.range(at: 3), in: raw),
              let resetInSec = Int(raw[resetRange]),
              let usagePercent = Int(raw[percentRange]) else {
            logger.error("Failed to extract values for label: \(label)")
            throw NetworkError.parseError
        }

        let status = String(raw[statusRange])
        return UsageItem(status: status, resetInSec: resetInSec, usagePercent: usagePercent)
    }
}
