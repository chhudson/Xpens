import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var date: Date
    var amount: Decimal
    var merchant: String
    var client: String
    var notes: String
    var receiptImagePath: String?
    var createdAt: Date
    var isRecurring: Bool
    var recurrenceRule: String?
    var lastGeneratedDate: Date?

    var category: Category?
    var tags: [Tag]?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        category: Category? = nil,
        tags: [Tag]? = nil,
        amount: Decimal = 0,
        merchant: String = "",
        client: String = "",
        notes: String = "",
        receiptImagePath: String? = nil,
        createdAt: Date = .now,
        isRecurring: Bool = false,
        recurrenceRule: String? = nil,
        lastGeneratedDate: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.category = category
        self.tags = tags
        self.amount = amount
        self.merchant = merchant
        self.client = client
        self.notes = notes
        self.receiptImagePath = receiptImagePath
        self.createdAt = createdAt
        self.isRecurring = isRecurring
        self.recurrenceRule = recurrenceRule
        self.lastGeneratedDate = lastGeneratedDate
    }
}
