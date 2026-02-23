import SwiftUI
import SwiftData

struct BackupView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var backups: [BackupService.BackupInfo] = []
    @State private var isBackingUp = false
    @State private var isRestoring = false
    @State private var selectedBackup: BackupService.BackupInfo?
    @State private var showingRestoreAlert = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingSuccess = false
    @State private var successMessage = ""

    var body: some View {
        List {
            backupSection
            if !backups.isEmpty {
                backupListSection
            }
        }
        .navigationTitle("Backup")
        .onAppear { loadBackups() }
        .alert("Restore Backup?", isPresented: $showingRestoreAlert, presenting: selectedBackup) { backup in
            Button("Restore", role: .destructive) { performRestore(backup) }
            Button("Cancel", role: .cancel) {}
        } message: { backup in
            Text("This will replace all current data with the backup from \(backup.date.formatted(date: .abbreviated, time: .shortened)). This cannot be undone.")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An unknown error occurred.")
        }
        .alert("Success", isPresented: $showingSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(successMessage)
        }
    }

    // MARK: - Sections

    private var backupSection: some View {
        Section {
            Button {
                performBackup()
            } label: {
                HStack {
                    Label("Back Up Now", systemImage: "arrow.clockwise.icloud")
                    if isBackingUp {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .disabled(isBackingUp || isRestoring)
        } footer: {
            if FileManager.default.ubiquityIdentityToken != nil {
                Text("Backups are stored in iCloud Drive.")
            } else {
                Text("iCloud is not available. Backups are stored locally on this device.")
            }
        }
    }

    private var backupListSection: some View {
        Section("Backups") {
            ForEach(backups) { backup in
                Button {
                    selectedBackup = backup
                    showingRestoreAlert = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(backup.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text("\(backup.expenseCount) expenses \u{00B7} \(formattedSize(backup.size))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.blue)
                    }
                }
                .disabled(isRestoring)
            }
            .onDelete(perform: deleteBackups)
        }
    }

    // MARK: - Actions

    private func loadBackups() {
        backups = BackupService.listBackups()
    }

    private func performBackup() {
        isBackingUp = true
        Task {
            do {
                try BackupService.backup(modelContext: modelContext)
                successMessage = "Backup completed successfully."
                showingSuccess = true
                loadBackups()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
            isBackingUp = false
        }
    }

    private func performRestore(_ backup: BackupService.BackupInfo) {
        isRestoring = true
        Task {
            do {
                try BackupService.restore(from: backup, modelContext: modelContext)
                successMessage = "Restore completed successfully."
                showingSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
            isRestoring = false
        }
    }

    private func deleteBackups(at offsets: IndexSet) {
        for index in offsets {
            try? BackupService.deleteBackup(backups[index])
        }
        loadBackups()
    }

    private func formattedSize(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}
