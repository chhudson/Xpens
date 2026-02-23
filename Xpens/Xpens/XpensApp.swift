import SwiftUI
import SwiftData

@main
struct XpensApp: App {
    let container: ModelContainer

    init() {
        let config = ModelConfiguration(cloudKitDatabase: .none)
        let container = try! ModelContainer(
            for: Expense.self, Category.self, Tag.self, UserPreferences.self,
            configurations: config
        )
        self.container = container

        #if DEBUG
        if CommandLine.arguments.contains("--uitesting-reset") {
            let resetContext = container.mainContext
            try? resetContext.delete(model: Expense.self)
            try? resetContext.delete(model: Category.self)
            try? resetContext.delete(model: Tag.self)
            try? resetContext.delete(model: UserPreferences.self)
            try? resetContext.save()
        }
        if CommandLine.arguments.contains("--uitesting-skip-onboarding") {
            let seedContext = container.mainContext
            let existingPrefs = (try? seedContext.fetch(FetchDescriptor<UserPreferences>()))?.first
            if existingPrefs == nil {
                let categories = Category.createDefaults()
                for cat in categories { seedContext.insert(cat) }
                let prefs = UserPreferences(
                    currencyCode: "USD",
                    hasCompletedOnboarding: true,
                    featuredCategoryIDs: Array(categories.prefix(4).map(\.id))
                )
                seedContext.insert(prefs)
                try? seedContext.save()
            }
        }
        #endif

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
