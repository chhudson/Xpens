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

        // Generate any pending recurring expenses
        let recurringDescriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { $0.isRecurring }
        )
        if let templates = try? context.fetch(recurringDescriptor), !templates.isEmpty {
            RecurringExpenseService.generatePendingExpenses(
                templates: templates,
                modelContext: context
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}

private struct RootView: View {
    @Query private var allPreferences: [UserPreferences]

    private var hasCompletedOnboarding: Bool {
        allPreferences.first?.hasCompletedOnboarding ?? false
    }

    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}
