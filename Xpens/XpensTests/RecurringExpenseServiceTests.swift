import Testing
import Foundation
import SwiftData
@testable import Xpens

@Suite("RecurringExpenseService")
struct RecurringExpenseServiceTests {

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(
            for: Expense.self, Category.self, Tag.self, UserPreferences.self,
            configurations: config
        )
        return ModelContext(container)
    }

    @Test("monthly template 2 months behind generates 2 expenses")
    func monthlyGeneration() throws {
        let context = try makeContext()
        let cal = Calendar.current
        let asOf = DateComponents(calendar: cal, year: 2024, month: 4, day: 1).date!
        let lastGen = DateComponents(calendar: cal, year: 2024, month: 2, day: 1).date!

        let template = Expense(
            amount: 15.99,
            merchant: "Netflix",
            isRecurring: true,
            recurrenceRule: "monthly",
            lastGeneratedDate: lastGen
        )
        context.insert(template)

        let count = RecurringExpenseService.generatePendingExpenses(
            templates: [template],
            modelContext: context,
            asOf: asOf
        )
        // Feb 1 → Mar 1 (generate), Apr 1 (generate), May 1 (stop)
        #expect(count == 2)
        #expect(template.lastGeneratedDate == asOf)
    }

    @Test("weekly template 3 weeks behind generates 3 expenses")
    func weeklyGeneration() throws {
        let context = try makeContext()
        let cal = Calendar.current
        let asOf = DateComponents(calendar: cal, year: 2024, month: 1, day: 22).date!
        let lastGen = DateComponents(calendar: cal, year: 2024, month: 1, day: 1).date!

        let template = Expense(
            amount: 5.99,
            merchant: "Spotify",
            isRecurring: true,
            recurrenceRule: "weekly",
            lastGeneratedDate: lastGen
        )
        context.insert(template)

        let count = RecurringExpenseService.generatePendingExpenses(
            templates: [template],
            modelContext: context,
            asOf: asOf
        )
        // Jan 1 → Jan 8, Jan 15, Jan 22 = 3
        #expect(count == 3)
    }

    @Test("yearly template 2 years behind generates 2 expenses")
    func yearlyGeneration() throws {
        let context = try makeContext()
        let cal = Calendar.current
        let asOf = DateComponents(calendar: cal, year: 2024, month: 1, day: 1).date!
        let lastGen = DateComponents(calendar: cal, year: 2022, month: 1, day: 1).date!

        let template = Expense(
            amount: 99.99,
            merchant: "Domain Renewal",
            isRecurring: true,
            recurrenceRule: "yearly",
            lastGeneratedDate: lastGen
        )
        context.insert(template)

        let count = RecurringExpenseService.generatePendingExpenses(
            templates: [template],
            modelContext: context,
            asOf: asOf
        )
        // 2022 → 2023, 2024 = 2
        #expect(count == 2)
    }

    @Test("nil lastGeneratedDate falls back to createdAt")
    func usesCreatedAtWhenNoLastGenerated() throws {
        let context = try makeContext()
        let cal = Calendar.current
        let asOf = DateComponents(calendar: cal, year: 2024, month: 4, day: 1).date!
        let created = DateComponents(calendar: cal, year: 2024, month: 2, day: 1).date!

        let template = Expense(
            amount: 15.99,
            merchant: "Netflix",
            createdAt: created,
            isRecurring: true,
            recurrenceRule: "monthly"
        )
        context.insert(template)

        let count = RecurringExpenseService.generatePendingExpenses(
            templates: [template],
            modelContext: context,
            asOf: asOf
        )
        // createdAt Feb 1 → Mar 1, Apr 1 = 2
        #expect(count == 2)
    }

    @Test("up-to-date template generates nothing")
    func upToDateGeneratesNothing() throws {
        let context = try makeContext()
        let cal = Calendar.current
        let asOf = DateComponents(calendar: cal, year: 2024, month: 4, day: 1).date!

        let template = Expense(
            amount: 15.99,
            merchant: "Netflix",
            isRecurring: true,
            recurrenceRule: "monthly",
            lastGeneratedDate: asOf
        )
        context.insert(template)

        let count = RecurringExpenseService.generatePendingExpenses(
            templates: [template],
            modelContext: context,
            asOf: asOf
        )
        #expect(count == 0)
    }

    @Test("generated expenses copy template fields but are not recurring")
    func generatedExpenseCopiesFields() throws {
        let context = try makeContext()
        let cal = Calendar.current
        let asOf = DateComponents(calendar: cal, year: 2024, month: 3, day: 1).date!
        let lastGen = DateComponents(calendar: cal, year: 2024, month: 2, day: 1).date!

        let template = Expense(
            amount: 15.99,
            merchant: "Netflix",
            client: "Personal",
            notes: "Streaming subscription",
            isRecurring: true,
            recurrenceRule: "monthly",
            lastGeneratedDate: lastGen
        )
        context.insert(template)

        let count = RecurringExpenseService.generatePendingExpenses(
            templates: [template],
            modelContext: context,
            asOf: asOf
        )
        #expect(count == 1)

        // Fetch non-recurring expenses to verify the generated one
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { !$0.isRecurring }
        )
        let generated = try context.fetch(descriptor)
        #expect(generated.count == 1)

        let expense = generated[0]
        #expect(expense.amount == 15.99)
        #expect(expense.merchant == "Netflix")
        #expect(expense.client == "Personal")
        #expect(expense.notes == "Streaming subscription")
        #expect(expense.isRecurring == false)
        #expect(expense.recurrenceRule == nil)
    }

    @Test("non-recurring expense in templates array is skipped")
    func skipsNonRecurring() throws {
        let context = try makeContext()
        let cal = Calendar.current
        let asOf = DateComponents(calendar: cal, year: 2024, month: 4, day: 1).date!

        let normalExpense = Expense(amount: 50, merchant: "Lunch")
        context.insert(normalExpense)

        let count = RecurringExpenseService.generatePendingExpenses(
            templates: [normalExpense],
            modelContext: context,
            asOf: asOf
        )
        #expect(count == 0)
    }
}
