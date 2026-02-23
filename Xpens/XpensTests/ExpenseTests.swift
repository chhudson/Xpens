import Testing
import Foundation
@testable import Xpens

private typealias ExpenseCategory = Xpens.Category

@Suite("Expense")
struct ExpenseTests {

    @Test("default initializer sets expected values")
    func defaultInit() {
        let expense = Expense()
        #expect(expense.amount == 0)
        #expect(expense.merchant == "")
        #expect(expense.client == "")
        #expect(expense.notes == "")
        #expect(expense.receiptImagePath == nil)
        #expect(expense.category == nil)
        #expect(expense.tags == nil)
        #expect(expense.isRecurring == false)
        #expect(expense.recurrenceRule == nil)
    }

    @Test("custom initializer stores all fields")
    func customInit() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let category = ExpenseCategory(name: "Hotel", icon: "building.2", color: "#9C27B0", sortOrder: 1)
        let expense = Expense(
            date: date,
            category: category,
            amount: 249.99,
            merchant: "Hilton",
            client: "Acme Corp",
            notes: "Business trip"
        )
        #expect(expense.date == date)
        #expect(expense.category?.name == "Hotel")
        #expect(expense.amount == 249.99)
        #expect(expense.merchant == "Hilton")
        #expect(expense.client == "Acme Corp")
        #expect(expense.notes == "Business trip")
    }

    @Test("category relationship can be set to nil")
    func categoryCanBeNil() {
        let expense = Expense()
        #expect(expense.category == nil)
    }

    @Test("each instance gets a unique UUID")
    func uniqueIds() {
        let a = Expense()
        let b = Expense()
        #expect(a.id != b.id)
    }

    @Test("recurring fields default correctly")
    func recurringDefaults() {
        let expense = Expense()
        #expect(expense.isRecurring == false)
        #expect(expense.recurrenceRule == nil)
        #expect(expense.lastGeneratedDate == nil)
    }

    @Test("recurring fields can be set via init")
    func recurringInit() {
        let expense = Expense(
            isRecurring: true,
            recurrenceRule: "monthly"
        )
        #expect(expense.isRecurring == true)
        #expect(expense.recurrenceRule == "monthly")
    }
}
