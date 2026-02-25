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
        if CommandLine.arguments.contains("--uitesting-seed-screenshots") {
            let ctx = container.mainContext
            let categories = (try? ctx.fetch(FetchDescriptor<Category>())) ?? []
            func cat(_ name: String) -> Category? {
                categories.first { $0.name == name }
            }
            let cal = Calendar.current
            let now = Date.now
            let tag1 = Tag(name: "tax-deductible", color: "#2196F3")
            let tag2 = Tag(name: "Q1-2026", color: "#4CAF50")
            let tag3 = Tag(name: "client: Acme", color: "#FF9800")
            ctx.insert(tag1)
            ctx.insert(tag2)
            ctx.insert(tag3)
            let sampleExpenses: [(String, Decimal, String, String, Category?, [Tag]?, Int)] = [
                ("Delta Airlines", 487.50, "Acme Corp", "", cat("Airline Tickets"), [tag1, tag3], -1),
                ("Marriott Downtown", 219.00, "Acme Corp", "", cat("Hotel"), [tag1, tag3], -2),
                ("Marriott Downtown", 219.00, "Acme Corp", "", cat("Hotel"), [tag1, tag3], -3),
                ("Uber to Airport", 34.75, "Acme Corp", "", cat("Rideshare"), [tag3], -1),
                ("Lyft to Hotel", 28.50, "Acme Corp", "", cat("Rideshare"), [tag3], -2),
                ("Blue Bottle Coffee", 6.25, "", "Morning coffee", cat("Food"), [tag2], 0),
                ("Chipotle", 14.85, "", "Lunch", cat("Food"), [tag2], -1),
                ("The Capital Grille", 87.40, "Acme Corp", "Client dinner", cat("Food"), [tag1, tag2, tag3], -3),
                ("Sweetgreen", 16.50, "", "Lunch", cat("Food"), [tag2], -5),
                ("Starbucks", 5.75, "", "", cat("Food"), nil, -7),
                ("Airport Parking", 45.00, "", "", cat("Parking"), [tag1], -1),
                ("Staples", 32.60, "", "Printer paper & pens", cat("Office Supplies"), [tag1], -4),
                ("Broadway Show", 125.00, "", "Team outing", cat("Entertainment"), nil, -6),
            ]
            for (merchant, amount, client, notes, category, tags, dayOffset) in sampleExpenses {
                let date = cal.date(byAdding: .day, value: dayOffset, to: now) ?? now
                let expense = Expense(
                    date: date,
                    category: category,
                    tags: tags,
                    amount: amount,
                    merchant: merchant,
                    client: client,
                    notes: notes
                )
                ctx.insert(expense)
            }
            try? ctx.save()
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
