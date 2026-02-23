import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var date: Date
    var categoryRawValue: String
    var amount: Decimal
    var merchant: String
    var client: String
    var notes: String
    var receiptImagePath: String?
    var createdAt: Date

    var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRawValue) ?? .food }
        set { categoryRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        date: Date = .now,
        category: ExpenseCategory = .food,
        amount: Decimal = 0,
        merchant: String = "",
        client: String = "",
        notes: String = "",
        receiptImagePath: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.date = date
        self.categoryRawValue = category.rawValue
        self.amount = amount
        self.merchant = merchant
        self.client = client
        self.notes = notes
        self.receiptImagePath = receiptImagePath
        self.createdAt = createdAt
    }
}
