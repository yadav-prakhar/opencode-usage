@testable import OpencodeUsage
import Testing

struct UsageLevelTests {
    @Test func boundaries() {
        #expect(UsageLevel(percent: 0) == .safe)
        #expect(UsageLevel(percent: 50) == .safe)
        #expect(UsageLevel(percent: 51) == .elevated)
        #expect(UsageLevel(percent: 80) == .elevated)
        #expect(UsageLevel(percent: 81) == .critical)
        #expect(UsageLevel(percent: 100) == .critical)
    }

    @Test func outOfRangeValuesDoNotCrash() {
        #expect(UsageLevel(percent: -10) == .safe)
        #expect(UsageLevel(percent: 500) == .critical)
    }
}
