import SwiftUI
import SwiftData

struct CategoryPicker: View {
    @Binding var selection: Category?
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query private var allPreferences: [UserPreferences]

    @State private var showingAllCategories = false

    private var prefs: UserPreferences? { allPreferences.first }

    private var featuredCategories: [Category] {
        let ids = prefs?.featuredCategoryIDs ?? []
        // Preserve the featured order
        return ids.compactMap { id in categories.first { $0.id == id } }
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(featuredCategories) { category in
                    CategoryCard(
                        category: category,
                        isSelected: selection?.id == category.id
                    )
                    .onTapGesture { selection = category }
                }
            }

            Button {
                showingAllCategories = true
            } label: {
                HStack {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                    Text(selection.flatMap { cat in
                        featuredCategories.contains(where: { $0.id == cat.id }) ? nil : cat.name
                    } ?? "Other")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.primary)
            }
        }
        .sheet(isPresented: $showingAllCategories) {
            AllCategoriesSheet(selection: $selection, categories: categories)
        }
    }
}

// MARK: - All Categories Sheet

private struct AllCategoriesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: Category?
    let categories: [Category]

    @State private var searchText = ""

    private var filtered: [Category] {
        if searchText.isEmpty { return categories }
        let query = searchText.lowercased()
        return categories.filter { $0.name.lowercased().contains(query) }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { category in
                Button {
                    selection = category
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .foregroundStyle(category.swiftUIColor)
                            .frame(width: 28)
                        Text(category.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        if selection?.id == category.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search categories")
            .navigationTitle("All Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Category Card

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
