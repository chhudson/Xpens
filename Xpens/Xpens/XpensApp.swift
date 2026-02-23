import SwiftUI
import SwiftData

@main
struct XpensApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Expense.self)
    }
}