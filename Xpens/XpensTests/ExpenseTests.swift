import Testing
import Foundation
@testable import Xpens

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
        #expect(expense.category == .food)
    }

    @Test("custom initializer stores all fields")
    func customInit() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let expense = Expense(
            date: date,
            category: .hotel,
            amount: 249.99,
            merchant: "Hilton",
            client: "Acme Corp",
            notes: "Business trip"
        )
        #expect(expense.date == date)
        #expect(expense.category == .hotel)
        #expect(expense.amount == 249.99)
        #expect(expense.merchant == "Hilton")
        #expect(expense.client == "Acme Corp")
        #expect(expense.notes == "Business trip")
    }

    @Test("category computed property writes raw value")
    func categoryWritesRawValue() {
        let expense = Expense()
        expense.category = .rideshare
        #expect(expense.categoryRawValue == "rideshare")
        #expect(expense.category == .rideshare)
    }

    @Test("invalid raw value defaults to food")
    func invalidCategoryDefaultsToFood() {
        let expense = Expense()
        expense.categoryRawValue = "invalid_category"
        #expect(expense.category == .food)
    }

    @Test("each instance gets a unique UUID")
    func uniqueIds() {
        let a = Expense()
        let b = Expense()
        #expect(a.id != b.id)
    }
}
