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
                    .accessibilityIdentifier(AccessibilityID.Settings.currencyRow)
                }

                Section("Categories") {
                    NavigationLink("Manage Categories") {
                        ManageCategoriesView()
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.manageCategoriesRow)
                    NavigationLink("Featured Categories") {
                        FeaturedCategoriesView()
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.featuredCategoriesRow)
                }

                Section("Tags") {
                    NavigationLink("Manage Tags") {
                        ManageTagsView()
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.manageTagsRow)
                }

                Section("Support") {
                    NavigationLink {
                        TipJarView()
                    } label: {
                        Label("Tip Jar", systemImage: "heart.fill")
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.tipJarRow)
                }

                Section("Backup") {
                    NavigationLink {
                        BackupView()
                    } label: {
                        Label("Backup & Restore", systemImage: "arrow.clockwise.icloud")
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.backupRow)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier(AccessibilityID.Settings.versionLabel)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
