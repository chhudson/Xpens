import SwiftUI
import SwiftData

@main
struct Slide3ExpensesApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Expense.self)
    }
}