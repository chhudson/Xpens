import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Expenses", systemImage: "list.bullet") {
                ExpenseListView()
            }

            Tab("Add Expense", systemImage: "plus.circle") {
                AddExpenseView()
            }

            Tab("Reports", systemImage: "chart.bar") {
                ReportsView()
            }

            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
    }
}
