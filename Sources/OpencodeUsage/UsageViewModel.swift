import Foundation
import Combine
import os

@MainActor
class UsageViewModel: ObservableObject {
    @Published var stats: UsageStats?
    @Published var menuBarTitle: String = "--%"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var timer: Timer?
    private let networkManager = NetworkManager()
    private let logger = Logger(subsystem: "com.wiscaksono.opencode-usage", category: "Usage")

    init() {
        startMonitoring()
    }

    func startMonitoring() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task { @MainActor in
                self.refresh()
            }
        }
    }

    func refresh() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        logger.info("Refreshing usage data...")

        Task {
            do {
                let newStats = try await networkManager.fetchUsage()
                self.stats = newStats
                self.menuBarTitle = "\(newStats.rolling.usagePercent)%"
                logger.info("Usage updated: rolling=\(newStats.rolling.usagePercent)%, weekly=\(newStats.weekly.usagePercent)%, monthly=\(newStats.monthly.usagePercent)%")
            } catch {
                self.errorMessage = error.localizedDescription
                logger.error("Failed to refresh usage: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}
