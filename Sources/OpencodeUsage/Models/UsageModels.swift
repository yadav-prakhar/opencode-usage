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

enum UsageLevel: Equatable {
    case safe
    case elevated
    case critical

    init(percent: Int) {
        switch percent {
        case ..<51: self = .safe
        case ..<81: self = .elevated
        default: self = .critical
        }
    }
}
