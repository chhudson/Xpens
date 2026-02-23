import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Expenses", systemImage: "list.bullet") {
                ExpenseListView()
            }
            .accessibilityIdentifier(AccessibilityID.Tabs.expenses)

            Tab("Add Expense", systemImage: "plus.circle") {
                AddExpenseView()
            }
            .accessibilityIdentifier(AccessibilityID.Tabs.addExpense)

            Tab("Reports", systemImage: "chart.bar") {
                ReportsView()
            }
            .accessibilityIdentifier(AccessibilityID.Tabs.reports)

            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
            .accessibilityIdentifier(AccessibilityID.Tabs.settings)
        }
    }
}
