import SwiftUI
import SwiftData

struct CategoryPicker: View {
    @Binding var selection: Category?
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(categories) { category in
                CategoryCard(
                    category: category,
                    isSelected: selection?.id == category.id
                )
                .onTapGesture { selection = category }
            }
        }
    }
}

private struct CategoryCard: View {
    let category: Category
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.title2)
            Text(category.name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(
            isSelected
                ? category.swiftUIColor.opacity(0.15)
                : Color(.secondarySystemBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? category.swiftUIColor : .clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .foregroundStyle(isSelected ? category.swiftUIColor : .primary)
    }
}
