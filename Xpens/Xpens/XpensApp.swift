import SwiftUI
import SwiftData

@main
struct XpensApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [Expense.self, Category.self, Tag.self, UserPreferences.self])
    }
}