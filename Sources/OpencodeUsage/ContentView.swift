import AppKit
import SwiftUI

struct ContentView: View {
    /// Header icon loaded from bundle Resources as a template image.
    private static let headerIcon: NSImage = {
        let img: NSImage
        if let url = Bundle.main.url(forResource: "opencode-logo", withExtension: "png"),
            let loaded = NSImage(contentsOf: url)
        {
            img = loaded
        } else {
            img =
                NSImage(systemSymbolName: "cpu", accessibilityDescription: "OpencodeUsage")
                ?? NSImage()
        }
        img.isTemplate = true
        img.size = NSSize(width: 16, height: 16)
        return img
    }()
    @StateObject var viewModel: UsageViewModel
    @FocusState private var focusedField: FocusableField?

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            contentView
            Divider()
            footerView
        }
        .frame(width: 260)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: 6) {
            Text("Opencode Go")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)

            Spacer()

            ProgressView()
                .controlSize(.small)
                .scaleEffect(0.7)
                .opacity(viewModel.isLoading ? 1 : 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        if let stats = viewModel.stats {
            VStack(alignment: .leading, spacing: 0) {
                usageCard(title: "Rolling", item: stats.rolling)
                Divider()
                usageCard(title: "Weekly", item: stats.weekly)
                Divider()
                usageCard(title: "Monthly", item: stats.monthly)
            }
        } else if let error = viewModel.errorMessage {
            errorBanner(error)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        } else {
            loadingView
        }
    }

    // MARK: - Usage Card

    private func usageCard(title: String, item: UsageItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text(" (Resets in \(formatDuration(seconds: item.resetInSec)))")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()

                Spacer()

                Text("\(item.usagePercent)%")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
            }

            ProgressView(value: Double(item.usagePercent), total: 100)
                .progressViewStyle(.linear)
                .tint(colorForPercent(item.usagePercent))
                .controlSize(.small)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .controlSize(.small)
            Text("Loading usage...")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 10))
                .foregroundStyle(.orange)
            Text(message)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 8) {
            Button {
                viewModel.refresh()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .focused($focusedField, equals: .refresh)

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .focused($focusedField, equals: .quit)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func colorForPercent(_ percent: Int) -> Color {
        switch percent {
        case 0...50:
            return .green
        case 51...80:
            return .yellow
        default:
            return .red
        }
    }
}

enum FocusableField: Hashable {
    case refresh, quit
}
