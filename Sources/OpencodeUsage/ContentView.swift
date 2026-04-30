import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: UsageViewModel
    @FocusState private var focusedField: FocusableField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView
            
            Divider()
            
            if let stats = viewModel.stats {
                usageSection(title: "Rolling Usage", item: stats.rolling)
                usageSection(title: "Weekly Usage", item: stats.weekly)
                usageSection(title: "Monthly Usage", item: stats.monthly)
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                    Spacer()
                }
            }
            
            Divider()
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.refresh()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .focused($focusedField, equals: .refresh)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Label("Quit", systemImage: "power")
                        .frame(maxWidth: .infinity)
                }
                .focused($focusedField, equals: .quit)
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(20)
        .frame(width: 300)
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "cpu")
                .font(.title2)
                .foregroundColor(.primary)
            Text("Opencode Go")
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
    }
    
    private func usageSection(title: String, item: UsageItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatDuration(seconds: item.resetInSec))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(item.usagePercent)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("%")
                    .font(.title3)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            ProgressView(value: Double(item.usagePercent), total: 100)
                .progressViewStyle(.linear)
                .tint(.primary)
        }
    }
}

enum FocusableField: Hashable {
    case refresh, quit
}
