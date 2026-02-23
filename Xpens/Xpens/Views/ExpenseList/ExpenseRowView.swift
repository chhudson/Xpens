import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            categoryIcon
            details
            Spacer()
            amountLabel
        }
        .padding(.vertical, 4)
    }

    private var categoryIcon: some View {
        Image(systemName: expense.category?.icon ?? "questionmark")
            .font(.title3)
            .foregroundStyle(expense.category?.swiftUIColor ?? .gray)
            .frame(width: 36, height: 36)
            .background((expense.category?.swiftUIColor ?? .gray).opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(expense.merchant)
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(1)

            HStack(spacing: 6) {
                if !expense.client.isEmpty {
                    Text(expense.client)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Text(expense.date.displayString)
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
}
