import Foundation

struct UsageItem: Equatable {
    let status: String
    let resetInSec: Int
    let usagePercent: Int
}

struct UsageStats: Equatable {
    let rolling: UsageItem
    let weekly: UsageItem
    let monthly: UsageItem
}
