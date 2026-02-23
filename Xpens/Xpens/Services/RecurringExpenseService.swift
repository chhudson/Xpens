import Foundation
import SwiftData

enum RecurringExpenseService {

    /// Generates new expenses from recurring templates that are behind schedule.
    /// Each template's `lastGeneratedDate` is advanced as entries are created.
    /// - Returns: The number of expenses generated.
    @discardableResult
    static func generatePendingExpenses(
        templates: [Expense],
        modelContext: ModelContext,
        asOf: Date = .now
    ) -> Int {
        var count = 0
        let calendar = Calendar.current

        for template in templates where template.isRecurring {
            guard let rule = template.recurrenceRule,
                  let component = calendarComponent(for: rule) else { continue }

            let startDate = template.lastGeneratedDate ?? template.createdAt

            var nextDate = calendar.date(byAdding: component, value: 1, to: startDate)!
            while nextDate <= asOf {
                let expense = Expense(
                    date: nextDate,
                    category: template.category,
                    tags: template.tags,
                    amount: template.amount,
                    merchant: template.merchant,
                    client: template.client,
                    notes: template.notes
                )
                modelContext.insert(expense)
                template.lastGeneratedDate = nextDate
                count += 1
                nextDate = calendar.date(byAdding: component, value: 1, to: nextDate)!
            }
        }

        return count
    }

    private static func calendarComponent(for rule: String) -> Calendar.Component? {
        switch rule {
        case "weekly": return .weekOfYear
        case "monthly": return .month
        case "yearly": return .year
        default: return nil
        }
    }
}
