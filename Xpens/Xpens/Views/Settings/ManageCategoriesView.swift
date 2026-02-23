import SwiftUI
import SwiftData

struct ManageCategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @State private var showingAddSheet = false
    @State private var categoryToDelete: Category?
    @State private var reassignTarget: Category?
    @State private var showingReassignAlert = false

    var body: some View {
        List {
            ForEach(categories) { category in
                NavigationLink {
                    EditCategoryView(category: category)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .foregroundStyle(category.swiftUIColor)
                            .frame(width: 28)
                        Text(category.name)
                        Spacer()
                        if category.isDefault {
                            Text("Default")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .onDelete(perform: requestDelete)
        }
        .accessibilityIdentifier(AccessibilityID.ManageCategories.list)
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier(AccessibilityID.ManageCategories.addButton)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCategoryView()
        }
        .alert("Reassign Expenses", isPresented: $showingReassignAlert) {
            ForEach(categories.filter { $0.id != categoryToDelete?.id }) { cat in
                Button(cat.name) {
                    deleteCategory(reassignTo: cat)
                }
            }
            Button("Cancel", role: .cancel) {
                categoryToDelete = nil
            }
        } message: {
            let count = categoryToDelete?.expenses?.count ?? 0
            Text("This category has \(count) expense\(count == 1 ? "" : "s"). Choose a category to reassign them to.")
        }
    }

    private func requestDelete(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let category = categories[index]
        let expenseCount = category.expenses?.count ?? 0

        if expenseCount > 0 {
            categoryToDelete = category
            showingReassignAlert = true
        } else {
            modelContext.delete(category)
        }
    }

    private func deleteCategory(reassignTo target: Category) {
        guard let category = categoryToDelete else { return }
        for expense in category.expenses ?? [] {
            expense.category = target
        }
        modelContext.delete(category)
        categoryToDelete = nil
    }
}

// MARK: - Add Category

private struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @State private var name = ""
    @State private var icon = "folder"
    @State private var color = "#607D8B"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("SF Symbol", text: $icon)
                HStack {
                    Text("Color")
                    Spacer()
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 24, height: 24)
                }
                TextField("Hex Color", text: $color)
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let cat = Category(
                            name: name,
                            icon: icon,
                            color: color,
                            sortOrder: categories.count
                        )
                        modelContext.insert(cat)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Category

private struct EditCategoryView: View {
    @Bindable var category: Category

    var body: some View {
        Form {
            TextField("Name", text: $category.name)
            TextField("SF Symbol", text: $category.icon)
            HStack {
                Text("Color")
                Spacer()
                Circle()
                    .fill(category.swiftUIColor)
                    .frame(width: 24, height: 24)
            }
            TextField("Hex Color", text: $category.color)
        }
        .navigationTitle("Edit Category")
        .navigationBarTitleDisplayMode(.inline)
    }
}
