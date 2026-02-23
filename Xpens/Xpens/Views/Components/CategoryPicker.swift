import SwiftUI

struct CategoryPicker: View {
    @Binding var selection: ExpenseCategory

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(ExpenseCategory.allCases) { category in
                CategoryCard(
                    category: category,
                    isSelected: selection == category
                )
                .onTapGesture { selection = category }
            }
        }
    }
}

private struct CategoryCard: View {
    let category: ExpenseCategory
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.title2)
            Text(category.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(
            isSelected
                ? category.color.opacity(0.15)
                : Color(.secondarySystemBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? category.color : .clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .foregroundStyle(isSelected ? category.color : .primary)
    }
}
