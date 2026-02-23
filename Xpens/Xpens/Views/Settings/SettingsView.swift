import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var allPreferences: [UserPreferences]

    private var prefs: UserPreferences? { allPreferences.first }

    var body: some View {
        NavigationStack {
            Form {
                Section("Currency") {
                    NavigationLink {
                        CurrencyPickerView()
                    } label: {
                        HStack {
                            Text("Default Currency")
                            Spacer()
                            Text(prefs?.currencyCode ?? "USD")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Categories") {
                    NavigationLink("Manage Categories") {
                        ManageCategoriesView()
                    }
                    NavigationLink("Featured Categories") {
                        FeaturedCategoriesView()
                    }
                }

                Section("Tags") {
                    NavigationLink("Manage Tags") {
                        ManageTagsView()
                    }
                }

                Section("Backup") {
                    NavigationLink {
                        BackupView()
                    } label: {
                        Label("Backup & Restore", systemImage: "arrow.clockwise.icloud")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
