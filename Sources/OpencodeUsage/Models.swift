import Foundation

struct UsageItem {
    let status: String
    let resetInSec: Int
    let usagePercent: Int
}

struct UsageStats {
    let rolling: UsageItem
    let weekly: UsageItem
    let monthly: UsageItem
}
