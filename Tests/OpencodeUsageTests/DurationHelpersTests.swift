import Foundation
@testable import OpencodeUsage
import Testing

struct DurationHelpersTests {
    @Test func underAMinute() {
        #expect(formatDuration(seconds: 0) == "< 1m")
        #expect(formatDuration(seconds: 59) == "< 1m")
    }

    @Test func minutesOnly() {
        #expect(formatDuration(seconds: 60) == "1m")
        #expect(formatDuration(seconds: 3599) == "59m")
    }

    @Test func hoursAndMinutes() {
        #expect(formatDuration(seconds: 3600) == "1h")
        #expect(formatDuration(seconds: 5400) == "1h 30m")
    }

    @Test func daysHoursMinutes() {
        #expect(formatDuration(seconds: 90061) == "1d 1h 1m")
        #expect(formatDuration(seconds: 86400 * 2 + 60) == "2d 1m")
    }

    @Test func secondsUntilClampsNegativeDatesToZero() {
        let past = Date(timeIntervalSinceNow: -120)
        #expect(secondsUntil(past) == 0)
    }

    @Test func secondsUntilFutureDate() {
        let future = Date(timeIntervalSinceNow: 120)
        let value = secondsUntil(future)
        #expect((115 ... 125).contains(value))
    }
}
