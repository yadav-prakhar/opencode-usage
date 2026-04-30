import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: UsageViewModel
    @Binding var isPresented: Bool
    let isFirstSetup: Bool

    @State private var curlCommand: String = ""
    @State private var errorMessage: String?
    @State private var isSaving = false
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            Divider()
            formView
            if let error = errorMessage {
                errorView(error)
            }
            Divider()
            buttonRow
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text(isFirstSetup ? "Setup Required" : "Settings")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Form

    private var formView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Paste curl command from browser DevTools:")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            TextEditor(text: $curlCommand)
                .font(.system(size: 11, design: .monospaced))
                .frame(height: 80)
                .focused($isTextEditorFocused)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        .background(Color.secondary.opacity(0.05))
                )
                .onChange(of: curlCommand) { _, _ in
                    errorMessage = nil
                }

            Text("Right-click request → Copy → Copy as cURL (bash)")
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 10))
                .foregroundStyle(.orange)
            Text(message)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Buttons

    private var buttonRow: some View {
        HStack(spacing: 8) {
            Button {
                save()
            } label: {
                HStack(spacing: 4) {
                    if isSaving {
                        ProgressView()
                            .controlSize(.small)
                            .scaleEffect(0.6)
                    }
                    Text("Save")
                }
                .font(.system(size: 11))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(curlCommand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)

            if !isFirstSetup {
                Button {
                    isPresented = false
                } label: {
                    Text("Cancel")
                        .font(.system(size: 11))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Actions

    private func save() {
        isSaving = true
        errorMessage = nil

        do {
            try Config.save(curlCommand: curlCommand)
            isSaving = false
            isPresented = false
            viewModel.credentialsUpdated()
        } catch let parseError as CurlParserError {
            isSaving = false
            errorMessage = parseError.localizedDescription
        } catch {
            isSaving = false
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
}
