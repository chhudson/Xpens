import SwiftUI
import SwiftData

struct FeaturedCategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query private var allPreferences: [UserPreferences]

    private var prefs: UserPreferences? { allPreferences.first }

    private var featuredIDs: Set<UUID> {
        Set(prefs?.featuredCategoryIDs ?? [])
    }

    var body: some View {
        List {
            Section {
                Text("Choose up to 4 categories for the quick-pick grid when adding expenses.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section {
                ForEach(categories) { category in
                    Button {
                        toggle(category)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: category.icon)
                                .foregroundStyle(category.swiftUIColor)
                                .frame(width: 28)
                            Text(category.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            if featuredIDs.contains(category.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Featured Categories")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggle(_ category: Category) {
        guard let prefs else { return }
        var ids = prefs.featuredCategoryIDs
        if let index = ids.firstIndex(of: category.id) {
            ids.remove(at: index)
        } else {
            guard ids.count < 4 else { return }
            ids.append(category.id)
        }
        prefs.featuredCategoryIDs = ids
    }
}
