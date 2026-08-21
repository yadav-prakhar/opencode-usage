import Foundation

func secondsUntil(_ date: Date) -> Int {
    max(0, Int(date.timeIntervalSinceNow))
}

func formatDuration(seconds: Int) -> String {
    let days = seconds / 86400
    let hrs = (seconds % 86400) / 3600
    let mins = (seconds % 3600) / 60

    var parts: [String] = []
    if days > 0 {
        parts.append("\(days)d")
    }
    if hrs > 0 {
        parts.append("\(hrs)h")
    }
    if mins > 0 {
        parts.append("\(mins)m")
    }

    return parts.isEmpty ? "< 1m" : parts.joined(separator: " ")
}
