import SwiftUI

struct RecurringExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            categoryIcon
            details
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                amountLabel
                frequencyBadge
            }
        }
        .padding(.vertical, 4)
    }

    private var categoryIcon: some View {
        ZStack {
            Image(systemName: expense.category?.icon ?? "questionmark")
                .font(.title3)
                .foregroundStyle(expense.category?.swiftUIColor ?? .gray)
        }
        .frame(width: 36, height: 36)
        .background((expense.category?.swiftUIColor ?? .gray).opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 8, weight: .bold))
                .padding(2)
                .background(.background)
                .clipShape(Circle())
                .offset(x: 4, y: 4)
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(expense.merchant)
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(1)

            if let nextDate = nextGenerationDate {
                Text("Next: \(nextDate.displayString)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var amountLabel: some View {
        Text(CurrencyFormatter.string(from: expense.amount))
            .font(.body)
            .fontWeight(.semibold)
            .monospacedDigit()
    }

    private var frequencyBadge: some View {
        Text(frequencyLabel)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.blue.opacity(0.12))
            .foregroundStyle(.blue)
            .clipShape(Capsule())
    }

    private var frequencyLabel: String {
        switch expense.recurrenceRule {
        case "weekly": "Weekly"
        case "monthly": "Monthly"
        case "yearly": "Yearly"
        default: "Recurring"
        }
    }

    private var nextGenerationDate: Date? {
        guard let rule = expense.recurrenceRule else { return nil }
        let calendar = Calendar.current
        let from = expense.lastGeneratedDate ?? expense.createdAt
        switch rule {
        case "weekly": return calendar.date(byAdding: .weekOfYear, value: 1, to: from)
        case "monthly": return calendar.date(byAdding: .month, value: 1, to: from)
        case "yearly": return calendar.date(byAdding: .year, value: 1, to: from)
        default: return nil
        }
    }
}
