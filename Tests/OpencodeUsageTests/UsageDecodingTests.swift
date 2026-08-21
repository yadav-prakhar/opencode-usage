import Foundation
@testable import OpencodeUsage
import Testing

struct UsageDecodingTests {
    private static func json(resetsAt: String) -> Data {
        """
        {
          "usage": {
            "rolling": { "status": "allowed", "percent": 10,  "resetsAt": "\(resetsAt)" },
            "weekly":  { "status": "allowed", "percent": 34,  "resetsAt": "\(resetsAt)" },
            "monthly": { "status": "allowed", "percent": 56,  "resetsAt": "\(resetsAt)" }
          }
        }
        """.data(using: .utf8)!
    }

    @Test func decodesFractionalSecondsTimestamps() throws {
        let response = try NetworkManager.decoder.decode(UsageResponse.self, from: Self.json(resetsAt: "2026-08-22T12:00:00.123Z"))
        #expect(response.usage.rolling.percent == 10)
        #expect(response.usage.rolling.resetsAt.timeIntervalSince1970 == 1_787_400_000.123)
    }

    @Test func decodesWholeSecondTimestamps() throws {
        let response = try NetworkManager.decoder.decode(UsageResponse.self, from: Self.json(resetsAt: "2026-08-22T12:00:00Z"))
        #expect(response.usage.monthly.resetsAt == Date(timeIntervalSince1970: 1_787_400_000))
    }

    @Test func invalidDateThrowsDecodingError() {
        #expect(throws: DecodingError.self) {
            try NetworkManager.decoder.decode(UsageResponse.self, from: Self.json(resetsAt: "not-a-date"))
        }
    }

    @Test func usageLevelRoundTripFromDecodedPercent() throws {
        let response = try NetworkManager.decoder.decode(UsageResponse.self, from: Self.json(resetsAt: "2026-08-22T12:00:00Z"))
        #expect(UsageLevel(percent: response.usage.weekly.percent) == .safe)
    }
}
