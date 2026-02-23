import SwiftUI
import SwiftData

@main
struct XpensApp: App {
    let container: ModelContainer

    init() {
        let container = try! ModelContainer(for: Expense.self, Category.self, Tag.self, UserPreferences.self)
        self.container = container

        let context = container.mainContext
        let prefs = (try? context.fetch(FetchDescriptor<UserPreferences>()))?.first
        CurrencyFormatter.setCurrency(code: prefs?.currencyCode ?? "USD")
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(container)
    }
}