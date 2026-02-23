import SwiftUI
import SwiftData

enum ExpenseSortOrder: String, CaseIterable, Identifiable {
    case dateDescending = "Newest First"
    case dateAscending = "Oldest First"
    case amountDescending = "Highest Amount"
    case amountAscending = "Lowest Amount"

    var id: String { rawValue }
}

struct ExpenseFilterView: View {
    @Binding var selectedCategory: Category?
    @Binding var selectedClient: String
    @Binding var selectedTags: Set<UUID>
    @Binding var sortOrder: ExpenseSortOrder
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query(sort: \Tag.name) private var tags: [Tag]

    let availableClients: [String]

    var body: some View {
        NavigationStack {
            Form {
                categorySection
                tagSection
                clientSection
                sortSection
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") { resetFilters() }
                }
            }
        }
    }

    private var categorySection: some View {
        Section("Category") {
            Button("All Categories") {
                selectedCategory = nil
            }
            .foregroundStyle(selectedCategory == nil ? .primary : .secondary)

            ForEach(categories) { cat in
                Button {
                    selectedCategory = cat
                } label: {
                    HStack {
                        Label(cat.name, systemImage: cat.icon)
                            .foregroundStyle(cat.swiftUIColor)
                        Spacer()
                        if selectedCategory?.id == cat.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
    }

    private var clientSection: some View {
        Section("Client") {
            TextField("Filter by client", text: $selectedClient)
                .autocorrectionDisabled()

            if !availableClients.isEmpty {
                ForEach(availableClients, id: \.self) { client in
                    Button(client) {
                        selectedClient = client
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
    }

    private var sortSection: some View {
        Section("Sort By") {
            Picker("Sort Order", selection: $sortOrder) {
                ForEach(ExpenseSortOrder.allCases) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }

    private var tagSection: some View {
        Section("Tags") {
            if tags.isEmpty {
                Text("No tags created yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(tags) { tag in
                    Button {
                        if selectedTags.contains(tag.id) {
                            selectedTags.remove(tag.id)
                        } else {
                            selectedTags.insert(tag.id)
                        }
                    } label: {
                        HStack {
                            Circle()
                                .fill(tag.swiftUIColor)
                                .frame(width: 10, height: 10)
                            Text(tag.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedTags.contains(tag.id) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
        }
    }

    private func resetFilters() {
        selectedCategory = nil
        selectedClient = ""
        selectedTags = []
        sortOrder = .dateDescending
    }
}
