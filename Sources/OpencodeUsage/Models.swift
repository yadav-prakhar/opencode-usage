import Foundation

struct UsageItem: Equatable, Codable {
    let status: String
    let percent: Int
    let resetsAt: Date
}

struct UsageStats: Equatable, Codable {
    let rolling: UsageItem
    let weekly: UsageItem
    let monthly: UsageItem
}

struct UsageResponse: Codable {
    let usage: UsageStats
}
