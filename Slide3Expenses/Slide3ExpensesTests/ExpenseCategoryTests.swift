import Testing
@testable import Slide3Expenses

@Suite("ExpenseCategory")
struct ExpenseCategoryTests {

    @Test("all cases have non-empty display names")
    func displayNames() {
        for category in ExpenseCategory.allCases {
            #expect(!category.displayName.isEmpty)
        }
    }

    @Test("all cases have SF Symbol icon names")
    func icons() {
        for category in ExpenseCategory.allCases {
            #expect(!category.icon.isEmpty)
        }
    }

    @Test("specific display names match expected values")
    func specificDisplayNames() {
        #expect(ExpenseCategory.airlineTickets.displayName == "Airline Tickets")
        #expect(ExpenseCategory.hotel.displayName == "Hotel")
        #expect(ExpenseCategory.rideshare.displayName == "Rideshare")
        #expect(ExpenseCategory.food.displayName == "Food")
    }

    @Test("raw values round-trip correctly")
    func rawValueRoundTrip() {
        for category in ExpenseCategory.allCases {
            let restored = ExpenseCategory(rawValue: category.rawValue)
            #expect(restored == category)
        }
    }

    @Test("id matches raw value")
    func idMatchesRawValue() {
        for category in ExpenseCategory.allCases {
            #expect(category.id == category.rawValue)
        }
    }

    @Test("there are exactly four categories")
    func categoryCount() {
        #expect(ExpenseCategory.allCases.count == 4)
    }
}
