import SwiftUI
import os

@main
struct OpencodeUsageApp: App {
    @StateObject private var viewModel = UsageViewModel()
    private let logger = Logger(subsystem: "com.wiscaksono.opencode-usage", category: "App")

    init() {
        logger.info("OpencodeUsage app started")
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView(viewModel: viewModel)
        } label: {
            Text(viewModel.menuBarTitle)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.primary)
        }
        .menuBarExtraStyle(.window)
    }
}
